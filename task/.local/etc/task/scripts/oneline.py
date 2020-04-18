#!/usr/bin/env python3

import json
import re
import sys


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


def rawlen(formatted_text):
    """Get length of string having removed ANSI formatting codes"""
    if not formatted_text:
        return 0

    raw_text = re.sub("\033[^m]+m", "", formatted_text)
    return len(raw_text)


def main():
    """Format Taskwarrior JSON into one line with colours for piping to fzf"""
    tasklist = json.load(sys.stdin)
    tasklist.sort(key=lambda t: int(t["id"]))

    tasklist_formatted = []
    for task in tasklist:
        task_formatted = {}

        task_formatted["id"] = colour(task["id"], 172)

        task_formatted["description"] = task["description"]

        if "annotations" in task:
            task_formatted["annotations"] = " | ".join(
                [x["description"] for x in task["annotations"]]
            )
        else:
            task_formatted["annotations"] = ""

        if "project" in task:
            task_formatted["project"] = colour(task["project"], 108)
        else:
            task_formatted["project"] = colour("Inbox", 108)

        if "tags" in task:
            task_formatted["tags"] = colour(
                " ".join(["+" + tag for tag in task["tags"]]),
                132
            )
        else:
            task_formatted["tags"] = ""

        tasklist_formatted.append(task_formatted)

    col_len = {
        "id": max([rawlen(t["id"]) for t in tasklist_formatted]),
        "description": max(
            [rawlen(t["description"]) for t in tasklist_formatted]
        ),
        "annotations": max(
            [rawlen(t["annotations"]) for t in tasklist_formatted]
        ),
        "project": max([rawlen(t["project"]) for t in tasklist_formatted]),
        "tags": max([rawlen(t["tags"]) for t in tasklist_formatted])
    }

    spacer = " " * 2
    for task in tasklist_formatted:
        # Note that str.ljust does not correctly pad strings with ANSI escape
        # sequences in
        print("".join([
            task["id"],
            " " * (col_len["id"] - rawlen(task["id"])),
            spacer
        ]), end="")
        print("".join([
            task["project"],
            " " * (col_len["project"] - rawlen(task["project"])),
            spacer
        ]), end="")
        print("".join([
            task["description"],
            " " * (col_len["description"] - rawlen(task["description"])),
            spacer
        ]), end="")
        print("".join([
            task["tags"],
            " " * (col_len["tags"] - rawlen(task["tags"])),
            spacer
        ]), end="")
        if task["annotations"]:
            print("[{}]".format(task["annotations"]), end="")
        print()


if __name__ == "__main__":
    main()
