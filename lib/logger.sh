#!/bin/bash
#
# Logging Library
# Provides structured logging with levels, colors, and formatting
#
# Usage: source ./logger.sh
#
# Variables:
#   LOG_LEVEL           @options [DEBUG, INFO, SUCCESS, WARN, ERROR, FATAL]
#   LOG_TIMESTAMP       @options [true, false] @desc Enables timestamps.
#   LOG_PREFIX          @desc Name of what is being logged.
#   LOG_FILE            @options [name, -] @desc Log filename to wrtie to
#   LOG_FORMAT          @options [json, simple, standard] @desc logging message format.
# 
# Functions:
#   should_log()        @param [level]
#   get_log_level_num() @param [level]
#   get_timestamp()     @param []
#   log_get_config()    @param []
#
#   log_set_level()     @param [level]
#   log_set_prefix()    @param [prefix]
#   log_set_file()      @param [filename]
#   log_set_format()    @param [format]
#
#   log_to_term()       @param [color, level, message]
#   log_to_file()       @param [level, message]
#   log_output()        @param [color, level, message]
#
#   log_debug()         @param [message]
#   log_info()          @param [message]
#   log_success()       @param [message]
#   log_warn()          @param [message]
#   log_error()         @param [message]
#   log_fatal()         @param [message]
#
#   log_section()       @param [title, width, separator]
#   log_header()        @param [title]
#
#   log_step()          @param [curr_step, total_step, message, end]
#   log_progress()      @param [curr_step, total_step, width, message, end]
#
#   log_table()         @param [table_headers]
#   log_table_row()     @param [columns]
#

[[ "${_LOGGER_LOADED:-}" == "true" ]] && return 0
readonly _LOGGER_LOADED=true

_load_scripts() {
    source "./ansi_codes.sh"
}
_load_scripts

# ============================================================================
# LOGGING CONFIGURATION
# ============================================================================

# Log levels (can be configured via environment variables)
LOG_LEVEL="${LOG_LEVEL:-INFO}"
LOG_TIMESTAMP="${LOG_TIMESTAMP:-true}"
LOG_PREFIX="${LOG_PREFIX:-}"
LOG_FILE="${LOG_FILE:-}"
LOG_FORMAT="${LOG_FORMAT:-standard}"  # standard, json, simple

# Log level hierarchy (for filtering)
# Use associative arrays if available (bash 4.0+), otherwise use function
if [[ "${BASH_VERSINFO[0]:-0}" -ge 4 ]]; then
    declare -A LOG_LEVELS=(
        [DEBUG]=0
        [INFO]=1
        [SUCCESS]=1
        [WARN]=2
        [ERROR]=3
        [FATAL]=4
    )
    _use_log_levels_array=true
else
    _use_log_levels_array=false
fi

# Fallback function for older bash versions
get_log_level_num() {
    local level="$1"
    case "$level" in
        DEBUG) echo 0 ;;
        INFO|SUCCESS) echo 1 ;;
        WARN) echo 2 ;;
        ERROR) echo 3 ;;
        FATAL) echo 4 ;;
        *) echo 1 ;;
    esac
}

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

get_timestamp() {
    if [[ "$LOG_TIMESTAMP" == "true" ]]; then
        date '+%Y-%m-%d %H:%M:%S'
    fi
}

should_log() {
    local level="$1"
    local current_level_num
    local message_level_num
    
    if [[ "$_use_log_levels_array" == "true" ]]; then
        current_level_num="${LOG_LEVELS[$LOG_LEVEL]:-1}"
        message_level_num="${LOG_LEVELS[$level]:-1}"
    else
        current_level_num="$(get_log_level_num "$LOG_LEVEL")"
        message_level_num="$(get_log_level_num "$level")"
    fi
    
    [[ $message_level_num -ge $current_level_num ]]
}

# ============================================================================
# CORE LOGGING FUNCTIONS
# ============================================================================

log_to_term() {
    local color="$1"
    local level="$2"
    shift 2
    local message="$*"
    
    should_log "$level" || return 0
    
    local timestamp=""
    if [[ "$LOG_TIMESTAMP" == "true" ]]; then
        timestamp="$(get_timestamp) "
    fi
    
    local prefix=""
    if [[ -n "$LOG_PREFIX" ]]; then
        prefix="[$LOG_PREFIX] "
    fi
    
    case "$LOG_FORMAT" in
        "json")
            printf '{"timestamp":"%s","level":"%s","prefix":"%s","message":"%s"}\n' \
                "$(get_timestamp)" "$level" "$LOG_PREFIX" "$message"
            ;;
        "simple")
            printf "%s%s: %s%s\n" "$timestamp" "$level" "$prefix" "$message"
            ;;
        *)
            printf "%s%s[%s]%s %s%s\n" \
                "$timestamp" \
                "$color" "$level" "$RESET" \
                "$prefix" "$message"
            ;;
    esac
}

log_to_file() {
    local level="$1"
    shift
    local message="$*"
    
    if [[ -n "$LOG_FILE" ]]; then
        local timestamp
        timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
        local prefix=""
        [[ -n "$LOG_PREFIX" ]] && prefix="[$LOG_PREFIX] "
        
        printf "%s [%s] %s%s\n" "$timestamp" "$level" "$prefix" "$message" >> "$LOG_FILE"
    fi
}

log_output() {
    local color="$1"
    local level="$2"
    shift 2
    local message="$*"
    
    log_to_term "$color" "$level" "$message" >&2
    
    # Also log to file if configured
    log_to_file "$level" "$message"
}

