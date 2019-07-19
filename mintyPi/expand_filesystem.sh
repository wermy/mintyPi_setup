#!/bin/bash

if [ ! -f /home/pi/.first_run ]; then
    echo "File not found!"
    echo "sudomod" > /home/pi/.first_run
else
    echo "File already exists."
fi
