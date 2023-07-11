unit u_GlyphForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.AppEvnts, u_BaseDockForm,
  Vcl.ComCtrls, Vcl.ToolWin, Vcl.Samples.Spin, Vcl.ExtCtrls, SVG;

type
  TFormGlyph = class(TBaseDockForm)
    Panel2: TPanel;
    Panel3: TPanel;
    seGrid: TSpinEdit;
    cb_Scale: TComboBox;
    PageScroller1: TPageScroller;
    ToolBar3: TToolBar;
    tbPin: TToolButton;
    tbAlignTop: TToolButton;
    tbAlignBottom: TToolButton;
    tbAlignMiddle: TToolButton;
    tbAlignHeight: TToolButton;
    tbAlignCenter: TToolButton;
    PageScroller2: TPageScroller;
    ToolBar2: TToolBar;
    tbSizePlus: TToolButton;
    tbSizeMinus: TToolButton;
    ToolButton4: TToolButton;
    tbMoveZero: TToolButton;
    tbMoveLeft: TToolButton;
    tbMoveRight: TToolButton;
    tbMoveUp: TToolButton;
    tbMoveDown: TToolButton;
    tbAlignGlyph: TToolButton;
    tbEdgeZero: TToolButton;
    tbEdgeLeft: TToolButton;
    tbEdgeRight: TToolButton;
    pn_GLYPG: TPanel;
    pnt_Draw: TPaintBox;
    tbApply: TToolButton;
    tbCancel: TToolButton;
    tbZero: TToolButton;
    ToolButton5: TToolButton;
    tbPrior: TToolButton;
    tbNext: TToolButton;
    ToolButton3: TToolButton;
    tbUndo: TToolButton;
    tbRedo: TToolButton;
    ToolButton1: TToolButton;
    procedure pnt_DrawDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure tbZeroClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure pnt_DrawMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pnt_DrawStartDrag(Sender: TObject; var DragObject: TDragObject);
    procedure pnt_DrawPaint(Sender: TObject);
    procedure cb_ScaleChange(Sender: TObject);
    procedure seGridChange(Sender: TObject);
    procedure tbMoveUpClick(Sender: TObject);
    procedure tbMoveDownClick(Sender: TObject);
    procedure tbMoveLeftClick(Sender: TObject);
    procedure tbMoveRightClick(Sender: TObject);
    procedure tbSizeMinusClick(Sender: TObject);
    procedure tbSizePlusClick(Sender: TObject);
    procedure tbMoveZeroClick(Sender: TObject);
    procedure tbEdgeZeroClick(Sender: TObject);
    procedure tbEdgeLeftClick(Sender: TObject);
    procedure tbEdgeRightClick(Sender: TObject);
    procedure tbAlignGlyphClick(Sender: TObject);
    procedure tbPinClick(Sender: TObject);
    procedure tbAlignTopClick(Sender: TObject);
    procedure tbAlignBottomClick(Sender: TObject);
    procedure tbAlignMiddleClick(Sender: TObject);
    procedure tbAlignHeightClick(Sender: TObject);
    procedure tbAlignCenterClick(Sender: TObject);
    procedure tbCancelClick(Sender: TObject);
    procedure tbApplyClick(Sender: TObject);
    procedure tbPasteClick(Sender: TObject);
    procedure tbUndoClick(Sender: TObject);
    procedure tbRedoClick(Sender: TObject);
  private
    { Private declarations }
    MouseStart, ZeroXY:TPoint;
    fSelectedIdx:word;
    fBaseChar:char;
    fBaseRect:TRect;
    fCharRect:TRect;
    EditSVG:TSVG;
    EdgeDelta:integer;
    OldSVG:string;
    BaseSvg:string;
  public
    fSelectedChar:char;
    { Public declarations }
    procedure SetGlyph(Chr:Char;Id:word;aSVG:string);
    procedure ApplyToSelection(AEvent:TNotifyEvent; ACaption: string);
  end;

var
  FormGlyph: TFormGlyph;

implementation

{$R *.dfm}

uses  u_MainForm, PT_UnicodeNames, Math, dy_TTFHelper, System.Types, u_TtfForm, clipbrd;

