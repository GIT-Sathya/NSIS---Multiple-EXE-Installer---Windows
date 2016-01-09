;Demo softare Installer with JRE check and external installers using NSIS installer
;Copyright 2015-2016
;Multiple EXE  Installer Script by Sathya
;Use MakeNSISW to compile this script
;Use NSIS 3.0 version and install UAC plugin for Admin rights

!define PRODUCT_NAME "AppName"
!define PRODUCT_VERSION "AppVersion"
!define PRODUCT_PUBLISHER "AppPublisher"
!define PRODUCT_WEB_SITE "www.yourAppwebsite.co.in"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"
!define PRODUCT_DIR_REGKEY "Software\Microsoft\Windows\CurrentVersion\App Paths\${PRODUCT_NAME}.exe"
!define JRE_URL "javadl.sun.com/webapps/download/AutoDL?BundleId=95501"
!define JAVAEXE "javaw.exe"
!define JRE_VERSION "8.0"
!define PRODUCT_DEFAULT_PATH "C:"
!define /file WELCOME_TITLE  "Welcome.txt"

!define InstallDirBackupFiles "C:\${PRODUCT_NAME}\backupFolder"

SetCompressor BZIP2


!include  "MUI2.nsh"
!include  "MUI.nsh"
!include  "UAC.nsh"
!include  "FileFunc.nsh"
!include  "WordFunc.nsh"
!include  "nsDialogs.nsh"
!include  "sections.nsh"
!include  "LogicLib.nsh"

Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
OutFile "${PRODUCT_NAME}_Setup.exe"
InstallDir "C:\${PRODUCT_NAME}"
InstallDirRegKey HKLM "${PRODUCT_DIR_REGKEY}" ""
!insertmacro VersionCompare
!insertmacro GetParameters

;!define MUI_CUSTOMFUNCTION_ABORT "AbortGUI"
!define MUI_ABORTWARNING
!define MUI_ICON "logo.ico"
!define MUI_UNICON "logo.ico"
!define MUI_WELCOMEFINISHPAGE_BITMAP "launch-screen.bmp"
!define MUI_UNWELCOMEFINISHPAGE_BITMAP "launch-screen.bmp"
!define MUI_PAGE_CUSTOMFUNCTION_SHOW  WelcomeShowCallback




!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "PrivacyLaws.txt"
page custom InitComponentsPage
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_INSTFILES

!insertmacro MUI_PAGE_FINISH

SectionGroup "AppName" App_Group
 
#Intialize JRE section 
Section "Jre" Jre_sec
DetailPrint "Starting the JRE installation"
SendMessage $HWNDPARENT ${WM_SETTEXT} 0 "STR:JRE Installation"
Call GetJRE
SectionEnd


#check JRE is installed in system or not
Function InitComponentsPage

 call CheckJRE

Functionend

 

!define MUI_STARTMENUPAGE_DEFAULTFOLDER "${PRODUCT_NAME}"
!define MUI_STARTMENUPAGE_REGISTRY_ROOT "${PRODUCT_UNINST_ROOT_KEY}"
!define MUI_STARTMENUPAGE_REGISTRY_KEY "${PRODUCT_UNINST_KEY}"
!define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "${PRODUCT_NAME}"

!define MUI_FINISHPAGE_RUN "$INSTDIR\${PRODUCT_NAME}.exe"
!define MUI_FINISHPAGE_SHOWREADME "$INSTDIR\Readme.txt"
!define MUI_FINISHPAGE_LINK "http://google.com"
!define MUI_FINISHPAGE_LINK_LOCATION "${PRODUCT_WEB_SITE}"
!define MUI_UNABORTWARNING
!insertmacro MUI_UNPAGE_WELCOME
!insertmacro MUI_UNPAGE_INSTFILES

!insertmacro MUI_LANGUAGE "English"


LicenseText " "
LicenseData "PrivacyLaws.txt"
ShowInstDetails show

#Backup previous software folders and files
 
!macro BackupFile FILE_DIR FILE BACKUP_TO
 IfFileExists "${BACKUP_TO}\*.*" +2
  CreateDirectory "${BACKUP_TO}"
 IfFileExists "${FILE_DIR}\${FILE}" 0 +2
  Rename "${FILE_DIR}\${FILE}" "${BACKUP_TO}\${FILE}"
!macroend

