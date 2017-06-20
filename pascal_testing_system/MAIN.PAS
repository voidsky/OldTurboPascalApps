unit Main;
INTERFACE
uses graph;
Type  TKlausimas=record
                   klausimas:string[80];
                   atsakymas:array[1..5] of string[50];
                   teisingas:byte;
                 end;
      TTema=record
                pavadinimas:string[20];
                klausimai:array[1..100] of TKlausimas;
                klausimu:integer;
               end;
      TReport=record
                name:string[30];
                klausimas:string[80];
                atsakymas:string[50];
                m,men,d,v,min:word;
                viso,teisingu:integer;
              end;
var
    pal:palettetype;
    TestFile:string;
procedure HardWare;
procedure Koduoti(filename:string);
procedure Statistika;
PROCEDURE  Redaguoti;
procedure Testuoti(fnme:string);
Procedure DeskTop;

IMPLEMENTATION
uses dos,simpgrfx,crt;

procedure HardWare;
begin
    GetDefaultPalette(pal);
    AllBlack;
    OpenEga(1,0,640,97,'new1.ega',0);
    OpenEga(1,96,639,97,'new2.ega',0);
    OpenEga(1,96+96,639,97,'new3.ega',0);
    OpenEga(1,96+96+96,639,97,'new4.ega',0);
    OpenEga(1,96+96+2*96,639,97,'new5.ega',0);
    SetAllPalette(pal);
{    RestorePal;}
end;

procedure Koduoti;
var ff1:file of byte;
    b:byte;
    x:integer;
begin
     assign(ff1,filename);
     reset(ff1);
     while not eof(ff1) do
     begin
        read(ff1,b);
        seek(ff1,filepos(ff1)-1);
        b:=b or b;

        write(ff1,b);
     end;
     close(ff1);
end;

procedure Statistika;
var repfn:string[12];
    repf:file of TReport;
    rep:TReport;
    ry:integer;
begin
     Hardware;
     repfn:=GetFileName('RPT');
     if repfn<>'' then
     begin
     Koduoti(repfn);
     assign(repf,repfn);
     reset(repf);
     read(repf,rep);
     settextstyle(0,0,2); setcolor(yellow);
     settextjustify(1,1);
     with rep do
     begin
     outtextxy(Succ(GetMaxX) div 2,20,name);
     setcolor(green);
     outtextxy(Succ(GetMaxX) div 2,40,inttostr(m)+'m. '+inttostr(men)+'m”n. '+inttostr(d)+'d.');
     outtextxy(Succ(GetMaxX) div 2,60,inttostr(v)+'val. '+inttostr(min)+'min.');

     settextstyle(0,0,1); setcolor(red);
     settextjustify(0,2);
     ry:=80;
     while not eof(repf) do
     begin
         outtextxy(10,ry,klausimas+'  Atsakyta: '+atsakymas+'  ');
         ry:=ry+10;
         if ry>getmaxy then
         begin readkey; hardware; ry:=1; end;
         read(repf,rep);
     end;
     outtextxy(10,ry,klausimas+'  Atsakyta: '+atsakymas+'  ');
     settextstyle(0,0,2); setcolor(yellow);
     settextjustify(1,1);
     outtextxy(Succ(GetMaxX) div 2,ry+20,'Viso '+inttostr(viso));
     outtextxy(Succ(GetMaxX) div 2,ry+40,'Teisingu '+inttostr(teisingu));

    end;
     close(repf);
     Koduoti(repfn);
     readkey;
     end;
end;

{*********************************}
PROCEDURE  Redaguoti;
var n,code,x:integer;
    temaf:file of ttema;
    tema:ttema;
    kokiatema:string[20];
    filename:string[12];
    nr:integer;

function GautiTema(filename:string):string;
var i,j:integer;
    f:file of ttema;
begin
     assign(f,filename);
     reset(f);
     i:=1;
     while not eof(f) do
     begin
      read(f,tema);
      listarray[i]:=tema.pavadinimas;
      i:=i+1;
     end;
     j:=getfromlist(100,100,30,20,i-1,'<< Pasirinkite tem– >>');
     GautiTema:=listarray[j];
     seek(f,1);
     close(f);
