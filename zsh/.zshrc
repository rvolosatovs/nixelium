#!/bin/zsh
for rc in ${ZDOTDIR}/rc/*.sh ${ZDOTDIR}/rc/*.zsh; do
    source $rc
done

