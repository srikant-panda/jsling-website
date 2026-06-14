; JSling Windows Installer Script (Inno Setup)
; ------------------------------------------------------------
; How to use:
; 1. Install Inno Setup (free): https://jrsoftware.org/isinfo.php
; 2. Place jsling.exe in the same folder as this script
;    (or update the Source path below).
; 3. Open this file in Inno Setup and click "Compile"
;    (or run from command line: iscc jsling-setup.iss)
; 4. Output: dist\JSling-Setup.exe
;    This is the file you share/download — double-click to install,
;    just like the Node.js or Git installers.

#define MyAppName "JSling"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "JSling Project"
#define MyAppURL "https://github.com/yourusername/jsling"
#define MyAppExeName "jsling.exe"

[Setup]
AppId={{8C1F2B6E-4A3D-4E8F-9C2A-7B1234567890}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
OutputDir=dist
OutputBaseFilename=JSling-Setup
Compression=lzma
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
; Optional: set an icon for the installer itself
; SetupIconFile=jsling.ico

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "addtopath"; Description: "Add JSling to PATH (recommended, like Git/Node installers)"; GroupDescription: "Additional options:"; Flags: checkedonce

[Files]
Source: "jsling.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "WINDOWS_USAGE.md"; DestDir: "{app}"; Flags: ignoreversion isreadme
; If you have a README/LICENSE, add them here too:
; Source: "README.md"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{group}\Uninstall {#MyAppName}"; Filename: "{uninstallexe}"

[Registry]
; Add install dir to user PATH if the task is selected
Root: HKCU; Subkey: "Environment"; ValueType: expandsz; ValueName: "Path"; \
    ValueData: "{olddata};{app}"; Flags: preservestringtype uninsdeletevalue; \
    Check: NeedsAddPath('{app}') and WizardIsTaskSelected('addtopath')

[Code]
function NeedsAddPath(Param: string): boolean;
var
  OrigPath: string;
begin
  if not RegQueryStringValue(HKEY_CURRENT_USER, 'Environment', 'Path', OrigPath) then
  begin
    Result := True;
    exit;
  end;
  // Look for the path with leading and trailing semicolon to avoid partial matches
  Result := Pos(';' + Param + ';', ';' + OrigPath + ';') = 0;
end;

[Run]
Filename: "{cmd}"; Parameters: "/C ""{app}\{#MyAppExeName}"" --version"; \
    Description: "Verify installation"; Flags: postinstall skipifsilent runhidden shellexec

[UninstallDelete]
Type: filesandordirs; Name: "{app}"
