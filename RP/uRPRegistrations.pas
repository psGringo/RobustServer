unit uRPRegistrations;

interface

uses
  uPSClasses, System.Classes, Spring.Collections, uRP, Spring, uRSConst;

type
  TRPRegistrations = class
  private
    FRPClasses: IDictionary<string, TRPClass>;
  public
    constructor Create();
    procedure Assign(aSource: TRPRegistrations);
    procedure RegisterRPClass(aClass: TRPClass; aAlias: string = '');
    property RPClasses: IDictionary<string, TRPClass> read FRPClasses;
  end;

var
  GlobalRPRegistrations: TRPRegistrations;

implementation

uses
  System.Generics.Collections;

{ TRPRegistrations }

procedure TRPRegistrations.Assign(aSource: TRPRegistrations);
var
  paramValidator: ISP<TParamValidator>;
begin
  paramValidator := TSP<TParamValidator>.Create();
  paramValidator.EnsureNotNull(aSource);

  aSource.RPClasses.ForEach(
    procedure(const aPair: TPair<string, TRPClass>)
    begin
      FRPClasses.Add(aPair.Key, aPair.Value);
    end);
end;

constructor TRPRegistrations.Create();
begin
  FRPClasses := TCollections.CreateDictionary<string, TRPClass>;
end;

procedure TRPRegistrations.RegisterRPClass(aClass: TRPClass; aAlias: string = '');
begin
  if aAlias <> '' then
    FRPClasses.Add(aAlias, aClass)
  else
    FRPClasses.Add(aClass.ClassName, aClass);
end;

end.

