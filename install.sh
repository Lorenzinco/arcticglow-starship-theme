#!/usr/bin/env bash

set -euo pipefail

THEME_NAME="arcticglow"
INSTALL_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE_THEME="$INSTALL_DIR/$THEME_NAME.toml"
TARGET_DIR="$HOME/.config/starship_themes"
TARGET_THEME="$TARGET_DIR/$THEME_NAME.toml"
THEME_CONFIG_REL=".config/starship_themes/$THEME_NAME.toml"

RC_FILES=(
    "$HOME/.bashrc"
    "$HOME/.bash_profile"
    "$HOME/.zshrc"
    "$HOME/.profile"
    "$HOME/.config/fish/config.fish"
    "$HOME/.config/ion/initrc"
    "$HOME/.tcshrc"
    "$HOME/.xonshrc"
    "$HOME/.config/elvish/rc.elv"
    "$HOME/.config/nushell/env.nu"
    "$HOME/.config/nushell/config.nu"
    "$HOME/.config/powershell/Microsoft.PowerShell_profile.ps1"
)

echo_error() {
    printf '\033[0;31mError: %s\033[0m\n' "$1"
}

echo_info() {
    printf '\033[0;32mInfo: %s\033[0m\n' "$1"
}

normalize_shell_name() {
    local shell_name
    shell_name="$(basename "${1:-${SHELL:-bash}}")"

    case "$shell_name" in
        bash|zsh|fish|ion|tcsh|xonsh|elvish|nu|pwsh|powershell)
            echo "$shell_name"
            ;;
        sh|ash|dash)
            echo "bash"
            ;;
        *)
            echo "bash"
            ;;
    esac
}

infer_shell_from_rc_file() {
    case "$1" in
        */.bashrc|*/.bash_profile)
            echo "bash"
            ;;
        */.zshrc)
            echo "zsh"
            ;;
        */config.fish)
            echo "fish"
            ;;
        */.config/ion/initrc)
            echo "ion"
            ;;
        */.tcshrc)
            echo "tcsh"
            ;;
        */.xonshrc)
            echo "xonsh"
            ;;
        */rc.elv)
            echo "elvish"
            ;;
        */.config/nushell/env.nu|*/.config/nushell/config.nu)
            echo "nu"
            ;;
        */Microsoft.PowerShell_profile.ps1)
            echo "pwsh"
            ;;
        *)
            normalize_shell_name "${SHELL:-bash}"
            ;;
    esac
}

select_rc_file() {
    case "$1" in
        bash)
            if [ -f "$HOME/.bashrc" ]; then
                echo "$HOME/.bashrc"
            else
                echo "$HOME/.bash_profile"
            fi
            ;;
        zsh)
            echo "$HOME/.zshrc"
            ;;
        fish)
            echo "$HOME/.config/fish/config.fish"
            ;;
        ion)
            echo "$HOME/.config/ion/initrc"
            ;;
        tcsh)
            echo "$HOME/.tcshrc"
            ;;
        xonsh)
            echo "$HOME/.xonshrc"
            ;;
        elvish)
            echo "$HOME/.config/elvish/rc.elv"
            ;;
        nu)
            echo "$HOME/.config/nushell/env.nu"
            ;;
        pwsh|powershell)
            echo "$HOME/.config/powershell/Microsoft.PowerShell_profile.ps1"
            ;;
        *)
            echo "$HOME/.profile"
            ;;
    esac
}

starship_config_for_shell() {
    case "$1" in
        fish)
            echo 'set -gx STARSHIP_CONFIG ~/.config/starship_themes/arcticglow.toml'
            ;;
        ion)
            echo 'let-env STARSHIP_CONFIG = "$HOME/.config/starship_themes/arcticglow.toml"'
            ;;
        tcsh)
            echo 'setenv STARSHIP_CONFIG "$HOME/.config/starship_themes/arcticglow.toml"'
            ;;
        xonsh)
            echo '$STARSHIP_CONFIG = f"{$HOME}/.config/starship_themes/arcticglow.toml"'
            ;;
        elvish)
            echo 'set-env STARSHIP_CONFIG (printf "%s/.config/starship_themes/arcticglow.toml" $E:HOME)'
            ;;
        nu)
            echo '$env.STARSHIP_CONFIG = $"($env.HOME)/.config/starship_themes/arcticglow.toml"'
            ;;
        pwsh|powershell)
            echo '$env:STARSHIP_CONFIG = "$HOME/.config/starship_themes/arcticglow.toml"'
            ;;
        *)
            echo 'export STARSHIP_CONFIG="$HOME/.config/starship_themes/arcticglow.toml"'
            ;;
    esac
}

