#!/bin/sh

THE_LIST="AdobeAir.munki
AdobeFlashPlayer.munki
AdobeReaderDC.munki
Atom.munki
Audacity.munki
AutoDMG.munki
Caffeine.munki
Dropbox.munki
Evernote.munki
Firefox.munki
Github.munki
GoogleChrome.munki
GoogleEarth.munki
LibreOffice.munki
MSExcel2016.munki
MSOffice2011Updates.munki
MSOneNote2016.munki
MSOutlook2016.munki
MSPowerPoint2016.munki
MSWord2016.munki
munkiadmin.munki
OpenOffice.munki
Opera.munki
OracleJava8.munki
Packages.munki
Sal.munki
Silverlight.munki
SketchUpMake.munki
Skype.munki
Spotify.munki
TextWrangler.munki
VLC.munki
royaltsx.munki"

autopkg repo-update all
autopkg run -v $THE_LIST
