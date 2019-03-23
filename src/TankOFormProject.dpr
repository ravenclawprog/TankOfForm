program TankOFormProject;

uses
  Vcl.Forms,
  GeneralUnit in 'GeneralUnit.pas' {GeneralForm},
  GameObjectUnit in 'GameObjectUnit.pas',
  ColliderUnit in 'ColliderUnit.pas',
  GameUnit in 'GameUnit.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TGeneralForm, GeneralForm);
  Application.Run;
end.
