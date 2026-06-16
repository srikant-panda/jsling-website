#!/usr/bin/env bash
# =============================================================================
# jsling installer - cross-platform install script
# Usage: curl -fsSL https://yoursite.com/install.sh | bash
# Or:    bash install.sh [--prefix /usr/local] [--version latest]
# =============================================================================
set -euo pipefail

# --- Configuration ---
JSLING_VERSION="${JSLING_VERSION:-latest}"
JSLING_REPO="${JSLING_REPO:-https://github.com/user/jsling}"
JSLING_NAME="jsling"
JSLING_INSTALL_PREFIX="${JSLING_INSTALL_PREFIX:-}"
JSLING_INSTALL_BIN=""
JSLING_TEMP_DIR=""

# --- Colors ---
if [ -t 1 ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    BOLD='\033[1m'
    RESET='\033[0m'
else
    RED='' GREEN='' YELLOW='' BLUE='' BOLD='' RESET=''
fi

# --- Helpers ---
info()    { echo -e "${BLUE}info${RESET}  $*"; }
success() { echo -e "${GREEN}done${RESET}  $*"; }
warn()    { echo -e "${YELLOW}warn${RESET}  $*"; }
fail()    { echo -e "${RED}error${RESET} $*" >&2; exit 1; }

cleanup() {
    if [ -n "${JSLING_TEMP_DIR:-}" ] && [ -d "$JSLING_TEMP_DIR" ]; then
        rm -rf "$JSLING_TEMP_DIR"
    fi
}
trap cleanup EXIT

# --- Parse arguments ---
while [ $# -gt 0 ]; do
    case "$1" in
        --prefix)    JSLING_INSTALL_PREFIX="$2"; shift 2;;
        --prefix=*)  JSLING_INSTALL_PREFIX="${1#*=}"; shift;;
        --version)   JSLING_VERSION="$2"; shift 2;;
        --version=*) JSLING_VERSION="${1#*=}"; shift;;
        --help|-h)
            echo "jsling installer"
            echo ""
            echo "Usage: bash install.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --prefix <path>    Install location (default: auto-detect)"
            echo "  --version <ver>    Version to install (default: latest)"
            echo "  --help             Show this help"
            echo ""
            echo "Environment variables:"
            echo "  JSLING_INSTALL_PREFIX   Install prefix"
            echo "  JSLING_VERSION          Version to install"
            echo "  JSLING_REPO             Git repository URL"
            exit 0
            ;;
        *) fail "Unknown argument: $1 (try --help)";;
    esac
done

# --- Detect OS ---
detect_os() {
    local os
    os="$(uname -s)"
    case "$os" in
        Linux*)  echo "linux";;
        Darwin*) echo "macos";;
        MINGW*|MSYS*|CYGWIN*) echo "windows";;
        *) fail "Unsupported operating system: $os";;
    esac
}

# --- Detect architecture ---
detect_arch() {
    local arch
    arch="$(uname -m)"
    case "$arch" in
        x86_64|amd64)   echo "x64";;
        aarch64|arm64)  echo "arm64";;
        armv7l|armv7)   echo "arm";;
        *) fail "Unsupported architecture: $arch";;
    esac
}

# --- Check dependencies ---
check_cmd() {
    command -v "$1" &>/dev/null && echo "$1" || echo ""
}

