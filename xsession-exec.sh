#!/bin/bash

if [[ $DESKTOP_SESSION == "awesome" ]]; then
    git -C /home/krem/.config/ checkout awesome
    awesome
else 
    git -C /home/krem/.config checkout xfce
    startxfce4
fi 