end;

procedure NaujasKlausimas;
var ats:integer;
begin
           kokiatema:=GautiTema(testfile);
           {insertstring(5,100,70,red,white,'Tema?: ','');}
           read(temaf,tema);
           while (tema.pavadinimas<>kokiatema) and (not eof(temaf)) do
            read(temaf,tema);
           if tema.pavadinimas=kokiatema then
           begin
           with tema do
           begin
              klausimu:=klausimu+1;
              klausimai[klausimu].klausimas:=
                   insertstring(3,100,65,red,white,'Klausimas: ','');
          for ats:=1 to 5 do
          begin
            klausimai[klausimu].atsakymas[ats]:=
            insertstring(1,100,50,red,white,'Atsakymas '+inttostr(ats)+' ','');
          end;
          val(insertstring(300,100,5,red,white,'Teisingas? ',''),
             klausimai[klausimu].teisingas,code);
          seek(temaf,filepos(temaf)-1);
          write(temaf,tema);
          end;

          end else
                begin
                  settextstyle(0,0,3);
                  settextjustify(1,1); setcolor(13);
                  OutTextXY( Succ(GetMaxX) div 2,100,'Tokios temos n”ra?!');
                end;
end;

procedure NaujaTema(kokiatema:string);
var kl,ats1:integer;
begin
          if filesize(temaf)>0 then
          begin
           seek(temaf,0);
           read(temaf,tema);
           while (tema.pavadinimas<>kokiatema) and (not eof(temaf)) do
            read(temaf,tema);
          end else tema.pavadinimas:='**';
           if tema.pavadinimas<>kokiatema then
           begin
           with tema do
           begin
              pavadinimas:=kokiatema;
              val(insertstring(100,100,5,red,white,'Kiek klausim÷ ',''),
                klausimu,code);
            for kl:=1 to klausimu do
            begin
              klausimai[kl].klausimas:=
               insertstring(5,100,65,red,white,'Klausimas:','');

              for ats1:=1 to 5 do
              begin
               klausimai[kl].atsakymas[ats1]:=
               insertstring(1,100,65,red,white,'Atsakymas '+inttostr(ats1)+':','');
              end;
              val(insertstring(100,100,5,red,white,'Teisingas? ',''),
              klausimai[kl].teisingas,code);
             end;
              seek(temaf,filesize(temaf));
              write(temaf,tema);
          end;

          end else
                begin
                  settextstyle(0,0,3);
                  settextjustify(1,1); setcolor(13);
                  OutTextXY( Succ(GetMaxX) div 2,100,'Tokia tema yra !');
                end;
end;

procedure PanaikintiTema(kokiatema:string);
begin
               read(temaf,tema);
               while (tema.pavadinimas<>kokiatema) and (not eof(temaf)) do
               read(temaf,tema);
               if tema.pavadinimas=kokiatema then
               begin
                  nr:=filepos(temaf)-1;
                  seek(temaf,filesize(temaf)-1);
                  read(temaf,tema);
                  seek(temaf,nr); write(temaf,tema);
                  seek(temaf,filesize(temaf)-1);
                  truncate(temaf);
               end
               else
               begin
                  settextstyle(0,0,3);
                  settextjustify(1,1); setcolor(13);
                  OutTextXY( Succ(GetMaxX) div 2,100,'Tokios temos n”ra !');
                end;

end;

procedure PanaikintiKlausima(kokiatema:string);
var a,j,i:integer;
begin
     read(temaf,tema);
     while (tema.pavadinimas<>kokiatema) and (not eof(temaf)) do
      read(temaf,tema);
     if tema.pavadinimas=kokiatema then
     begin
      with tema do
      begin
       for a:=1 to klausimu do listarray[a]:=klausimai[a].klausimas;
       i:=getfromlist(10,100,50,10,klausimu,'<< Pasirinkite klausim– >>');
       if i<>0 then
       begin
        klausimai[i].klausimas:=klausimai[klausimu-1].klausimas;
        klausimu:=klausimu-1;
        seek(temaf,filepos(temaf)-1);
        write(temaf,tema);
       end;
      end;
     end;
