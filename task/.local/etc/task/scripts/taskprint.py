#!/usr/bin/env python3

import datetime
import json
import re
import sys


def bst_start(year):
    """(UTC) 01:00 on the last Sunday in March for a given year

    Returns a naive datetime which is actually in UTC.
    """
    x = datetime.datetime(year, 3, 31, 1, 0, 0)
    while x.weekday() != 6:
        x = x - datetime.timedelta(days=1)
    return x


def bst_end(year):
    """(UTC) 01:00 on the last Sunday in October for a given year

    Returns a naive datetime which is actually in UTC.
    """
    x = datetime.datetime(year, 10, 31, 1, 0, 0)
    while x.weekday() != 6:
        x = x - datetime.timedelta(days=1)
    return x


def ts_is_past(ts):
    """Determine if a taskwarrior timestamp string is in the past"""
    ts_utc = datetime.datetime.strptime(ts, "%Y%m%dT%H%M%SZ")
    now_utc = datetime.datetime.utcnow()
    return ts_utc < now_utc


def ts_is_future(ts):
    """Determine if a taskwarrior timestamp string is in the future"""
    ts_utc = datetime.datetime.strptime(ts, "%Y%m%dT%H%M%SZ")
    now_utc = datetime.datetime.utcnow()
    return ts_utc > now_utc


def tasklist_sort(tl):
    """Sort a list of tasks according to my preference"""
    # Take out tasks which are waiting (to be stacked on to the end later)
    waiting = [task for task in tl if task["status"] == "waiting"]
    tl = [task for task in tl if task["status"] != "waiting"]
    waiting.sort(key=lambda task: task["wait"])

    # Take out tasks which are scheduled for the future (to be stacked on to the
    # end later)
    scheduled_future = [task for task in tl
                        if "scheduled" in task and
                        ts_is_future(task["scheduled"])]
    tl = [task for task in tl
          if "scheduled" not in task or not ts_is_future(task["scheduled"])]
    scheduled_future.sort(key=lambda task: task["scheduled"])

    # First: overdue tasks, sorted by due date
    overdue = [task for task in tl
               if "due" in task and ts_is_past(task["due"])]
    tl = [task for task in tl
          if "due" not in task or not ts_is_past(task["due"])]
    overdue.sort(key=lambda task: task["due"])
    tl_sorted = overdue

    # Next: tasks which have been scheduled, and the scheduled date has
    # past (sorted by scheduled date).  Future scheduled tasks have already
    # been removed.
    scheduled = [task for task in tl if "scheduled" in task]
    tl = [task for task in tl if "scheduled" not in task]
    scheduled.sort(key=lambda task: task["scheduled"])
    tl_sorted.extend(scheduled)

    # Next: remaining tasks, sorted by modification date
    tl_sorted.extend(sorted(tl, key=lambda task: task["modified"]))

    # Next: future scheduled tasks
    tl_sorted.extend(scheduled_future)

    # Last: add the waiting tasks on to the end
    tl_sorted.extend(waiting)

    return tl_sorted


def colour(text, num):
    """Wrap text in ANSI escape sequences to produce foreground colours

    Uses the gruvbox colour palette, where num is the 256 colour code.
    """
    colours = {
        235: (0x28, 0x28, 0x28), 124: (0xCC, 0x24, 0x1D),
        106: (0x98, 0x97, 0x1A), 172: (0xD7, 0x99, 0x21),
        66: (0x45, 0x85, 0x88), 132: (0xB1, 0x62, 0x86),
        72: (0x68, 0x9D, 0x6A), 246: (0xA8, 0x99, 0x84),
        245: (0x92, 0x83, 0x74), 167: (0xFB, 0x49, 0x34),
        142: (0xB8, 0xBB, 0x26), 214: (0xFA, 0xBD, 0x2F),
        109: (0x83, 0xA5, 0x98), 175: (0xD3, 0x86, 0x9B),
        108: (0x8E, 0xC0, 0x7C), 223: (0xEB, 0xDB, 0xB2),
        234: (0x1D, 0x20, 0x21), 235: (0x28, 0x28, 0x28),
        237: (0x3C, 0x38, 0x36), 239: (0x50, 0x49, 0x45),
        241: (0x66, 0x5C, 0x54), 243: (0x7C, 0x6F, 0x64),
        166: (0xD6, 0x5D, 0x0E), 236: (0x32, 0x30, 0x2F),
        246: (0xA8, 0x99, 0x84), 248: (0xBD, 0xAE, 0x93),
        250: (0xD5, 0xC4, 0xA1), 229: (0xFB, 0xF1, 0xC7),
        208: (0xFE, 0x80, 0x19)
    }

    if num not in colours:
        raise ValueError

    output = "".join([
        "\033[38;2;{};{};{}m".format(*colours[num]),
        str(text),
        "\033[0m"
    ])

    return output


def datef(ts):
    """Turn a Taskwarrior timestamp into natural language date representation"""
    ts_utc = datetime.datetime.strptime(ts, "%Y%m%dT%H%M%SZ")
    if (ts_utc > bst_start(ts_utc.year) and
            ts_utc < bst_end(ts_utc.year)):
        ts_local = ts_utc + datetime.timedelta(hours=1)
    else:
        ts_local = ts_utc

    ts_date = ts_local.date()
    today_date = datetime.date.today()

    if ts_date < today_date:
        output = ts_date.strftime("%Y-%m-%d")
    elif ts_date == today_date:
        output = "today"
    elif (ts_date - today_date).days == 1:
        output = "tomorrow"
    elif (ts_date - today_date).days <= 6:
        output = ts_date.strftime("%a")
    else:
        output = ts_date.strftime("%Y-%m-%d")

    return output


