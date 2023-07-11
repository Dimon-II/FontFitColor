unit u_MainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Menus,
  Vcl.Tabs, Vcl.DockTabSet, System.ImageList, Vcl.ImgList, System.Actions,
  Vcl.ActnList, dy_TTFHelper, SVG, System.Types, Vcl.ExtDlgs, GDIPOBJ2;

type
  TFormMain = class(TForm)
    mmMainMenu: TMainMenu;
    miFile: TMenuItem;
    miOpenTTF: TMenuItem;
    miSave: TMenuItem;
    miFolder: TMenuItem;
    miRootFolder: TMenuItem;
    Export1: TMenuItem;
    Import1: TMenuItem;
    Windows1: TMenuItem;
    StatusBar1: TStatusBar;
    pnMain: TPanel;
    DockTabSet: TDockTabSet;
    ilMain: TImageList;
    alMain: TActionList;
    aRootfolder: TAction;
    OpenDialog: TOpenDialog;
    aOpenTTF: TAction;
    SaveSVGDialog: TSavePictureDialog;
    miRefresh: TMenuItem;
    aSaveTTF: TAction;
    aClearSVG: TAction;
    aPaste: TAction;
    aCopy: TAction;
    aExport: TAction;
    aRefresh: TAction;
    aApply: TAction;
    aSaveSVG: TAction;
    aPin: TAction;
    aImport: TAction;
    SaveTTFDialog: TSaveDialog;
    aPrior: TAction;
    aNext: TAction;
    Resetview1: TMenuItem;
    SHOW1: TMenuItem;
    Font1: TMenuItem;
    Glyph1: TMenuItem;
    Folder1: TMenuItem;
    N1: TMenuItem;
    About1: TMenuItem;
    procedure aRootfolderExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure aOpenTTFExecute(Sender: TObject);
    procedure Import1Click(Sender: TObject);
    procedure aSaveTTFUpdate(Sender: TObject);
    procedure aSaveTTFExecute(Sender: TObject);
    procedure aClearSVGExecute(Sender: TObject);
    procedure aClearSVGUpdate(Sender: TObject);
    procedure aPasteExecute(Sender: TObject);
    procedure aPasteUpdate(Sender: TObject);
    procedure aCopyExecute(Sender: TObject);
    procedure aCopyUpdate(Sender: TObject);
    procedure aExportExecute(Sender: TObject);
    procedure aExportUpdate(Sender: TObject);
    procedure aRefreshExecute(Sender: TObject);
    procedure aRefreshUpdate(Sender: TObject);
    procedure aApplyUpdate(Sender: TObject);
    procedure aApplyExecute(Sender: TObject);
    procedure aSaveSVGExecute(Sender: TObject);
    procedure aSaveSVGUpdate(Sender: TObject);
    procedure aPinExecute(Sender: TObject);
    procedure aPinUpdate(Sender: TObject);
    procedure aImportExecute(Sender: TObject);
    procedure aImportUpdate(Sender: TObject);
    procedure aRootfolderUpdate(Sender: TObject);
    procedure aPriorExecute(Sender: TObject);
    procedure aPriorUpdate(Sender: TObject);
    procedure aNextExecute(Sender: TObject);
    procedure aNextUpdate(Sender: TObject);
    procedure Resetview1Click(Sender: TObject);
    procedure Font1Click(Sender: TObject);
    procedure Glyph1Click(Sender: TObject);
    procedure Folder1Click(Sender: TObject);
    procedure About1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    fDirSVG: string;
    dyTTF:TdyTTF;
   function SvgSize(ASVG:TSVG; Trans:boolean=False):TRectF;
   procedure AddOutline(ASVG:TSVGObject);
   function FixedSVG(ASVG:TSVG; AGlyph:word; ascent:integer=0):string;
  end;

var
  FormMain: TFormMain;

const
   sz:array[0..2] of integer=(32,64,128);

implementation

{$R *.dfm}

uses Vcl.FileCtrl, u_TtfForm, u_GlyphForm, u_FolderSVGForm, Winapi.GDIPOBJ,
  Winapi.GDIPAPI, clipbrd, Math;

procedure TFormMain.aApplyExecute(Sender: TObject);
var
  Img:TSVG;
  RF:TRectF;
  dy:single;
