unit uRP;
{< Request processing base class, derive from this all your logical classes}

interface

uses
  System.SysUtils, System.Classes, IdCustomHTTPServer, superobject, uCommon, uDB, System.Generics.Collections, System.Rtti, IdContext, uAttributes, System.Json, System.IOUtils,
  uRSService;

type
  TProcedure = reference to procedure;

  TRP = class
  private
    FContext: TIdContext;
    FResponseInfo: TIdHTTPResponseInfo;
    FRequestInfo: TIdHTTPRequestInfo;
    FDB: ISP<TDB>;
    FRelWebFileDir: string;
    function ConvertUtf8ToAnsi(const Source: string): string;
    //function RttiMethodInvokeEx(const MethodName: string; RttiType: TRttiType; Instance: TValue; const Args: array of TValue): TValue; // for overloaded methods
  protected
    FClassAlias: string;
    FParams: ISP<TStringList>; // << params collected in one place for GET, POST Request
    FResponses: ISP<TResponses>;
  public
    constructor Create(aContext: TIdContext; aRequestInfo: TIdHTTPRequestInfo; aResponseInfo: TIdHTTPResponseInfo); overload; virtual;
    constructor Create(aContext: TIdContext; aRequestInfo: TIdHTTPRequestInfo; aResponseInfo: TIdHTTPResponseInfo; NoExecute: Boolean); overload; virtual;
    procedure Create(); overload; virtual;
    procedure Delete(); virtual;
    procedure Update(); virtual;
    procedure GetInfo(); virtual;
    procedure Execute(aClassAlias: string);
    property Context: TIdContext read FContext;
    property RequestInfo: TIdHTTPRequestInfo read FRequestInfo write FRequestInfo;
    property ResponseInfo: TIdHTTPResponseInfo read FResponseInfo write FResponseInfo;
    property DB: ISP<TDB> read FDB;
    property Responses: ISP<TResponses> read FResponses;
    property Params: ISP<TStringList> read FParams;
    property RelWebFileDir: string read FRelWebFileDir write FRelWebFileDir;
  end;

  TRPClass = class of TRP;

implementation

uses
  System.TypInfo, uDecodePostRequest, uRPTests, Winapi.Windows;

{ TRP }
procedure TRP.Create;
begin
    // insert your code here...
  FDB := TSP<TDB>.Create(TDB.Create(nil));
  FResponses.OK();
end;

function TRP.ConvertUtf8ToAnsi(const Source: string): string;
var
  Iterator, SourceLength, FChar, NChar: Integer;
begin
  Result := '';
  Iterator := 0;
  SourceLength := Length(Source);
  while Iterator < SourceLength do
  begin
    Inc(Iterator);
    FChar := Ord(Source[Iterator]);
    if FChar >= $80 then
    begin
      Inc(Iterator);
      if Iterator > SourceLength then
        break;
      FChar := FChar and $3F;
      if (FChar and $20) <> 0 then
      begin
        FChar := FChar and $1F;
        NChar := Ord(Source[Iterator]);
        if (NChar and $C0) <> $80 then
          break;
        FChar := (FChar shl 6) or (NChar and $3F);
        Inc(Iterator);
        if Iterator > SourceLength then
          break;
      end;
      NChar := Ord(Source[Iterator]);
      if (NChar and $C0) <> $80 then
        break;
      Result := Result + WideChar((FChar shl 6) or (NChar and $3F));
    end
    else
      Result := Result + WideChar(FChar);
  end;
end;

constructor TRP.Create(aContext: TIdContext; aRequestInfo: TIdHTTPRequestInfo; aResponseInfo: TIdHTTPResponseInfo);
var
  c: ISP<TCommon>;
  d: ISP<TDecodePostRequest>;
begin
  c := TSP<TCommon>.Create();
  c.IsNotNull(aContext);
  c.IsNotNull(aResponseInfo);
  c.IsNotNull(aRequestInfo);

  FResponses := TSP<TResponses>.Create(TResponses.Create(aRequestInfo, aResponseInfo));
  FContext := aContext;
  FResponseInfo := aResponseInfo;
  FRequestInfo := aRequestInfo;
  FDB := TSP<TDB>.Create(TDB.Create(nil));

  FClassAlias := '';
  FParams := TSP<TStringList>.Create();
  aRequestInfo.Params.Text := ConvertUtf8ToAnsi(aRequestInfo.Params.Text);
  //reading params
  case aRequestInfo.CommandType of
    hcGET:
      FParams.Assign(aRequestInfo.Params);
    hcPOST:
      begin
        d := TSP<TDecodePostRequest>.Create();
        d.Execute(aContext, aRequestInfo, aResponseInfo);
        FParams.Text := d.Params.Text;
        FRelWebFileDir := d.RelWebFileDir;
    // might me continued with PUT, DELETE and other request types...
      end;
  end;
end;