detect_distro_and_install_deps() {
    local missing=("$@")
    warn "Missing dependencies: ${missing[*]}"
    
    local install_choice
    read -p "Would you like to install the missing dependencies automatically? [y/N]: " -r install_choice
    if [[ ! "$install_choice" =~ ^[Yy]$ ]]; then
        fail "Cannot proceed without dependencies. Please install manually."
    fi

    local cmd=""
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        case "$ID" in
            ubuntu|debian|pop|mint)
                cmd="apt-get update && apt-get install -y cmake build-essential git"
                ;;
            fedora)
                cmd="dnf install -y cmake gcc-c++ git make"
                ;;
            arch|manjaro)
                cmd="pacman -Syu --noconfirm cmake base-devel git"
                ;;
            alpine)
                cmd="apk update && apk add cmake g++ git make"
                ;;
            centos|rhel)
                cmd="yum install -y cmake gcc-c++ git make"
                ;;
        esac
    fi

    if [ -z "$cmd" ]; then
        if command -v apt-get &>/dev/null; then
            cmd="apt-get update && apt-get install -y cmake build-essential git"
        elif command -v dnf &>/dev/null; then
            cmd="dnf install -y cmake gcc-c++ git make"
        elif command -v pacman &>/dev/null; then
            cmd="pacman -Syu --noconfirm cmake base-devel git"
        elif command -v apk &>/dev/null; then
            cmd="apk update && apk add cmake g++ git make"
        elif command -v yum &>/dev/null; then
            cmd="yum install -y cmake gcc-c++ git make"
        else
            fail "Unable to auto-detect package manager. Please install dependencies manually."
        fi
    fi

    info "Installing dependencies via: $cmd"
    
    if [ "$(id -u)" != "0" ]; then
        info "Elevated privileges (sudo) are required to install packages. Requesting password..."
        eval "sudo $cmd" || fail "Dependency installation failed."
    else
        eval "$cmd" || fail "Dependency installation failed."
    fi

    success "Dependencies installed successfully."
}

check_dependencies() {
    info "Checking dependencies..."

    local missing=()

    # Build tools
    local cmake_cmd
    cmake_cmd="$(check_cmd cmake)"
    if [ -z "$cmake_cmd" ]; then
        missing+=("cmake (>= 3.16)")
    else
        local cmake_ver
        cmake_ver="$(cmake --version | head -1 | grep -oE '[0-9]+\.[0-9]+')"
        info "Found cmake $cmake_ver"
    fi

    # Compiler: g++ or clang++
    local cxx=""
    cxx="$(check_cmd g++)" || cxx="$(check_cmd clang++)" || true
    if [ -z "$cxx" ]; then
        missing+=("C++17 compiler (g++ >= 8 or clang++ >= 7)")
    else
        local cxx_ver
        cxx_ver="$($cxx --version | head -1)"
        info "Found $cxx_ver"
    fi

    # Git (needed for source install)
    local git_cmd
    git_cmd="$(check_cmd git)"
    if [ -z "$git_cmd" ]; then
        missing+=("git")
    else
        info "Found git $(git --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
    fi

    # Make or ninja
    local build_tool=""
    build_tool="$(check_cmd make)" || build_tool="$(check_cmd ninja)" || true
    if [ -z "$build_tool" ]; then
        missing+=("make or ninja")
    else
        info "Found $build_tool"
    fi

    if [ ${#missing[@]} -gt 0 ]; then
        local os
        os="$(detect_os)"
        if [ "$os" = "linux" ]; then
            detect_distro_and_install_deps "${missing[@]}"
        else
            echo ""
            fail "Missing required tools:\n$(printf '  - %s\n' "${missing[@]}")\n\n$(install_help)"
        fi
    fi

    success "All dependencies found"
}

# --- Platform-specific install hints ---
install_help() {
    local os
    os="$(detect_os)"
    case "$os" in
        linux)
            echo "Install missing tools with:"
            echo "  Ubuntu/Debian:  sudo apt-get install -y cmake g++ git make"
            echo "  Fedora:         sudo dnf install -y cmake gcc-c++ git make"
            echo "  Arch:           sudo pacman -S cmake gcc git make"
            echo "  Alpine:         sudo apk add cmake g++ git make"
            ;;
        macos)
            echo "Install missing tools with:"
            echo "  brew install cmake git"
            echo "  (Xcode CLI tools: xcode-select --install)"
            ;;
        windows)
            echo "Install missing tools with:"
            echo "  winget install Kitware.CMake Git"
            echo "  Or use MSYS2: pacman -S mingw-w64-x86_64-cmake mingw-w64-x86_64-gcc git make"
            ;;
    esac
}

