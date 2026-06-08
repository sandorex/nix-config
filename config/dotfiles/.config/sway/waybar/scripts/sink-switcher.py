#!/usr/bin/env python 
# simple rofi sink switcher
#
# TODO clean it up

import subprocess

# function to parse output of command "wpctl status" and return a dictionary of sinks with their id and name.
def parse_wpctl_status():
    # Execute the wpctl status command and store the output in a variable.
    process = subprocess.run(["wpctl", "status"], capture_output=True, check=True)

    output = process.stdout.decode("utf-8")

    # remove non-ascii characters
    lines = output.encode("ascii", errors="ignore").decode().splitlines()

    # get the index of the Sinks line as a starting point
    sinks_index = None
    for index, line in enumerate(lines):
        if "Sinks:" in line:
            sinks_index = index
            break

    # start by getting the lines after "Sinks:" and before the next blank line and store them in a list
    sinks = []
    for line in lines[sinks_index + 1:]:
        if not line.strip():
            break
        sinks.append(line.strip())

    # remove the "[vol:" from the end of the sink name
    for index, sink in enumerate(sinks):
        sinks[index] = sink.split("[vol:")[0].strip()

    # return structured dict
    sinks_dict = [
        {
            "sink_id": int(sink.split(".")[0].replace("*", "").strip()),
            "sink_name": sink.split(".")[1].strip(),
            "default": "*" in sink,
        } for sink in sinks
    ]

    return sinks_dict

output = ''
sinks = parse_wpctl_status()
for items in sinks:
    if items['default'] == True:
        output += f"<b>{items['sink_name']} (current)</b>\n"
    else:
        output += f"{items['sink_name']}\n"

output = output.strip()

wofi_command = f"echo '{output}' | rofi -dmenu -markup-rows -i -no-custom -format i -p 'Select sink'"
wofi_process = subprocess.run(wofi_command, shell=True, encoding='utf-8', stdout=subprocess.PIPE, stderr=subprocess.PIPE)

if wofi_process.returncode != 0:
    print("User cancelled the operation.")
    exit(0)

sink_index = int(wofi_process.stdout.strip())
sink_id = sinks[sink_index]["sink_id"]
subprocess.run(["wpctl", "set-default", str(sink_id)], capture_output=True, check=True)
