program RobustServer;

uses
  Vcl.Forms,
  Vcl.SvcMgr,
  uMain in 'uMain.pas' {Main},
  uCommandGet in 'uCommandGet.pas',
  Vcl.Themes,
  Vcl.Styles,
  uTimers in 'uTimers.pas' {Timers: TDataModule},
  uRPMemory in 'RP\uRPMemory.pas',
  uCommon in 'uCommon.pas',
  uRPUsers in 'RP\uRPUsers.pas',
  uDecodePostRequest in 'uDecodePostRequest.pas',
  uUniqueName in 'uUniqueName.pas',
  uDB in 'uDB.pas' {DB: TDataModule},
  uClientExamples in 'uClientExamples.pas',
  uConst in 'uConst.pas',
  uRP in 'RP\uRP.pas',
  uRPTests in 'RP\uRPTests.pas',
  uRPFiles in 'RP\uRPFiles.pas',
  uRSService in 'uRSService.pas' {RobustService},
  Winapi.Windows {MainService: TDataModule},
  uRPSystem in 'RP\uRPSystem.pas',
  System.SysUtils,
  uRSMainModule in 'uRSMainModule.pas' {RSMainModule: TDataModule};

{$R *.res}

//Creates a mutex to see if the program is already running.
function IsSingleInstance(MutexName: string; KeepMutex: boolean = true): boolean;
const
  MUTEX_GLOBAL = 'Global\'; //Prefix to explicitly create the object in the global or session namespace. I.e. both client app (local user) and service (system account)
var
  MutexHandle: THandle;
  SecurityDesc: TSecurityDescriptor;
  SecurityAttr: TSecurityAttributes;
  ErrCode: integer;
begin
    // By default (lpMutexAttributes =nil) created mutexes are accessible only by
    // the user running the process. We need our mutexes to be accessible to all
    // users, so that the mutex detection can work across user sessions.
    // I.e. both the current user account and the System (Service) account.
    // To do this we use a security descriptor with a null DACL.
  InitializeSecurityDescriptor(@SecurityDesc, SECURITY_DESCRIPTOR_REVISION);
  SetSecurityDescriptorDacl(@SecurityDesc, True, nil, False);
  SecurityAttr.nLength := SizeOf(SecurityAttr);
  SecurityAttr.lpSecurityDescriptor := @SecurityDesc;
  SecurityAttr.bInheritHandle := False;

    // The mutex is created in the global name space which makes it possible to
    // access across user sessions.

  MutexHandle := CreateMutex(@SecurityAttr, True, PChar(MUTEX_GLOBAL + MutexName));
  ErrCode := GetLastError;
    // If the function fails, the return value is 0
    // If the mutex is a named mutex and the object existed before this function
    // call, the return value is a handle to the existing object, GetLastError
    // returns ERROR_ALREADY_EXISTS.
  if (MutexHandle = 0) or (ErrCode = ERROR_ALREADY_EXISTS) then
  begin
    result := false;
    closeHandle(MutexHandle);
  end
  else
  begin
    // Mutex object has not yet been created, meaning that no previous
    // instance has been created.
    result := true;

    if not KeepMutex then
      CloseHandle(MutexHandle);
  end;
    // The Mutexhandle is not closed because we want it to exist during the
    // lifetime of the application. The system closes the handle automatically
    //when the process terminates.
end;

begin
  if not IsSingleInstance('RobustServer', true) then
    raise Exception.Create('RobustServer уже запущен');

  if (ParamCount > 0) and (ParamStr(1) = 'exe') then
  begin
    Vcl.Forms.Application.Initialize;
    Vcl.Forms.Application.MainFormOnTaskbar := True;
    TStyleManager.TrySetStyle('Charcoal Dark Slate');
    Vcl.Forms.Application.CreateForm(TMain, Main);
  Application.CreateForm(TRSMainModule, RSMainModule);
  Vcl.Forms.Application.Run;
  end
  else
  begin // service
    if not Vcl.SvcMgr.Application.DelayInitialize or Vcl.SvcMgr.Application.Installing then
      Vcl.SvcMgr.Application.Initialize;
    Vcl.SvcMgr.Application.CreateForm(TRobustService, RobustService);
    Application.Run;
  end;

end.

