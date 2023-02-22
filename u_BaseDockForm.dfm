object BaseDockForm: TBaseDockForm
  Left = 0
  Top = 0
  Caption = 'BaseDockForm'
  ClientHeight = 299
  ClientWidth = 635
  Color = clBtnFace
  DragKind = dkDock
  DragMode = dmAutomatic
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object StatusBar: TStatusBar
    Left = 0
    Top = 280
    Width = 635
    Height = 19
    Panels = <>
  end
  object appEvents: TApplicationEvents
    OnIdle = appEventsIdle
    Left = 232
    Top = 200
  end
end
