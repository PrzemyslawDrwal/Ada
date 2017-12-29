with Ada.Text_IO, Ada.Calendar;
use Ada.Text_IO, Ada.Calendar;

procedure Zacieranie is
Podgrzewanie_Aktywne : Boolean := False;
Aktualna_Temperatura : Float := 30.0;
Faza : Integer := 1;

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
		end loop;
	end Modul_Podgrzewania; 
	
task Termometr;

task body Termometr is
		Okres_Odczytu : Duration := 1.0;
		Aktualny_Czas_Odczyt_Temperatury : Ada.Calendar.Time;
		Temp_Tymczasowa : Float := 30.0;
	begin
		Aktualny_Czas_Odczyt_Temperatury := Ada.Calendar.Clock;
		loop
			delay until Aktualny_Czas_Odczyt_Temperatury;
			Aktualny_Czas_Odczyt_Temperatury := Aktualny_Czas_Odczyt_Temperatury + Okres_Odczytu;	
			Bufor_Temperatury.Pobierz(Temp_Tymczasowa);
			Aktualna_Temperatura := Temp_Tymczasowa;
		end loop;
end Termometr;
	
	
task Zacieranie;

task body Zacieranie is
	Czas_Faza_1 : Duration := 10.0; --100.0
	Temp_Faza_1 : Float := 40.0;
	Czas_Faza_2 : Duration := 10.0; --100.0
	Temp_Faza_2 : Float := 66.0;
	Czas_Faza_3 : Duration := 1.5; --15.0
	Temp_Faza_3 : Float := 72.0;
	Czas_Faza_4 : Duration := 1.0; --1.0
	Temp_Faza_4 : Float := 78.0;	
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
								exit;
						else 
						Modul_Podgrzewania.Aktywuj_Podgrzewanie;
						end if;
					when others => Modul_Podgrzewania.Wylacz_Podgrzewanie;
					end case;
		end loop;
	end Zacieranie;
					
	begin
	loop
	delay 1.0;
	Put_Line(Aktualna_Temperatura'Img);
	end loop;
	end Zacieranie;