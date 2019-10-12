unit uRPTests;

interface

uses
  System.SysUtils, System.Types, System.Classes, IdCustomHTTPServer, superobject, uCommon, uDB, uRP, IdContext, System.NetEncoding, uAttributes, System.JSON, SyncObjs, uConst, uRSMainModule;

type
  TRPTests = class(TRP)
  private
    procedure OnException(aObject: TObject; aClass, aMsg: string);
    procedure OnStartLongTask(aProgress: double; aMsg: string);
    procedure OnProgressLongTask(aProgress: double; aMsg: string);
    procedure OnFinishLongTask(aProgress: double; aMsg: string);
  public
    constructor Create(aContext: TIdContext; aRequestInfo: TIdHTTPRequestInfo; aResponseInfo: TIdHTTPResponseInfo); overload; override;
    procedure Connection;
    procedure Exceptions;
    [THTTPAttributes('HttpPost')]
    procedure PostJson;
    procedure SimplePostRequest(a, b: string);
    procedure URLEncoded(a, b: string);
    procedure Sessions;
    function PingContext: string;
    procedure MethodWithParams(aParam1: string; aParam2: string);
    [THTTPAttributes('HttpGet')]
    procedure HTTPAttribute(); overload;
    [THTTPAttributes('HttpPost')]
    procedure HTTPAttribute(aParam: string); overload;
    procedure LongTask();
    procedure GetLongTaskProgress(aGuid: string);
    procedure SharedResourceExample();
    procedure DBConnection();
  end;

implementation

uses
  idHTTP, IdMultipartFormData, uMain, Vcl.Dialogs;

{ TRPUsers }

constructor TRPTests.Create(aContext: TIdContext; aRequestInfo: TIdHTTPRequestInfo; aResponseInfo: TIdHTTPResponseInfo);
begin
  inherited;
  Execute(RP_Tests);
end;

procedure TRPTests.MethodWithParams(aParam1: string; aParam2: string);
var
  json: ISuperObject;
begin
  json := SO;
  json.S['param1'] := aParam1;
  json.S['param2'] := aParam2;
  FResponses.OkWithJson(json.AsJSon(false, false));
end;

procedure TRPTests.OnException(aObject: TObject; aClass, aMsg: string);
begin
// Notify exception here...
  with TRSMainModule.GetInstance.LongTaskThreads.LockList() do
  try
    TRSMainModule.GetInstance.LongTaskThreads.Remove(aObject);
//    TRSMainModule.GetInstance.mAnswer.Lines.Add(aClass + ' ' + aMsg);
  finally
    TRSMainModule.GetInstance.LongTaskThreads.UnlockList();
  end;
end;

procedure TRPTests.OnFinishLongTask(aProgress: double; aMsg: string);
begin
//  TRSMainModule.GetInstance.mAnswer.Lines.Add(aProgress.ToString() + aMsg);
end;

procedure TRPTests.OnProgressLongTask(aProgress: double; aMsg: string);
begin
//  TRSMainModule.GetInstance.mAnswer.Lines.Add(aProgress.ToString() + aMsg);
end;

procedure TRPTests.OnStartLongTask(aProgress: double; aMsg: string);
begin
  //TMain.GetInstance.mAnswer.Lines.Add(aProgress.ToString() + aMsg);
end;

procedure TRPTests.Exceptions;
begin
  raise Exception.Create('Test Error Message');
end;

procedure TRPTests.GetLongTaskProgress(aGuid: string);
var
  p: double;
  json: ISuperObject;
  i: integer;
begin
  p := 0.00;
  with TRSMainModule.GetInstance.LongTaskThreads.LockList() do
  try
    for i := 0 to Count - 1 do
      if TLongTaskThread(Items[i]).GuiId = aGuid then
      begin
        p := TLongTaskThread(Items[i]).Progress;
        break;
      end;
  finally
    TRSMainModule.GetInstance.LongTaskThreads.UnlockList();
  end;
  json := SO;
  json.D['progress'] := p;
  FResponses.OkWithJson(json.AsJSon(false, false));
end;

procedure TRPTests.HTTPAttribute(aParam: string);
var
  json: ISuperObject;
begin
  json := SO;
  json.S['commandType'] := 'POST';
  json.S['param'] := aParam;
  FResponses.OkWithJson(json.AsJSon(false, false));
end;

procedure TRPTests.HTTPAttribute;
var
  json: ISuperObject;
