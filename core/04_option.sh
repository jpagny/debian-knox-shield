#!/bin/bash

DEBUG_MODE=0

for arg in "$@"; do

  if [ "$arg" = "--debug" ]; then
    DEBUG_MODE=1
  fi

done