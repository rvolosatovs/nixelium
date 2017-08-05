#!/bin/zsh
curl wttr.in/Eindhoven&

for rc in ${ZDOTDIR}/rc/*.sh; do
    source $rc
done