const
   zm:array[0..5] of single=(2,1,1/2,1/4,1/8,1/16);

{ TFormGlyph }

procedure TFormGlyph.ApplyToSelection(AEvent: TNotifyEvent; ACaption: string);
var
  li,sel: TListItem;

begin
  if FormTTF.lv_Font.SelCount = 0 then exit;

  if Application.MessageBox(pchar(
    format('Apply %s to %d selected glyphs?',[ACaption, FormTTF.lv_Font.SelCount])),
    'Confirmation',MB_YESNO) <> id_yes
  then exit;

  sel := FormTTF.lv_Font.Selected;
  li := nil;
  repeat
    li := FormTTF.lv_Font.GetNextItem(li,sdAll,[isSelected]);
    if li <> nil then
    begin
      SetGlyph(char(Li.ImageIndex), StrToIntDef(Li.SubItems[0],0),FormMain.dyTTF.GetSVG(StrToIntDef(Li.SubItems[0],0)));
      AEvent(Nil);
      dyTTF.FontFace.hmtx[fSelectedIdx].Width := dyTTF.FontFace.hmtx[fSelectedIdx].Width + EdgeDelta;
      if EditSVG.Source <> '' then
         FormMain.dyTTF.SetSVG(fSelectedIdx, FormMain.FixedSVG(EditSVG, fSelectedIdx, 0));
      FormTTF.lv_Font.UpdateItems(li.Index, li.Index);
      if li.Focused then
        sel := li;

    end;
  until li=nil;

  SetGlyph(char(sel.ImageIndex), StrToIntDef(sel.SubItems[0],0),FormMain.dyTTF.GetSVG(StrToIntDef(sel.SubItems[0],0)));
end;

procedure TFormGlyph.cb_ScaleChange(Sender: TObject);
begin
  pnt_Draw.Invalidate;
end;

procedure TFormGlyph.FormCreate(Sender: TObject);
begin
  inherited;
  tbZeroClick(Sender);
  EditSVG:=TSVG.Create;

end;

procedure TFormGlyph.pnt_DrawDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
var
  pnt:TPoint;
begin
  if Source = Sender then
  begin
    pnt := TControl(Source).ScreenToClient(TControl(Sender).ClientToScreen(Point(x,y)));

    if Source is TPaintBox then
    begin
      ZeroXY.x := ZeroXY.x + MouseStart.x - Mouse.CursorPos.x;
      ZeroXY.y := ZeroXY.y + MouseStart.y - Mouse.CursorPos.y;
      MouseStart := Mouse.CursorPos;
      pnt_DrawPaint(pnt_Draw)
    end;
    Accept := True
  end
{
  else if (Source = lv_DirSVG)and(lv_DirSVG.SelCount=1)  then   Accept := True}
 else
    Accept := False;


end;

procedure TFormGlyph.pnt_DrawMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   pnt_Draw.BeginDrag(True)
end;

procedure TFormGlyph.pnt_DrawPaint(Sender: TObject);
var z:single;
  SVG : TSVG;
  x,y:integer;
  sz:TRectF;
  procedure NormalizeSvg;
  begin
    SVG.Width := 0;
    SVG.Height := 0;

    FormMain.AddOutline(SVG);

    if SVG.Width>SVG.ViewBox.Width then
    begin
      SVG.ViewBox.Width := max(SVG.Width,SVG.Height);
      SVG.ViewBox.Height := SVG.ViewBox.Width;
    end;

    if SVG.ViewBox.Width=0 then
      SVG.ViewBox.Create(0,-dyTTF.FontFace.ascent,dyTTF.FontFace.units_per_em,dyTTF.FontFace.units_per_em - dyTTF.FontFace.ascent)
    else
      Svg.LocalMatrix  := Svg.InitialMatrix.Create(1, 0, 0, 1, 0, dyTTF.FontFace.ascent / dyTTF.FontFace.units_per_em * SVG.ViewBox.Height);
  end;