begin
  with FormTTF do
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
      Img.ViewBox.Create(Img.ViewBox.Left, Img.ViewBox.Top
                         + dy / FormMain.dyTTF.FontFace.units_per_em * Img.ViewBox.Height,
                         Img.ViewBox.Left + Img.ViewBox.Height,
                         Img.ViewBox.Top + Img.ViewBox.Height
                         + dy / FormMain.dyTTF.FontFace.units_per_em * Img.ViewBox.Height);

    FormMain.dyTTF.SetSVG(StrToIntDef(lv_Font.Selected.SubItems[0],0),
                          FormMain.FixedSVG(Img, StrToIntDef(lv_Font.Selected.SubItems[0],0), 0));

    lv_Font.UpdateItems(lv_Font.Selected.Index,lv_Font.Selected.Index);

    FormGlyph.SetGlyph(char(lv_Font.Selected.ImageIndex), StrToIntDef(lv_Font.Selected.SubItems[0],0),FormMain.dyTTF.GetSVG(StrToIntDef(lv_Font.Selected.SubItems[0],0)));
    rgd_Tables.Cells[4,SvgRow] := IntToStr(dyTTF.SVGFiles.Count);

  finally
    Img.Free;
  end;
end;

procedure TFormMain.aApplyUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := (FormTTF.lv_Font.Selected <> nil)
                         and (FormSvgFolder.lv_DirSVG.Selected <> nil);
  if TAction(Sender).Enabled then
    TAction(Sender).Caption := 'Apply to: '+Char(FormTTF.lv_Font.Selected.ImageIndex)+' '+IntToHex(FormTTF.lv_Font.Selected.ImageIndex,4)
  else
    TAction(Sender).Caption := 'Apply to ...'
end;

procedure TFormMain.About1Click(Sender: TObject);
begin
  MessageDlg('FontFit Color (freeware opensource)'^M^M +
    'This program is designed to substitute'^M'colored SVG-icons over existing TTF font glyphs.'^M^M +
    'If you do not plan to replace glyphs, add new glyphs in the font editor in advance (FontForge, GlyphrStudio). '^M^M +
    'For custom icons, it is recommended to use'^M'the unicode range E000:F8FF "Private Use Area".'^M^M +
    'Issue: used SVG-renderer cannot hande "mask" attrribute.'^M^M +
    'Dmitry Yatsenko <yatcenko@gmail.com>',


    TMsgDlgType.mtInformation, [mbOK],0);
end;

procedure TFormMain.aClearSVGExecute(Sender: TObject);
var
  idx: integer;
begin
  with FormTTF do
  begin
    idx := dyTTF.GetSVGIndex(StrToIntDef(lv_Font.Selected.SubItems[0],0));
    if idx>-1 then
    begin
      dyTTF.SVGFiles.Delete(idx);
      lv_Font.UpdateItems(lv_Font.Selected.Index,lv_Font.Selected.Index);
      rgd_Tables.Cells[4,SvgRow] :=  IntToStr(dyTTF.SVGFiles.Count);
      FormGlyph.fSelectedChar:=#0;
      FormGlyph.SetGlyph(char(lv_Font.Selected.ImageIndex),
                         StrToIntDef(lv_Font.Selected.SubItems[0],0),
                         dyTTF.GetSVG(StrToIntDef(lv_Font.Selected.SubItems[0],0)));

    end;
  end;
end;

procedure TFormMain.aClearSVGUpdate(Sender: TObject);
begin
  TAction(sender).Enabled := (FormTTF.lv_Font.Selected<>nil)
                         and (dyTTF.GetSVGIndex(StrToIntDef(FormTTF.lv_Font.Selected.SubItems[0],0))>-1)

end;

procedure TFormMain.aCopyExecute(Sender: TObject);
begin
  if Screen.ActiveControl.Owner = FormTTF then
    FormTTF.aCopyExecute(Sender)
  else
  if Screen.ActiveControl.Owner = FormSvgFolder then
    FormSvgFolder.aCopyExecute(Sender);

end;

procedure TFormMain.aCopyUpdate(Sender: TObject);
begin
  if Screen.ActiveControl.Owner = FormTTF then
    TAction(Sender).Enabled := (FormTTF.lv_Font.Selected<>nil)
                           and (dyTTF.GetSVGIndex(StrToIntDef(FormTTF.lv_Font.Selected.SubItems[0],0))>-1)
  else
  if Screen.ActiveControl.Owner = FormSvgFolder then
    TAction(Sender).Enabled := (FormSvgFolder.lv_DirSVG.Selected<>nil);

