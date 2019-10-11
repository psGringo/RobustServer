object DB: TDB
  OldCreateOrder = False
  Height = 222
  Width = 365
  object FDConnectionTemp: TFDConnection
    AfterConnect = FDConnectionAfterConnect
    AfterDisconnect = FDConnectionAfterDisconnect
    Left = 48
    Top = 40
  end
  object FDPhysMySQLDriverLink: TFDPhysMySQLDriverLink
    Left = 112
    Top = 112
  end
  object Q: TFDQuery
    Connection = FDConnectionTemp
    Left = 216
    Top = 40
  end
end
