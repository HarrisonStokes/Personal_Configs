#!/bin/bash
#
# Test script for the utility libraries
#

echo "=== Testing Utility Libraries ==="
echo "Bash version: ${BASH_VERSION:-unknown}"
echo "Shell: $0"
echo

# Test 1: Load libraries individually
echo "Test 1: Loading libraries individually"
echo "======================================"

# Test ansi_codes.sh
if [[ -f "./ansi_codes.sh" ]]; then
    echo "Loading ansi_codes.sh..."
    source ./ansi_codes.sh
    if [[ -n "$RED" ]]; then
        echo -e "${GREEN}✓ ansi_codes.sh loaded successfully${RESET}"
        echo -e "  Colors enabled: ${RED:+yes}${RED:-no}"
    else
        echo "⚠ ansi_codes.sh loaded but colors disabled"
    fi
else
    echo "❌ ansi_codes.sh not found"
fi

echo

# Test logger.sh  
if [[ -f "./logger.sh" ]]; then
    echo "Loading logger.sh..."
    source ./logger.sh
    if declare -f log_info >/dev/null 2>&1; then
        echo -e "${GREEN}✓ logger.sh loaded successfully${RESET}"
        log_info "Logger is working!"
    else
        echo "❌ logger.sh failed to load"
    fi
else
    echo "❌ logger.sh not found"
fi

echo

# Test system.sh
if [[ -f "./system.sh" ]]; then
    echo "Loading system.sh..."
    source ./system.sh
    if [[ -n "$OS" ]]; then
        echo -e "${GREEN}✓ system.sh loaded successfully${RESET}"
        log_info "Detected system: $OS ($ARCH)"
    else
        echo "❌ system.sh failed to detect system"
    fi
else
    echo "❌ system.sh not found"
fi

echo

# Test 2: Basic functionality
echo "Test 2: Basic functionality"
echo "==========================="

if declare -f log_info >/dev/null 2>&1; then
    log_header "Testing All Log Levels"
    
    log_debug "Debug message (may not show if level is INFO+)"
    log_info "Info message"
    log_success "Success message"
    log_warn "Warning message"
    log_error "Error message (this is not a real error)"
    
    log_section "System Information"
    if [[ -n "$OS" ]]; then
        log_info "Operating System: $OS"
        log_info "Architecture: $ARCH"
        log_info "Shell: $SHELL_NAME"
        log_info "Package Manager: $PACKAGE_MANAGER"
    else
        log_warn "System detection not available"
    fi
    
    log_section "Progress Test"
    for i in 1 2 3; do
        log_step "$i" 3 "Processing step $i"
        log_progress "$i" 3 15 "Working..."
        sleep 0.2
    done
    
else
    echo "Skipping functionality tests - logger not available"
fi

echo

# Test 3: Configuration
echo "Test 3: Configuration"
echo "====================="

if declare -f log_set_level >/dev/null 2>&1; then
    log_info "Testing configuration..."
    
    # Test log level changes
    log_set_level "DEBUG"
    log_debug "This debug message should now be visible"
    
    log_set_level "ERROR"
    log_info "This info message should be hidden"
    log_error "This error message should be visible"
    
    # Reset to INFO
    log_set_level "INFO"
    log_info "Reset log level to INFO"
    
    # Test prefix
    log_set_prefix "TEST"
    log_info "This message has a prefix"
    log_set_prefix ""
    log_info "Prefix removed"
    
else
    echo "Configuration test skipped - logger functions not available"
fi

echo

# Test 4: Error handling
echo "Test 4: Error handling"
echo "======================"

if declare -f log_info >/dev/null 2>&1; then
    log_info "Testing error conditions..."
    
    # Test invalid log level
    if ! log_set_level "INVALID"; then
        log_info "✓ Correctly rejected invalid log level"
    fi
    
    # Test invalid log format
    if ! log_set_format "invalid"; then
        log_info "✓ Correctly rejected invalid log format"
    fi
    
    log_success "Error handling tests completed"
else
    echo "Error handling test skipped - logger not available"
fi

echo

# Test 5: Performance/compatibility
echo "Test 5: Compatibility"
echo "===================="

echo "Bash version: ${BASH_VERSION:-not bash}"
if [[ -n "$BASH_VERSION" ]]; then
    major="${BASH_VERSION%%.*}"
    if [[ "$major" -ge 4 ]]; then
        echo "✓ Bash 4.0+ detected - full features available"
    else
        echo "⚠ Bash 3.x detected - using compatibility mode"
    fi
else
    echo "⚠ Not running in bash - compatibility may be limited"
fi

if [[ -t 1 ]]; then
    echo "✓ Running in terminal - colors should work"
else
    echo "⚠ Not running in terminal - colors disabled"
fi

if [[ "${NO_COLOR:-}" == "1" ]]; then
    echo "⚠ NO_COLOR environment variable set - colors disabled"
else
    echo "✓ Colors not explicitly disabled"
fi

echo

# Summary
echo "Test Summary"
echo "============"
echo "Libraries tested:"
[[ "${_ANSI_CODES_LOADED:-}" == "true" ]] && echo "  ✓ ansi_codes.sh" || echo "  ❌ ansi_codes.sh"
[[ "${_LOGGER_LOADED:-}" == "true" ]] && echo "  ✓ logger.sh" || echo "  ❌ logger.sh"  
[[ "${_SYSTEM_LOADED:-}" == "true" ]] && echo "  ✓ system.sh" || echo "  ❌ system.sh"

echo
if declare -f log_success >/dev/null 2>&1; then
    log_success "All tests completed!"
else
    echo "Tests completed (basic mode)"
fi
