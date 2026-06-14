#!/usr/bin/env bash
# =============================================================================
# jsling local installer - builds and installs from current source tree
# Usage: bash install-local.sh [--prefix /usr/local] [--uninstall]
# =============================================================================
set -euo pipefail

# --- Colors ---
if [ -t 1 ]; then
    RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
    BLUE='\033[0;34m'; BOLD='\033[1m'; RESET='\033[0m'
else
    RED='' GREEN='' YELLOW='' BLUE='' BOLD='' RESET=''
fi

info()    { echo -e "${BLUE}info${RESET}  $*"; }
success() { echo -e "${GREEN}done${RESET}  $*"; }
warn()    { echo -e "${YELLOW}warn${RESET}  $*"; }
fail()    { echo -e "${RED}error${RESET} $*" >&2; exit 1; }

# --- Configuration ---
JSLING_NAME="jsling"
PREFIX=""
UNINSTALL=false
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# --- Parse arguments ---
while [ $# -gt 0 ]; do
    case "$1" in
        --prefix)    PREFIX="$2"; shift 2;;
        --prefix=*)  PREFIX="${1#*=}"; shift;;
        --uninstall) UNINSTALL=true; shift;;
        --help|-h)
            echo "jsling local installer"
            echo ""
            echo "Usage: bash install-local.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --prefix <path>    Install location (default: auto-detect)"
            echo "  --uninstall        Remove jsling from system"
            echo "  --help             Show this help"
            exit 0
            ;;
        *) fail "Unknown argument: $1 (try --help)";;
    esac
done

# --- Detect OS ---
detect_os() {
    case "$(uname -s)" in
        Linux*)  echo "linux";;
        Darwin*) echo "macos";;
        MINGW*|MSYS*|CYGWIN*) echo "windows";;
        *) fail "Unsupported OS: $(uname -s)";;
    esac
}

# --- Determine prefix ---
determine_prefix() {
    if [ -n "$PREFIX" ]; then return; fi

    local os
    os="$(detect_os)"

    case "$os" in
        linux|macos)
            if [ -w /usr/local/bin ] || [ "$(id -u)" = "0" ]; then
                PREFIX="/usr/local"
            else
                PREFIX="${HOME}/.local"
            fi
            ;;
        windows)
            PREFIX="${HOME}"
            ;;
    esac
}

# --- Uninstall ---
do_uninstall() {
    determine_prefix
    local os
    os="$(detect_os)"
    local bin_name="jsling"
    [ "$os" = "windows" ] && bin_name="jsling.exe"
    local target="$PREFIX/bin/$bin_name"

    if [ -f "$target" ]; then
        info "Removing $target..."
        rm -f "$target" 2>/dev/null || sudo rm -f "$target" || fail "Cannot remove $target"
        success "$JSLING_NAME uninstalled"
    else
        warn "No installation found at $target"
    fi
    exit 0
}

# --- Main ---
main() {
    echo ""
    echo -e "${BOLD}jsling local installer${RESET}"
    echo "========================"
    echo ""

    local os
    os="$(detect_os)"

    [ "$UNINSTALL" = true ] && do_uninstall

    info "Source directory: $PROJECT_DIR"

    # Verify source exists
    if [ ! -f "$PROJECT_DIR/CMakeLists.txt" ]; then
        fail "CMakeLists.txt not found in $PROJECT_DIR"
    fi

    determine_prefix
    info "Install prefix: $PREFIX"

    # Check dependencies
    info "Checking dependencies..."
    command -v cmake &>/dev/null || fail "cmake not found"
    (command -v g++ &>/dev/null || command -v clang++ &>/dev/null) || fail "C++ compiler not found (need g++ or clang++)"
    (command -v make &>/dev/null || command -v ninja &>/dev/null) || fail "Build tool not found (need make or ninja)"
    success "Dependencies OK"

    # Build
    local build_dir="$PROJECT_DIR/build-release"
    info "Building in Release mode..."

    local cores
    if command -v nproc &>/dev/null; then cores="$(nproc)"
    elif command -v sysctl &>/dev/null; then cores="$(sysctl -n hw.ncpu 2>/dev/null || echo 1)"
    else cores=1; fi

    cmake -S "$PROJECT_DIR" -B "$build_dir" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$PREFIX" \
        -DCMAKE_CXX_STANDARD=17 \
        > /dev/null 2>&1 || fail "CMake configure failed"

    cmake --build "$build_dir" --config Release -j"$cores" \
        > /dev/null 2>&1 || fail "Build failed"

    success "Build complete"

    # Install
    local bin_name="jsling"
    [ "$os" = "windows" ] && bin_name="jsling.exe"
    local src_bin="$build_dir/$bin_name"

    # Handle Release subdirectory on some platforms
    [ -f "$build_dir/Release/$bin_name" ] && src_bin="$build_dir/Release/$bin_name"
    [ -f "$build_dir/$JSLING_NAME" ] && src_bin="$build_dir/$JSLING_NAME"

    [ -f "$src_bin" ] || fail "Binary not found at $src_bin"

    mkdir -p "$PREFIX/bin" 2>/dev/null || \
        sudo mkdir -p "$PREFIX/bin" 2>/dev/null || \
        fail "Cannot create $PREFIX/bin"

    local dest="$PREFIX/bin/$bin_name"
    if cp "$src_bin" "$dest" 2>/dev/null; then
        chmod +x "$dest"
    else
        info "Using sudo..."
        sudo cp "$src_bin" "$dest"
        sudo chmod +x "$dest"
    fi

    success "Installed: $dest"

    # Cleanup build dir
    rm -rf "$build_dir"

    echo ""
    echo -e "${BOLD}╔══════════════════════════════════════╗${RESET}"
    echo -e "${BOLD}║   jsling installed successfully!     ║${RESET}"
    echo -e "${BOLD}╚══════════════════════════════════════╝${RESET}"
    echo ""

    # Version check
    if [ -f "$dest" ]; then
        local ver
        ver="$("$dest" --version 2>/dev/null || echo "unknown")"
        echo -e "  Binary:  ${GREEN}$dest${RESET}"
        echo -e "  Version: ${GREEN}$ver${RESET}"
    fi

    # PATH check
    if ! echo "$PATH" | tr ':' '\n' | grep -qF "$PREFIX/bin" 2>/dev/null; then
        echo ""
        warn "$PREFIX/bin not in PATH"
        echo ""
        echo "  Add to your shell config:"
        case "$os" in
            linux)
                echo "    echo 'export PATH=\"$PREFIX/bin:\$PATH\"' >> ~/.bashrc"
                echo "    source ~/.bashrc"
                ;;
            macos)
                echo "    echo 'export PATH=\"$PREFIX/bin:\$PATH\"' >> ~/.zshrc"
                echo "    source ~/.zshrc"
                ;;
            windows)
                echo "    export PATH=\"$PREFIX/bin:\$PATH\""
                ;;
        esac
    fi

    echo ""
    echo "  Quick start:"
    echo "    jsling                  # Start REPL"
    echo "    jsling script.js        # Run a file"
    echo "    jsling -e \"1 + 2\"       # Evaluate expression"
    echo ""
}

main "$@"
