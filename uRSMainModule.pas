unit uRSMainModule;

interface

uses
  System.SysUtils, System.Classes, SyncObjs, IdContext, IdCustomHTTPServer, System.ImageList, Vcl.ImgList, Vcl.Controls, IdCustomTCPServer, IdHTTPServer, IdBaseComponent,
  IdComponent, IdServerIOHandler, IdSSL, IdSSLOpenSSL, uRSService, System.IOUtils, LDSLogger, IniFiles, uConst, VCL.Forms,
  //
  uPSClasses, //
  uRSTimers;

type
  THttpProtocolSettings = class
  private
    FProtocol: string;
    FHost: string;
    FPort: integer;
    FAdress: string;
    FFilePathSettings: string;
    procedure ReadSettingsFromFile();
    procedure WriteDefaultSettingsToFile();
  public
    constructor Create(aFilePathSettings: string; aIsCreatedNewSettingsFile: Boolean);
    property Port: integer read FPort;
    property Adress: string read FAdress;
  end;

  TSettingsFile = class
  private
    FHttpProtocol: ISP<THttpProtocolSettings>;
    FWasCreatedNewFile: Boolean;
    FServer: TIdHTTPServer;
  public
    constructor Create(aSettingsFilePath: string; aServer: TIdHTTPServer);
    property HttpProtocol: ISP<THttpProtocolSettings> read FHttpProtocol;
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
  public
    constructor Create(aFilePathSettings: string);
    destructor Destroy; override;
    procedure AddToFirstPosition(aRequest: string);
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
    function GetAdress(): string;
    procedure PostRequestProcessing();
    procedure SetRSGui(const Value: TObject);
  public
    constructor Create(aOwner: TComponent; aIsStartOnCreate: Boolean);
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
  uCommon, uCommandGet, uRSGui;

{ TRSMainModule }

constructor TRSMainModule.Create(aOwner: TComponent; aIsStartOnCreate: Boolean);
var
  filePathSettings: string;
begin
  inherited Create(aOwner);

  filePathSettings := ExtractFilePath(Application.ExeName) + SETTINGS_FILE_NAME;

  FSettingsFile := TSP<TSettingsFile>.Create(TSettingsFile.Create(filePathSettings, Server));
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
//  case cbPostType.ItemIndex of
//    0:
//      begin
//        TTHread.CreateAnonymousThread(
//          procedure()
//          var
//            r: string;
//            client: ISP<TIdHTTP>;
//            ss: ISP<TStringStream>;
//            jo: ISuperobject;
//          begin
//            client := TSP<TIdHTTP>.Create();
//            jo := SO(Trim(mPostParams.Lines.Text));
//            ss := TSP<TStringStream>.Create();
//            ss.WriteString(jo.AsJSon(false, false));
//            client.Request.ContentType := 'application/json';
//            client.Request.ContentEncoding := 'utf-8';
//            r := client.Post(FAdress + '/' + cbRequest.Text, ss);
//            TThread.Synchronize(TThread.CurrentThread,
//              procedure()
//              begin
//                mAnswer.Lines.Add(r);
//                SaveRequest();
//              end);
//          end).Start();
//      end;
//    1:
//      TTHread.CreateAnonymousThread(
//        procedure()
//        var
//          r: string;
//          client: ISP<TIdHTTP>;
//          paramsSL: ISP<TStringList>;
//        begin
//          client := TSP<TIdHTTP>.Create();
//           //for test Send with 2 params on  Test/URLEncoded
//          paramsSL := TSP<TStringList>.Create();
//          paramsSL.Assign(mPostParams.Lines);
//            { or in code you can add params...
//             paramsSL.Add('a=UrlEncoded(aValue)')
//             paramsSL.Add('b=UrlEncoded(bValue)')
//            }
//          client.Request.ContentType := 'application/x-www-form-urlencoded';
//          client.Request.ContentEncoding := 'utf-8';
//
//          r := client.Post(FAdress + '/' + cbRequest.Text, paramsSL);
//
//          TThread.Synchronize(TThread.CurrentThread,
//            procedure()
//            begin
//              mAnswer.Lines.Add(r);
//              SaveRequest();
//            end);
//        end).Start();
//    2:
//      TTHread.CreateAnonymousThread(
//        procedure()
//        var
//          client: ISP<TIdHTTP>;
//          ss: ISP<TStringStream>;
//          fileName: string;
//          postData: ISP<TIdMultiPartFormDataStream>;
//        begin
//          ss := TSP<TStringStream>.Create();
//          client := TSP<TIdHTTP>.Create();
//            // multipart...
//          fileName := ExtractFileName(mPostParams.Lines[0]);
//          postData := TSP<TIdMultiPartFormDataStream>.Create();
//          client.Request.Referer := FAdress + '/' + cbRequest.Text;
//          client.Request.ContentType := 'multipart/form-data';
//          client.Request.RawHeaders.AddValue('AuthToken', System.NetEncoding.TNetEncoding.URL.Encode('evjTI82N'));
//          postData.AddFormField('filename', System.NetEncoding.TNetEncoding.URL.Encode(fileName));
//          postData.AddFormField('isOverwrite', System.NetEncoding.TNetEncoding.URL.Encode(mPostParams.Lines[1]));
//          postData.AddFile('attach', mPostParams.Lines[0], 'application/x-rar-compressed');
//          client.POST(FAdress + '/' + cbRequest.Text, postData, ss);
//          TThread.Synchronize(TThread.CurrentThread,
//            procedure()
//            begin
//              mAnswer.Lines.Add(ss.DataString);
//              SaveRequest();
//            end);
//        end).Start();
//  end;
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
  ini.WriteString('server', 'port', DEFAULT_HTTP_PORT);
end;


{ THttpProtocolSettings }

constructor THttpProtocolSettings.Create(aFilePathSettings: string; aIsCreatedNewSettingsFile: Boolean);
begin
  FFIlePathSettings := aFilePathSettings;

  if aIsCreatedNewSettingsFile then
    WriteDefaultSettingsToFile();

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

  if (isRequestFound) and (currentIndex <> 0) then
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
    FData.Add('Test/Connection')
end;

destructor TLastHttpRequests.Destroy;
begin
  Save();
  FData.Free();
  inherited;
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
begin
  ini := TSP<Tinifile>.Create(Tinifile.Create(FFilePath));
  count := ini.ReadInteger('lastRequests', 'count', 0);
  for i := 0 to count - 1 do
  begin
    sectionName := Format('lastRequest%s', [i.ToString()]);
    FData.Add(ini.ReadString('lastRequests', sectionName, '<None>'));
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

  ini.WriteInteger('lastRequests', 'count', FData.Count);
end;

{ TSettingsFile }

constructor TSettingsFile.Create(aSettingsFilePath: string; aServer: TIdHTTPServer);
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

  FHttpProtocol := TSP<THttpProtocolSettings>.Create(THttpProtocolSettings.Create(aSettingsFilePath, FWasCreatedNewFile));
  aServer.DefaultPort := FHttpProtocol.Port;
end;

function TSettingsFile.GetAdress: string;
begin
  Result := FHttpProtocol.Adress;
end;

end.

