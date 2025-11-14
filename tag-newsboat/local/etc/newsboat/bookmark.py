#!/usr/bin/env python3

import argparse
import json
import re
import sys
import urllib.error
import urllib.parse
import urllib.request
import xml.etree.ElementTree


def get_zotero_creds(file):
    """Read Zotero API key from line 2 of file and also return user id"""
    with open(file, "r") as f:
        api_key = f.readlines()[1].strip()

    req = urllib.request.Request(f"https://api.zotero.org/keys/{api_key}")
    req.add_header("Zotero-API-Version", "3")
    res = urllib.request.urlopen(req).read().decode("utf-8")
    user_id = json.loads(res)["userID"]

    return {"api_key": api_key, "user_id": user_id}


def get_instapaper_creds(file):
    """Read instapaper credentials from line 3 of file"""
    with open(file, "r") as f:
        line = f.readlines()[2].strip()

    return {"username": line.split(":")[0], "password": line.split(":")[1]}


def url2pmid(url):
    """Take a pubmed URL and extract the pmid"""
    match = re.search(r"/(\d+)/", url)
    if not match:
        print(f"Could not extract PMID from {url}")
        sys.exit(1)
    else:
        return match[1]


def get_from_pubmed(pmid):
    """Return a python dict containing article info

    Some of the pubmed XML parsing logic is based on Zotero's translator:
    https://github.com/zotero/translators/blob/master/PubMed%20XML.js
    """
    pmurl = (
        "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?"
        f"db=pubmed&id={pmid}&retmode=xml"
    )
    try:
        pmxml = urllib.request.urlopen(pmurl).read().decode("utf-8")
        tree = xml.etree.ElementTree.fromstring(pmxml)
    except urllib.error.HTTPError as e:
        print(f"HTTP {e.code} received when querying PubMed")
        sys.exit(1)
    except xml.etree.ElementTree.ParseError as e:
        print(f"{e.code} error when parsing PubMed XML")
        sys.exit(1)

    if len(tree) == 0:
        print(f"No results querying PubMed for PMID {pmid}")
        sys.exit(1)

    output = {"itemType": "journalArticle"}
    article = tree.find(".//Article")

    # Can't just do:
    #   output["title"] = article.findtext("./ArticleTitle").strip(". ")
    # because sometimes the title includes HTML tags like <sup>
    title_et = article.find("./ArticleTitle")
    if title_et is None:
        title_et = article.find("./VernacularTitle")
    if title_et is not None:
        title = xml.etree.ElementTree.tostring(title_et, encoding="unicode")
        # Remove opening and closing <ArticleTitle>/<VernacularTitle> tags
        output["title"] = re.sub(r"^[^>]*>|<[^<]*$", "", title).strip("\n .")

    creators = []
    for author_et in article.findall("./AuthorList/Author"):
        if author_et.findtext("./Type") == "editors":
            creatorType = "editor"
        else:
            creatorType = "author"
        firstName = author_et.findtext("./FirstName")
        if not firstName:
            firstName = author_et.findtext("./ForeName")
        if firstName and author_et.find("./Suffix"):
            firstName = ", ".join([firstName, author_et.findtext("./Suffix")])
        lastName = author_et.findtext("./LastName")
        if firstName and firstName.isupper():
            firstName = firstName.title()
        if lastName and lastName.isupper():
            lastName = lastName.title()
        if firstName or lastName:
            creators.append(
                {
                    "creatorType": creatorType,
                    "firstName": firstName or "",
                    "lastName": lastName or "",
                }
            )
        elif author_et.find("./CollectiveName"):
            creators.append(
                {
                    "creatorType": creatorType,
                    "lastName": author_et.findtext("./CollectiveName"),
                    "fieldMode": 1,
                }
            )
    output["creators"] = creators

    abstract_list = []
    for abstract_part_et in article.findall("./Abstract/AbstractText"):
        abstract_part_label = abstract_part_et.get("Label", "")
        if abstract_part_label == "UNLABELLED":
            abstract_part_label = ""
        elif abstract_part_label.isupper():
            abstract_part_label = abstract_part_label.title()
        abstract_part_text = abstract_part_et.text or ""
        abstract_list.append(
            f"{abstract_part_label}\n{abstract_part_text}"
            if abstract_part_label
            else abstract_part_text
        )
    output["abstractNote"] = "\n\n".join(abstract_list)

    if article.find("./Journal"):
        journal_title = article.findtext("./Journal/Title")
        journal_abbrev = article.findtext("./Journal/ISOAbbreviation")
        if not journal_abbrev:
            journal_abbrev = article.findtext("./MedlineJournalInfo/MedlineTA")
        if not journal_title and journal_abbrev:
            journal_title = journal_abbrev
        output["publicationTitle"] = journal_title
        output["journalAbbreviation"] = journal_abbrev
        output["ISSN"] = article.findtext("./Journal/ISSN")

    output["volume"] = article.findtext("./Journal/JournalIssue/Volume")
    output["issue"] = article.findtext("./Journal/JournalIssue/Issue")

    startpage = article.findtext("./Pagination/StartPage")
    endpage = article.findtext("./Pagination/EndPage")
    if not startpage and not endpage:
        medlinepgn = article.findtext("./Pagination/MedlinePgn")
        if medlinepgn:
            medlinepgn_parts = medlinepgn.split("-", 1)
            startpage = medlinepgn_parts[0]
            endpage = medlinepgn_parts[1] if len(medlinepgn_parts) > 1 else None
    if startpage and not endpage:
        output["pages"] = startpage
    elif startpage and endpage:
        pagelendiff = len(startpage) - len(endpage)
        if pagelendiff > 0:
            endpage = startpage[:pagelendiff] + endpage
        output["pages"] = "-".join([startpage, endpage])
    else:
        output["pages"] = article.findtext("./ELocationID[@EIdType='pii']")

    pubday = article.findtext("./Journal/JournalIssue/PubDate/Day")
    pubmonth = article.findtext("./Journal/JournalIssue/PubDate/Month")
    pubyear = article.findtext("./Journal/JournalIssue/PubDate/Year")
    pubday = pubday.zfill(2) if pubday and pubday.isdigit() else None
    if pubmonth:
        if pubmonth.isdigit():
            pubmonth = pubmonth.zfill(2)
        else:
            months = {
                "jan": "01",
                "feb": "02",
                "mar": "03",
                "apr": "04",
                "may": "05",
                "jun": "06",
                "jul": "07",
                "aug": "08",
                "sep": "09",
                "oct": "10",
                "nov": "11",
                "dec": "12",
            }
            try:
                pubmonth = months[pubmonth.strip()[:3].lower()]
            except KeyError:
                pubmonth = None
    if pubyear and pubmonth and pubday:
        output["date"] = "-".join([pubyear, pubmonth, pubday])
    elif pubyear and pubmonth:
        output["date"] = "-".join([pubyear, pubmonth])
    elif pubyear:
        output["date"] = pubyear
    else:
        output["date"] = article.findtext("./Journal/JournalIssue/PubDate/MedlineDate")

    output["language"] = article.findtext("./Language")
    output["DOI"] = tree.findtext(
        ".//PubmedData/ArticleIdList/ArticleId[@IdType='doi']"
    )
    output["url"] = f"https://pubmed.ncbi.nlm.nih.gov/{pmid}/"
    output["libraryCatalog"] = "PubMed"
    output["extra"] = f"PMID: {pmid}"

    tags = []
    for kw_et in tree.findall(".//KeywordList/Keyword"):
        tags.append({"tag": kw_et.text, "type": 1})
    output["tags"] = tags

    output["collections"] = ["R9YE82TB"]
    output["relations"] = {}

    # Remove empty items
    required = ("itemType", "tags", "collections", "relations")
    output = {k: v for k, v in output.items() if v or k in required}
    return output


