unit uConst;

interface

type
  TConst = class
  end;

const
  LOG_FILE_NAME = 'log.txt';
  SETTINGS_FILE_NAME = 'settings.ini';
  // rp modules
  RP_Users = 'Users';
  RP_Tests = 'Tests';
  RP_Files = 'Files';
  RP_System = 'System';
  // protocol settings
  DEFAULT_HTTP_PROTOCOL = 'http';
  DEFAULT_HTTP_HOST = 'localhost';
  DEFAULT_HTTP_PORT = '7777';
  // GUI Request types
  GUI_REQUEST_TYPE_GET = 0;
  GUI_REQUEST_TYPE_POST = 1;

implementation

end.

