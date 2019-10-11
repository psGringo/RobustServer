unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, IdBaseComponent, IdComponent, IdCustomTCPServer,
  IdHTTPServer, Vcl.ComCtrls, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls, uCommandGet, uTimers, IdTCPConnection, IdTCPClient, IdHTTP, IdCustomHTTPServer, IdContext, Vcl.Samples.Spin,
  System.ImageList, Vcl.ImgList, uCommon, System.Classes, superobject, IdHeaderList, ShellApi, uRPTests, Registry, uConst, System.SyncObjs, IdServerIOHandler, IdSSL, IdSSLOpenSSL,
  Vcl.AppEvnts, Vcl.Menus;

const
  WM_WORK_TIME = WM_USER + 1000;
  WM_APP_MEMORY = WM_USER + 1001;

type
  TMain = class(TForm)
    Server: TIdHTTPServer;
    pUrlEncode: TPanel;
    bDoUrlEncode: TBitBtn;
    eUrlEncodeValue: TEdit;
    pTop: TPanel;
    bStartStop: TBitBtn;
    StatusBar: TStatusBar;
    ilPics: TImageList;
    bAPI: TBitBtn;
    bLog: TBitBtn;
    cbRequestType: TComboBox;
    pPost: TPanel;
    pPostParamsTop: TPanel;
    cbPostType: TComboBox;
    mPostParams: TMemo;
    pAnswers: TPanel;
    pAnswerTop: TPanel;
    mAnswer: TMemo;
    bClearAnswers: TBitBtn;
    pRequest: TPanel;
    cbRequest: TComboBoxEx;
    bGo: TBitBtn;
    IdServerIOHandlerSSLOpenSSL: TIdServerIOHandlerSSLOpenSSL;
    bSettings: TBitBtn;
    TrayIcon: TTrayIcon;
    ApplicationEvents: TApplicationEvents;
    PopupMenu: TPopupMenu;
    pNormalWindow: TMenuItem;
    pExit: TMenuItem;
    procedure ServerCommandGet(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    procedure bStartStopClick(Sender: TObject);
    procedure bAPIClick(Sender: TObject);
    procedure ServerException(AContext: TIdContext; AException: Exception);
    procedure UpdateStartStopGlyph(aBitmapIndex: integer);
    procedure bClearAnswersClick(Sender: TObject);
    procedure bLogClick(Sender: TObject);
    procedure bGoClick(Sender: TObject);
    procedure cbRequestTypeSelect(Sender: TObject);
    procedure bUrlEncodeClick(Sender: TObject);
    procedure cbPostTypeSelect(Sender: TObject);
    procedure bDoUrlEncodeClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure cbRequestKeyPress(Sender: TObject; var Key: Char);
    procedure bSettingsClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ApplicationEventsMinimize(Sender: TObject);
    procedure TrayIconDblClick(Sender: TObject);
    procedure pNormalWindowClick(Sender: TObject);
    procedure pExitClick(Sender: TObject);
  private
    { Private declarations }
    FProtocol: string;
    FHost: string;
    FPort: string;
    FTimers: TTimers;
    FAdress: string;
    FLongTaskThreads: ISP<TThreadList>;
    FCS: ISP<TCriticalSection>;
    FSomeSharedResource: ISP<TStringList>;
    FDBConnectionsCount: integer;
    FMyIcon: TIcon;
    procedure SwitchStartStopButtons();
    procedure UpdateWorkTime(var aMsg: TMessage); message WM_WORK_TIME;
    procedure UpdateAppMemory(var aMsg: TMessage); message WM_APP_MEMORY;
    procedure PostRequestProcessing();
    procedure GetRequestProcessing();
    procedure SaveRequest;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    procedure Start;
    procedure Stop;
    class function GetInstance(): TMain;
    property Protocol: string read FProtocol write FProtocol;
    property Host: string read FHost write FHost;
    property Port: string read FPort write FPort;
    property Adress: string read FAdress write FAdress;
    property Timers: TTimers read FTimers write FTimers;
    property LongTaskThreads: ISP<TThreadList> read FLongTaskThreads;
    property CS: ISP<TCriticalSection> read FCS write FCS;
    property SomeSharedResource: ISP<TStringList> read FSomeSharedResource;
    property DBConnectionsCount: integer read FDBConnectionsCount write FDBConnectionsCount;
  end;

var
  Main: TMain;

implementation
{$R *.dfm}

uses
  System.NetEncoding, IdMultipartFormData, uClientExamples, uRP, System.Math, System.IOUtils, System.IniFiles, uRSService;

{ TMain }
procedure TMain.ApplicationEventsMinimize(Sender: TObject);
begin
  TrayIcon.Visible := True;
  Application.ShowMainForm := True;
  ShowWindow(Handle, SW_HIDE);
end;

procedure TMain.bAPIClick(Sender: TObject);
var
  c: ISP<TIdHTTP>;
begin
  c := TSP<TIdHTTP>.Create();
  c.Get(FAdress + '/System/Api');
  ShellExecute(Handle, 'open', 'c:\windows\notepad.exe', PWideChar(ExtractFilePath(Application.ExeName) + 'api.txt'), nil, SW_SHOWNORMAL);
end;

procedure TMain.bClearAnswersClick(Sender: TObject);
begin
  mAnswer.Lines.Clear();
end;

procedure TMain.bDoUrlEncodeClick(Sender: TObject);
begin
  eUrlEncodeValue.Text := System.NetEncoding.TNetEncoding.URL.Encode(eUrlEncodeValue.Text);
end;

procedure TMain.SaveRequest();
var
  filepathLastRequests: string;
  sl: ISP<TStringList>;
  fs: TFileStream;
  index: Integer;
  j: Integer;
const
  maxListCount = 10;
begin
  // Последние запросы читаем из текстового файла
  filepathLastRequests := ExtractFilePath(Application.ExeName) + lastRequestsFileName;

  if not TFile.Exists(filepathLastRequests) then
  try
    fs := TFile.Create(filepathLastRequests);
  finally
    fs.Free;
  end;

  sl := TSP<TStringList>.Create();
  sl.LoadFromFile(filepathLastRequests);

  index := sl.IndexOf(trim(cbRequest.Text));
  if (index = -1) and (cbRequest.Text <> '') then
  begin
    sl.Add(cbRequest.Text);
    cbRequest.Items.Assign(sl);
    // Очищаем список, если больше 10 элементов
    if sl.Count > maxListCount then
    begin
      for j := sl.Count - 1 downto maxListCount do
        sl.Delete(j);
    end;
    cbRequest.Items.Assign(sl);
  end
  else
    sl.Move(index, 0); // move Position first

  sl.SaveToFile(filepathLastRequests);
end;

procedure TMain.bGoClick(Sender: TObject);
begin
  case cbRequestType.ItemIndex of
    0:
      GetRequestProcessing();
    1:
      PostRequestProcessing();
  end;
end;

procedure TMain.bLogClick(Sender: TObject);
begin
  ShellExecute(Handle, 'open', 'c:\windows\notepad.exe', PWideChar(ExtractFilePath(Application.ExeName) + 'log.txt'), nil, SW_SHOWNORMAL);
end;

procedure TMain.PostRequestProcessing();
begin
  case cbPostType.ItemIndex of
    0:
      begin
        TTHread.CreateAnonymousThread(
          procedure()
          var
            r: string;
            client: ISP<TIdHTTP>;
            ss: ISP<TStringStream>;
            jo: ISuperobject;
          begin
            client := TSP<TIdHTTP>.Create();
            jo := SO(Trim(mPostParams.Lines.Text));
            ss := TSP<TStringStream>.Create();
            ss.WriteString(jo.AsJSon(false, false));
            client.Request.ContentType := 'application/json';
            client.Request.ContentEncoding := 'utf-8';
            r := client.Post(FAdress + '/' + cbRequest.Text, ss);
            TThread.Synchronize(TThread.CurrentThread,
              procedure()
              begin
                mAnswer.Lines.Add(r);
                SaveRequest();
              end);
          end).Start();
      end;
    1:
      TTHread.CreateAnonymousThread(
        procedure()
        var
          r: string;
          client: ISP<TIdHTTP>;
          paramsSL: ISP<TStringList>;
        begin
          client := TSP<TIdHTTP>.Create();
           //for test Send with 2 params on  Test/URLEncoded
          paramsSL := TSP<TStringList>.Create();
          paramsSL.Assign(mPostParams.Lines);
            { or in code you can add params...
             paramsSL.Add('a=UrlEncoded(aValue)')
             paramsSL.Add('b=UrlEncoded(bValue)')
            }
          client.Request.ContentType := 'application/x-www-form-urlencoded';
          client.Request.ContentEncoding := 'utf-8';

          r := client.Post(FAdress + '/' + cbRequest.Text, paramsSL);

          TThread.Synchronize(TThread.CurrentThread,
            procedure()
            begin
              mAnswer.Lines.Add(r);
              SaveRequest();
            end);
        end).Start();
    2:
      TTHread.CreateAnonymousThread(
        procedure()
        var
          client: ISP<TIdHTTP>;
          ss: ISP<TStringStream>;
          fileName: string;
          postData: ISP<TIdMultiPartFormDataStream>;
        begin
          ss := TSP<TStringStream>.Create();
          client := TSP<TIdHTTP>.Create();
            // multipart...
          fileName := ExtractFileName(mPostParams.Lines[0]);
          postData := TSP<TIdMultiPartFormDataStream>.Create();
          client.Request.Referer := FAdress + '/' + cbRequest.Text;
          client.Request.ContentType := 'multipart/form-data';
          client.Request.RawHeaders.AddValue('AuthToken', System.NetEncoding.TNetEncoding.URL.Encode('evjTI82N'));
          postData.AddFormField('filename', System.NetEncoding.TNetEncoding.URL.Encode(fileName));
          postData.AddFormField('isOverwrite', System.NetEncoding.TNetEncoding.URL.Encode(mPostParams.Lines[1]));
          postData.AddFile('attach', mPostParams.Lines[0], 'application/x-rar-compressed');
          client.POST(FAdress + '/' + cbRequest.Text, postData, ss);
          TThread.Synchronize(TThread.CurrentThread,
            procedure()
            begin
              mAnswer.Lines.Add(ss.DataString);
              SaveRequest();
            end);
        end).Start();
  end;
end;

procedure TMain.bSettingsClick(Sender: TObject);
begin
  ShellExecute(Handle, 'open', 'c:\windows\notepad.exe', PWideChar(ExtractFilePath(Application.ExeName) + 'settings.ini'), nil, SW_SHOWNORMAL);
end;

procedure TMain.bStartStopClick(Sender: TObject);
begin
  SwitchStartStopButtons();
end;

procedure TMain.bUrlEncodeClick(Sender: TObject);
begin
  pUrlEncode.Visible := not pUrlEncode.Visible;
end;

procedure TMain.cbPostTypeSelect(Sender: TObject);
begin
  mPostParams.Clear();
  mPostParams.Lines.BeginUpdate;
  case cbPostType.ItemIndex of
    0:
      begin
        //cmbRequest.Text := 'Test/PostJson';
        mPostParams.Text := '{ "name":"Stas", "age":35 }';
      end;
    1:
      begin
        //cmbRequest.Text := 'Test/URLEncoded';
        mPostParams.Lines.Add('PostParam1 = URLEncoded(PostParam1Value)');
        mPostParams.Lines.Add('PostParam2 = URLEncoded(PostParam2Value)');
      end;
    2:
      begin
        cbRequest.Text := 'Files/Upload';
        mPostParams.Lines.Add(ExtractFilePath(Application.ExeName) + 'testFile.php');
        mPostParams.Lines.Add('false');
      end;
  end;
  mPostParams.Lines.EndUpdate;
end;

procedure TMain.cbRequestKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
    bGoClick(Self);
end;

procedure TMain.cbRequestTypeSelect(Sender: TObject);
begin
  case cbRequestType.ItemIndex of
    0:
      cbRequest.Text := 'Test/Connection';
    1:
      cbPostTypeSelect(nil);
  end;
end;

constructor TMain.Create(AOwner: TComponent);
var
  filepathSettings: string;
  filepathLastRequests: string;
  iniSettings: ISP<TIniFile>;
  i: integer;
begin
  inherited;

  filepathSettings := ExtractFilePath(Application.ExeName) + settingsFileName;
  if TFile.Exists(filepathSettings) then
  begin
    iniSettings := TSP<Tinifile>.Create(Tinifile.Create(filepathSettings));
    FProtocol := iniSettings.ReadString('server', 'protocol', '<None>');
    FHost := iniSettings.ReadString('server', 'host', '<None>');
    FPort := iniSettings.ReadString('server', 'port', '<None>');
  end
  else
  begin
    FProtocol := 'http';
    FHost := 'localhost';
    FPort := '7777';
  end;
  Adress := FProtocol + '://' + FHost + ':' + FPort;
  // Последние запросы читаем из текстового файла
  filepathLastRequests := ExtractFilePath(Application.ExeName) + lastRequestsFileName;
  if TFile.Exists(filepathLastRequests) then
  begin
    cbRequest.Items.LoadFromFile(filepathLastRequests);
    if cbRequest.Items.Count > 0 then
      cbRequest.ItemIndex := 0
    else
      cbRequest.Text := 'Test/Connection';
  end;

  ReportMemoryLeaksOnShutdown := True;
  FTimers := TTimers.Create(Self);
  Server.DefaultPort := FPort.ToInteger();
  ilPics.GetBitmap(3, bClearAnswers.Glyph);
  SwitchStartStopButtons(); // will start server

  FLongTaskThreads := TSP<TThreadList>.Create();
  FCS := TSP<TCriticalSection>.Create();
  FSomeSharedResource := TSP<TStringList>.Create();
  //some test values
  for i := 0 to 99 do
    FSomeSharedResource.Add(Random(9).ToString());

  bGo.Glyph := nil;
  ilPics.GetBitmap(7, bGo.Glyph);
  bSettings.Glyph := nil;
  ilPics.GetBitmap(5, bSettings.Glyph);
end;

procedure TMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Stop();
end;

procedure TMain.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FMyIcon);
end;

