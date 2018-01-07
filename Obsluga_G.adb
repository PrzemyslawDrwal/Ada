with Ada.Text_IO, Ada.Calendar;
use Ada.Text_IO, Ada.Calendar;
with NT_Console;              use NT_Console;
with Ada.Strings.Fixed;       use Ada.Strings.Fixed;
with Ada.Characters.Handling; use Ada.Characters.Handling;
with Ada.Synchronous_Task_Control;
use Ada.Synchronous_Task_Control;

package body Obsluga_G is
   T_Got : Duration := 10.0;
   T_1 : Duration := 1.0;
   T_2 : Duration := 5.0;
   T_3 : Duration := 8.0;
   T_End : Float := 18.0;
   Zn: Character := ' ';
   procedure Gotowanie_Chlodzenie(Czas_Gotowania : in Duration; Chmielenie_Jeden : in Duration; Chmielenie_Dwa : in Duration; Chmielenie_Trzy : in Duration; Temp_Koniec_Chlodzenia : in Float) is 
      Koniec_Chmielenie : Boolean := False with Atomic;
      Chmielenie_Zakonczone : Boolean := False with Atomic;
      Aktualna_Temperatura : Float := 70.0 with atomic;
      Chlodzenie_Aktywne : Boolean := False;
      Ogrzewanie_Aktywne : Boolean := True;
      type STANY is (PODGRZEWANIE, GOTOWANIE, CHLODZENIE);
      type CHMIELENIE is (INIT, JEDEN, DWA, TRZY, WAIT);
	  
      
		
      Sem_We, Sem_Wy : Suspension_Object;
      Buf: Float;

      procedure Wstaw(Temp : in Float) is
      begin
         Suspend_Until_True(Sem_We);
         Buf := Temp;
         Set_True(Sem_Wy);
      end Wstaw;

      procedure Pobierz(Temp: out Float) is
      begin
         Suspend_Until_True(Sem_Wy);
         Temp := Buf;
         Set_True(Sem_We);
      end Pobierz;
		 
      task Termometr;
      task Czytaj_Termometr;
	
      task body Termometr is
         Temperatura : Float := 70.0;
         Delta_Temp : Float := 0.1;
      begin
         loop
            if (Ogrzewanie_Aktywne = True) then
               Delta_Temp := 1.0;
            elsif (Chlodzenie_Aktywne = True) then
               Delta_Temp := -2.0;
            else
               Delta_Temp := 0.0;
            end if;
            Temperatura := Temperatura + Delta_Temp;
            Wstaw(Temperatura);
            exit when Koniec_Chmielenie or Chmielenie_Zakonczone;
         end loop;
      end Termometr;
		
      task body Czytaj_Termometr is
         Okres_Odczytu : Duration := 1.0;
         Aktualny_Czas_Odczyt_Temperatury : Ada.Calendar.Time;
         Temp_Tymczasowa : Float := 70.0;
      begin
         Aktualny_Czas_Odczyt_Temperatury := Ada.Calendar.Clock;
         loop
            delay until Aktualny_Czas_Odczyt_Temperatury;
            Aktualny_Czas_Odczyt_Temperatury := Aktualny_Czas_Odczyt_Temperatury + Okres_Odczytu;	
            Pobierz(Temp_Tymczasowa);
            Aktualna_Temperatura := Temp_Tymczasowa;
            exit when Koniec_Chmielenie or Chmielenie_Zakonczone;
         end loop;
      end Czytaj_Termometr;
		
      task Chlodzenie_Ogrzewanie is
         entry Aktywuj_Chlodzenie;
         entry Wylacz_Chlodzenie;
         entry Aktywuj_Ogrzewanie;
         entry Wylacz_Ogrzewanie;
      end Chlodzenie_Ogrzewanie;

      task body Chlodzenie_Ogrzewanie is
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
            or 
               accept Aktywuj_Ogrzewanie do
                  Ogrzewanie_Aktywne := True;
               end Aktywuj_Ogrzewanie;
            or 
               accept Wylacz_Ogrzewanie do
                  Ogrzewanie_Aktywne := False;
               end Wylacz_Ogrzewanie;
            else
               delay 0.1;
            end select;
            exit when Koniec_Chmielenie or Chmielenie_Zakonczone;
         end loop;
      end Chlodzenie_Ogrzewanie; 	
      Aktualny_Stan : STANY := PODGRZEWANIE;
      Aktualne_Chmielenie : CHMIELENIE := INIT;
      task Modul_Kontrolny;

      task body Modul_Kontrolny is
         Aktualny_Czas : Ada.Calendar.Time;
         --           Aktualny_Stan : STANY := PODGRZEWANIE;
         --           Aktualne_Chmielenie : CHMIELENIE := INIT;
         ACzas_Gotowania :  Ada.Calendar.Time;
         Czas_1 :  Ada.Calendar.Time;
         Czas_2 :  Ada.Calendar.Time;
         Czas_3 :  Ada.Calendar.Time;
      begin
         loop 
            case ( Aktualny_Stan ) is
            when PODGRZEWANIE =>
               --Put_Line("Zyje");
               --Put_Line(Aktualna_Temperatura'Img);
               if(Aktualna_Temperatura < 99.9) then
                  Chlodzenie_Ogrzewanie.Aktywuj_Ogrzewanie;
                  Aktualny_Stan := PODGRZEWANIE;
               else
                  Chlodzenie_Ogrzewanie.Wylacz_Ogrzewanie;
                  Aktualny_Stan := GOTOWANIE;
                  ACzas_Gotowania := Ada.Calendar.Clock;
                  ACzas_Gotowania := ACzas_Gotowania + Czas_Gotowania;
                  Czas_1 := Ada.Calendar.Clock;
                  Czas_1 := Czas_1 + Chmielenie_Jeden;
                  Czas_2 := Ada.Calendar.Clock;
                  Czas_2 := Czas_2 + Chmielenie_Dwa;
                  Czas_3 := Ada.Calendar.Clock;
                  Czas_3 := Czas_3 + Chmielenie_Trzy;
               end if;
            when GOTOWANIE =>
               Aktualny_Czas := Ada.Calendar.Clock;
               if(Aktualny_Czas > ACzas_Gotowania) then
                  Aktualny_Stan := CHLODZENIE;
               else 
                  Aktualny_Stan := GOTOWANIE;
                  case (Aktualne_Chmielenie) is
                  when INIT =>
                     if (Aktualny_Czas > Czas_1) then
                        Aktualne_Chmielenie := JEDEN;
                     else
                        Aktualne_Chmielenie := INIT;
                     end if;
                  when JEDEN =>
                     if (Aktualny_Czas > Czas_2) then
                        Aktualne_Chmielenie := DWA;
                     else
                        Aktualne_Chmielenie := JEDEN;
                     end if;
                  when DWA => 
                     if (Aktualny_Czas > Czas_3) then
                        Aktualne_Chmielenie := TRZY;
                     else
                        Aktualne_Chmielenie := DWA;
                     end if;		
                  when TRZY =>
                     Aktualne_Chmielenie := WAIT;
					when WAIT =>
					delay until ACzas_Gotowania + Czas_Gotowania - 1.0;
					Aktualne_Chmielenie := INIT;
                  when others =>
                     null;
                  end case;
               end if;
            when CHLODZENIE =>
               if(Aktualna_Temperatura > Temp_Koniec_Chlodzenia) then
                  Chlodzenie_Ogrzewanie.Aktywuj_Chlodzenie;
               else
                  Chlodzenie_Ogrzewanie.Wylacz_Chlodzenie;
                  Chmielenie_Zakonczone := True;
               end if;
            end case;
            exit when Koniec_Chmielenie or Chmielenie_Zakonczone;
         end loop;
      end Modul_Kontrolny;
      
      task Display_Menu;
      task body Display_Menu is

      begin
         loop
            Clear_Screen (Cyan);
            Set_Foreground (Blue);
            Set_Background (Yellow);
            Goto_XY (20, 0);
            Put_Line("* KONTROLA FERMENTACJI PIWA - CHMIELENIE * ");
            Set_Background (Cyan);
            Goto_XY (0, 2);
            Put_Line("Czas Gotowania: " & Czas_Gotowania'Img);
            Goto_XY (0, 4);
            Put_Line("Chmielenie Jeden: " & Chmielenie_Jeden'Img);
            Goto_XY (0, 6);
            Put("Chmielenie Dwa: " & Chmielenie_Dwa'Img);
            Goto_XY (0, 8);
            Put("Chmielenie Trzy: " & Chmielenie_Trzy'Img);
            Goto_XY (0, 10);
            Put("Temp Koniec Chlodzenia: " & Temp_Koniec_Chlodzenia'Img);
            Goto_XY (0, 20);
            case (Aktualne_Chmielenie) is
            when INIT =>
               Put_Line("Dodaj pierwsza porcje chmielu");
               when JEDEN =>
                  Put_Line("Dodaj druga porcje chmielu"); 
               when DWA => 
                  Put_Line("Dodaj trzecia porcje chmielu");
               when others =>
                  null;
            end case;
            Set_Foreground (Yellow);
            Goto_XY (17, 24);
            Put("Please press S to exit and go back to start menu");
            --loop
            if(Chmielenie_Zakonczone) then
               Clear_Screen (Cyan);
               Set_Background (Cyan);
               Set_Foreground (Yellow);
               Goto_XY (12, 10);
               Put("Chmielenieelenie skonczone nacisnij S aby wrocic do menu glownego");
            else
               Set_Background (Cyan);
               Set_Foreground (Blue);
               Goto_XY (0, 12);
               Put("Stan: " & Aktualny_Stan'Img);
               Goto_XY (0, 14);
               Put("Chmielenie: " & Aktualne_Chmielenie'Img);
               Goto_XY (0, 16);
               Put("Aktualna Temperatura: " & Aktualna_Temperatura'Img);
            end if;
            delay 0.05;
            exit when Koniec_Chmielenie;
         end loop; 
         Set_Foreground (Gray);
         Clear_Screen;    
      end Display_Menu;
		
   begin
      Set_True(Sem_We);
      Set_False(Sem_Wy);  
      loop
         Get_Immediate(Zn);
         exit when Zn in 's'|'S';
      end loop;
      Koniec_Chmielenie := True;
   end Gotowanie_Chlodzenie;

end Obsluga_G;
		