starship_init_for_shell() {
    case "$1" in
        fish)
            echo 'starship init fish | source'
            ;;
        ion)
            echo 'eval $(starship init ion)'
            ;;
        tcsh)
            echo 'eval `starship init tcsh`'
            ;;
        xonsh)
            echo 'execx($(starship init xonsh))'
            ;;
        elvish)
            echo 'eval (starship init elvish)'
            ;;
        nu)
            echo ''
            ;;
        pwsh|powershell)
            echo 'Invoke-Expression (&starship init powershell)'
            ;;
        *)
            echo 'eval "$(starship init '"$1"')"'
            ;;
    esac
}

has_starship_init() {
    local rc_file

    for rc_file in "${RC_FILES[@]}"; do
        if [ -f "$rc_file" ] && grep -Eq 'starship[[:space:]]+init|starship\.nu|Invoke-Expression.*starship' "$rc_file"; then
            echo "$rc_file"
            return 0
        fi
    done

    return 1
}

ensure_starship_config() {
    local rc_file="$1"
    local shell_name="$2"
    local config_line

    config_line="$(starship_config_for_shell "$shell_name")"

    if grep -Fq "$THEME_CONFIG_REL" "$rc_file"; then
        echo "Detected Arctic Glow Starship config in $rc_file"
        return 0
    fi

    echo "Adding Arctic Glow Starship config to $rc_file"
    {
        printf '\n'
        printf '# Arctic Glow Starship theme\n'
        printf '%s\n' "$config_line"
    } >> "$rc_file"
}

ensure_starship_init() {
    local rc_file="$1"
    local shell_name="$2"
    local init_line

    if [ "$shell_name" = "nu" ]; then
        ensure_nushell_init
        return 0
    fi

    if grep -Eq 'starship[[:space:]]+init|starship\.nu|Invoke-Expression.*starship' "$rc_file"; then
        echo "Detected Starship initialization in $rc_file"
        return 0
    fi

    init_line="$(starship_init_for_shell "$shell_name")"

    echo "Adding Starship initialization to $rc_file"
    {
        printf '\n'
        printf '# Starship prompt\n'
        printf '%s\n' "$init_line"
    } >> "$rc_file"
}

ensure_nushell_init() {
    local data_home autoload_dir starship_nu

    data_home="${XDG_DATA_HOME:-$HOME/.local/share}"
    autoload_dir="$data_home/nushell/vendor/autoload"
    starship_nu="$autoload_dir/starship.nu"

    mkdir -p "$autoload_dir"

    if [ -f "$starship_nu" ]; then
        echo "Detected Starship Nushell init in $starship_nu"
        return 0
    fi

    echo "Adding Starship Nushell init to $starship_nu"
    starship init nu > "$starship_nu"
}

if [ ! -f "$SOURCE_THEME" ]; then
    echo_error "$SOURCE_THEME not found."
    echo "Please make sure you have cloned the repository correctly."
    exit 1
fi

if ! command -v starship >/dev/null 2>&1; then
    echo_error "Starship was not found in PATH."
    echo "Install Starship first: https://starship.rs/guide/#installation"
    exit 1
fi

mkdir -p "$TARGET_DIR"
echo "Copying theme to $TARGET_THEME"
cp "$SOURCE_THEME" "$TARGET_THEME"

shell_name="$(normalize_shell_name "${SHELL:-bash}")"

if existing_rc="$(has_starship_init)"; then
    rc_file="$existing_rc"
    shell_name="$(infer_shell_from_rc_file "$rc_file")"
else
    rc_file="$(select_rc_file "$shell_name")"
fi

mkdir -p "$(dirname "$rc_file")"
touch "$rc_file"

ensure_starship_config "$rc_file" "$shell_name"
ensure_starship_init "$rc_file" "$shell_name"

echo "Successfully installed $THEME_NAME for Starship."
echo_info "Please restart your terminal to see the changes."
