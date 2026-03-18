#!/usr/bin/env python3
# parses INI files and removes unwanted options
#
# it should be used as clean filter in git

# TODO check if it works properly with keys that dont have a section

import configparser
import sys
import re
import io
import os
import tomllib
import pathlib
import shutil

# config file has the same file just different extension
CFG_PATH = __file__[:-3] + ".toml"

# allows debugging messages
DEBUG = False

def dprint(*args, **kwargs):
    global DEBUG
    if DEBUG:
        print(*args, **kwargs, file=sys.stderr)

try:
    file = os.path.expanduser(sys.argv[1])
except IndexError:
    print("No argument is provided", file=sys.stderr)
    sys.exit(1)

try:
    with open(CFG_PATH, "rb") as fp:
        cfg = tomllib.load(fp)
except FileNotFoundError:
    print(f"Could not find config {CFG_PATH}")
    sys.exit(1)

def verbatim():
    """Just read the file verbatim to stdout and quits"""
    # just write it to the stdout
    with open(file, "r") as f:
        shutil.copyfileobj(f, sys.stdout)

    sys.exit(0)

if not os.path.exists(file):
    print(f"File {file} does not exist", file=sys.stderr)
    sys.exit(1)

filename = os.path.basename(file)
if not filename in cfg:
    # if it is not defined then just print it out verbatim
    print(f"Warning file '{file}' is not configured", file=sys.stderr)
    verbatim()

cfg = cfg[filename]

sections_exact = cfg.get("section", [])
keys_exact = cfg.get("key", [])
sections_regex = cfg.get("regex", {}).get("section", [])
keys_regex = cfg.get("regex", {}).get("key", [])

# do not waste time processing if nothing is to be removed
if not any([sections_exact, keys_exact, sections_regex, keys_regex]):
    verbatim()

# options to emulate KDE INI style
ini = configparser.ConfigParser(
    # kde files sometimes have colons `:` in the key names
    delimiters=("="),

    # kde files have duplicates often
    strict=False,

    allow_unnamed_section=True,
    interpolation=None,
    default_section="",
)
ini.optionxform = str # make it case-sensitive
ini.read(file)

# remove exact sections
for section in sections_exact:
    try:
        dprint(f"E '{section}'")
        ini.remove_section(section)
    except configparser.NoSectionError:
        # i do not care if it fails
        pass

# remove exact keys
for key_raw in keys_exact:
    try:
        section = key_raw[0]
        key = key_raw[1]
    except IndexError:
        print("Invalid key '{key_raw}' in config")
        sys.exit(1)

    try:
        dprint(f"E '{key}' in '{section}'")
        ini.remove_option(section, key)
    except configparser.NoSectionError:
        # i do not care if it fails
        pass

# compile regexes in advance
section_regexes = [ re.compile(x) for x in sections_regex ]
key_regexes = [ re.compile(x) for x in keys_regex ]

for name, section in list(ini.items()):
    for r in section_regexes:
        if r.search(str(name)):
            dprint(f"R '{name}'")
            ini.remove_section(name)
            break
    else:
        for key_name in section:
            for r in key_regexes:
                if r.search(key_name):
                    dprint(f"R '{key_name}' in '{name}'")
                    ini.remove_option(name, key_name)
                    break

with io.StringIO() as file:
    ini.write(file, space_around_delimiters=False)
    file.seek(0)
    content = file.read()

print(content.strip())
