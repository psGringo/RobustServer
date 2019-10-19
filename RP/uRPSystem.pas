unit uRPSystem;

interface

uses
  uRP, System.SysUtils, System.Classes, IdCustomHTTPServer, superobject, uRSCommon, uDB, IdContext, System.NetEncoding, uAttributes, System.JSON, TypInfo, System.Rtti, System.IOUtils,
  Winapi.PsAPI, Winapi.Windows, Math, IdHeaderList, uRSService, uRSMainModule, uPSClasses;

type
  TRPSystem = class(TRP)
  protected
    function CurrentProcessMemoryKB: Extended;
    function CurrentProcessMemoryPeakKB: Extended;
  private
    function CloseAllConnections(): boolean;
    procedure ServerHeadersAvailable(AContext: TIdContext; const AUri: string; AHeaders: TIdHeaderList; var VContinueProcessing: Boolean);
    procedure ServerHeadersBlocked(AContext: TIdContext; AHeaders: TIdHeaderList; var VResponseNo: Integer; var VResponseText, VContentText: string);
    procedure CreateAPIFromClass(aClass: TClass; aApi: TStringList);
  public
    constructor Create(aContext: TIdContext; aRequestInfo: TIdHTTPRequestInfo; aResponseInfo: TIdHTTPResponseInfo); overload; override;
    procedure Memory();
    procedure WorkTime();
    procedure Offline();
    procedure Online();
    procedure Connections();
    procedure DBConnections();
    procedure Deactivate();
    procedure Log();
    procedure Api();
    procedure PingContext(aId: string);
  end;

implementation

uses
  IdThreadSafe, Vcl.Forms, uRPTests, uRPFiles, uRPMemory, uRPUsers;

{ TRPApi }

procedure TRPSystem.Api;
var
  fileName: string;
  api: ISP<TStringList>;
  filepath: string;
begin
  fileName := 'api.txt';

  if TFile.Exists(fileName) then
    TFile.Delete(fileName);

  api := TSP<TStringList>.Create();

  CreateAPIFromClass(TRPSystem, api);
  CreateAPIFromClass(TRPTests, api);
  CreateAPIFromClass(TRPFiles, api);
  CreateAPIFromClass(TRPMemory, api);
  CreateAPIFromClass(TRPUsers, api);
  // add other classes that descendants from TRP or just API classes
  // CreateAPIFromClass(TRPOtherClass, api);

  api.SaveToFile(fileName);

  filepath := ExtractFileDir(Application.ExeName) + '\' + fileName;
  if TFile.Exists(filepath) then
  begin
    ResponseInfo.SmartServeFile(Context, RequestInfo, filepath);
    FResponses.OK();
  end;
end;

function TRPSystem.CloseAllConnections: boolean;
var
  i: Integer;
  l: TList;
  c: TIdThreadSafeObjectList;
begin
  Result := false;

  c := TRSMainModule.GetInstance.Server.Contexts;
  if c = nil then
    Exit();

  l := c.LockList();
  try
    for i := 0 to l.Count - 1 do
      TIdContext(l.Items[i]).Connection.Disconnect(False);
    Result := true;
  finally
    c.UnlockList;
  end;
end;

procedure TRPSystem.Connections;
var
  jo: ISuperObject;
begin
  with TRSMainModule.GetInstance.Server.Contexts.LockList() do
  try
    jo := SO;
    jo.I['connections'] := TRSMainModule.GetInstance.Server.Contexts.Count;
    FResponses.OkWithJson(jo.AsJSon(false, false));
  finally
    TRSMainModule.GetInstance.Server.Contexts.UnlockList();
  end;
end;

constructor TRPSystem.Create(aContext: TIdContext; aRequestInfo: TIdHTTPRequestInfo; aResponseInfo: TIdHTTPResponseInfo);
begin
  inherited;
  Execute('System');
end;

function TRPSystem.CurrentProcessMemoryKB: Extended;
var
  MemCounters: TProcessMemoryCounters;