end;

procedure TFormMain.aPinExecute(Sender: TObject);
begin
  FormGlyph.tbPin.Down := True;
  FormGlyph.tbPin.Click;
end;

procedure TFormMain.aPinUpdate(Sender: TObject);
begin
  TAction(sENDER).Enabled := FormTTF.lv_Font.Selected <> nil;
end;

procedure TFormMain.aPriorExecute(Sender: TObject);
var itm:TListItem;
begin
  if FormTTF.lv_Font.Selected.Index >0 then
  begin
    FormGlyph.tbApply.Click;
    itm := FormTTF.lv_Font.Selected;
    itm.Selected := False;
    itm :=  FormTTF.lv_Font.Items[itm.Index-1];
    itm.Focused := True;
    itm.Selected := True;
    itm.MakeVisible(False);
  end;

end;

procedure TFormMain.aPriorUpdate(Sender: TObject);
begin
  TAction(sender).Enabled := (FormTTF.lv_Font.Selected <> nil)
                         and (FormTTF.lv_Font.Selected.Index >0) ;

end;

procedure TFormMain.AddOutline(ASVG: TSVGObject);
var i:integer;
begin
  if ASVG is TSVGBasic then

  with ASVG as TSVGBasic do
  if StrokeWidth <=1 then
  begin
    StrokeColor := clGray;
    StrokeWidth := 0.0001;
    StrokeOpacity := 1;
  end;

  for i := 0 to ASVG.Count-1 do
    AddOutline(TSVGBasic(ASVG.Items[i]));
end;

procedure TFormMain.aExportExecute(Sender: TObject);
var
  i,idx: integer;
  fn:string;
  sl:TStringList;
  cnt:integer;
begin
  with FormTTF do
  begin
    cnt := 0;
    for i:= 0 to lv_Font.Items.Count - 1 do
    begin
      if (lv_Font.SelCount>1) and (not lv_Font.Items[i].Selected) then Continue;
      idx := dyTTF.GetSVGIndex(StrToIntDef(lv_Font.Items[i].SubItems[0],0));
      if idx=-1 then continue;
      fn := FormSvgFolder.SvgFolder + '\U+' +IntToHex(lv_Font.Items[i].ImageIndex,4)+ '.svg';
      (dyTTF.SVGFiles[idx] as dy_TTFHelper.TSVGObject).SaveToFile(fn, TEncoding.UTF8);
      inc(cnt);
    end;
    if FormSvgFolder.treeFolders.Selected <> nil  then
      FormSvgFolder.treeFoldersChange(FormSvgFolder.treeFolders, FormSvgFolder.treeFolders.Selected);
    Application.MessageBox(pchar(Format('Exported SVG-glyphs: %d',[cnt])),'Information',MB_ICONINFORMATION);
  end;
end;

procedure TFormMain.aExportUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := FormTTF.lv_Font.Items.Count > 0;
end;

procedure TFormMain.aImportExecute(Sender: TObject);
var
  i, cnt: integer;
  s,ch: string;
  Img:TSVG;
  Itm: TListItem;
  RF:TRectF;
  dy:single;

begin
  cnt := 0;
  Img:=TSVG.Create;
  try
    for i := 0 to FormSvgFolder.lv_DirSVG.Items.Count-1 do
    begin
      s := FormSvgFolder.lv_DirSVG.Items[i].SubItems[0];
      ch := UpperCase(ExtractFileName(s));
      if (copy(ch,1,2)='U+') and (copy(ch,7,4)='.SVG') then
      begin
        Itm := FormTTF.lv_Font.FindCaption(0, copy(ch,3,4), True, True, False);
        if Itm = nil  then Continue;
        if (FormTTF.lv_Font.SelCount>1) and (not Itm.Selected) then Continue;
        Img.LoadFromFile(s);

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
                             Img.ViewBox.Top + Img.ViewBox.Height + dy / FormMain.dyTTF.FontFace.units_per_em * Img.ViewBox.Height);

        FormMain.dyTTF.SetSVG(StrToIntDef(Itm.SubItems[0],0), FormMain.FixedSVG(Img, StrToIntDef(Itm.SubItems[0],0), 0));
        FormTTF.lv_Font.UpdateItems(Itm.Index, Itm.Index);
        inc(cnt);
      end;
    end;
  finally
    if FormTTF.lv_Font.Selected<>nil then
      FormGlyph.SetGlyph(char(FormTTF.lv_Font.Selected.ImageIndex),
                         StrToIntDef(FormTTF.lv_Font.Selected.SubItems[0],0),
                         FormMain.dyTTF.GetSVG(StrToIntDef(FormTTF.lv_Font.Selected.SubItems[0],0)));
    Img.Free;
    FormTTF.rgd_Tables.Cells[4,FormTTF.SvgRow] :=  IntToStr(dyTTF.SVGFiles.Count);
    Application.MessageBox(pchar(Format('Imported SVG-glyphs: %d',[cnt])),'Information',MB_ICONINFORMATION);
  end;

