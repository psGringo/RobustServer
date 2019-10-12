unit uClientExamples;

interface

type
  TClientExamples = class
  private
    FRequest: string;
    FPort: string;
    procedure SetPort(const Value: string);
    procedure SetRequest(const Value: string);

  public
    procedure PostJson;
    procedure PostSendFile(aAbsWinFilePath: string);
    procedure PostFormURLEncoded();
    procedure SendEmail();

    constructor Create(aRequest, aPort :string); overload;
    property Port :string read FPort write SetPort;
    property Request: string read FRequest write SetRequest;
  end;

implementation

uses
  idHTTP, System.Classes, IdMultipartFormData, superobject,uMain,
  System.SysUtils, System.NetEncoding, uCommon, Vcl.Dialogs, uPSClasses;

{ TClientRequestExamples }

constructor TClientExamples.Create(aRequest, aPort: string);
begin
  FPort := aPort;
  FRequest := aRequest;
end;

procedure TClientExamples.PostJson;
var
  client: ISP<TIdHTTP>;
  jo:ISuperobject;
  ss: ISP<TStringStream>;
  r: string;
begin
//  jo := SO;
//  jo.S['param1'] := '1234';
//  jo.S['param2'] := '12345';
//  client := TSP<TIdHTTP>.Create();
//  ss := TSP<TStringStream>.Create();
//  ss.WriteString(jo.AsJSon(false, false));
//  client.Request.ContentType := 'application/json';
//  client.Request.ContentEncoding := 'utf-8';
//  r := client.Post('http://localhost:' + FPort + '/' + 'Tests/PostJson', ss); //
//  TMain.GetInstance.mAnswer.Lines.Add(r);
end;

procedure TClientExamples.PostSendFile(aAbsWinFilePath: string);
var
  client: ISP<TIdHTTP>;
  ss: ISP<TStringStream>;
  postData: ISP<TIdMultiPartFormDataStream>;
  fileName: string;
begin
//  fileName := ExtractFileName(aAbsWinFilePath);
//  Assert(fileName <> '', 'filename is empty');
//  client := TSP<TIdHTTP>.Create();
//  ss := TSP<TStringStream>.Create();
//  postData := TSP<TIdMultiPartFormDataStream>.Create();
//  client.Request.Referer := 'http://localhost:' + FPort + '/Files/Send';
//  client.Request.ContentType := 'multipart/form-data';
//  client.Request.RawHeaders.AddValue('AuthToken', System.NetEncoding.TNetEncoding.URL.Encode('evjTI82N'));
//  postData.AddFormField('filename', System.NetEncoding.TNetEncoding.URL.Encode(fileName));
//  postData.AddFormField('isOverwrite', System.NetEncoding.TNetEncoding.URL.Encode('false'));
//  postData.AddFile('attach', aAbsWinFilePath, 'application/x-rar-compressed');
//  client.POST('http://localhost:' + FPort + '/Files/Send', postData, ss); //
//  TMain.GetInstance.mAnswer.Lines.Add(ss.DataString);
end;

procedure TClientExamples.PostFormURLEncoded();
var
  client: ISP<TIdHTTP>;
  sl: ISP<TStringList>;
  r: string;
begin
//  client := TSP<TIdHTTP>.Create();
//  sl := TSP<TStringList>.Create();
//
//  sl.Add('param1='+System.NetEncoding.TNetEncoding.URL.Encode('–усскийѕараметр1'));
//  sl.Add('param2='+System.NetEncoding.TNetEncoding.URL.Encode('–усскийѕараметр2'));
//
//  client.Request.Referer := 'http://localhost:' + FPort + '/Tests/URLEncoded';
//  client.Request.ContentType := 'application/x-www-form-urlencoded';
//  client.Request.RawHeaders.AddValue('AuthToken', 'evjTI82N');
//  r := client.POST('http://localhost:' + FPort + '/Tests/URLEncoded', sl);
//  TMain.GetInstance.mAnswer.Lines.Add(r);
end;

procedure TClientExamples.SendEmail();
var y: ISP<TEmail>;
begin
  y := TSP<TEmail>.Create();
  y.Send('smtp.yandex.ru',465, 'subject', 'content', 'panteleevstas@gmail.com','test@yandex.ru','xxx','testUser');
end;

procedure TClientExamples.SetPort(const Value: string);
begin
  FPort := Value;
end;

procedure TClientExamples.SetRequest(const Value: string);
begin
  FRequest := Value;
end;

end.

