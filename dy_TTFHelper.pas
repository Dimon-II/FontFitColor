unit dy_TTFHelper;

interface

uses vcl.Graphics, Vcl.Forms, system.Classes, System.SysUtils, Winapi.Windows, Winapi.Messages, System.Contnrs;

type
    //  This is the TTF file header
    TT_OFFSET_TABLE = packed record
        uMajorVersion : UInt16;
        uMinorVersion : UInt16;
        uNumOfTables  : UInt16;
        uSearchRange  : UInt16;
        uEntrySelector: UInt16;
        uRangeShift   : UInt16;
    end;

    //  Tables in the TTF file and their placement and name (tag)
    TT_TABLE_DIRECTORY = packed record
        szTag         : array[0..3] of ansichar;    //  table name
        uCheckSum     : UInt32;                 //  Check sum
        uOffset       : UInt32;                 //  Offset from beginning of file
        uLength       : UInt32;                 //  length of the table in bytes
    end;

    TSVGDocumentRecord = packed record
      startGlyphID: UInt16; //	The first glyph ID for the range covered by this record.
      endGlyphID: UInt16;   //	The last glyph ID for the range covered by this record.
      svgDocOffset: UInt32; //	Offset from the beginning of the SVGDocumentList to an SVG document. Must be non-zero.
      svgDocLength: UInt32; //	Length of the SVG document data. Must be non-zero.
    end;

    ThmtxRecord = packed record
      Width: UInt16;
      Left: Int16;
    end;

    TSVGRecord = packed record
      startGlyphID : word;

      endGlyphID : word;
      svgDocOffset : longword;
      svgDocLength : longword;
    end;

    TSVGObject = class(TStringList)
      public
        SVGRecord:TSVGRecord;
        UndoStack:TStringList;
        UndoIdx:integer;
        procedure SetTextStr(const Value: string); override;
        constructor Create;
        destructor Destroy; override;
        function Undo: string;
        function Redo: string;

    end;

    TFontFace=record
        font_family: string;

        units_per_em: Int16;
        ascent: Int16;
        descent: Int16;
        Gap: Int16;
//        Subscript: TRect;
//        Superscript: TRect;
        right: Int16;
        baseright: Int16;
        horiz_adv_x: Int16;
        Weight: Int16;
        X_Height: Int16;
        Cap_Height: Int16;
        winascent: Int16;
        windescent: Int16;
        numGlyphs: UInt16;
        hmtx:array of ThmtxRecord;
//        leftSideBearings:array of Int16;
        FileName:string;
    end;


  TdyTTF=class(TFont)
  private
    hh:THandle;
    Bmp:Vcl.Graphics.TBitmap;
    FFontFace:TFontFace;
    iSVG :integer;


  public
    FontData:array of byte;
    ttOffsetTable: TT_OFFSET_TABLE;
    ttTableDirectory: array of TT_TABLE_DIRECTORY;
    ttSVGDocuments: array of TSVGDocumentRecord;
    OffsetSVG: UInt32;
    METRICS: TTextMetric;
    SVGFiles : TObjectList;
    procedure LoadFromStream(Stream: TStream);
    procedure LoadFromFile(const FileName: string);
    property FontFace:TFontFace read FFontFace;
    function GetSVG(AGlyph:word):string;
    function GetSVGIndex(AGlyph:word): integer;
    procedure SetSVG(AGlyph:word; ASVG:string);
    function Canvas:TCanvas;
    constructor Create;

    procedure SaveToFile(const FileName: string);
    procedure SaveToStream(Stream: TStream);
    function CalculateCheckSum(Stream: TMemoryStream; TBL:TT_TABLE_DIRECTORY): Cardinal;

  end;

  function Swap16(Value: UInt16): UInt16;

implementation

uses Math, System.ZLib;

