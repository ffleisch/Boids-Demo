unit swarmunit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Math, typeunit;

type
  swarm = class
  private
    boidsarr: array of boid;
    function randreal(range: real): real;
    function findCenter(): vec2;
    function findAvrgVel(): vec2;
    function rule1(inVec, center: vec2): vec2;
    function rule2(inVec: vec2): vec2;
    function rule3(inVec, avrgVel: vec2): vec2;
  public
    par1, par2, par3, par4: real;
    mdist: real;
    velcap: real;
    aim:vec2;
    aimenabled:boolean;
    constructor Create(posin: vec2; posrange: real; velrange: real;
      size: integer; colorin: Tcolor; colrange: TColor);
    procedure setAim(x,y:integer;conv:transf);
    procedure draw(c: TCanvas; conv: transf);
    procedure step(conv: transf);
    procedure updateVel();
  end;

implementation

function vecAdd(v1, v2: vec2): vec2;
begin
  vecAdd.x := v1.x + v2.x;
  vecAdd.y := v1.y + v2.y;
end;

function vecSub(v1, v2: vec2): vec2;
begin
  vecSub.x := v1.x - v2.x;
  vecSub.y := v1.y - v2.y;
end;

function vecDiv(v1: vec2; scalar: real): vec2;
begin
  vecDiv.x := v1.x / scalar;
  vecDiv.y := v1.y / scalar;
end;

function vecMul(v1: vec2; scalar: real): vec2;
begin
  vecMul.x := v1.x * scalar;
  vecMul.y := v1.y * scalar;
end;

function vecLength(v: vec2): real;
begin
  vecLength := Sqrt(power(v.x, 2) + power(v.y, 2));
end;

function capVec(varIn: vec2; cap: real): vec2;
var
  l: real;
begin
  l := vecLength(varIn);
  if l > cap then
  begin
    capVec.x := (varIn.x / l) * cap + varIn.x * cap / 10;
    capVec.y := (varIn.y / l) * cap + varIn.y * cap / 10;
  end
  else
  begin
    capVec := varIn;
  end;
end;

function vecDist(v1, v2: vec2): real;
begin
  vecDist := Sqrt(power(v2.x - v1.x, 2) + power(v2.y - v1.y, 2));
end;

function swarm.randreal(range: real): real;
begin
  randreal := range * (Random(high(int64)) / high(int64));
end;

constructor swarm.Create(posin: vec2; posrange: real; velrange: real;
  size: integer; colorin: Tcolor; colrange: TColor);
var
  i, r, g, b, r1, g1, b1: integer;
  zwsch: vec2;
begin
  aimenabled:=true;
  aim.x:=0;
  aim.y:=0;
  SetLength(boidsarr, size);
  r := red(colorin);
  g := green(colorin);
  b := blue(colorin);
  for i := 0 to length(boidsarr) - 1 do
  begin
    par1 := 0.0005;
    par2 := 0.0001;
    par3 := 0.01;
    par4 := 0.0005;
    mdist := 3;
    velCap := 0.5;
    zwsch.x := (posin.x + randreal(posrange) - posrange / 2);
    zwsch.y := (posin.y + randreal(posrange) - posrange / 2);
    boidsarr[i].pos := zwsch;
    zwsch.x := randreal(velrange) - velrange / 2;
    zwsch.y := randreal(velrange) - velrange / 2;
    boidsarr[i].vel := zwsch;
    r1 := r + Math.floor(random(red(colrange)) - red(colrange) / 2);
    g1 := g + Math.floor(random(green(colrange)) - green(colrange) / 2);
    b1 := b + Math.floor(random(blue(colrange)) - blue(colrange) / 2);
    while (r1 < 0) do
      r1 := r1 + 255;
    while (g1 < 0) do
      g1 := g1 + 255;
    while (b1 < 0) do
      b1 := b1 + 255;
    while (r1 > 255) do
      r1 := r1 - 255;
    while (g1 > 255) do
      g1 := g1 - 255;
    while (b1 > 255) do
      b1 := b1 - 255;
    boidsarr[i].col := RGBToColor(r1, g1, b1);
  end;

end;

procedure swarm.draw(c: TCanvas; conv: transf);
var
  i: integer;
  r: TRect;
  Esize: integer;
