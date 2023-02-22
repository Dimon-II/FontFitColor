object FormTTF: TFormTTF
  Left = 0
  Top = 0
  Caption = 'Font:'
  ClientHeight = 561
  ClientWidth = 784
  Color = clBtnFace
  DragKind = dkDock
  DragMode = dmAutomatic
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 784
    Height = 39
    Align = alTop
    BevelOuter = bvNone
    ParentBackground = False
    TabOrder = 0
    object PageScroller1: TPageScroller
      Left = 0
      Top = 0
      Width = 641
      Height = 39
      Align = alClient
      Control = tbrTTF
      TabOrder = 0
      object tbrTTF: TToolBar
        Left = 0
        Top = 0
        Width = 500
        Height = 39
        Align = alLeft
        AutoSize = True
        ButtonHeight = 38
        ButtonWidth = 39
        Caption = 'tbrTTF'
        Images = FormMain.ilMain
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        object tbOpenTTF: TToolButton
          Left = 0
          Top = 0
          Action = FormMain.aOpenTTF
        end
        object tbSaveFont: TToolButton
          Left = 39
          Top = 0
          Action = FormMain.aSaveTTF
        end
        object ToolButton5: TToolButton
          Left = 78
          Top = 0
          Width = 8
          Caption = 'ToolButton5'
          ImageIndex = 3
          Style = tbsSeparator
        end
        object tbCopySVG: TToolButton
          Left = 86
          Top = 0
          Hint = 'Copy SVG to clipboard'
          Caption = 'Copy'
          ImageIndex = 6
          OnClick = aCopyExecute
        end
        object tbPasteSVG: TToolButton
          Left = 125
          Top = 0
          Action = FormMain.aPaste
        end
        object tbClearSVG: TToolButton
          Left = 164
          Top = 0
          Action = FormMain.aClearSVG
        end
        object ToolButton13: TToolButton
          Left = 203
          Top = 0
          Width = 8
          Caption = 'ToolButton13'
          ImageIndex = 6
          Style = tbsSeparator
        end
        object tbRootfolder: TToolButton
          Left = 211
          Top = 0
          Action = FormMain.aRootfolder
        end
        object tbImportFolder: TToolButton
          Left = 250
          Top = 0
          Action = FormMain.aImport
        end
        object tbExportFolder: TToolButton
          Left = 289
          Top = 0
          Action = FormMain.aExport
        end
        object ToolButton11: TToolButton
          Left = 328
          Top = 0
          Width = 8
          Caption = 'ToolButton11'
          ImageIndex = 4
          Style = tbsSeparator
        end
        object tbExportSel: TToolButton
          Left = 336
          Top = 0
          Action = FormMain.aSaveSVG
        end
        object tbImportSel: TToolButton
          Left = 375
          Top = 0
          Action = FormMain.aApply
        end
        object ToolButton3: TToolButton
          Left = 414
          Top = 0
          Width = 8
          Caption = 'ToolButton3'
          ImageIndex = 8
          Style = tbsSeparator
        end
        object tbPin: TToolButton
          Left = 422
          Top = 0
          Action = FormMain.aPin
        end
        object tbFontInfo: TToolButton
          Left = 461
          Top = 0
          Hint = 'Show font info'
          Caption = 'tbFontInfo'
          ImageIndex = 34
          Style = tbsCheck
          OnClick = tbFontInfoClick
        end
      end
    end
    object Panel4: TPanel
      Left = 641
      Top = 0
      Width = 143
      Height = 39
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 1
      DesignSize = (
        143
        39)
      object chbOutline: TCheckBox
        Left = 2
        Top = 8
        Width = 57
        Height = 21
        Anchors = [akTop, akRight]
        Caption = 'Outline'
        TabOrder = 0
        OnClick = chbOutlineClick
      end
      object cb_SizeGlyph: TComboBox
        AlignWithMargins = True
        Left = 65
        Top = 8
        Width = 75
        Height = 21
        Margins.Top = 8
        Align = alRight
        Style = csDropDownList
        ItemIndex = 0
        TabOrder = 1
        Text = '32 x 32'
        OnChange = cb_SizeGlyphChange
        Items.Strings = (
          '32 x 32'
          '64 x 64'
          '128 x 128')
      end
    end
  end
  object lv_Font: TListView
    Left = 0
    Top = 39
    Width = 784
    Height = 522
    Align = alClient
    BorderStyle = bsNone
    Columns = <>
    FlatScrollBars = True
    GridLines = True
    IconOptions.AutoArrange = True
    IconOptions.WrapText = False
    LargeImages = il_Glyph
    MultiSelect = True
    GroupView = True
    PopupMenu = pmFont
    ShowColumnHeaders = False
    TabOrder = 1
    OnCustomDrawItem = lv_FontCustomDrawItem
    OnDragDrop = lv_FontDragDrop
    OnDragOver = lv_FontDragOver
    OnSelectItem = lv_FontSelectItem
  end
  object SplitView1: TSplitView
    Left = 784
    Top = 39
    Width = 0
    Height = 522
    AnimationStep = 240
    Opened = False
    OpenedWidth = 480
    Placement = svpRight
    TabOrder = 2
    object pn_FontName: TPanel
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 0
      Height = 50
      Align = alTop
      Alignment = taLeftJustify
      BevelOuter = bvNone
      Caption = 'Font...'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
    end
    object rgd_Tables: TStringGrid
      Left = 0
      Top = 56
      Width = 300
      Height = 466
      Align = alLeft
      DefaultColWidth = 60
      FixedCols = 0
      RowCount = 2
      TabOrder = 1
    end
    object me_FontFace: TMemo
      Left = 300
      Top = 56
      Width = 248
      Height = 466
      Align = alClient
      TabOrder = 2
    end
  end
  object lbUnicodeRegions: TListBox
    Left = 508
    Top = 56
    Width = 220
    Height = 160
    ItemHeight = 13
    Items.Strings = (
      '0000:001F=Control characters'
      '0020:007F=Basic Latin'
      '00A0:00FF=Latin-1 Supplement'
      '0100:017F=Latin Extended-A'
      '0180:024F=Latin Extended-B'
      '0250:02AF=IPA Extensions'
      '02B0:02FF=Spacing Modifier Letters'
      '0300:036F=Combining Diacritical Marks'
      '0370:03FF=Greek and Coptic'
      '0400:04FF=Cyrillic'
      '0500:052F=Cyrillic Supplementary'
      '0530:058F=Armenian'
      '0590:05FF=Hebrew'
      '0600:06FF=Arabic'
      '0700:074F=Syriac'
      '0780:07BF=Thaana'
      '0900:097F=Devanagari'
      '0980:09FF=Bengali'
      '0A00:0A7F=Gurmukhi'
      '0A80:0AFF=Gujarati'
      '0B00:0B7F=Oriya'
      '0B80:0BFF=Tamil'
      '0C00:0C7F=Telugu'
      '0C80:0CFF=Kannada'
      '0D00:0D7F=Malayalam'
      '0D80:0DFF=Sinhala'
      '0E00:0E7F=Thai'
      '0E80:0EFF=Lao'
      '0F00:0FFF=Tibetan'
      '1000:109F=Myanmar'
      '10A0:10FF=Georgian'
      '1100:11FF=Hangul Jamo'
      '1200:137F=Ethiopic'
      '13A0:13FF=Cherokee'
      '1400:167F=Unified Canadian Aboriginal Syllabics'
      '1680:169F=Ogham'
      '16A0:16FF=Runic'
      '1700:171F=Tagalog'
      '1720:173F=Hanunoo'
      '1740:175F=Buhid'
      '1760:177F=Tagbanwa'
      '1780:17FF=Khmer'
      '1800:18AF=Mongolian'
      '1900:194F=Limbu'
      '1950:197F=Tai Le'
      '19E0:19FF=Khmer Symbols'
      '1D00:1D7F=Phonetic Extensions'
      '1E00:1EFF=Latin Extended Additional'
      '1F00:1FFF=Greek Extended'
      '2000:206F=General Punctuation'
      '2070:209F=Superscripts and Subscripts'
      '20A0:20CF=Currency Symbols'
      '20D0:20FF=Combining Diacritical Marks for Symbols'
      '2100:214F=Letterlike Symbols'
      '2150:218F=Number Forms'
      '2190:21FF=Arrows'
      '2200:22FF=Mathematical Operators'
      '2300:23FF=Miscellaneous Technical'
      '2400:243F=Control Pictures'
      '2440:245F=Optical Character Recognition'
      '2460:24FF=Enclosed Alphanumerics'
      '2500:257F=Box Drawing'
      '2580:259F=Block Elements'
      '25A0:25FF=Geometric Shapes'
      '2600:26FF=Miscellaneous Symbols'
      '2700:27BF=Dingbats'
      '27C0:27EF=Miscellaneous Mathematical Symbols-A'
      '27F0:27FF=Supplemental Arrows-A'
      '2800:28FF=Braille Patterns'
      '2900:297F=Supplemental Arrows-B'
      '2980:29FF=Miscellaneous Mathematical Symbols-B'
      '2A00:2AFF=Supplemental Mathematical Operators'
      '2B00:2BFF=Miscellaneous Symbols and Arrows'
      '2E80:2EFF=CJK Radicals Supplement'
      '2F00:2FDF=Kangxi Radicals'
      '2FF0:2FFF=Ideographic Description Characters'
      '3000:303F=CJK Symbols and Punctuation'
      '3040:309F=Hiragana'
      '30A0:30FF=Katakana'
      '3100:312F=Bopomofo'
      '3130:318F=Hangul Compatibility Jamo'
      '3190:319F=Kanbun'
      '31A0:31BF=Bopomofo Extended'
      '31F0:31FF=Katakana Phonetic Extensions'
      '3200:32FF=Enclosed CJK Letters and Months'
      '3300:33FF=CJK Compatibility'
      '3400:4DBF=CJK Unified Ideographs Extension A'
      '4DC0:4DFF=Yijing Hexagram Symbols'
      '4E00:9FFF=CJK Unified Ideographs'
      'A000:A48F=Yi Syllables'
      'A490:A4CF=Yi Radicals'
      'AC00:D7AF=Hangul Syllables'
      'D800:DB7F=High Surrogates'
      'DB80:DBFF=High Private Use Surrogates'
      'DC00:DFFF=Low Surrogates'
      'E000:F8FF=Private Use Area'
      'F900:FAFF=CJK Compatibility Ideographs'
      'FB00:FB4F=Alphabetic Presentation Forms'
      'FB50:FDFF=Arabic Presentation Forms-A'
      'FE00:FE0F=Variation Selectors'
      'FE20:FE2F=Combining Half Marks'
      'FE30:FE4F=CJK Compatibility Forms'
      'FE50:FE6F=Small Form Variants'
      'FE70:FEFF=Arabic Presentation Forms-B'
      'FF00:FFEF=Halfwidth and Fullwidth Forms'
      'FFF0:FFFF=Specials'
      '10000:1007F=Linear B Syllabary'
      '10080:100FF=Linear B Ideograms'
      '10100:1013F=Aegean Numbers'
      '10300:1032F=Old Italic'
      '10330:1034F=Gothic'
      '10380:1039F=Ugaritic'
      '10400:1044F=Deseret'
      '10450:1047F=Shavian'
      '10480:104AF=Osmanya'
      '10800:1083F=Cypriot Syllabary'
      '1D000:1D0FF=Byzantine Musical Symbols'
      '1D100:1D1FF=Musical Symbols'
      '1D300:1D35F=Tai Xuan Jing Symbols'
      '1D400:1D7FF=Mathematical Alphanumeric Symbols'
      '20000:2A6DF=CJK Unified Ideographs Extension B'
      '2F800:2FA1F=CJK Compatibility Ideographs Supplement'
      'E0000:E007F=Tags')
    TabOrder = 3
    Visible = False
  end
  object il_Glyph: TImageList
    Height = 40
    Width = 48
    Left = 328
    Top = 120
  end
  object pmFont: TPopupMenu
    Images = FormMain.ilMain
    Left = 168
    Top = 160
    object Copy1: TMenuItem
      Action = FormMain.aCopy
    end
    object Paste1: TMenuItem
      Action = FormMain.aPaste
    end
    object CleraSVG1: TMenuItem
      Action = FormMain.aClearSVG
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object aSaveSVG1: TMenuItem
      Action = FormMain.aSaveSVG
    end
    object Applyto1: TMenuItem
      Action = FormMain.aApply
    end
    object Pin1: TMenuItem
      Action = FormMain.aPin
    end
  end
end