!macro BackupDir SOURCE_DIR BACKUP_TO
 ; SOURCE_DIR = Source Directory
 ; BACKUP_TO = Backup Directory
 ; INSTDIR = Destination Directory
 ; $R0 = handle from the search function
 ; $R1 = current file

  FindFirst $R0 $R1 "${SOURCE_DIR}\*.*"
  strcmp $R1 "" EndBackup ;Source Dir does not exist

  loop:
       Strcmp $R1 "" EndBackup
       StrCmp $R1 "." next
       StrCmp $R1 ".." next
       IfFileExists "${SOURCE_DIR}\$R1\*.*" next
       ; Backup File
       !insertmacro BackupFile "${InstallDirBackupFiles}" $R1 ${BACKUP_TO}
       ; install new version
      ; File "${SOURCE_DIR}\$R1"
  next:
       FindNext $R0 $R1
  Goto loop

  EndBackup:
  FindClose $R0
!macroend


Section "-MainApp" AppName

!insertmacro BackupDir  ${InstallDirProgramFiles} "$INSTDIR\AppName_old"

SetOutPath "$INSTDIR"

SendMessage $HWNDPARENT ${WM_SETTEXT} 0 "STR: Main App Installation"

File /r InstallerFolder\*.*  ;write here path to your installer directory which contains files.

CreateShortCut "${PRODUCT_DEFAULT_PATH}\${PRODUCT_NAME}\${PRODUCT_NAME}.lnk" "$INSTDIR\${PRODUCT_NAME}.exe"
;CreateShortCut "$DESKTOP\${PRODUCT_NAME}.lnk" "$INSTDIR\${PRODUCT_NAME}.exe""
CreateShortCut "${PRODUCT_DEFAULT_PATH}\${PRODUCT_NAME}\Uninstall.lnk" "$INSTDIR\${PRODUCT_NAME}_Uninst.exe"

;File "";write here path to your program other files
WriteUninstaller "$INSTDIR\${PRODUCT_NAME}_Uninst.exe"
WriteRegStr HKLM "${PRODUCT_DIR_REGKEY}" "" "$INSTDIR\${PRODUCT_NAME}.exe"
WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayName" "$(^Name)"
WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "UninstallString" "$INSTDIR\${PRODUCT_NAME}_Uninst.exe"
WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "URLInfoAbout" "${PRODUCT_WEB_SITE}"

SectionEnd

Section "secondEXE " secondEXE
SendMessage $HWNDPARENT ${WM_SETTEXT} 0 "STR: second EXE Installation"
Call GetsecondEXEInstall
SectionEnd

SectionGroupEnd

;ShowUnInstDetails show
Section "-Uninstall"  Uninstall
Delete "$INSTDIR\${PRODUCT_NAME}_Uninst.exe"
;Delete "$INSTDIR\License.txt" ; write same for your other files
Delete "$INSTDIR\${PRODUCT_NAME}.exe"
Delete "${PRODUCT_DEFAULT_PATH}\${PRODUCT_NAME}\Uninstall.lnk"
;Delete "$DESKTOP\${PRODUCT_NAME}.lnk"
Delete "${PRODUCT_DEFAULT_PATH}\${PRODUCT_NAME}\${PRODUCT_NAME}.lnk"
RMDir "${PRODUCT_DEFAULT_PATH}\${PRODUCT_NAME}"
RMDir "$INSTDIR"
DeleteRegKey ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}"
DeleteRegKey HKLM "${PRODUCT_DIR_REGKEY}"
SetAutoClose true
SectionEnd


;-----------------Custom defined functions--------------------

#welcome text with integrating custom welcome.txt file

Function  WelcomeShowCallback
SendMessage $mui.WelcomePage.Text ${WM_SETTEXT} 0 "STR:${WELCOME_TITLE}"
FunctionEnd


;-----------------Pre defined functions--------------------

 
#JRE must condition for software/ Remove if you want JRE is optional

Function .onSelChange
 

    ${If}        $0 == 1
    ${AndIfNot}  ${SectionIsSelected} ${Jre_sec}
   
       MessageBox MB_ICONINFORMATION "${PRODUCT_NAME} uses Java RuntimeEnvironment ${JRE_VERSION}"

    ${EndIf}
      
    
FunctionEnd


;-----------------Second EXE functions--------------------

 Function GetsecondEXEInstall

 InstallsecondEXE:

  ;MessageBox MB_OK "Installing second EXE"
  DetailPrint "Launching second EXE setup"
  ExecWait '"$INSTDIR\install_flash_player.exe" /passive'
  DetailPrint "Setup finished"

