#!/bin/env bash

f=./wine_smoothfonts.reg
reg='
REGEDIT4
 
[HKEY_CURRENT_USER\Control Panel\Desktop]
"FontSmoothing"="2"
"FontSmoothingType"=dword:00000002
"FontSmoothingGamma"=dword:00000578
"FontSmoothingOrientation"=dword:00000001
'
#echo $reg > $f
wine regedit $f
if [ $? -eq 0 ]; then
    echo "OK.. register wine smooth fonts"
else
    echo "Failed to register wine smooth fonts"; exit 1
fi
