unit uRPFiles;

interface

uses
  System.SysUtils, System.Classes, IdCustomHTTPServer, superobject, uRSCommon, uDB,
  uRP, IdContext, System.NetEncoding, uAttributes, System.JSON;

type
  TRPFiles = class(TRP)
    public
    constructor Create(aContext: TIdContext; aRequestInfo: TIdHTTPRequestInfo;
      aResponseInfo: TIdHTTPResponseInfo); overload; override;
    constructor Create(aContext: TIdContext; aRequestInfo: TIdHTTPRequestInfo;
      aResponseInfo: TIdHTTPResponseInfo; NoExecute: Boolean); overload; override;
    procedure Upload;
    procedure Download;
  end;

implementation

uses
  uDecodePostRequest, System.IOUtils, Vcl.Forms;

{ TRPFiles }

constructor TRPFiles.Create(aContext: TIdContext; aRequestInfo: TIdHTTPRequestInfo; aResponseInfo:
  TIdHTTPResponseInfo);
begin
  inherited;
  Execute('Files');
end;

constructor TRPFiles.Create(aContext: TIdContext; aRequestInfo:
  TIdHTTPRequestInfo; aResponseInfo: TIdHTTPResponseInfo; NoExecute: Boolean);
begin
  inherited;
end;

procedure TRPFiles.Download;
var
  filepath: string;
begin
  filepath := ExtractFileDir(Application.ExeName) + StringReplace(RequestInfo.URI, '/', '\', [rfReplaceAll]);
  if TFile.Exists(filepath) then
  begin
    ResponseInfo.SmartServeFile(Context, RequestInfo, filepath);
    FResponses.OK();
  end;
end;

procedure TRPFiles.Upload;
var
  json: ISuperobject;
begin
  json := SO;
  json.S['relWebFilePath'] := RelWebFileDir;
  FResponses.OkWithJson(json.AsJSon(false, false));
end;

end.

