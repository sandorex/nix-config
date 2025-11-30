#!/usr/bin/env python3
# waybar module for taskwarrior

import json
import subprocess
import sys

PAUSED_TASK_TAG = "hold"

def task(query):
    try:
        process = subprocess.run(["task"] + query + ["export"], capture_output=True, check=True)
    except subprocess.CalledProcessError:
        # prevent failure as it messes with waybar
        return []

    stdout = process.stdout.decode("utf-8")
    obj = json.loads(stdout)

    return obj

def next_task(): # use in waybar 󰔟 󰦕 󰦖 󰏄 󰀩 󰅜 󰏧 󰏃
    """
    Get next taskwarrior task including custom logic for paused tasks 
    """
    # show next paused tag first
    paused = task(["status:pending", "limit:1", "+" + PAUSED_TASK_TAG])
    if len(paused) > 0:
        return paused[0]

    # show next non paused tag
    other = task(["status:pending", "limit:1", "-" + PAUSED_TASK_TAG])
    if len(other) > 0:
        return other[0]

    return None

def start_task(id):
    # TODO remove pause tag
    subprocess.run(["task", "start", id], capture_output=True)

def stop_task(id):
    subprocess.run(["task", "stop", id], capture_output=True)

def rofi(args):

def select_task():
    """
    Get next tasks and just choose which to start using rofi 
    """
    # # show next paused tag first
    # paused = task(["status:pending", "limit:1", "+" + PAUSED_TASK_TAG])

    # # show next non paused tag
    # other = task(["status:pending", "limit:1", "-" + PAUSED_TASK_TAG])

    process = subprocess.run(sys.argv[1] + " select-rofi | rofi -dmenu", shell=True, capture_output=True)
    stdout = process.stdout.decode("utf-8")

    # TODO select the specific task and remove tag

    
    return None

def report(text, icon, tooltip):
    print(json.dumps({
        "text": text,
        "alt": icon,
        "tooltip": tooltip
    }), end='\r')

try:
    cmd = sys.argv[1]
except IndexError:
    print(f"Invalid command {cmd}")
    sys.exit(1)

match cmd:
    case "next":
        next_task = next_task()
        if not next_task:
            report("No tasks", "none", "There are no next tasks")
        elif PAUSED_TASK_TAG in next_task.tags:
            report(next_task.description, "paused", next_task.description)
        else:
            report(next_task.description, "active", next_task.description)
    case "pause":
        next_task = next_task()
        if PAUSED_TASK_TAG in next_task.tags:
            start_task(next_task.id)
        else:
            stop_task(next_task.id)
    case "select-rofi":
        pass # print all data for rofi
    case "select":
        pass # show rofi and 

# def get_active_tasks():
#     process = subprocess.run(["task", "export", "active"], capture_output=True)
#     try:
#         process = subprocess.run(["task", "export", "active"], capture_output=True, check=True)
#     except subprocess.CalledProcessError:
#         # prevent failure as it messes with waybar
#         return []

#     stdout = process.stdout.decode("utf-8")
#     obj = json.loads(stdout)

#     return obj

# print(get_next_task())
# match sys.argv[1]:
#     case "active":
#         obj = get_active_tasks()
#         print(obj[0]["description"])
#     case "pause": # pause and resume same task
#         print("TODO")
#     case _:
#         print("Invalid command")
#         sys.exit(1)


