unit uRPAutotests;

interface

uses
  System.SysUtils, System.Classes, IdCustomHTTPServer, superobject, uCommon, uDB, uRP, IdContext, System.NetEncoding,
  uAttributes, System.JSON, SyncObjs, Vcl.ExtCtrls;

type
  TRPAutotests = class(TRP)
  private
    FTimer: TTimer;
    FProc: TProc<integer>;
    procedure OnTimer(Sender: TObject);
    procedure TestDBConnections(aCountRequestsPerSecond: integer);
  public
    constructor Create(aContext: TIdContext; aRequestInfo: TIdHTTPRequestInfo; aResponseInfo: TIdHTTPResponseInfo);
      overload; override;
    destructor Destroy; override;
    procedure DBConnections(aCountRequestsPerSecond: string);
  end;

implementation

uses
  IdHTTP;

{ TRPAutotests }

constructor TRPAutotests.Create(aContext: TIdContext; aRequestInfo: TIdHTTPRequestInfo; aResponseInfo: TIdHTTPResponseInfo);
begin
  inherited;
  FTimer := TTimer.Create(Self);
  FTimer.Enabled := false;
  Execute('Autotests');
end;

procedure TRPAutotests.DBConnections(aCountRequestsPerSecond: string);
begin
  FProc := TestDBConnections(aCountRequestsPerSecond.ToInteger());
  FTimer.Enabled := true;
end;

destructor TRPAutotests.Destroy;
begin
  FTimer.Free();
  inherited;
end;

procedure TRPAutotests.OnTimer(Sender: TObject);
begin

end;

procedure TRPAutotests.TestDBConnections(aCountRequestsPerSecond: integer);
var
  i: Integer;
  l: ISP<TLogger>;
begin
  for i := 0 to aCountRequestsPerSecond.ToInteger() do
  begin
    TThread.CreateAnonymousThread(
      procedure()
      var
        c: ISP<TIdHTTP>;
        s: string;
      begin
        try
          c := TSP<TIdHTTP>.Create();
          s := c.Get('http://localhost:7777/Test/DBConnection');
        except
          on E: Exception do
          begin
            l := TSP<TLogger>.Create();
            l.LogError(e.Message);
          end;
        end;
      end).Start();
  end;
end;

end.

