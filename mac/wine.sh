#!/usr/bin/env bash
brew install wine

brew install winetricks

winetricks cmd
winetricks comctl32
winetricks comctl32ocx
winetricks comdlg32ocx
winetricks riched30
winetricks richtx32
winetricks mdac28
winetricks jet40
winetricks mfc42
winetricks msxml6
winetricks vb6run
winetricks vcrun2003
winetricks vcrun2005
winetricks vcrun2008
winetricks vcrun2012
winetricks vcrun2013
winetricks vcrun2015

winetricks vcrun6sp6

winetricks wenquanyi

winetricks fakechinese

winetricks ddr=opengl

winetricks fontsmooth=rgb
