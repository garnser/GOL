#!/bin/bash

for i in {1..300}; do
    curl -s http://192.168.10.10
done | sort | uniq -c | sort -g

