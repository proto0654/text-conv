#!/usr/bin/env bash
# Установка text-conv в ~/.local/bin (или в каталог из первого аргумента).
set -euo pipefail

here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
target=${1:-$HOME/.local/bin}

for dep in python3 wtype wl-copy wl-paste; do
  command -v "$dep" >/dev/null || {
    echo "Не хватает: $dep" >&2
    echo "Arch: sudo pacman -S --needed python wtype wl-clipboard" >&2
    exit 1
  }
done

mkdir -p "$target"
install -m 755 "$here/text-conv" "$target/text-conv"
echo "Установлено: $target/text-conv"

case ":$PATH:" in
  *":$target:"*) ;;
  *) echo "Внимание: $target нет в PATH — используйте полный путь в биндингах." ;;
esac

cat <<EOF

Добавьте в ~/.config/hypr/bindings.lua (release = true, без ignore_mods —
иначе на одно нажатие сработают оба биндинга):

  o.bind("SHIFT + PAUSE", "Сменить раскладку выделенного", "$target/text-conv layout", { release = true })
  o.bind("SHIFT + BREAK", "Сменить раскладку выделенного", "$target/text-conv layout", { release = true })
  o.bind("CTRL + PAUSE", "Инвертировать регистр выделенного", "$target/text-conv case", { release = true })
  o.bind("CTRL + BREAK", "Инвертировать регистр выделенного", "$target/text-conv case", { release = true })

Затем: hyprctl reload && hyprctl configerrors
EOF
