#!/bin/bash

# Helper para formatar bonito (B, KB, MB, GB)
format_size() {
    local size=$1
    if [ "$size" -ge 1073741824 ]; then
        printf "%.2f GB" "$(echo "$size/1073741824" | bc -l)"
    elif [ "$size" -ge 1048576 ]; then
        printf "%.2f MB" "$(echo "$size/1048576" | bc -l)"
    elif [ "$size" -ge 1024 ]; then
        printf "%.2f KB" "$(echo "$size/1024" | bc -l)"
    else
        printf "%d B" "$size"
    fi
}

# Pega o espaço usado em bytes
get_used_space() {
    df --output=used -B1 / | tail -1 | tr -dc '0-9'
}

echo "💽 Disk usage before cleanup: $(format_size $(get_used_space))"
echo ""

echo "🧹 Removing orphan packages (pacman)..."
orphans=$(pacman -Qdtq)
if [[ -n "$orphans" ]]; then
    sudo pacman -Rns $orphans
else
    echo "✅ No orphan packages to remove."
fi

echo "🧼 Clearing pacman cache..."
sudo pacman -Scc --noconfirm

echo "📦 Clearing yay cache..."
yay -Sc --noconfirm

echo "🗑 Removing temporary files..."
sudo rm -rf /var/tmp/*
rm -rf ~/.cache/*

echo "🪵 Vacuuming journal logs (keeping 100MB max)..."
sudo journalctl --vacuum-size=100M

if command -v flatpak >/dev/null 2>&1; then
    echo "📦 Removing unused Flatpak packages..."
    flatpak uninstall --unused -y
else
    echo "⚠️ Flatpak is not installed, skipping Flatpak cleanup."
fi

# Espaço usado depois da limpeza
used_after=$(get_used_space)

# Calcula espaço liberado
freed=$(( $(get_used_space) - $used_after ))

echo ""
echo "✅ Cleanup complete!"
echo "💾 Disk space freed: $(format_size $freed)"

