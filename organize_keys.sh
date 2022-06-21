#!/bin/bash

contrib/sort_yaml.py server/*.yml proxy/*.yml
contrib/sort_serverproperties.py server/server.properties
