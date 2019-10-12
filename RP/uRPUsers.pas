unit uRPUsers;
{< Request processing users}

interface

uses
  System.SysUtils, System.Classes, IdCustomHTTPServer, superobject,
  uCommon, uDB, uRP, IdContext;

type
  TRPUsers = class(TRP)
  public
    constructor Create(aContext: TIdContext; aRequestInfo: TIdHTTPRequestInfo; aResponseInfo: TIdHTTPResponseInfo); overload; override;
    procedure Create(); overload; override;
    procedure Delete(); override;
    procedure Update(); override;
    procedure GetInfo(); override;
  end;

implementation

{ TRPUsers }

procedure TRPUsers.Create();
begin
  // insert your code here...
  Responses.OK();
end;

constructor TRPUsers.Create(aContext: TIdContext; aRequestInfo: TIdHTTPRequestInfo; aResponseInfo: TIdHTTPResponseInfo);
begin
  inherited;
  //FClassAlias := ''; // Assign it here or below
  Execute('Users'); // this moment we know klass Alias, so we can fire proper method
end;

procedure TRPUsers.Delete;
begin
  // insert your code here...
Responses.OK();
end;

procedure TRPUsers.GetInfo;
var id :string;
    jsonUser : ISuperobject;
begin
  // insert your code here...
  id := RequestInfo.Params.Values['password'];
  // getInfo by id... ... for ex in db
  jsonUser := SO();
  jsonUser.S['name'] := 'Bill Gates';
  Responses.OkWithJson(jsonUser.AsJSon(false, false));
end;

procedure TRPUsers.Update;
begin
  // insert your code here...
  Responses.OK();
end;

end.


