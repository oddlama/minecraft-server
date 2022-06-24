#!/bin/bash

echo "Generating css..."
npx tailwindcss -i ./style.css -o docs/style.css --minify