def add_to_zotero(url):
    """Query PubMed for information and add article to Zotero"""
    pmid = url2pmid(url)
    article = get_from_pubmed(pmid)

    required = {"itemType", "tags", "collections", "relations"}
    if not isinstance(article, dict) or not required.issubset(article):
        print("PubMed data extraction failed")
        sys.exit(1)

    zotero_creds = get_zotero_creds("/root/.local/share/newsboat/passwd")
    req = urllib.request.Request(
        f"https://api.zotero.org/users/{zotero_creds['user_id']}/items"
    )
    req.add_header("Zotero-API-Version", "3")
    req.add_header("Zotero-API-Key", zotero_creds["api_key"])
    req.add_header("Content-Type", "application/json")
    data = json.dumps([article]).encode("utf-8")
    try:
        urllib.request.urlopen(req, data)
    except urllib.error.HTTPError as e:
        print(f"HTTP {e.code} received when writing to Zotero")
        sys.exit(1)


def add_to_instapaper(url):
    """Save URL to instapaper"""
    instapaper_creds = get_instapaper_creds("/root/.local/share/newsboat/passwd")
    req = urllib.request.Request("https://www.instapaper.com/api/add")
    data = urllib.parse.urlencode(
        {
            "username": instapaper_creds["username"],
            "password": instapaper_creds["password"],
            "url": url,
        }
    ).encode("utf-8")
    try:
        urllib.request.urlopen(req, data)
    except urllib.error.HTTPError as e:
        print(f"HTTP {e.code} received when saving to instapaper")
        sys.exit(1)


def main():
    """Add URL to Zotero (if PubMed) else Instapaper"""
    parser = argparse.ArgumentParser(description="bookmark-cmd /path/to/bookmark.py")
    parser.add_argument("url")
    parser.add_argument("title")
    parser.add_argument("description")
    parser.add_argument("feed_url")
    args = parser.parse_args()

    if args.url[:31] == "https://pubmed.ncbi.nlm.nih.gov":
        add_to_zotero(args.url)
    else:
        add_to_instapaper(args.url)


if __name__ == "__main__":
    main()
