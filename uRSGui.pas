unit uRSGui;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls,
  Vcl.ComCtrls, System.ImageList, Vcl.ImgList, System.NetEncoding, IdHTTP,
  //
  uRSMainModule, //
  uPSClasses, //
  uConst;

const
  WM_WORK_TIME = WM_USER + 1000;
  WM_APP_MEMORY = WM_USER + 1001;

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
    eUrlEncode: TEdit;
    bUrlEncode: TBitBtn;
    mAnswers: TMemo;
    ilPics: TImageList;
    bSettings: TBitBtn;
    bApi: TBitBtn;
    bLog: TBitBtn;
    bClearAnswers: TBitBtn;
    cbRequest: TComboBox;
    procedure bStartStopClick(Sender: TObject);
    procedure bUrlEncodeClick(Sender: TObject);
    procedure cbRequestTypeSelect(Sender: TObject);
    procedure bFireClick(Sender: TObject);
  private
    FRSMainModule: TRSMainModule;
    procedure UpdateAppMemory(var aMsg: TMessage); message WM_APP_MEMORY;
    procedure UpdateWorkTime(var aMsg: TMessage); message WM_WORK_TIME;
    procedure SetStartStopGUI();
    procedure ProcessGetRequest();
  public
    constructor Create(aOwner: TComponent; aRSMainModule: TRSMainModule);
  end;

implementation

{$R *.dfm}

{ TRSGui }

procedure TRSGui.bFireClick(Sender: TObject);
begin
  if cbRequestType.ItemIndex = GUI_REQUEST_TYPE_GET then
    ProcessGetRequest();

end;

procedure TRSGui.UpdateAppMemory(var aMsg: TMessage);
begin
  StatusBar.Panels[2].Text := PChar(aMsg.LParam);
end;

procedure TRSGui.UpdateWorkTime(var aMsg: TMessage);
begin
  StatusBar.Panels[1].Text := PChar(aMsg.LParam);
end;

procedure TRSGui.bStartStopClick(Sender: TObject);
begin
  FRSMainModule.ToggleStartStop();
  SetStartStopGUI();
end;

procedure TRSGui.bUrlEncodeClick(Sender: TObject);
begin
  eUrlEncode.Text := TNetEncoding.URL.Encode(eUrlEncode.Text);
end;

procedure TRSGui.cbRequestTypeSelect(Sender: TObject);
begin
  cbPostRequestType.Visible := cbRequestType.ItemIndex = GUI_REQUEST_TYPE_POST;
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
  // fire button
  bFire.Glyph := nil;
  ilPics.GetBitmap(7, bFire.Glyph);
  // settings
  bSettings.Glyph := nil;
  ilPics.GetBitmap(5, bSettings.Glyph);
  // clearAnswers
  bClearAnswers.Glyph := nil;
  ilPics.GetBitmap(3, bClearAnswers.Glyph);
  //
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

