# 0. О программе

  TankOfForm - проект, имитирующий движение танков по местности с препятствиями.

# 1. Структура репозитория

    \src - каталог, содержащий в себе основной код приложения;  
    \ - корневой каталог;  

# 2. Системные требования
   
	* ОС Windows 7 или выше;  
	* Delphi XE5 или выше;  
	
# 3. Установка программы

   Установка программы не требуется.
   После сборки проекта приложение доступно для установки по адресу \src\Win32\Debug\TankOfForm.exe.  

# 4. Настройка программы

   Перед запуском сборки программы рекомендуется установить свою конфигурацию объектов на Windows Forms проекта. При этом любые кнопки типа TButton, принадлежащие главной форме GeneralForm являются препятствиями; текстовые поля типа TLabel, у которых в поле "Caption" содержится латинская буква "T" будут являться танками. (Для отображения границ рекомендуется изменить цвет фона текстового поля).  
   Поле класса TGameObject _speed определяет, на сколько пикселей за такт будет перемещен объект. Поле _abs_max_velocity задаёт границы абсолютного значения для вектора скорости.  
   Объект TrackBar на форме задаёт частоту вызова тактов игры. Начальное значение задаётся в конструкторе класса TGame. При изменении состояния элемента управления TTrackBar происходит изменение скорости игры.
   
# 5. Инструкция по работе

   Перед запуском приложения необходимо установить объекты на форме.  
   Подвижными объектами на форме являются объекты типа TLabel, поле "Caption" которых содержит латинскую букву "T".  
   После запуска, программа проводит проверку расположения объектов на форме. Если объекты пересекаются (кнопки и текстовые поля, содержащие букву "Т") или же данные объекты выходят за форму, то пользователю выводится об этом сообщение. В принципе, можно сделать так, чтобы они подкрашивались каким-нибудь цветом.  
   ВНИМАНИЕ! Данная программа не может обработать особо сложные столкновения объектов (deadlock), из-за чего возможны зависания, выводы сообщения об ошибках, выход объектов за их пределы препятствий.
   