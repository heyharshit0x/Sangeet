[Setup]
AppId=B9F6E402-0CAE-4045-BDE6-14BD6C39C4EA
AppVersion=1.0.0+1
AppName=Sangeet Music
AppPublisher=harshit
AppPublisherURL=https://github.com/heyharshit0x/Sangeet
AppSupportURL=https://github.com/heyharshit0x/Sangeet
AppUpdatesURL=https://github.com/heyharshit0x/Sangeet
DefaultDirName={autopf}\sangeetmusic
DisableProgramGroupPage=yes
OutputDir=.
OutputBaseFilename=sangeetmusic-1.0.0
Compression=lzma
SolidCompression=yes
SetupIconFile=..\..\windows\runner\resources\app_icon.ico
WizardStyle=modern
PrivilegesRequired=lowest
LicenseFile=..\..\LICENSE
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "..\..\build\windows\x64\runner\Release\sangeetmusic.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{autoprograms}\Sangeet Music"; Filename: "{app}\sangeetmusic.exe"
Name: "{autodesktop}\Sangeet Music"; Filename: "{app}\sangeetmusic.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\sangeetmusic.exe"; Description: "{cm:LaunchProgram,{#StringChange('Sangeet Music', '&', '&&')}}"; Flags: nowait postinstall skipifsilent