begin
  z := zm[cb_Scale.ItemIndex];
  SVG := TSVG.Create;
  try

    with pnt_Draw.Canvas do
    begin
      pen.Style := psClear;
      Brush.Color := clWhite;
      Rectangle(0,0, pnt_Draw.Width+1, pnt_Draw.Height+1);

      if seGrid.Value>4 then
        for x:= 0 to pnt_Draw.Width div seGrid.Value+1 do
          for y:= 0 to pnt_Draw.Height div seGrid.Value+1 do
            Pixels[x * seGrid.Value - (seGrid.Value + ZeroXY.x mod seGrid.Value) mod seGrid.Value,
            y * seGrid.Value - (seGrid.Value + (-round(dyTTF.FontFace.ascent* z) + ZeroXY.y)  mod seGrid.Value) mod seGrid.Value] := clBlack;

      Pen.Style := psDot;
      Pen.Color := clRed;
      MoveTo(-ZeroXY.X,0);LineTo(-ZeroXY.X,pnt_Draw.Height);
      Font.Color := Pen.Color;
      Font.Name := 'Tahoma';
      Font.Size := 8;
      TextOut(-ZeroXY.X - TextExtent('X: 0').Width-4 ,0,'X: 0');


      MoveTo(0,-ZeroXY.Y + round(dyTTF.FontFace.ascent* z));LineTo(pnt_Draw.Width,-ZeroXY.Y+ round(dyTTF.FontFace.ascent* z));
      TextOut(pnt_Draw.Width - TextExtent('Baseline').Width-4 ,-ZeroXY.Y + round(dyTTF.FontFace.ascent* z)+1,'Baseline');

      Pen.Color := clBlue;
      Font.Color := Pen.Color;

      MoveTo(0,-ZeroXY.Y);LineTo(pnt_Draw.Width,-ZeroXY.Y);
      TextOut(pnt_Draw.Width - TextExtent('Ascent: '+IntToStr(dyTTF.FontFace.Ascent)).Width-4 ,
        -ZeroXY.Y + Font.Height-2,
        'Ascent: '+IntToStr(dyTTF.FontFace.Ascent));
      MoveTo(0,-ZeroXY.Y + round(dyTTF.FontFace.units_per_em* z));LineTo(pnt_Draw.Width,-ZeroXY.Y+round(dyTTF.FontFace.units_per_em* z));
      TextOut(pnt_Draw.Width - TextExtent('Descent: '+IntToStr(dyTTF.FontFace.Descent)).Width-4 ,
        -ZeroXY.Y + round(dyTTF.FontFace.units_per_em* z) +1,
        'Descent: '+IntToStr(dyTTF.FontFace.Descent));

