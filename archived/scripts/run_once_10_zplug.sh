#!/usr/bin/env bash

if [[ ! -e $HOME/.zplug ]]; then
  git clone https://github.com/zplug/zplug "$HOME/.zplug"
fi
