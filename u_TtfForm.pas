unit u_TtfForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.WinXCtrls,
  Vcl.ComCtrls, Vcl.ToolWin, u_BaseDockForm, Vcl.StdCtrls, Vcl.Grids, dy_TTFHelper,
  System.ImageList, Vcl.ImgList, System.Types, System.Actions, Vcl.ActnList,
  Vcl.Menus;

type
  TFormTTF = class(TBaseDockForm)
    Panel1: TPanel;
    PageScroller1: TPageScroller;
    tbrTTF: TToolBar;
    tbOpenTTF: TToolButton;
    tbSaveFont: TToolButton;
    ToolButton5: TToolButton;
    tbCopySVG: TToolButton;
    tbPasteSVG: TToolButton;
    ToolButton13: TToolButton;
    tbClearSVG: TToolButton;
    tbRootfolder: TToolButton;
    tbExportFolder: TToolButton;
    tbImportFolder: TToolButton;
    ToolButton11: TToolButton;
    tbPin: TToolButton;
    tbFontInfo: TToolButton;
    Panel4: TPanel;
    chbOutline: TCheckBox;
    cb_SizeGlyph: TComboBox;
    lv_Font: TListView;
    SplitView1: TSplitView;
    pn_FontName: TPanel;
    rgd_Tables: TStringGrid;
    me_FontFace: TMemo;
    lbUnicodeRegions: TListBox;
    il_Glyph: TImageList;
    tbExportSel: TToolButton;
    tbImportSel: TToolButton;
    ToolButton3: TToolButton;
    pmFont: TPopupMenu;
    Copy1: TMenuItem;
    Paste1: TMenuItem;
    CleraSVG1: TMenuItem;
    aSaveSVG1: TMenuItem;
    Applyto1: TMenuItem;
    Pin1: TMenuItem;
    N1: TMenuItem;
    procedure tbFontInfoClick(Sender: TObject);
    procedure lv_FontCustomDrawItem(Sender: TCustomListView; Item: TListItem;
      State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure cb_SizeGlyphChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure lv_FontSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure chbOutlineClick(Sender: TObject);
    procedure lv_FontDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure lv_FontDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure aCopyExecute(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    Metrics: tagTEXTMETRICW;
    SvgRow: integer;
    procedure PrepareGrid(dyTTF:TdyTTF);
  end;

var
  FormTTF: TFormTTF;

implementation

{$R *.dfm}

uses u_MainForm, SVG, math, u_GlyphForm, clipbrd, u_FolderSVGForm;

procedure TFormTTF.aCopyExecute(Sender: TObject);
begin
  Clipboard.AsText := dyTTF.GetSVG(StrToIntDef(lv_Font.Selected.SubItems[0],0));
end;

procedure TFormTTF.cb_SizeGlyphChange(Sender: TObject);
var
  tmp:TImageList;
begin
  lv_Font.OnCustomDrawItem := nil;
  FormMain.dyTTF.Height := -sz[cb_SizeGlyph.ItemIndex];
  GetTextMetrics(FormMain.dyTTF.Canvas.Handle, METRICS);
{
  tmp:=TImageList.Create(self);
  tmp.Width := 2*sz[cb_SizeGlyph.ItemIndex];
  tmp.Height := sz[cb_SizeGlyph.ItemIndex]+16;
  lv_Font.LargeImages := tmp;
  il_Glyph.free;
  il_Glyph := tmp;
}
  il_Glyph.Width := 2*sz[cb_SizeGlyph.ItemIndex];
  il_Glyph.Height := sz[cb_SizeGlyph.ItemIndex]+16;
  if lv_Font.Selected <> nil then
    lv_Font.Selected.MakeVisible(False);
  lv_Font.OnCustomDrawItem := lv_FontCustomDrawItem;
end;

procedure TFormTTF.chbOutlineClick(Sender: TObject);
begin
  lv_Font.Invalidate;
  FormSvgFolder.lv_DirSVG.Invalidate;
end;

procedure TFormTTF.FormCreate(Sender: TObject);
begin
  inherited;
  rgd_Tables.Rows[0].CommaText := 'TAG,Checksum,Offset,Length,Count';
  cb_SizeGlyphChange(Sender)
end;

procedure TFormTTF.lv_FontCustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
var
  Ch:char;
  Idx:word;
  SVG:TSVG;
  BMP:TBitmap;
  s:string;
  Rect:TRect;
  kf:single;
  dy:integer;
  i:integer;
  dyTTF:TDyTTF;
begin
  Rect := Item.DisplayRect(drIcon);
  if Rect.Width =0 then exit;
  dyTTF := FormMain.dyTTF;




  ch := char(Item.ImageIndex);

  Sender.Canvas.Font.Assign(dyTTF);
  Sender.Canvas.Font.Height  := -sz[cb_SizeGlyph.ItemIndex];


  kf := -Sender.Canvas.Font.Height / dyTTF.FontFace.units_per_em;
  dy := METRICS.tmAscent + 4 - round(kf * dyTTF.FontFace.ascent);

  Sender.Canvas.Pen.Style := psDot;
  Sender.Canvas.Pen.Color := clRed;
  // Glypp right
  Sender.Canvas.MoveTo(Rect.Left+8, Rect.Top);
  Sender.Canvas.LineTo(Rect.Left+8, Rect.Bottom);


  // Baseline
  Sender.Canvas.MoveTo(Rect.Left,Rect.Top+METRICS.tmAscent+3);
  Sender.Canvas.LineTo(Rect.Right-8,Rect.Top+METRICS.tmAscent+3);

  Sender.Canvas.Pen.Color := clSilver;
  // SVG right
  Sender.Canvas.MoveTo(Rect.CenterPoint.x, Rect.Top);
  Sender.Canvas.LineTo(Rect.CenterPoint.x, Rect.Bottom);



  Sender.Canvas.Pen.Color := clBlue;
//  Sender.Canvas.Pen.Style := psSolid;

  Sender.Canvas.MoveTo(Rect.Left,Rect.Top+METRICS.tmAscent+4 - round(kf * dyTTF.FontFace.descent));
  Sender.Canvas.LineTo(Rect.Right-8,Rect.Top+METRICS.tmAscent+4 - round(kf * dyTTF.FontFace.descent));

  Sender.Canvas.MoveTo(Rect.Left,Rect.Top+dy);
  Sender.Canvas.LineTo(Rect.Right-8,Rect.Top+dy);



  GetGlyphIndices(Sender.Canvas.Handle, @ch, 1, @Idx,0);

  if Idx>0 then
  begin
//    Rect := Item.DisplayRect(drIcon);

    Sender.Canvas.Pen.Color := clLime;

    SetBkMode(Sender.Canvas.Handle, TRANSPARENT );

    Sender.Canvas.TextOut(Rect.Left+8,Rect.Top+4, ch);
    Sender.Canvas.MoveTo(round(Rect.Left+8+dyTTF.FontFace.hmtx[Idx].Width * kf), Rect.Top);
    Sender.Canvas.LineTo(Sender.Canvas.PenPos.X, Rect.Bottom);



//    Sender.Canvas.TextExtent(ch).Width
//--ExtTextOut(Sender.Canvas.Handle, Rect.Left+8,Rect.Top+8, 0  , nil, ch,   2, nil);
    s:= dyTTF.GetSVG(Idx);
    if s<>'' then
    try
      Sender.Canvas.MoveTo(Sender.Canvas.PenPos.X + Rect.Width div 2 - 8  , Rect.Top);
      Sender.Canvas.LineTo(Sender.Canvas.PenPos.X, Rect.Bottom);

      Sender.Canvas.Pen.Color := clRed;
     // SVG right
     Sender.Canvas.MoveTo(Rect.CenterPoint.x, Rect.Top);
     Sender.Canvas.LineTo(Rect.CenterPoint.x, Rect.Bottom);

      SVG:=TSVG.Create;
      SVG.LoadFromText(s);
      if chbOutline.Checked then
        FormMain.AddOutline(SVG);

      if SVG.Width>SVG.ViewBox.Width then
      begin
        SVG.ViewBox.Width := max(SVG.Width,SVG.Height);
        SVG.ViewBox.Height := SVG.ViewBox.Width;
      end;

      if SVG.ViewBox.Width=0 then
        SVG.ViewBox.Create(0,-dyTTF.FontFace.ascent,dyTTF.FontFace.units_per_em,dyTTF.FontFace.units_per_em - dyTTF.FontFace.ascent)
      else begin
        Svg.LocalMatrix  := Svg.InitialMatrix.Create(1, 0, 0, 1, 0, dyTTF.FontFace.ascent / dyTTF.FontFace.units_per_em * SVG.ViewBox.Height);
      end;

      SVG.PaintTo(Sender.Canvas.Handle,rect.CenterPoint.x, rect.Top+dy,-Sender.Canvas.Font.Height,-Sender.Canvas.Font.Height);

    finally
      SVG.Free;
    end;
  end;

  Sender.Canvas.Font.Name := 'Tahoma';
  Sender.Canvas.Font.Size := 8;
  Sender.Canvas.Font.Style := [];

end;

procedure TFormTTF.lv_FontDragDrop(Sender, Source: TObject; X, Y: Integer);
var Itm: TListItem;
  Img:TSVG;
  RF:TRectF;
  dy:single;
begin
  Itm := lv_Font.GetItemAt(X, Y);
  try
    Img:=TSVG.Create;
    Img.LoadFromFile(FormSvgFolder.lv_DirSVG.Selected.SubItems[0]);

    rf:=FormMain.SvgSize(Img);

    if rf.CenterPoint.y > 0 then
      dy := FormMain.dyTTF.FontFace.ascent
    else
      dy := 0;

    if Img.ViewBox.Width <> Img.ViewBox.Height then
    begin
      Img.ViewBox.Width := max(Img.ViewBox.Height, Img.ViewBox.Width);
      Img.ViewBox.Height := Img.ViewBox.Width
    end;


    if Img.ViewBox.Width=0 then
      Img.ViewBox.Create(0,
                         dy,
                         FormMain.dyTTF.FontFace.units_per_em,
                         FormMain.dyTTF.FontFace.units_per_em + dy)
    else
      Img.ViewBox.Create(Img.ViewBox.Left,
                         Img.ViewBox.Top + dy / FormMain.dyTTF.FontFace.units_per_em * Img.ViewBox.Height,
                         Img.ViewBox.Left + Img.ViewBox.Height,
                         Img.ViewBox.Top + Img.ViewBox.Height + dy/ FormMain.dyTTF.FontFace.units_per_em * Img.ViewBox.Height);

    FormMain.dyTTF.SetSVG(StrToIntDef(Itm.SubItems[0],0), FormMain.FixedSVG(Img, StrToIntDef(Itm.SubItems[0],0), 0));
    lv_Font.UpdateItems(Itm.Index,Itm.Index);
    if Itm=lv_Font.Selected then
      FormGlyph.SetGlyph(char(lv_Font.Selected.ImageIndex), StrToIntDef(lv_Font.Selected.SubItems[0],0),FormMain.dyTTF.GetSVG(StrToIntDef(lv_Font.Selected.SubItems[0],0)));
    rgd_Tables.Cells[4,SvgRow] := IntToStr(dyTTF.SVGFiles.Count);

  finally
    Img.Free;
  end;


end;

procedure TFormTTF.lv_FontDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
  Accept := (Source = FormSvgFolder.lv_DirSVG)  and (lv_Font.GetItemAt(X, Y)<> nil)
end;

procedure TFormTTF.lv_FontSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  inherited;
  FormGlyph.tbApply.Click;
  FormGlyph.SetGlyph(char(Item.ImageIndex), StrToIntDef(Item.SubItems[0],0),FormMain.dyTTF.GetSVG(StrToIntDef(Item.SubItems[0],0)));
end;

procedure TFormTTF.PrepareGrid(dyTTF:TdyTTF);
var
  GS:PGlyphSet;
  GSSize:LongWord;
  wc:char;
  i,j,gr:integer;
  Idx:word;
  s:string;
  LoChr, HiChr:word;

begin
  pn_FontName.Font.Assign(dyTTF);
  pn_FontName.Font.Size := 24;
  pn_FontName.Caption :=  dyTTF.Name;
  caption := 'Font: '+dyTTF.Name;


  lv_Font.OnCustomDrawItem := nil;
  lv_Font.Items.BeginUpdate;

  dyTTF.Height := -sz[cb_SizeGlyph.ItemIndex];
  GetTextMetrics(dyTTF.Canvas.Handle, METRICS);

  me_FontFace.Clear;
  with me_FontFace.Lines do
  begin
    Add('FileName: '+ ExtractFileName(dyTTF.FontFace.FileName));
    Add('Family: '+dyTTF.Name);

    if dyTTF.Style=[] then
      s:='Regular';
    if fsBold in dyTTF.Style then
      s:='Bold';
    if fsItalic in dyTTF.Style then
    begin
      if s<>'' then
        s:=s+', ';
      s:=s+'Italic';
    end;

    Add('Style: '+s);
    Add('Weight: '+IntToStr(dyTTF.FontFace.Weight));
    Add('Em size: '+IntToStr(dyTTF.FontFace.units_per_em));
    Add('Ascent: '+IntToStr(dyTTF.FontFace.ascent));
    Add('Descent: '+IntToStr(dyTTF.FontFace.descent));
  end;


  rgd_Tables.RowCount := length(dyTTF.ttTableDirectory)+1;
  for I := 0 to length(dyTTF.ttTableDirectory) do
  begin
    rgd_Tables.Cells[0,i+1] :=  dyTTF.ttTableDirectory[i].szTag;
    rgd_Tables.Cells[1,i+1] :=  IntToHex(dyTTF.ttTableDirectory[i].uCheckSum,8);
    rgd_Tables.Cells[2,i+1] :=  IntToHex(dyTTF.ttTableDirectory[i].uOffset,8);
    rgd_Tables.Cells[3,i+1] :=  IntToHex(dyTTF.ttTableDirectory[i].uLength,8);
    rgd_Tables.Cells[4,i+1] :=  '';

    if UpperCase(dyTTF.ttTableDirectory[i].szTag)='SVG ' then
    begin
      rgd_Tables.Cells[4,i+1] :=  IntToStr(dyTTF.SVGFiles.Count);
      SvgRow := i+1;
    end;

    if dyTTF.ttTableDirectory[i].szTag='hmtx' then
      rgd_Tables.Cells[4,i+1] :=  IntToStr(dyTTF.FontFace.numGlyphs);

    if dyTTF.ttTableDirectory[i].szTag='glyf' then
      rgd_Tables.Cells[4,i+1] :=  IntToStr(dyTTF.FontFace.numGlyphs);


  end;


  lv_Font.Items.Clear;
  lv_Font.Groups.Clear;

//  NumberBox1ChangeValue(nil);
//  GetTextMetrics(dyTTF.Canvas.Handle, METRICS);



  GSSize := GetFontUnicodeRanges(dyTTF.Canvas.Handle, nil);
  GetMem(Pointer(GS), GSSize);
  GS.cbThis:=GSSize;
  GS.flAccel:=0;
  GS.cGlyphsSupported:=0;
  GS.cRanges:=0;
  if GetFontUnicodeRanges(dyTTF.Canvas.Handle, GS)<>0 then
  begin
      for i:=0 to GS.cRanges-1 do
      if (GS.ranges[i].cGlyphs>0) then
      begin
        wc:=GS.ranges[i].wcLow;


        for j := 0 to lbUnicodeRegions.Count-1 do
        begin
          s := lbUnicodeRegions.Items[j];
          LoChr := StrToInt('$'+copy(s,1,pos(':',s)-1));
          delete(s,1,pos(':',s));
          HiChr := StrToInt('$'+copy(s,1,pos('=',s)-1));
          s := lbUnicodeRegions.Items[j];
          if (ord(wc)>= LoChr) and (ord(wc)<= HiChr) then
            break;
        end;

        gr := -1;
        for j := 0 to lv_Font.Groups.Count-1 do
          if lv_Font.Groups[j].Header=s then
          begin
            gr := j;
            break;
          end;
        if gr=-1 then
        begin
          lv_Font.Groups.Add.Header := s;
          gr := lv_Font.Groups.Count-1;
        end;


        for j:=0 to GS.ranges[i].cGlyphs-1 do
        begin
//          ws:= ws + wc;
          GetGlyphIndices(dyTTF.Canvas.Handle, @wc, 1, @Idx,0);
          if Idx > 0 then

          with lv_Font.Items.Add do
          begin
            if Idx>0 then
              Caption := IntToHex(Ord(wc),4)+' (#'+IntToStr(Idx)+')'
            else
              Caption := IntToHex(Ord(wc),4)+' ( - )';
            ImageIndex := ord(wc);
            SubItems.Add(IntToStr(Idx));
            GroupID := lv_Font.Groups[gr].GroupID;
          end;
          inc(wc);
        end;
      end;
    end;
 FreeMem(GS);
// lv_Font.Groups.EndUpdate;
 lv_Font.Items.EndUpdate;
 lv_Font.OnCustomDrawItem := lv_FontCustomDrawItem;
end;

procedure TFormTTF.tbFontInfoClick(Sender: TObject);
begin
  inherited;
  SplitView1.Opened := tbFontInfo.Down
end;

end.




