#!/bin/bash

# Define log level colors
LOG_COLOR_DEBUG='\033[0;36m' # Cyan for debug
LOG_COLOR_INFO='\033[0;32m'  # Green for info
LOG_COLOR_WARN='\033[0;33m'  # Yellow for warning
LOG_COLOR_ERROR='\033[0;31m' # Red for error
LOG_COLOR_END='\033[0m'      # End color

# Debug log function
log_debug() {
  echo -e "${LOG_COLOR_DEBUG}[DEBUG]: $1${LOG_COLOR_END}" >&2
}

# Information log function
log_info() {
  echo -e "${LOG_COLOR_INFO}[INFO]: $1${LOG_COLOR_END}" >&2
}

# Warning log function
log_warn() {
  echo -e "${LOG_COLOR_WARN}[WARN]: $1${LOG_COLOR_END}" >&2
}

# Error log function
log_error() {
  echo -e "${LOG_COLOR_ERROR}[ERROR]: $1${LOG_COLOR_END}" >&2
}