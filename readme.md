# What's New Menu for MisterFPGA

This script provides a new menu within the MisterFPGA called "@WhatsNew".  Under this directory, it will link the latest set of Arcade core updates (the last three by default).

## The Problem

Whenever I ran `update_all.sh` and downloaded new Arcade cores, they would dissappear into a big long list, and I would struggle to find and play them.  I knew I was missing out!  So, I wanted to update a menu whenever I ran `update_all.sh` to automatically populate a list to get my attention!

## How to Install

1. Copy the files `whats_new.sh` to you script directory (generally `/media/fat/Scripts`).  
2. Optionally, add a `whats_new.ini` file if you feel like modifying any of the defaults.

## How to Run

Once you have run  `update_all.sh` or manually updated files, just run `whats_new.sh` from your Scripts directory.  It will create the directory structure and symbolic links to show you the latest updates.

The script only creates symbolic links, it does not copy anything.  To remove the resultant menu, just delete the directory.

## Defaults

Check the script for the defaults.  Overrides are taken from the `whats_new.ini`, then environment variables, then the defaults, in that order.