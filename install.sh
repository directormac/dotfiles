#!/bin/bash

for file in *; do
    ln -sf home/"$file" ~/."$file"
done