#!/usr/bin/env python3
# simple waybar module for todoist

import csv
import subprocess
import sys

def get_tasks():
    try:
        process = subprocess.run(["task"] + query + ["export"], capture_output=True, check=True)
    except subprocess.CalledProcessError:
        # prevent failure as it messes with waybar
        return []

    stdout = process.stdout.decode("utf-8")
    obj = json.loads(stdout)

    return obj
