unit Ava02;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls;

type
  TForm2 = class(TForm)
    Ima2: TImage;
    procedure FormCreate(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  Form2: TForm2;
  depx,depy,
  butx,buty : byte;
  trouve : boolean;
  tablo : array[0..10,0..10] of integer;
  ctr,tmp : integer;
  image : TBitmap;
  cases : array[0..16] of TBitmap;
  tca : array[1..64] of byte;
  lim : integer;
  nivo : byte;

implementation

{$R *.dfm}

procedure TForm2.FormCreate(Sender: TObject);
var  i : byte;
begin
  image := TBitmap.Create;
  image.Width := 600;
  image.Height := 600;
  image.Canvas.Brush.Color := $0088000;
  image.Canvas.Rectangle(Rect(0,0,600,600));
  for i := 0 to 16 do
  begin
    cases[i] := TBitmap.Create;
    cases[i].Width := 60;
    cases[i].Height := 60;
    cases[i].Canvas.CopyRect(Rect(0,0,60,60),Ima2.Canvas,Rect(i*60,0,i*60+60,60));
  end;
end;

end.
