program bomber;
uses crt,graph,dos;
type      coord  = record
                    x     : integer;
                    y     : integer;
           end;

var Gd, Gm, dydis,jetdydis,readhouse,bumnr,mstnr             : Integer;
    f                         : file;
    introp,housep,moonp,jetp,bombp,bomber1p,bomber2p       : pointer;
    housesf                   : text;
    housname,jetfilename      : string[6];
    housex                    : integer;
    testi                     : boolean;
    bum                       :array[0..9] of pointer;
    starcoord                 :array[0..99] of coord;
    KBHEADPTR       : WORD ABSOLUTE 0:$041A;
    KBTAILPTR       : WORD ABSOLUTE 0:$041C;
label               1;
procedure finish;
begin
      nosound;
{atminties islaisvinimas}
{      dydis:=imagesize(1,1,160,200);
      freemem(introp,dydis);
      dydis:=imagesize(1,1,10,10);
      freemem(bombp,dydis);
      for bumnr:=0 to 9 do begin
                  dydis:=imagesize(1,1,50,50);
                  freemem(bum[bumnr],dydis);
                           end;
      jetdydis:=imagesize(1,1,100,40);
      freemem(jetp,jetdydis);
      dydis:=imagesize(1,1,100,100);
      freemem(moonp,dydis);
      dydis:=imagesize(1,1,70,230);
      freemem(housep,dydis); }
      closegraph;
      halt;

end;

procedure intro;
begin
  clearviewport;
  putimage(220,160,introp^,0);
  repeat until keypressed;
  clearviewport;
  putimage(195,165,bomber1p^,0);
  repeat
   if port[$60]=1 then finish;
  until port[$60]=28;
  putimage(195,165,bomber2p^,0);
  repeat until port[$60]=28;
  clearviewport;

end;

procedure set_sky;
var       zx,zy,zsk : integer;
begin
    for zsk:=1 to 100 do
        begin
           zx:=random(640); zy:=random(100);
           putpixel(zx,zy,random(15)+1);
           starcoord[zsk].x:=zx;       starcoord[zsk].y:=zy;
         end;
     putimage(0,10,moonp^,0);
     setcolor(green); line(0,479,640,479);
end;


PROCEDURE main_proc;
var        jetcoord,bombcoord     : coord;
           jetfile                : file;
           pirmyn,paleista        : boolean;
           kl                     : byte;
           star,STARNR                   : integer;

procedure explode(xx,yy:integer);
var       sk      : integer;
begin
     if yy<getmaxy then begin
        for sk:=0 to 8 do
          begin
              putimage(xx,yy,bum[sk]^,0);
              sound((sk+1)*10);
          end;
        for sk:=8 downto 0 do
          begin
              putimage(xx,yy,bum[sk]^,0);
              sound((sk+1)*10);
          end;
        putimage(xx,yy,bum[9]^,0);
        nosound;
        end;
end;

function crash          : boolean;
var      v : integer;
begin
     if getpixel(jetcoord.x+101,jetcoord.y+40) <>0 then
      begin
           putimage(jetcoord.x,jetcoord.y,jetp^,0);
         for v:=1 to 5 do explode(jetcoord.x+random(50),jetcoord.y+random(20));
           crash:=true;
      end else crash:=false;
end;


function bomb_crash:boolean;
begin
     if getpixel(bombcoord.x+3,bombcoord.y+21) <>0 then
      begin
          explode(bombcoord.x-2,bombcoord.y+10);
          bomb_crash:=true;
      end else bomb_crash:=false;
end;


