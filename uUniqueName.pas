unit uUniqueName;
{< this unit contains methods that will Create Unique Name}

interface

uses
  System.SysUtils, System.Classes, vcl.dialogs, System.RegularExpressions, StrUtils, uCommon, System.IOUtils, Vcl.Forms, uPSClasses;

type
  TUniqueName = class(TDataModule)
  private
    function GetNumberInBracketsFromTheEnd(AFileName: string): string;
    function GetSubStringWithoutLastBracketsInTheEnd(ASomeString, AValueInBrackets: string): string;
    function IsValueInBracketsAtEndOfString(ASomeString, AValueInBrackets: string): Boolean;
    function GetStringWithoutExtension(AFileName: string; var ext: string): string;
  public
    { Public declarations }
    function CreateUniqueNameAddingGUID(aFileName: string; aMaxOriginNameLength: Integer): string;
    {< CreateUniqueNameAddingGUID - all clear from the name. This is class function}
    function AddNumberOnTheEnd(ANameWithNumberOnTheEnd: string): string;
    function CreateUniqueNameAddingNumber(ANamesToCompare: TStringList; ANameThatShouldBeUnique: string): string; overload;
    function CreateUniqueNameAddingNumber(aAbsWinDir: string; ANameThatShouldBeUnique: string): string; overload;
    {< this method will Create Unique Name like SomeName(1),SomeName(2), Etc.}
    function IsFileNameUnique(ANameThatShouldBeUnique: string; AAllNamesToCompareSL: TStringList): boolean;
    {< this method will Create Unique Name like SomeName(1),SomeName(2), Etc.}
    function AddParamAndValueToName(aFileName, aParam, aValue: string): string;
    {<this will add Param=Value to someName }
    function GetParamValueFromFileName(FileName: string; const ParamName: string): string;
    {<this will get ParamValue from Name like Param=Value   }
  end;

implementation

uses
  System.Types;

{%CLASSGROUP 'Vcl.Controls.TControl'}

{ TCreateUniqueName }

{Creating New Unique Name with a rest of old name, using GUID}
function TUniqueName.CreateUniqueNameAddingGUID(aFileName: string; aMaxOriginNameLength: Integer): string;
var
  ext: string;
  splittedString: TArray<string>;
  someStringToChange: string;
  newguid: tguid;
  i: Integer;
  fileNameTemp: string;
begin
//Checks
  if aFileName = '' then
    Exit;
//if MaxOriginNameLength=0 then exit;  // if MaxOriginNameLength=0 will be only GUID as a result
//1--------- First of all we need to extract extension if it is
  splittedString := aFileName.Split(['.']);
    //we suppose that extensions are symbols after last '.', so...
    // if FileName has extension like 'SomeFileName.exe'
  if Length(splittedString) > 0 //1 and more, for example somename.ext [somename,ext]
    then
  begin
    ext := splittedString[High(splittedString)];
    //Lets join everything except extension
    for i := Low(splittedString) to High(splittedString) - 1 do
    begin
      if i = 0 then
        someStringToChange := someStringToChange + splittedString[i]
      else
        someStringToChange := someStringToChange + '.' + splittedString[i];
    end;
         //Cutting name up to the MaxOriginNameLength
    if Length(someStringToChange) > aMaxOriginNameLength then
      someStringToChange := someStringToChange.Substring(0, aMaxOriginNameLength);
      //Adding GUID
    Createguid(newguid);
    someStringToChange := someStringToChange + newguid.ToString;
      // Joining Extension
    someStringToChange := someStringToChange + '.' + ext;
    Result := someStringToChange;
  end
  else
     // if FileName without Extension like 'SomeFileName'
if Length(splittedString) = 0 then
  begin
    fileNameTemp := aFileName;
      //Cutting name up to the MaxOriginNameLength
    if Length(fileNameTemp) > aMaxOriginNameLength then
      fileNameTemp := fileNameTemp.Substring(0, aMaxOriginNameLength);
      //Adding GUID
    Createguid(newguid);
    fileNameTemp := fileNameTemp + newguid.ToString;
    Result := fileNameTemp;
  end;
