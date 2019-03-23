unit GeneralUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, GameUnit, Vcl.ComCtrls;

type
  TGeneralForm = class(TForm)
    Button1: TButton;
    Label1: TLabel;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    TrackBar1: TTrackBar;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    g:TGame;
  end;

var
  GeneralForm: TGeneralForm;

implementation

{$R *.dfm}

procedure TGeneralForm.FormCreate(Sender: TObject);
begin
  g:= TGame.Create(TForm(Self),100);
  if(g.CheckTheGame())then
  begin
    g.Start();
  end
  else
  begin
    g.Stop;
    ShowMessage('Игра не запущена. Пожалуйста, проверьте правильность расположения объектов.');
  end;
end;

procedure TGeneralForm.FormDestroy(Sender: TObject);
begin
  g.Destroy;
end;

procedure TGeneralForm.FormPaint(Sender: TObject);
begin
  InvalidateRect(Self.Canvas.Handle,nil,false);
end;

procedure TGeneralForm.TrackBar1Change(Sender: TObject);
begin
  if((sender as TTrackBar).Position = 0) then
    g.ChangeSpeedOfGame(0)
  else
    g.ChangeSpeedOfGame(Round(1000*1/((sender as TTrackBar).Position)));
end;

end.
