#!/bin/bash

#
# ANSI Color Codes Library
# Provides color and formatting constants for terminal output.
# 
# Usage: source ./ansi_codes.sh
#

[[ "${_ANSI_CODES_LOADED:-}" == "true" ]] && return 0
readonly _ANSI_CODES_LOADED=true

# Checks if color is support and their is a terminal.
if [[ -t 1 ]] && [[ "${TERM:-}" != "dumb" ]] && [[ "${NO_COLOR:-}" != "1" ]]; then
    # =======================================================================
    # TEXT ATTRIBUTES
    # =======================================================================
    readonly RESET=$'\033[0m' 
    readonly BOLD=$'\033[1m' 
    readonly DIM=$'\033[2m' 
    readonly ITALIC=$'\033[3m' 
    readonly UNDER=$'\033[4m' 
    readonly BLINK=$'\033[5m' 
    readonly INVERT=$'\033[7m' 
    readonly HIDDEN=$'\033[8m' 
    readonly STRIKE=$'\033[9m' 

    # =======================================================================
    # STANDARD COLORS (FOREGROUND)
    # =======================================================================
    readonly BLACK_FG=$'\033[30m'
    readonly RED_FG=$'\033[31m'
    readonly GREEN_FG=$'\033[32m'
    readonly YELLOW_FG=$'\033[33m'
    readonly BLUE_FG=$'\033[34m'
    readonly MAGENTA_FG=$'\033[35m'
    readonly CYAN_FG=$'\033[36m'
    readonly WHITE_FG=$'\033[37m'

    # =======================================================================
    # BRIGHT COLORS (FOREGROUND)
    # =======================================================================
    readonly BRIGHT_BLACK_FG=$'\033[90m'
    readonly BRIGHT_RED_FG=$'\033[91m'
    readonly BRIGHT_GREEN_FG=$'\033[92m'
    readonly BRIGHT_YELLOW_FG=$'\033[93m'
    readonly BRIGHT_BLUE_FG=$'\033[94m'
    readonly BRIGHT_MAGENTA_FG=$'\033[95m'
    readonly BRIGHT_CYAN_FG=$'\033[96m'
    readonly BRIGHT_WHITE_FG=$'\033[97m'


    # =======================================================================
    # STANDARD COLORS (BACKGROUND)
    # =======================================================================
    readonly BLACK_BG=$'\033[40m'
    readonly RED_BG=$'\033[41m'
    readonly GREEN_BG=$'\033[42m'
    readonly YELLOW_BG=$'\033[43m'
    readonly BLUE_BG=$'\033[44m'
    readonly MAGENTA_BG=$'\033[45m'
    readonly CYAN_BG=$'\033[46m'
    readonly WHITE_BG=$'\033[47m'

    # =======================================================================
    # BRIGHT COLORS (BACKGROUND)
    # =======================================================================
    readonly BRIGHT_BLACK_BG=$'\033[100m'
    readonly BRIGHT_RED_BG=$'\033[101m'
    readonly BRIGHT_GREEN_BG=$'\033[102m'
    readonly BRIGHT_YELLOW_BG=$'\033[103m'
    readonly BRIGHT_BLUE_BG=$'\033[104m'
    readonly BRIGHT_MAGENTA_BG=$'\033[105m'
    readonly BRIGHT_CYAN_BG=$'\033[106m'
    readonly BRIGHT_WHITE_BG=$'\033[107m'

    # =======================================================================
    # ALIASES
    # =======================================================================
    readonly BLACK="$BLACK_FG"
    readonly RED="$RED_FG"
    readonly GREEN="$GREEN_FG"
    readonly YELLOW="$YELLOW_FG"
    readonly BLUE="$BLUE_FG"
    readonly MAGENTA="$MAGENTA_FG"
    readonly CYAN="$CYAN_FG"
    readonly WHITE="$WHITE_FG"

    readonly PURPLE="$MAGENTA_FG"
    readonly PINK="$BRIGHT_MAGENTA_FG"
    readonly GRAY="$BRIGHT_BLACK_FG"
    readonly GREY="$GRAY"
    readonly ORANGE="$YELLOW_FG"

else
    # =======================================================================
    # NO COLOR MODE
    # =======================================================================

    readonly RESET="" BOLD="" DIM="" ITALIC="" UNDER=""
    readonly BLINK="" INVERT="" HIDDEN="" STRIKE="" 
    readonly BLACK_FG="" RED_FG="" GREEN_FG="" YELLOW_FG="" 
    readonly BLUE_FG="" MAGENTA_FG="" CYAN_FG="" WHITE_FG=""
    readonly BRIGHT_BLACK_FG="" BRIGHT_RED_FG="" BRIGHT_GREEN_FG="" BRIGHT_YELLOW_FG=""
    readonly BRIGHT_BLUE_FG="" BRIGHT_MAGENTA_FG="" BRIGHT_CYAN_FG="" BRIGHT_WHITE_FG="" 
    readonly BLACK="" RED="" GREEN="" YELLOW="" BLUE="" MAGENTA="" CYAN="" 
    readonly WHITE="" PURPLE="" PINK="" GRAY="" GREY="" ORANGE=""
fi

# =======================================================================
# UTILITY FUNCTIONS
# =======================================================================

enable_colors() {
    if [[ -t 1 ]] && [[ "${TERM:-}" != "dumb" ]]; then
        export NO_COLOR=""
        souce "${BASH_SOURCE[0]}"
    fi
}

disable_colors() {
    export NO_COLOR=1
    souce "${BASH_SOURCE[0]}"
}

colorize() {
    local color="$1"
    local text="$2"
    echo -e "${color}${text}${RESET}"
}

# Color functions
black() { colorize "$BLACK" "$*"; }
red() { colorize "$RED" "$*"; }
green() { colorize "$GREEN" "$*"; }
yellow() { colorize "$YELLOW" "$*"; }
blue() { colorize "$BLUE" "$*"; }
magenta() { colorize "$MAGENTA" "$*"; }
cyan() { colorize "$CYAN" "$*"; }
white() { colorize "$WHITE" "$*"; }
purple() { colorize "$PURPLE" "$*"; }
pink() { colorize "$PINK" "$*"; }
gray() { colorize "$GRAY" "$*"; }
grey() { colorize "$GREY" "$*"; }
orange() { colorize "$ORANGE" "$*"; }

# Attribute function
bold() { colorize "$BOLD" "$*"; }
italic() { colorize "$ITALIC" "$*"; }
underline() { colorize "$UNDER" "$*"; }
strike() { colorize "$STRIKE" "$*"; }
