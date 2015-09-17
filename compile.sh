#!/bin/bash
#
# Simple script to compile the site into HTML
#
echo "Re-building site every 2 seconds"
watch "jekyll build"  > /dev/null 2>&1
