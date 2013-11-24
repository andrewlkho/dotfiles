My RSS setup probably requires a bit of explanation (if only to remind myself).
My ideal feed reader is console-based and lets me navigate a resonable volume of
feeds in a few keystrokes.  I rarely read the articles at the time of browsing;
the two options are either archive/delete or send to instapaper.  The closest I
found was [newsbeuter][1] but unfortunately the configuration just wasn't quite
what I wanted so I ended up cobbling together my own solution.  It is split into
several parts, outlined below.

1.  Feeds are fetched on a periodic basis by [rss2email][2], run via a cronjob.
This e-mails them to `andrewho+rss@andrewho.co.uk` using the fastmail SMTP
servers.

2.  I have a [Sieve][3] rule set up on the fastmail side of things that
files all of the e-mails into the RSS/Incoming subfolder:

        if address "To" "andrewho+rss@andrewho.co.uk" {
            fileinto "INBOX.RSS.Incoming";
        }

3.  Another cronjob downloads the e-mails using offlineimap.  If you look in my
`.offlineimaprc` you will see that I effectively treat this as a separate
mailbox to my main account, just one that happens to share the same credentials:

        nametrans = lambda f: re.sub('^INBOX\.RSS\.', '', f)
        folderfilter = lambda f: re.search('^INBOX\.RSS\.', f)

4.  I use mutt to read the messages in `Incoming`.  Read messages are
automatically moved to `Archive`.  A keyboard shortcut (CTRL-L) moves messages
to `Instapaper` instead.  This is a queue for articles that I want to add to
instapaper.

5.  The `instapaper.py` script, again run periodically as a cronjob, trawls the
`Instapaper` folder, adds each URL to instapaper using the [Simple API][4], and
then moves the message to `Archive`.

The point of this queueing system is that I go through the feeds on a relatively
irregular basis.  Therefore, when I do, I want to be able to go through a large
volume of articles quickly.  Adding each one to instapaper via the API as I come
across it, which was the previous setup I had with newsbeuter, would make things
slow as I would constantly be making API calls.  I'm never in such a rush that I
want it on instapaper *now* (and if I am, I can just run `instapaper.py`
manually).

My crontab includes:

    0  1 * * * /usr/bin/r2e run
    15 1 * * * /usr/bin/offlineimap -a rss
    30 1 * * * /home/andrewlkho/bin/instapaper.py

[1]: http://www.newsbeuter.org/
[2]: http://www.allthingsrss.com/rss2email/
[3]: http://sieve.info
[4]: http://www.instapaper.com/api
