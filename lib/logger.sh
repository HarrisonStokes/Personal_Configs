#!/bin/bash/

# Basic logging features

source ./ansi_codes.sh

log_section() { echo -e "\n${PURPLE}=== $1 ===${RESET}"; }
log_info() { echo -e "${BLUE}[INFO]${RESET} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${RESET} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${RESET} $1"; }
log_error() { echo -e "${RED}[ERROR]${RESET} $1"; }