begin
     jetcoord.x:=00; jetcoord.y:=160;

     assign(jetfile,jetfilename+'.ega');
     reset(jetfile,jetdydis);
     blockread(jetfile,jetp^,1);
     close(jetfile);
     setfillstyle(1,0);
     pirmyn:=true;
     paleista:=false;
    while pirmyn do
      begin
           putimage(jetcoord.x,jetcoord.y,jetp^,0);
{           delay(20);}
           jetcoord.x:=jetcoord.x+3;
           sound(20);
{           putimage(jetcoord.x,jetcoord.y,jetp^,0);}
           if jetcoord.x>=635 then
              begin
                    bar(jetcoord.x+5,jetcoord.y,jetcoord.x-100,jetcoord.y+40);
                   jetcoord.x:=1;
                   jetcoord.y:=jetcoord.y+10;
              end;
           if crash then begin pirmyn:=false; testi:=false; end;
           kbtailptr:=kbheadptr;
           kl:=port[$60];
           if (kl=48) and (not paleista) then
              begin
                   bombcoord.y:=jetcoord.y+40;
                   bombcoord.x:=jetcoord.x+50;
                   paleista:=true;
               end;
            if paleista then
               begin
                   bombcoord.y:=bombcoord.y+6;
                   sound(bombcoord.y div 2);
                   putimage(bombcoord.x,bombcoord.y,bombp^,0);
                   if bombcoord.y>=475 then paleista:=false;

                   if bomb_crash then paleista:=false;
               end;
            if (jetcoord.y>=getmaxy-40) and
               (jetcoord.x>=getmaxx div 2) then begin
             pirmyn:=false; nosound;
             cleardevice;
             set_sky;
             end;
           for star:=1 to 5 do
            begin
             starnr:=random(99);
             putpixel(starcoord[starnr].x,starcoord[starnr].y,0);
             starcoord[starnr].x:=100+random(540);
             starcoord[starnr].y:=random(100);
             putpixel(starcoord[starnr].x,starcoord[starnr].y,random(16));
            end;
      end;
end;


BEGIN
     randomize;    nosound;
     Gd := detect;
     InitGraph(Gd, Gm, '');
     if GraphResult <> grOk then Halt(1);
     clearviewport;


     dydis:=imagesize(1,1,160,200);
     getmem(introp,dydis);
     assign(f,'asoft.ega');
     reset(f,dydis);
     blockread(f,introp^,1);
     close(f);

     dydis:=imagesize(1,1,250,150);
     getmem(bomber1p,dydis);
     assign(f,'bomber1.ega');
     reset(f,dydis);
     blockread(f,bomber1p^,1);
     close(f);
     getmem(bomber2p,dydis);
     assign(f,'bomber2.ega');
     reset(f,dydis);
     blockread(f,bomber2p^,1);
     close(f);

     dydis:=imagesize(1,1,10,10);
     getmem(bombp,dydis);
     assign(f,'bomb1.ega');
     reset(f,dydis);
     blockread(f,bombp^,1);
     close(f);

     for bumnr:=0 to 9 do
     begin
            dydis:=imagesize(1,1,50,50);
            getmem(bum[bumnr],dydis);
            assign(f,'bum'+(chr(48+bumnr))+'.ega');
            reset(f,dydis);
            blockread(f,bum[bumnr]^,1);
            close(f);
     end;

     jetdydis:=imagesize(1,1,100,40);
     getmem(jetp,jetdydis);

     dydis:=imagesize(1,1,100,100);
     getmem(moonp,dydis);
     assign(f,'hmoon.ega');
     reset(f,dydis);
     blockread(f,moonp^,1);
     close(f);
{     set_sky;}

     dydis:=imagesize(1,1,70,230);
     getmem(housep,dydis);

1:   intro;
     set_sky;

     assign(housesf,'houses.mp');
     reset(housesf);
     testi:=true;
     mstnr:=1;
     while ((mstnr<8) and (testi=true)) do
      begin
           housex:=60;
           for readhouse:=1 to 9 do
            begin
                 read(housesf,housname);
                 assign(f,housname+'.ega');
                 reset(f,dydis);
                 blockread(f,housep^,1);
                 close(f);
                 putimage(housex,478-230,housep^,0);
                 housex:=housex+50;
             end;
             read(housesf,jetfilename);
             main_proc;
             readln(housesf);
             mstnr:=mstnr+1;
       end;
       goto 1;
end.