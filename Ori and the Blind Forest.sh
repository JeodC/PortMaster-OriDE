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
GAMEDIR=/$directory/ports/ori

# CD and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
$ESUDO chmod +x -R $GAMEDIR/*

# Determine exe and setup config folders
mkdir -p $GAMEDIR/config
if [ -f "$GAMEDIR/data/oriDE.exe" ]; then
    EXE="oriDE.exe"
    SPLASH="splashDE.png"
    bind_directories "$WINEPREFIX/drive_c/users/root/AppData/Local/Ori and the Blind Forest DE" "$GAMEDIR/config"
else
    EXE="ori.exe"
    SPLASH="splash.png"
    bind_directories "$WINEPREFIX/drive_c/users/root/AppData/Local/Ori and the Blind Forest" "$GAMEDIR/config"
fi

# Display loading splash
[ "$CFW_NAME" == "muOS" ] && $ESUDO $GAMEDIR/splash "$SPLASH" 1
$ESUDO $GAMEDIR/splash "$SPLASH" 30000 & 

# Exports
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export WINEPREFIX=/storage/.wine64
export WINEDEBUG=-all

# Run the game
$GPTOKEYB "$EXE" -c "./ori.gptk" &
box64 wine64 "./data/$EXE"

# Kill processes
pm_finish