//      TextOut(0,0, IntToStr(-ZeroXY.X)+':'+IntToStr(-ZeroXY.Y) );

      Pen.Color := clSilver;
      Font.Color := clBlack;
      MoveTo(0,-ZeroXY.Y + round((dyTTF.FontFace.ascent - dyTTF.FontFace.Cap_Height)* z));LineTo(pnt_Draw.Width,-ZeroXY.Y+ round((dyTTF.FontFace.ascent-dyTTF.FontFace.Cap_Height) * z));
      TextOut(pnt_Draw.Width - TextExtent('Cap.Height: '+IntToStr(dyTTF.FontFace.Cap_Height)).Width-4 ,
        -ZeroXY.Y + round((dyTTF.FontFace.ascent - dyTTF.FontFace.Cap_Height)* z) + 1,
        'Cap.Height: '+IntToStr(dyTTF.FontFace.Cap_Height));


      MoveTo(0,-ZeroXY.Y + round((dyTTF.FontFace.ascent - dyTTF.FontFace.X_Height)* z));LineTo(pnt_Draw.Width,-ZeroXY.Y+ round((dyTTF.FontFace.ascent-dyTTF.FontFace.X_Height)* z));
      TextOut(pnt_Draw.Width - TextExtent('X-Height: '+IntToStr(dyTTF.FontFace.X_Height)).Width-4 ,
        -ZeroXY.Y + round((dyTTF.FontFace.ascent - dyTTF.FontFace.X_Height)* z)+ 1,
        'X-Height: '+IntToStr(dyTTF.FontFace.X_Height));

      Pen.Color := clLime;
      Font.Color := clGreen;

      if fSelectedIdx >0 then
      begin
        MoveTo(-ZeroXY.X + round(z* (dyTTF.FontFace.hmtx[fSelectedIdx].Width+EdgeDelta)) ,0);
        LineTo(-ZeroXY.X+ round(z* (dyTTF.FontFace.hmtx[fSelectedIdx].Width+EdgeDelta)), pnt_Draw.Height);
        TextOut(-ZeroXY.X + round(z* (dyTTF.FontFace.hmtx[fSelectedIdx].Width+EdgeDelta)) + 4, 0,
          'Right: '+IntToStr(dyTTF.FontFace.hmtx[fSelectedIdx].Width+EdgeDelta));
      end;

      SetBkMode(Handle, TRANSPARENT );
      Font.Assign(dyTTF);
      Font.Height := -round(dyTTF.FontFace.units_per_em * z);

      if tbPin.Down then
      begin
        Font.Color := clSilver;
        TextOut(-ZeroXY.X-TextWidth(fBaseChar) , -ZeroXY.Y + round(z*(dyTTF.FontFace.ascent - dyTTF.FontFace.winascent)) , fBaseChar);
        if BaseSvg='' then
          TextOut(-ZeroXY.X + round(z* (dyTTF.FontFace.hmtx[fSelectedIdx].Width + EdgeDelta) ) , -ZeroXY.Y + round(z*(dyTTF.FontFace.ascent - dyTTF.FontFace.winascent)) , fBaseChar)
        else
        begin
          svg.LoadFromText(BaseSvg);
          SVG.Grayscale := True;
          NormalizeSvg;
          SVG.PaintTo(pnt_Draw.Canvas.Handle, -ZeroXY.X + round(z* (dyTTF.FontFace.hmtx[fSelectedIdx].Width + EdgeDelta) )  , -ZeroXY.Y ,dyTTF.FontFace.units_per_em * z, dyTTF.FontFace.units_per_em * z);
          SVG.Grayscale := False;
        end;
      end;

      Font.Color := clBlack;
    end;

    SVG.LoadFromText(EditSVG.Source);
    SVG.ViewBox.Create(EditSvg.ViewBox);
    NormalizeSvg;
    if SVG.Source='' then
      pnt_Draw.Canvas .TextOut(-ZeroXY.X, -ZeroXY.Y + round(z*(dyTTF.FontFace.ascent - dyTTF.FontFace.winascent)) , fSelectedChar)
    else
      SVG.PaintTo(pnt_Draw.Canvas.Handle, -ZeroXY.X , -ZeroXY.Y ,dyTTF.FontFace.units_per_em * z, dyTTF.FontFace.units_per_em * z);

  finally
   SVG.free;

  end;

end;

procedure TFormGlyph.pnt_DrawStartDrag(Sender: TObject;
  var DragObject: TDragObject);
begin
  MouseStart := Mouse.CursorPos;
end;

procedure TFormGlyph.seGridChange(Sender: TObject);
begin
  pnt_Draw.Invalidate;
end;

procedure TFormGlyph.SetGlyph(Chr: Char; Id: word; aSVG: string);
var
  GlyphMetrics  : TGlyphMetrics;
  Matrix        : TMat2;
  Idx:word;
  s:string;