type
    //  Header of the names table
    TT_NAME_TABLE_HEADER = packed record
        uFSelector    : UInt16;        //  format selector. Always 0
        uNRCount      : UInt16;        //  Name Records count
        uStorageOffset: UInt16;     //  Offset for strings storage, from start of the table
    end;

    //  Records in the names table
    TT_NAME_RECORD = packed record
        uPlatformID   : UInt16;
        uEncodingID   : UInt16;
        uLanguageID   : UInt16;
        uNameID       : UInt16;
        uStringLength : UInt16;
        uStringOffset : UInt16;     //  from start of storage area
    end;

function Swap32(Value: UInt32): UInt32;
type
  Bytes = packed array[0..3] of Byte;
begin
  Bytes(Result)[0]:= Bytes(Value)[3];
  Bytes(Result)[1]:= Bytes(Value)[2];
  Bytes(Result)[2]:= Bytes(Value)[1];
  Bytes(Result)[3]:= Bytes(Value)[0];
end;

function Swap16(Value: UInt16): UInt16;
type
  Bytes = packed array[0..1] of Byte;

begin
  Bytes(Result)[0]:= Bytes(Value)[1];
  Bytes(Result)[1]:= Bytes(Value)[0];
end;

function Swap32i(Value: Int32): Int32;
type
  Bytes = packed array[0..3] of Byte;
begin
  Bytes(Result)[0]:= Bytes(Value)[3];
  Bytes(Result)[1]:= Bytes(Value)[2];
  Bytes(Result)[2]:= Bytes(Value)[1];
  Bytes(Result)[3]:= Bytes(Value)[0];
end;

function Swap16i(Value: Int16): Int16;
type
  Bytes = packed array[0..1] of Byte;

begin
  Bytes(Result)[0]:= Bytes(Value)[1];
  Bytes(Result)[1]:= Bytes(Value)[0];
end;


function CalculateCheckSum(Data: Pointer; Size: Integer): UInt32;
var
  I: Integer;
begin
  Result := Swap32(PCardinal(Data)^);
  Inc(PCardinal(Data));
  for I := 1 to Size - 1 do
  begin
    Result := Result + Swap32(PCardinal(Data)^);
    Inc(PCardinal(Data));
  end;
end;

{ TdyTTF }

function TdyTTF.Canvas: TCanvas;
begin
 bmp.Canvas.Font.Assign(self);
 result := bmp.Canvas;
end;

constructor TdyTTF.Create;
begin
 inherited Create;
  SVGFiles := TObjectList.Create;
  FFontFace.units_per_em := 1000;
  FFontFace.ascent := 800;
  FFontFace.descent := 200;
  bmp:=Vcl.Graphics.TBitmap.Create(FontFace.units_per_em,FontFace.units_per_em);
  GetTextMetrics(bmp.Canvas.Handle, METRICS);
end;

function TdyTTF.GetSVG(AGlyph: word): string;
var
  i:integer;
begin
  result:='';
  i := GetSVGIndex(AGlyph);
  if i<>-1 then
    result :=  TSVGObject(SVGFiles[i]).Text;
end;

function TdyTTF.GetSVGIndex(AGlyph: word): integer;
var i:integer;
begin
  result := -1;
  for i:=0 to SVGFiles.Count-1 do
    if (AGlyph >= TSVGObject(SVGFiles[i]).SVGRecord.startGlyphID) and
       (AGlyph <= TSVGObject(SVGFiles[i]).SVGRecord.endGlyphID)
    then
    begin
      result := i;
      break;
    end;
end;

procedure TdyTTF.LoadFromFile(const FileName: string);
var
  F: TFileStream;
begin
  F := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    LoadFromStream(F);
    FFontFace.FileName:=FileName;
  finally
    F.Free;
  end;
end;

