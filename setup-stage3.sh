#!/bin/bash

. helpers/error.sh
. helpers/prompt.sh
. helpers/funcs.sh

# Determine where the user wants to install the tools
. config/ffxiv-tools-location.sh

SCRIPT_VERSION="3"

should_overwrite()
{
    CHECK_FILE="$1"
    if [[ -f "$CHECK_FILE" ]]; then
        VERSION="$(grep "# VERSION=" "$CHECK_FILE" | cut -d'=' -f2)"
        if [[ "$VERSION" != "" ]]; then
            if [ "$VERSION" -lt "$SCRIPT_VERSION" ]; then
                return 0
            fi
        fi
        return 1
    fi
    return 0
}

echo "Setting up the FFXIV helper scripts."
echo
echo "This script will set up helper scripts in $HOME/$FFXIV_TOOLS_LOCATION/ to launch FFXIV, ACT, or both."
echo
echo "Current script version: $SCRIPT_VERSION."
echo

HAS_PATH="$(grep -P 'export FFXIV_PATH=' $HOME/$FFXIV_TOOLS_LOCATION/ffxiv-env-setup.sh | wc -l)"

if [[ "$HAS_PATH" != "1" ]]; then
    error "Your $HOME/$FFXIV_TOOLS_LOCATION/ffxiv-env-setup.sh script does not have a FFXIV_PATH variable."
    echo "This likely indicates that you're running setup-stage3.sh against an environment built before it was created."
    echo "Please edit the script at $HOME/$FFXIV_TOOLS_LOCATION/ffxiv-env-setup.sh and add a line like the following, with the path corrected for your FFXIV install location:"
    echo "export FFXIV_PATH=\"/home/valarnin/.local/share/Steam/steamapps/common/FINAL FANTASY XIV Online\""
    exit 1
fi

BOOT_DIR=""

SCRIPT_HEADER=$(cat << EOF
#!/bin/bash
# If you want to modify this script yourself, delete the following line to prevent newer versions of setup-stage3.sh from overwriting your changes.
# VERSION=$SCRIPT_VERSION
EOF
)
SCRIPT_START_GAME=$(cat << EOF
$SCRIPT_HEADER

. $HOME/$FFXIV_TOOLS_LOCATION/ffxiv-env-setup.sh
cd \$WINEPREFIX
wine64 "\$XIVLAUNCHER_PATH"
EOF
)
SCRIPT_START_ACT=$(cat << EOF
$SCRIPT_HEADER

. $HOME/$FFXIV_TOOLS_LOCATION/ffxiv-env-setup.sh
cd \$WINEPREFIX
wine64 "\$(cat "\$WINEPREFIX/.ACT_Location")/Advanced Combat Tracker.exe"
EOF
)
SCRIPT_START_BOTH=$(cat << EOF
$SCRIPT_HEADER

. $HOME/$FFXIV_TOOLS_LOCATION/ffxiv-env-setup.sh
cd \$WINEPREFIX
wine64 "\$XIVLAUNCHER_PATH" &
sleep 5
wine64 "\$(cat "\$WINEPREFIX/.ACT_Location")/Advanced Combat Tracker.exe"
EOF
)

SCRIPT_FILE_GAME="$HOME/$FFXIV_TOOLS_LOCATION/ffxiv-run-game.sh"
SCRIPT_FILE_ACT="$HOME/$FFXIV_TOOLS_LOCATION/ffxiv-run-act.sh"
SCRIPT_FILE_BOTH="$HOME/$FFXIV_TOOLS_LOCATION/ffxiv-run-both.sh"

echo "Checking for local changes to $SCRIPT_FILE_GAME..."

should_overwrite "$SCRIPT_FILE_GAME"
if [[ "$?" == "0" ]]; then
    echo "Writing the file"
    echo "$SCRIPT_START_GAME" > "$SCRIPT_FILE_GAME"
    chmod +x "$SCRIPT_FILE_GAME"
else
    echo "Skipping the file"
fi
echo

echo "Checking for local changes to $SCRIPT_FILE_ACT..."

should_overwrite "$SCRIPT_FILE_ACT"
if [[ "$?" == "0" ]]; then
    echo "Writing the file"
    echo "$SCRIPT_START_ACT" > "$SCRIPT_FILE_ACT"
    chmod +x "$SCRIPT_FILE_ACT"
else
    echo "Skipping the file"
fi
echo

echo "Checking for local changes to $SCRIPT_FILE_BOTH..."

should_overwrite "$SCRIPT_FILE_BOTH"
if [[ "$?" == "0" ]]; then
    echo "Writing the file"
    echo "$SCRIPT_START_BOTH" > "$SCRIPT_FILE_BOTH"
    chmod +x "$SCRIPT_FILE_BOTH"
else
    echo "Skipping the file"
fi

PROMPT_DESKTOP_ENTRIES
