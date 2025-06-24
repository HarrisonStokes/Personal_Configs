#!/bin/bash

if [[ -t 1 ]]; then
    # Attributes
    readonly RESET="\033[0m"
    readonly INVERT="\033[7m"
    readonly BLINK="\033[5m"
    readonly HIDDEN="\033[8m"
    
    # Styles
    readonly ITALIC="\033[3m"
    readonly BOLD="\033[1m"
    readonly DIM="\033[2m"
    readonly UNDER="\033[4m"
    readonly STRIKE="\033[9m"

    # Foreground Colors
    readonly BLACK_FG="\033[30m"
    readonly RED_FG="\033[31m"
    readonly GREEN_FG="\033[32m"
    readonly YELLOW_FG="\033[33m"
    readonly BLUE_FG="\033[34m"
    readonly MAGENTA_FG="\033[35m"
    readonly CYAN_FG="\033[36m"
    readonly WHITE_FG="\033[37m"

    # Background Colors
    readonly BLACK_BG="\033[40m"
    readonly RED_BG="\033[41m"
    readonly GREEN_BG="\033[42m"
    readonly YELLOW_BG="\033[43m"
    readonly BLUE_BG="\033[44m"
    readonly MAGENTA_BG="\033[45m"
    readonly CYAN_BG="\033[46m"
    readonly WHITE_BG="\033[47m"
else
    # Attributes
    readonly RESET="" INVERT="" BLINK="" HIDDEN=""
    # Styles
    readonly ITALIC="" BOLD="" DIM="" UNDER="" STRIKE=""
    # Foreground Colors
    readonly BLACK_FG="" RED_FG="" GREEN_FG="" YELLOW_FG="" BLUE_FG="" MAGENTA_FG="" CYAN_FG="" WHITE_FG=""
    # Background Colors
    readonly BLACK_BG="" RED_BG="" GREEN_BG="" YELLOW_BG="" BLUE_BG="" MAGENTA_BG="" CYAN_BG="" WHITE_BG=""
fi
