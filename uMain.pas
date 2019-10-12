unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, IdBaseComponent, IdComponent, IdCustomTCPServer,
  IdHTTPServer, Vcl.ComCtrls, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls, uCommandGet, uTimers, IdTCPConnection, IdTCPClient, IdHTTP, IdCustomHTTPServer, IdContext, Vcl.Samples.Spin,
  System.ImageList, Vcl.ImgList, uCommon, System.Classes, superobject, IdHeaderList, ShellApi, uRPTests, Registry, uConst, System.SyncObjs, IdServerIOHandler, IdSSL, IdSSLOpenSSL,
  Vcl.AppEvnts, Vcl.Menus, uPSClasses;

const
  WM_WORK_TIME = WM_USER + 1000;
  WM_APP_MEMORY = WM_USER + 1001;

type
  TMain = class(TForm)
    pUrlEncode: TPanel;
    bDoUrlEncode: TBitBtn;
    eUrlEncodeValue: TEdit;
    pTop: TPanel;
    bStartStop: TBitBtn;
    StatusBar: TStatusBar;
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
    procedure UpdateWorkTime(var aMsg: TMessage); message WM_WORK_TIME;
    procedure UpdateAppMemory(var aMsg: TMessage); message WM_APP_MEMORY;
  public
    constructor Create(AOwner: TComponent); override;
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
//  c := TSP<TIdHTTP>.Create();
//  c.Get(FAdress + '/System/Api');
//  ShellExecute(Handle, 'open', 'c:\windows\notepad.exe', PWideChar(ExtractFilePath(Application.ExeName) + 'api.txt'), nil, SW_SHOWNORMAL);
end;

procedure TMain.bClearAnswersClick(Sender: TObject);
begin
  mAnswer.Lines.Clear();
end;

procedure TMain.bDoUrlEncodeClick(Sender: TObject);
begin
  eUrlEncodeValue.Text := System.NetEncoding.TNetEncoding.URL.Encode(eUrlEncodeValue.Text);
end;



procedure TMain.bGoClick(Sender: TObject);
begin
//  case cbRequestType.ItemIndex of
//    0:
//      GetRequestProcessing();
//    1:
//      PostRequestProcessing();
//  end;
end;

procedure TMain.bLogClick(Sender: TObject);
begin
  ShellExecute(Handle, 'open', 'c:\windows\notepad.exe', PWideChar(ExtractFilePath(Application.ExeName) + 'log.txt'), nil, SW_SHOWNORMAL);
end;

procedure TMain.bSettingsClick(Sender: TObject);
begin
  ShellExecute(Handle, 'open', 'c:\windows\notepad.exe', PWideChar(ExtractFilePath(Application.ExeName) + 'settings.ini'), nil, SW_SHOWNORMAL);
end;

procedure TMain.bStartStopClick(Sender: TObject);
begin
//  SwitchStartStopButtons();
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

begin
  inherited;

  // Последние запросы читаем из текстового файла

  ReportMemoryLeaksOnShutdown := True;

//  ilPics.GetBitmap(3, bClearAnswers.Glyph);

//  bGo.Glyph := nil;
//  ilPics.GetBitmap(7, bGo.Glyph);
//  bSettings.Glyph := nil;
//  ilPics.GetBitmap(5, bSettings.Glyph);
end;

procedure TMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
//  Stop();
end;

procedure TMain.FormDestroy(Sender: TObject);
begin
//  FreeAndNil(FMyIcon);
end;


procedure TMain.pExitClick(Sender: TObject);
begin
//  Stop();
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
//  bStartStop.Glyph := nil;
//  ilPics.GetBitmap(aBitmapIndex, bStartStop.Glyph);
end;

procedure TMain.UpdateWorkTime(var aMsg: TMessage);
begin
  StatusBar.Panels[1].Text := PChar(aMsg.LParam);
end;

end.