begin
  Esize := 5;
  for i := 0 to length(boidsarr) - 1 do
  begin
    c.brush.color := boidsarr[i].col;
    r.TopLeft.x := Math.floor(boidsarr[i].pos.x * conv.scale + conv.trax) - Esize;
    r.TopLeft.y := Math.floor(boidsarr[i].pos.y * conv.scale + conv.tray) - Esize;
    r.BottomRight.x := Math.floor(boidsarr[i].pos.x * conv.scale + conv.trax) + Esize;
    r.BottomRight.y := Math.floor(boidsarr[i].pos.y * conv.scale + conv.tray) + Esize;
    c.Ellipse(r);
  end;
end;

procedure swarm.setAim(x,y:integer;conv:transf);
var
  xcon,ycon:real;
begin
  xcon := (x - conv.trax) / conv.scale;
  ycon := (y - conv.tray) / conv.scale;
  aim.x:=xcon;
  aim.y:=ycon;
end;

procedure swarm.step(conv: transf);
var
  i: integer;
  xmax, ymax, xmin, ymin: real;
begin
  updateVel();
  xmax := (conv.w - conv.trax) / conv.scale;
  xmin := (-conv.trax) / conv.scale;
  ymax := (conv.h - conv.tray) / conv.scale;
  ymin := (-conv.tray) / conv.scale;
  for i := 0 to length(boidsarr) - 1 do
  begin
    boidsarr[i].pos.x := boidsarr[i].pos.x + boidsarr[i].vel.x;
    while boidsarr[i].pos.x > xmax do
      boidsarr[i].pos.x := boidsarr[i].pos.x - (xmax - xmin);
    while boidsarr[i].pos.x < xmin do
      boidsarr[i].pos.x := boidsarr[i].pos.x + (xmax - xmin);

    boidsarr[i].pos.y := boidsarr[i].pos.y + boidsarr[i].vel.y;
    while boidsarr[i].pos.y > ymax do
      boidsarr[i].pos.y := boidsarr[i].pos.y - (ymax - ymin);
    while boidsarr[i].pos.y < ymin do
      boidsarr[i].pos.y := boidsarr[i].pos.y + (ymax - ymin);
  end;
end;

function swarm.findCenter(): vec2;
var
  i: integer;
  zwsch: vec2;
begin
  zwsch.x := 0;
  zwsch.y := 0;
  for i := 0 to length(boidsarr) do
  begin
    zwsch := vecAdd(zwsch, boidsarr[i].pos);
  end;
  findCenter := VecDiv(zwsch, length(boidsarr));
end;

function swarm.findAvrgVel(): vec2;
var
  i: integer;
  zwsch: vec2;
begin
  zwsch.x := 0;
  zwsch.y := 0;
  for i := 0 to length(boidsarr) do
  begin
    zwsch := vecAdd(zwsch, boidsarr[i].vel);
  end;
  findAvrgVel := VecDiv(zwsch, length(boidsarr));
end;

function swarm.rule1(inVec, center: vec2): vec2;
begin
  rule1 := VecSub(VecSub(center, vecDiv(inVec, length(boidsarr))), inVec);
end;

function swarm.rule2(inVec: vec2): vec2;
var
  i: integer;
  zwsch: vec2;
begin
  zwsch.x := 0;
  zwsch.y := 0;
  for i := 0 to length(boidsarr) do
  begin

    if (vecDist(boidsarr[i].pos, inVec) < mdist) then
    begin
      zwsch := vecAdd(zwsch, vecSub(inVec, boidsarr[i].pos));
    end;
  end;
  rule2 := zwsch;
end;

function swarm.rule3(inVec, avrgVel: vec2): vec2;
begin
  rule3 := VecSub(avrgVel, vecDiv(inVec, length(boidsarr)));
end;

procedure swarm.updateVel();
var
  center: vec2;
  i: integer;
  zwsch: vec2;
  avVel: vec2;
begin
  center := findCenter();
  avVel := findAvrgVel();
  for i := 0 to length(boidsarr) do
  begin
    zwsch := vecMul(rule1(boidsarr[i].pos, center), par1);
    zwsch := vecAdd(zwsch, vecMul(rule2(boidsarr[i].pos), par2));
    zwsch := vecAdd(zwsch, vecMul(rule3(boidsarr[i].vel, avVel), par3));
    zwsch := vecAdd(zwsch, VecMul(VecSub(boidsarr[i].pos,aim), -par4));
    boidsarr[i].vel := capVec(vecAdd(boidsarr[i].vel, zwsch), velCap);
  end;
end;







end.