begin
  Result := 0;
  MemCounters.cb := SizeOf(MemCounters);
  if GetProcessMemoryInfo(GetCurrentProcess, @MemCounters, SizeOf(MemCounters)) then
    Result := trunc(MemCounters.WorkingSetSize / 1024)
  else
    RaiseLastOSError;
end;

function TRPSystem.CurrentProcessMemoryPeakKB: Extended;
var
  MemCounters: TProcessMemoryCounters;
begin
  Result := 0;
  MemCounters.cb := SizeOf(MemCounters);
  if GetProcessMemoryInfo(GetCurrentProcess, @MemCounters, SizeOf(MemCounters)) then
    Result := trunc(MemCounters.PeakWorkingSetSize / 1024)
  else
    RaiseLastOSError;
end;

procedure TRPSystem.DBConnections;
var
  json: IsuperObject;
begin
  DB.Connect();
  with DB.Q do
  begin
    SQL.Text := 'SHOW STATUS WHERE `variable_name` = ''Threads_connected''';
    Disconnect();
    Open();
    json := SO;
    json.I['DbConnections'] := FieldByName('Value').AsInteger; // TMain.GetInstance.DBConnectionsCount;
    FResponses.OkWithJson(json.AsJSon(false, false));
    Close();
  end;
end;

procedure TRPSystem.Deactivate;
begin
  CloseAllConnections();
  TRSMainModule.GetInstance.Server.Active := false;
end;

procedure TRPSystem.Log;
var
  fileName: string;
  filepath: string;
begin
  fileName := 'log.txt';
  filepath := ExtractFileDir(Application.ExeName) + '\' + fileName;
  if TFile.Exists(filepath) then
  begin
    ResponseInfo.SmartServeFile(Context, RequestInfo, filepath);
    FResponses.OK();
  end;
end;

procedure TRPSystem.Memory();

  function GetMemory(aMemory: Extended): string;
  begin
    if aMemory <= 1024 then
      Result := aMemory.ToString() + ' Kb'
    else if (aMemory > 1024) and (aMemory < (1024 * 1024)) then
      Result := Math.RoundTo(aMemory / 1024, -2).ToString() + ' Mb'
    else if (aMemory >= 1024 * 1024) then
      Result := Math.RoundTo(aMemory / (1024 * 1024), -2).ToString() + ' Gb';
  end;

var
  json: ISuperobject;
begin
  json := SO;
  json.S['memory'] := GetMemory(CurrentProcessMemoryKB) + ' / ' + GetMemory(CurrentProcessMemoryPeakKB);
  FResponses.OkWithJson(json.AsJSon(false, false));
end;

procedure TRPSystem.Online();
begin
  TRSMainModule.GetInstance.Server.OnHeadersAvailable := nil;
  TRSMainModule.GetInstance.Server.OnHeadersBlocked := nil;
  FResponses.OK();
end;

procedure TRPSystem.PingContext(aId: string);
var
  jo: ISuperObject;
  i: integer;
  r: boolean;
  someProgress: string;
begin
  r := false;
  with TRSMainModule.GetInstance.Server.Contexts.LockList() do
  try
    for i := 0 to Count - 1 do
      if TIdContext(Items[i]).Binding.ID = aId.ToInteger then
      begin
        someProgress := '10 %';  // take progress param and give it in answer
        r := true;
        Break;
      end;
  finally
    TRSMainModule.GetInstance.Server.Contexts.UnlockList();
  end;
  if r then
  begin
    jo := SO;
    jo.S['progress'] := someProgress;
    FResponses.OkWithJson(jo.AsJSon(false, false));
  end;
end;

procedure TRPSystem.Offline();
begin
  TRSMainModule.GetInstance.Server.OnHeadersAvailable := ServerHeadersAvailable;
  TRSMainModule.GetInstance.Server.OnHeadersBlocked := ServerHeadersBlocked;
  FResponses.OK();
end;

procedure TRPSystem.WorkTime;
var
  json: ISuperobject;
begin
  json := SO;
  json.S['workTime'] := TimeToStr(TRSMainModule.GetInstance.Timers.WorkTime);
  FResponses.OkWithJson(json.AsJSon(false, false));
end;

