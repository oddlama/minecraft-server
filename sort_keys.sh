#!/bin/bash

scripts/sort_yaml.py server/*.yml proxy/*.yml
scripts/sort_serverproperties.py server/server.properties
