unit ColliderUnit;

interface
uses Types,Classes,Math,Windows,GameObjectUnit,System.Generics.Collections;

type

TCollisions = array of array of TGameObject;

TCollider = class
private
    _game_objects:              TList<TGameObject>;
    _collisions:                TList<TList<TGameObject>>;
    _count_of_collisions:       Integer;
    procedure DetectCollisions();
    procedure StepBehind(G:TGameObject);
    procedure StepForward(G:TGameObject);
    procedure Uncollide(i: integer);
    function FindMaxCollision():Integer;
public
    constructor Create();
    destructor Destroy(); override;
    procedure SetGameObjects(GL:TList<TGameObject>);
    procedure DoWork();
end;

implementation
{ TCollider }

constructor TCollider.Create;
begin
    _count_of_collisions := 0;
    _game_objects := TList<TGameObject>.Create;
    _collisions := TList<TList<TGameObject>>.Create;
    OutputDebugString('Collider is Created.');
end;

destructor TCollider.Destroy;
begin
    _count_of_collisions := 0;
    _collisions.DeleteRange(0,_collisions.Count);
    _collisions.Free;
    _game_objects.Free;
    OutputDebugString('Collider is Deleted.');
    inherited;
end;

procedure TCollider.DetectCollisions;
var
    i,j:             Integer;							// индексы списков
    _buffer_list:    TList<TGameObject>;					// буферный список, куда будут отправляться пересеченные объекты
begin
    _collisions.Clear();
    _collisions.DeleteRange(0,_collisions.Count);
    _count_of_collisions := 0;

    for i := 0 to _game_objects.Count-1 do
    begin
    _buffer_list := TList<TGameObject>.Create;
        for j := 0 to _game_objects.Count-1 do
        begin
            if (j <> i) then
            begin
                if (_game_objects.Items[i].Interaction(_game_objects.Items[j])) then
                begin
                    _buffer_list.Add(_game_objects[j]);
                    inc(_count_of_collisions);
                end;
            end;
        end;
    _collisions.Add(_buffer_list);
    end;
end;

procedure TCollider.StepBehind(G:TGameObject);
begin
    G.ChangeDirection();
    G.Step();
    G.ChangeDirection();
end;

procedure TCollider.StepForward(G:TGameObject);
begin
    G.Step();
end;

procedure TCollider.Uncollide(i:Integer);
var
    _buffer_list:              TList<TGameObject>;				// буферный список, куда будут отправляться пересеченные объекты
    _old_count_of_collisions:  Integer;
	  index:                     Integer;
begin
    _buffer_list := TList<TGameObject>.Create(_collisions.Items[i]);
    // передвигаем основной объект на шаг назадS
    StepBehind(_game_objects.Items[i]);
    // проверяем, исчезла ли при этом коллизия
    DetectCollisions();
	// если коллизия не ушла, 
    if(TList<TGameObject>(_collisions.Items[i]).Count <> 0) then					//здесь можно всё это дело отрекурсировать
    begin
        StepForward(_game_objects.Items[i]);
    end;
    //если коллизия не исчезла
    while(TList<TGameObject>(_collisions.Items[i]).Count <> 0)do
    begin
        _buffer_list := _collisions.Items[i];
        // сохраняем предыдущее значение коллизий
        _old_count_of_collisions := _count_of_collisions;
        // делаем шаг назад для каждого из объектов (включая все объекты коллизии)
        for index:=0 to _buffer_list.Count-1 do
        begin
            StepBehind(_buffer_list.Items[index]);
        end;
        StepBehind(_game_objects.Items[i]);
        // повторная проверка на отсутствие коллизий
        DetectCollisions();
        // если после разрешения коллизии мы создали ещё больше коллизий
        if (_count_of_collisions > _old_count_of_collisions) then
        begin
        // то отменяем наши действия
            for index:=0 to _buffer_list.Count-1 do
            begin
                StepBehind(_buffer_list.Items[index]);
            end;
            StepBehind(_game_objects.Items[i]);
                    // и выходим из функции
			_buffer_list.Clear();
			_buffer_list.Free;
            Exit;
        end;
    end;
            // если нам удалось разрешить коллизию
            // то теперь наши объекты будут двигаться с новым вектором
    for index:=0 to _buffer_list.Count-1 do
    begin
        _buffer_list.Items[index].ReflectionDirection(_game_objects[i]);
    end;
    // а сам наш объект также будет впредь двигаться по-другому
    if (_buffer_list.Count <> 0) then
        _game_objects[i].ReflectionDirection(_buffer_list.Items[0]);
	_buffer_list.Clear();
	_buffer_list.Free;
end;

function TCollider.FindMaxCollision():Integer;
var
    _max_length: Integer;
    i:           Integer;
begin
    Result := 0;
    _max_length := 0;

    for i := 0 to _collisions.Count-1 do
    begin
        if(TList<TGameObject>(_collisions.Items[i]).Count > _max_length) then
        begin
            _max_length := TList<TGameObject>(_collisions.Items[i]).Count;
            Result := i;
        end;
    end;
end;

procedure TCollider.SetGameObjects(GL:TList<TGameObject>);
begin
    if(_game_objects.Count <> 0)then
      _game_objects.Clear();
    _game_objects.AddRange(GL);
end;

procedure TCollider.DoWork();
var
    _old_count_of_collisions: Integer;
begin
    DetectCollisions();
    while (_count_of_collisions <> 0) do
    begin
        // сохраняем предыдущее значение коллизий
         _old_count_of_collisions := _count_of_collisions;
		    // пробуем развернуть максимальную коллизию
       // if(_count_of_collisions <> 0)then
       // begin
       // DetectCollisions();
        Uncollide(FindMaxCollision());
       // end;
        // если улучшений нет по результатам наших действий, то выходим
        if(_old_count_of_collisions <= _count_of_collisions)then
        begin
            exit;
        end;
    end;
end;

end.
