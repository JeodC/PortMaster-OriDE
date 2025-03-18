#!/bin/bash

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

# Variables
GAMEDIR="/$directory/windows/ori"

# CD and set log
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Exports
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export WINEDEBUG=-all

# Determine exe and setup config folders
mkdir -p $GAMEDIR/config
if [ -f "$GAMEDIR/data/oriDE.exe" ]; then
    EXEC="oriDE.exe"
    SPLASH="splashDE.png"
    bind_directories "$WINEPREFIX/drive_c/users/root/AppData/Local/Ori and the Blind Forest DE" "$GAMEDIR/config"
else
    EXEC="ori.exe"
    SPLASH="splash.png"
    bind_directories "$WINEPREFIX/drive_c/users/root/AppData/Local/Ori and the Blind Forest" "$GAMEDIR/config"
fi

# Determine architecture
if file "$GAMEDIR/data/$EXEC" | grep -q "PE32" && ! file "$GAMEDIR/data/$EXEC" | grep -q "PE32+"; then
    export WINEARCH=win32
    export WINEPREFIX=~/.wine32
elif file "$GAMEDIR/data/$EXEC" | grep -q "PE32+"; then
    export WINEPREFIX=~/.wine64
else
    echo "Unknown file format"
fi

# Display loading splash
chmod +x "$GAMEDIR/splash"
$ESUDO $GAMEDIR/splash "$SPLASH" 30000 & 

# Install dependencies
if ! winetricks list-installed | grep -q "^dxvk2041$"; then
    pm_message "Installing dependencies."
    winetricks dxvk2041
fi

# Run the game
$GPTOKEYB "$EXEC" -c "$GAMEDIR/ori.gptk" &
box64 wine "$GAMEDIR/data/$EXEC"

# Kill processes
wineserver -k
pm_finish