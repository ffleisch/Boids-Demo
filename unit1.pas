unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls,math, swarmunit, typeunit;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Panel1: TPanel;
    Timer1: TTimer;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure draw();
    procedure Panel1Click(Sender: TObject);
    procedure Panel1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Timer1Timer(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;
  swarmarr: array of swarm;
  swarms: integer;
  conversion:transf;
implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
var
  i: integer;
  pos,vel:vec2;
  m:integer;
begin
  randomize();
  conversion.scale:=10;
  conversion.trax:=math.floor(panel1.width/2);
  conversion.tray:=math.floor(panel1.height/2);
  conversion.w:=panel1.Width;
  conversion.h:=panel1.Height;
  swarms:=2;
  SetLength(swarmarr,swarms);
  for i := 0 to length(swarmarr) do
  begin
    pos.x:=0;
    pos.y:=0;
    swarmarr[i] := swarm.Create(pos,10,0.1,101,RGBToColor(random(255),random(255),random(255)),RGBToColor(30,30,30));
  end;
  m:=length(swarmarr);

end;

procedure TForm1.Button1Click(Sender: TObject);

begin
  timer1.Enabled:= not timer1.Enabled;
end;

procedure TForm1.draw();
var
  i:integer;
begin
  panel1.canvas.brush.color:=clWhite;
  panel1.canvas.FillRect(0,0,panel1.width,panel1.height);
  for i:=1 to length(swarmarr) do
  begin
    swarmarr[i].draw(panel1.canvas,conversion);
  end;
end;

procedure TForm1.Panel1Click(Sender: TObject);
begin

end;

procedure TForm1.Panel1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
i:integer;
begin
  for i:=1 to length(swarmarr) do
  begin
    swarmarr[i].setAim(X,Y,conversion);
  end;
end;


procedure TForm1.Timer1Timer(Sender: TObject);
var
  i:integer;
begin
   for i:=0 to length(swarmarr) do
  begin
    swarmarr[i].step(conversion);
  end;
  draw();
end;

end.
