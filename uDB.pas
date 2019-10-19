unit uDB;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait, Data.DB, FireDAC.Comp.Client, FireDAC.Phys.MySQLDef, FireDAC.Phys.MySQL, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf,
  FireDAC.DApt, FireDAC.Comp.DataSet, uRSCommon, uRSMainModule;

type
  TDB = class(TDataModule)
    FDConnectionTemp: TFDConnection;
    FDPhysMySQLDriverLink: TFDPhysMySQLDriverLink;
    Q: TFDQuery;
    procedure FDConnectionAfterDisconnect(Sender: TObject);
    procedure FDConnectionAfterConnect(Sender: TObject);
  private
    FFDConnection: TFDConnection;
    { Private declarations }
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function Connect: boolean;
    function GetLastID: integer;
    property FDConnection: TFDConnection read FFDConnection write FFDConnection;
  end;

implementation

uses
  uMain;
{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

function TDB.Connect: boolean;
var
  oParams: TStrings;
begin
  oParams := TStringList.Create;
  try
    oParams.Add('DataBase=sarafan_db');
    oParams.Add('Password=masterkey');
    oParams.Add('User_Name=root');
    oParams.Add('Port=3306');
    oParams.Add('Server=localhost');
    oParams.Add('CharacterSet=utf8');
//  oParams.Add('Pooled=true');
    FDConnection.Params.Assign(oParams);
    FDConnection.DriverName := 'MySQL';
   //Пробуем подключиться
    try
      FDConnection.Connected := true;
      Q.Connection := FDConnection;
      Result := FDConnection.Connected;

    except
      on E: EFDDBEngineException do
        case E.Kind of
          ekUserPwdInvalid:
       // user name or password are incorrect
            raise Exception.Create('DBConnection Error. User name or password are incorrect' + #13#10 + #13#10 + E.ClassName + ' поднята ошибка, с сообщением : ' + E.Message);
          ekUserPwdExpired:
            raise Exception.Create('DBConnection Error. User password is expired' + #13#10 + #13#10 + E.ClassName + ' поднята ошибка, с сообщением : ' + E.Message);
          ekServerGone:
            raise Exception.Create('DBConnection Error. DBMS is not accessible due to some reason' + #13#10 + #13#10 + E.ClassName + ' поднята ошибка, с сообщением : ' + E.Message);
        else                // other issues
          raise Exception.Create('DBConnection Error. UnknownMistake' + #13#10 + #13#10 + E.ClassName + ' поднята ошибка, с сообщением : ' + E.Message);
        end;
      on E: Exception do
        raise Exception.Create(E.ClassName + ' поднята ошибка, с сообщением : ' + #13#10 + #13#10 + E.Message);
    end;
  finally
    FreeAndNil(oParams);
  end;
end;

constructor TDB.Create(AOwner: TComponent);
begin
  inherited;
  FFDConnection := TFDConnection.Create(Self);
  FFDConnection.AfterConnect := FDConnectionAfterConnect;
  FFDConnection.BeforeConnect := FDConnectionAfterDisconnect;
end;

destructor TDB.Destroy;
begin
  FFDConnection.Free();
  inherited;
end;

procedure TDB.FDConnectionAfterConnect(Sender: TObject);
begin
//  TRSMainModule.GetInstance.DBConnectionsCount := TRSMainModule.GetInstance.DBConnectionsCount + 1;
end;

procedure TDB.FDConnectionAfterDisconnect(Sender: TObject);
begin
//  TMains.Get.DBConnectionsCount := TMains.Get.DBConnectionsCount - 1;
end;

function TDB.GetLastID: integer;
var
  q: TFdquery;
begin
  q := TFdquery.Create(nil);
  try
    with q do
    begin
      Connection := FDConnection;
      sql.Text := 'SELECT last_insert_id() as lastID;';
      Disconnect();
      Open();
      result := FieldByName('lastID').AsInteger;
      Close();
    end;
  finally
    q.Free;
  end;
end;

end.