end;

procedure TFormMain.aImportUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := (FormTTF.lv_Font.Items.Count>0)
                         and (FormSvgFolder.lv_DirSVG.Items.Count>0);
end;

procedure TFormMain.aNextExecute(Sender: TObject);
var itm:TListItem;
begin
  if FormTTF.lv_Font.Selected.Index < FormTTF.lv_Font.Items.Count-2 then
  begin
    FormGlyph.tbApply.Click;
    itm := FormTTF.lv_Font.Selected;
    itm.Selected := False;
    itm :=  FormTTF.lv_Font.Items[itm.Index+1];
    itm.Focused := True;
    itm.Selected := True;
    itm.MakeVisible(False);
  end;
end;

procedure TFormMain.aNextUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := (FormTTF.lv_Font.Selected <> nil)
   and (FormTTF.lv_Font.Selected.Index < FormTTF.lv_Font.Items.Count-2);

end;

procedure TFormMain.aOpenTTFExecute(Sender: TObject);
begin
  if OpenDialog.Execute then
  begin
    FormGlyph.fSelectedChar := #0;
    FormGlyph.SetGlyph(#0,0,'');

    FormTTF.lv_Font.Clear;

    SaveTTFDialog.FileName := OpenDialog.FileName;

    dyTTF.LoadFromFile(OpenDialog.FileName);
    FormTTF.PrepareGrid(dyTTF);
    if fDirSVG='' then
    FormSvgFolder.ReadFolderTree(ExtractFilePath(OpenDialog.FileName));
  end;
end;

procedure TFormMain.aPasteExecute(Sender: TObject);
var
  SVG:TSVG;
begin
  if (pos('<svg',clipboard.AsText)=0) then exit;

  with FormTTF do
  try
    SVG:=TSVG.Create;
    SVG.LoadFromText(Clipboard.AsText);
    FormMain.dyTTF.SetSVG(StrToIntDef(lv_Font.Selected.SubItems[0],0), FormMain.FixedSVG(SVG, StrToIntDef(lv_Font.Selected.SubItems[0],0), 0));
    lv_Font.UpdateItems(lv_Font.Selected.Index,lv_Font.Selected.Index);
    FormGlyph.SetGlyph(char(lv_Font.Selected.ImageIndex), StrToIntDef(lv_Font.Selected.SubItems[0],0),FormMain.dyTTF.GetSVG(StrToIntDef(lv_Font.Selected.SubItems[0],0)));
    rgd_Tables.Cells[4,SvgRow] := IntToStr(dyTTF.SVGFiles.Count);

  finally
    SVG.Free;
  end;

end;

procedure TFormMain.aPasteUpdate(Sender: TObject);
begin
  TAction(sender).Enabled := (FormTTF.lv_Font.Selected<>nil)
end;

procedure TFormMain.aRefreshExecute(Sender: TObject);
begin
  FormSvgFolder.ReadSVGFolder(FormSvgFolder.SvgFolder, FormSvgFolder.lv_DirSVG);
end;

procedure TFormMain.aRefreshUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := FormSvgFolder.SvgFolder <>''

end;

procedure TFormMain.aRootfolderExecute(Sender: TObject);
var s:string;
begin
  s:= fDirSVG;
  if s='' then
    s :=  FormSvgFolder.SvgFolder;


  if SelectDirectory('SVG folder','',s, [sdNewFolder , sdShowEdit , sdNewUI , sdValidateDir] ,nil)  then
  begin
    fDirSVG := s;
    FormSvgFolder.ReadFolderTree(fDirSVG);
  end;
end;

procedure TFormMain.aRootfolderUpdate(Sender: TObject);
begin
  FormTTF.tbCopySVG.Enabled := (FormTTF.lv_Font.Selected<>nil)
                           and (dyTTF.GetSVGIndex(StrToIntDef(FormTTF.lv_Font.Selected.SubItems[0],0))>-1);

  FormSvgFolder.tbCopySVGFile.Enabled :=  (FormSvgFolder.lv_DirSVG.Selected<>nil);
end;

procedure TFormMain.aSaveSVGExecute(Sender: TObject);
var
  i,idx: integer;
  sl:TStringList;
  cnt:integer;
begin
  idx := dyTTF.GetSVGIndex(StrToIntDef(FormTTF.lv_Font.Selected.SubItems[0],0));
  FormMain.SaveSVGDialog.FileName := StringReplace(FormSvgFolder.SvgFolder + '\U+' +IntToHex(FormTTF.lv_Font.Selected.ImageIndex,4)+ '.svg','\\','\',[]);
  if FormMain.SaveSVGDialog.Execute then
  begin
    (dyTTF.SVGFiles[idx] as dy_TTFHelper.TSVGObject).SaveToFile(FormMain.SaveSVGDialog.FileName, TEncoding.UTF8);
    FormSvgFolder.treeFoldersChange(FormSvgFolder.treeFolders, FormSvgFolder.treeFolders.Selected);
  end;
end;

procedure TFormMain.aSaveSVGUpdate(Sender: TObject);
begin
  TAction(sender).Enabled := (FormTTF.lv_Font.Selected <> nil)
    and (dyTTF.GetSVGIndex(StrToIntDef(FormTTF.lv_Font.Selected.SubItems[0],0)) >-1)

end;

procedure TFormMain.aSaveTTFExecute(Sender: TObject);
begin
  SaveTTFDialog.InitialDir := ExtractFilePath(SaveTTFDialog.FileName);
  if SaveTTFDialog.Execute then
   dyTTF.SaveToFile(SaveTTFDialog.FileName);
end;

procedure TFormMain.aSaveTTFUpdate(Sender: TObject);
begin
  aSaveTTF.Enabled := FormTTF.lv_Font.Items.Count >0
end;

function TFormMain.FixedSVG(ASVG:TSVG; AGlyph:word; ascent:integer=0):string;
var
  tagSvg, s:string;

  procedure Clear(atr:string);
  var
    n1, n2:integer;
  begin
    n1 := pos(atr, s);
    if n1 > 0 then
    begin
      n2 := pos('"', s, n1+length(atr));
      delete(s, n1, n2-n1+1);
    end;
  end;

begin
  result := ASVG.Source;

  tagSvg := copy(result, pos('<svg', result), length(result));
  tagSvg := copy(tagSvg, 1, pos('>', tagSvg)-1);
  s := tagSvg;

//  width="1000" height="1000" viewBox="0 0 1000 1000" id="glyph191"
  Clear(' width="');
  Clear(' height="');
  Clear(' viewBox="');
  Clear(' id="');

  s := s + Format(' id="glyph%d" viewBox="%g %g %g %g"', [AGlyph,
    ASVG.ViewBox.Left, ASVG.ViewBox.Top + ascent /dyTTF.FontFace.units_per_em*ASVG.ViewBox.Height, ASVG.ViewBox.Width, ASVG.ViewBox.Height]);

  result := StringReplace(result,tagSvg,s,[]);
end;

procedure TFormMain.Folder1Click(Sender: TObject);
begin
  FormSvgFolder.Show;
  FormSvgFolder.SetFocus;
end;

procedure TFormMain.Font1Click(Sender: TObject);
begin
  FormTTF.Show;
  FormTTF.SetFocus;
end;

procedure TFormMain.FormCreate(Sender: TObject);
begin
    dyTTF:=TdyTTF.Create;
end;

procedure TFormMain.Glyph1Click(Sender: TObject);
begin
  FormGlyph.Show;
  FormGlyph.SetFocus;
end;

procedure TFormMain.Import1Click(Sender: TObject);
begin
  FormTTF.tbImportFolder.Click
end;

procedure TFormMain.Resetview1Click(Sender: TObject);
begin
  FormTTF.lv_Font.OnCustomDrawItem := nil;
  FormSvgFolder.lv_DirSVG.OnCustomDrawItem := nil;
  FormTTF.Show;
  FormGlyph.Show;
  FormSvgFolder.Show;

  FormTTF.ManualDock(FormMain.pnMain, nil, alClient);
  FormGlyph.ManualDock(FormMain.pnMain, nil, alRight);
  FormSvgFolder.ManualDock(FormMain.pnMain, nil, alBottom);
  FormTTF.lv_Font.OnCustomDrawItem := FormTTF.lv_FontCustomDrawItem;
  FormSvgFolder.lv_DirSVG.OnCustomDrawItem := FormSvgFolder.lv_DirSVGCustomDrawItem;
end;

function TFormMain.SvgSize(ASVG: TSVG; Trans: boolean): TRectF;
var
  gpt: TGPGraphicsPath;

  procedure GetBranchSize(Itm:TSVGBasic; var Result:TRectF; ClipBnd: TGPRectF);
  var i:integer;
    rf:TRectF;
    ClipRoot: TSVGBasic;
    ClipPath: TGPGraphicsPath;
    TGP: TGPMatrix;
    Bn1: TGPRectF;
    FClipBnd: TGPRectF;


  begin
    if Itm.ObjectName='defs' then exit;

  if Itm.ClipURI<>'' then
  begin
    ClipRoot := TSVGBasic(Itm.Root.FindByID(Itm.ClipURI));
    if Assigned(ClipRoot) and (ClipRoot is TSVGClipPath) then
    begin
      ClipPath := TSVGClipPath(ClipRoot).ClipPath;
//      ParentSVG := ClipRoot.Parent as TSVGBasic;
      if not Itm.FullMatrix.IsEmpty then
      begin
        TGP := Itm.FullMatrix.ToGPMatrix;
        ClipPath.GetBounds(FClipBnd,TGP);

        TGP.Free;
      end
      else
        ClipPath.GetBounds(FClipBnd);
    end;
  end
  else
    FClipBnd := ClipBnd;


    if Itm.ObjectName<>'svg' then
    begin
      rf := Itm.ObjectBounds(True,True);
      rf.NormalizeRect;

     if FClipBnd.Width >0 then
     rf := TRectF.Create(Max(rf.Left, FClipBnd.x), max(rf.Top,FClipBnd.Y),
        min(rf.Right,  FClipBnd.x + FClipBnd.Width ),
        Min(rf.Bottom, FClipBnd.y + FClipBnd.Height));

      if (rf.Height<>0) and (rf.Width<>0) then
      begin
        if rf.Width>0 then
        begin
           if Result.Width=0 then
             Result := rf;

           if Result.Left > rf.Left then
             Result.Create(rf.Left, result.Top, rf.Left + Result.Width, result.Bottom);

           if Result.Top > rf.top then
             Result.Create(result.left, rf.top, Result.Right, rf.top + Result.Height);

           if Result.Right < rf.Right then
             Result.Right := rf.Right;

           if Result.Bottom < rf.Bottom then
             Result.Bottom := rf.Bottom;
        end;

      end;
    end
    else
      Result.Width := 0;

  for i := 0 to Itm.Count-1 do
    GetBranchSize(pointer(Itm.Items[i]), Result, FClipBnd);

  if Itm.ObjectName='svg' then
    if Result.Width = 0 then begin
      Result := ASVG.ObjectBounds(True,True);
      Result.Offset(- ASVG.ViewBox.Left, - ASVG.ViewBox.Top);
    end;
    FClipBnd := Bn1;
end;
 var bnd: TGPRectF;
begin

  gpt := TGPGraphicsPath.Create;
  ASVG.LocalMatrix  := ASVG.InitialMatrix.Create(1, 0, 0, 1, 0, 0);
  ASVG.CalculateMatrices;
  ASVG.PaintToPath(gpt);
//  gpt.Flatten;
//  gpt.GetBounds(bnd);
//  Result.Create(bnd.X, bnd.Y, bnd.x+bnd.Width, bnd.y+bnd.Height);
  gpt.Free;
  bnd.Width := 0;
  GetBranchSize(ASVG, Result, bnd);

end;

initialization
 FormatSettings.DecimalSeparator := '.';

end.