//ShowMessage(Result);
end;

function TUniqueName.CreateUniqueNameAddingNumber(aAbsWinDir: string; ANameThatShouldBeUnique: string): string;
var
  files: ISP<TStringList>;
  a: TStringDynArray;
  i: Integer;
begin
  // getting files
  files := TSP<TStringList>.Create();
  a := TDirectory.GetFiles(aAbsWinDir);
  for i := Low(a) to High(a) do
    files.add(ExtractFileName(a[i]));
  // Creating Unique Name
  Result := ANameThatShouldBeUnique;
  if files.IndexOf(ANameThatShouldBeUnique) = -1 then
  begin
    Result := ANameThatShouldBeUnique; // Already Unique
    Exit;
  end
  else
    repeat
      Result := AddNumberOnTheEnd(Result);
    until files.IndexOf(Result) = -1;
end;

function TUniqueName.CreateUniqueNameAddingNumber(ANamesToCompare: TStringList; ANameThatShouldBeUnique: string): string;
begin
  Result := ANameThatShouldBeUnique;
  if ANamesToCompare.IndexOf(ANameThatShouldBeUnique) = -1 then
  begin
    Result := ANameThatShouldBeUnique; // Already Unique
    Exit;
  end
  else
    repeat
      Result := AddNumberOnTheEnd(Result);
    until ANamesToCompare.IndexOf(Result) = -1;
end;

function TUniqueName.AddNumberOnTheEnd(ANameWithNumberOnTheEnd: string): string;
var
  NumberInTheEnd: Integer;
  StringWithoutExtension: string;
  Extension: string;
  StringWithoutBracketsInTheEnd: string;
begin
// Check of Uniquiness
  StringWithoutExtension := GetStringWithoutExtension(ANameWithNumberOnTheEnd, Extension);
  if GetNumberInBracketsFromTheEnd(ANameWithNumberOnTheEnd) = '' then
  begin
    Result := StringWithoutExtension + '(1)'; // adding first number
    if Extension <> '' then
      Result := Result + '.' + Extension;
  end
  else
  begin
    NumberInTheEnd := GetNumberInBracketsFromTheEnd(StringWithoutExtension).ToInteger;
    if IsValueInBracketsAtEndOfString(StringWithoutExtension, NumberInTheEnd.ToString()) then
    begin
      StringWithoutBracketsInTheEnd := GetSubStringWithoutLastBracketsInTheEnd(StringWithoutExtension, NumberInTheEnd.ToString());
      NumberInTheEnd := NumberInTheEnd + 1;
      Result := StringWithoutBracketsInTheEnd + '(' + NumberInTheEnd.ToString() + ')';
    end
    else
    begin
      Result := ANameWithNumberOnTheEnd + '(1)'; // adding first number
    end;
    if Extension <> '' then
      Result := Result + '.' + Extension;
  end;
end;

function TUniqueName.GetStringWithoutExtension(AFileName: string; var ext: string): string;
var
  SplittedString: TArray<string>;
  i: Integer;
begin
  SplittedString := AFileName.Split(['.']);
      // if some Extension is...
  if High(SplittedString) >= 1 then
  begin
        //Gather all splitted elements except extension
    Result := '';
    for i := 0 to High(SplittedString) - 1 do
    begin
      Result := Result + SplittedString[i];
    end;
          // Remembering Extension;
    ext := SplittedString[High(SplittedString)];
  end
  else
  begin
    Result := AFileName;
    ext := '';
  end;
end;

function TUniqueName.GetNumberInBracketsFromTheEnd(AFileName: string): string;
var
  regEx: TRegEx;
  m: TMatchCollection;
  numberInBrackets: string;
  regEx2: TRegEx;
  m2: TMatchCollection;
begin
  Result := '';
  regEx := TRegEx.Create('\([\d]+\)'); // Extracting (1) from SomeFile(1) - will receive (1)
  m := regEx.Matches(AFileName);
  if m.Count > 0 then
  begin
    numberInBrackets := m.Item[m.Count - 1].Value; // Extracting Last One
  end;
  regEx2 := TRegEx.Create('[\d]+'); // Extracting 1 from  (1)
  m2 := regEx2.Matches(numberInBrackets);
  if m2.Count > 0 then
  begin
    Result := m2.Item[m.Count - 1].Value; // Extracting Last One
  end;