procedure TdyTTF.LoadFromStream(Stream: TStream);
var i, iHMTX: integer;
  SVGObject:TSVGObject;
  tblDir: TT_TABLE_DIRECTORY;

  csTemp: string;
  ttNTHeader: TT_NAME_TABLE_HEADER;
  ttRecord: TT_NAME_RECORD;
  nPos: integer;
  Buf: array[0..1024] of ansichar; //  ??...

  Value64: Int64;
  Value32: Cardinal;
  Value16: Word;
  Value32i: Int32;
  Value16i: Int16;
  ps:integer;
  Version: Word;
  z,pz:integer;
  dc : hdc;
  cnv:Vcl.Graphics.TBitmap;
  BufStream,ZStream:TStream;
//  s:array of byte;
  s,s1: TBytes;
begin
  FFontFace.FileName:='';
  if hh<>0 then
    RemoveFontMemResourceEx(hh);

  SVGFiles.Clear;

  SetLength(FontData, Stream.Size);
  Stream.Read(FontData[0], Stream.Size);
  Stream.Position := 0;

  hh := AddFontMemResourceEx(@FontData[0],length(FontData),nil, @i);
  SendMessage(HWND_BROADCAST, WM_FONTCHANGE, 0 , 0) ;
  Application.ProcessMessages;


  Stream.Read(ttOffsetTable, SizeOf(TT_OFFSET_TABLE));

  ttOffsetTable.uNumOfTables  := Swap16(ttOffsetTable.uNumOfTables);
  ttOffsetTable.uMajorVersion := Swap16(ttOffsetTable.uMajorVersion);
  ttOffsetTable.uMinorVersion := Swap16(ttOffsetTable.uMinorVersion);

  SetLength(ttTableDirectory,ttOffsetTable.uNumOfTables);
  iSVG := -1;

  for i:= 0 to ttOffsetTable.uNumOfTables do
  begin
    Stream.Read(ttTableDirectory[i], SizeOf(TT_TABLE_DIRECTORY));
    ttTableDirectory[i].uCheckSum := swap32(ttTableDirectory[i].uCheckSum);
    ttTableDirectory[i].uOffset := swap32(ttTableDirectory[i].uOffset);
    ttTableDirectory[i].uLength := swap32(ttTableDirectory[i].uLength);
    ps:=Stream.Position;

    if ttTableDirectory[i].szTag='SVG ' then
      iSVG := i;

    if ttTableDirectory[i].szTag='maxp' then
    begin
      Stream.Seek(ttTableDirectory[i].uOffset, soFromBeginning);
      Stream.Read(Value32, SizeOf(Value32));
      Stream.Read(Value16, SizeOf(Value16));
      FFontFace.numGlyphs := swap16(Value16);
    end;

    if ttTableDirectory[i].szTag='hmtx' then
      iHMTX:=i;


    if (LowerCase(ttTableDirectory[i].szTag) = 'name') then
      tblDir := ttTableDirectory[i];

    if (LowerCase(ttTableDirectory[i].szTag) = 'head') then
    begin
      Stream.Seek(ttTableDirectory[i].uOffset, soFromBeginning);

      // read version
      Stream.Read(Value32, SizeOf(Value32));
      // read font revision
      Stream.Read(Value32, SizeOf(Value32));
      // read check sum adjust
      Stream.Read(Value32, SizeOf(Value32));
      // read magic number
      Stream.Read(Value32, SizeOf(Value32));
      // read flags
      Stream.Read(Value16, SizeOf(Value16));
      Stream.Read(Value16, SizeOf(Value16));
      FFontFace.units_per_em := Swap16(Value16);
      // read CreatedDate
      Stream.Read(Value64, SizeOf(Value64));
      // read ModifiedDate
      Stream.Read(Value64, SizeOf(Int64));
      // read xMin
      Stream.Read(Value16, SizeOf(Value16));
      // read yMin
      Stream.Read(Value16, SizeOf(Value16));
      // read xMax
      Stream.Read(Value16, SizeOf(Value16));
      // read xMax
      Stream.Read(Value16, SizeOf(Value16));
      // read MacStyle
      Stream.Read(Value16, SizeOf(Value16));
      Value16 := Swap16(Value16);
      Style := [];
      if Value16 and $0001>0 then
        Style := Style + [fsBold];
      if Value16 and $0002>0 then
        Style := Style + [fsItalic];
      if Value16 and $0004>0 then
        Style := Style + [fsUnderline];
    end;
{
    if (LowerCase(ttTableDirectory[i].szTag) = 'hhea') then
    begin
      Stream.Seek(ttTableDirectory[i].uOffset, soFromBeginning);
      // read majorVersion
      Stream.Read(Value16, SizeOf(Value16));
      // read minorVersion
      Stream.Read(Value16, SizeOf(Value16));
//    read ascent
      Stream.Read(Value16i, SizeOf(Value16i));
      FFontFace.ascent := Swap16i(Value16i);
      // read descent
      Stream.Read(Value16i, SizeOf(Value16i));
      FFontFace.descent := Swap16i(Value16i);

      Stream.Read(Value16i, SizeOf(Value16i));
      FFontFace.gap := Swap16i(Value16i);
    end;
}
    if (LowerCase(ttTableDirectory[i].szTag) = 'os/2') then
    begin
      Stream.Seek(ttTableDirectory[i].uOffset, soFromBeginning);
      // read Version
      Stream.Read(Value16, SizeOf(Value16));
      Version := Swap16(Value16);

      // read average horizontal character width
      Stream.Read(Value16, SizeOf(Value16));
      // read weight
      Stream.Read(Value16, SizeOf(Value16));
      FFontFace.Weight := Swap16(Value16);
      // read width type
      Stream.Read(Value16, SizeOf(Value16));
      // read font embedding right flags
      Stream.Read(Value16, SizeOf(Value16));
    // read SubscriptSizeX
      Stream.Read(Value16, SizeOf(Value16));
