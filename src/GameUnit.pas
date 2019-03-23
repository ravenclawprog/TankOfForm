unit GameUnit;

interface
uses GameObjectUnit,ColliderUnit,Vcl.Forms,Vcl.Controls,Vcl.StdCtrls,
Types,Classes,Math,Windows,SysUtils,Vcl.ExtCtrls,System.Generics.Collections;

type

TGame = class
private
    _ground:       TList<TGameObject>;		// границы игрового поля, список представляет собой набор по умолчанию из четырех сторон
    _obstacles:    TList<TGameObject>;		// неподвижные препятствия, кнопки
    _tanks:        TList<TGameObject>;		// подвижные объекты, текстовые поля

    _collider:     TCollider;				// объект, разрешающий столкновения объектов
    
    _step_of_game: Integer;					// такт игры
    _handle_form:  TForm;					// форма для нашей игры
    _buttons:      TList<TButton>;			// список кнопок
    _labels:       TList<TLabel>;			// список лейблов
    _timer:        TTimer;
    procedure ReadFromForm(_only_ground: Boolean);
    procedure WriteToForm();
    procedure Step();
    procedure TimerEvent(Sender: TObject);
public
    constructor Create(HF: TForm; speed:integer = 200);
    destructor Destroy(); override;
    
    procedure Start();
    procedure Stop();
    function IsGameStart(): Boolean;
    procedure ChangeSpeedOfGame(_new_speed: Integer);
    function CheckTheGame(): Boolean;
end;

implementation
{ TGame }

constructor TGame.Create(HF:TForm; speed:integer = 200);
var
    i:          Integer;
    AButton:    TButton;
    ALabel:     TLabel;
    RandomX:    Integer;
    RandomY:    Integer;
begin
    OutputDebugString('Game is Creating.');
    _handle_form := HF;
    _ground := TList<TGameObject>.Create;
    _obstacles := TList<TGameObject>.Create;
    _tanks := TList<TGameObject>.Create;
    _collider := TCollider.Create;
    _buttons := TList<TButton>.Create;
    _labels := TList<TLabel>.Create;
    _buttons.Clear();
    _labels.Clear();
    Randomize;
    for i := 0 to _handle_form.ComponentCount - 1 do
    begin
        if(_handle_form.Components[i] is TButton)then
        begin
            AButton:=((_handle_form.Components[i]) as TButton);
            _buttons.Add(AButton);
            _obstacles.Add(TGameObject.Create(TRect.Create(AButton.Left,
            AButton.Top,
            AButton.Left+AButton.Width,
            AButton.Top+AButton.Height),
            TPoint.Create(0,0)));
        end;
        if(_handle_form.Components[i] is TLabel)then
        begin
            ALabel:=((_handle_form.Components[i]) as TLabel);
            if(ALabel.Caption = 'T')then
            begin
                RandomX:=RandomRange(-15,15);
                RandomY:=RandomRange(-15,15);
                while((Abs(RandomX) <= 5) OR (Abs(RandomY) <= 5)) do
                begin
                  RandomX:=RandomRange(-15,15);
                  RandomY:=RandomRange(-15,15);
                end;
                _labels.Add(ALabel);
                _tanks.Add(TGameObject.Create(TRect.Create(ALabel.Left,
                ALabel.Top,
                ALabel.Left+ALabel.Width,
                ALabel.Top+ALabel.Height),
                TPoint.Create(RandomX,RandomY)));
            end;
        end;
    end;
    _ground.Add(TGameObject.Create(TRect.Create(
    0, -2, _handle_form.ClientWidth,0), TPoint.Create(0,0)));
    _ground.Add(TGameObject.Create(TRect.Create(
    0, _handle_form.ClientHeight, _handle_form.ClientWidth,2+_handle_form.ClientHeight), TPoint.Create(0,0)));
    _ground.Add(TGameObject.Create(TRect.Create(
    -2, 0, 0,_handle_form.ClientHeight), TPoint.Create(0,0)));
    _ground.Add(TGameObject.Create(TRect.Create(
    _handle_form.ClientWidth, 0, _handle_form.ClientWidth+2,_handle_form.ClientHeight), TPoint.Create(0,0)));
    _timer := TTimer.Create(nil);
    _timer.OnTimer:= TimerEvent;
    _step_of_game:=speed;
    _timer.Interval:=_step_of_game;
    _timer.Enabled:=False;
    OutputDebugString('Game have been created.');
end;

