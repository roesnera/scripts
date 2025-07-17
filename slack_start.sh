#!/bin/bash

slack=$(ps a | awk '{ print $5 }' | rg ^slack$)

echo $slack
