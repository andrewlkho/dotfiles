#!/usr/bin/env python3

import argparse
import datetime
import json
import subprocess


def summarise(tasks):
    """Given a list of tasks, return how many are overdue and/or available"""
    non_waiting_tasks = [p for p in tasks if p["status"] != "waiting"]
    overdue_tasks = [p for p in non_waiting_tasks if "due" in p and
                     datetime.datetime.strptime(p["due"], "%Y%m%dT%H%M%SZ") <
                     datetime.datetime.utcnow()
                     ]
    return (len(overdue_tasks), len(non_waiting_tasks)-len(overdue_tasks))


def print_proj(tasks, label, proj_lenmax, padding):
    """Print out the project and tasks information on one line"""
    summary = summarise(tasks)

    if summary[0]:
        counts_overdue = colour(str(summary[0]).rjust(2), 167) + " "
    else:
        counts_overdue = "   "
    if summary[1]:
        counts_avail = str(summary[1]).rjust(2)
    else:
        counts_avail = colour(str(summary[1]).rjust(2), 245)
    counts = counts_overdue + counts_avail

    if label in ["INBOX", "TODAY"]:
        name = colour(label.ljust(proj_lenmax), 108)
    elif summary[0]:
        name = colour(label.ljust(proj_lenmax), 167)
    elif summary[1]:
        name = label.ljust(proj_lenmax)
    else:
        name = colour(label.ljust(proj_lenmax), 245)

    print(padding + "  ".join([name, counts]))


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


def main():
    run = subprocess.run([
        "task", "rc.hooks=off", "status:pending", "or", "status:waiting",
        "export"
    ], capture_output=True)
    tasks = json.loads(run.stdout)
    projects = sorted(set([t["project"] for t in tasks if "project" in t]))

    # How long is the longest project name to be printed?  Note that projects
    # with a '.' in them are printed with everything preceding the first '.'
    # excluded i.e. Personal.Foo -> Foo
    proj_lenmax = max([
        len(p[p.find('.')+1:]) if '.' in p else len(p) for p in projects
    ])

    # defined padding to center the project list
    parser = argparse.ArgumentParser(description="Print a project sidebar")
    parser.add_argument("-w", "--width", help="Width of tmux pane")
    args = parser.parse_args()
    if args.width:
        # the outer int() is essentially math.floor for +ve numbers
        padding = " " * int((int(args.width) - proj_lenmax - 7) / 2)
    else:
        padding = " "

    # Inbox = all tasks without a project
    print_proj(
        [t for t in tasks if "project" not in t],
        "INBOX", proj_lenmax, padding
    )
    print("")

    # Today:
    today = json.loads(
        subprocess.run([
            "task", "rc.hooks=off",
            (
                "(scheduled.before:tomorrow or due.before:tomorrow or +today) "
                "and status:pending"
            ), "export"
        ], capture_output=True).stdout
    )
    print_proj(today, "TODAY", proj_lenmax, padding)

    # Next, projects without a '.'
    for project in [p for p in projects if '.' not in p]:
        print_proj(
            [t for t in tasks if "project" in t and t["project"] == project],
            project, proj_lenmax, padding
        )

    # Finally, projects with a '.'
    groups = sorted(set([p[:p.find('.')] for p in projects if '.' in p]))
    for group in groups:
        print(colour(
            "\n" + padding + "- {} ".format(group)
            + "-" * (proj_lenmax + 7 - len(group) - 3),
            214
        ))
        for project in [p for p in projects if p[:len(group)] == group]:
            print_proj(
                [t for t in tasks if "project" in t and
                 t["project"] == project],
                project[project.find('.')+1:], proj_lenmax, padding
            )


if __name__ == "__main__":
    main()
