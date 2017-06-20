Unit SimpGrfx;
INTERFACE

{$L cgadrv.obj}
{$L egadrv.obj}
var
   ListArray:array[1..80] of string[50];


procedure SetGraph;
Procedure SetRGBColor(Color,wr,wg,wb : Byte);
procedure RestorePal;
procedure AllBlack;
procedure OpenEga(x,y,plotis,aukstis:integer; fname:string;bitblt:integer);
Procedure Intro;
function InsertString(x,y,ilgis,col,bcol:integer; zodis,def:string):string;
function GetFromList(x,y,stulpeliu,eiluciu,viso:integer;st:string):integer;
function GetFileName(ext:string):string;
function IntToStr(I: Longint): String;

IMPLEMENTATION
uses graph,crt,dos;
Procedure CGAdriver; far; external;
Procedure EgaDriver; far; external;

Procedure SetGraph;
var
  GraphDriver: Integer;
  GraphMode: Integer;

begin
   DirectVideo:=false;
   GraphDriver:=RegisterBGIDriver(@CGAdriver);
   GraphDriver:=RegisterBGIDriver(@EgaDriver);
   GraphDriver:=Detect;
   InitGraph(GraphDriver,GraphMode,'');
   SetGraphMode(2);
end;

Procedure SetRGBColor;
begin
  Port[$3C8]:=Color;
  Port[$3C9]:=wr;
  Port[$3C9]:=wg;
  Port[$3C9]:=wb;
end;

procedure RestorePal;
var col:integer;
begin
    for col:=0 to GetMaxColor do
    SetPalette(col,col);
end;

procedure AllBlack;
var col:integer;
begin
    for col:=0 to GetMaxColor do
    SetPalette(col,0);
end;

procedure OpenEga;
var rod:pointer;
      f:file;
    dydis:integer;
begin
     dydis:=imagesize(1,1,plotis,aukstis);
     getmem(rod,dydis);
      assign(f,fname);
      reset(f,1);
      blockread(f,rod^,dydis);
      close(f);
     putimage(x,y,rod^,bitblt);
     freemem(rod,dydis);
end;

Procedure Intro;
type star=record
            x,y,greitis,col:integer;
            det:boolean;
           end;
var ex,sx,sy,n,tarpas:integer;
    stars:array[1..50] of star;
    leave:boolean;

procedure MoveStars;
var ss:integer;
begin
     for ss:=1 to 50 do
     begin
         if stars[ss].x>640 then
          begin stars[ss].x:=1;
                stars[ss].y:=random(480);
                stars[ss].greitis:=random(10)+1;
            end;
         if stars[ss].det then putpixel(stars[ss].x,stars[ss].y,0);
         stars[ss].x:=stars[ss].x+stars[ss].greitis;
         if getpixel(stars[ss].x,stars[ss].y)<>0 then stars[ss].det:=false
          else stars[ss].det:=true;
         if stars[ss].det then
              putpixel(stars[ss].x,stars[ss].y,stars[ss].col);
     end;
end;

begin
      SetBkcolor(black); ClearDevice;
      setfillstyle(1,0); bar(0,0,getmaxx,getmaxy);
      OpenEga(150,130,300,200,'asm.ega',0);
      OpenEga(260,188,90,90,'testas.ega',0);
      for n:=1 to 50 do
      begin
         sx:=random(640); sy:=random(480);
         stars[n].x:=sx; stars[n].y:=sy;
         stars[n].greitis:=random(10)+1; stars[n].col:=random(10)+1;
         if getpixel(stars[n].x,stars[n].y)=0 then
          begin
               putpixel(stars[n].x,stars[n].y,stars[n].col);
               stars[n].det:=true;
          end else stars[n].det:=false;
      end;
      ex:=1;  tarpas:=1;
      SetTextStyle(0,0,1); settextjustify(0,2);
      setcolor(blue); outtextxy(255,450,'Sapuskite [Esc]');
      leave:=false;
       repeat
         MoveStars;
         delay(10);
         if keypressed then if readkey=#27 then leave:=true;
       until leave;
end;

function InsertString;
const curs='€';{€}
var kl:char;
    startx,tx,ty,nr:integer;     {simb. plotis=8pxl}
    IStr:string;
    sp:pointer;
    size:integer;