end;

function TUniqueName.GetSubStringWithoutLastBracketsInTheEnd(ASomeString: string; AValueInBrackets: string): string;
begin
//
  if (ASomeString.Length > 0) and (AValueInBrackets.Length > 0) and (ASomeString.Length - AValueInBrackets.Length >= 3) // 3 means (1) for example
    then
    Result := ASomeString.Substring(0, ASomeString.Length - AValueInBrackets.Length - 2); // -2 means brackets around value for ex. (1)
end;

function TUniqueName.IsValueInBracketsAtEndOfString(ASomeString: string; AValueInBrackets: string): Boolean;
var
  valueInBrackets: string;
  endOfString: string;
begin
  Result := false;
  if ASomeString.Length >= valueInBrackets.Length then
  begin
    valueInBrackets := '(' + AValueInBrackets + ')';
    endOfString := ASomeString.Substring(ASomeString.Length - valueInBrackets.Length);
    if endOfString = valueInBrackets then
      Result := True;
  end;
end;

// {Adding Params to FileName, so FileName.exe will be FileName{Param=Value}.exe }
function TUniqueName.AddParamAndValueToName(aFileName: string; aParam: string; aValue: string): string;
var
  ext: string;
  splittedString: TArray<string>;
  SomeStringToChange: string;
  i: Integer;
  FileNameTemp: string;
begin
//Checks
  if aFileName = '' then
    Exit;
//1--------- First of all we need to extract extension if it is
  splittedString := aFileName.Split(['.']);
    //we suppose that extensions are symbols after last '.', so...
    // if FileName has extension like 'SomeFileName.exe'
  if Length(splittedString) > 1 //2 and more, for example somename.ext [somename,ext]
    then
  begin
    ext := splittedString[High(splittedString)];
//ShowMessage(Extension); // for test
//2----------Now lets change previous massive Element if it is
    SomeStringToChange := splittedString[High(splittedString) - 1];
      //Adding Param And Value
    SomeStringToChange := SomeStringToChange + '{' + aParam + '=' + aValue + '}';
    splittedString[High(splittedString) - 1] := SomeStringToChange;
//3-------Now our name is Unique we can join it back
    Result := '';
    for i := Low(splittedString) to High(splittedString) - 1 do
      Result := Result + splittedString[i] + '.';
    //At last adding Extension
    Result := Result + ext;
  end
  else
  // if FileName without Extension like 'SomeFileName'
if Length(splittedString) = 1 then
  begin
    FileNameTemp := aFileName;
    FileNameTemp := FileNameTemp + '{' + aParam + '=' + aValue + '}';
    Result := FileNameTemp;
  end;
end;

{Get Param Value from FileName}
function TUniqueName.GetParamValueFromFileName(FileName: string; const ParamName: string): string;
var
  m: TMatchCollection;
  m2: TMatchCollection;
  m3: TMatchCollection;
begin
  Result := '';
  m := TRegEx.Matches(FileName, '{' + ParamName + '=[\w\d]*}'); //chunkNumber=[\w\d]*[\d]\b //chunkNumber=[\w]*[\d]\b
  if m.Count > 0 then
    m2 := TRegEx.Matches(m.Item[m.Count - 1].Value, '=[\w\d]*');
  if m2.Count > 0 then
    m3 := TRegEx.Matches(m2.Item[m2.Count - 1].Value, '[\w\d]*');
  if m3.Count > 0 then
    Result := m3.Item[m3.Count - 1].Value;
end;

function TUniqueName.IsFileNameUnique(ANameThatShouldBeUnique: string; AAllNamesToCompareSL: TStringList): boolean;
begin
  Result := false;
  if AAllNamesToCompareSL.IndexOf(ANameThatShouldBeUnique) = -1 then
    Result := true;
end;

end.

