# --- ENux Setup Phase 1: Customization and Bedrock Hijack ---
# This script must be run as root after the base Debian install is complete.
# It performs system customization and the irreversible Bedrock Linux hijack.
WALLPAPER_FILE="$HOME/enux-wallpaper.jpg"
PHASE2_SCRIPT="$HOME/Desktop/phase2.sh" # Phase 2 is now visible on the Desktop
PHASE2_TARGET_NAME="phase2.sh" # The name for the file saved in /root
FASTFETCH_CONFIG_DIR="/etc/fastfetch"
FASTFETCH_CONFIG_FILE="$FASTFETCH_CONFIG_DIR/config.jsonc"
BEDROCK_VERSION="0.7.30"
BEDROCK_URL="https://github.com/bedrocklinux/bedrocklinux-userland/releases/download/$BEDROCK_VERSION/bedrock-linux-$BEDROCK_VERSION-x86_64.sh"

echo "==============================================="
echo " ENux Phase 1: Customization and Bedrock Hijack"
echo "==============================================="

# --- 1/5: Creating the 'enux' apt wrapper (Apt Wrapper) ---
echo "--> 1/5: Creating 'enux' apt wrapper..."
cat << 'EOF' > /usr/local/bin/enux
#!/bin/bash
# ENux: Custom wrapper for the Debian/Apt package manager.
if command -v apt &> /dev/null
then
    echo "Running apt command via ENux wrapper (Debian stratum)..."
    apt "$@"
else
    echo "Error: The 'apt' package manager is not available in the current stratum." >&2
    exit 1
fi
EOF
chmod +x /usr/local/bin/enux
echo "    -> '/usr/local/bin/enux' created."

# --- 2/5: Install Fastfetch and Apply ENux Branding ---
echo "--> 2/5: Installing fastfetch and applying ENux branding..."
# Use the new enux wrapper to install fastfetch
/usr/local/bin/enux update -y
/usr/local/bin/enux install fastfetch -y

mkdir -p "$FASTFETCH_CONFIG_DIR"

# Apply the custom fastfetch configuration
cat << EOF > "$FASTFETCH_CONFIG_FILE"
{
    "\$schema": "https://fastfetch.dev/json-schema",
    "modules": [
        {
            "type": "title",
            "format": "{1}@ENux-Hybrid-Meta_Distro"
        },
        {
            "type": "os",
            "format": "ENux 1.0 x86_64"
        },
        {
            "type": "kernel",
            "format": "linux-6.12.48-enux1-amd64"
        },
        "uptime",
        "shell",
        "de",
        "memory",
        "display",
        "disk",
        {
            "type": "packages",
            "format": "Packages: {1}{2}{3}{4}{5}{6}"
        }
    ]
}
EOF
echo "    -> Fastfetch configuration customized."

# --- 3/5: Setting System-Wide Wallpaper Defaults ---
echo "--> 3/5: Setting system-wide ENux wallpaper defaults..."
if [ -f "$WALLPAPER_FILE" ]; then
    mkdir -p /usr/share/backgrounds
    cp "$WALLPAPER_FILE" /usr/share/backgrounds/enux-wallpaper.jpg
    WALLPAPER_PATH="/usr/share/backgrounds/enux-wallpaper.jpg"
    echo "    -> Wallpaper copied to $WALLPAPER_PATH."

    # Configure GSettings (GNOME, Cinnamon, MATE)
    echo "[org/gnome/desktop/background]" > /etc/dconf/db/local.d/00-enux-wallpaper
    echo "picture-uri='file://$WALLPAPER_PATH'" >> /etc/dconf/db/local.d/00-enux-wallpaper
    echo "picture-uri-dark='file://$WALLPAPER_PATH'" >> /etc/dconf/db/local.d/00-enux-wallpaper
    echo "picture-options='zoom'" >> /etc/dconf/db/local.d/00-enux-wallpaper
    dconf update

    # Configure Xfce defaults (for new users via /etc/skel)
    XFCE_SKEL_DIR="/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml"
    mkdir -p "$XFCE_SKEL_DIR"
    cat << EOF > "$XFCE_SKEL_DIR/xfce4-desktop.xml"
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-desktop" version="1.0">
  <property name="backdrop" type="array">
    <value type="string" value="/backdrop/screen0/monitor0/workspace0"/>
  </property>
  <property name="backdrop" type="string" value="/backdrop/screen0/monitor0/workspace0">
    <property name="workspace0" type="empty">
      <property name="color-style" type="int" value="0"/>
      <property name="image-style" type="int" value="5"/>
      <property name="last-image" type="string" value="$WALLPAPER_PATH"/>
    </property>
  </property>
</channel>
EOF
    echo "    -> Desktop environment defaults set."
    
    # Cleanup wallpaper from user's home directory/desktop
    rm -f "$WALLPAPER_FILE"
    echo "    -> Cleaned up enux-wallpaper.jpg from user home."
else
    echo "    -> WARNING: Wallpaper file '$WALLPAPER_FILE' not found. Skipping wallpaper setup."
fi

# --- 4/5: Bedrock Linux Download and Hijack ---
echo "--> 4/5: Downloading Bedrock Linux $BEDROCK_VERSION..."
wget "$BEDROCK_URL" -O /tmp/bedrock-install.sh
chmod +x /tmp/bedrock-install.sh

echo "--> Executing Bedrock Hijack (Responding 'Not reversible!' automatically)..."
yes "Not reversible!" | /tmp/bedrock-install.sh --hijack

# --- 5/5: Prepare and Reboot ---
echo "--> 5/5: Preparing for Phase 2 and Reboot..."
if [ -f "$PHASE2_SCRIPT" ]; then
    # Copy Phase 2 script from its Desktop location to /root/
    cp "$PHASE2_SCRIPT" "/root/$PHASE2_TARGET_NAME"
    chmod +x "/root/$PHASE2_TARGET_NAME"
    echo "    -> Phase 2 script saved to /root/$PHASE2_TARGET_NAME."
    
    # NOTE: Phase 2 is NO LONGER deleted from the desktop here.
else
    echo "    -> ERROR: Phase 2 script '$PHASE2_SCRIPT' not found. Cannot proceed."
fi

# Cleanup
rm -f /tmp/bedrock-install.sh
# NOTE: Phase 1 script (which is $0) is NO LONGER deleted here.
echo "    -> NOTE: phase1.sh and phase2.sh icons remain on the desktop for user convenience."

echo "==============================================="
echo " SUCCESS! Bedrock Hijack is complete."
echo " The system needs to reboot now to finalize."
echo " After reboot, log in as root and run /root/$PHASE2_TARGET_NAME"
echo "==============================================="

read -p "Press Enter to reboot now, or Ctrl+C to cancel and reboot manually later."
reboot
