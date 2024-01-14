#!/bin/bash

function ask_yes_no {
    local prompt="$1"
    local default="$2"
    read -p "$prompt " answer
    if [[ $answer == "" ]]; then
        answer="$default"
    fi
    case ${answer:0:1} in
        y|Y )
            true
            ;;
        * )
            false
            ;;
    esac
}