end;

procedure NaujasTestas;
var kiektemu,a:integer;
begin
     filename:=
     insertstring(5,100,12,red,white,'Failo pavadunimas [pvz.: test.KLS]: ','');
     assign(temaf,filename);
     rewrite(temaf);
     val(insertstring(100,100,3,red,white,'Kiek bus tem÷? ',''),
                kiektemu,code);
     for a:=1 to kiektemu do
     begin
      NaujaTema(insertstring(5,100,20,red,white,'Tema?: ',''));
     end;
     close(temaf);
end;

procedure PasirinktiTesta;
begin
     testfile:=getfilename('KLS');
end;

begin
     Hardware;
     ListArray[1]:='Naujas klausimas';
     ListArray[2]:='Nauja tema';
     ListArray[3]:='Panaikinti klausim–';
     ListArray[4]:='Panaikinti tem–';
     listArray[5]:='Naujas TESTAS';
     listArray[6]:='PASIRINKTI TESTµ TESTAVIMUI';
     n:=getfromlist(100,100,30,6,6,'<< K– norite daryti? >>');
     if (n<>0) and (n<>5) and (n<>6) then
     begin
       filename:=getfilename('KLS');
       if filename<>'' then
        begin
         assign(temaf,filename); reset(temaf);
         case n of
           1: NaujasKlausimas;
           2: NaujaTema(insertstring(5,100,20,red,white,'Tema?: ',''));
           4: PanaikintiTema(GautiTema(testfile));
           3: PanaikintiKlausima(GautiTema(testfile));
          end;
         close(temaf);
        end;
     end else if n=5 then NaujasTestas else if n=6 then PasirinktiTesta;
END; {PROCEDUROS REDAGUOTI}       {*****************************}

procedure Testuoti;
var  f:file of TTema;
     freport:file of TReport; report:Treport;
     met,men,d,sd,v,min,s,ms:word;
     t:TTEma;
     name:string[30];
     kl1:string;
     numeris,x,atsy,ats,ln:integer;
     kl:char;
     viso,teisingu:integer;
procedure Teisingai;
begin
     setfillstyle(1,green); bar(50,50,590,150); settextstyle(0,0,3);
     settextjustify(1,1); setcolor(13);
     OutTextXY( Succ(GetMaxX) div 2,100,'Teisingai!');
     delay(50);
     teisingu:=teisingu+1;
end;

procedure Blogai;
begin
     setfillstyle(1,red); bar(50,50,590,150); settextstyle(0,0,3);
     settextjustify(1,1); setcolor(13);
     OutTextXY( Succ(GetMaxX) div 2,100,'Atsakymas blogas!');
     delay(50);
end;


