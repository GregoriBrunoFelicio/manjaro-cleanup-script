
#!/bin/bash

# Get used disk space before cleanup
used_before=$(df --output=used -BG / | tail -1 | tr -dc '0-9')
echo "💽 Disk usage before cleanup: ${used_before}G"
echo ""

echo "🧹 Removing orphan packages (pacman)..."
sudo pacman -Rns $(pacman -Qdtq) 2>/dev/null

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

# Get used disk space after cleanup
used_after=$(df --output=used -BG / | tail -1 | tr -dc '0-9')
freed=$((used_before - used_after))

echo ""
echo "✅ Cleanup complete!"
echo "💾 Disk space freed: ${freed}G"
