{ *************************************************************************** }
{                                                                             }
{                                                                             }
{                                                                             }
{ ������ LDSLogger - ������ ��� ������� �����                                 }
{ (c) 2007-2010 ������� ������� ���������                                     }
{ ��������� ����������: 09.12.2010                                            }
{ ����� �����: http://matrix.kladovka.net.ru/                                 }
{ e-mail: loginov_d@inbox.ru                                                  }
{                                                                             }
{ *************************************************************************** }

{��������� �������� ���������������� ������������ ��������� ������
 � ������������ ����������� LOG-����� ��� �� �������, ��� � �� �������, � �
 �������������� ������ �������������� ������ LOG-������. ������ � ����� ����
 ������� ����������� ���������, ��� ��������� ������������ ������������� ������
 ���������� � ��� ����������� ������������ � ��������. ������ �������� �������
 ������������� � ���������, ����� � ����� ������ ������� ���� ���� ����� ����
 ������ ������������ ������������ (� ��� ����� � ����������� �� ������).
 ��� ����������� � ������� ������������� ������� WaitAndCreateLogFileStream().
 ����� ������, ����������� ��� �������� �����, ��� ������ � ����, ��� ���������
 �����, ������� � ��� "%TEMP%\LDSLoggerErrorsWriter.log".
 � ������� �������� NotifyHandle ����� ���������������� Handle ����, � � ����
 ������ ����� ������ � ��� � ������� PostMessage ���� ����� ������� ���������
 LOGGER_NOTIFY_MESSAGE (�������� NotifyMessage ��������� ���������� ����� ���������).
 ������� ������ ���������, ������� ��������� ������ ��������� �������������� ��������
 ������ � ������� ������ GetStringListBufferText() � ���������� ��� ������ ���
 �� ������. ��������� ����� ��� ���� ������ �� ��������� �� 1024 ����� (���
 �������� ����� �������� � ������� �������� ListBufferMaxCount).
 ������ ��������� �������� ������ ���� � �������, ������� � ��� ID �������� �
 ������, ������� ������� � ������������ �������, ������� ��������� DefaultPrefix.
 ������ ��������� ��������� ���� ��������� ����� ������ ��������� � ��� �
 ������� �������� UsedLogTypes. ��� ������� ������� �� ����� � ��� �����������
 Enabled := False ���� UsedLogTypes := [].

 {�������� ���������
  20.05.2008
   - ��������� ��������� ��������� �������� ���������� UseResStr

  22.05.2008
   - ��������� ������� TranslateLoggerMessages()

  29.08.2008
   - ��������� �� ������ ������ ����� ����������, � � ��� ����� ��������
     ������ �������� ����������, ��� ������.
   - ��������������� ����� ������� Beep(). ��� �� ������ ��������, ���� ������������
     ��������� ������������ ���� ������� ReadOnly. ��� ���� ���������� �����
     ������� ���������. � ���� �� �� ����� ����������� ������� �������� �� ������.
   - ������������ ������� WaitAndCreateLogFileStream(). �������� ����� ���������
     �������� ����� ������ ���������� 10 �� ������ 20 ��, � ���������� ��� ������
     ������ � ������, ���� ���� ������������� ����� ������ ���������. ��� ������
     �� ������� ����� ����������� ����������� ���������� ��� ������ ��������.

  30.08.2008
   - ���������� �������� �������� ����� ���� �� �������. ��������� ��������
     DateTimeTrimInterval, ������������, � ������� ������ ������� ������ ������
     ��������� � �����. � ����������� �� ClearOldLogData ����������� ����
     ������� �����, ���� �������������� �����.
   - ��������� Lock � UnLock ���������� � ������ Public. ��������� ����� ��
     ������ � ����� ������ ��������� ����������� ��������� ���� �� ��������
     �� ����������� �������������� ������� � �����
   - ������� WaitAndCreateLogFileStream �������� � ������ Interface.
     ����� ������ ������ ������ ������� ��������� � Matrix32.

  31.08.2008
   - ������������ ������� ProcessFile(). ���������� �� TMemoryStream. ������
     ��� ������� ������ ����� �������� �� �����. ������������ ����������� ��
     ������ IDE-���������� � FAT-32. ��������� ����� �������� 1 ����� ��������
     0 ��, 5 ����� - 16 ��, 10 ����� - 47 ��, 20 ����� - 1047 ��, 50 ����� - 2500 ��.
     (� ���������������� ������ ����� ��������� �� �����, �.�. ������ 50 �����
     ������������� ���� 70 ����� � �.�.)

  22.08.2009
   - ��������� ��������� ��������� �������� ���������� LDSLoggerMutexExclusive.
     ������ ������������� ������ � ��� ����� ����� ����������, ���������� ���
     ������� �������� ��������. ������ � ����� ������� ������ ������ ����������
     ���������� ����� ����� ������ � ���. ��� ������� ������� ���������� ���
     ������ ������� ������� ��� ������� ������ � ��� ���������� ������
     �������� ������� "�������" (�������� � �������). ��������� � Windows XP.
   - ��������� ���������� LDSCanRaiseMutexError. ��� �� ��������� = False, �.�.
     ���������� �� ������������ ��� ������ �������� ��������.

   21.11.2009
    - ������ ����������� ��� ������ � Unicode-�������� Delphi (������������� �� D2010).
      ��� ����� �������� ������ ��������� ����������� �����-���� � ����/���� ������.
      ������ ������ ����� �� ��������� (������ ������� � ����������� ��������� Ansi).
      ��� ����������� ������ � ��� ����� Unicode ���������� ������ ��������� � �������
      CheckLogTime, ProcessFile, LogStr (������� Fs.Write).

   28.09.2010
     - ���������� ������ � ������ ProcessFile. ������� ������ ����� ��� ������� �����
       ��� �������� � ��������� ���������.

   09.12.2010
     - ������ �������� ���������� ������� � ��������� �������������� � ������� CharInSet
 }


{����������, � ����� ���� ������� ��������� ���������: � resourcestring ��� String.
 ������ ������ ��������� ������������ ��� ����������� ���������� ��������
 Translation Manager. ������ ������ ��������� ��������� ����������� ����� ���������,
 ��������, � ������� ��������� ���������� LangReader.pas}
{.$DEFINE UseResStr}

{����������, ������ �� ��������� ������ "�������" ���� ������������ (�.�. ��������
 ������ ��� ����� ������� ������), ���� � ��� ����� �������� ����������, ����������
 ������������ ��� ������� �������� �������� �������������. �� ��������� ���������
 ���������, �.�. ������� ��������� � ����� �������. ���� ���� ������������ �������
 �� �����-�� �������� ������������ ��������� ������ "�������" � ����� ������, ��
 �������� ��������� LDSLoggerMutexExclusive (����� � ������ �������) }
{.$DEFINE LDSLoggerMutexExclusive}

unit LDSLogger;

interface

uses
  Windows, Messages, SysUtils, Classes, SyncObjs, DateUtils, IniFiles;

{��������� D2009PLUS ����������, ��� ������� ������ Delphi: 2009 ��� ����}
{$IF RTLVersion >= 20.00}
   {$DEFINE D2009PLUS}
{$IFEND}

type
  TLDSLogType = (tlpNone, tlpInformation, tlpError, tlpCriticalError, tlpWarning, tlpEvent, tlpDebug, tlpOther);

  TLDSLogTypes = set of TLDSLogType;

  {TODO : ���� �� ���� ��� ������ � ����� "string" ��� Delphi2009.}

  TLDSLogger = class(TObject)
  private
    FCritSect: TCriticalSection;
    FBufferCS: TCriticalSection;
    FMutexHandle: THandle;
    FFileName: string;
    FMaxFileSize: Int64;
    FClearOldLogData: Boolean;
    FEnabled: Boolean;
    FDefaultPrefix: string;
    FCanWriteThreadID: Boolean;
    FCanWriteProcessID: Boolean;
    FDateTimeFormat: string;
    FCanWriteLogSymbols: Boolean;
    FCanWriteLogWords: Boolean;
    FUseMutex: Boolean;
    FMaxOldLogFileCount: Integer;
    FIsErrorWriter: Boolean;
    FUsedLogTypes: TLDSLogTypes;
    FStringListBuffer: TStringList;
    FNotifyHandle: THandle;
    FNotifyMessage: Cardinal;
    FListBufferMaxCount: Integer;
    FDateTimeTrimInterval: TDateTime;
    FLastCheckTime: TDateTime;

    {���������� ��� ��������}
    function GenerateMutexName: string;
    procedure SetFileName(Value: string);

    {��������� ��������� �����, ��������� � ����������� ���������� ��������}
    procedure ProcessFile(var fs: TFileStream);

    {������������ �������������� ������ ����}
    procedure RenameFiles;

    {������� �� ���� ������ ������. ���������� ����� �������� ������ 32768 ����}
    procedure CheckLogTime(var fs: TFileStream);
    procedure SetUseMutex(const Value: Boolean);
    procedure SetDateTimeFormat(const Value: string);
    procedure SetDefaultPrefix(const Value: string);
    procedure SetUsedLogTypes(const Value: TLDSLogTypes);
    procedure SetNotifyHandle(const Value: THandle);
    procedure SetNotifyMessage(const Value: Cardinal);
    procedure SetListBufferMaxCount(const Value: Integer);
    procedure SetDateTimeTrimInterval(const Value: TDateTime);
  public
    {�����������. AFileName ���������� ��� ���-�����. ���� ����������� ��� �����
     ��� ����, �� � �������� ���� ������������� ���� � ������������ �����. ���
     ����� ������������ ��� �������� ������������ ��������, � ������� ��������
     ����������� ����������, ����������� ��� ����������� ���������� ������ �
     ���� ��� ����� ����������� ������������ }
    constructor Create(AFileName: string);
    destructor Destroy; override;

    {��� LOG-�����. ��� ������������� ��������� ��� ����� ���������� ��� ��������.
     ��� ��������� ������ ����� ����� ������ ������� ����� ����������}
    property FileName: string read FFileName write SetFileName;

    {������������ ������ LOG-�����. ��� ���������� ������� ����� �� �����
     ������������ MaxFileSize ���������� ����� ������� ProcessFile.
     �� ��������� MaxFileSize = 1 �����.
     ��� ���������� �������� ������� ����� ���������� MaxFileSize=0}
    property MaxFileSize: Int64 read FMaxFileSize write FMaxFileSize;

    {���������� �� ����� ������ ������ ������ ��������� � �����. ������ ������
     ����� ������������� ������������. ������ ���� ����������� �� ������ ���, �
     ������ ����� �������� ������� LDSCheckTimeInterval. �� ���������
     DateTimeTrimInterval=0, �.�. ������� ���� �� ������� ���������.
     ��� ������� ���� ������ ����������� MaxFileSize}
    property DateTimeTrimInterval: TDateTime read FDateTimeTrimInterval write SetDateTimeTrimInterval;

    {������������ ���-�� ��������������� ���-������. ��� ��������������
     ������������ ���-����� ��� � ����� ����� ������������ ������ 000. ��� �����
     ������� ����� ����� ����������������� (�� ������ ������������� �� �������).
     ����� ���������� ��������������� ���-������ ��������� MaxOldLogFileCount,
     ������ ����� ���������}
    property MaxOldLogFileCount: Integer read FMaxOldLogFileCount write FMaxOldLogFileCount;

    {����������, ��� ����� ������ � ������, ���� ������ LOG-����� ��������
     MaxFileSize, ���� ��������� ����������� DateTimeTrimInterval.
     ���� ClearOldLogData=True, �� ������ ������ � ����� �����
     ������ �������. ���� ClearOldLogData=False, �� ����� ������ ����� LOG-����,
     � ������ LOG-���� ����� ������ ������������ (��������, ��� MyLogFile.log,
     � ������ MyLogFile.log000)}
    property ClearOldLogData: Boolean read FClearOldLogData write FClearOldLogData;

    {����������, ������� �� ������������ ������� ��� ������ �������� ������ �
     ����. �� ��������� UseMutex=True. ��� ������� ������ ��� ��������� ������� ��������}
    property UseMutex: Boolean read FUseMutex write SetUseMutex;

    {���������� ������ MsgText � LOG-����. ��� ���� �������������� ����������
     ��������� � ����������� �������, ���� �����������, � ���� ������������
     ����������, ����������� ������ �����, �� ���������� �������� ����� ���� �������
     ��������� ProcessFile() ��� CheckLogTime(). ���� ��������������� Handle ����
     (� ������� ��-�� NotifyHandle), �� �������� ������ ������������ � ������
     TStringList, ���� ���������� ��������� NotifyMessage � ������� PostMessage,
     ����� ���� � ������� ��������� ���� ����� ������� ����������� � �������
     ����� ����� ������ ������ GetStringListBufferText}
    procedure LogStr(MsgText: string = ''; LogType: TLDSLogType = tlpNone);
    procedure LogStrFmt(MsgText: string; Args: array of const; LogType: TLDSLogType = tlpNone);

    {��������� ������������ ������ ������ � LOG-����}
    property Enabled: Boolean read FEnabled write FEnabled;

    {���� ���������, ������� ������� ���������� � ���. ����� ��������� ������ �
     ��� �������� ���������, �������� ���:
       UsedLogTypes := UsedLogTypes - [tlpDebug, tlpOther]
     ����� ������ ��������� ������� ����:  UsedLogTypes := [] }
    property UsedLogTypes: TLDSLogTypes read FUsedLogTypes write SetUsedLogTypes;

    {���������� ����������� �������, � �������� ������ ���������� ���������
     ��������� � LOG-�����}
    property DefaultPrefix: string read FDefaultPrefix write SetDefaultPrefix;

    {����������, ������� �� ���������� � ��� ID �������� ������}
    property CanWriteThreadID: Boolean read FCanWriteThreadID write FCanWriteThreadID;

    {����������, ������� �� ���������� � ��� ID �������� ��������}
    property CanWriteProcessID: Boolean read FCanWriteProcessID write FCanWriteProcessID;

    {���������� ������ ������������� ������� � LOG-�����. �� ��������� ������������
     ������������� ������ "dd/mm/yyyy hh:nn:ss.zzz". ��� �������� ����� �����
     ��������� ������ ���� � �����������, ����� ������� "dd/mm hh:nn:ss". �� �����
     ��� ������ log-����� ������������ ������������ ��������� �������� ������,
     �.�. �� ������� ������ ������ ����������� �������� ����������� ���� �� �������,
     � ��� ������������ ��� ������ ��������� ������������ �������. �������������
     ������ �������� ������� (d, m, h, n, s, z) ������������ (dd, mm, hh, nn, ss, zzz),
     ����� ����� ���� �������� � �������� ��� � ����. ����� ����, ���� ����� �������
     ����� ���������, �� ������ �������� ����� ������ ��� ����, �.�. ����� ������
     ������� �� ��������}
    property DateTimeFormat: string read FDateTimeFormat write SetDateTimeFormat;

    {����������, ������� �� � ��� ������ �������-��������� ���������}
    property CanWriteLogSymbols: Boolean read FCanWriteLogSymbols write FCanWriteLogSymbols;

    {����������, ������� �� � ��� ������ �����-��������� ���������}
    property CanWriteLogWords: Boolean read FCanWriteLogWords write FCanWriteLogWords;

    {������� ������ TStringList}
    procedure ClearListBuffer;

    {���������� ����, �������� ��� ������ ������ � ��� ����� ���������� ���������
     PostMessage � ���������� NotifyMessage. ���� NotifyHandle=0 (�� ���������),
     �� ��������� �� ����� ���������� ������, � ������ StringListBuffer
     �������������� �� �����}
    property NotifyHandle: THandle read FNotifyHandle write SetNotifyHandle;

    {���������, ������� ���������� ���� NotifyHandle. ����, ���������� ������
     ��������� � ������� ���������, ����� ������� �����, ����������� � �������
     ����� ������ ������ GetStringListBufferText()}
    property NotifyMessage: Cardinal read FNotifyMessage write SetNotifyMessage;

    {���������� �����, ����������� � ��������� ������� � ������� ������}
    function GetStringListBufferText(ClearBuffer: Boolean = True): string;

    {������������ ����� ����� � �������}
    property ListBufferMaxCount: Integer read FListBufferMaxCount write SetListBufferMaxCount;

    {������������� ���������� �����}
    procedure Lock;

    {������� ���������� �����}
    procedure UnLock;
  end;

{��������� ������� ����  ��������� ��������� ������ LDSLogger. LangFileName -
 ��� ��������� �����. LoggerSection - ��� ������}
procedure TranslateLoggerMessages(const LangFileName: string; const LoggerSection: string = 'LoggerSection');

{ ������� �������� ����� � �������� �������� ��������. ������ ������ �������
  ��������� � ��������� ������ Matrix32.pas. � ��� ������������ ��������������
  ������ ���� �������� ����� � ������� ��������. }
function WaitAndCreateLogFileStream(AFileName: string; AMode: Word; WaitTime: Integer): TFileStream;

{$IFDEF UseResStr}
resourcestring
  resSProcessID = '<P:%d>';
  resSThreadID = '<T:%d>';
  resSProcessAndThreadID = '<P:%d;T:%d>';
  resSCreateMutexError = '������ ��� �������� ������� "�������": %s';
  resSLogErrorsWriterMessage = '������ ��� ������� ������ (%0:s) � ��� "%1:s" ������ [%2:s]: %3:s <%4:s>';
  resSLogWriteError = '<������ ��� ������ � ���>';
  resSLogInformation = ' [����]';
  resSLogError = ' [����]';
  resSLogCritError = ' [����]';
  resSLogWarning = ' [����]';
  resSLogEvent = ' [�����]';
  resSLogDebug = ' [�����]';
  resSLogOther = ' [����]';
  DATE_TIME_FORMAT = 'dd/mm/yyyy hh:nn:ss.zzz';

{$ELSE}
var
  resSProcessID: string = '<P:%d>';
  resSThreadID: string = '<T:%d>';
  resSProcessAndThreadID: string = '<P:%d;T:%d>';
  resSCreateMutexError: string = '������ ��� �������� ������� "�������": %s';
  resSLogErrorsWriterMessage: string = '������ ��� ������� ������ (%0:s) � ��� "%1:s" ������ [%2:s]: %3:s <%4:s>';
  resSLogWriteError: string = '<������ ��� ������ � ���>';
  resSLogInformation: string = ' [����]';
  resSLogError: string = ' [����]';
  resSLogCritError: string = ' [����]';
  resSLogWarning: string = ' [����]';
  resSLogEvent: string = ' [�����]';
  resSLogDebug: string = ' [�����]';
  resSLogOther: string = ' [����]';
  DATE_TIME_FORMAT: string = 'dd/mm/yyyy hh:nn:ss.zzz';
{$ENDIF}

const
  MAX_LOGFILE_SIZE = 1024 * 1024;
  LOGGER_NOTIFY_MESSAGE = WM_USER + 321;
  LIST_BUFFER_MAX_COUNT = 1024;

var
  {������, ������������ ��� ������ ��������� �� �������, ����������� ��� ������
   � ���-�����. �� ��������� ������ ��������� � ���� %TEMP%\LDSLoggerErrorsWriter.log.
   ������ ��� ������ � ���-����� ���������� ������ ����� (��� ����� ������ �������
   �� ����������). �������� ������� ������ ������ - �������� ���-������ �
   ������� �������� ���������� (��� ������ ������ ���������� �� ������ ����� ���
   ��� ��������. ���� ���������� ������ ������, ��� LDSMaxWaitFileTime, �� ���������
   ������ ������� � �����). ����� ����, ���� ��������� ����������� �����������
   �������� ����� �� ����� ������ ������ ������� �������� ������� �����. �����
   ����� ���������� ������ ������������ ����� (� �.�. � �.�.)}
  LogErrorsWriter: TLDSLogger;

  {����� ��������, � ������� �������� ����������� ������� �������� ����� ���
   ������. ��� ����������, ��� ��� �������� ��������� ����� ��������� �����
   � ����������� [fmOpenRead or fmShareDenyWrite] ��� ��� ��� ���� �����
   (��������, Total Commander ��� ���������� ������� ������ ������-�� ���
   ���������. ����� ��������� ���� ��� ������ � ����������� ������ ������������
   ������� Reset().}
  LDSMaxWaitFileTime: Integer = 200;

  {���������� �������� �������, ����� ������� �������� ����������� ���� �� ����
   ������������ ������ ����. �������� �������� � ��������}
  LDSCheckTimeInterval: Integer = 60;

  {��� ��������� - ������ ������}
  LDSLogWords: array[TLDSLogType] of string;

  {��� ��������� - ����������� ������. ������������� ������� ������������ � ����
   � ������ ������ ������ ������ ������. �������������� ���� - ������������
   ������� �������� ��������� ��� ����������� ����������� ���� ������������, �
   ����� ��������� �������� ���������� ���������}
  LDSLogSymbols: array[TLDSLogType] of AnsiChar = ('-', '+', '?', '!', '#', '$', '%', '@');

  {���������� ��������� �������������� ���� � �������, ��������� � ���.
   ��� ������������� ������ ��������������� DateSeparator � TimeSeparator.
   ��� ������������� �� ������ �� �������� ��������� �������.}
  LDSLoggerFormatSettings: TFormatSettings;

  {����������, ����� ��������� ��� �������������� ���� � ������� �������
   ������������: �������, ��� ���������� LDSLoggerFormatSettings. �� ���������
   ������������ LDSLoggerFormatSettings (������ ����������� DateSeparator � TimeSeparator)}
  LDSUseSystemLocalSettings: Boolean = False;

  {����������, ����� �� ������������ ����������, ���� �� ������� ������� ������
  "�������". �� ��������� ���������� �� ������������. ���� ���� ������� ��
  ������, ������ �������� ������ �������.}
  LDSCanRaiseMutexError: Boolean = False;

  {����������, ������ �� ����� ��������� ������� TLDSLogger ��������� ��������.
   �� ��������� ������� ���������. ��������� ������ ��������� ����� �����
   ������ � ����������������� �����}
  LDSGlobalUseMutex: Boolean = True;

implementation

{$IFNDEF D2009PLUS}
function CharInSet(C: Char; const CharSet: TSysCharSet): Boolean;
begin
  Result := C in CharSet;
end;
{$ENDIF}

{ TLDSLogger }

function WaitAndCreateLogFileStream(AFileName: string; AMode: Word; WaitTime: Integer): TFileStream;
const
  SleepTime = 10;
  // ������, ����������, ��� ���� � ������ ������ ���-�� ��� �����, � �������
  // ���������, ���� �� �� �����������
  FriendlyErrors =[ERROR_SHARING_VIOLATION, ERROR_LOCK_VIOLATION];
var
  EndTime: TDateTime;
  ALastError: Integer;
begin
  ALastError := 0;

  if WaitTime < 0 then
    WaitTime := LDSMaxWaitFileTime;

  if WaitTime = 0 then
    Result := TFileStream.Create(AFileName, AMode)
  else
  begin

    EndTime := IncMilliSecond(Now, WaitTime);

    try
      while True do
      try
        Result := TFileStream.Create(AFileName, AMode);
        Exit;
      except
        on E: Exception do
        begin
          // ���������� ��� ������ - ����������� �����
          ALastError := GetLastError;

          // ���� ����� ����� ��������, ��� ��������� ������, ��� �������
          // �������� �� ����� ������, �� ���������� ����������
          if (Now >= EndTime) or (not (ALastError in FriendlyErrors)) then
            raise;

          // ���� ���-�� �����. ������� ������� �������, ������ ��� ��������� �������
          Sleep(SleepTime);
        end;
      end;
    except
      on E: Exception do
        if ALastError in FriendlyErrors then
          raise Exception.CreateFmt('Log file open timeout: %d ms (%s)', [WaitTime, SysErrorMessage(ALastError)])
        else
          raise; // ������������ ������, ��������� �����
    end;
  end;
end;

{ ������� �������. ��������� ����� �������� ���������� LDSLoggerMutexExclusive }
function LDSLoggerCreateMutex(AName: string): Cardinal;
var
{$IFNDEF LDSLoggerMutexExclusive}
  SD: TSecurityDescriptor;
  SA: TSecurityAttributes;
{$ENDIF}
  pSA: PSecurityAttributes;
begin
{$IFNDEF LDSLoggerMutexExclusive}
  if not InitializeSecurityDescriptor(@SD, SECURITY_DESCRIPTOR_REVISION) then
    raise Exception.CreateFmt('Error InitializeSecurityDescriptor: %s', [SysErrorMessage(GetLastError)]);

  SA.nLength := SizeOf(TSecurityAttributes);
  SA.lpSecurityDescriptor := @SD;
  SA.bInheritHandle := False;

  if not SetSecurityDescriptorDacl(SA.lpSecurityDescriptor, True, nil, False) then
    raise Exception.CreateFmt('Error SetSecurityDescriptorDacl: %s', [SysErrorMessage(GetLastError)]);

  pSA := @SA;
{$ELSE}
  pSA := nil;
{$ENDIF}

  Result := CreateMutex(pSA, False, PChar('Global\' + AName)); // �������� ������� � ���������� Global
  if Result = 0 then
    Result := CreateMutex(pSA, False, PChar(AName)); // �������� ������� ��� ��������� Global


  if Result = 0 then
    if LDSCanRaiseMutexError then
      raise Exception.CreateFmt(resSCreateMutexError, [SysErrorMessage(GetLastError)]);
end;

procedure TLDSLogger.CheckLogTime(var fs: TFileStream);
const
  BufSize = 32768; // ������ ������ ������
var
  ar: array of AnsiChar;
  I, NextLinePos: Integer;
  S: string;
  TempTime, TempTime2: TDateTime;
  WasFirst: Boolean;
  tempfs: TFileStream;
  tempfname: string;

  function IsEventChar(C: AnsiChar): Boolean;
  var
    I: TLDSLogType;
  begin
    Result := True;
    for I := Low(LDSLogSymbols) to High(LDSLogSymbols) do
      if C = LDSLogSymbols[I] then
        Exit;
    Result := False;
  end;

begin
  if (DateTimeTrimInterval > 0) and (fs.Size > BufSize) then
  begin
    if FLastCheckTime < IncSecond(Now, -LDSCheckTimeInterval) then
    begin
      // ������� ���������� ��������� ������. ���� ���� ����� ��������� ������� ��������
      try
        fs.Seek(0, soFromBeginning);
        WasFirst := False;
        TempTime2 := 0; // ����� ���������� �� �������

        S := FormatDateTime(DateTimeFormat, Now); // �������� ��������� ����� ������ �����

        SetLength(ar, BufSize);

        // ������������ ��������������� ���� ���� (���� ��� ����������)
        while fs.Position + BufSize < fs.Size do
        begin
          fs.Read(ar[0], BufSize);

          I := 0;

          // ���������� ���� ����, ������� �� ������ �� �����
          // ���� �������� ��������������� ��������� ��������� ���� - ������
          // ���������, ���������� ������ ������
          while I < High(ar) - (Length(S) * 2 + 5) do
          begin
            if ar[I] = #10 then
            begin
              NextLinePos := I + 1; // ���������� ������ ��������� ������
              if IsEventChar(ar[NextLinePos]) and (ar[NextLinePos + 1] = ' ') then
              begin
                SetString(S, PAnsiChar(@ar[NextLinePos + 2]), Length(S)); // � D2010 ��������!
                Inc(I, Length(S) + 2);
              end
              else
              begin
                SetString(S, PAnsiChar(@ar[NextLinePos]), Length(S));
                Inc(I, Length(S));
              end;

              // ���� ������ ���������� � ���������� ����, �� ��������� �� ���������
              if (LDSUseSystemLocalSettings and TryStrToDateTime(S, TempTime)) or (not LDSUseSystemLocalSettings and TryStrToDateTime(S, TempTime, LDSLoggerFormatSettings)) then
              begin
                // ���� � ���� �� ������� ����� ����, �� ����� ����������� ����
                if Trunc(TempTime) = 0 then
                  TempTime := Date + TempTime;

                // ��� ������ ����� ������ ���� ������ ������, ����� �� ����������
                if not WasFirst then
                begin
                  WasFirst := True;
                  // ���������� � ����� ����������, ������� �� ���������
                  if TempTime + (DateTimeTrimInterval + DateTimeTrimInterval / 3) > Now then
                    Exit;
                  TempTime2 := TempTime;
                end
                else
                begin
                  // ���� ��������� ������ ����������, � ���������� - ������������,
                  // �� ������������ ��������� �����
                  if (TempTime + DateTimeTrimInterval > Now) and (TempTime2 + DateTimeTrimInterval < Now) then
                  begin
                    if ClearOldLogData then
                    begin
                      tempfname := Format('%s_%d_%d', [FileName, GetCurrentProcessId, GetCurrentThreadId]);

                      tempfs := TFileStream.Create(tempfname, fmCreate);
                      try
                        fs.Seek(-BufSize + NextLinePos, soFromCurrent);
                        tempfs.CopyFrom(fs, fs.Size - fs.Position);
                        // �������� ������� ����. ������� ��� ���������������
                        // ����� ������, �.�. ������� ����������
                        fs.Size := tempfs.Size; // ����� ����� ���������� Exception
                        fs.Seek(0, soFromBeginning);
                        tempfs.Seek(0, soFromBeginning);
                        fs.CopyFrom(tempfs, tempfs.Size);
                        Exit;
                      finally
                        tempfs.Free;
                        DeleteFile(tempfname);
                      end;
                    end
                    else
                    begin
                      // ������������ �������������� ������
                      FreeAndNil(fs);
                      RenameFiles;
                      Exit;
                    end;
                  end;
                  TempTime2 := TempTime;
                end;
              end;
            end
            else
              Inc(I);
          end; // while I
        end; // fs.Position

        // ���� �� ����� ����� ������ � 2� �������: ���� � ����� ��� �� �����
        // ����� ������� (TempTime2=0), ���� ���� �� 100% ������� �� ����������
        // ������, � ����� ������� ������� �� �������.
        if (TempTime2 > 0) and Assigned(fs) then
        begin
          if ClearOldLogData then
            fs.Size := 0
          else
          begin
            FreeAndNil(fs);
            RenameFiles;
          end;
        end;
      finally
        FreeAndNil(fs);
        FLastCheckTime := Now;
      end;
    end;
  end;
end;

procedure TLDSLogger.ClearListBuffer;
begin
  FBufferCS.Enter;
  try
    FStringListBuffer.Clear;
  finally
    FBufferCS.Leave;
  end;
end;

constructor TLDSLogger.Create(AFileName: string);
begin
  FCritSect := TCriticalSection.Create;
  FBufferCS := TCriticalSection.Create;
  FMaxFileSize := MAX_LOGFILE_SIZE;
  FDateTimeFormat := DATE_TIME_FORMAT;
  FUseMutex := LDSGlobalUseMutex;
  FileName := AFileName;
  FEnabled := True;
  FCanWriteLogWords := True;
  FClearOldLogData := True;
  FMaxOldLogFileCount := 10;
  FUsedLogTypes := [tlpNone, tlpInformation, tlpError, tlpCriticalError, tlpWarning, tlpEvent, tlpDebug, tlpOther];
  FStringListBuffer := TStringList.Create;
  FNotifyMessage := LOGGER_NOTIFY_MESSAGE;
  FListBufferMaxCount := LIST_BUFFER_MAX_COUNT;
end;

destructor TLDSLogger.Destroy;
begin
  UseMutex := False;
  FreeAndNil(FCritSect);
  FreeAndNil(FStringListBuffer);
  FreeAndNil(FBufferCS);
  inherited;
end;

function TLDSLogger.GenerateMutexName: string;
var
  I: Integer;
begin
  Result := AnsiLowerCase(FileName);
  for I := 1 to Length(Result) do
    if CharInSet(Result[I], ['\', '/', ':', '*', '"', '?', '|', '<', '>']) then
      Result[I] := '_';
end;

function TLDSLogger.GetStringListBufferText(ClearBuffer: Boolean): string;
begin
  FBufferCS.Enter;
  try
    Result := FStringListBuffer.Text;
    if ClearBuffer then
      FStringListBuffer.Clear;
  finally
    FBufferCS.Leave;
  end;
end;

procedure TLDSLogger.Lock;
begin
  FCritSect.Enter;

  if FMutexHandle <> 0 then
    WaitForSingleObject(FMutexHandle, INFINITE);
end;

procedure TLDSLogger.LogStr(MsgText: string; LogType: TLDSLogType);
var
  Fs: TFileStream;
  SFileMode: string;
  BufferMsgText: string;

  function GetLogString: string;
  begin
    Result := '';
    MsgText := Trim(MsgText);
    if MsgText <> '' then
    begin
      if LDSUseSystemLocalSettings then
        Result := FormatDateTime(DateTimeFormat, Now)
      else
        Result := FormatDateTime(DateTimeFormat, Now, LDSLoggerFormatSettings);

      if CanWriteLogSymbols then
        Result := LDSLogSymbols[LogType] + ' ' + Result;
      if CanWriteLogWords then
        Result := Result + LDSLogWords[LogType];

      if DefaultPrefix <> '' then
        Result := Result + ' ' + DefaultPrefix;

      if CanWriteProcessID and CanWriteThreadID then
        Result := Result + ' ' + Format(resSProcessAndThreadID, [GetCurrentProcessId, GetCurrentThreadId])
      else if CanWriteProcessID then
        Result := Result + ' ' + Format(resSProcessID, [GetCurrentProcessId])
      else if CanWriteThreadID then
        Result := Result + ' ' + Format(resSThreadID, [GetCurrentThreadId]);

      Result := Result + ' ' + MsgText;
    end;
  end;

begin
  if Enabled and (FileName <> '') and Assigned(FCritSect) and (LogType in FUsedLogTypes) then
  begin
    Lock;
    try
      try

        BufferMsgText := GetLogString;

        if FileExists(FileName) then
        begin
          // �������� FileExists() �� ����������� �� 100%, ��� ��������� �������
          // ���� ���� �� ������. � ���� ������ � LDSLoggerErrorsWriter.log �����
          // ��������: [Cannot open file "LogName.log". �� ������� ����� ��������� ����]

          // ��� ������������� ������������ ������ � LDSLoggerErrorsWriter.log
          // ������� ���������: [������ ��� ������� ������ (fmCreate) � ��� ""
          // ������ [....]: Cannot create file "". ������� �� ������� �����
          // ��������� ����]. ��������� ������� ������ ��� ������ �� ���������.
          // ������, �� ���� ������ �������� ������ ��� ������� ��� ������������
          // ������������ ������. ����������� �� ����� ������� �� ����, �� ������.
          // ��� ������������ ���� ������ ������� ��� ������ �� ��������� ���������
          // ���������� ������ ���� �������.

          SFileMode := 'fmOpenReadWrite';
          Fs := WaitAndCreateLogFileStream(FileName, fmOpenReadWrite or fmShareDenyNone, LDSMaxWaitFileTime);

          // ������������ ������
           //Fs := TFileStream.Create(FileName, fmOpenWrite or fmShareDenyNone);
        end
        else
        begin
          CreateDir(ExtractFilePath(FileName));
          SFileMode := 'fmCreate';
          Fs := WaitAndCreateLogFileStream(FileName, fmCreate, LDSMaxWaitFileTime);
        end;
        SFileMode := SFileMode + '-OK';
        MsgText := BufferMsgText + sLineBreak;
        try
          Fs.Seek(0, soFromEnd);
          Fs.Write(AnsiString(MsgText)[1], Length(MsgText) * SizeOf(AnsiChar));

          SFileMode := SFileMode + ';ProcessFile...';

          if (FMaxFileSize > 0) and (Fs.Size > FMaxFileSize + FMaxFileSize div 3) then
            ProcessFile(Fs) // ������� ��������� ���� � ������� Fs
          else
            CheckLogTime(Fs);
        finally
          Fs.Free;
        end;

      except
        on E: Exception do
        begin
          //Windows.Beep(500, 50); // - ��� ����� ����������� ����������� ������ ���������
          if not FIsErrorWriter then
          begin
            LogErrorsWriter.LogStrFmt(resSLogErrorsWriterMessage, [SFileMode, FileName, Trim(MsgText), E.Message, E.ClassName]);
          end;
          BufferMsgText := BufferMsgText + ' ' + resSLogWriteError;
        end;
      end;

      // �������� ����������� � ����� �����, �.�. ������ �����
      // BufferMsgText ������������ ���������
      if (NotifyHandle <> 0) and (NotifyMessage <> 0) then
      begin
        FBufferCS.Enter;
        try
          FStringListBuffer.Add(BufferMsgText);
          while FStringListBuffer.Count > ListBufferMaxCount do
            FStringListBuffer.Delete(0);
          PostMessage(NotifyHandle, NotifyMessage, 0, 0);
        finally
          FBufferCS.Leave;
        end;
      end;
    finally
      UnLock;
    end;
  end;
end;

procedure TLDSLogger.LogStrFmt(MsgText: string; Args: array of const; LogType: TLDSLogType);
begin
  LogStr(Format(MsgText, Args), LogType);
end;

procedure TLDSLogger.ProcessFile(var fs: TFileStream);
const
  BufSize = MaxByte;
var
  Counter, I: Integer;
  ar: array of AnsiChar;
  WasFind: Boolean;
  tempfs: TFileStream;
  tempfname: string;
begin
  if ClearOldLogData then
  begin
    // ������� ������ ������ � ������ �����
    if fs.Size > MaxFileSize + BufSize then
    begin
      //fs.Seek(-MaxFileSize, soFromEnd);
      fs.Position := fs.Size - -MaxFileSize;
      SetLength(ar, BufSize);
      Counter := 0;
      WasFind := False;
      // �� ��������� ������ ������ �� ��������
      while (fs.Position >= BufSize) and (not WasFind) do
      begin
        fs.Seek(-BufSize, soFromCurrent); // �������� ��������� �����
        fs.Read(ar[0], BufSize);          // ������. ��� ���� ��������� ��������� ������

        for I := High(ar) downto Low(ar) do
          if CharInSet(ar[I], [#13, #10]) then
          begin
            WasFind := True;
            Break;
          end
          else
            Inc(Counter);

        if not WasFind then // ���� �� ������� ����� ������ ������
          fs.Seek(-BufSize, soFromCurrent); // ��� ��� �������� ��������� �����
      end;

      if not WasFind then
        Counter := 0; // ������� �������

      //fs.Seek(-MaxFileSize - Counter, soFromEnd);
      fs.Position := fs.Size -MaxFileSize - Counter;

      tempfname := Format('%s_%d_%d', [FileName, GetCurrentProcessId, GetCurrentThreadId]);

      tempfs := TFileStream.Create(tempfname, fmCreate);
      try
        tempfs.CopyFrom(fs, fs.Size - fs.Position);
        // �������� ������� ����. ������� ��� ���������������
        // ����� ������, �.�. ������� ����������
        fs.Size := tempfs.Size; // ����� ����� ���������� Exception
        fs.Seek(0, soFromBeginning);
        tempfs.Seek(0, soFromBeginning);
        fs.CopyFrom(tempfs, tempfs.Size);
      finally
        tempfs.Free;
        DeleteFile(tempfname);
      end;
    end;
  end
  else
  begin
    FreeAndNil(fs);
    RenameFiles;
  end;
end;

procedure TLDSLogger.RenameFiles;
var
  AList: TStringList;
  Index: Integer;

  { ���������� ������ ��������������� ���-������ }

  function GetOldFilesList(List: TStringList): Integer;
  var
    SR: TSearchRec;
    APath: string;
    AFileExt, SRExt: string;
    NumExt: string;

    function StringListSortCompare(AList: TStringList; Index1, Index2: Integer): Integer;
    var
      NumExt1, NumExt2: Integer;
      AFileName: string;
      S: string;
    begin
      AFileName := TLDSLogger(AList.Objects[Index1]).FileName;
      S := Copy(AList[Index1], Length(AFileName) + 1, Length(AList[Index1]) - Length(AFileName));
      NumExt1 := StrToInt(S);

      S := Copy(AList[Index2], Length(AFileName) + 1, Length(AList[Index2]) - Length(AFileName));
      NumExt2 := StrToInt(S);

      if NumExt1 > NumExt2 then
        Result := 1
      else if NumExt1 < NumExt2 then
        Result := -1
      else
        Result := 0;

    end;

  begin
    APath := ExtractFilePath(FileName);
    AFileExt := AnsiLowerCase(ExtractFileExt(FileName));
    List.Clear;

    // ��������� ������ ��������������� LOG-������
    if FindFirst(FileName + '*', faAnyFile, SR) = 0 then
    try
      repeat
        if FileExists(APath + SR.Name) then
        begin
          SRExt := ExtractFileExt(SR.Name);
          if not AnsiSameText(AFileExt, SRExt) then
          begin
            NumExt := Copy(SRExt, Length(AFileExt) + 1, Length(SRExt) - Length(AFileExt));


            // ��������� ��� ����� � Self (Self ������������ ��� �����������
            // FileName ������ ������� StringListSortCompare)
            if StrToIntDef(NumExt, -1) >= 0 then
              List.AddObject(APath + SR.Name, Self);
          end;
        end;
      until FindNext(SR) <> 0;
    finally
      FindClose(SR);
    end;

    // ��������� ������ � ������� ����������� ������
    List.CustomSort(@StringListSortCompare);
    Result := List.Count;
  end;

  procedure RenameOldLogFiles(List: TStringList);
  var
    I, NumExt: Integer;
    S: string;
  begin
    for I := List.Count - 1 downto 0 do
    begin
      S := Copy(AList[I], Length(FileName) + 1, Length(AList[I]) - Length(FileName));
      NumExt := StrToInt(S);
      S := IntToStr(NumExt + 1);
      while Length(S) < 3 do
        S := '0' + S;
      RenameFile(List[I], FileName + S);
    end;
  end;

begin
  AList := TStringList.Create;
  try
    GetOldFilesList(AList);
    // ������� ������ ���-�����
    if MaxOldLogFileCount > 0 then
      while AList.Count > MaxOldLogFileCount do
      begin
        Index := AList.Count - 1;
        DeleteFile(AList[Index]);
        AList.Delete(Index);
      end;

    // ��������������� ���������� ���-����� ����� ���������� ����������
    // �������� ���������� �� 1-��
    RenameOldLogFiles(AList);

    // ��������������� �������� ���� (���� ��� ������ = 000)
    RenameFile(FileName, FileName + '000');
  finally
    AList.Free;
  end;
end;

procedure TLDSLogger.SetDateTimeFormat(const Value: string);
begin
  FCritSect.Enter;
  try
    FDateTimeFormat := Value;
  finally
    FCritSect.Leave;
  end;
end;

procedure TLDSLogger.SetDateTimeTrimInterval(const Value: TDateTime);
begin
  FCritSect.Enter;
  try
    FDateTimeTrimInterval := Value;
  finally
    FCritSect.Leave;
  end;
end;

procedure TLDSLogger.SetDefaultPrefix(const Value: string);
begin
  FCritSect.Enter;
  try
    FDefaultPrefix := Value;
  finally
    FCritSect.Leave;
  end;
end;

procedure TLDSLogger.SetFileName(Value: string);
begin
  {�������� 2 ����� ������� - ��������� ���������� FFileName � �������}
  FCritSect.Enter;
  try
    if Value = '' then
      Exit;

    // ���� ������ �������� ��� �����, �� ��������� ��� ������ ������
    if ExtractFilePath(Value) = '' then
      Value := ExtractFilePath(ParamStr(0)) + Value;

    // ���� ������� ����� ��� �����, �� ����������� ������ "�������
    if ((FMutexHandle = 0) and UseMutex) or (AnsiLowerCase(Value) <> AnsiLowerCase(FFileName)) then
    begin
      // ���� ������� ����� ��� �����������, �� ������� ���
      if FMutexHandle <> 0 then
      begin
        CloseHandle(FMutexHandle);
        FMutexHandle := 0;
      end;

      FFileName := Value;

      if UseMutex then
        FMutexHandle := LDSLoggerCreateMutex(GenerateMutexName);
    end;
  finally
    FCritSect.Leave;
  end;
end;

procedure TLDSLogger.SetListBufferMaxCount(const Value: Integer);
begin
  FListBufferMaxCount := Value;
end;

procedure TLDSLogger.SetNotifyHandle(const Value: THandle);
begin
  FNotifyHandle := Value;
end;

procedure TLDSLogger.SetNotifyMessage(const Value: Cardinal);
begin
  FNotifyMessage := Value;
end;

procedure TLDSLogger.SetUsedLogTypes(const Value: TLDSLogTypes);
begin
  FUsedLogTypes := Value;
end;

procedure TLDSLogger.SetUseMutex(const Value: Boolean);
begin
  FCritSect.Enter;
  try
    FUseMutex := Value;
    if not Value and (FMutexHandle <> 0) then
    begin
      CloseHandle(FMutexHandle);
      FMutexHandle := 0;
    end;
  finally
    FCritSect.Leave;
  end;
end;

procedure TLDSLogger.UnLock;
begin
  if FMutexHandle <> 0 then
    ReleaseMutex(FMutexHandle);
  FCritSect.Leave;
end;

procedure FillLDSLogWords;
begin
  LDSLogWords[tlpNone] := '';
  LDSLogWords[tlpInformation] := resSLogInformation;
  LDSLogWords[tlpError] := resSLogError;
  LDSLogWords[tlpCriticalError] := resSLogCritError;
  LDSLogWords[tlpWarning] := resSLogWarning;
  LDSLogWords[tlpEvent] := resSLogEvent;
  LDSLogWords[tlpDebug] := resSLogDebug;
  LDSLogWords[tlpOther] := resSLogOther;
end;

procedure TranslateLoggerMessages(const LangFileName: string; const LoggerSection: string = 'LoggerSection');
var
  AList: TStringList;
  Ini: TIniFile;

  procedure TranslateStr(const AName: string; var AValue: string);
  var
    S: string;
  begin
    S := AnsiDequotedStr(AList.Values[AName], '"');
    if S <> '' then
      AValue := S;
  end;

  procedure TranslateMessages;
  begin
    {$IFNDEF UseResStr}
    TranslateStr('SProcessID', resSProcessID);
    TranslateStr('SThreadID', resSThreadID);
    TranslateStr('SProcessAndThreadID', resSProcessAndThreadID);
    TranslateStr('SCreateMutexError', resSCreateMutexError);
    TranslateStr('SLogErrorsWriterMessage', resSLogErrorsWriterMessage);
    TranslateStr('SLogWriteError', resSLogWriteError);
    TranslateStr('SLogInformation', resSLogInformation);
    TranslateStr('SLogError', resSLogError);
    TranslateStr('SLogCritError', resSLogCritError);
    TranslateStr('SLogWarning', resSLogWarning);
    TranslateStr('SLogEvent', resSLogEvent);
    TranslateStr('SLogDebug', resSLogDebug);
    TranslateStr('SLogOther', resSLogOther);
    FillLDSLogWords;
    {$ENDIF UseResStr}
  end;

begin
  Ini := TIniFile.Create(LangFileName);
  AList := nil;
  try
    AList := TStringList.Create;
    try
      Ini.ReadSectionValues(LoggerSection, AList);
      TranslateMessages;
    except
      on E: Exception do
      begin
        LogErrorsWriter.LogStr('TranslateLoggerMessages -> ' + E.Message, tlpError);
        Windows.Beep(500, 50);
      end;
    end;
  finally
    AList.Free;
    Ini.Free;
  end;
end;

procedure CreateLogErrorsWriter;
var
  S: string;
begin
  SetLength(S, MAX_PATH);
  GetTempPath(MAX_PATH, PChar(S));
  S := PChar(S);
  LogErrorsWriter := TLDSLogger.Create(S + 'LDSLoggerErrorsWriter.log');
  LogErrorsWriter.ClearOldLogData := True;
  LogErrorsWriter.FIsErrorWriter := True;
end;

procedure InitFormatSettings;
begin
  {$WARN SYMBOL_PLATFORM OFF}
  LDSLoggerFormatSettings := TFormatSettings.Create(LOCALE_USER_DEFAULT);
  {$WARN SYMBOL_PLATFORM ON}
  LDSLoggerFormatSettings.LongDateFormat := 'dd/mm/yyyy';
  LDSLoggerFormatSettings.ShortDateFormat := 'dd/mm/yyyy';
  LDSLoggerFormatSettings.LongTimeFormat := 'hh:nn:ss.zzz';
  LDSLoggerFormatSettings.ShortTimeFormat := 'hh:nn:ss.zzz';
  LDSLoggerFormatSettings.DateSeparator := '.';
  LDSLoggerFormatSettings.TimeSeparator := ':';
  LDSLoggerFormatSettings.DecimalSeparator := '.';
end;

initialization
  FillLDSLogWords;
  CreateLogErrorsWriter;
  InitFormatSettings;

finalization
  FreeAndNil(LogErrorsWriter);

end.