class function TMain.GetInstance: TMain;
begin
  if Assigned(RobustService) then
    Result := TMain(RobustService.MainInstance)
  else
    Result := Main;
end;

procedure TMain.GetRequestProcessing;
begin
  TTHread.CreateAnonymousThread(
    procedure()
    var
      r: string;
      client: ISP<TIdHTTP>;
    begin
      client := TSP<TIdHTTP>.Create();
      r := client.Get(FAdress + '/' + cbRequest.Text);
      TThread.Synchronize(TThread.CurrentThread,
        procedure()
        begin
          mAnswer.Lines.BeginUpdate;
          mAnswer.Lines.Add(r);
          mAnswer.Lines.EndUpdate;
          SaveRequest();
        end);
    end).Start();
end;

procedure TMain.pExitClick(Sender: TObject);
begin
  Stop();
end;

procedure TMain.pNormalWindowClick(Sender: TObject);
begin
  Self.WindowState := wsNormal;
end;

procedure TMain.ServerCommandGet(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  cg: ISP<TCommandGet>;
begin
  cg := TSP<TCommandGet>.Create(TCommandGet.Create(AContext, ARequestInfo, AResponseInfo));
end;

procedure TMain.ServerException(AContext: TIdContext; AException: Exception);
var
  l: ISP<TLogger>;
begin
  l := TSP<TLogger>.Create();
  l.LogError('Exception class ' + AException.ClassName + ' exception message ' + AException.Message);
end;

procedure TMain.Start;
var
  l: ISP<TLogger>;
begin
  l := TSP<TLogger>.Create();
  Server.Active := true;
  StatusBar.Panels[0].Text := 'Started';
  UpdateStartStopGlyph(1);
  l.LogInfo('Server successfully started');
end;

procedure TMain.Stop;
var
  l: ISP<TLogger>;
  i: integer;
begin
  l := TSP<TLogger>.Create();
  Server.Active := false;
  StatusBar.Panels[0].Text := 'Stopped';
  UpdateStartStopGlyph(0);
  l.LogInfo('Server successfully stopped');
  //
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
  //
end;

procedure TMain.SwitchStartStopButtons;
begin
  if (Server.Active) then
    Stop
  else
    Start;
end;

procedure TMain.TrayIconDblClick(Sender: TObject);
begin
  TrayIcon.Visible := False;
  Show();
  WindowState := wsNormal;
  Application.BringToFront()
end;

procedure TMain.UpdateAppMemory(var aMsg: TMessage);
begin
  StatusBar.Panels[2].Text := PChar(aMsg.LParam);
end;

procedure TMain.UpdateStartStopGlyph(aBitmapIndex: integer);
begin
  bStartStop.Glyph := nil;
  ilPics.GetBitmap(aBitmapIndex, bStartStop.Glyph);
end;

procedure TMain.UpdateWorkTime(var aMsg: TMessage);
begin
  StatusBar.Panels[1].Text := PChar(aMsg.LParam);
end;

end.

