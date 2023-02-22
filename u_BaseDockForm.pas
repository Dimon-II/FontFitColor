unit u_BaseDockForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.AppEvnts, dy_TTFHelper;

type
  TBaseDockForm = class(TForm)
    StatusBar: TStatusBar;
    appEvents: TApplicationEvents;
    procedure appEventsIdle(Sender: TObject; var Done: Boolean);
  private
    function GetdyTTF: TdyTTF;
    { Private declarations }
  public
    { Public declarations }
     procedure WMSize(var Msg: TMessage); message WM_SIZE;
     property dyTTF:TdyTTF read GetdyTTF;
  end;

var
  BaseDockForm: TBaseDockForm;

implementation

{$R *.dfm}

uses u_MainForm;


procedure TBaseDockForm.appEventsIdle(Sender: TObject;
  var Done: Boolean);
begin
  StatusBar.Visible := Floating
end;

function TBaseDockForm.GetdyTTF: TdyTTF;
begin
  result := FormMain.dyTTF;
end;

procedure TBaseDockForm.WMSize(var Msg: TMessage);
begin
  if Msg.WParam  = SIZE_MINIMIZED then
  begin
    ManualDock(FormMain.DockTabSet);
    PostMessage(Handle,WM_SIZE, SIZE_RESTORED,0);
  end
  else
    Inherited;
end;

end.