begin
     SetLineStyle(0,0,1); settextjustify(0,2);
     SetTextStyle(0,0,1); ty:=y+1;
     tx:=x+textwidth(zodis)+textwidth(def); startx:=x+textwidth(zodis);
     size:=imagesize(x,y,tx+8*(ilgis+1-length(def))+5,y+9+5);
     getmem(sp,size);
     getimage(x,y,tx+8*(ilgis+1-length(def))+5,y+9+5,sp^);
     SetFillStyle(1,0); Bar(x+5,y+5,tx+8*(ilgis+1-length(def))+5,y+9+5);
     SetFillStyle(1,bcol); Bar(x,y,tx+8*(ilgis+1-length(def)),y+9);


     SetColor(col);
     Outtextxy(x+1,y+1,zodis); Outtextxy(startx,y+1,def);
     Istr:=def; nr:=length(def);
     outtextxy(tx,ty,curs);
     repeat
       kl:=readkey;
       case kl of
           #8: if tx>startx then
                begin bar(tx,ty,tx+8,ty+8); tx:=tx-8; nr:=nr-1;
                      istr:=copy(istr,1,nr);
                      bar(tx,ty,tx+8,ty+8); outtextxy(tx,ty,curs); end;
           #13: InsertString:=IStr;
           #27: begin nr:=0; tx:=startx; IStr:='';
                      bar(tx,ty,tx+8*(ilgis+1),ty+8); outtextxy(tx,ty,curs);
                      end;
       else
      if nr<ilgis then
       begin
        Istr:=IStr+kl;
        bar(tx,ty,tx+8,ty+8); outtextxy(tx,ty,kl);
        tx:=tx+8;
        outtextxy(tx,ty,curs);
        nr:=nr+1;
       end;
       end;
     until (kl=#13);
     putimage(x,y,sp^,normalput);
     freemem(sp,size);
end;

function GetFromList;
var p:pointer;
    size,txtx,txty,x1,x2,wy,n,active,plot,aukst:integer;
    key:char;

procedure filllist(a,b:integer);
var e,yy:integer;
begin
       SetFillStyle(8,blue); Bar(0,0,plot,aukst);
       txty:=0; txtx:=6;
       for yy:=a to b do
       begin
        outtextxy(txtx,txty,listarray[yy]);
        txty:=txty+9;
       end;
       rectangle(1,wy*9-1,plot,wy*9+7);
end;
begin
     SetTextStyle(0,0,1); SetLineStyle(0,0,1); settextjustify(0,2);
     plot:=stulpeliu*9; aukst:=eiluciu*9;
     Size := ImageSize(0,0,plot+5,aukst+5+20); GetMem(P, Size);
     GetImage(x,y-10, x+plot+5,y+aukst+5+10, P^);
     SetFillStyle(1,0); Bar(x+5,y-5,x+plot+5,y+aukst+15);
     SetFillStyle(8,blue); Bar(x,y,x+plot,y+aukst);
     SetFillStyle(1,white); Bar(x,y-10,x+plot,y);
      Bar(x,y+aukst,x+plot,y+aukst+10);
     SetColor(0); outtextxy(x+5,y-8,' '+st);
     outtextxy(x+5,y+aukst+2,' '+'AlgisSoft');
     setviewport(x,y,x+plot+5,y+aukst+5,true);

     txtx:=6; txty:=0; active:=1; x1:=1;  wy:=0;
     if viso<eiluciu then x2:=viso
      else x2:=eiluciu;
    setcolor(green);
    filllist(x1,x2);
    rectangle(1,wy*9-1,plot,wy*9+7);
    setwritemode(xorput);
    repeat
      key:=readkey;
     if key=#0 then
     case readkey of
      #72: if (wy=0) and (active>1) then
           begin x1:=x1-1; x2:=x2-1; active:=active-1;
                 filllist(x1,x2);
            end
          else
            if wy>0 then
              begin active:=active-1;
                    rectangle(1,wy*9-1,plot,wy*9+7); wy:=wy-1;
                    rectangle(1,wy*9-1,plot,wy*9+7);
              end;
      #80: if (wy=eiluciu-1) and (active<viso) then
            begin x2:=x2+1; x1:=x1+1;  active:=active+1;
                  filllist(x1,x2);
            end
          else
            if (wy<eiluciu-1) and (wy<viso-1) then
              begin active:=active+1;
                    rectangle(1,wy*9-1,plot,wy*9+7); wy:=wy+1;
                    rectangle(1,wy*9-1,plot,wy*9+7);
              end;
      #71: begin  if viso<=eiluciu then x2:=viso else x2:=eiluciu; {home}
                  active:=1; wy:=0; x1:=1; filllist(1,x2);
                  end;
      #79: begin if viso<=eiluciu then
                   begin  active:=viso; x1:=1; x2:=viso; wy:=viso-1;
                          filllist(x1,x2);
                   end
                   else begin
                           active:=viso; x1:=viso-eiluciu+1;
                           x2:=viso; wy:=eiluciu-1;
                           filllist(x1,x2);
                        end;
           end;
     end;
    until (key=#13) or (key=#27);
    setwritemode(normalput);
    SetViewPort(0,0,GetMaxX,GetMaxY,True);
    PutImage(x,y-10, P^,normalput); FreeMem(P,size);
    if key=#27 then GetFromList:=0
     else GetFromList:=active;
end;

function GetFileName;
var dirinfo,dirinfo2:searchrec;
    dirnr:integer;
    issirinktas:integer;
    xt:string[3];
begin
   repeat
       dirnr:=1;
       FindFirst('*',directory, DirInfo);
       while DosError = 0 do
       begin
        if (dirinfo.size=0) and (dirinfo.name<>'.') then
        begin
          listarray[dirnr]:=DirInfo.Name;
          dirnr:=dirnr+1;
        end;
         FindNext(DirInfo);
       end;
      FindFirst('*.'+ext,directory, DirInfo2);
      while DosError = 0 do
      begin
        listarray[dirnr]:=DirInfo2.Name;
        dirnr:=dirnr+1;
        FindNext(DirInfo2);
      end;
      issirinktas:=GetFromList(20,10,20,20,dirnr-1,'Pasirinkite fail–!');
      if issirinktas<>0 then
      begin
        xt:=copy(listarray[issirinktas],length(listarray[issirinktas])-2,3);
        if xt=ext then
          begin
             GetFilename:=ListArray[issirinktas];
             issirinktas:=0;
           end
          else
           begin
            chdir(listarray[issirinktas]);
           end;
       end else GetFileName:='';
   until issirinktas=0;
   chdir('\ATEST');
end;

function IntToStr;
{ Convert any integer type to a string }
var
  S: string[11];
begin
  Str(I, S);
  IntToStr := S;
end;

END.