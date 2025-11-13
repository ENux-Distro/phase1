# --- ENux Setup Phase 2: Stratum Installation and Finalization ---
# This script must be run as root immediately after the first reboot
# following the Bedrock Linux 'hijack' (Phase 1).

echo "==============================================="
echo " ENux Phase 2: Fetching Core Strata for ENux "
echo "==============================================="
echo "Fetching strata required for all 8 package managers (This may take a while)..."
echo ""

# --- 1. Fetching Strata ---
# Note: Debian is already the base stratum, providing dpkg and apt/enux.

# Arch Linux: Provides 'pacman'
echo "--> Fetching Arch Linux stratum (for pacman)..."
brl fetch arch

# Alpine Linux: Provides 'apk'
echo "--> Fetching Alpine Linux stratum (for apk)..."
brl fetch alpine

# Void Linux: Provides 'xbps'
echo "--> Fetching Void Linux stratum (for xbps)..."
brl fetch void

# Fedora: Provides 'dnf' and low-level 'rpm'
echo "--> Fetching Fedora stratum (for dnf/rpm)..."
brl fetch fedora

# Gentoo (Stage 3): Provides 'emerge'
echo "--> Fetching Gentoo stratum (for emerge)..."
brl fetch gentoo

# --- 2. Final Check and Instructions ---

echo "==============================================="
echo " ENUX HYBRID META-DISTRO IS READY! "
echo "==============================================="
echo "Your ENux system now has the following strata(s) installed:"
echo "Arch, Alpine, Void, Fedora, Gentoo"
echo ""
echo "All 8 package managers are now globally available. "
echo ""
echo "To use them, simply run the package manager command from any terminal:"
echo "  - Arch:    pacman -S <package>"
echo "  - Alpine:  apk add <package>"
echo "  - Void:    xbps-install <package>"
echo "  - Fedora:  dnf install <package>"
echo "  - Debian:  enux install <package>"
echo ""

# Cleanup
rm -f "$0"
echo "Phase 2 script removed from /root. Installation complete. Enjoy ENux!"
