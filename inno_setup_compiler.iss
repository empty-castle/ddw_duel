[Setup]
AppName=DDWduel
AppVersion=1.0
DefaultDirName={pf}\DDWduel
DefaultGroupName=DDWduel
OutputDir=.
OutputBaseFilename=DDWduelSetup
Compression=lzma
SolidCompression=yes

[Files]
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\DDWduel"; Filename: "{app}\DDWduel.exe"