begin
     HardWare;
     name:=InsertString(130,100,30,red,white,'Vardas ir pavard”: ','');
     while name='' do
       name:=InsertString(130,100,30,red,white,'Vardas ir pavard”: ','');

     assign(freport,'REPORT.RPT');  rewrite(freport);
     report.name:=name;
     gettime(v,min,s,ms); getdate(met,men,d,sd);
     report.m:=met; report.men:=men; report.d:=d;
     report.v:=v; report.min:=min;

     assign(f,fnme);
     reset(f); seek(f,0);
     viso:=0; teisingu:=0;
     while not eof(f) do
     begin
      read(f,t);
      setfillstyle(1,0); bar(50,50,590,150);
      settextjustify(1,1); settextstyle(0,0,3);
      OutTextXY( Succ(GetMaxX) div 2,100,t.pavadinimas);

      settextstyle(0,0,2);
      numeris:=random(t.klausimu)+1;
      with t.klausimai[numeris] do
      begin
       report.klausimas:=klausimas;
       if textwidth(klausimas)>640 then
       begin
        x:=length(klausimas) div 2-1;
        repeat
         x:=x+1;
        until (copy(klausimas,x,1)=' ') or (x>=length(klausimas));;
        if copy(klausimas,x,1)<>' ' then
        begin
         OutTextXY( Succ(GetMaxX) div 2,200,copy(klausimas,1,length(klausimas) div 2));
         OutTextXY( Succ(GetMaxX) div 2,220,
            copy(klausimas,length(klausimas) div 2+1,length(klausimas)));
        end else
        begin
          OutTextXY( Succ(GetMaxX) div 2,200,copy(klausimas,1,x));
          OutTextXY( Succ(GetMaxX) div 2,220,
           copy(klausimas,x+1,length(klausimas)));
        end;
       end else OutTextXY( Succ(GetMaxX) div 2,200,klausimas);
       x:=1;  atsy:=0; ln:=0;
       setfillstyle(1,blue); bar(5,300,635,450); settextstyle(0,0,2);
       settextjustify(1,1); setcolor(yellow);
       for x:=1 to 5 do
           if atsakymas[x]<>'' then
           begin
            outtextxy( Succ(GetMaxX) div 2,320+atsy,atsakymas[x]);
            atsy:=atsy+20; ln:=ln+1;
           end;
       ln:=ln-1;

       atsy:=0; ats:=1;
       settextjustify(0,2);
       setcolor(green); rectangle(5,310+atsy,635,330+atsy);
       repeat
       kl:=readkey;
       if kl=#0 then
       case readkey of
        #72: if ats>1 then begin ats:=ats-1;
              setcolor(blue); rectangle(5,310+atsy,635,330+atsy);
              atsy:=atsy-20; setcolor(green); rectangle(5,310+atsy,635,330+atsy);
             end;
        #80: if ats<(ln+1) then begin ats:=ats+1;
              setcolor(blue); rectangle(5,310+atsy,635,330+atsy);
              atsy:=atsy+20; setcolor(green); rectangle(5,310+atsy,635,330+atsy);
             end;
        end;
       until kl=#13;

      report.atsakymas:=atsakymas[ats];
      viso:=viso+1;
      if ats=teisingas then teisingai
       else blogai;

       OpenEga(1,96+96,639,97,'new3.ega',0);
     end;
      report.viso:=viso; report.teisingu:=teisingu;
      write(freport,report);
   end;
     close(f);
      close(freport);
end;    {proceduros testuoti} {**********************************}

Procedure DeskTop;
var kx:integer;
    choice:byte;
    kl:char;
    Exit:boolean;

procedure MainButtons;
begin
    setfillstyle(1,0);
    bar(15,15,15+128,15+125); OpenEga(10,10,128,125,'godown16.ega',0);
    bar(485,15,485+128,15+125); OpenEga(480,10,128,125,'drinke16.ega',0);
    bar(255,335,255+128,335+125); OpenEga(250,330,128,125,'stink.ega',0);
    bar(255,15,255+128,15+125); OpenEga(250,10,128,125,'begin3.ega',0);
end;
procedure ClearChoice;
begin
     setcolor(blue);
     rectangle(250,10,250+128,135);
     rectangle(250,330,250+128,330+125);
     rectangle(10,10,138,135);
     rectangle(480,10,480+128,135);
end;

begin
    exit:=false;
   repeat
    HardWare;
    OpenEga(150,130,300,200,'asm.ega',2);
    MainButtons;
    choice:=1;
    setlinestyle(0,0,3); clearchoice;
    setcolor(green); rectangle(250,10,250+128,135);
    repeat
    kl:=readkey;
    if kl=#0 then
    case readkey of
     #72: begin choice:=1; ClearChoice;
                setcolor(green); rectangle(250,10,250+128,135); end;
     #80: begin choice:=3; ClearChoice;
                setcolor(green); rectangle(250,330,250+128,330+125); end;
     #75: begin choice:=4; ClearChoice;
                setcolor(green); rectangle(10,10,138,135); end;
     #77: begin choice:=2; ClearChoice;
                     setcolor(green); rectangle(480,10,480+128,135); end;
    end;
    until kl=#13;
    case choice of
     1: begin Testuoti(testfile); Koduoti('REPORT.RPT'); end;
     2: Redaguoti;
     3: Exit:=true;
     4: Statistika;
    end;
   until Exit;
end;    {proceduros DeskTop}

Begin
    testfile:='test1.kls';

END.