program AvaJong;

uses
  Forms,
  Ava01 in 'Ava01.pas' {Form1},
  Astar in 'Astar.pas',
  Ava02 in 'Ava02.pas' {Form2};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
