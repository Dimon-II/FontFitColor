unit u_FolderSVGForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.AppEvnts, u_BaseDockForm,
  Vcl.ComCtrls, Vcl.ToolWin, System.ImageList, Vcl.ImgList, Vcl.WinXCtrls,
  Vcl.Menus, System.Actions, Vcl.ActnList;

type
  TFormSvgFolder = class(TBaseDockForm)
    Panel1: TPanel;
    PageScroller1: TPageScroller;
    cb_SizeSVG: TComboBox;
    ToolBar1: TToolBar;
    tbRootfolder: TToolButton;
    ToolButton5: TToolButton;
    tbCopySVGFile: TToolButton;
    tbImportSVGFiles: TToolButton;
    il_Folder: TImageList;
    splitFolders: TSplitView;
    treeFolders: TTreeView;
    splFolders: TSplitter;
    il_DirSVG: TImageList;
    lv_DirSVG: TListView;
    tbApply: TToolButton;
    tbRefreshFolder: TToolButton;
    pmFolder: TPopupMenu;
    miApplyTo: TMenuItem;
    miCopy: TMenuItem;
    miSep1: TMenuItem;
    miRefresh: TMenuItem;
    miImportAll: TMenuItem;
    miRootfolder: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure treeFoldersCollapsing(Sender: TObject; Node: TTreeNode;
      var AllowCollapse: Boolean);
    procedure treeFoldersExpanding(Sender: TObject; Node: TTreeNode;
      var AllowExpansion: Boolean);
    procedure treeFoldersChange(Sender: TObject; Node: TTreeNode);
    procedure lv_DirSVGCustomDrawItem(Sender: TCustomListView; Item: TListItem;
      State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure cb_SizeSVGChange(Sender: TObject);
    procedure aCopyExecute(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    SvgFolder:string;
    procedure ResetTree;
    procedure ReadFolderTree(const ParentDirectory: string);
    function ReadDirectoryNames(const ParentDirectory: string; DirectoryList: TTreeNode): Integer;
     procedure ReadSVGFolder(strPath: string; ListView: TListView);
  end;

var
  FormSvgFolder: TFormSvgFolder;

implementation

{$R *.dfm}

uses u_MainForm, Winapi.ShellAPI, SVG, System.Types, Winapi.GDIPAPI, Winapi.GDIPOBJ,
  u_TtfForm, Clipbrd, math;

procedure TFormSvgFolder.aCopyExecute(Sender: TObject);
var  Img: TSVG;
  RF:TRectF;
  dy:single;
begin
  try
    Img := TSVG.Create;
    Img.LoadFromFile(lv_DirSVG.Selected.SubItems[0]);


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
      Img.ViewBox.Create(0,dy,FormMain.dyTTF.FontFace.units_per_em,FormMain.dyTTF.FontFace.units_per_em+dy)
    else
      Img.ViewBox.Create(Img.ViewBox.Left, Img.ViewBox.Top
        + dy /FormMain.dyTTF.FontFace.units_per_em * Img.ViewBox.Height,
        Img.ViewBox.Left+Img.ViewBox.Height,
        Img.ViewBox.Top + Img.ViewBox.Height
        + dy / FormMain.dyTTF.FontFace.units_per_em * Img.ViewBox.Height);

    Clipboard.AsText := FormMain.FixedSVG(Img, 0, 0);
  finally
    Img.Free;
  end;

end;

procedure TFormSvgFolder.cb_SizeSVGChange(Sender: TObject);
var
  tmp:TImageList;
begin
  lv_DirSVG.OnCustomDrawItem := nil;
  tmp:=TImageList.Create(self);
  tmp.Width := sz[cb_SizeSVG.ItemIndex]+16;
  tmp.Height := sz[cb_SizeSVG.ItemIndex]+16;
  lv_DirSVG.LargeImages := tmp;
  il_DirSVG.free;
  il_DirSVG:= tmp;
  if lv_DirSVG.Selected<> nil then
    lv_DirSVG.Selected.MakeVisible(False);
  lv_DirSVG.OnCustomDrawItem := lv_DirSVGCustomDrawItem;
end;

procedure TFormSvgFolder.FormCreate(Sender: TObject);
begin
  ResetTree;
  cb_SizeSVGChange(Nil)
end;

procedure TFormSvgFolder.ResetTree;
begin
  splitFolders.Opened := treeFolders.Items.Count >1;
  splFolders.Visible :=  treeFolders.Items.Count >1;
  splFolders.Left := 500
end;

procedure TFormSvgFolder.treeFoldersChange(Sender: TObject; Node: TTreeNode);
begin
  ReadSVGFolder(PAnsiString(Node.Data)^, lv_DirSVG);
end;

procedure TFormSvgFolder.treeFoldersCollapsing(Sender: TObject; Node: TTreeNode;
  var AllowCollapse: Boolean);
begin
  AllowCollapse := Node.Level>0;
end;

procedure TFormSvgFolder.treeFoldersExpanding(Sender: TObject; Node: TTreeNode;
  var AllowExpansion: Boolean);
var
  n: TTreeNode;
  s:string;
  i:integer;
begin
  for i:= 0 to Node.Count-1 do
    if Node.item[i].Count=0 then
      ReadDirectoryNames(PAnsiString(Node.item[i].Data)^ , Node.item[i]);
end;

procedure TFormSvgFolder.lv_DirSVGCustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
var
  R:TRect;
  Img:TSVG;
  RF:TRectF;
  Kf,Kx,dy:single;
  BMP: TBitmap;
  Bs: TGPRectF;
  Graphics:TGPGraphics;
  s:string;
begin
  R := Item.DisplayRect(drIcon);
  if R.Width = 0 then exit;

  kf := sz[cb_SizeSVG.ItemIndex] / FormMain.dyTTF.FontFace.units_per_em;
  with Sender.Canvas do
  begin
    Pen.Style := psDot;
    Pen.Color := clRed;
    MoveTo(r.Left+8,r.Top);LineTo(r.Left+8,r.Bottom);

    MoveTo(r.Left,r.Top + round(FormMain.dyTTF.FontFace.ascent* kf));LineTo(r.Right-8,r.Top+ round(FormMain.dyTTF.FontFace.ascent* kf));

    Pen.Color := clBlue;

    MoveTo(r.Left,r.Top);LineTo(r.Right-8,r.Top);
    MoveTo(r.Left,r.Top + sz[cb_SizeSVG.ItemIndex] );LineTo(r.Right-8,r.Top+ sz[cb_SizeSVG.ItemIndex]);

    Pen.Color := clSilver;
    MoveTo(r.Left,r.Top + round((FormMain.dyTTF.FontFace.ascent - FormMain.dyTTF.FontFace.Cap_Height)* kf));LineTo(r.Right-8,r.Top+ round((FormMain.dyTTF.FontFace.ascent-FormMain.dyTTF.FontFace.Cap_Height) * kf));
    MoveTo(r.Left,r.Top + round((FormMain.dyTTF.FontFace.ascent-FormMain.dyTTF.FontFace.X_Height)* kf));LineTo(r.Right-8,r.Top+ round((FormMain.dyTTF.FontFace.ascent-FormMain.dyTTF.FontFace.X_Height)* kf));
  end;

  Img := TSVG.Create;
  try
    try
      Img.LoadFromFile(Item.SubItems[0]);
    except
//      Img.LoadFromText('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><text style="font-size:16;stroke:none;fill:red" left="10" top="50">ERROR!</text></svg>')
Img.LoadFromText('<?xml version="1.0" encoding="UTF-8"?>'
  +'<svg width="256" height="256" version="1.1" viewBox="0 0 256 256" xml:space="preserve" xmlns="http://www.w3.org/2000/svg">'
  +'<g transform="translate(1 1) scale(3)">'
+'	<path d="m45 88h41c3 0 5-3 4-6l-41-78c-2-3-6-3-7 0l-41 78c-1 3 0.6 6 4 6h41z" fill="#d60000" stroke-linecap="round"/>'
+'	<path d="m45 64v0c-2 0-3-1-3-3l-3-26c-0.2-3 2-6 6-6h0c3 0 6 3 6 6l-3 26c-0.07 2-1 3-3 3z" fill="#fff" stroke-linecap="round"/>'
+'	<circle cx="45" cy="74" r="5" fill="#fff"/></g></svg>');
    end;


    rf:=FormMain.SvgSize(Img);

    if FormTTF.chbOutline.Checked then
       formMain.AddOutline(Img);

    if rf.CenterPoint.y < 0 then
      dy := -FormMain.dyTTF.FontFace.ascent
    else
      dy := 0;


    if Img.ViewBox.Width=0 then
      Img.ViewBox.Create(0,dy,FormMain.dyTTF.FontFace.units_per_em,FormMain.dyTTF.FontFace.units_per_em+dy)
    else
      Img.ViewBox.Create(Img.ViewBox.Left,Img.ViewBox.Top + dy /FormMain.dyTTF.FontFace.units_per_em *Img.ViewBox.Height, Img.ViewBox.Left+Img.ViewBox.Height, Img.ViewBox.Top + Img.ViewBox.Height+ dy /FormMain.dyTTF.FontFace.units_per_em *Img.ViewBox.Height);

    Img.PaintTo(Sender.Canvas.Handle, r.Left+8, r.Top, sz[cb_SizeSVG.ItemIndex], sz[cb_SizeSVG.ItemIndex]);

    s := ExtractFileName(Item.SubItems[0]);
    if (copy(s,1,2)='U+') and (StrToIntDef('$'+copy(s+'----',3,4),-1)>0) then
      Sender.Canvas.Font.Style := [fsBold];



  finally
    img.free;
  end;


end;

function TFormSvgFolder.ReadDirectoryNames(const ParentDirectory: string;
  DirectoryList: TTreeNode): Integer;
var
  Status: Integer;

  SearchRec: TSearchRec;
  FileInfo: SHFILEINFO;
  Icon: TIcon;
begin
  Icon := TIcon.Create;
  if DirectoryList.Text='' then
  begin
  DirectoryList.Text := ExtractFileName(ParentDirectory);

  SHGetFileInfo(PChar(ParentDirectory), 0, FileInfo, SizeOf(FileInfo), SHGFI_DISPLAYNAME);
  if FileInfo.szDisplayName<>'' then
    DirectoryList.Text :=  FileInfo.szDisplayName;

  //Get The Icon That Represents The File
  SHGetFileInfo(PChar(ParentDirectory), 0, FileInfo, SizeOf(FileInfo), SHGFI_ICON or SHGFI_SMALLICON);
  icon.Handle := FileInfo.hIcon;
//  il_Folder.Width := icon.Width;
//  il_Folder.Height := icon.Height;
  DirectoryList.ImageIndex := il_Folder.AddIcon(Icon);
  DirectoryList.SelectedIndex := DirectoryList.ImageIndex;
  DirectoryList.Data := NewStr(ParentDirectory);
  // Destroy the Icon
  DestroyIcon(FileInfo.hIcon);

  end;

  Result := 1;


  Status := FindFirst(ExcludeTrailingPathDelimiter(ParentDirectory)+'\*.*', faDirectory or faVolumeID , SearchRec);
  try
    while Status = 0 do
    begin
      if (SearchRec.Name<>'..') and (SearchRec.Name<>'.') and
         ((SearchRec.Attr and FaDirectory = FaDirectory) or  (SearchRec.Attr and FaVolumeId = FaVolumeID))
      then
      with treeFolders.Items.AddChild(DirectoryList,SearchRec.Name) do
      begin
        Inc(Result);
//        Text := ExtractFileName(SearchRec.Name);

        SHGetFileInfo(PChar(IncludeTrailingPathDelimiter(ParentDirectory)+SearchRec.Name), 0, FileInfo, SizeOf(FileInfo), SHGFI_DISPLAYNAME);
        Text :=  FileInfo.szDisplayName;

        //Get The Icon That Represents The File
        SHGetFileInfo(PChar(IncludeTrailingPathDelimiter(ParentDirectory)+SearchRec.Name), 0, FileInfo, SizeOf(FileInfo), SHGFI_ICON or SHGFI_SMALLICON);
        icon.Handle := FileInfo.hIcon;
        ImageIndex := il_Folder.AddIcon(Icon);
        SelectedIndex := ImageIndex;
        Data := NewStr(IncludeTrailingPathDelimiter(ParentDirectory)+SearchRec.Name);
       // Destroy the Icon
          DestroyIcon(FileInfo.hIcon);


//        Inc(Result, ReadDirectoryNames(ParentDirectory+'\'+SearchRec.Name, treeFolders.Items.AddChild(DirectoryList,'')));
      end;
      Status := FindNext(SearchRec);
    end;
  finally
    FindClose(SearchRec);
  end;
  Icon.Free;
end;

procedure TFormSvgFolder.ReadFolderTree(const ParentDirectory: string);
begin
  treeFolders.Items.Clear;
  treeFolders.Items.BeginUpdate;
  ReadDirectoryNames(ParentDirectory, treeFolders.Items.AddFirst(nil,''));
  treeFolders.Items[0].Expand(False);
  treeFolders.Items[0].Selected := True;
  treeFolders.Items.EndUpdate;
  ResetTree;
end;


procedure TFormSvgFolder.ReadSVGFolder(strPath: string; ListView: TListView);
var
  i: Integer;
  SearchRec: TSearchRec;
  ListItem: TListItem;
  OldEvent:procedure;
begin
  SvgFolder := strPath;
  Caption := 'SVG Folder: '+ strPath;
  ListView.OnCustomDrawItem := nil;
  ListView.Items.BeginUpdate;
  ListView.Clear;
  try
    // search for the first file
    i := FindFirst(strPath + '\*.svg', faAnyFile, SearchRec);
    while i = 0 do
    begin
      with ListView do
      begin
        if ((SearchRec.Attr and FaDirectory <> FaDirectory) and
          (SearchRec.Attr and FaVolumeId <> FaVolumeID)) then
        begin
          ListItem := ListView.Items.Add;
          Listitem.Caption := ExtractFileName(SearchRec.Name);
          ListItem.SubItems.Add(strPath + '\' + SearchRec.Name);
        end;
      end;
      i := FindNext(SearchRec);
    end;
  finally
    ListView.Items.EndUpdate;
    ListView.OnCustomDrawItem := lv_DirSVGCustomDrawItem;
  end;
end;

end.