//      FFontFace.Subscript.width := Swap16(Value16);
    // read SubscriptSizeY
      Stream.Read(Value16i, SizeOf(Value16i));
//      FFontFace.Subscript.height := Swap16i(Value16i);
    // read SubScriptOffsetX
      Stream.Read(Value16i, SizeOf(Value16i));
//      FFontFace.Subscript.Left := Swap16i(Value16i);
    // read SubscriptOffsetY
      Stream.Read(Value16i, SizeOf(Value16i));
//      FFontFace.Subscript.Top := Swap16(Value16i);
    // read SuperscriptSizeX
      Stream.Read(Value16i, SizeOf(Value16i));
//      FFontFace.Superscript.width := Swap16i(Value16i);
    // read SuperscriptSizeY
      Stream.Read(Value16i, SizeOf(Value16i));
//      FFontFace.Superscript.height := Swap16i(Value16i);
    // read SuperscriptOffsetX
      Stream.Read(Value16i, SizeOf(Value16i));
//      FFontFace.Superscript.Left := Swap16i(Value16i);
    // read SuperscriptOffsetY
      Stream.Read(Value16i, SizeOf(Value16i));
  //    FFontFace.Superscript.Top := Swap16i(Value16i);
{
    FStrikeoutSize         : SmallInt;   // width of the strikeout stroke
    FStrikeoutPosition     : SmallInt;   // position of the strikeout stroke relative to the baseline
    FFontFamilyType        : Word;       // classification of font-family design.
    FFontVendorID          : TTableType; // four character identifier for the font vendor
    FFontSelection         : Word;       // 2-byte bit field containing information concerning the nature of the font patterns
    FUnicodeFirstCharIndex : Word;       // The minimum Unicode index in this font.
    FUnicodeLastCharIndex  : Word;       // The maximum Unicode index in this font.}
{
    pz := Stream.Position;
    for z:= 0 to 48 do begin
    Stream.Seek(pz + z, soFromBeginning);
      Stream.Read(Value16i, SizeOf(Value16i));
      FFontFace.ascent := Swap16i(Value16i);
      // read descent
      Stream.Read(Value16i, SizeOf(Value16i));
      FFontFace.descent := Swap16i(Value16i);
    end;
}
    Stream.Seek(42, soFromCurrent);

      Stream.Read(Value16i, SizeOf(Value16i));
      FFontFace.ascent := Swap16i(Value16i);
      // read descent
      Stream.Read(Value16i, SizeOf(Value16i));
      FFontFace.descent := Swap16i(Value16i);

      Stream.Read(Value16i, SizeOf(Value16i));
      FFontFace.gap := Swap16i(Value16i);

      Stream.Read(Value16i, SizeOf(Value16i));
      FFontFace.WinAscent := Swap16i(Value16i);

      Stream.Read(Value16i, SizeOf(Value16i));
      FFontFace.WinDescent := Swap16i(Value16i);

    {
    FTypographicLineGap    : SmallInt;
    FWindowsAscent         : Word;
    FWindowsDescent        : Word;}
//    Stream.Position := Stream.Position + 4;
//    Stream.Position := Stream.Position + 4;
    if Version > 0 then
    begin
      Stream.Position := Stream.Position + 8;
      if Version >= 2 then
      begin
        Stream.Read(Value16i, SizeOf(Value16i));
        FFontFace.x_height :=Swap16i(Value16i);
        Stream.Read(Value16i, SizeOf(Value16i));
        FFontFace.cap_height :=Swap16i(Value16i);
      end;
    end;

    end;
    Stream.Position := ps;
  end;


  // Read name
  Stream.Seek(tblDir.uOffset, soFromBeginning);
  Stream.Read(ttNTHeader, SizeOf(TT_NAME_TABLE_HEADER));
  ttNTHeader.uNRCount       := Swap16(ttNTHeader.uNRCount);
  ttNTHeader.uStorageOffset := Swap16(ttNTHeader.uStorageOffset);
  for i := 0 to ttNTHeader.uNRCount - 1 do
  begin
    Stream.Read(ttRecord, SizeOf(TT_NAME_RECORD));
    ttRecord.uNameID := Swap16(ttRecord.uNameID);
    if (ttRecord.uNameID = 1) then
    begin
      ttRecord.uStringLength := Swap16(ttRecord.uStringLength);
      ttRecord.uStringOffset := Swap16(ttRecord.uStringOffset);
      nPos := Stream.Position;
      Stream.Seek(tblDir.uOffset
        + ttRecord.uStringOffset
        + ttNTHeader.uStorageOffset,
        soFromBeginning);
      FillChar(Buf, SizeOf(Buf), 0);
      Stream.Read(Buf, ttRecord.uStringLength);
      csTemp := string(Buf);
      if (csTemp <> '') then
      begin
        Name := csTemp;
        FFontFace.font_family := Name;
        break;
      end;
     Stream.Seek(nPos, soFromBeginning);
    end;

  end;

  FFontFace.descent := FFontFace.ascent - FFontFace.units_per_em;
  SetLength(FFontFace.hmtx, FFontFace.numGlyphs);
  Stream.Seek(ttTableDirectory[iHMTX].uOffset, soFromBeginning);
  for i:= 0 to FFontFace.numGlyphs-1 do
  begin
    Stream.Read(Value16, SizeOf(Value16));
    FFontFace.hmtx[i].Width := Swap16(Value16);
    Stream.Read(Value16i, SizeOf(Value16i));
    FFontFace.hmtx[i].Left := Swap16i(Value16i);
  end;


  if iSVG=-1 then
  begin
    iSVG := ttOffsetTable.uNumOfTables;
    SetLength(ttTableDirectory,ttOffsetTable.uNumOfTables+1);
    ttTableDirectory[iSVG].szTag:='SVG ';
    ttTableDirectory[iSVG].uCheckSum := 0;
    ttTableDirectory[iSVG].uOffset := 0;
    ttTableDirectory[iSVG].uLength := 0;
  end;

  if ttTableDirectory[iSVG].uOffset >0 then
  begin
      Stream.Seek(ttTableDirectory[iSVG].uOffset, soFromBeginning);
      Stream.Read(Value16, SizeOf(Value16));
      Stream.Read(Value32, SizeOf(Value32));

      OffsetSVG := ttTableDirectory[iSVG].uOffset + Swap32(Value32);

      Stream.Seek(OffsetSVG, soFromBeginning);
      Stream.Read(Value16, SizeOf(Value16));
      SetLength(ttSVGDocuments, Swap16(Value16));
      Stream.Read(ttSVGDocuments[0], SizeOf(TSVGDocumentRecord) * Swap16(Value16) );
  end else
      SetLength(ttSVGDocuments, 0);


  for i := 0 to Length(ttSVGDocuments)-1 do
  begin
    SVGObject:=TSVGObject.Create;
    SVGFiles.add(SVGObject);
    SVGObject.SVGRecord.startGlyphID := swap16(ttSVGDocuments[i].startGlyphID);
    SVGObject.SVGRecord.endGlyphID := swap16(ttSVGDocuments[i].endGlyphID);
    SVGObject.SVGRecord.svgDocOffset := Swap32(ttSVGDocuments[i].svgDocOffset);
    SVGObject.SVGRecord.svgDocLength := Swap32(ttSVGDocuments[i].svgDocLength);

    Stream.Position :=  OffsetSVG + SVGObject.SVGRecord.svgDocOffset;

    SetLength(s,SVGObject.SVGRecord.svgDocLength);
    Stream.Read(s[0],Length(s));

    BufStream:=TMemoryStream.Create;
    BufStream.Write(s[0],Length(s));
    BufStream.Position := 0;


    if (s[0]=$1F) and (s[1]=$8B) and (s[2]=$08) then
    try
      ZStream := TZDecompressionStream.Create(BufStream, 16);
      SVGObject.LoadFromStream(ZStream);
    finally
      ZStream.Destroy;
    end
    else
      SVGObject.LoadFromStream(BufStream);
    BufStream.Free;
  end;

  bmp.Canvas.Font.Assign(Self);
end;

procedure TdyTTF.SaveToFile(const FileName: string);
var
  fs: TFileStream;
begin
  fs := TFileStream.Create(FileName, fmCreate);
  try
    SaveToStream(fs);
  finally
    fs.free;
  end;
end;

function Compare1(Item1, Item2: Pointer): Integer;
begin
  Result := CompareValue(TSVGObject(Item1).SVGRecord.startGlyphID, TSVGObject(Item2).SVGRecord.startGlyphID);
end;

procedure TdyTTF.SaveToStream(Stream: TStream);
var
  ms:TMemoryStream;
  i,j: integer;
  OldPos,SizePos, SvgPos:Cardinal;
  buf32:Cardinal;
  buf16:word;
  buf16i:SmallInt;

  NumTables     : Word; // number of tables
  SearchRange   : Word; // (maximum power of 2 <= numTables) * 16
  EntrySelector : Word; // log2(maximum power of 2 <= numTables)
  RangeShift    : Word; // numTables * 16 - searchRange
  TBL:TT_TABLE_DIRECTORY;
  ZeroByte:byte;
  SVGObject:TSVGObject;

begin
  ZeroByte:=0;
  ms:=TMemoryStream.Create;
  try
    for i := SVGFiles.Count-1 downto 0 do
      if (trim(TSVGObject(SVGFiles[i]).Text) = '')
      then
        SVGFiles.Delete(i);

    SVGFiles.SortList(Compare1);

//uint32	sfntVersion	0x00010000 or 0x4F54544F ('OTTO') — see below.
    buf16 := swap16(1);
    ms.Write(buf16,2);
    buf16 := 0;
    ms.Write(buf16,2);

//uint16	numTables	Number of tables.
    NumTables  :=  length(ttTableDirectory);
    if SVGFiles.Count=0 then
      NumTables  := NumTables  - 1;
    buf16 := swap16(NumTables );
    ms.Write(buf16,2);

//uint16	searchRange	Maximum power of 2 less than or equal to numTables, times 16 ((2**floor(log2(numTables))) * 16, where “**” is an exponentiation operator).
    SearchRange :=  1;
    while SearchRange*2 <= NumTables do
      SearchRange := SearchRange * 2;
    SearchRange := SearchRange * 16;
    buf16 := swap16(SearchRange);
    ms.Write(buf16,2);

//uint16	entrySelector	Log2 of the maximum power of 2 less than or equal to numTables (log2(searchRange/16), which is equal to floor(log2(numTables))).
    entrySelector := floor(log2(numTables));
    buf16 := swap16(entrySelector);
    ms.Write(buf16,2);

//uint16	rangeShift	numTables times 16, minus searchRange ((numTables * 16) - searchRange).
    rangeShift := numTables * 16 - searchRange;
    buf16 := swap16(entrySelector);
    ms.Write(buf16,2);

    OldPos := ms.Position;
    ms.Size := ms.Size + NumTables * 16;
    ms.Position := OldPos;

    //tableRecord	tableRecords[numTables]	Table records array—one for each top-level table in the font
    for i:= 0 to length(ttTableDirectory)-1   do
    begin
      if ttTableDirectory[i].szTag = 'SVG ' then
      begin
{
        SvgPos := ms.Position;

        ms.Write(ttTableDirectory[i].szTag,4);
        buf32 := swap32(TBL.uCheckSum);  ms.Write(buf32,4);
        buf32 := swap32(TBL.uOffset);    ms.Write(buf32,4);
        buf32 := swap32(TBL.uLength);    ms.Write(buf32,4);
}
        Continue;
      end;
      TBL := ttTableDirectory[i];

      TBL.uOffset := ms.Size;
      TBL.uCheckSum := 0;

      OldPos := ms.Position;
      ms.Position := ms.Size;


      if TBL.szTag = 'hmtx' then
      begin
        for j:= 0 to FFontFace.numGlyphs-1 do
        begin
          buf16 := Swap16(FFontFace.hmtx[j].Width);
          ms.Write(buf16,2);
          buf16i := Swap16i(FFontFace.hmtx[j].Left);
          ms.Write(buf16i,2);
        end;
      end
      else
        ms.Write(FontData[ttTableDirectory[i].uOffset], ttTableDirectory[i].uLength);

      TBL.uCheckSum := CalculateCheckSum(ms,TBL);

      ms.Position := OldPos;
      //2DO recalc uCheckSum
      ms.Write(ttTableDirectory[i].szTag,4);
      buf32 := swap32(TBL.uCheckSum);  ms.Write(buf32,4);
      buf32 := swap32(TBL.uOffset);    ms.Write(buf32,4);
      buf32 := swap32(TBL.uLength);    ms.Write(buf32,4);
    end;
// Save non-empty SVG

    if SVGFiles.Count>0 then
    begin
      TBL := ttTableDirectory[iSVG];
      OldPos := ms.Position;
      TBL.uOffset := ms.Size;

      ms.Position := TBL.uOffset;
//uint16 version Table version (starting at 0). Set to 0.
      buf16 := 0; buf16 := swap16(buf16);  ms.Write(buf16,2);
//Offset32 svgDocumentListOffset Offset to the SVG Document List, from the start of the SVG table. Must be non-zero.
      buf32 := 10; buf32 := swap32(buf32);  ms.Write(buf32,4);
//uint32 reserved Set to 0.
      buf32 := 0; buf32 := swap32(buf32);  ms.Write(buf32,4);

//uint16 numEntries Number of SVG document records.
      buf16 := swap16(SVGFiles.Count);  ms.Write(buf16,2);

      ms.Size := ms.Size + SVGFiles.Count*12;
      ms.Position := ms.Size;

      Buf32 := SVGFiles.Count*12+2;
      for i := 0 to SVGFiles.Count-1 do
      begin
        TSVGObject(SVGFiles[i]).SVGRecord.svgDocOffset := Buf32;
        SizePos := ms.Position;
        TSVGObject(SVGFiles[i]).SaveToStream(ms);
        TSVGObject(SVGFiles[i]).SVGRecord.svgDocLength := ms.Position - SizePos;
        Buf32 := Buf32 + TSVGObject(SVGFiles[i]).SVGRecord.svgDocLength;
      end;
      TBL.uLength := Buf32;

      ms.Position := TBL.uOffset+12;
      for i := 0 to SVGFiles.Count-1 do
      begin
        Buf16 := swap16(TSVGObject(SVGFiles[i]).SVGRecord.startGlyphID); ms.Write(buf16,2);
        Buf16 := swap16(TSVGObject(SVGFiles[i]).SVGRecord.endGlyphID);   ms.Write(buf16,2);
        buf32 := swap32(TSVGObject(SVGFiles[i]).SVGRecord.svgDocOffset); ms.Write(buf32,4);
        buf32 := swap32(TSVGObject(SVGFiles[i]).SVGRecord.svgDocLength); ms.Write(buf32,4);
      end;

      TBL.uCheckSum := CalculateCheckSum(ms,TBL);

      ms.Position := OldPos;

      //2DO recalc uCheckSum
      ms.Write(TBL.szTag,4);
      buf32 := swap32(TBL.uCheckSum);  ms.Write(buf32,4);
      buf32 := swap32(TBL.uOffset);    ms.Write(buf32,4);
      buf32 := swap32(TBL.uLength+10);    ms.Write(buf32,4);
    end;

    ms.Position := 0;
    ms.SaveToStream(stream);
  finally
    ms.free;
  end;

end;

procedure TdyTTF.SetSVG(AGlyph: word; ASVG: string);
var
  i:integer;
  SVGObject:TSVGObject;
begin
  i := GetSVGIndex(AGlyph);
  if i=-1 then
  begin
    SVGObject:=TSVGObject.Create;
    SVGFiles.add(SVGObject);
    SVGObject.SVGRecord.startGlyphID := AGlyph;
    SVGObject.SVGRecord.endGlyphID := AGlyph;
  end
  else
    SVGObject:=TSVGObject(SVGFiles[i]);
  SVGObject.Text := ASVG;
end;

function TdyTTF.CalculateCheckSum(Stream: TMemoryStream; TBL:TT_TABLE_DIRECTORY): Cardinal;
var
  I    : Integer;
  Value: Cardinal;
  buf:array of Cardinal;
begin
  Result := 0;
  // set position to beginning of the stream
  Stream.Position := TBL.uOffset;
  SetLength(buf, (TBL.uLength + 3) div 4);
  buf[length(buf)-1] := 0;

  // read first cardinal
  Stream.Read(buf[0], TBL.uLength);
  // read subsequent cardinals
  for I := 0 to length(buf) - 1 do
    Result := Result + Swap32(buf[i]);
end;


{ TSVGObject }

constructor TSVGObject.Create;
begin
  Inherited;
  UndoStack:=TStringList.Create;
  UndoIdx:=0;
  TrailingLineBreak := False;
end;

destructor TSVGObject.Destroy;
begin
  UndoStack.Destroy;
  inherited;
end;

function TSVGObject.Redo: string;
begin
  if UndoIdx >0   then
    UndoIdx := UndoIdx-1;
  Result := UndoStack[UndoIdx];
end;

procedure TSVGObject.SetTextStr(const Value: string);
begin
  if (trim(Text) <> trim(Value)) then
  begin
    UndoStack.Insert(0, Value);
    UndoIdx := 0;
  end;
  inherited;
end;

function TSVGObject.Undo: string;
begin
  if UndoIdx < UndoStack.Count-1  then
    UndoIdx := UndoIdx+1;
  Result := UndoStack[UndoIdx];
end;

end.
