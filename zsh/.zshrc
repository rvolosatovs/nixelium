#!/bin/zsh
for rc in ${ZDOTDIR:-~}/rc/*.sh; do
    source $rc
done