begin
  if fSelectedChar <> #0 then
    tbApplyClick(Nil);

  Caption := 'Glyph: '+Chr +' ' +IntToHex(ord(chr),4) +  ' ('+GetUnicodeName(ord(chr)) +') #'+IntToStr(Id);
  OldSVG := aSVG;
  EditSVG.LoadFromText(aSVG);
  EdgeDelta:=0;

  if EditSVG.ViewBox.Width=0 then
  begin
    if EditSVG.Width = 0 then
      EditSVG.ViewBox.Create(0,0,dyTTF.FontFace.units_per_em,dyTTF.FontFace.units_per_em)
    else
      EditSVG.ViewBox.Create(0,max(EditSVG.Width,EditSVG.Height),max(EditSVG.Width,EditSVG.Height), max(EditSVG.Width,EditSVG.Height));

  end;
  EditSVG.Width := 0;
  EditSVG.Height := 0;


  fSelectedIdx := id;
  fSelectedChar := Chr;

  if not tbPin.Down then
    tbPin.Click
  else
    pnt_Draw.Invalidate;


  with Matrix do begin
    eM11.Value := 1;
    eM11.fract :=0;
    eM12.Value := 0;
    eM12.fract :=0;
    eM21.Value := 0;
    eM21.fract :=0;
    eM22.Value := 1;
    eM22.fract :=0;
  end;
  dyTTF.Height := -dyTTF.FontFace.units_per_em;
  idx:= ord(chr);

  GetGlyphOutline(dyTTF.Canvas.Handle, idx, GGO_METRICS, GlyphMetrics, 0, nil, Matrix);

  fCharRect.Create(GlyphMetrics.gmptGlyphOrigin.X,
                   -GlyphMetrics.gmptGlyphOrigin.Y +dyTTF.FontFace.ascent,
                   GlyphMetrics.gmptGlyphOrigin.X + GlyphMetrics.gmBlackBoxX,
                   -GlyphMetrics.gmptGlyphOrigin.Y + GlyphMetrics.gmBlackBoxY+dyTTF.FontFace.ascent);

end;

procedure TFormGlyph.tbZeroClick(Sender: TObject);
begin
  ZeroXY.Y := -32;
  ZeroXY.X := -32;
  pnt_Draw.Invalidate;
end;


procedure TFormGlyph.tbSizeMinusClick(Sender: TObject);
var
  sz:TRectF;
  d,s:single;
begin
  if (FormTTF.lv_Font.SelCount=1) or (Sender=nil) then
  begin
    sz := FormMain.SvgSize(EditSVG,True);
    d := max(sz.Width,sz.Height);
    if d<>0 then
    begin
      s := seGrid.Value / zm[cb_Scale.ItemIndex] * EditSVG.ViewBox.width /dyTTF.FontFace.units_per_em;
      EditSVG.ViewBox.width := EditSVG.ViewBox.width + s * (EditSVG.ViewBox.width/d)   ;
      EditSVG.ViewBox.Height :=EditSVG.ViewBox.width;
    end;
  end
  else
    ApplyToSelection(tbSizeMinusClick, '"Reduce size"');

  pnt_Draw.Invalidate

end;

procedure TFormGlyph.tbMoveZeroClick(Sender: TObject);
var
  sz:TRectF;
  d,s:single;
begin
  if (FormTTF.lv_Font.SelCount=1) or (Sender=nil) then
  begin
    sz := FormMain.SvgSize(EditSVG,True);
    EdgeDelta := EdgeDelta - round(sz.Left);
    EditSVG.ViewBox.Offset(sz.Left,0);
  end
  else
    ApplyToSelection(tbMoveZeroClick,'"Pinch left"');
  pnt_Draw.Invalidate
end;



procedure TFormGlyph.tbPasteClick(Sender: TObject);
begin
  if pos('<svg',clipboard.AsText)=0 then exit;

  EditSVG.LoadFromText(clipboard.AsText);
  pnt_Draw.Invalidate
end;

procedure TFormGlyph.tbPinClick(Sender: TObject);

var
  GlyphMetrics  : TGlyphMetrics;
  Matrix        : TMat2;
  Idx:word;
  sz:TRectF;
  wk:single;
begin
  if FormTTF.lv_Font.Selected = nil then exit;

  fBaseChar := fSelectedChar;

  if EditSVG.Source='' then
   begin
     BaseSvg := '';

     with Matrix do begin
       eM11.Value := 1;
       eM11.fract :=0;
       eM12.Value := 0;
       eM12.fract :=0;
       eM21.Value := 0;
       eM21.fract :=0;
       eM22.Value := 1;
       eM22.fract :=0;
     end;
     dyTTF.Height := -dyTTF.FontFace.units_per_em;
     idx:= ord(fBaseChar);

     GetGlyphOutline(dyTTF.Canvas.Handle, idx, GGO_METRICS, GlyphMetrics, 0, nil, Matrix);

     fBaseRect.Create(GlyphMetrics.gmptGlyphOrigin.X,
                   -GlyphMetrics.gmptGlyphOrigin.Y +dyTTF.FontFace.ascent,
                   GlyphMetrics.gmptGlyphOrigin.X + GlyphMetrics.gmBlackBoxX,
                   -GlyphMetrics.gmptGlyphOrigin.Y + GlyphMetrics.gmBlackBoxY+dyTTF.FontFace.ascent);
   end
   else begin
     wk := EditSVG.ViewBox.Height / dyTTF.FontFace.units_per_em;
     sz := FormMain.SvgSize(EditSVG,True);
     fBaseRect.Create(Point(Round(sz.Left / wk),
                      Round(sz.Top / wk + dyTTF.FontFace.ascent)),
                      Round(sz.Width / wk),
                      Round(sz.Height / wk));
      BaseSvg := EditSVG.Source;
   end;
  pnt_Draw.Invalidate;
