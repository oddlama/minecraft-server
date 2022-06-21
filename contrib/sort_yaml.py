#!/usr/bin/env python3

# requires pyyaml

import sys
import yaml

class DumperWithCorrectListIndent(yaml.Dumper):
    def increase_indent(self, flow=False, indentless=False):
        return super(DumperWithCorrectListIndent, self).increase_indent(flow, False)

if len(sys.argv) < 2:
    print("usage: {} FILES...".format(sys.argv[0]))
    sys.exit(1)

for filename in sys.argv[1:]:
    print(f"Sorting {filename}")
    with open(filename, 'r') as file:
        data = yaml.safe_load(file)

    with open(filename, 'w') as file:
        yaml.dump(data, file, Dumper=DumperWithCorrectListIndent, default_flow_style=False, indent=2)
