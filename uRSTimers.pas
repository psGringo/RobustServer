unit uRSTimers;

interface

uses
  System.SysUtils, Vcl.ExtCtrls, DateUtils, System.Classes, IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP, uPSClasses;

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
    FRSGui: TObject;
    procedure SetRSGui(const Value: TObject);
    { Private declarations }
  public
    constructor Create(aOwner: TComponent; aIsStartAllTimers: Boolean);
    procedure StopAllTimers();
    procedure StartAllTimers();
    property StartTime: TDateTime read FStartTime write FStartTime;
    property WorkTime: TDateTime read FWorkTime write FWorkTime;
    property RSGui: TObject read FRSGui write SetRSGui;
  end;

implementation

uses
  Winapi.Windows, Winapi.Messages, uRPSystem, superobject, uRSCommon, uRSMainModule, uRSGui;

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

constructor TTimers.Create(aOwner: TComponent; aIsStartAllTimers: Boolean);
begin
  inherited Create(aOwner);
  if aIsStartAllTimers then
    StartAllTimers()
  else
    StopAllTimers();
end;

procedure TTimers.DataModuleCreate(Sender: TObject);
begin
  FStartTime := Now();
end;

procedure TTimers.SetRSGui(const Value: TObject);
begin
  if Value.ClassType <> TRSGui then
    raise Exception.Create('Value is not a TRSGui');

  FRSGui := Value;
end;

procedure TTimers.StartAllTimers;
begin
  tWork.Enabled := true;
  tMemory.Enabled := true;
end;

procedure TTimers.StopAllTimers;
begin
  tWork.Enabled := false;
  tMemory.Enabled := false;
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
          if Assigned(FRSGui) then
            TRSGui(FRSGui).StatusBar.Panels[2].Text := jo.O['data'].s['memory'];
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
          if Assigned(FRSGui) then
            TRSGui(FRSGui).StatusBar.Panels[1].Text := TimeToStr(FWorkTime);
        end);
    end).Start;
end;

end.

