; USB Security Software Installer Script
; Created with Inno Setup (https://jrsoftware.org/isinfo.php)

#define MyAppName "USB Security"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "Security Solutions"
#define MyAppURL "https://github.com/yourusername/usb-security"
#define MyAppExeName "USB_Security.exe"
#define MyAppDescription "Advanced USB/HDD Security Monitor"

[Setup]
; NOTE: The value of AppId uniquely identifies this application.
AppId={{A1B2C3D4-E5F6-7890-ABCD-EF1234567890}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
AllowNoIcons=yes
LicenseFile=LICENSE.txt
InfoBeforeFile=INSTALLATION_INFO.txt
OutputDir=installer
OutputBaseFilename=USB_Security_Setup_v{#MyAppVersion}
SetupIconFile=assets\app_icon.ico
Compression=lzma
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=admin
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
Name: "quicklaunchicon"; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked; OnlyBelowVersion: 6.1
Name: "autostart"; Description: "Start {#MyAppName} automatically with Windows"; GroupDescription: "Startup Options:"; Flags: checked

[Files]
Source: "dist\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "dist\config\*"; DestDir: "{app}\config"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "dist\README.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "dist\requirements.txt"; DestDir: "{app}"; Flags: ignoreversion
Source: "dist\INSTALLATION_INFO.txt"; DestDir: "{app}"; Flags: ignoreversion
Source: "dist\Start_USB_Security.bat"; DestDir: "{app}"; Flags: ignoreversion
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{group}\{#MyAppName} (Safe Mode)"; Filename: "{app}\Start_USB_Security.bat"
Name: "{group}\Configuration"; Filename: "{app}\config"
Name: "{group}\Documentation"; Filename: "{app}\README.md"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon
Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: quicklaunchicon

[Registry]
; Auto-start registry entry
Root: HKCU; Subkey: "Software\Microsoft\Windows\CurrentVersion\Run"; ValueType: string; ValueName: "{#MyAppName}"; ValueData: """{app}\{#MyAppExeName}"""; Flags: uninsdeletevalue; Tasks: autostart

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#MyAppName}}"; Flags: nowait postinstall skipifsilent runascurrentuser

[UninstallRun]
Filename: "taskkill"; Parameters: "/f /im ""{#MyAppExeName}"""; Flags: runhidden; RunOnceId: "KillApp"

[Code]
function InitializeSetup(): Boolean;
var
  ResultCode: Integer;
begin
  // Check if application is already running
  if CheckForMutexes('USB_Security_Mutex') then
  begin
    if MsgBox('USB Security is currently running. Setup needs to close it before continuing.' + #13#10 + #13#10 + 'Click OK to close the application and continue, or Cancel to exit setup.', mbConfirmation, MB_OKCANCEL) = IDOK then
    begin
      Exec('taskkill', '/f /im USB_Security.exe', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
      Sleep(2000); // Wait for process to terminate
    end
    else
    begin
      Result := False;
      Exit;
    end;
  end;
  Result := True;
end;

function InitializeUninstall(): Boolean;
var
  ResultCode: Integer;
begin
  // Kill the application before uninstalling
  Exec('taskkill', '/f /im USB_Security.exe', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  Sleep(1000);
  Result := True;
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
  begin
    // Create application mutex for single instance detection
    // This is handled by the application itself
  end;
end;

function ShouldSkipPage(PageID: Integer): Boolean;
begin
  Result := False;
  // Skip license page if no license file exists
  if (PageID = wpLicense) and not FileExists(ExpandConstant('{src}\LICENSE.txt')) then
    Result := True;
end;

procedure CurPageChanged(CurPageID: Integer);
begin
  if CurPageID = wpWelcome then
  begin
    WizardForm.WelcomeLabel2.Caption := 
      'This will install ' + '{#MyAppName}' + ' version ' + '{#MyAppVersion}' + ' on your computer.' + #13#10 + #13#10 +
      '{#MyAppDescription}' + #13#10 + #13#10 +
      'Features:' + #13#10 +
      '• Real-time USB/HDD monitoring' + #13#10 +
      '• Full-screen security alerts' + #13#10 +
      '• Device whitelisting system' + #13#10 +
      '• System tray integration' + #13#10 +
      '• Comprehensive event logging' + #13#10 + #13#10 +
      'It is recommended that you close all other applications before continuing.';
  end;
end;
