unit uRSGui;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls,
  Vcl.ComCtrls, System.ImageList, Vcl.ImgList, System.NetEncoding, IdHTTP, ShellApi, uRSCommon,
  //
  uRSMainModule, //
  uPSClasses, //
  uRSConst;

type
  TRSGui = class(TFrame)
    pTop: TPanel;
    bStartStop: TBitBtn;
    StatusBar: TStatusBar;
    PageControl: TPageControl;
    tsMonitor: TTabSheet;
    tsClient: TTabSheet;
    pClientTop: TPanel;
    cbRequestType: TComboBox;
    cbPostRequestType: TComboBox;
    pRequest: TPanel;
    bFire: TBitBtn;
    ilPics: TImageList;
    bSettings: TBitBtn;
    bApi: TBitBtn;
    bLog: TBitBtn;
    cbRequest: TComboBox;
    pPostParams: TPanel;
    pPostParamsTop: TPanel;
    mPostParams: TMemo;
    pAnswers: TPanel;
    pAnswersTop: TPanel;
    mAnswers: TMemo;
    bClearPostParams: TBitBtn;
    bClearAnswers: TBitBtn;
    bClearRequest: TBitBtn;
    bUrlEncode: TBitBtn;
    pUrlEncode: TPanel;
    bDoEncode: TBitBtn;
    eUrlEncode: TEdit;
    procedure bStartStopClick(Sender: TObject);
    procedure bDoEncodeClick(Sender: TObject);
    procedure cbRequestTypeSelect(Sender: TObject);
    procedure bFireClick(Sender: TObject);
    procedure bClearAnswersClick(Sender: TObject);
    procedure bClearPostParamsClick(Sender: TObject);
    procedure bClearRequestClick(Sender: TObject);
    procedure bUrlEncodeClick(Sender: TObject);
    procedure bSettingsClick(Sender: TObject);
    procedure bApiClick(Sender: TObject);
    procedure bLogClick(Sender: TObject);
  private
    FRSMainModule: TRSMainModule;
    procedure SetGlyphsToButtons();
    procedure UpdateAppMemory(var aMsg: TMessage); message WM_APP_MEMORY;
    procedure UpdateWorkTime(var aMsg: TMessage); message WM_WORK_TIME;
    procedure SetStartStopGUI();
    procedure ProcessGetRequest();
    procedure ProcessPostRequest();
    procedure PostRequestApplicationJson();
    procedure PostRequestUrlEncoded();
    procedure PostRequestMultiPart();
  public
    constructor Create(aOwner: TComponent; aRSMainModule: TRSMainModule);
  end;

implementation

uses
  superobject, IdMultipartFormData;

{$R *.dfm}

{ TRSGui }

procedure TRSGui.bApiClick(Sender: TObject);
var
  c: ISP<TIdHTTP>;
  filePathApi: string;
begin
  c := TSP<TIdHTTP>.Create();
  c.Get(Format('%s/System/Api', [FRSMainModule.Adress]));
  filePathApi := Format('%s%s', [ExtractFilePath(Application.ExeName), API_FILE_NAME]);
  ShellExecute(Handle, 'open', 'c:\windows\notepad.exe', PWideChar(filePathApi), nil, SW_SHOWNORMAL);
end;

procedure TRSGui.bClearAnswersClick(Sender: TObject);
begin
  mAnswers.Clear();
end;

procedure TRSGui.bClearPostParamsClick(Sender: TObject);
begin
  mPostParams.Clear();
end;

procedure TRSGui.bClearRequestClick(Sender: TObject);
var
  nextIndex: integer;
begin
  FRSMainModule.LastHttpRequests.Delete(cbRequest.Text);

  nextIndex := -1;
  if cbRequest.ItemIndex + 1 < cbRequest.Items.Count - 1 then
    nextIndex := cbRequest.ItemIndex + 1;

  cbRequest.Items.Delete(cbRequest.ItemIndex);
  cbRequest.ItemIndex := nextIndex;
