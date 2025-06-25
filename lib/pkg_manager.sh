#!/bin/bash

#
# POSIX-Compatiable Package Manager Library
#
#   Supported Shells:
#   bash, dash, sh, zsh, and most UNIX shells.
#

# ===================================================
# CONFIGURATION & GLOBALS
# ===================================================

PKG_LIB_VERSION="1.0.0.0-posix"
PKG_LIB_NAME="posix_package_manager"

# Runtime tracking
# (Arrays are spaced separated strings)
TEMP_DIRS=""
INSTALLED_PACKAGES=""
PKG_LIB_INITIALIZED=false

# Configuration options
PKG_VERBOSE=${PKG_VERBOSE:-false}
PKG_DRY_RUN=${PKG_DRY_RUN:-false}
PKG_AUTO_CLEANUP=${PKG_AUTO_CLEANUP:-true}
PKG_UPDATE_CACHE=${PKG_UPDATE_CACHE:-true}

# ===================================================
# CONFIGURATION & GLOBALS
# ===================================================
pkg_log() {
    level="$1"
    shift
    message="$*"

    if [ "$PKG_VERBOSE" = "true" ] || [ "$level" = "ERROR" ]; then
        printf "[%s:%s] %s\n" "$PKG_LIB_NAME" "$level" "$message" >&2
    fi
}
