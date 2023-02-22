object FormGlyph: TFormGlyph
  Left = 0
  Top = 0
  Caption = 'GLYPH'
  ClientHeight = 441
  ClientWidth = 654
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
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 654
    Height = 76
    Align = alTop
    BevelOuter = bvNone
    ParentBackground = False
    TabOrder = 0
    object Panel3: TPanel
      Left = 502
      Top = 0
      Width = 152
      Height = 36
      Align = alRight
      Alignment = taLeftJustify
      BevelOuter = bvNone
      BorderWidth = 5
      Caption = 'Step'
      TabOrder = 0
      object seGrid: TSpinEdit
        AlignWithMargins = True
        Left = 33
        Top = 8
        Width = 49
        Height = 22
        Margins.Top = 6
        Margins.Bottom = 5
        AutoSize = False
        MaxLength = 3
        MaxValue = 256
        MinValue = 1
        TabOrder = 0
        Value = 20
        OnChange = seGridChange
      end
      object cb_Scale: TComboBox
        AlignWithMargins = True
        Left = 88
        Top = 9
        Width = 56
        Height = 21
        Margins.Top = 4
        Align = alRight
        Style = csDropDownList
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ItemIndex = 3
        ParentFont = False
        TabOrder = 1
        Text = #188
        OnChange = cb_ScaleChange
        Items.Strings = (
          '2x'
          '1x'
          #189
          #188
          #8539
          #185#8260#8321#8326)
      end
    end
    object PageScroller1: TPageScroller
      Left = 0
      Top = 0
      Width = 502
      Height = 36
      Align = alClient
      Control = ToolBar3
      TabOrder = 1
      object ToolBar3: TToolBar
        Left = 0
        Top = 0
        Width = 490
        Height = 36
        Align = alClient
        AutoSize = True
        ButtonHeight = 38
        ButtonWidth = 39
        Caption = 'ToolBar1'
        Images = FormMain.ilMain
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        object tbZero: TToolButton
          Left = 0
          Top = 0
          Hint = 'Go to origin'
          Caption = 'Zero'
          ImageIndex = 37
          OnClick = tbZeroClick
        end
        object tbPin: TToolButton
          Left = 39
          Top = 0
          Hint = 'Pin base glyph (Ctrl + Space)'
          ImageIndex = 5
          Style = tbsCheck
          OnClick = tbPinClick
        end
        object tbPrior: TToolButton
          Left = 78
          Top = 0
          Action = FormMain.aPrior
        end
        object tbNext: TToolButton
          Left = 117
          Top = 0
          Action = FormMain.aNext
        end
        object ToolButton5: TToolButton
          Left = 156
          Top = 0
          Width = 8
          Caption = 'ToolButton5'
          ImageIndex = 42
          Style = tbsSeparator
        end
        object tbEdgeZero: TToolButton
          Left = 164
          Top = 0
          Hint = 'Zero indent'
          ImageIndex = 14
          OnClick = tbEdgeZeroClick
        end
        object tbEdgeLeft: TToolButton
          Left = 203
          Top = 0
          Hint = 'Decrease indent'
          ImageIndex = 16
          OnClick = tbEdgeLeftClick
        end
        object tbEdgeRight: TToolButton
          Left = 242
          Top = 0
          Hint = 'Increase indent'
          ImageIndex = 15
          OnClick = tbEdgeRightClick
        end
        object ToolButton3: TToolButton
          Left = 281
          Top = 0
          Width = 8
          Caption = 'ToolButton3'
          ImageIndex = 42
          Style = tbsSeparator
        end
        object tbUndo: TToolButton
          Left = 289
          Top = 0
          Hint = 'Undo applied'
          Caption = 'tbUndo'
          ImageIndex = 51
          OnClick = tbUndoClick
        end
        object tbRedo: TToolButton
          Left = 328
          Top = 0
          Hint = 'Redo applied'
          Caption = 'tbRedo'
          ImageIndex = 52
          OnClick = tbRedoClick
        end
        object tbApply: TToolButton
          Left = 367
          Top = 0
          Hint = 'Apply changes'
          Caption = 'tbApply'
          ImageIndex = 18
          OnClick = tbApplyClick
        end
        object tbCancel: TToolButton
          Left = 406
          Top = 0
          Hint = 'Undo changes'
          Caption = 'tbCancel'
          ImageIndex = 24
          OnClick = tbCancelClick
        end
      end
    end
    object PageScroller2: TPageScroller
      Left = 0
      Top = 36
      Width = 654
      Height = 40
      Align = alBottom
      Control = ToolBar2
      TabOrder = 2
      object ToolBar2: TToolBar
        Left = 0
        Top = 0
        Width = 642
        Height = 40
        Align = alClient
        AutoSize = True
        ButtonHeight = 38
        ButtonWidth = 39
        Caption = 'ToolBar1'
        Images = FormMain.ilMain
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        object tbAlignMiddle: TToolButton
          Left = 0
          Top = 0
          Hint = 'Align glyphs middle'
          ImageIndex = 30
          OnClick = tbAlignMiddleClick
        end
        object tbAlignTop: TToolButton
          Left = 39
          Top = 0
          Hint = 'Align glyphs top'
          ImageIndex = 27
          OnClick = tbAlignTopClick
        end
        object tbAlignBottom: TToolButton
          Left = 78
          Top = 0
          Hint = 'Align glyphs bottom'
          ImageIndex = 28
          OnClick = tbAlignBottomClick
        end
        object tbAlignCenter: TToolButton
          Left = 117
          Top = 0
          Hint = 'Align glyphs center'
          ImageIndex = 41
          OnClick = tbAlignCenterClick
        end
        object ToolButton1: TToolButton
          Left = 156
          Top = 0
          Width = 8
          Caption = 'ToolButton1'
          ImageIndex = 42
          Style = tbsSeparator
        end
        object tbAlignHeight: TToolButton
          Left = 164
          Top = 0
          Hint = 'Align glyphs size'
          ImageIndex = 17
          OnClick = tbAlignHeightClick
        end
        object tbSizePlus: TToolButton
          Left = 203
          Top = 0
          Hint = 'Enlarge size'
          ImageIndex = 42
          OnClick = tbSizePlusClick
        end
        object tbSizeMinus: TToolButton
          Left = 242
          Top = 0
          Hint = 'Reduce size'
          ImageIndex = 43
          OnClick = tbSizeMinusClick
        end
        object ToolButton4: TToolButton
          Left = 281
          Top = 0
          Width = 8
          Caption = 'ToolButton4'
          ImageIndex = 7
          Style = tbsSeparator
        end
        object tbAlignGlyph: TToolButton
          Left = 289
          Top = 0
          Hint = 'Align middle'
          ImageIndex = 45
          OnClick = tbAlignGlyphClick
        end
        object tbMoveZero: TToolButton
          Left = 328
          Top = 0
          Hint = 'Pinch to the left'
          Caption = 'Pinch left'
          ImageIndex = 26
          OnClick = tbMoveZeroClick
        end
        object tbMoveLeft: TToolButton
          Left = 367
          Top = 0
          Hint = 'Move left'
          ImageIndex = 22
          OnClick = tbMoveLeftClick
        end
        object tbMoveRight: TToolButton
          Left = 406
          Top = 0
          Hint = 'Move right'
          ImageIndex = 23
          OnClick = tbMoveRightClick
        end
        object tbMoveUp: TToolButton
          Left = 445
          Top = 0
          Hint = 'Move up'
          ImageIndex = 40
          OnClick = tbMoveUpClick
        end
        object tbMoveDown: TToolButton
          Left = 484
          Top = 0
          Hint = 'Move down'
          ImageIndex = 39
          OnClick = tbMoveDownClick
        end
      end
    end
  end
  object pn_GLYPG: TPanel
    Left = 0
    Top = 76
    Width = 654
    Height = 365
    Align = alClient
    BevelOuter = bvNone
    Color = clWindow
    DoubleBuffered = True
    ParentBackground = False
    ParentDoubleBuffered = False
    TabOrder = 1
    object pnt_Draw: TPaintBox
      AlignWithMargins = True
      Left = 8
      Top = 8
      Width = 638
      Height = 349
      Margins.Left = 8
      Margins.Top = 8
      Margins.Right = 8
      Margins.Bottom = 8
      Align = alClient
      DragCursor = crSizeAll
      OnDragOver = pnt_DrawDragOver
      OnMouseDown = pnt_DrawMouseDown
      OnPaint = pnt_DrawPaint
      OnStartDrag = pnt_DrawStartDrag
      ExplicitTop = 11
    end
  end
end
