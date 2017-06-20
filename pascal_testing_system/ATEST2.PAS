program testgrf2;
uses graph,crt,dos,Main,SimpGrfx;
{$M 65520, 0, 655360}
var
    dir:string;
begin
     getdir(0,dir);
     {$I-}
     chdir('\ATEST');
     {$I+}
     if ioresult=0 then
     begin
       SetGraph;
        Intro;
       DeskTop;
       closegraph;
       writeln('Viso gero!');
     end else
     writeln('Klaida: programa ir visi failai turi buti katalge [diskas]:\atest !');
     chdir(dir);
end.