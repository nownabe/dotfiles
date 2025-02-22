#!/usr/bin/env bash

sudo apt update
sudo apt install -y \
  byobu \
  git \
  libyaml-dev \
  zip \
  zsh

curl https://mise.run | sh