FunctionEnd


;-----------------Jre functions--------------------

Function CheckJRE
    Push $R0
    Push $R1

   CheckLocal:

    ClearErrors
    StrCpy $R0 "$EXEDIR\jre\bin\${JAVAEXE}"
    IfFileExists $R0 JreFound

  CheckJavaHome:

    ClearErrors
    ReadEnvStr $R0 "JAVA_HOME"
    StrCpy $R0 "$R0\bin\${JAVAEXE}"
    IfErrors CheckRegistry
    IfFileExists $R0 0 CheckRegistry
    Call CheckJREVersion
    IfErrors CheckRegistry JreFound


  CheckRegistry:

    ClearErrors
    ReadRegStr $R1 HKLM "SOFTWARE\JavaSoft\Java Runtime Environment" "CurrentVersion"
    ReadRegStr $R0 HKLM "SOFTWARE\JavaSoft\Java Runtime Environment\$R1" "JavaHome"
    StrCpy $R0 "$R0\bin\${JAVAEXE}"
    IfErrors JreNotFound
    IfFileExists $R0 0 JreNotFound
    ;MessageBox MB_OK " $R0 jre found"
    Call CheckJREVersion
    IfErrors JreNotFound JreFound

   JreFound:
     ;!insertmacro UnSelectSection ${Jre_sec}
     ;SectionSetText ${Jre_sec} ""
    
   JreNotFound:
   
FunctionEnd

Function GetJRE
    Push $R0
    Push $R1
    Push $2

  DownloadJRE:

    Call ElevateToAdmin
     MessageBox MB_ICONINFORMATION "${PRODUCT_NAME} uses Java Runtime Environment ${JRE_VERSION}, it will now be downloaded and installed."
    StrCpy $2 "$TEMP\Jre.exe"
    nsisdl::download /TIMEOUT=20000 ${JRE_URL} $2
    Pop $R0 ;Get the return value
    StrCmp $R0 "success" +3
      MessageBox MB_ICONSTOP "Download failed: $R0"
      Abort
    ExecWait $2
    Delete $2

    ReadRegStr $R1 HKLM "SOFTWARE\JavaSoft\Java Runtime Environment" "CurrentVersion"
    ReadRegStr $R0 HKLM "SOFTWARE\JavaSoft\Java Runtime Environment\$R1" "JavaHome"
    StrCpy $R0 "$R0\bin\${JAVAEXE}"
    IfFileExists $R0 0 GoodLuck
    Call CheckJREVersion
    IfErrors GoodLuck JreFound

  GoodLuck:
     StrCpy $R0 "${JAVAEXE}"
     MessageBox MB_ICONSTOP "Cannot find appropriate Java Runtime Environment."
     Abort

  JreFound:
    Pop $2
    Pop $R1
    Exch $R0

FunctionEnd

; Pass the "javaw.exe" path by $R0

Function CheckJREVersion
    Push $R1

    ; Get the file version of javaw.exe
    ${GetFileVersion} $R0 $R1
    ${VersionCompare} ${JRE_VERSION} $R1 $R1

    ; Check whether $R1 != "1"
    ClearErrors
    StrCmp $R1 "1" 0 CheckDone
    SetErrors

  CheckDone:
    Pop $R1

FunctionEnd


; Attempt to give the UAC plug-in a user process and an admin process.

Function ElevateToAdmin
  UAC_Elevate:
    !insertmacro UAC_RunElevated
    StrCmp 1223 $0 UAC_ElevationAborted ; UAC dialog aborted by user?
    StrCmp 0 $0 0 UAC_Err ; Error?
    StrCmp 1 $1 0 UAC_Success ;Are we the real deal or just the wrapper?
    Quit

  UAC_ElevationAborted:
    # elevation was aborted, run as normal?
    MessageBox MB_ICONSTOP "This installer requires admin access, aborting!"
    Abort

  UAC_Err:
    MessageBox MB_ICONSTOP "Unable to elevate, error $0"
    Abort

  UAC_Success:
    StrCmp 1 $3 +4 ;Admin?
    StrCmp 3 $1 0 UAC_ElevationAborted ;Try again?
    MessageBox MB_ICONSTOP "This installer requires admin access, try again"
    goto UAC_Elevate
FunctionEnd