# ============================================================================
# MAIN LOGGING FUNCTIONS
# ============================================================================

log_debug() {
    log_output "$GRAY" "DEBUG" "$@"
}

log_info() {
    log_output "$BLUE" "INFO" "$@"
}

log_success() {
    log_output "$GREEN" "SUCCESS" "$@"
}

log_warn() {
    log_output "$YELLOW" "WARN" "$@"
}

log_error() {
    log_output "$RED" "ERROR" "$@"
}

log_fatal() {
    log_output "$BOLD$RED" "FATAL" "$@"
    exit 1
}

# ============================================================================
# SPECIAL FORMATTING FUNCTIONS
# ============================================================================

log_section() {
    local title="$1"
    local width="${2:-60}"
    local char="${3:-=}"
    
    should_log "INFO" || return 0
    
    echo >&2
    printf "%s%s%s\n" \
        "$CYAN" \
        "$(printf "%*s" $(((width + ${#title}) / 2)) "$title" | sed "s/ /$char/g")" \
        "$RESET" >&2
    
    if [[ -n "$LOG_FILE" ]]; then
        echo >> "$LOG_FILE"
        printf "%s\n" "$(printf "%*s" $(((width + ${#title}) / 2)) "$title" | sed "s/ /$char/g")" >> "$LOG_FILE"
    fi
}

log_header() {
    local title="$1"
    
    should_log "INFO" || return 0
    
    echo >&2
    printf "%s%s%s%s\n" "$BOLD" "$BLUE" "$title" "$RESET" >&2
    printf "%s%s%s\n" "$BLUE" "$(printf '=%.0s' $(seq 1 ${#title}))" "$RESET" >&2
    
    if [[ -n "$LOG_FILE" ]]; then
        echo >> "$LOG_FILE"
        printf "%s\n" "$title" >> "$LOG_FILE"
        printf "%s\n" "$(printf '=%.0s' $(seq 1 ${#title}))" >> "$LOG_FILE"
    fi
}

log_step() {
    local step="$1"
    local total="$2"
    local message="$3"
    local end="${4:$'\n'}"
    
    should_log "INFO" || return 0
    
    printf "%s[%d/%d]%s %s%s" "$CYAN" "$step" "$total" "$RESET" "$message" "$end" >&2
    
    log_to_file "STEP" "[$step/$total] $message"
}

log_progress() {
    local current="$1"
    local total="$2"
    local width="${3:-30}"
    local message="${4:-}"
    local end="${5:$'\n'}"
    
    should_log "INFO" || return 0
    
    local percentage=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))
    
    printf "\r%s[%s%s] %d%% (%d/%d)%s %s%s" \
        "$BLUE" \
        "$(printf "%*s" $filled "" | tr ' ' '#')" \
        "$(printf "%*s" $empty "")" \
        "$percentage" "$current" "$total" \
        "$RESET" "$message" "${end}" >&2
    
    if [[ $current -eq $total ]]; then
        echo >&2
    fi
}

log_table() {
    local -a headers=("$@")
    
    should_log "INFO" || return 0
    
    echo >&2
    printf "%s" "$BOLD" >&2
    for header in "${headers[@]}"; do
        printf "%-20s " "$header" >&2
    done
    printf "%s\n" "$RESET" >&2
    
    # Print separator
    for header in "${headers[@]}"; do
        printf "%s" "$(printf '─%.0s' $(seq 1 20))" >&2
    done
    echo >&2
}

log_table_row() {
    local -a columns=("$@")
    
    should_log "INFO" || return 0
    
    for column in "${columns[@]}"; do
        printf "%-20s " "$column" >&2
    done
    echo >&2
}

# ============================================================================
# CONFIGURATION FUNCTIONS
# ============================================================================

log_set_level() {
    local level="$1"
    local valid_levels="DEBUG INFO SUCCESS WARN ERROR FATAL"
    
    if [[ " $valid_levels " =~ $level ]]; then
        LOG_LEVEL="$level"
        log_debug "Log level set to: $level"
    else
        log_error "Invalid log level: $level. Valid levels: $valid_levels"
        return 1
    fi
}

log_set_prefix() {
    LOG_PREFIX="$1"
    log_debug "Log prefix set to: $LOG_PREFIX"
}

log_set_file() {
    LOG_FILE="$1"
    if [[ -n "$LOG_FILE" ]]; then
        local log_dir
        log_dir="$(dirname "$LOG_FILE")"
        [[ ! -d "$log_dir" ]] && mkdir -p "$log_dir"
        
        if touch "$LOG_FILE" 2>/dev/null; then
            log_debug "Log file set to: $LOG_FILE"
        else
            log_error "Cannot write to log file: $LOG_FILE"
            LOG_FILE=""
            return 1
        fi
    fi
}

log_set_format() {
    local format="$1"
    case "$format" in
        "standard"|"json"|"simple")
            LOG_FORMAT="$format"
            log_debug "Log format set to: $format"
            ;;
        *)
            log_error "Invalid log format: $format. Valid formats: standard, json, simple"
            return 1
            ;;
    esac
}

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

log_get_config() {
    echo "Log Configuration:"
    echo "  Level: $LOG_LEVEL"
    echo "  Timestamp: $LOG_TIMESTAMP"
    echo "  Prefix: ${LOG_PREFIX:-none}"
    echo "  File: ${LOG_FILE:-none}"
    echo "  Format: $LOG_FORMAT"
    echo "  Colors: $(colors_enabled 2>/dev/null && echo "enabled" || echo "disabled")"
}
