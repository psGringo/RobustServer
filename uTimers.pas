unit uTimers;

interface

uses
  System.SysUtils, Vcl.ExtCtrls, DateUtils, System.Classes, IdBaseComponent, IdComponent, IdTCPConnection,
  IdTCPClient, IdHTTP, uPSClasses;

type
  TTimers = class(TDataModule)
    tWork: TTimer;
    tMemory: TTimer;
    procedure tWorkTimer(Sender: TObject);
    procedure tMemoryTimer(Sender: TObject);
    procedure DataModuleCreate(Sender: TObject);
  private
    FStartTime: TDateTime;
    FWorkTime: TDateTime;
    { Private declarations }
  public
    { Public declarations }
    property StartTime: TDateTime read FStartTime write FStartTime;
    property WorkTime: TDateTime read FWorkTime write FWorkTime;
  end;

implementation

uses
  uMain, Winapi.Windows, Winapi.Messages, uRPSystem, superobject, uCommon, uRSMainModule;

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

procedure TTimers.DataModuleCreate(Sender: TObject);
begin
  FStartTime := Now();
end;

procedure TTimers.tMemoryTimer(Sender: TObject);
var
  jo: ISuperObject;
  idHTTP: ISP<TiDHTTP>;
begin
  TThread.CreateAnonymousThread(
    procedure
    begin
      idHTTP := TSP<TiDHTTP>.Create();
      jo := SO[idHTTP.Get(TRSMainModule.GetInstance.Adress + '/System/Memory')];
      TThread.Synchronize(TThread.CurrentThread,
        procedure()
        begin
//          TRSMainModule.GetInstance.StatusBar.Panels[2].Text := jo.O['data'].s['memory'];
        end);
    end).Start;
end;

procedure TTimers.tWorkTimer(Sender: TObject);
begin
  TThread.CreateAnonymousThread(
    procedure
    begin
      TThread.Synchronize(TThread.CurrentThread,
        procedure()
        begin
          FWorkTime := (Now() - FStartTime);
//          TRSMainModule.GetInstance.StatusBar.Panels[1].Text := TimeToStr(FWorkTime);
        end);
    end).Start;
end;

end.