# --- Determine install prefix ---
determine_prefix() {
    if [ -n "$JSLING_INSTALL_PREFIX" ]; then
        JSLING_INSTALL_BIN="$JSLING_INSTALL_PREFIX/bin"
        return
    fi

    local os
    os="$(detect_os)"

    case "$os" in
        linux)
            # Prefer /usr/local if writable, else ~/.local/bin
            if [ -w /usr/local/bin ] || [ "$(id -u)" = "0" ]; then
                JSLING_INSTALL_BIN="/usr/local/bin"
            else
                JSLING_INSTALL_BIN="${HOME}/.local/bin"
            fi
            ;;
        macos)
            if [ -w /usr/local/bin ] || [ "$(id -u)" = "0" ]; then
                JSLING_INSTALL_BIN="/usr/local/bin"
            else
                JSLING_INSTALL_BIN="${HOME}/.local/bin"
            fi
            ;;
        windows)
            # Use ~/bin on MSYS2/MinGW
            JSLING_INSTALL_BIN="${HOME}/bin"
            ;;
    esac

    JSLING_INSTALL_PREFIX="$(dirname "$JSLING_INSTALL_BIN")"
}

# --- Clone / fetch source ---
fetch_source() {
    JSLING_TEMP_DIR="$(mktemp -d 2>/dev/null || mktemp -d -t jsling)"

    if [ "$JSLING_VERSION" = "latest" ]; then
        info "Cloning $JSLING_NAME from $JSLING_REPO (latest)..."
        git clone --depth 1 --quiet "$JSLING_REPO" "$JSLING_TEMP_DIR/repo" 2>&1 || \
            fail "Failed to clone repository: $JSLING_REPO"
    else
        info "Cloning $JSLING_NAME v$JSLING_VERSION..."
        git clone --depth 1 --branch "$JSLING_VERSION" --quiet "$JSLING_REPO" "$JSLING_TEMP_DIR/repo" 2>&1 || \
            fail "Failed to clone version: $JSLING_VERSION"
    fi

    success "Source fetched"
}

# --- Build from source ---
build_source() {
    local src_dir="$JSLING_TEMP_DIR/repo"

    # Find the C++ project directory
    local project_dir=""
    if [ -f "$src_dir/CMakeLists.txt" ]; then
        project_dir="$src_dir"
    elif [ -f "$src_dir/COMPILER_CPP/CMakeLists.txt" ]; then
        project_dir="$src_dir/COMPILER_CPP"
    else
        fail "Could not find CMakeLists.txt in source tree"
    fi

    info "Building $JSLING_NAME (this may take a minute)..."

    local build_dir="$JSLING_TEMP_DIR/build"
    mkdir -p "$build_dir"

    # Configure
    local cores
    if command -v nproc &>/dev/null; then
        cores="$(nproc)"
    elif command -v sysctl &>/dev/null; then
        cores="$(sysctl -n hw.ncpu 2>/dev/null || echo 1)"
    else
        cores=1
    fi

    if ! cmake -S "$project_dir" -B "$build_dir" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$JSLING_INSTALL_PREFIX" \
        -DCMAKE_CXX_STANDARD=17; then
        fail "CMake configuration failed. See configuration errors above."
    fi

    # Build
    if ! cmake --build "$build_dir" --config Release -j"$cores"; then
        fail "Build failed. See compilation errors above."
    fi

    success "Build complete"

    # Export the build directory for install
    JSLING_BUILD_DIR="$build_dir"
}

