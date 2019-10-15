unit uRSService;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.SvcMgr, Vcl.Dialogs,
  Vcl.Forms;

type
  TRobustService = class(TService)
    procedure ServiceCreate(Sender: TObject);
    procedure ServiceStart(Sender: TService; var Started: Boolean);
    procedure ServiceStop(Sender: TService; var Stopped: Boolean);
  private
    FMainInstance: TObject;
    { Private declarations }
  public
    { Public declarations }
    function GetServiceController: TServiceController; override;
    property MainInstance: TObject read FMainInstance write FMainInstance;
  end;

var
  RobustService: TRobustService;

implementation

uses uRSMainModule;

{%CLASSGROUP 'Vcl.Controls.TControl'}
{$R *.dfm}

{ TMainService }

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  RobustService.Controller(CtrlCode);
end;

function TRobustService.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure TRobustService.ServiceCreate(Sender: TObject);
begin
   FMainInstance := TRSMainModule.Create(Self, true);
end;

procedure TRobustService.ServiceStart(Sender: TService; var Started: Boolean);
begin
  TRSMainModule(FMainInstance).Start();
  Started := true;
end;

procedure TRobustService.ServiceStop(Sender: TService; var Stopped: Boolean);
begin
  TRSMainModule(FMainInstance).Stop();
  Stopped := true;
end;


end.

