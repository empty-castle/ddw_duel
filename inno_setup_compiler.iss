[Setup]
AppName=DDWduel
AppVersion=1.0
AppId={{00fce5fd-5630-40cd-87df-f4452c5cc339}}
DefaultDirName={pf}\DDWduel
DefaultGroupName=DDWduel
OutputDir=.
OutputBaseFilename=DDWduelSetup-1.0
Compression=lzma
SolidCompression=yes

[Files]
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\DDWduel"; Filename: "{app}\ddw_duel.exe"