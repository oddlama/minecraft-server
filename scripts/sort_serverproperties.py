#!/usr/bin/env python3

import sys
import re

key_regex = re.compile(r'^\s*([^=]*)=')
comment_regex = re.compile(r'^\s*#')

def is_comment(line):
    return bool(comment_regex.match(line))

def is_empty(line):
    return not line or line is '\n'

class Block:
    def __init__(self):
        self.lines = []
        self.had_value = False
        self.key = None

    def accepts(self, line):
        return is_empty(line) or not self.had_value

    def append(self, line):
        if is_empty(line):
            return

        if not is_comment(line):
            self.key = key_regex.search(line).group(1)
            self.had_value = True
        self.lines.append(line)

if len(sys.argv) != 2:
    print("usage: {} <server.properties>".format(sys.argv[0]))
    sys.exit(1)

filename = sys.argv[1]
print(f"Sorting {filename}")

content = []
with open(filename, 'r') as file:
    content = file.readlines()

# Strip comment header
header = []
for line in content:
    if is_comment(line):
        header.append(line)
    else:
        break
content = content[len(header):]

# Parse in blocks to retain comments
blocks = []
cur = Block()
for line in content:
    if cur.accepts(line):
        cur.append(line)
    else:
        blocks.append(cur)
        cur = Block()
        cur.append(line)

if len(cur.lines) > 0:
    blocks.append(cur)

# Sort blocks and reappend header
blocks.sort(key=lambda b: b.key)
# Header is disabled for now.
# We don't want the ever-chaning header!
# new_content = ''.join(header) + ''.join([''.join(b.lines) for b in blocks])
new_content = ''.join([''.join(b.lines) for b in blocks])

# Write to file
with open(filename, 'w') as file:
    file.write(new_content)
