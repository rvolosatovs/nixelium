#!/bin/zsh

CITY=${CITY:-"Eindhoven"}
{ curl -s wttr.in/${CITY} 2>/dev/null | head -7 } &|

for rc in ${ZDOTDIR}/rc/*.sh; do
    source $rc
done