end;

procedure TRSGui.bFireClick(Sender: TObject);
begin
  case cbRequestType.ItemIndex of
    GUI_REQUEST_TYPE_GET:
      ProcessGetRequest();
    GUI_REQUEST_TYPE_POST:
      ProcessPostRequest();
  end;
end;

procedure TRSGui.bLogClick(Sender: TObject);
var
  filePathLog: string;
begin
  filePathLog := Format('%s%s', [ExtractFilePath(Application.ExeName), LOG_FILE_NAME]);
  ShellExecute(Handle, 'open', 'c:\windows\notepad.exe', PWideChar(filePathLog), nil, SW_SHOWNORMAL);
end;

procedure TRSGui.UpdateAppMemory(var aMsg: TMessage);
begin
  StatusBar.Panels[2].Text := PChar(aMsg.LParam);
end;

procedure TRSGui.UpdateWorkTime(var aMsg: TMessage);
begin
  StatusBar.Panels[1].Text := PChar(aMsg.LParam);
end;

procedure TRSGui.bSettingsClick(Sender: TObject);
var
  filePathSettings: string;
begin
  filePathSettings := Format('%s%s', [ExtractFilePath(Application.ExeName), SETTINGS_FILE_NAME]);
  ShellExecute(Handle, 'open', 'c:\windows\notepad.exe', PWideChar(filePathSettings), nil, SW_SHOWNORMAL);
end;

procedure TRSGui.bStartStopClick(Sender: TObject);
begin
  FRSMainModule.ToggleStartStop();
  SetStartStopGUI();
end;

procedure TRSGui.bUrlEncodeClick(Sender: TObject);
begin
  eUrlEncode.Visible := not eUrlEncode.Visible;
  bDoEncode.Visible := not bDoEncode.Visible;
end;

procedure TRSGui.bDoEncodeClick(Sender: TObject);
begin
  eUrlEncode.Text := TNetEncoding.URL.Encode(eUrlEncode.Text);
end;

procedure TRSGui.cbRequestTypeSelect(Sender: TObject);
begin
  cbPostRequestType.Visible := cbRequestType.ItemIndex = GUI_REQUEST_TYPE_POST;
  pPostParams.Visible := cbRequestType.ItemIndex = GUI_REQUEST_TYPE_POST;
end;

constructor TRSGui.Create(aOwner: TComponent; aRSMainModule: TRSMainModule);
var
  paramValidator: ISP<TParamValidator>;
begin
  inherited Create(aOwner);
  paramValidator := TSP<TParamValidator>.Create();
  paramValidator.EnsureNotNull(aRSMainModule);
  FRSMainModule := aRSMainModule;
  FRSMainModule.RSGui := Self;
  FRSMainModule.Timers.RSGui := Self;

  cbRequest.Items.Assign(FRSMainModule.LastHttpRequests.Data);
  cbRequest.ItemIndex := 0;

  SetStartStopGUI();
  SetGlyphsToButtons();
end;

procedure TRSGui.PostRequestApplicationJson;
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
      r := client.Post(FRSMainModule.Adress + '/' + cbRequest.Text, ss);
      TThread.Synchronize(TThread.CurrentThread,
        procedure()
        begin
          mAnswers.Lines.Add(r);
          FRSMainModule.LastHttpRequests.AddToFirstPosition(cbRequest.Text);
        end);
    end).Start();
end;

