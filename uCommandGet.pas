unit uCommandGet;

interface

uses
  System.Classes, IdContext, IdCustomHTTPServer, System.Generics.Collections, superobject, System.NetEncoding, System.IOUtils, Vcl.Forms, uUniqueName, uDB, uCommon,
  Spring.Collections, uRP, IdException;

type
  TCommandGet = class
  private
    FContext: TIdContext;
    FRequestInfo: TIdHTTPRequestInfo;
    FResponseInfo: TIdHTTPResponseInfo;
    FUniqueModuleNames: IDictionary<string, TRPClass>;
    procedure ProcessRequest();
    function ParseFirstSection(): string;
    procedure DownloadFile;
  public
    constructor Create(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    procedure Execute();
    property Context: TIdContext read FContext write FContext;
    property RequestInfo: TIdHTTPRequestInfo read FRequestInfo write FRequestInfo;
    property ResponseInfo: TIdHTTPResponseInfo read FResponseInfo write FResponseInfo;
  end;

implementation

uses
  uRPUsers, uRPTests, uRPFiles, uRPSystem, uDecodePostRequest, System.SysUtils, DateUtils, uConst;

{ TCommandGet }
constructor TCommandGet.Create(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
begin
  FContext := AContext;
  FRequestInfo := ARequestInfo;
  FResponseInfo := AResponseInfo;
  FUniqueModuleNames := TCollections.CreateDictionary<string, TRPClass>;
  // fill data
  FUniqueModuleNames.Add(RP_Users, TRPUsers);
  FUniqueModuleNames.Add(RP_Tests, TRPTests);
  FUniqueModuleNames.Add(RP_Files, TRPFiles);
  FUniqueModuleNames.Add(RP_System, TRPSystem);
  // fire
  Execute();
end;

procedure TCommandGet.DownloadFile();
var
  f: ISP<TRPFiles>;
begin
  f := TSP<TRPFiles>.Create(TRPFiles.Create(FContext, FRequestInfo, FResponseInfo, true));
  f.Download();
end;

procedure TCommandGet.Execute();
var
  responses: ISP<TResponses>;
begin
  try
    ProcessRequest();
    DownloadFile();
    FResponseInfo.ResponseNo := 404;
  except
    on E: Exception do
    begin
      responses := TSP<TResponses>.Create(TResponses.Create(FRequestInfo, FResponseInfo));
      responses.Error(e.Message);
    end;
  end;
end;

function TCommandGet.ParseFirstSection(): string;
var
  a: TArray<string>;
begin
  Result := '';
  a := FRequestInfo.URI.Split(['/']);
  if Length(a) > 0 then
    Result := a[1]; // Parses Users from /Users/Add for example....
end;

procedure TCommandGet.ProcessRequest();
var
  rp: ISP<TRP>;
  firstSection: string;
begin
  firstSection := ParseFirstSection();
  if FUniqueModuleNames.ContainsKey(firstSection) then
    rp := TSP<TRP>.Create(FUniqueModuleNames.GetValueOrDefault(firstSection).Create(FContext, FRequestInfo, FResponseInfo));
end;

end.

