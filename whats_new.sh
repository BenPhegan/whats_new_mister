#!/usr/bin/env python
import datetime
import os
from pathlib import Path
import glob
import configparser

config = configparser.ConfigParser()
config.read("whats_new.ini")

# Where is the default root?  We will use the parent of the directory the script is in, assuming we are in /media/fat/Scripts
DEFAULT_ROOT = config.get(
    "DEFAULTS",
    "root",
    fallback=os.getenv(
        "ROOT",
        Path(Path(os.path.abspath(__file__)).parent).parent
    )
)

# Where is the arcade root?
ARCADE_ROOT = config.get(
    "DEFAULTS",
    "arcade_root",
    fallback=os.getenv("ARCADE_ROOT", os.path.join(DEFAULT_ROOT, "_Arcade"))
)

# By default we will use the directory name "_@WhatsNew" but this can be overridden in the config file of environment variable
WHATS_NEW_DIRECTORY_NAME = config.get(
    "DEFAULTS", "whats_new_directory_name", fallback="_@WhatsNew"
)

# Where are we going to store the symbolic links to the new files
WHATS_NEW_ROOT = config.get(
    "DEFAULTS",
    "whats_new_root",
    fallback=os.path.join(DEFAULT_ROOT, WHATS_NEW_DIRECTORY_NAME)
)

# If we update less than this number of files, we will just add them to the existing list.
MINIMUN_NUMBER_OF_FILES = config.getint(
    "DEFAULTS", "minimum_number_of_files", fallback=3
)

# We will show the last set of three updates by default.
NUMBER_OF_UPDATES_TO_SHOW = config.getint(
    "DEFAULTS",
    "number_of_updates_to_show",
    fallback=int(os.getenv("NUMBER_OF_UPDATES_TO_SHOW", 3))
)


def main():
    print(f"ARCADE_ROOT: {ARCADE_ROOT}")
    print(f"WHATS_NEW_ROOT: {WHATS_NEW_ROOT}")
    print(f"MINIMUN_NUMBER_OF_FILES: {MINIMUN_NUMBER_OF_FILES}")
    print(f"NUMBER_OF_UPDATES_TO_SHOW: {NUMBER_OF_UPDATES_TO_SHOW}")

    mra_files = glob.glob(f"{ARCADE_ROOT}/*.mra")

    files_by_hour = {}

    for mra_file in mra_files:
        file_modified_time = datetime.datetime.fromtimestamp(
            os.path.getmtime(mra_file)
        )
        # We will be bucketing by hour, and will take the last modified set of files over an hour and use that as our "What's New" list
        file_modified_hour = file_modified_time.replace(
            minute=0, second=0, microsecond=0
        )
        if file_modified_hour not in files_by_hour:
            files_by_hour[file_modified_hour] = []
        files_by_hour[file_modified_hour].append(mra_file)

    # Check to see if we have any keys in the dictionary
    if not files_by_hour:
        print("No files found, exiting")
        return

    hour_keys = sorted([hour for hour in files_by_hour.keys()])
    hour_keys.reverse()
    selected_files = []
    hour_ranges = []

    for i in range(0, NUMBER_OF_UPDATES_TO_SHOW):
        if i >= len(hour_keys):
            break
        hour_key = hour_keys[i]
        hour_ranges.append(hour_key)
        selected_files.extend(files_by_hour[hour_key])

    # If we did not find any files, then lets print out a message and exit
    if len(selected_files) == 0:
        print(f"Did not find enough new files to create a 'What's New' list.")
        return

    print(f"Last set of updated files found at: {hour_ranges}")
    print(f"Files found: {selected_files}")

    # So now we have our list, we need to create a file symbolic link to each of these files to a new directory called _WhatsNew
    if not os.path.exists(WHATS_NEW_ROOT):
        os.mkdir(WHATS_NEW_ROOT)

    # We need to make sure that the cores are in place, otherwise our symbolic links will not launch
    if not os.path.exists(os.path.join(WHATS_NEW_ROOT, "cores")):
        os.symlink(
            os.path.join(ARCADE_ROOT, "cores"),
            os.path.join(WHATS_NEW_ROOT, "cores")
        )

    # If it has been a small update, we may want to keep the old ones there, otherwise delete our existing links
    if len(selected_files) > MINIMUN_NUMBER_OF_FILES:
        for file in glob.glob(f"{WHATS_NEW_ROOT}/*.mra"):
            os.remove(file)

    for mra_file in selected_files:
        mra_file_path = os.path.join(WHATS_NEW_ROOT, os.path.basename(mra_file))
        # We need to check whether the file exists, and remove it if it does
        if os.path.exists(mra_file_path):
            print(f"Removing existing symbolic link: {mra_file_path}")
            os.remove(mra_file_path)

        print(f"Creating symbolic link for {mra_file_path}")
        os.symlink(mra_file, mra_file_path)


if __name__ == "__main__":
    main()
