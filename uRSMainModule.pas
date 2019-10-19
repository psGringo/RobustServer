unit uRSMainModule;

interface

uses
  System.SysUtils, System.Classes, SyncObjs, IdContext, IdCustomHTTPServer, System.ImageList, Vcl.ImgList, Vcl.Controls, IdCustomTCPServer, IdHTTPServer, IdBaseComponent,
  IdComponent, IdServerIOHandler, IdSSL, IdSSLOpenSSL, uRSService, System.IOUtils, LDSLogger, IniFiles, uRSConst, VCL.Forms, uRSCommon, uPSClasses, uRSTimers;

type
  THttpProtocolSettings = class
  private
    FProtocol: string;
    FHost: string;
    FPort: integer;
    FAdress: string;
    FFilePathSettings: string;
    function HttpProtocolToString(aHttpProtocol: THttpProtocol): string;
    procedure ReadSettingsFromFile();
    procedure WriteDefaultSettingsToFile();
    procedure WriteSettingsToFile();
  public
    constructor Create(aFilePathSettings: string; aIsCreatedNewSettingsFile: Boolean; aProtocol: THttpProtocol; aPort: integer);
    property Port: integer read FPort;
    property Adress: string read FAdress;
  end;

  TSettingsFile = class
  private
    FHttpProtocolSettings: ISP<THttpProtocolSettings>;
    FWasCreatedNewFile: Boolean;
    FServer: TIdHTTPServer;
  public
    constructor Create(aSettingsFilePath: string; aServer: TIdHTTPServer; aProtocol: THttpProtocol; aPort: integer);
    property HttpProtocol: ISP<THttpProtocolSettings> read FHttpProtocolSettings;
    function GetAdress(): string;
  end;

  TLastHttpRequests = class
  private
    FMaxCountRequests: integer;
    FData: TStringList;
    FFilePath: string;
    procedure KeepNoMoreCountRecords(aCount: integer);
    procedure Load();
    procedure Save();
    function FindIndexOfKeyInIniSection(aSection: string; aKey: string): integer;
  public
    constructor Create(aFilePathSettings: string);
    destructor Destroy; override;
    procedure AddToFirstPosition(aRequest: string);
    procedure Delete(aRequest: string);
    property Data: TStringList read FData;
  end;

  TRSMainModule = class(TDataModule)
    IdServerIOHandlerSSLOpenSSL: TIdServerIOHandlerSSLOpenSSL;
    Server: TIdHTTPServer;
    ilPics: TImageList;
    procedure ServerCommandGet(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
  private
    FTimers: TTimers;
    FSettingsFile: ISP<TSettingsFile>;
    FLastHttpRequests: ISP<TLastHttpRequests>;
    FAdress: string;
    FLongTaskThreads: ISP<TThreadList>;
    FCS: ISP<TCriticalSection>;
    FOnStart: TNotifyEvent;
    FOnStop: TNotifyEvent;
    FRSGui: TObject;
    FName: string;
    function GetAdress(): string;
    procedure PostRequestProcessing();
    procedure SetRSGui(const Value: TObject);
  public
    constructor Create(aOwner: TComponent; aIsStartOnCreate: Boolean = true; aProtocol: THttpProtocol = hpHTTP; aPort: integer = DEFAULT_HTTP_PORT);
    destructor Destroy; override;
    procedure ToggleStartStop();
    procedure Start;
    procedure Stop;
    class function GetInstance(): TRSMainModule;
    property Timers: TTimers read FTimers write FTimers;
    property Adress: string read GetAdress;
    property LongTaskThreads: ISP<TThreadList> read FLongTaskThreads;
    property LastHttpRequests: ISP<TLastHttpRequests> read FLastHttpRequests;
    property CS: ISP<TCriticalSection> read FCS write FCS;
    property OnStart: TNotifyEvent read FOnStart;
    property OnStop: TNotifyEvent read FOnStop;
    property RSGui: TObject read FRSGui write SetRSGui;
  end;

var
  RSMainModule: TRSMainModule;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

uses
  uCommandGet, uRSGui;

{ TRSMainModule }

constructor TRSMainModule.Create(aOwner: TComponent; aIsStartOnCreate: Boolean = true; aProtocol: THttpProtocol = hpHTTP; aPort: integer = DEFAULT_HTTP_PORT);
var
  filePathSettings: string;
  guid: TGuid;
begin
  inherited Create(aOwner);

  filePathSettings := ExtractFilePath(Application.ExeName) + SETTINGS_FILE_NAME;

  FSettingsFile := TSP<TSettingsFile>.Create(TSettingsFile.Create(filePathSettings, Server, aProtocol, aPort));
  FLastHttpRequests := TSP<TLastHttpRequests>.Create(TLastHttpRequests.Create(filePathSettings));
  FTimers := TTimers.Create(Self, true);
  FLongTaskThreads := TSP<TThreadList>.Create();
  FCS := TSP<TCriticalSection>.Create();

  RSMainModule := Self;

  if aIsStartOnCreate then
    Start();
end;

destructor TRSMainModule.Destroy;
begin
  Stop();
  inherited;
end;

function TRSMainModule.GetAdress: string;
begin
  Result := FSettingsFile.GetAdress();
end;

class function TRSMainModule.GetInstance: TRSMainModule;
begin
  if Assigned(RobustService) then
    Result := TRSMainModule(RobustService.MainInstance)
  else
    Result := RSMainModule;
end;

procedure TRSMainModule.PostRequestProcessing;
begin

end;

procedure TRSMainModule.ServerCommandGet(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  cg: ISP<TCommandGet>;
begin
  cg := TSP<TCommandGet>.Create(TCommandGet.Create(AContext, ARequestInfo, AResponseInfo, FCs));
end;

procedure TRSMainModule.SetRSGui(const Value: TObject);
begin
  if Value.ClassType <> TRSGui then
    raise Exception.Create('Value is not a TRSGui');

  FRSGui := Value;
end;

procedure TRSMainModule.Start;
var
  l: ISP<TLogger>;
begin
  if Server.Active then
    Exit;

  l := TSP<TLogger>.Create();
  Server.Active := true;
  l.LogInfo('Server successfully started');

  FTimers.StartAllTimers();

  if Assigned(FOnStart) then
    FOnStart(Self)
end;

procedure TRSMainModule.Stop;
var
  l: ISP<TLogger>;
  i: integer;
begin
  if not Server.Active then
    Exit;

  l := TSP<TLogger>.Create();
  Server.Active := false;

  FTimers.StopAllTimers();

  l.LogInfo('Server successfully stopped');
  with LongTaskThreads.LockList() do
  try
    for i := 0 to Count - 1 do
    begin
      TLongTaskThread(Items[i]).FreeOnTerminate := false; // in other case they will be destroyed automatically
      TLongTaskThread(Items[i]).Terminate;
    end;
  finally
    LongTaskThreads.UnlockList();
  end;

  if Assigned(FOnStart) then
    FOnStart(Self)
end;

procedure TRSMainModule.ToggleStartStop;
begin
  if not Server.Active then
    Start
  else
    Stop();
end;

{ FHttpProtocolSettings }

function THttpProtocolSettings.HttpProtocolToString(aHttpProtocol: THttpProtocol): string;
begin
  if aHttpProtocol = hpHTTP then
    Result := 'http'
  else if aHttpProtocol = hpHTTPs then
    Result := 'https'
  else


end;

procedure THttpProtocolSettings.ReadSettingsFromFile();
var
  ini: ISP<TIniFile>;
begin
  ini := TSP<Tinifile>.Create(Tinifile.Create(FFIlePathSettings));
  FProtocol := ini.ReadString('server', 'protocol', '<None>');
  FHost := ini.ReadString('server', 'host', '<None>');
  FPort := ini.ReadString('server', 'port', '<None>').ToInteger();
end;

procedure THttpProtocolSettings.WriteDefaultSettingsToFile();
var
  ini: ISP<TIniFile>;
begin
  ini := TSP<Tinifile>.Create(Tinifile.Create(FFIlePathSettings));
  ini.WriteString('server', 'protocol', DEFAULT_HTTP_PROTOCOL);
  ini.WriteString('server', 'host', DEFAULT_HTTP_HOST);
  ini.WriteString('server', 'port', DEFAULT_HTTP_PORT.ToString());
end;

procedure THttpProtocolSettings.WriteSettingsToFile;
var
  ini: ISP<TIniFile>;
begin
  ini := TSP<Tinifile>.Create(Tinifile.Create(FFIlePathSettings));
  ini.WriteString('server', 'protocol', FProtocol);
  ini.WriteString('server', 'host', DEFAULT_HTTP_HOST);
  ini.WriteString('server', 'port', FPort.ToString());
end;

{ THttpProtocolSettings }

constructor THttpProtocolSettings.Create(aFilePathSettings: string; aIsCreatedNewSettingsFile: Boolean; aProtocol: THttpProtocol; aPort: integer);
begin
  FFIlePathSettings := aFilePathSettings;

  FProtocol := HttpProtocolToString(aProtocol);
  FPort := aPort;

  if aIsCreatedNewSettingsFile then
  begin
    if (FProtocol <> '') and (FPort <> -1) then
      WriteSettingsToFile()
    else
      WriteDefaultSettingsToFile()
  end;

  ReadSettingsFromFile();

  FAdress := Format('%s://%s:%s', [FProtocol, FHost, FPort.ToString()]);
end;

{ TLastHttpRequests }

procedure TLastHttpRequests.AddToFirstPosition(aRequest: string);
var
  currentIndex: integer;
  isRequestFound: Boolean;
begin
  KeepNoMoreCountRecords(FMaxCountRequests);
  aRequest := Trim(aRequest);

  currentIndex := FData.IndexOf(aRequest);
  isRequestFound := currentIndex <> -1;

  if (isRequestFound) then
    FData.Exchange(currentIndex, 0)
  else
    FData.Insert(0, aRequest);
end;

constructor TLastHttpRequests.Create(aFilePathSettings: string);
begin
  FMaxCountRequests := 10;

  if not TFile.Exists(aFilePathSettings) then
    raise Exception.Create(Format('no file %s', [aFilePathSettings]));

  FFilePath := aFilePathSettings;

  FData := TStringList.Create();
  Load();

  if FData.Count = 0 then
    FData.Add('Tests/Connection')
end;

procedure TLastHttpRequests.Delete(aRequest: string);
var
  currentIndex: integer;
  ini: ISP<TIniFile>;
  sectionName: string;
begin
  currentIndex := FData.IndexOf(aRequest);
  if currentIndex = -1 then
    Exit;

  FData.Delete(currentIndex);

  // delete from ini
  ini := TSP<Tinifile>.Create(Tinifile.Create(FFilePath));
  sectionName := Format('lastRequest%s', [currentIndex.ToString()]);
  ini.DeleteKey('lastRequests', sectionName);
end;

destructor TLastHttpRequests.Destroy;
begin
  Save();
  FData.Free();
  inherited;
end;

function TLastHttpRequests.FindIndexOfKeyInIniSection(aSection, aKey: string): integer;
var
  count: integer;
  ini: ISP<TIniFile>;
  i: Integer;
  itemResult: string;
begin
  Result := -1;

  ini := TSP<Tinifile>.Create(Tinifile.Create(FFilePath));
  count := ini.ReadInteger('lastRequests', 'count', 0);
  for i := 0 to count - 1 do
  begin
    itemResult := ini.ReadString(aSection, aKey, 'not found');
    if itemResult = aKey then
    begin
      Result := i;
      Exit;
    end;
  end;
end;

procedure TLastHttpRequests.KeepNoMoreCountRecords(aCount: integer);
var
  diff: integer;
  i: integer;
begin
  diff := FData.Count - aCount;
  if diff > 0 then
  begin
    for i := aCount to FData.Count - 1 do
      FData.Delete(i);
  end;
end;

procedure TLastHttpRequests.Load();
var
  ini: ISP<TIniFile>;
  count: integer;
  i: integer;
  sectionName: string;
  item: string;
  notFound: string;
begin
  ini := TSP<Tinifile>.Create(Tinifile.Create(FFilePath));

  i := 0;
  notFound := 'not found';

  while item <> notFound do
  begin
    sectionName := Format('lastRequest%s', [i.ToString()]);
    item := ini.ReadString('lastRequests', sectionName, notFound);
    if item <> notFound then
      FData.Add(item);
    Inc(i);
  end;
end;

procedure TLastHttpRequests.Save;
var
  ini: ISP<TIniFile>;
  i: integer;
  sectionName: string;
begin
  KeepNoMoreCountRecords(FMaxCountRequests);

  ini := TSP<Tinifile>.Create(Tinifile.Create(FFilePath));

  for i := 0 to FData.Count - 1 do
  begin
    sectionName := Format('lastRequest%s', [i.ToString()]);
    ini.WriteString('lastRequests', sectionName, FData[i]);
  end;
end;

{ TSettingsFile }

constructor TSettingsFile.Create(aSettingsFilePath: string; aServer: TIdHTTPServer; aProtocol: THttpProtocol; aPort: integer);
var
  validator: ISP<TParamValidator>;
begin
  FWasCreatedNewFile := false;
  validator := TSP<TParamValidator>.Create();
  validator.EnsureNotNull(aServer);

  if not TFile.Exists(aSettingsFilePath) then
  begin
    FWasCreatedNewFile := true;
    TFile.Create(aSettingsFilePath);
  end;

  FHttpProtocolSettings := TSP<THttpProtocolSettings>.Create(THttpProtocolSettings.Create(aSettingsFilePath, FWasCreatedNewFile, aProtocol, aPort));
  aServer.DefaultPort := FHttpProtocolSettings.Port;
end;

function TSettingsFile.GetAdress: string;
begin
  Result := FHttpProtocolSettings.Adress;
end;

end.

