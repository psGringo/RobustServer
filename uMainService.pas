unit uMainService;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.SvcMgr, Vcl.Dialogs, uMain, Vcl.Forms;

type
  TDRS = class(TService)
    procedure ServiceCreate(Sender: TObject);
    procedure ServiceStart(Sender: TService; var Started: Boolean);
    procedure ServiceStop(Sender: TService; var Stopped: Boolean);
  private
    { Private declarations }
    FMain: TMain;
  public
    { Public declarations }
    function GetServiceController: TServiceController; override;
  end;

var
  DRS: TDRS;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

{ TMainService }

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  DRS.Controller(CtrlCode);
end;

function TDRS.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure TDRS.ServiceCreate(Sender: TObject);
begin
  FMain := TMain.Create(Self);
end;

procedure TDRS.ServiceStart(Sender: TService; var Started: Boolean);
begin
  FMain.Start();
//  Started := true;
end;

procedure TDRS.ServiceStop(Sender: TService; var Stopped: Boolean);
begin
  FMain.Stop();
//  Stopped := true;
end;

end.

