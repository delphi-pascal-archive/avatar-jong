unit Ava01;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, Ava02, Astar, StdCtrls, Menus;

type
  TForm1 = class(TForm)
    Plato: TImage;
    Panel1: TPanel;
    BNouveau: TButton;
    BQuitter: TButton;
    Timer1: TTimer;
    Ptim: TPanel;
    Pnivo: TPanel;
    BPause: TButton;
    IPause: TImage;
    Ifin: TImage;
    procedure PlatoMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure AfficheCase(x,y,d : integer);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BNouveauClick(Sender: TObject);
    procedure Initialiser;
    procedure FinTableau;
    procedure BQuitterClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure BPauseClick(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

var
  cas1 : boolean;
  fond : TColor;
  bfin : boolean = false;

procedure Trace(a,b : integer);
begin
  ShowMessage(format('%d -%d',[a,b]));
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  // Initialise les listes de recherche de chemin
  lesCases := TAStarList.Create;
  leChemin := TAStarList.Create;
  macase := TAStarcell.Create;
  Randomize;
  fond := RGB(246,246,184);
  nivo := 0;
  lim := 240;   // durée maxi du jeu en secondes pour un tableau
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
var i : byte;
begin
  macase.Free;
  leChemin.Free;
  lesCases.Free;
  image.Free;
  for i := 0 to 16 do cases[i].Free;
end;

procedure TForm1.AfficheCase(x,y,d : integer); // pour le tracé du chemin
begin
  plato.Canvas.Draw(x*60,y*60,cases[d]);
  plato.Repaint;
  sleep(50);
  plato.Canvas.Draw(x*60,y*60,cases[16]);
end;

procedure TForm1.PlatoMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var i,d : integer;
    px,py : integer;
begin
  if bfin then exit;
  if not Timer1.Enabled then exit;
  if cas1 then            // si clic sur la 1ère case
  begin
    depx := X div 60;
    depy := Y div 60;
    px := depx * 60 + 1;
    py := depy * 60 + 1;
    cas1 := false;
    plato.Canvas.Pen.Color := clRed;
    Plato.Canvas.Pen.Width := 5;
    Plato.Canvas.Polyline([Point(px,py),Point(px+57,py),Point(px+57,py+57),
                          Point(px,py+57),Point(px,py)]);
    exit;
  end;
  butx := X div 60;
  buty := Y div 60;
  px := butx * 60 + 1;
  py := buty * 60 + 1;
  Plato.Canvas.Polyline([Point(px,py),Point(px+57,py),Point(px+57,py+57),
                          Point(px,py+57),Point(px,py)]);
  if tablo[butx,buty] <> tablo[depx,depy] then   // si cases différentes
  begin
    beep;
    Plato.Canvas.Draw(0,0,image);
    cas1 := true;
    exit;
  end;
  d := tablo[depx,depy];    // on sauvegarde le type de case
  tablo[depx,depy] := -1;   // on annule les cases début et fin pour permettre
  tablo[butx,buty] := -1;   // la recherche du chemin composé de cases négatives
  if CheminOk(Point(depx,depy),Point(butx,buty)) then  // Si un chemin existe
  begin
    Plato.Canvas.Draw(depx*60,depy*60,cases[16]);
    for i := High(chemin) downto 1 do                  // on l'affiche
    begin
      AfficheCase(chemin[i].X,chemin[i].Y,d);
    end;
    image.Canvas.Draw(depx*60,depy*60,cases[16]);      // et on efface les cases
    image.Canvas.Draw(butx*60,buty*60,cases[16]);
    tablo[depx,depy] := -1;
    tablo[butx,buty] := -1;
    Plato.Canvas.Draw(0,0,image);
    inc(ctr);
  end
  else
    begin   // sinon on restore les cases début et fin de chemin
      beep;
      tablo[depx,depy] := d;
      tablo[butx,buty] := d;
      Plato.Canvas.Draw(0,0,image);
    end;  
  cas1 := true;
  if ctr = 32 then FinTableau;
end;

procedure TForm1.BNouveauClick(Sender: TObject);
begin
  lim := 240;
  nivo := 0;
  bfin := false;
  Ifin.Visible := false;
  Initialiser;
end;

procedure TForm1.Initialiser;
var  i,k,c : byte;
     x,y : integer;
begin
  k := 0;
  for i := 1 to 32 do     // tirage des paires de cases
  begin
    tca[i] := k;
    tca[i+32] := k;
    inc(k);
    if k > 15 then k := 0;
  end;
  for i := 1 to 64 do    // mélange des cases
  begin
    k := Random(64)+1;
    c := tca[i];
    tca[i] := tca[k];
    tca[k] := c;
  end;
  for x := 0 to 9 do    // Init Image
    for y := 0 to 9 do
    begin
      tablo[x,y] := -1;
      image.Canvas.Draw(x*60,y*60,cases[16]);
    end;
  c := 0;
  for x := 1 to 8 do      // affichage des cases
    for y := 1 to 8 do
    begin
      inc(c);
      tablo[x,y] := tca[c];
      image.Canvas.Draw(x*60,y*60,cases[tca[c]]);
    end;
  Plato.Canvas.Draw(0,0,image);
  cas1 := true;
  ctr := 0;
  tmp := lim;
  Ptim.Color := clYellow;
  Ptim.Font.Color := clNavy;
  inc(nivo);
  Pnivo.Caption := Format('New %d',[nivo]);
  Timer1.Enabled := true;
end;

procedure TForm1.FinTableau;
begin
  Timer1.Enabled := false;
  if tmp < lim then
  begin
    case nivo of          // on réduit la durée  en fonction du niveau
      1 : dec(lim,30);
      2 : dec(lim,25);
      3 : dec(lim,20);
      4 : dec(lim,15);
      else dec(lim,10);
    end;
    Initialiser;          // on lance le tableau suivant
  end;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  dec(tmp);
  Ptim.Caption := IntToStr(tmp);
  if tmp = 30 then
  begin
    Ptim.Color := clRed;
    Ptim.Font.Color := clYellow;
  end;
  if tmp = 0 then
  begin
    Timer1.Enabled := false;
    Ifin.Visible := true;
    bfin := true;
  end;
end;
 
procedure TForm1.BQuitterClick(Sender: TObject);
begin
  Close;
end;

procedure TForm1.BPauseClick(Sender: TObject);
begin
  if Timer1.Enabled then
  begin
    Timer1.Enabled := false;
    IPause.Visible := true;
  end
  else begin
         IPause.Visible := false;
         Timer1.Enabled := true;
       end;
end;

end.
