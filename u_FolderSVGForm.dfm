object FormSvgFolder: TFormSvgFolder
  Left = 0
  Top = 0
  Caption = 'SVG Folder:'
  ClientHeight = 441
  ClientWidth = 624
  Color = clBtnFace
  Constraints.MinHeight = 200
  Constraints.MinWidth = 200
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
  object splFolders: TSplitter
    Left = 200
    Top = 38
    Width = 5
    Height = 403
    Color = clActiveBorder
    ParentColor = False
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 624
    Height = 38
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object PageScroller1: TPageScroller
      Left = 0
      Top = 0
      Width = 543
      Height = 38
      Align = alClient
      Control = ToolBar1
      TabOrder = 0
      object ToolBar1: TToolBar
        Left = 0
        Top = 0
        Width = 203
        Height = 38
        Align = alLeft
        AutoSize = True
        ButtonHeight = 38
        ButtonWidth = 39
        Caption = 'ToolBar1'
        Images = FormMain.ilMain
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        object tbRootfolder: TToolButton
          Left = 0
          Top = 0
          Action = FormMain.aRootfolder
        end
        object tbRefreshFolder: TToolButton
          Left = 39
          Top = 0
          Action = FormMain.aRefresh
        end
        object tbImportSVGFiles: TToolButton
          Left = 78
          Top = 0
          Action = FormMain.aImport
        end
        object ToolButton5: TToolButton
          Left = 117
          Top = 0
          Width = 8
          Caption = 'ToolButton5'
          ImageIndex = 3
          Style = tbsSeparator
        end
        object tbApply: TToolButton
          Left = 125
          Top = 0
          Action = FormMain.aApply
        end
        object tbCopySVGFile: TToolButton
          Left = 164
          Top = 0
          Hint = 'Copy SVG to clipboard'
          Caption = 'Copy'
          ImageIndex = 6
          OnClick = aCopyExecute
        end
      end
    end
    object cb_SizeSVG: TComboBox
      AlignWithMargins = True
      Left = 546
      Top = 8
      Width = 75
      Height = 21
      Margins.Top = 8
      Align = alRight
      Style = csDropDownList
      ItemIndex = 1
      TabOrder = 1
      Text = '64 x 64'
      OnChange = cb_SizeSVGChange
      Items.Strings = (
        '32 x 32'
        '64 x 64'
        '128 x 128')
    end
  end
  object splitFolders: TSplitView
    Left = 0
    Top = 38
    Width = 200
    Height = 403
    OpenedWidth = 200
    Placement = svpLeft
    TabOrder = 1
    object treeFolders: TTreeView
      Left = 0
      Top = 0
      Width = 200
      Height = 403
      Align = alClient
      BevelInner = bvNone
      BorderStyle = bsNone
      Color = clBtnFace
      HideSelection = False
      Images = il_Folder
      Indent = 19
      ReadOnly = True
      RowSelect = True
      ShowRoot = False
      TabOrder = 0
      OnChange = treeFoldersChange
      OnCollapsing = treeFoldersCollapsing
      OnExpanding = treeFoldersExpanding
    end
  end
  object lv_DirSVG: TListView
    Left = 205
    Top = 38
    Width = 419
    Height = 403
    Margins.Top = 0
    Margins.Bottom = 4
    Align = alClient
    BorderStyle = bsNone
    Columns = <>
    DoubleBuffered = True
    DragMode = dmAutomatic
    FlatScrollBars = True
    GridLines = True
    IconOptions.AutoArrange = True
    IconOptions.WrapText = False
    LargeImages = il_DirSVG
    ParentDoubleBuffered = False
    PopupMenu = pmFolder
    ShowColumnHeaders = False
    SortType = stText
    TabOrder = 2
    OnCustomDrawItem = lv_DirSVGCustomDrawItem
  end
  object il_Folder: TImageList
    Left = 21
    Top = 58
  end
  object il_DirSVG: TImageList
    Height = 128
    Width = 128
    Left = 216
    Top = 53
  end
  object pmFolder: TPopupMenu
    Images = FormMain.ilMain
    Left = 312
    Top = 136
    object miCopy: TMenuItem
      Action = FormMain.aCopy
    end
    object miApplyTo: TMenuItem
      Action = FormMain.aApply
    end
    object miSep1: TMenuItem
      Caption = '-'
    end
    object miRefresh: TMenuItem
      Action = FormMain.aRefresh
    end
    object miRootfolder: TMenuItem
      Action = FormMain.aRootfolder
    end
    object miImportAll: TMenuItem
      Caption = 'Import all'
      Hint = 'Import all SVG to TTF'
      ImageIndex = 3
      ShortCut = 120
    end
  end
end
