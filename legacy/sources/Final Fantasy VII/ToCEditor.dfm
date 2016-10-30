object ToCForm: TToCForm
  Left = 193
  Top = 126
  Width = 696
  Height = 480
  Caption = #1056#1077#1076#1072#1082#1090#1086#1088' ToC'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Tree: TTreeView
    Left = 8
    Top = 32
    Width = 201
    Height = 385
    Images = TocImages
    Indent = 19
    ReadOnly = True
    TabOrder = 0
    OnChange = TreeChange
    OnCollapsing = TreeCollapsing
    OnExpanding = TreeExpanding
  end
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 688
    Height = 25
    Caption = 'ToolBar1'
    TabOrder = 1
  end
  object Button1: TButton
    Left = 472
    Top = 24
    Width = 97
    Height = 33
    Caption = 'DEBUG!'
    Enabled = False
    TabOrder = 2
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 472
    Top = 56
    Width = 97
    Height = 33
    Caption = 'LoadList'
    TabOrder = 3
    OnClick = Button2Click
  end
  object ValList: TValueListEditor
    Left = 216
    Top = 32
    Width = 233
    Height = 169
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goColSizing, goAlwaysShowEditor, goThumbTracking]
    Strings.Strings = (
      'File='
      'LBA='
      'Size='
      'RealSize='
      'Key='
      'kCompressed='
      'Type=')
    TabOrder = 4
    TitleCaptions.Strings = (
      #1055#1077#1088#1077#1084#1077#1085#1085#1072#1103
      #1047#1085#1072#1095#1077#1085#1080#1077)
    ColWidths = (
      80
      147)
  end
  object Button3: TButton
    Left = 624
    Top = 40
    Width = 33
    Height = 33
    Caption = 'Button3'
    TabOrder = 5
    OnClick = Button3Click
  end
  object Button5: TButton
    Left = 472
    Top = 88
    Width = 97
    Height = 33
    Caption = 'LoadScript'
    TabOrder = 6
    OnClick = Button5Click
  end
  object Button4: TButton
    Left = 472
    Top = 120
    Width = 97
    Height = 33
    Caption = 'LoadKeyFiles'
    TabOrder = 7
    OnClick = Button4Click
  end
  object ActionList1: TActionList
    Left = 48
    Top = 40
  end
  object MainMenu1: TMainMenu
    Left = 16
    Top = 40
    object N1: TMenuItem
      Caption = #1060#1072#1081#1083
    end
  end
  object TocImages: TImageList
    Left = 80
    Top = 40
    Bitmap = {
      494C010103000400040010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000001000000001002000000000000010
      0000000000000000000000000000000000000000000055555500555555005555
      5500555555005555550055555500555555005555550055555500555555005555
      5500555555005555550055555500000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000086868600CCCCCC00CCCC
      CC00CCCCCC00CCCCCC00CCCCCC00CCCCCC00CCCCCC00CCCCCC00CCCCCC00CCCC
      CC00CCCCCC00CCCCCC0055555500000000000000000000000000030303000303
      0300030303000303030003030300030303000303030003030300030303000303
      0300030303000303030003030300000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000086868600FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF005555550000000000000000001C82B5001A80B300177D
      B000157BAE001278AB000F75A8000C72A5000A70A300076DA000056B9E000369
      9C0001679A000066990002020200030303000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000086868600FFFFFF000808
      0800080808000808080008080800080808000808080008080800080808000808
      080008080800FFFFFF0055555500000000002187BA0066CCFF001F85B80099FF
      FF006ED4FF006ED4FF006ED4FF006ED4FF006ED4FF006ED4FF006ED4FF006ED4
      FF003AA0D30099FFFF000066990003030300000000000C72A5000C72A5000C72
      A5000C72A5000C72A5000C72A5000C72A5000C72A5000C72A5000C72A5000C72
      A5000C72A5000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000086868600FFFFFF008686
      8600D6E7E700D6E7E700D6E7E700D6E7E700D6E7E700D6E7E700D6E7E700D6E7
      E70008080800FFFFFF005555550000000000248ABD0066CCFF00268CBF0099FF
      FF007AE0FF007AE0FF007AE0FF007AE0FF007AE0FF007AE0FF007AE0FF007AE0
      FF0043A9DC0099FFFF0001679A0003030300189AC6001B9CC7009CFFFF006BD7
      FF006BD7FF006BD7FF006BD7FF006BD7FF006BD7FF006BD7FF006BD7FF006BD7
      FF002899BF000C72A50000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000086868600FFFFFF008686
      8600FFFFFF00FFFFFF0000008000FFFFFF00FFFFFF000080000000800000D6E7
      E70008080800FFFFFF005555550000000000278DC00066CCFF002C92C50099FF
      FF0085EBFF0085EBFF0085EBFF0085EBFF0085EBFF0085EBFF0085EBFF0085EB
      FF004DB3E60099FFFF0003699C0003030300189AC600199AC60079E4F0009CFF
      FF007BE3FF007BE3FF007BE3FF007BE3FF007BE3FF007BE3FF007BE3FF007BDF
      FF0042B2DE00197A9D0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000086868600FFFFFF008686
      8600FFFFFF00000080000000FF00FFFFFF00FF000000FFFF0000FF000000D6E7
      E70008080800FFFFFF005555550000000000298FC20066CCFF003298CB0099FF
      FF0091F7FF0091F7FF0091F7FF0091F7FF0091F7FF0091F7FF0091F7FF0091F7
      FF0056BCEF0099FFFF00056B9E0003030300189AC60025A2CF003FB8D7009CFF
      FF0084EBFF0084EBFF0084EBFF0084EBFF0084EBFF0084EBFF0084EBFF0084E7
      FF0042BAEF00189AC60000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000086868600FFFFFF008686
      8600FFFFFF0000FFFF0000008000FFFFFF00FFFFFF00FF000000FFFFFF00D6E7
      E70008080800FFFFFF0055555500000000002C92C5006ED4FF003399CC0099FF
      FF0099FFFF0099FFFF0099FFFF0099FFFF0099FFFF0099FFFF0099FFFF0099FF
      FF005FC5F80099FFFF00076DA00003030300189AC60042B3E20020A0C900A5FF
      FF0094F7FF0094F7FF0094F7FF0094F7FF0094F7FF0094F7FF0094F7FF0094F7
      FF0052BEE7005BBCCE000C72A500000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000086868600FFFFFF008686
      8600FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00D6E7
      E70008080800FFFFFF0055555500000000002E94C7007AE0FF002C92C500FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0080E6FF00FFFFFF000A70A30003030300189AC6006FD5FD00189AC60089F0
      F7009CFFFF009CFFFF009CFFFF009CFFFF009CFFFF009CFFFF009CFFFF009CFF
      FF005AC7FF0096F9FB00187A9B00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000086868600FFFFFF008686
      8600990000009900000099000000990000009900000099000000990000009900
      000008080800FFFFFF0055555500000000003096C90085EBFF0080E6FF002C92
      C5002C92C5002C92C5002C92C5002C92C5002C92C500278DC0002389BC001F85
      B8001B81B4001A80B3001A80B30000000000189AC60084D7FF00189AC6006BBF
      DA00FFFFFF00FFFFFF00F7FBFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0084E7FF00FFFFFF00187DA100000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000086868600FFFFFF008686
      86009900000033CCFF0099000000990000009900000099000000990000009900
      000008080800FFFFFF0055555500000000003298CB0091F7FF008EF4FF008EF4
      FF008EF4FF008EF4FF008EF4FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00157BAE00030303000000000000000000189AC60084EBFF004FC1E200189A
      C600189AC600189AC600189AC600189AC600189AC600189AC600189AC600189A
      C600189AC600189AC6001889B100000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000086868600FFFFFF008686
      8600868686008686860086868600868686008686860086868600868686008686
      860008080800CBCBCB0055555500000000003399CC00FFFFFF0099FFFF0099FF
      FF0099FFFF0099FFFF00FFFFFF00248ABD002187BA001E84B7001C82B5001A80
      B300177DB000000000000000000000000000189AC6009CF3FF008CF3FF008CF3
      FF008CF3FF008CF3FF008CF3FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00189AC600197A9D0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000086868600FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF009999
      990055555500555555005555550000000000000000003399CC00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00298FC200000000000000000000000000000000000000
      000000000000000000000000000000000000189AC600FFFFFF009CFFFF009CFF
      FF009CFFFF009CFFFF00FFFFFF00189AC600189AC600189AC600189AC600189A
      C600189AC6000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000086868600FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF009999
      9900FFFFFF0055555500000000000000000000000000000000003399CC003298
      CB003096C9002E94C70000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000021A2CE00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00189AC600000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000086868600D6E7E700D6E7
      E700D6E7E700D6E7E700D6E7E700D6E7E700D6E7E700D6E7E700D6E7E7009999
      9900555555000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000021A2CE0021A2
      CE0021A2CE0021A2CE0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000086868600868686008686
      8600868686008686860086868600868686008686860086868600868686009999
      9900000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000100000000100010000000000800000000000000000000000
      000000000000000000000000FFFFFF008001FFFFFFFF00008001C001FFFF0000
      80018000FFFF0000800100008007000080010000000300008001000000030000
      8001000000030000800100000001000080010000000100008001000100010000
      80010003000100008001000700030000800181FF000700008003C3FF81FF0000
      8007FFFFC3FF0000800FFFFFFFFF000000000000000000000000000000000000
      000000000000}
  end
end
