unit uAttributes;

interface

type
  THTTPAttributes = class(TCustomAttribute)
    FCommandType: string;
    constructor Create(aCommandType: string); overload;
    property CommandType: string read FCommandType;
  end;
implementation

{ THTTPAttributes }
constructor THTTPAttributes.Create(aCommandType: string);
begin
  FCommandType := aCommandType;
end;

end.
