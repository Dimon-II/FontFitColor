program FontFitColor;

uses
  Vcl.Forms,
  Vcl.Controls,
  dy_TTFHelper in 'dy_TTFHelper.pas',
  u_TtfForm in 'u_TtfForm.pas' {FormTTF},
  u_MainForm in 'u_MainForm.pas' {FormMain},
  u_GlyphForm in 'u_GlyphForm.pas' {FormGlyph},
  u_FolderSVGForm in 'u_FolderSVGForm.pas' {FormSvgFolder},
  u_BaseDockForm in 'u_BaseDockForm.pas' {BaseDockForm},
  PT_UnicodeNames in 'PT_UnicodeNames.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormMain, FormMain);
  Application.CreateForm(TFormTTF, FormTTF);
  Application.CreateForm(TFormGlyph, FormGlyph);
  Application.CreateForm(TFormSvgFolder, FormSvgFolder);
  FormTTF.Show;
  FormTTF.ManualDock(FormMain.pnMain, nil, alClient);

  FormGlyph.Show;
  FormGlyph.ManualDock(FormMain.pnMain, nil, alRight);

  FormSvgFolder.Show;
  FormSvgFolder.ManualDock(FormMain.pnMain, nil, alBottom);


  Application.Run;
end.
