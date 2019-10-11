unit uClientRequestExamples;

interface

type
  TClientExamples = class
  private
    FRequest: string;
    FPort: string;
    procedure SetPort(const Value: string);
    procedure SetRequest(const Value: string);
  published
    procedure Post;
    constructor Create(aRequest, aPort :string);
    property Port :string read FPort write SetPort;
    property Request: string read FRequest write SetRequest;
  end;

implementation

uses
  uSmartPointer, IdHTTP, System.Classes, IdMultipartFormData, superobject,uMain;

{ TClientRequestExamples }

constructor TClientExamples.Create(aRequest, aPort: string);
begin
  FPort := aPort;
  FRequest := aRequest;
end;

procedure TClientExamples.Post;
var
  client: ISmartPointer<TIdHTTP>;
  s : string;
  postData : ISmartPointer<TIdMultiPartFormDataStream>;
  fileName: string;
  jo:ISuperobject;
  ss: ISmartPointer<TStringStream>;
  r: string;
begin
  jo := SO;
  jo.S['param1'] := '1234';
  jo.S['param2'] := '12345';
  client := TSmartPointer<TIdHTTP>.Create();
  ss := TSmartPointer<TStringStream>.Create();
  s := jo.AsJSon(false, false);
  ss.Write(Pointer(s)^, length(s));
  client.Request.ContentType := 'application/json';
  client.Request.ContentEncoding := 'utf-8';
  r := client.Post('http://localhost:' + FPort + '/' + FRequest, ss); //
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

