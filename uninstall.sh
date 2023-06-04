#!/bin/bash

for dotfile in .*; do
    test -L || continue
    target="$(readlink "$dotfile")"
    [[ $target =~ ^home/ ]] && echo rm "$dotfile"
done