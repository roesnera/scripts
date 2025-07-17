#!/bin/bash
function handle {
  notify-send "handling socket emission"
  slack=$(ps a | awk '{ print $5 }' | rg ^slack$);
  if [ -z $slack ]; then
    slack
    notify-send "starting slack"
  else
    notify-send "slack already running"
  fi
}
handle
