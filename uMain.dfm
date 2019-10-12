object Main: TMain
  Left = 0
  Top = 0
  Caption = 'Delphi Robust Server'
  ClientHeight = 418
  ClientWidth = 842
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clGrayText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnClose = FormClose
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object pUrlEncode: TPanel
    AlignWithMargins = True
    Left = 3
    Top = 74
    Width = 836
    Height = 32
    Align = alTop
    Caption = 'Answer'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 0
    object bDoUrlEncode: TBitBtn
      AlignWithMargins = True
      Left = 739
      Top = 4
      Width = 93
      Height = 24
      Align = alRight
      Caption = '> URLEncode'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      OnClick = bDoUrlEncodeClick
    end
    object eUrlEncodeValue: TEdit
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 729
      Height = 24
      Align = alClient
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGrayText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
    end
  end
  object pTop: TPanel
    Left = 0
    Top = 0
    Width = 842
    Height = 33
    Align = alTop
    Caption = 'pTop'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clGrayText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    ShowCaption = False
    TabOrder = 1
    object bStartStop: TBitBtn
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 33
      Height = 25
      Align = alLeft
      TabOrder = 0
      OnClick = bStartStopClick
    end
    object bAPI: TBitBtn
      AlignWithMargins = True
      Left = 150
      Top = 4
      Width = 33
      Height = 25
      Align = alLeft
      Caption = 'API'
      TabOrder = 1
      OnClick = bAPIClick
    end
    object bLog: TBitBtn
      AlignWithMargins = True
      Left = 189
      Top = 4
      Width = 33
      Height = 25
      Align = alLeft
      Caption = 'LOG'
      TabOrder = 2
      OnClick = bLogClick
    end
    object cbRequestType: TComboBox
      AlignWithMargins = True
      Left = 43
      Top = 4
      Width = 62
      Height = 24
      Align = alLeft
      Style = csDropDownList
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGrayText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ItemIndex = 0
      ParentFont = False
      TabOrder = 3
      Text = 'GET'
      OnSelect = cbRequestTypeSelect
      Items.Strings = (
        'GET'
        'POST')
    end
    object bSettings: TBitBtn
      AlignWithMargins = True
      Left = 111
      Top = 4
      Width = 33
      Height = 25
      Align = alLeft
      TabOrder = 4
      OnClick = bSettingsClick
    end
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 399
    Width = 842
    Height = 19
    Panels = <
      item
        Text = 'Stoped'
        Width = 80
      end
      item
        Width = 120
      end
      item
        Width = 150
      end
      item
        Width = 100
      end>
  end
  object pPost: TPanel
    AlignWithMargins = True
    Left = 3
    Top = 112
    Width = 836
    Height = 112
    Align = alTop
    BevelOuter = bvNone
    Caption = 'pPost'
    ShowCaption = False
    TabOrder = 3
    object pPostParamsTop: TPanel
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 830
      Height = 25
      Align = alTop
      BevelEdges = []
      BevelOuter = bvNone
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      ShowCaption = False
      TabOrder = 0
      object cbPostType: TComboBox
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 824
        Height = 21
        Align = alClient
        Style = csDropDownList
        ItemIndex = 0
        TabOrder = 0
        Text = 'application/json'
        OnSelect = cbPostTypeSelect
        Items.Strings = (
          'application/json'
          'application/x-www-form-urlencoded'
          'multipart/form-data')
      end
    end
    object mPostParams: TMemo
      AlignWithMargins = True
      Left = 3
      Top = 34
      Width = 830
      Height = 75
      Align = alClient
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGrayText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      Lines.Strings = (
        '{ "name":"Stas", "age":35 }')
      ParentFont = False
      ScrollBars = ssVertical
      TabOrder = 1
    end
  end
  object pAnswers: TPanel
    AlignWithMargins = True
    Left = 3
    Top = 230
    Width = 836
    Height = 166
    Align = alClient
    BevelOuter = bvNone
    Caption = 'pAnswers'
    TabOrder = 4
    object pAnswerTop: TPanel
      Left = 0
      Top = 0
      Width = 836
      Height = 33
      Align = alTop
      BevelOuter = bvNone
      Caption = 'Answers'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
      object bClearAnswers: TBitBtn
        AlignWithMargins = True
        Left = 3
        Top = 1
        Width = 33
        Height = 31
        Hint = 'ClearMessages'
        Margins.Top = 1
        Margins.Right = 5
        Margins.Bottom = 1
        Align = alLeft
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        OnClick = bClearAnswersClick
      end
    end
    object mAnswer: TMemo
      AlignWithMargins = True
      Left = 3
      Top = 36
      Width = 830
      Height = 127
      Align = alClient
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGrayText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      ScrollBars = ssVertical
      TabOrder = 1
      ExplicitLeft = 6
      ExplicitTop = 12
    end
  end
  object pRequest: TPanel
    AlignWithMargins = True
    Left = 3
    Top = 36
    Width = 836
    Height = 32
    Align = alTop
    Caption = 'Request'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    ShowCaption = False
    TabOrder = 5
    object cbRequest: TComboBoxEx
      AlignWithMargins = True
      Left = 11
      Top = 4
      Width = 771
      Height = 25
      Margins.Left = 10
      Margins.Right = 5
      Align = alClient
      ItemsEx = <>
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGrayText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      Text = 'Test/Connection'
      OnKeyPress = cbRequestKeyPress
    end
    object bGo: TBitBtn
      AlignWithMargins = True
      Left = 790
      Top = 4
      Width = 42
      Height = 24
      Hint = 'Send Request'
      Align = alRight
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
      OnClick = bGoClick
    end
  end
  object TrayIcon: TTrayIcon
    PopupMenu = PopupMenu
    Visible = True
    OnDblClick = TrayIconDblClick
    Left = 512
    Top = 296
  end
  object ApplicationEvents: TApplicationEvents
    OnMinimize = ApplicationEventsMinimize
    Left = 416
    Top = 216
  end
  object PopupMenu: TPopupMenu
    Left = 584
    Top = 298
    object pNormalWindow: TMenuItem
      Caption = #1056#1072#1079#1074#1077#1088#1085#1091#1090#1100
      OnClick = pNormalWindowClick
    end
    object pExit: TMenuItem
      Caption = #1042#1099#1081#1090#1080
      OnClick = pExitClick
    end
  end
end
