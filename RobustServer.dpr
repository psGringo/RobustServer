program RobustServer;

uses
  Vcl.Forms,
  Vcl.SvcMgr,
  uMain in 'uMain.pas' {Main},
  uCommandGet in 'uCommandGet.pas',
  Vcl.Themes,
  Vcl.Styles,
  uRSTimers in 'uRSTimers.pas' {Timers: TDataModule},
  uRPMemory in 'RP\uRPMemory.pas',
  uRSCommon in 'uRSCommon.pas',
  uRPUsers in 'RP\uRPUsers.pas',
  uDecodePostRequest in 'uDecodePostRequest.pas',
  uUniqueName in 'uUniqueName.pas',
  uDB in 'uDB.pas' {DB: TDataModule},
  uClientExamples in 'uClientExamples.pas',
  uRSConst in 'uRSConst.pas',
  uRP in 'RP\uRP.pas',
  uRPTests in 'RP\uRPTests.pas',
  uRPFiles in 'RP\uRPFiles.pas',
  uRSService in 'uRSService.pas' {RobustService},
  Winapi.Windows {MainService: TDataModule},
  uRPSystem in 'RP\uRPSystem.pas',
  System.SysUtils,
  uRSMainModule in 'uRSMainModule.pas' {RSMainModule: TDataModule},
  uRPRegistrations in 'RP\uRPRegistrations.pas',
  uRSGui in 'uRSGui.pas' {RSGui: TFrame},
  uRSServers in 'uRSServers.pas';

{$R *.res}

begin
  if (ParamCount > 0) and (ParamStr(1) = 'exe') then
  begin
    Vcl.Forms.Application.Initialize;
    Vcl.Forms.Application.MainFormOnTaskbar := True;
    TStyleManager.TrySetStyle('Light');
    if (ParamCount > 1) and (ParamStr(2) = 'hideApp') then
      Vcl.Forms.Application.ShowMainForm := False;
    Vcl.Forms.Application.CreateForm(TMain, Main);
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