constructor TRP.Create(aContext: TIdContext; aRequestInfo: TIdHTTPRequestInfo; aResponseInfo: TIdHTTPResponseInfo; NoExecute: Boolean);
begin
  FResponses := TSP<TResponses>.Create(TResponses.Create(aRequestInfo, aResponseInfo));
  FDB := TSP<TDB>.Create(TDB.Create(nil));
  FRequestInfo := aRequestInfo;
  FResponseInfo := aResponseInfo;
  FContext := aContext;
end;

procedure TRP.Delete;
begin
  // insert your code here...
  FResponses.OK();
end;

procedure TRP.Execute(aClassAlias: string);
var
  ctx: TRttiContext;
  t: TRttiType;
  m: TRttiMethod;
  classAlias: TRttiField;
  classAliasValue: TValue;
  className: string;
  args: array of TValue;
  attribs: TArray<TCustomAttribute>;
  a: TCustomAttribute;
  methodParams: TArray<System.Rtti.TRttiParameter>;
  iCounterPerSec: TLargeInteger;
  C1: Int64;

  procedure CollectArgs();
  var
    i: int;
  begin
    SetLength(args, 0);
    for i := 0 to FParams.Count - 1 do
    begin
      SetLength(args, Length(args) + 1);
      args[i] := FParams.Values[FParams.Names[i]];
    end;
  end;

begin
  QueryPerformanceFrequency(iCounterPerSec);
  QueryPerformanceCounter(C1);

  FResponses.ICounterPerSec := iCounterPerSec;
  FResponses.TimeCounterStart := C1;

  FClassAlias := aClassAlias;
  CollectArgs();
  ctx := TRttiContext.Create();
  try
    t := ctx.GetType(Self.ClassType);
    classAlias := t.GetField('FClassAlias');
    // looking for className
    classAliasValue := classAlias.GetValue(Self);
    if (classAliasValue.AsString) <> '' then
      className := classAliasValue.AsString
    else
      className := Self.ClassName;

    for m in t.GetMethods do
      if (m.MethodKind <> mkConstructor) and (m.MethodKind <> mkDestructor) //
        and ((FRequestInfo.URI = '/' + className + '/' + m.Name) //
        or (FRequestInfo.URI = '/' + className + '/' + m.Name + '()')) then
      begin
        if (Pos('application/json', LowerCase(RequestInfo.ContentType)) > 0) or ((Pos('multipart/form-data', LowerCase(FRequestInfo.ContentType)) > 0) and (Pos('boundary',
          LowerCase(FRequestInfo.ContentType)) > 0) and (FRequestInfo.URI = '/Files/Upload')) then
        begin
          // do nothing, pass Fparams.Text which is json here, to invoked method
          SetLength(args, 0);
          m.Invoke(Self, args);
        end
        else
        begin
          methodParams := m.GetParameters;
          if Length(args) <> Length(methodParams) then
            Continue;

          attribs := m.GetAttributes;
          if Length(attribs) > 0 then
          begin
            for a in m.GetAttributes() do
            begin
              // if attribs HttpGet or HttpPost
              if (THTTPAttributes(a).CommandType = 'HttpGet') or (THTTPAttributes(a).CommandType = 'HttpPost') then
              begin
                if (THTTPAttributes(a).CommandType = 'HttpGet') and (FRequestInfo.CommandType = hcGET) then
                  m.Invoke(Self, args)
                else if (THTTPAttributes(a).CommandType = 'HttpPost') and (FRequestInfo.CommandType = hcPOST) then
                  m.Invoke(Self, args)
              end;
            end
          end
          else
            m.Invoke(Self, args);
        end;
        break;
      end;
    FResponseInfo.ResponseNo := 404;
  finally
    ctx.Free();
  end;
end;

procedure TRP.GetInfo;
begin

  // insert your code here...
  FResponses.OK();
end;

procedure TRP.Update;
begin
  // insert your code here...
  FResponses.OK();
end;
{ for overloaded methods
function TRP.RttiMethodInvokeEx(const MethodName:string; RttiType : TRttiType; Instance: TValue; const Args: array of TValue): TValue;
var
 Found   : Boolean;
 LMethod : TRttiMethod;
 LIndex  : Integer;
 LParams : TArray<TRttiParameter>;
begin
  Result:=nil;
  LMethod:=nil;
  Found:=False;
  for LMethod in RttiType.GetMethods do
   if SameText(LMethod.Name, MethodName) then
   begin
     LParams:=LMethod.GetParameters;
     if Length(Args)=Length(LParams) then
     begin
       Found:=True;
       for LIndex:=0 to Length(LParams)-1 do
       if LParams[LIndex].ParamType.Handle<>Args[LIndex].TypeInfo then
       begin
         Found:=False;
         Break;
       end;
     end;

     if Found then Break;
   end;

   if (LMethod<>nil) and Found then
     Result:=LMethod.Invoke(Instance, Args)
   else
     raise Exception.CreateFmt('method %s not found',[MethodName]);
end;
}

end.