destructor TGame.Destroy;
begin
    OutputDebugString('Game is deleting.');
    _ground.DeleteRange(0,_ground.Count);
    _obstacles.DeleteRange(0,_obstacles.Count);
    _tanks.DeleteRange(0,_obstacles.Count);
    
    _buttons.Clear();
    _labels.Clear();
    
    _buttons.Free;
    _labels.Free;
    _ground.Free;
    _obstacles.Free;
    _tanks.Free;
    _collider.Free;
    _timer.Free;
    OutputDebugString('Game have been deleted.');
    inherited;
end;

procedure TGame.ChangeSpeedOfGame(_new_speed: Integer);
begin
  _step_of_game := _new_speed;
  _timer.Interval:=_step_of_game;
end;

function TGame.IsGameStart: Boolean;
begin
  Result := _timer.Enabled;
end;

function TGame.CheckTheGame(): Boolean;
var
    i,j:             Integer;
    _all_objects:    TList<TGameObject>;
begin
    _all_objects := TList<TGameObject>.Create;
    _all_objects.AddRange(_obstacles);
    _all_objects.AddRange(_ground);
    _all_objects.AddRange(_tanks);
    Result := true;
    for i:= 0 to _all_objects.Count - 1 do
    begin
        for j:= i+1 to _all_objects.Count -1 do
        begin
            if(_all_objects[i].Interaction(_all_objects[j]))then
            begin
                Result := false;
                break;
            end;
        end;
        if(Result = false)then
            break;
    end;
    _all_objects.Clear();
    _all_objects.Free;
end;

procedure TGame.WriteToForm();
var
    i:      Integer;
begin
    for i:= 0 to _labels.Count - 1 do
    begin
        TLabel(_labels.Items[i]).Left := _tanks.Items[i].GetRect().Location.X;
        TLabel(_labels.Items[i]).Top := _tanks.Items[i].GetRect().Location.Y;
        //TLabel(_labels.Items[i]).Caption:=IntToStr(_tanks.Items[i].GetVelocity().X)+
        //';'+IntToStr(_tanks.Items[i].GetVelocity().Y);

    end;
    for i:= 0 to _buttons.Count - 1 do
    begin
        TButton(_buttons.Items[i]).Left := _obstacles.Items[i].GetRect().Left;
        TButton(_buttons.Items[i]).Top := _obstacles.Items[i].GetRect().Top;
    end;
end;

procedure TGame.ReadFromForm(_only_ground: Boolean);
var
	i:integer;
begin
    If(not(_only_ground))then
    begin
    for i:= 0 to _tanks.Count - 1 do
    begin
        _tanks.Items[i].SetRect(Rect(_labels.Items[i].Left,
        _labels.Items[i].Top,
        _labels.Items[i].Left+_labels.Items[i].Width,
        _labels.Items[i].Top+_labels.Items[i].Height));
    end;
    for i:= 0 to _buttons.Count - 1 do
    begin
        _obstacles.Items[i].SetRect(Rect(_buttons.Items[i].Left,
        _buttons.Items[i].Top,
        _buttons.Items[i].Left+_buttons.Items[i].Width,
        _buttons.Items[i].Top+_buttons.Items[i].Height));
    end;
    end;
    _ground.Items[0].SetRect(Rect(
    0, -2, _handle_form.ClientWidth,0));
    _ground.Items[1].SetRect(Rect(
    0, _handle_form.ClientHeight, _handle_form.ClientWidth,2+_handle_form.ClientHeight));
    _ground.Items[2].SetRect(Rect(
    -2, 0, 0,_handle_form.ClientHeight));
    _ground.Items[3].SetRect(Rect(
    _handle_form.ClientWidth, 0, _handle_form.ClientWidth+2,_handle_form.ClientHeight));
end;

procedure TGame.Start;
begin
  _timer.Enabled := True;
end;

procedure TGame.Step;
var
   i:               Integer;
   _all_objects:    TList<TGameObject>;
begin
    for i:=0 to _tanks.Count - 1 do              // производим шаг каждого танка
    begin
      _tanks.Items[i].Step();
    end;
    _all_objects := TList<TGameObject>.Create;
    _all_objects.AddRange(_tanks);
    _all_objects.AddRange(_obstacles);
    _all_objects.AddRange(_ground);
    _collider.SetGameObjects(_all_objects);                    // установка списка объектов для распознавания коллизий
    _collider.DoWork();
    _all_objects.Clear();
    _all_objects.Free;
end;

procedure TGame.Stop;
begin
  _timer.Enabled := false;
end;

procedure TGame.TimerEvent(Sender: TObject);
begin
  ReadFromForm(true);
  Step();
  WriteToForm();
end;

end.