end;

procedure TFormGlyph.tbRedoClick(Sender: TObject);
var idx:integer;
begin
  if (FormTTF.lv_Font.SelCount=1) or (Sender=nil) then
  begin
    idx:=FormMain.dyTTF.GetSVGIndex(fSelectedIdx);
    if idx<0 then exit;
    EditSVG.LoadFromText(TSVGObject(FormMain.dyTTF.SVGFiles.Items[idx]).Redo);
    FormGlyph.SetGlyph(fSelectedChar, fSelectedIdx, EditSVG.Source);
  end
  else
    ApplyToSelection(tbRedoClick,'"Redo"');
  pnt_Draw.Invalidate;
end;

procedure TFormGlyph.tbMoveLeftClick(Sender: TObject);
begin
  if (FormTTF.lv_Font.SelCount=1) or (Sender=nil) then
  begin
    EditSVG.ViewBox.Offset(seGrid.Value / zm[cb_Scale.ItemIndex]* EditSVG.ViewBox.Height/dyTTF.FontFace.units_per_em,0);
    EdgeDelta := EdgeDelta - round(seGrid.Value / zm[cb_Scale.ItemIndex]* EditSVG.ViewBox.Height/dyTTF.FontFace.units_per_em);
  end
  else
    ApplyToSelection(tbMoveLeftClick,'"Move left"');
  pnt_Draw.Invalidate
end;

procedure TFormGlyph.tbMoveRightClick(Sender: TObject);
begin
  if (FormTTF.lv_Font.SelCount=1) or (Sender=nil) then
  begin
    EditSVG.ViewBox.Offset(-seGrid.Value / zm[cb_Scale.ItemIndex]* EditSVG.ViewBox.Height/dyTTF.FontFace.units_per_em,0);
    EdgeDelta := EdgeDelta + round(seGrid.Value / zm[cb_Scale.ItemIndex]* EditSVG.ViewBox.Height/dyTTF.FontFace.units_per_em);
  end
  else
    ApplyToSelection(tbMoveRightClick,'"Move right"');
  pnt_Draw.Invalidate
end;

procedure TFormGlyph.tbMoveUpClick(Sender: TObject);
begin
  if (FormTTF.lv_Font.SelCount=1) or (Sender=nil) then
  begin
    EditSVG.ViewBox.Offset(0, seGrid.Value / zm[cb_Scale.ItemIndex]* EditSVG.ViewBox.Height/dyTTF.FontFace.units_per_em);
  end
  else
    ApplyToSelection(tbMoveUpClick,'"Move up"');

  pnt_Draw.Invalidate
end;

procedure TFormGlyph.tbAlignBottomClick(Sender: TObject);
var
  sz:TRectF;
  wk:single;
begin
  if (FormTTF.lv_Font.SelCount=1) or (Sender=nil) then
  begin
     wk := EditSVG.ViewBox.Height / dyTTF.FontFace.units_per_em;

    sz := FormMain.SvgSize(EditSVG,True);
    sz.Offset(0, dyTTF.FontFace.ascent*wk);

    EditSVG.ViewBox.Offset(0,  sz.Bottom - (fBaseRect.Bottom ) *wk);
  end
  else
    ApplyToSelection(tbAlignBottomClick,'"Align bottom"');

  pnt_Draw.Invalidate
end;

procedure TFormGlyph.tbAlignCenterClick(Sender: TObject);
var
  sz:TRectF;