procedure TRSGui.PostRequestMultiPart;
begin
  TTHread.CreateAnonymousThread(
    procedure()
    var
      client: ISP<TIdHTTP>;
      ss: ISP<TStringStream>;
      fileName: string;
      postData: ISP<TIdMultiPartFormDataStream>;
      request: string;
    begin
      request := Format('%s/%s', [FRSMainModule.Adress, cbRequest.Text]);
      ss := TSP<TStringStream>.Create();
      client := TSP<TIdHTTP>.Create();
          // multipart...
      fileName := ExtractFileName(mPostParams.Lines[0]);
      postData := TSP<TIdMultiPartFormDataStream>.Create();
      client.Request.Referer := request;
      client.Request.ContentType := 'multipart/form-data';
      client.Request.RawHeaders.AddValue('AuthToken', System.NetEncoding.TNetEncoding.URL.Encode('evjTI82N'));
      postData.AddFormField('filename', System.NetEncoding.TNetEncoding.URL.Encode(fileName));
      postData.AddFormField('isOverwrite', System.NetEncoding.TNetEncoding.URL.Encode(mPostParams.Lines[1]));
      postData.AddFile('attach', mPostParams.Lines[0], 'application/x-rar-compressed');
      client.POST(request, postData, ss);
      TThread.Synchronize(TThread.CurrentThread,
        procedure()
        begin
          mAnswers.Lines.Add(ss.DataString);
          FRSMainModule.LastHttpRequests.AddToFirstPosition(cbRequest.Text);
        end);
    end).Start();
end;

procedure TRSGui.PostRequestUrlEncoded;
begin
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

      r := client.Post(FRSMainModule.Adress + '/' + cbRequest.Text, paramsSL);

      TThread.Synchronize(TThread.CurrentThread,
        procedure()
        begin
          mAnswers.Lines.Add(r);
          FRSMainModule.LastHttpRequests.AddToFirstPosition(cbRequest.Text);
        end);
    end).Start();
end;

procedure TRSGui.ProcessGetRequest;
begin
  TTHread.CreateAnonymousThread(
    procedure()
    var
      r: string;
      client: ISP<TIdHTTP>;
    begin
      client := TSP<TIdHTTP>.Create();
      r := client.Get(FRSMainModule.Adress + '/' + cbRequest.Text);
      TThread.Synchronize(TThread.CurrentThread,
        procedure()
        begin
          mAnswers.Lines.BeginUpdate;
          mAnswers.Lines.Add(r);
          mAnswers.Lines.EndUpdate;
          FRSMainModule.LastHttpRequests.AddToFirstPosition(cbRequest.Text);
        end);
    end).Start();
end;

procedure TRSGui.ProcessPostRequest;
begin
  case cbPostRequestType.ItemIndex of
    GUI_REQUEST_TYPE_POST_APPLICATION_JSON:
      PostRequestApplicationJson();

    GUI_REQUEST_TYPE_POST_URL_ENCODED:
      PostRequestUrlEncoded();

    GUI_REQUEST_TYPE_POST_MULTIPART:
      PostRequestMultiPart();
  end;
end;

procedure TRSGui.SetGlyphsToButtons;
begin
  // fire button
  bFire.Glyph := nil;
  ilPics.GetBitmap(7, bFire.Glyph);
  // settings
  bSettings.Glyph := nil;
  ilPics.GetBitmap(5, bSettings.Glyph);
  // clearAnswers
  bClearAnswers.Glyph := nil;
  ilPics.GetBitmap(3, bClearAnswers.Glyph);
  // clear post params
  bClearPostParams.Glyph := nil;
  ilPics.GetBitmap(3, bClearPostParams.Glyph);
  // clear request
  bClearRequest.Glyph := nil;
  ilPics.GetBitmap(8, bClearRequest.Glyph);
end;

procedure TRSGui.SetStartStopGUI;
begin
  if FRSMainModule.Server.Active then
  begin
    bStartStop.Glyph := nil;
    ilPics.GetBitmap(1, bStartStop.Glyph);
    StatusBar.Panels[0].Text := 'Started';
  end
  else
  begin
    bStartStop.Glyph := nil;
    ilPics.GetBitmap(0, bStartStop.Glyph);
    StatusBar.Panels[0].Text := 'Stopped';
  end;
end;

end.

