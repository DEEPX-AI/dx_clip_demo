#!/bin/bash
SCRIPT_DIR=$(realpath "$(dirname "$0")")
PROJECT_ROOT=$(realpath "$SCRIPT_DIR")
DOWNLOAD_DIR="$SCRIPT_DIR/download"
PROJECT_NAME=$(basename "$SCRIPT_DIR")
VENV_PATH="$PROJECT_ROOT/venv-$PROJECT_NAME"

pushd "$PROJECT_ROOT" >&2

# color env settings
source ${PROJECT_ROOT}/scripts/color_env.sh
source ${PROJECT_ROOT}/scripts/common_util.sh

delete_dir() {
    local path="$1"
    if [ -e "$path" ]; then  # Check if the file exists
        echo -e "${TAG_INFO} Deleting path: $path"
        rm -rf "$path"
        if [ $? -ne 0 ]; then
            echo -e "${TAG_ERROR} Uninstalling ${PROJECT_NAME} failed!"
            exit 1
        fi
    else
        echo -e "${TAG_SKIP} Path does not exist: $path"
    fi
}

# Function to delete symlinks and their target files
delete_symlinks() {
    local dir="$1"
    for symlink in "$dir"/*; do
        if [ -L "$symlink" ]; then  # Check if the file is a symbolic link
            real_file=$(readlink -f "$symlink")  # Get the actual file path the symlink points to

            # If the original file exists, delete it
            if [ -e "$real_file" ]; then
                echo -e "${TAG_INFO} Deleting original file: $real_file"
                rm -rf "$real_file"
                if [ $? -ne 0 ]; then
                    echo "${TAG_ERROR} Uninstalling ${PROJECT_NAME} failed!"
                    exit 1
                fi

            fi

            # Delete the symbolic link
            echo -e "${TAG_INFO} Deleting symlink: $symlink"
            rm -rf "$symlink"
            if [ $? -ne 0 ]; then
                echo -e "${TAG_ERROR} Uninstalling ${PROJECT_NAME} failed!"
                exit 1
            fi
        else
            echo "Skipping non-symlink file: $symlink"
        fi
    done
}

echo "Uninstalling ${PROJECT_NAME} ..."

# Remove symlinks from DOWNLOAD_DIR and PROJECT_ROOT
delete_symlinks "$DOWNLOAD_DIR"
delete_symlinks "$PROJECT_ROOT"
delete_symlinks "${VENV_PATH}"
delete_symlinks "${VENV_PATH}-local"
delete_dir "${VENV_PATH}"
delete_dir "${VENV_PATH}-local"
delete_dir "${DOWNLOAD_DIR}"

echo "Uninstalling ${PROJECT_NAME} done"

popd >&2
exit 0
