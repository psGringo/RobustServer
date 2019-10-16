unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, IdBaseComponent, IdComponent, IdCustomTCPServer,
  IdHTTPServer, Vcl.ComCtrls, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls, uCommandGet, IdTCPConnection, IdTCPClient, IdCustomHTTPServer, IdContext, Vcl.Samples.Spin, System.ImageList,
  Vcl.ImgList, uCommon, System.Classes, superobject, IdHeaderList, ShellApi, Registry, uConst, System.SyncObjs, IdServerIOHandler, IdSSL, IdSSLOpenSSL, Vcl.AppEvnts, Vcl.Menus,
  //
  uPSClasses, //
  uRPRegistrations, //
  uRSMainModule, //
  uRSGui, //
  uRP, //
  uRPUsers, //
  uRPTests, //
  uRPFiles, //
  uRPSystem //
;

type
  TMain = class(TForm)
    procedure FormDestroy(Sender: TObject);
    procedure pNormalWindowClick(Sender: TObject);
  private
    FRSGui: TRSGui;
    FRSMainModule: TRSMainModule;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  Main: TMain;

implementation
{$R *.dfm}

uses
  System.NetEncoding, IdMultipartFormData, uClientExamples, System.Math, System.IOUtils, System.IniFiles, uRSService;

{ TMain }
constructor TMain.Create(AOwner: TComponent);
begin
  inherited;
  ReportMemoryLeaksOnShutdown := True;

  GlobalRPRegistrations := TRPRegistrations.Create();
  //
  GlobalRPRegistrations.RegisterRPClass(TRPUsers, RP_Users);
  GlobalRPRegistrations.RegisterRPClass(TRPTests, RP_Tests);
  GlobalRPRegistrations.RegisterRPClass(TRPFiles, RP_Files);
  GlobalRPRegistrations.RegisterRPClass(TRPSystem, RP_System);
  //
  FRSMainModule := TRSMainModule.Create(Self, True);
  FRSGui := TRSGui.Create(Self, RSMainModule);
  FRSGui.Parent := Self;
  FRSGui.Align := alClient;
  FRSGui.Show();
end;

destructor TMain.Destroy;
begin
  GlobalRPRegistrations.Free();
  inherited;
end;

procedure TMain.FormDestroy(Sender: TObject);
begin
//  FreeAndNil(FMyIcon);
end;

procedure TMain.pNormalWindowClick(Sender: TObject);
begin
  Self.WindowState := wsNormal;
end;

end.