def rawlen(formatted_text):
    """Get length of string having removed ANSI formatting codes"""
    if not formatted_text:
        return 0

    raw_text = re.sub("\033[^m]+m", "", formatted_text)
    return len(raw_text)


def main():
    tasklist = tasklist_sort(json.load(sys.stdin))
    if not tasklist:
        sys.exit("No matches")

    tasklist_formatted = []
    for task in tasklist:
        task_formatted = {}

        if task["status"] == "waiting":
            task_formatted["id"] = colour(task["id"], 245)
        else:
            task_formatted["id"] = colour(task["id"], 172)

        flags = ""
        if "annotations" in task:
            flags = flags + "¶"
        if "depends" in task:
            flags = flags + "⊂"
        if task["status"] == "waiting":
            task_formatted["flags"] = colour(flags, 245)
        else:
            task_formatted["flags"] = flags

        if task["status"] == "waiting":
            task_formatted["description"] = colour(task["description"], 245)
        elif "due" in task and ts_is_past(task["due"]):
            task_formatted["description"] = colour(task["description"], 167)
        else:
            task_formatted["description"] = task["description"]

        if "wait" in task:
            task_formatted["wait"] = colour(
                "w:{}".format(datef(task["wait"])),
                245
            )
        else:
            task_formatted["wait"] = ""

        if ("scheduled" in task and
                (task["status"] == "waiting" or ts_is_past(task["scheduled"]))):
            task_formatted["scheduled"] = colour(
                "s:{}".format(datef(task["scheduled"])),
                245
            )
        elif "scheduled" in task:
            task_formatted["scheduled"] = colour(
                "s:{}".format(datef(task["scheduled"])),
                108
            )
        else:
            task_formatted["scheduled"] = ""

        if "due" in task and task["status"] == "waiting":
            task_formatted["due"] = colour(
                "d:{}".format(datef(task["due"])),
                245
            )
        elif "due" in task and ts_is_future(task["due"]):
            task_formatted["due"] = colour(
                "d:{}".format(datef(task["due"])),
                166
            )
        elif "due" in task:
            task_formatted["due"] = colour(
                "d:{}".format(datef(task["due"])),
                167
            )
        else:
            task_formatted["due"] = ""

        if "tags" in task and task["status"] == "waiting":
            task_formatted["tags"] = colour(
                " ".join(["+" + tag for tag in task["tags"]]),
                245
            )
        elif "tags" in task:
            task_formatted["tags"] = colour(
                " ".join(["+" + tag for tag in task["tags"]]),
                132
            )
        else:
            task_formatted["tags"] = ""

        if "project" in task:
            task_formatted["project"] = task["project"]
        else:
            task_formatted["project"] = "[Inbox]"

        tasklist_formatted.append(task_formatted)

    col_len = {
        "id": max([rawlen(t["id"]) for t in tasklist_formatted]),
        "flags": max([rawlen(t["flags"]) for t in tasklist_formatted]),
        "description": max(
            [rawlen(t["description"]) for t in tasklist_formatted]
        ),
        "wait": max([rawlen(t["wait"]) for t in tasklist_formatted]),
        "scheduled": max([rawlen(t["scheduled"]) for t in tasklist_formatted]),
        "due": max([rawlen(t["due"]) for t in tasklist_formatted]),
        "tags": max([rawlen(t["tags"]) for t in tasklist_formatted])
    }

    projects = sorted(
        list(set([t["project"] for t in tasklist_formatted if "project" in t]))
    )
    spacer = " " * 5
    for project in projects:
        print()
        print(colour(project, 108))
        tl_proj = [t for t in tasklist_formatted if t["project"] == project]

        for task in tl_proj:
            # Note that str.ljust does not correctly pad strings with ANSI
            # escape sequences in
            print("".join([
                task["id"],
                " " * (col_len["id"] - rawlen(task["id"])),
                spacer
            ]), end="")
            if col_len["flags"]:
                print("".join([
                    task["flags"],
                    " " * (col_len["flags"] - rawlen(task["flags"])),
                    " "
                ]), end="")
            print("".join([
                task["description"],
                " " * (col_len["description"] - rawlen(task["description"])),
                spacer
            ]), end="")
            if col_len["wait"]:
                print("".join([
                    task["wait"],
                    " " * (col_len["wait"] - rawlen(task["wait"])),
                    spacer
                ]), end="")
            if col_len["scheduled"]:
                print("".join([
                    task["scheduled"],
                    " " * (col_len["scheduled"] - rawlen(task["scheduled"])),
                    spacer
                ]), end="")
            if col_len["due"]:
                print("".join([
                    task["due"],
                    " " * (col_len["due"] - rawlen(task["due"])),
                    spacer
                ]), end="")
            if col_len["tags"]:
                print("".join([
                    task["tags"],
                    " " * (col_len["tags"] - rawlen(task["tags"])),
                    spacer
                ]), end="")
            print()
        print()


if __name__ == "__main__":
    main()
