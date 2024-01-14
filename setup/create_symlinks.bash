#!/bin/bash

replace_with_symlink() {
    local target="$1"
    local link_name="$2"

    if [ -e "$link_name" ] || [ -L "$link_name" ]; then
        rm -rf "$link_name"
    fi

    ln -s "$target" "$link_name"
}

dotfiles_path="$(readlink -f "$(dirname "$0")/..")"
src_config_path="$dotfiles_path/config"
dest_config_path="$HOME/.config"

for src_path in "$src_config_path"/*; do
    name="$(basename "$src_path")"
    link_path="$dest_config_path/$name"

    replace_with_symlink "$src_path" "$link_path"
done
