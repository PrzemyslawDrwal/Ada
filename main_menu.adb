with NT_Console;              use NT_Console;
with Ada.Strings.Fixed;       use Ada.Strings.Fixed;
with Ada.Characters.Handling; use Ada.Characters.Handling;
with Ada.Text_IO;
use Ada.Text_IO;
with Obsluga_F;
use Obsluga_F;
with Obsluga_Z;
use Obsluga_Z;
with Obsluga_G;
use Obsluga_G;

package body Main_Menu is
   procedure Menu is
      Styl : Style;
      Czas_Fermentacji : Duration := 100.0;
      Temp_Otoczenia : Integer := 18;
      Zn: Character := ' ';
      Temp_Max : Float;
      Temp_Min : Float;
      Nazwa_Piwa: String(1 .. 20) := (others => ' ');
      Last: Integer;
      Faza : Integer := 1;
      Czas_Faza_1 : Duration := 100.0; 
      Temp_Faza_1 : Float := 40.0; 
      Czas_Faza_2 : Duration := 100.0; 
      Temp_Faza_2 : Float := 66.0;
      Czas_Faza_3 : Duration := 100.0; 
      Temp_Faza_3 : Float := 72.0;
      Czas_Faza_4 : Duration := 100.0; 
      Temp_Faza_4 : Float := 78.0;
      Chmielenie : Integer := 1;
      Czas_Gotowania : Duration; 
      Chmielenie_Jeden : Duration;
      Chmielenie_Dwa : Duration; 
      Chmielenie_Trzy : Duration;
      Temp_Koniec_Chlodzenia : Float;
      Blad_Czasu_Chmielenia: exception;
      Blad_Temperatury_Fazy: exception;


      procedure Get_Temp_Max is
      begin
         Clear_Screen (Light_Cyan);
         Set_Foreground (Blue);
         Set_Background (Yellow);
         Goto_XY (27, 4);
         Put("Podaj temperature max [C] ");
         Temp_Max := Float'Value(Get_Line);
      exception
         when Data_Error => Put_Line("Data Error! Podaj temperature max (float)"); Temp_Max := Float'Value(Get_Line);
         when Constraint_Error => Put_Line("Constraint Error! Podaj temperature max (float)"); Temp_Max := Float'Value(Get_Line);
      end Get_Temp_Max;

      procedure Get_Temp_Min is
      begin
         Clear_Screen (Light_Cyan);
         Set_Foreground (Blue);
         Set_Background (Yellow);
         Goto_XY (27, 4);
         Put("Podaj temperature min [C] ");
         Temp_Min := Float'Value(Get_Line);
      exception
         when Data_Error => Put_Line("Data Error! Podaj temperature min (float)"); Temp_Min := Float'Value(Get_Line);
         when Constraint_Error => Put_Line("Constraint Error! Podaj temperature min (float)"); Temp_Min := Float'Value(Get_Line);
      end Get_Temp_Min;

      procedure Get_Temp_Otoczenia is
      begin
         Clear_Screen (Light_Cyan);
         Set_Foreground (Blue);
         Set_Background (Yellow);
         Goto_XY (27, 4);
         Put("Podaj temperature otoczenia [C] ");
         Temp_Otoczenia := Integer'Value(Get_Line);
      exception
         when Data_Error => Put_Line("Data Error! Podaj temperature otoczenia (integer)"); Temp_Otoczenia := Integer'Value(Get_Line);
         when Constraint_Error => Put_Line("Constraint Error! Podaj temperature otoczenia (integer)"); Temp_Otoczenia := Integer'Value(Get_Line);
      end Get_Temp_Otoczenia;

      procedure Get_Nazwa_Piwa is
      begin
         Clear_Screen (Light_Cyan);
         Set_Foreground (Blue);
         Set_Background (Yellow);
         Goto_XY (32, 4);
         Put("Podaj nazwe piwa ");
         Get_Line(Nazwa_Piwa, Last);
      exception
         when Data_Error => Put_Line("Data Error! Podaj nazwe piwa (string)"); Get_Line(Nazwa_Piwa, Last);
         when Constraint_Error => Put_Line("Constraint Error! Podaj nazwe piwa (string)"); Get_Line(Nazwa_Piwa, Last);
      end Get_Nazwa_Piwa;
	  
      function Pobierz_Temp return Float is
         Temperatura_temp : Float;
      begin
         Clear_Screen (Light_Cyan);
         Set_Foreground (Blue);
         Set_Background (Yellow);
         Goto_XY (27, 4);
         Put("Podaj temperature fazy [C] " & Faza'Img & " ");
         Temperatura_temp := Float'Value(Get_Line);
         case (Faza) is
         when 2 => if (Temp_Faza_1 > Temperatura_temp) then 
               raise Blad_Temperatury_Fazy;
            else 
               return Temperatura_temp;
            end if;
         when 3 => if (Temp_Faza_2 > Temperatura_temp) then 
               raise Blad_Temperatury_Fazy;
            else 
               return Temperatura_temp;
            end if;
         when 4 => if (Temp_Faza_3 > Temperatura_temp) then 
               raise Blad_Temperatury_Fazy;
            else 
               return Temperatura_temp;
            end if;
         when others => return Temperatura_temp;
         end case;
      exception
         when Blad_Temperatury_Fazy => Put_Line("Error! Podaj temperature fazy " & Faza'Img & " wieksza od poprzedniej"); return Float'Value(Get_Line);
         when Data_Error => Put_Line("Data Error! Podaj temperature fazy " & Faza'Img & " (float)"); return Float'Value(Get_Line);
         when Constraint_Error => Put_Line("Constraint Error! Podaj temperature fazy " & Faza'Img & " (float)"); return Float'Value(Get_Line);
      end Pobierz_Temp;
			 
      function Pobierz_Czas return Duration is
      begin
         Clear_Screen (Light_Cyan);
         Set_Foreground (Blue);
         Set_Background (Yellow);
         Goto_XY (31, 4);
         Put("Podaj czas fazy  " & Faza'Img & "  [sek] ");
         return Duration'Value(Get_Line);
      exception
         when Data_Error => Put_Line("Data Error! Podaj czas fazy " & Faza'Img & " (Duration)"); return Duration'Value(Get_Line);
         when Constraint_Error => Put_Line("Constraint Error! Podaj czas fazy " & Faza'Img & " (Duration)"); return Duration'Value(Get_Line);
      end Pobierz_Czas;	
      
      function Pobierz_Czas_Fermentacji return Duration is
      begin
         Clear_Screen (Light_Cyan);
         Set_Foreground (Blue);
         Set_Background (Yellow);
         Goto_XY (30, 4);
         Put("Podaj czas fermentacji [sek] ");
         return Duration'Value(Get_Line);
      exception
         when Data_Error => Put_Line("Data Error! Podaj czas fermentacji (Duration)"); return Duration'Value(Get_Line);
         when Constraint_Error => Put_Line("Constraint Error! Podaj czas fermentacji (Duration)"); return Duration'Value(Get_Line);
      end Pobierz_Czas_Fermentacji;	
      
      function Pobierz_Czas_Gotowania return Duration is
      begin
         Clear_Screen (Light_Cyan);
         Set_Foreground (Blue);
         Set_Background (Yellow);
         Goto_XY (31, 4);
         Put("Podaj czas gotowania [sek] ");
         return Duration'Value(Get_Line);
      exception
         when Data_Error => Put_Line("Data Error! Podaj czas gotowania (Duration)"); return Duration'Value(Get_Line);
         when Constraint_Error => Put_Line("Constraint Error! Podaj czas gotowania (Duration)"); return Duration'Value(Get_Line);
      end Pobierz_Czas_Gotowania;	
			
      function Pobierz_Czas_Chmielenia return Duration is
         Chmielenie_temp : Duration;
      begin
         Clear_Screen (Light_Cyan);
         Set_Foreground (Blue);
         Set_Background (Yellow);
         Goto_XY (31, 4);
         Put("Podaj czas chmielenia [sek] " & Chmielenie'Img & " ");
         Chmielenie_temp := Duration'Value(Get_Line);
         if (Chmielenie_temp > Czas_Gotowania) then
            raise Blad_Czasu_Chmielenia;
         else
            return Chmielenie_temp;
         end if;
      exception
         when Blad_Czasu_Chmielenia => Put_Line("Error! Podaj czas chmielenia mniejszy od czasu gotownia" & Czas_Gotowania'Img); return Duration'Value(Get_Line);
         when Data_Error => Put_Line("Data Error! Podaj czas chmielenia " & Chmielenie'Img & " (Duration)"); return Duration'Value(Get_Line);
         when Constraint_Error => Put_Line("Constraint Error! Podaj czas chmielenia " & Chmielenie'Img & " (Duration)"); return Duration'Value(Get_Line);
      end Pobierz_Czas_Chmielenia;	
      
      function Pobierz_Temp_Koniec_Chlodzenia return Float is
      begin
         Clear_Screen (Light_Cyan);
         Set_Foreground (Blue);
         Set_Background (Yellow);
         Goto_XY (27, 4);
         Put("Podaj temperature Koniec Chlodzenia [C] ");
         return Float'Value(Get_Line);
      exception
         when Data_Error => Put_Line("Data Error! Podaj temperature Koniec Chlodzenia (float)"); return Float'Value(Get_Line);
         when Constraint_Error => Put_Line("Constraint Error! Podaj temperature Koniec Chlodzenia (float)"); return Float'Value(Get_Line);
      end Pobierz_Temp_Koniec_Chlodzenia;
      
      procedure Get_Styl_Piwa is
      begin
         Clear_Screen (Light_Cyan);
         Set_Foreground (Blue);
         Set_Background (Yellow);
         Goto_XY (33, 4);
         Put_Line("Podaj styl piwa ");
         Set_Background (Light_Cyan);
         Put_Line("l - Lager ");
         Put_Line("a - Ale ");
         Put_Line("h - Hefeweizen ");
         Put_Line("b - Abbaye ");
         Put_Line("k - Kveik ");
         loop
            Get_Immediate(Zn);
            if((Zn = 'L') or (Zn = 'l')) then 
               Styl := Lager;
               exit;
            elsif ((Zn = 'A') or (Zn = 'a')) then 
               Styl := Ale;
               exit;
            elsif ((Zn = 'H') or (Zn = 'h')) then 
               Styl := Hefeweizen;
               exit;
            elsif ((Zn = 'B') or (Zn = 'b')) then 
               Styl := Abbaye;
               exit;
            elsif ((Zn = 'K') or (Zn = 'k')) then 
               Styl := Kveik;
               exit;
            end if;
         end loop;
      end Get_Styl_Piwa;

   begin
      loop
         Clear_Screen (Light_Blue);
         Set_Cursor(False);
         Set_Foreground (Blue);
         Set_Background (Yellow);
         Goto_XY (27, 0);
         Put("* KONTROLA FERMENTACJI PIWA *");
         Set_Background (Light_Blue);
         Set_Foreground (Light_Cyan);
         Goto_XY (24, 6);
         Put("Nacisnij F aby zaczac fermentacje");
         Goto_XY (25, 2);
         Put("Nacisnij Z aby zaczac zacieranie");
         Goto_XY (19, 4);
         Put("Nacisnij G aby zaczac gotowanie i chlodzenie");
         Set_Foreground (Yellow);
         Goto_XY (27, 10);
         Put("Nacisnij Q aby wyjsc z programu");
         Get_Immediate(Zn);
         if((Zn = 'f') or (Zn = 'F')) then
            Get_Temp_Otoczenia;
            Get_Temp_Min;
            Get_Temp_Max;
            Get_Styl_Piwa;
            Get_Nazwa_Piwa;
            Czas_Fermentacji := Pobierz_Czas_Fermentacji;
            Fermentacja(Nazwa_Piwa, Styl, Czas_Fermentacji, Temp_Otoczenia, Temp_Min, Temp_Max);
         elsif ((Zn = 'z') or (Zn = 'Z')) then
            Czas_Faza_1 := Pobierz_Czas;
            Temp_Faza_1 :=  Pobierz_Temp;
            Faza := 2;
            Czas_Faza_2 := Pobierz_Czas;
            Temp_Faza_2 :=  Pobierz_Temp;
            Faza := 3;	
            Czas_Faza_3 := Pobierz_Czas;
            Temp_Faza_3 :=  Pobierz_Temp;
            Faza := 4;	
            Czas_Faza_4 := Pobierz_Czas;
            Temp_Faza_4 :=  Pobierz_Temp;
            Faza := 1;	
            Zacieranie(Czas_Faza_1, Temp_Faza_1, Czas_Faza_2, Temp_Faza_2, Czas_Faza_3, Temp_Faza_3, Czas_Faza_4, Temp_Faza_4);
         elsif ((Zn = 'g') or (Zn = 'G')) then
            Czas_Gotowania := Pobierz_Czas_Gotowania;
            Chmielenie := 1;
            Chmielenie_Jeden := Pobierz_Czas_Chmielenia;
            Chmielenie := 2;
            Chmielenie_Dwa := Pobierz_Czas_Chmielenia;
            Chmielenie := 3;
            Chmielenie_Trzy := Pobierz_Czas_Chmielenia;
            Temp_Koniec_Chlodzenia := Pobierz_Temp_Koniec_Chlodzenia;        
            Gotowanie_Chlodzenie(Czas_Gotowania, Chmielenie_Jeden, Chmielenie_Dwa, Chmielenie_Trzy, Temp_Koniec_Chlodzenia);
         end if;
         delay 0.5;
         exit when Zn in 'q'|'Q';
      end loop;
      Set_Foreground (Gray);
      Clear_Screen;
   end Menu;
end Main_Menu;
