#!/usr/bin/env bash

if [[ ! -e "$HOME/.local/bin/mise" ]]; then
  curl https://mise.run | sh
fi