begin
  if (FormTTF.lv_Font.SelCount=1) or (Sender=nil) then
  begin
    sz := FormMain.SvgSize(EditSVG,True);
    EditSVG.ViewBox.Offset( sz.CenterPoint.x - (fBaseRect.CenterPoint.x ) / dyTTF.FontFace.units_per_em * EditSVG.ViewBox.Height,0);
  end
  else
    ApplyToSelection(tbAlignCenterClick,'"Align center"');

  pnt_Draw.Invalidate
end;

procedure TFormGlyph.tbAlignGlyphClick(Sender: TObject);
var
  sz:TRectF;
begin
  if FormTTF.lv_Font.Selected = nil then exit;

  if (FormTTF.lv_Font.SelCount=1) or (Sender=nil) then
  begin
    sz := FormMain.SvgSize(EditSVG,True);
    EditSVG.ViewBox.Offset(sz.CenterPoint.x -  (dyTTF.FontFace.hmtx[fSelectedIdx].Width+EdgeDelta)/2 / dyTTF.FontFace.units_per_em * EditSVG.ViewBox.Height  , 0);
  end
  else
    ApplyToSelection(tbAlignGlyphClick, '"Align middle"');

  pnt_Draw.Invalidate
end;

procedure TFormGlyph.tbAlignHeightClick(Sender: TObject);
var
  sz:TRectF;
begin
  if (FormTTF.lv_Font.SelCount=1) or (Sender=nil) then
  begin
    if EditSVG.Source='' then exit;

    sz := FormMain.SvgSize(EditSVG,True);
    sz.Offset(0, dyTTF.FontFace.ascent);

    EditSVG.ViewBox.Height := EditSVG.ViewBox.Height * sz.Height / (fBaseRect.Height / dyTTF.FontFace.units_per_em * EditSVG.ViewBox.Height);
    EditSVG.ViewBox.Width := EditSVG.ViewBox.Height;
  end
  else
    ApplyToSelection(tbAlignHeightClick, '"Align height"');

  pnt_Draw.Invalidate
end;

procedure TFormGlyph.tbAlignMiddleClick(Sender: TObject);
var
  sz:TRectF;
  wk:single;
begin
  if (FormTTF.lv_Font.SelCount=1) or (Sender=nil) then
  begin
    wk := EditSVG.ViewBox.Height / dyTTF.FontFace.units_per_em;

    sz := FormMain.SvgSize(EditSVG,True);
    sz.Offset(0, dyTTF.FontFace.ascent*wk);

    EditSVG.ViewBox.Offset(0,  sz.CenterPoint.y - fBaseRect.CenterPoint.y * wk);
  end
  else
    ApplyToSelection(tbAlignMiddleClick, '"Align Middle"');

  pnt_Draw.Invalidate
end;



procedure TFormGlyph.tbAlignTopClick(Sender: TObject);
var
  sz:TRectF;
  wk:single;
begin
  if (FormTTF.lv_Font.SelCount=1) or (Sender=nil) then
  begin
    wk := EditSVG.ViewBox.Height / dyTTF.FontFace.units_per_em;

    sz := FormMain.SvgSize(EditSVG,False);
    sz.Offset(0, dyTTF.FontFace.ascent*wk);

    EditSVG.ViewBox.Offset(0, sz.top - (fBaseRect.Top) * wk)  ;
  end
  else
    ApplyToSelection(tbAlignTopClick,'"Align Top"');


  pnt_Draw.Invalidate
end;


procedure TFormGlyph.tbApplyClick(Sender: TObject);
begin
  if FormTTF.lv_Font.GetCount=0 then exit;
  if fSelectedChar=#0 then exit;

  dyTTF.FontFace.hmtx[fSelectedIdx].Width := dyTTF.FontFace.hmtx[fSelectedIdx].Width + EdgeDelta;
  EdgeDelta := 0;

  if EditSVG.Source='' then exit;

  FormMain.dyTTF.SetSVG(fSelectedIdx, FormMain.FixedSVG(EditSVG, fSelectedIdx, 0));
  if FormTTF.lv_Font.Selected <> nil then
    FormTTF.lv_Font.UpdateItems(FormTTF.lv_Font.Selected.Index,FormTTF.lv_Font.Selected.Index);
