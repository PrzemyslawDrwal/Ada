with Ada.Text_IO, Ada.Calendar;
use Ada.Text_IO, Ada.Calendar;
with NT_Console;              use NT_Console;
with Ada.Strings.Fixed;       use Ada.Strings.Fixed;
with Ada.Characters.Handling; use Ada.Characters.Handling;
with Ada.Float_Text_IO;
use Ada.Float_Text_IO;

package body Obsluga_Z is 

   procedure Zacieranie(Czas_Faza_1 : in Duration; Temp_Faza_1 : in Float; Czas_Faza_2 : in Duration; Temp_Faza_2 : in Float; Czas_Faza_3 : in Duration; Temp_Faza_3 : in Float; Czas_Faza_4 : in Duration; Temp_Faza_4 : in Float )  is
      Podgrzewanie_Aktywne : Boolean := False;
      Aktualna_Temperatura : Float := 30.0;
      Poprzednia_Temperatura : Float := 30.0;
      Faza : Integer := 1;
      Koniec_Zacieranie : Boolean := False with Atomic;
      Koniec_fazy_4 : Boolean := False with Atomic;
      Zn: Character := ' ';
      ---------------------- exceptions --------------------------  
      Blad_Temperatury_Zacierania_1: exception;
      Blad_Temperatury_Zacierania_2: exception;

      protected Bufor_Temperatury is
         entry Wstaw(T : in Float);
         entry Pobierz(T : out Float);
      private 
         Temp : Float;
         Pusty : Boolean := True;
      end Bufor_Temperatury;
	
      protected body Bufor_Temperatury is
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
      end Bufor_Temperatury;	

      task Modul_Podgrzewania is
         entry Aktywuj_Podgrzewanie;
         entry Wylacz_Podgrzewanie;
      end Modul_Podgrzewania;

      task body Modul_Podgrzewania is
         Temperatura_Tymczasowa : Float := 30.0;
      begin
         loop
            select 
               accept Aktywuj_Podgrzewanie do
                  Podgrzewanie_Aktywne := True;
                  Poprzednia_Temperatura := Temperatura_Tymczasowa;
                  Temperatura_Tymczasowa := Temperatura_Tymczasowa + 1.0;
                  Bufor_Temperatury.Wstaw(Temperatura_Tymczasowa);
                  delay 1.0;
               end Aktywuj_Podgrzewanie;
            or
               accept Wylacz_Podgrzewanie do
                  Bufor_Temperatury.Wstaw(Temperatura_Tymczasowa);
                  delay 1.0;
               end Wylacz_Podgrzewanie;
            else
               delay 1.0;
               Bufor_Temperatury.Wstaw(Temperatura_Tymczasowa);
			   
            end select;
            exit when Koniec_Zacieranie or Koniec_fazy_4;
         end loop;
      end Modul_Podgrzewania; 
	
      task Termometr;

      task body Termometr is
         Okres_Odczytu : Duration := 1.0;
         Aktualny_Czas_Odczyt_Temperatury : Ada.Calendar.Time;
         Temp_Tymczasowa : Float;
      begin
         Aktualny_Czas_Odczyt_Temperatury := Ada.Calendar.Clock;
         loop
            if Aktualna_Temperatura > 80.0 then
               raise Blad_Temperatury_Zacierania_1;
            end if;
            if Aktualna_Temperatura < 30.0 then
               raise Blad_Temperatury_Zacierania_2;
            end if;
            delay until Aktualny_Czas_Odczyt_Temperatury;
            Aktualny_Czas_Odczyt_Temperatury := Aktualny_Czas_Odczyt_Temperatury + Okres_Odczytu;	
            Bufor_Temperatury.Pobierz(Temp_Tymczasowa);
            Aktualna_Temperatura := Temp_Tymczasowa;
            exit when Koniec_Zacieranie or Koniec_fazy_4;
         end loop;
      exception 
         when Blad_Temperatury_Zacierania_1 =>             
			Goto_XY (0, 16);
            Put("Temperatura zacierania za wysoka");	 
         when Blad_Temperatury_Zacierania_2 =>
		 	Goto_XY (0, 16);
            Put("Temperatura zacierania za niska");	 
      end Termometr;
	
	
      task Zacieranie;

      task body Zacieranie is
         Aktualny_Czas : Ada.Calendar.Time;
      begin
         loop 
            case Faza is
            when 1 =>
               Aktualny_Czas := Ada.Calendar.Clock;
               if(Aktualna_Temperatura > Temp_Faza_1) then
                  Aktualny_Czas := Aktualny_Czas + Czas_Faza_1;
                  delay until Aktualny_Czas;
                  Modul_Podgrzewania.Wylacz_Podgrzewanie;
                  Faza := 2;
               else 
                  Modul_Podgrzewania.Aktywuj_Podgrzewanie;
               end if;
            when 2 =>
               Aktualny_Czas := Ada.Calendar.Clock;
               if(Aktualna_Temperatura > Temp_Faza_2) then
                  Aktualny_Czas := Aktualny_Czas + Czas_Faza_2;
                  delay until Aktualny_Czas;
                  Modul_Podgrzewania.Wylacz_Podgrzewanie;
                  Faza := 3;
               else 
                  Modul_Podgrzewania.Aktywuj_Podgrzewanie;
               end if;						
            when 3 =>
               Aktualny_Czas := Ada.Calendar.Clock;
               if(Aktualna_Temperatura > Temp_Faza_4) then
                  Aktualny_Czas := Aktualny_Czas + Czas_Faza_3;
                  delay until Aktualny_Czas;
                  Modul_Podgrzewania.Wylacz_Podgrzewanie;
                  Faza := 4;
               else 
                  Modul_Podgrzewania.Aktywuj_Podgrzewanie;
               end if;
            when 4 =>
               Aktualny_Czas := Ada.Calendar.Clock;
               if(Aktualna_Temperatura > Temp_Faza_4) then
                  Aktualny_Czas := Aktualny_Czas + Czas_Faza_4;
                  delay until Aktualny_Czas;
                  Modul_Podgrzewania.Wylacz_Podgrzewanie;
                  Faza := 1;
                  Koniec_fazy_4 := True;
                  exit;
               else 
                  Modul_Podgrzewania.Aktywuj_Podgrzewanie;
               end if;
            when others => Modul_Podgrzewania.Wylacz_Podgrzewanie;
            end case;
            exit when Koniec_Zacieranie or Koniec_fazy_4;
         end loop;
      end Zacieranie;
      
      task Display_Menu;
      task body Display_Menu is

      begin
         Clear_Screen (Cyan);
         Set_Foreground (Blue);
         Set_Background (Yellow);
         Goto_XY (20, 0);
         Put_Line("* KONTROLA FERMENTACJI PIWA - ZACIERANIE *");
         Set_Background (Cyan);
         Goto_XY (0, 2);
         --Put_Line("Temp Faza 1: " & Temp_Faza_1'Img);
		 Put("Temp Faza 1: ");
		 Put(Temp_Faza_1,2,4,0);
         Goto_XY (0, 4);
         --Put_Line("Temp Faza 2: " & Temp_Faza_2'Img);
		 Put("Temp Faza 2: ");
		 Put(Temp_Faza_2,2,4,0);
         Goto_XY (0, 6);
         --Put_Line("Temp Faza 3: " & Temp_Faza_3'Img);
		 Put("Temp Faza 3: ");
		 Put(Temp_Faza_3,2,4,0);
         Goto_XY (0, 8);
         --Put_Line("Temp Faza 4: " & Temp_Faza_4'Img);
		 Put("Temp Faza 4: ");
		 Put(Temp_Faza_4,2,4,0);
         Set_Foreground (Yellow);
         Goto_XY (22, 18);
         Put("Nacisnij S aby wrocic do menu glownego");
         loop
            if(Koniec_fazy_4) then
               Clear_Screen (Cyan);
               Set_Background (Cyan);
               Set_Foreground (Yellow);
               Goto_XY (10, 10);
               Put("Zacieranie skonczone nacisnij S aby wrocic do menu glownego");
            else
               Set_Background (Cyan);
               Set_Foreground (Blue);
               Goto_XY (0, 10);
               --Put("Aktualna Temperatura " & Aktualna_Temperatura'Img);
			   Put("Aktualna Temperatura ");
			   Put(Aktualna_Temperatura,2,4,0);
               Goto_XY (0, 12);
               Put("Faza: " & Faza'Img);
            end if;
            delay 0.05;
            exit when Koniec_Zacieranie;
         end loop; 
         Set_Foreground (Gray);
         Clear_Screen;    
      end Display_Menu;
					
   begin
      loop
         Get_Immediate(Zn);
         exit when Zn in 's'|'S';
      end loop;
      Koniec_Zacieranie := True;
   end Zacieranie;
   
end Obsluga_Z;