# --- Install binary ---
install_binary() {
    local build_dir="$JSLING_BUILD_DIR"
    local os
    os="$(detect_os)"

    # Determine binary name (Windows uses .exe)
    local bin_name="jsling"
    if [ "$os" = "windows" ]; then
        bin_name="jsling.exe"
    fi

    # Find the built binary
    local src_bin=""
    if [ -f "$build_dir/$bin_name" ]; then
        src_bin="$build_dir/$bin_name"
    elif [ -f "$build_dir/Release/$bin_name" ]; then
        src_bin="$build_dir/Release/$bin_name"
    elif [ -f "$build_dir/$JSLING_NAME" ]; then
        src_bin="$build_dir/$JSLING_NAME"
    else
        fail "Could not find built binary in $build_dir"
    fi

    # Create install directory if needed
    mkdir -p "$JSLING_INSTALL_BIN" 2>/dev/null || \
        sudo mkdir -p "$JSLING_INSTALL_BIN" 2>/dev/null || \
        fail "Cannot create directory: $JSLING_INSTALL_BIN"

    # Copy binary
    local dest="$JSLING_INSTALL_BIN/$bin_name"
    if cp "$src_bin" "$dest" 2>/dev/null; then
        chmod +x "$dest" 2>/dev/null || true
    else
        info "Using sudo to install to $JSLING_INSTALL_BIN..."
        sudo cp "$src_bin" "$dest" || fail "Failed to copy binary to $dest"
        sudo chmod +x "$dest" || true
    fi

    success "Installed to $dest"
}

# --- Post-install checks ---
post_install() {
    echo ""
    echo -e "${BOLD}╔══════════════════════════════════════╗${RESET}"
    echo -e "${BOLD}║   jsling installed successfully!     ║${RESET}"
    echo -e "${BOLD}╚══════════════════════════════════════╝${RESET}"
    echo ""

    local bin_path="$JSLING_INSTALL_BIN/jsling"
    local os
    os="$(detect_os)"
    if [ "$os" = "windows" ]; then
        bin_path="$JSLING_INSTALL_BIN/jsling.exe"
    fi

    if [ -f "$bin_path" ]; then
        echo -e "  Binary:   ${GREEN}$bin_path${RESET}"

        # Check if it runs
        local ver
        ver="$("$bin_path" --version 2>/dev/null || echo "unknown")"
        echo -e "  Version:  ${GREEN}$ver${RESET}"
    fi

    # Check PATH
    if ! echo "$PATH" | tr ':' '\n' | grep -qF "$JSLING_INSTALL_BIN" 2>/dev/null; then
        echo ""
        warn "Install directory not in PATH: $JSLING_INSTALL_BIN"
        echo ""
        echo "  Add to PATH by running:"

        case "$(detect_os)" in
            linux)
                if grep -q bash <<< "$SHELL" 2>/dev/null; then
                    echo "    echo 'export PATH=\"$JSLING_INSTALL_BIN:\$PATH\"' >> ~/.bashrc"
                    echo "    source ~/.bashrc"
                elif grep -q zsh <<< "$SHELL" 2>/dev/null; then
                    echo "    echo 'export PATH=\"$JSLING_INSTALL_BIN:\$PATH\"' >> ~/.zshrc"
                    echo "    source ~/.zshrc"
                else
                    echo "    export PATH=\"$JSLING_INSTALL_BIN:\$PATH\""
                fi
                ;;
            macos)
                echo "    echo 'export PATH=\"$JSLING_INSTALL_BIN:\$PATH\"' >> ~/.zshrc"
                echo "    source ~/.zshrc"
                ;;
            windows)
                echo "    export PATH=\"$JSLING_INSTALL_BIN:\$PATH\""
                ;;
        esac
    else
        echo ""
        info "PATH already includes $JSLING_INSTALL_BIN"
    fi

    echo ""
    echo "  Quick start:"
    echo "    jsling                  # Start REPL"
    echo "    jsling script.js        # Run a file"
    echo "    jsling -e \"1 + 2\"       # Evaluate expression"
    echo ""
}

# --- Main ---
main() {
    echo ""
    echo -e "${BOLD}jsling installer${RESET}"
    echo "=================="
    echo ""

    local os arch
    os="$(detect_os)"
    arch="$(detect_arch)"
    info "Detected: $os / $arch"

    if [ "$os" = "linux" ]; then
        local install_confirm
        read -p "Do you want to proceed with installing jsling on Linux? [Y/n]: " -r install_confirm
        if [[ "$install_confirm" =~ ^[Nn]$ ]]; then
            info "Installation aborted by user."
            exit 0
        fi
    fi

    determine_prefix
    info "Install target: $JSLING_INSTALL_BIN"

    check_dependencies
    fetch_source
    build_source
    install_binary
    post_install
}

main "$@"