procedure TRPSystem.ServerHeadersAvailable(AContext: TIdContext; const AUri: string; AHeaders: TIdHeaderList; var VContinueProcessing: Boolean);
begin
  if not AUri.contains('System') then
  begin
    VContinueProcessing := false;
  end;
end;

procedure TRPSystem.ServerHeadersBlocked(AContext: TIdContext; AHeaders: TIdHeaderList; var VResponseNo: Integer; var VResponseText, VContentText: string);
begin
  VResponseNo := 503;
  VResponseText := 'Service Unavailable';
end;

procedure TRPSystem.CreateAPIFromClass(aClass: TClass; aApi: TStringList);
{
  procedure getAPIClasses(aClasses: TList<TClass>);
  var
    ctx: TRttiContext;
    types: TArray<System.Rtti.TRttiType>;
    oneOfTypes: System.Rtti.TRttiType;
  begin
    ctx := TRttiContext.Create();
    types := ctx.GetTypes();
    for oneOfTypes in types do
      if (oneOfTypes.Name.contains('TRP')) and (oneOfTypes.Name <> 'TRP') then
        aClasses.Add(oneOfTypes.ClassType.ClassInfo);
  end;
}
var
  ctx: TRttiContext;
  t: TRttiType;
  m: TRttiMethod;
  j: integer;
  methodParams: TArray<System.Rtti.TRttiParameter>;
  attribs: TArray<TCustomAttribute>;
  a: TCustomAttribute;
  methodName: string;
begin
  aApi.Add('');
  aApi.Add('---');
  aApi.Add('');

  aApi.Add(aClass.ClassName);
  aApi.Add('');
  aApi.Add('---');
  ctx := TRttiContext.Create;
  try
    t := ctx.GetType(aClass);
    begin
      for m in t.GetMethods do
      begin
        if (m.Visibility = mvPublic) //
          and (m.MethodKind <> mkConstructor) //
          and (m.MethodKind <> mkDestructor) //
          and ((m.MethodKind = mkFunction) or (m.MethodKind = mkProcedure)) and (m.Name <> 'CPP_ABI_3') //
          and (m.Name <> 'CPP_ABI_2') and (m.Name <> 'CPP_ABI_1') //
          and (m.Name <> 'FreeInstance') //
          and (m.Name <> 'DefaultHandler') //
          and (m.Name <> 'Dispatch') //
          and (m.Name <> 'BeforeDestruction') //
          and (m.Name <> 'AfterConstruction') //
          and (m.Name <> 'SafeCallException') //
          and (m.Name <> 'ToString') //
          and (m.Name <> 'GetHashCode') //
          and (m.Name <> 'GetInterface') //
          and (m.Name <> 'FieldAddress') //
          and (m.Name <> 'ClassType') //
          and (m.Name <> 'CleanupInstance') //
          and (m.Name <> 'DisposeOf') //
          and (m.Name <> 'Connection') //
          and (m.Name <> 'CreateAPI') //
          and (m.Name <> 'Execute') //
          and (m.Name <> 'Equals') //
          and (m.Name <> 'Free') //
          then
        begin
          methodName := m.Name;
          attribs := m.GetAttributes;
          if Length(attribs) > 0 then
          begin
            for a in m.GetAttributes() do
            begin
              // if attribs HttpGet or HttpPost
              if (THTTPAttributes(a).CommandType = 'HttpGet') or (THTTPAttributes(a).CommandType = 'HttpPost') then
              begin
                if (THTTPAttributes(a).CommandType = 'HttpGet') then
                  methodName := '  ' + methodName + ' | GET'
                else if (THTTPAttributes(a).CommandType = 'HttpPost') then
                  methodName := '  ' + methodName + ' | POST'
              end;
            end;
          end
          else
            methodName := '  ' + methodName + ' | GET';

          aApi.Add(methodName);

          methodParams := m.GetParameters();
          if (Length(methodParams) > 0) then
          begin
            for j := 0 to high(methodParams) do
              aApi.Add('    ' + methodParams[j].ToString);
          end;
          aApi.Add('');
        end;
      end;
    end;
  finally
    ctx.Free;
  end;
end;

end.

