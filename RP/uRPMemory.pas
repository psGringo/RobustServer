unit uRPMemory;
{< Request processing memory}

interface

uses
  System.SysUtils, System.Classes, IdContext, IdCustomHTTPServer, Winapi.PsAPI,
  Winapi.Windows, Math;

type
  TRPMemory = class
  public
    function CurrentProcessMemoryKB: Extended;
    function CurrentProcessMemoryPeakKB: Extended;
    procedure GetMemory(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
  end;

implementation

function TRPMemory.CurrentProcessMemoryKB: Extended;
var
  MemCounters: TProcessMemoryCounters;
begin
  Result := 0;
  MemCounters.cb := SizeOf(MemCounters);
  if GetProcessMemoryInfo(GetCurrentProcess, @MemCounters, SizeOf(MemCounters)) then
    Result := trunc(MemCounters.WorkingSetSize / 1024)
  else
    RaiseLastOSError;
end;

function TRPMemory.CurrentProcessMemoryPeakKB: Extended;
var
  MemCounters: TProcessMemoryCounters;
begin
  Result := 0;
  MemCounters.cb := SizeOf(MemCounters);
  if GetProcessMemoryInfo(GetCurrentProcess, @MemCounters, SizeOf(MemCounters)) then
    Result := trunc(MemCounters.PeakWorkingSetSize / 1024)
  else
    RaiseLastOSError;
end;

procedure TRPMemory.GetMemory(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
begin
//
end;

end.

