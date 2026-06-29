#!/bin/bash

SCRIPT_DIR=$(realpath "$(dirname "$0")")
pushd "$SCRIPT_DIR" > /dev/null

# color / logging helpers (print_colored, print_colored_v2)
source "${SCRIPT_DIR}/scripts/color_env.sh"
source "${SCRIPT_DIR}/scripts/common_util.sh"

APP_TYPE=""
DXRT_SRC_PATH=""

# Function to display help message
show_help() {
  echo "Usage: $(basename "$0") [OPTIONS]"
  echo "Options:"
  echo "  [--app_type=<str>]           Set Application type (pyqt | opencv). If omitted, you are prompted."
  echo "  [--dxrt_src_path=<path>]     Set DXRT source path (passed to setup.sh)"
  echo "  --help                       Show this help message"

  if [ "$1" == "error" ]; then
    echo "Error: Invalid or missing arguments."
    exit 1
  fi
  exit 0
}

# Parse arguments
for i in "$@"; do
  case $i in
    --app_type=*)
      APP_TYPE="${i#*=}"
      ;;
    --dxrt_src_path=*)
      DXRT_SRC_PATH="${i#*=}"
      ;;
    --help)
      show_help
      ;;
    *)
      # Unknown option
      ;;
  esac
  shift
done

# Prompt for app_type when not provided on the command line
if [ -z "$APP_TYPE" ]; then
  echo "Select demo variant:"
  echo "  1) pyqt   - full GUI (PyQT5)"
  echo "  2) opencv - lightweight, terminal / headless"
  read -t 30 -p "Enter choice [1-2] (timeout:30s, default:1=pyqt): " choice
  case "$choice" in
    2|opencv) APP_TYPE="opencv" ;;
    *)        APP_TYPE="pyqt"   ;;
  esac
fi

# Check if APP_TYPE is valid
if [ "$APP_TYPE" != "pyqt" ] && [ "$APP_TYPE" != "opencv" ]; then
  print_colored "APP_TYPE ($APP_TYPE) is invalid. It must be 'pyqt' or 'opencv'." "ERROR"
  show_help "error"
fi
print_colored "Selected app_type: ${APP_TYPE}" "INFO"

check_valid_dir_or_symlink() {
    local path="$1"
    if [ -d "$path" ] || { [ -L "$path" ] && [ -d "$(readlink -f "$path")" ]; }; then
        return 0
    else
        return 1
    fi
}

# Setup (download models/videos + create venv) if assets, videos, or the
# venv for the selected app_type are missing. setup.sh is idempotent and
# skips whatever already exists.
if check_valid_dir_or_symlink "./assets" \
   && check_valid_dir_or_symlink "./assets/demo_videos" \
   && check_valid_dir_or_symlink "./venv-${APP_TYPE}"; then
    print_colored "Models, videos and venv-${APP_TYPE} already exist. Skipping setup." "INFO"
else
    print_colored "Models/videos/venv not found. Running setup.sh (app_type=${APP_TYPE})..." "INFO"
    SETUP_ARGS="--app_type=${APP_TYPE}"
    [ -n "$DXRT_SRC_PATH" ] && SETUP_ARGS="${SETUP_ARGS} --dxrt_src_path=${DXRT_SRC_PATH}"
    ./setup.sh ${SETUP_ARGS} || { print_colored "setup.sh failed." "ERROR"; popd > /dev/null; exit 1; }
fi

# Run the demo application (the inner run scripts activate the venv)
pushd "clip_demo_app_${APP_TYPE}" > /dev/null
./run_demo.sh
popd > /dev/null

popd > /dev/null
