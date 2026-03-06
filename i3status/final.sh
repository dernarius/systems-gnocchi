#!/usr/bin/env bash

i3status | while :
do
  read line
  lang="$(swaymsg -rt get_inputs | jq -r '.[1].xkb_active_layout_name ')"
  echo "$lang $line" || exit 1
done