begin
  json := SO;
  json.S['commandType'] := 'GET';
  FResponses.OkWithJson(json.AsJSon(false, false));
end;

function TRPTests.PingContext: string;
begin
//
end;

procedure TRPTests.PostJson;
var
  jso: ISuperobject;
  jo: TJSONObject; // ISP<> doesn't work here 'cause jo always has reference and no nil after wrong parse of json
begin
  jo := TJSONObject.ParseJSONValue(FParams.Text) as TJSONObject;
  try
    if not (Assigned(jo)) then
      raise Exception.Create('not a json object');
    jso := SO[FParams.Text];
    FResponses.OkWithJson(jso.AsJSon(false, false));
  finally
    jo.Free();
  end;
end;

procedure TRPTests.Sessions;
var
  jo: ISuperObject;
//  LSessionList: TIdHTTPDefaultSessionList;  //TIdHTTPSessionList;
  LSessionList: TIdHTTPSessionList;
begin
  jo := SO;
  jo.S['sessionID'] := RequestInfo.Session.SessionID;
  jo.S['content'] := RequestInfo.Session.Content.Text;
  jo.S['remoteHost'] := RequestInfo.Session.RemoteHost;
  jo.S['lastTimeStamp'] := DateTimeToStr(RequestInfo.Session.LastTimeStamp);

//  LSessionList := TIdHTTPDefaultSessionList(Main.Server.SessionList).LockList;
  LSessionList := TIdHTTPDefaultSessionList(TRSMainModule.GetInstance.Server.SessionList).SessionList.LockList;
  jo.S['sessionCount'] := LSessionList.Count.ToString;
  TIdHTTPDefaultSessionList(TRSMainModule.GetInstance.Server.SessionList).SessionList.UnlockList;
  FResponses.OkWithJson(jo.AsJSon(false, false));
end;

procedure TRPTests.SharedResourceExample;
var
  json: ISuperObject;
  i: Integer;
begin
  TRSMainModule.GetInstance.CS.Enter();
  try
//    json := SO;
//    for i := 0 to TRSMainModule.GetInstance.SomeSharedResource.Count - 1 do
//      json.S['value_' + i.ToString] := TRSMainModule.GetInstance.SomeSharedResource.ValueFromIndex[i];
//    FResponses.OkWithJson(json.AsJSon(false, false));
  finally
    TRSMainModule.GetInstance.CS.Leave();
  end;
end;

procedure TRPTests.SimplePostRequest(a, b: string);
var
  test: string;
begin
  test := a;
  test := b;
  FResponses.OK();
end;

procedure TRPTests.DBConnection;
var
  json: ISuperObject;
begin
  DB.Connect();
  json := SO;
  json.B['connected'] := DB.FDConnection.Connected; // Db.FDConnection.Connected;
  FResponses.OkWithJson(json.AsJSon(false, false));
end;

procedure TRPTests.LongTask;
var
  jo: ISuperObject;
  t: TLongTaskThread;
begin
  t := TLongTaskThread.Create(
    procedure()
    var
      i: integer;
    begin
      if Assigned(t.OnStart) then
        (t.OnStart(0, 'ThreadStarted'));

      for i := 0 to 99 do
      begin
        sleep(1000);
        t.Progress := i;

        if TLongTaskThread(t).IsTerminated then
          break;

        if Assigned(t.OnProgress) then
          (t.OnProgress(i));

//        raise Exception.Create('Test Error Message'); // test Exception
            end;

      if Assigned(t.OnFinish) and not TLongTaskThread(t).IsTerminated then
        (t.OnFinish(i, ' ThreadFinished')); // thread finished
    end);

  // events
  t.OnStart := OnStartLongTask;
  t.OnProgress := OnProgressLongTask;
  t.OnFinish := OnFinishLongTask;
  t.OnException := OnException;

  TRSMainModule.GetInstance.LongTaskThreads.Add(t);
  t.Start();
  if Assigned(t.OnStart) then
    (t.OnStart); // thread started

  jo := SO();
  jo.S['threadGuid'] := t.GuiId;
  FResponses.OkWithJson(jo.AsJSon(false, false));
end;

procedure TRPTests.Connection;
begin
  FResponses.OK();
end;

procedure TRPTests.URLEncoded(a, b: string);
var
  jo: ISuperObject;
begin
  jo := SO;
  jo.S[FParams.Names[0]] := a;
  jo.S[FParams.Names[1]] := b;
  FResponses.OkWithJson(jo.AsJSon(false, false));
end;

end.

