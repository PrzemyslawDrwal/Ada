with Ada.Text_IO, Ada.Calendar;
use Ada.Text_IO, Ada.Calendar;

with NT_Console;              use NT_Console;
with Ada.Strings.Fixed;       use Ada.Strings.Fixed;
with Ada.Characters.Handling; use Ada.Characters.Handling;

with Ada.Calendar.Formatting;
use Ada.Calendar.Formatting;

with Ada.Numerics.Float_Random;
use Ada.Numerics.Float_Random;


with Ada.Directories; use Ada.Directories;



package body Obsluga_F is 
   --type Style is (Lager, Ale, Hefeweizen, Abbaye, Kveik);
   Zn: Character := ' ';

   procedure Fermentacja (Nazwa_Piwa : in String; Styl : in Style; Czas_Fermentacji : in Duration; Temp_Otoczenia : in Integer; Temp_Min_O : in Float; Temp_Max_O : in Float) is
      Aktualna_Temperatura : Float := 18.0;
      Chlodzenie_Aktywne : Boolean := False;
      Aktualna_Temperatura_Otoczenia : Float;
      Koniec_Fermentacja : Boolean := False with Atomic;
      Fermentacja_Zakonczona : Boolean := False with Atomic;
      Bledy : String := "Brak bledow                                ";
      ---------------------- exceptions --------------------------  
      Blad_Temperatury_Fermentacji: exception;
	  
      ------------------------------------------------------------
	  
      ------------------------------------------------------
      ------------Pomiar temperatury fermentacji -----------	
      protected Bufor_Pomiar_Temperatury_Fermentor is
         entry Wstaw(T : in Float);
         entry Pobierz(T : out Float);
      private 
         Temp : Float;
         Pusty : Boolean := True;
      end Bufor_Pomiar_Temperatury_Fermentor;
	
      protected body Bufor_Pomiar_Temperatury_Fermentor is
         entry Wstaw(T : in Float)
           when Pusty is
         begin
            Temp := T;
            Pusty := False;
         end Wstaw;
		
         entry Pobierz (T : out Float)
           when not Pusty is
         begin	
            T := Temp;
            Pusty := True;
         end Pobierz;
      end Bufor_Pomiar_Temperatury_Fermentor;	
	
      task Termometr_Fermentor;
      task Czytaj_Termometr_Fermentor;
	

      task body Termometr_Fermentor is
         Temperatura : Float := 18.0;
         Delta_Temp : Float := 0.01;
      begin
         loop
            if Chlodzenie_Aktywne = True then
               Delta_Temp := -0.01;
            else
               Delta_Temp := 0.1;
            end if;
            Temperatura := Temperatura + Delta_Temp;
            Bufor_Pomiar_Temperatury_Fermentor.Wstaw(Temperatura);
            if Temperatura < 0.0 then
               raise Blad_Temperatury_Fermentacji;
            end if;
            exit when Koniec_Fermentacja or Fermentacja_Zakonczona;
         end loop;
      exception
         when Blad_Temperatury_Fermentacji =>
            Fermentacja_Zakonczona := True;
            Bledy := "Temperatura fermentacji nizsza od 0 "; 
      end Termometr_Fermentor;
	
      task body Czytaj_Termometr_Fermentor is
         Okres_Odczytu : Duration := 2.5;
         Aktualny_Czas_Odczyt_Temperatury : Ada.Calendar.Time;
         Temp_Tymczasowa : Float := 19.0;
      begin
         Aktualny_Czas_Odczyt_Temperatury := Ada.Calendar.Clock;
         loop
            delay until Aktualny_Czas_Odczyt_Temperatury;
            if Chlodzenie_Aktywne = True then
               Okres_Odczytu := 0.5;
            else
               Okres_Odczytu := 2.5;
            end if;			
            Aktualny_Czas_Odczyt_Temperatury := Aktualny_Czas_Odczyt_Temperatury + Okres_Odczytu;	
            Bufor_Pomiar_Temperatury_Fermentor.Pobierz(Temp_Tymczasowa);
            Aktualna_Temperatura := Temp_Tymczasowa;
            --Put_Line(Aktualna_Temperatura'Img);
            exit when Koniec_Fermentacja or Fermentacja_Zakonczona;
         end loop;
      end Czytaj_Termometr_Fermentor;
	
      ------------------------------------------------------
      ------------Pomiar temperatury otoczenia -------------

      protected Bufor_Pomiar_Temperatury_Otoczenie is
         entry Wstaw(T : in Float);
         entry Pobierz(T : out Float);
      private 
         Temp : Float;
         Pusty : Boolean := True;
      end Bufor_Pomiar_Temperatury_Otoczenie;
	
      protected body Bufor_Pomiar_Temperatury_Otoczenie is
         entry Wstaw(T : in Float)
           when Pusty is
         begin
            Temp := T;
            Pusty := False;
         end Wstaw;
		
         entry Pobierz (T : out Float)
           when not Pusty is
         begin	
            T := Temp;
            Pusty := True;
         end Pobierz;
      end Bufor_Pomiar_Temperatury_Otoczenie;
	
      task Termometr_Otoczenie;
      task Czytaj_Termometr_Otoczenie;	
      task body Termometr_Otoczenie is
         Temperatura : Float := Float(Temp_Otoczenia);
         Temp_Los : Float := 1.0;
         Gen: Generator; 		
      begin
         Reset(Gen);
         loop	
            Temp_Los := Random(Gen);
			Temp_Los := 2.0 * Temp_Los;
            Temperatura := Temperatura + Temp_Los;
            Bufor_Pomiar_Temperatury_Otoczenie.Wstaw(Temperatura);
            exit when Koniec_Fermentacja or Fermentacja_Zakonczona;
         end loop;
      end Termometr_Otoczenie;	
	
      task body Czytaj_Termometr_Otoczenie is
         Okres_Odczytu : Duration := 25.0;
         Aktualny_Czas_Odczyt_Temperatury : Ada.Calendar.Time;
         Temp_Tymczasowa : Float;
      begin
         Aktualny_Czas_Odczyt_Temperatury := Ada.Calendar.Clock;
         loop
            delay until Aktualny_Czas_Odczyt_Temperatury;		
            Aktualny_Czas_Odczyt_Temperatury := Aktualny_Czas_Odczyt_Temperatury + Okres_Odczytu;	
            Bufor_Pomiar_Temperatury_Otoczenie.Pobierz(Temp_Tymczasowa);
            Aktualna_Temperatura_Otoczenia := Temp_Tymczasowa;
            --Put_Line(Temp_Tymczasowa'Img);
            exit when Koniec_Fermentacja or Fermentacja_Zakonczona;
         end loop;
      end Czytaj_Termometr_Otoczenie;
	
      ------------------------------------------------------
      ------------------ Modul chlodzenia ------------------	

      task Modul_Chlodzenia is
         entry Aktywuj_Chlodzenie;
         entry Wylacz_Chlodzenie;
      end Modul_Chlodzenia;

      task body Modul_Chlodzenia is
      begin
         loop
            select 
               accept Aktywuj_Chlodzenie do
                  Chlodzenie_Aktywne := True;
               end Aktywuj_Chlodzenie;
            or
               accept Wylacz_Chlodzenie do
                  Chlodzenie_Aktywne := False;
               end Wylacz_Chlodzenie;
            else
               delay 1.0;
            end select;
            exit when Koniec_Fermentacja or Fermentacja_Zakonczona;
         end loop;
      end Modul_Chlodzenia; 
	
      ------------------------------------------------------
      ------------------ Modul sterowania ------------------	
      Temp_Otoczenia_Ok : Boolean := True;
      Temp_Min : Float := 18.0;
      Temp_Max : Float := 22.0;
      ------------------------------------------------------	

      task Modul_Sterowania;

      task body Modul_Sterowania is
	  
      begin
         case Styl is 
         when Lager => 
            Temp_Min := 8.0;
            Temp_Max := 12.0;
         when Ale => 
            Temp_Min := 18.0;
            Temp_Max := 22.0;
         when Hefeweizen => 
            Temp_Min := 18.0;
            Temp_Max := 24.0;
         when Abbaye => 
            Temp_Min := 18.0;
            Temp_Max := 25.0;
         when Kveik => 
            Temp_Min := 20.0;
            Temp_Max := 40.0;			
         when others =>
            Temp_Min := 18.0;
            Temp_Max := 22.0;
         end case;
		
         loop
            if(Aktualna_Temperatura <= Temp_Min or  Aktualna_Temperatura >= (Temp_Max+Temp_Min)/2.0) then
               Modul_Chlodzenia.Aktywuj_Chlodzenie;
               --Put_Line("Chlodzenie aktywne" & Aktualna_Temperatura'Img);
            else 	
               Modul_Chlodzenia.Wylacz_Chlodzenie;
               --Put_Line("Chlodzenie nieaktywne" & Aktualna_Temperatura'Img);
            end if;
		
            if((Aktualna_Temperatura_Otoczenia < Temp_Max_O ) and Aktualna_Temperatura_Otoczenia > Temp_Min_O) then
               Temp_Otoczenia_Ok := True;
               --Put_Line("Temp otoczenia ok" & Aktualna_Temperatura_Otoczenia'Img);
            else 
               Temp_Otoczenia_Ok := False;
               --Put_Line("Temp otoczenia nie ok" & Aktualna_Temperatura_Otoczenia'Img);
            end if;
            exit when Koniec_Fermentacja or Fermentacja_Zakonczona;
         end loop;
      end Modul_Sterowania;
      ------------------------------------------------------
      ------------------- Zapis do pliku -------------------	

      task Zapis_Do_Pliku;
      task body Zapis_Do_Pliku is
         P2 : File_Type;
         Nazwa : String := "Test 0.txt";
         Okres_Zapisu : Duration := 10.0;
         Aktualny_Czas_Zapisu : Ada.Calendar.Time;   
      begin
         for I in Positive range 1 .. 10 loop
            if (Exists(Nazwa)) then
               Nazwa := Overwrite(Nazwa, 5, Positive'Image(I) & ".txt");
            else
               Create(P2, Out_File, Nazwa); 
               exit;
            end if;
         end loop;
         Put_Line(P2, "Nazwa Piwa: " & Nazwa_Piwa);
         Put_Line(P2, "Styl Piwa: " & Styl'Img);
         Aktualny_Czas_Zapisu := Ada.Calendar.Clock;
         loop 
            delay until Aktualny_Czas_Zapisu;
            Aktualny_Czas_Zapisu := Aktualny_Czas_Zapisu + Okres_Zapisu;
            Put_Line(P2, Image(Aktualny_Czas_Zapisu) & " Temperatura: " & Aktualna_Temperatura'Img);
            exit when Koniec_Fermentacja or Fermentacja_Zakonczona;
         end loop;
      end Zapis_Do_Pliku;
		
 
      ------------------------------------------------------
      -------------------- Pomiar czasu --------------------	

      task Pomiar_Czasu;

      task body Pomiar_Czasu is
         Aktualny_Czas : Ada.Calendar.Time;
         --Czas_Fermentacji : Duration := 1000.0;
         Czas_Startowy : Ada.Calendar.Time;
	
      begin 
         Czas_Startowy := Ada.Calendar.Clock + Czas_Fermentacji;
         loop
            Aktualny_Czas := Ada.Calendar.Clock;
            if(Aktualny_Czas > Czas_Startowy) then
               Fermentacja_Zakonczona := True;
            else
               Fermentacja_Zakonczona := False;
            end if;
            exit when Koniec_Fermentacja or Fermentacja_Zakonczona;
         end loop;
      end Pomiar_Czasu;

      ------------------------------------------------------
      ------------------------ Menu ------------------------
      
      task Display_Menu;
      task body Display_Menu is

      begin
         Clear_Screen (Cyan);
         Set_Foreground (Blue);
         Set_Background (Yellow);
         Goto_XY (20, 0);
         Put_Line("* KONTROLA FERMENTACJI PIWA - FERMENTACJA * ");
         Set_Background (Cyan);
         Goto_XY (0, 2);
         Put_Line("Styl Piwa: " & Styl'Img);
         Goto_XY (0, 4);
         Put_Line("Nazwa Piwa: " & Nazwa_Piwa);
         Goto_XY (0, 6);
         Put("Zadany Zakres Temperatury " & Temp_Min'Img & " -" & Temp_Max'Img);
         Goto_XY (0, 8);
         Put("Podana Temperatura Otoczenia " & Temp_Otoczenia'Img);
         Set_Foreground (Yellow);
         Goto_XY (17, 18);
         Put("Please press S to exit and go back to start menu");
         loop
            if(Fermentacja_Zakonczona) then
               Clear_Screen (Cyan);
               Set_Background (Cyan);
               Set_Foreground (Yellow);
               Goto_XY (12, 10);
               Put("Fermentacja skonczona nacisnij S aby wrocic do menu glownego");
            else
               Set_Background (Cyan);
               Set_Foreground (Blue);
               Goto_XY (0, 10);
               Put("Aktualna Temperatura " & Aktualna_Temperatura'Img);
               Goto_XY (0, 12);
               Put("Chlodzenie Aktywne? " & Chlodzenie_Aktywne'Img);
               Goto_XY (0, 14);
               Put("Aktualna Temperatura Otoczenia " & Aktualna_Temperatura_Otoczenia'Img);
            end if;
            delay 0.05;
            exit when Koniec_Fermentacja;
         end loop; 
         Set_Foreground (Gray);
         Clear_Screen;    
      end Display_Menu;
	
   begin 
      loop
         Get_Immediate(Zn);
         exit when Zn in 's'|'S';
      end loop;
      Koniec_Fermentacja := True;
   end Fermentacja;
	
end Obsluga_F;	
