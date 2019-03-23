unit GameObjectUnit;

interface
uses Types,Classes,Math,Windows,System.Generics.Collections;

type  TGameObject = class
  private
    _velocity: TPoint;
    _rect: TRect;
    _x,_y: Double;
    _mass: Double;
    _speed: Integer;
    _abs_max_velocity: Integer;
	  function SquareDistanceBetweenPoints(P1,P2:TPoint): Double;
  public
    constructor Create(InRect: TRect;
                       InVelocity: TPoint;
					   InSpeed: Integer = 1;
					   InMass: Double = 0;
					   InAbsMaxVelocity: integer = 15);
    destructor Destroy(); override;

    procedure Step();
    procedure ChangeDirection();
    function  Interaction(G: TGameObject): Boolean;
    function  GetRect():TRect;								                // возможно, стоит заменить на property
    procedure SetRect(R:TRect);							                // возможно, стоит заменить на property
    function GetVelocity():TPoint;
    procedure ChangeRect(var R:TRect);
    procedure ReflectionDirection(G: TGameObject);
end;

implementation

{ TGameObject }

procedure TGameObject.ChangeDirection;
begin
  _velocity.X := -_velocity.X;
  _velocity.Y := -_velocity.Y;
end;

constructor TGameObject.Create(InRect: TRect; InVelocity: TPoint;InSpeed: Integer;InMass:double;InAbsMaxVelocity:Integer);
begin
	_rect := InRect;
  _x := _rect.Location.X;
  _y := _rect.Location.Y;
	_speed := InSpeed;
	_mass := InMass;
	_abs_max_velocity := InAbsMaxVelocity;
	InVelocity.X := InVelocity.X mod _abs_max_velocity;
	InVelocity.Y := InVelocity.Y mod _abs_max_velocity;
	_velocity := InVelocity;
	OutputDebugString('GameObject have been created.')
end;

destructor TGameObject.Destroy;
begin
  OutputDebugString('GameObject have been destroyed.');
  inherited;
end;

function TGameObject.GetRect: TRect;
begin
  Result := _rect;
end;

function TGameObject.GetVelocity: TPoint;
begin
    Result:=TPoint.Create(_velocity);
end;

function TGameObject.Interaction(G: TGameObject): Boolean;
var
  Temp: TRect;
begin
  Result := IntersectRect(Temp,_rect,G.getRect());
end;

procedure TGameObject.SetRect(R: TRect);
begin
   _rect := R;
  _x := _rect.Location.X;
  _y := _rect.Location.Y;
end;

procedure TGameObject.ChangeRect(var R: TRect);
begin
   _rect := R;
end;

procedure TGameObject.Step;
var 
	_new_velocity: 	TPointF;
	_current_speed:	Double;
begin
    _current_speed := Sqrt(_velocity.X* _velocity.X + _velocity.Y* _velocity.Y);
    if(_current_speed = 0) then
      _new_velocity.Y := 0
    else
      _new_velocity.Y := (_speed / Double(_current_speed))*(_velocity.Y);
    if(_velocity.Y = 0) then
      if(_current_speed = 0 )then
        _new_velocity.X := 0
       else
        _new_velocity.X :=  (_speed / Double(_current_speed))*(_velocity.X)
    else
     _new_velocity.X := (_velocity.X / _velocity.Y) * _new_velocity.Y;
    _x := _x + _new_velocity.X;
    _y := _y + _new_velocity.Y;
	_rect.SetLocation(Round(_x),
                      Round(_y));
end;

function TGameObject.SquareDistanceBetweenPoints(P1,P2:TPoint): Double;
begin
	Result:=(P1.X - P2.X) * (P1.X - P2.X) + (P1.Y - P2.Y) * (P1.Y - P2.Y);
end;

procedure TGameObject.ReflectionDirection(G: TGameObject);
var
	_center_of_game_object: TPoint;
	_control_point:			    TPoint;
	_list_of_points: 		    TList<TPoint>;
	_min_distance: 			    Double;
	i:Integer;
begin
	  { поиск центра объекта G }
    _center_of_game_object:= G.GetRect().CenterPoint;
    { список точек текущего объекта}
	  _list_of_points := TList<TPoint>.Create;
    _list_of_points.Add(TPoint.Create(_rect.Left,_rect.Top));
    _list_of_points.Add(TPoint.Create(_rect.Right,_rect.Top));
    _list_of_points.Add(TPoint.Create(_rect.Left,_rect.Bottom));
    _list_of_points.Add(TPoint.Create(_rect.Right,_rect.Bottom));

    {поиск точки текущего объекта, наиболее близкой к центру объекта G}
	  _control_point := _list_of_points.Items[0];
	  _min_distance := SquareDistanceBetweenPoints(_control_point, _center_of_game_object);
    for i:= 0 to _list_of_points.Count - 1 do
    begin
		  if (SquareDistanceBetweenPoints(_list_of_points.Items[i], _center_of_game_object) < _min_distance) then
		  begin
			  _min_distance := SquareDistanceBetweenPoints(_list_of_points.Items[i], _center_of_game_object);
			  _control_point := _list_of_points.Items[i];
		  end;
	  end;
	  { определяем, в какой области находится наиближайщая к центру объекта точка
	  и изменяем в соответствии с ней направление движения}
    if (_control_point.Y <= G.GetRect().TopLeft.Y)then
	  begin
		  if ((_control_point.X >= G.GetRect().TopLeft.X) AND
			    (_control_point.X <= G.GetRect().BottomRight.X)) then                // прямоугольник подобрался сверху
			    _velocity.Y := -_velocity.Y
      else
          ChangeDirection();									                    // ну или немного с края
	  end
    else if (_control_point.Y >= G.GetRect().BottomRight.Y) then
	  begin
        if ((_control_point.X >= G.GetRect().TopLeft.X) AND
			      (_control_point.X <= G.GetRect().BottomRight.X)) then              // прямоугольник подобрался снизу
			       _velocity.Y := -_velocity.Y
        else
             ChangeDirection();									                    // ну или немного с края
	  end
    else
    begin
          if ((_control_point.X <= G.GetRect().TopLeft.X) OR
              (_control_point.X >= G.GetRect().BottomRight.X)) then
              _velocity.X := -_velocity.X
        else
            ChangeDirection();
    end;
    _list_of_points.DeleteRange(0,_list_of_points.Count);
    _list_of_points.Free;
end;

end.