end;

procedure TFormGlyph.tbCancelClick(Sender: TObject);
begin
  if FormTTF.lv_Font.Selected = nil then exit;
  SetGlyph(fSelectedChar, fSelectedIdx, OldSVG);
end;

procedure TFormGlyph.tbEdgeLeftClick(Sender: TObject);
begin
  if (FormTTF.lv_Font.SelCount=1) or (Sender=nil) then
  begin
    EdgeDelta := EdgeDelta
    - round(seGrid.Value / zm[cb_Scale.ItemIndex] * EditSVG.ViewBox.width /dyTTF.FontFace.units_per_em);
  end
  else
    ApplyToSelection(tbEdgeLeftClick, '"Edge Left"');

  pnt_Draw.Invalidate
end;

procedure TFormGlyph.tbEdgeRightClick(Sender: TObject);
begin
  if (FormTTF.lv_Font.SelCount=1) or (Sender=nil) then
  begin
    EdgeDelta := EdgeDelta
    + round(seGrid.Value / zm[cb_Scale.ItemIndex] * EditSVG.ViewBox.width /dyTTF.FontFace.units_per_em);
  end
  else
    ApplyToSelection(tbEdgeRightClick, '"Edge Right"');

  pnt_Draw.Invalidate

end;


procedure TFormGlyph.tbEdgeZeroClick(Sender: TObject);
var
  sz:TRectF;
  li:TListItem;
begin
  if FormTTF.lv_Font.Selected = nil then exit;

  if (FormTTF.lv_Font.SelCount=1) or (Sender=nil) then
  begin
    if EditSVG.Source='' then
      sz := fCharRect
    else
      sz := FormMain.SvgSize(EditSVG,True);

     EdgeDelta := round(sz.Right/EditSVG.ViewBox.Height*dyTTF.FontFace.units_per_em - dyTTF.FontFace.hmtx[fSelectedIdx].Width);
  end
  else
    ApplyToSelection(tbEdgeZeroClick,'"Zero Edge"');

  pnt_Draw.Invalidate
end;

procedure TFormGlyph.tbMoveDownClick(Sender: TObject);
begin
  if (FormTTF.lv_Font.SelCount=1) or (Sender=nil) then
  begin
    EditSVG.ViewBox.Offset(0, -seGrid.Value / zm[cb_Scale.ItemIndex]* EditSVG.ViewBox.Height/dyTTF.FontFace.units_per_em);
  end
  else
    ApplyToSelection(tbMoveDownClick,'"Move Down"');

  pnt_Draw.Invalidate
end;

procedure TFormGlyph.tbSizePlusClick(Sender: TObject);
var
  sz:TRectF;
  d,s:single;
begin
  if (FormTTF.lv_Font.SelCount=1) or (Sender=nil) then
  begin
    sz := FormMain.SvgSize(EditSVG,True);
    d := max(sz.Width,sz.Height);
    if d<>0 then
    begin
      s := seGrid.Value / zm[cb_Scale.ItemIndex] * EditSVG.ViewBox.width /dyTTF.FontFace.units_per_em ;
      EditSVG.ViewBox.width := EditSVG.ViewBox.width - s * (EditSVG.ViewBox.width/d)   ;
      EditSVG.ViewBox.Height :=EditSVG.ViewBox.width ;
    end;
  end
  else
    ApplyToSelection(tbSizePlusClick,'"Enlarge size"');

  pnt_Draw.Invalidate
end;

procedure TFormGlyph.tbUndoClick(Sender: TObject);
var idx:integer;
begin
  if (FormTTF.lv_Font.SelCount=1) or (Sender=nil) then
  begin
    idx:=FormMain.dyTTF.GetSVGIndex(fSelectedIdx);
    if idx<0 then exit;
    EditSVG.LoadFromText(TSVGObject(FormMain.dyTTF.SVGFiles.Items[idx]).Undo);
    FormGlyph.SetGlyph(fSelectedChar, fSelectedIdx, EditSVG.Source);
  end
  else
    ApplyToSelection(tbUndoClick,'"Undo"');
  pnt_Draw.Invalidate;
end;

end.
