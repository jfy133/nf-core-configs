#!/usr/bin/env bash

for i in conf/*.config; do
    bash ./maxresource-to-resourcelimit.sh $i
done
