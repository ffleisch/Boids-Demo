unit typeunit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs;
type
  vec2=record
    x:real;
    y:real;
  end;

  boid=record
    vel:vec2;
    pos:vec2;
    col:TColor;
  end;

  transf=record
    trax:integer;
    tray:integer;
    scale:real;
    w:integer;
    h:integer;
  end;

implementation

end.

