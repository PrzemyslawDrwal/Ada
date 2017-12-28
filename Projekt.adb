with Ada.Text_IO, Ada.Calendar;
use Ada.Text_IO, Ada.Calendar;

procedure Projekt is
Aktualna_Temperatura : Float := 18.0 with atomic;
Chlodzenie_Aktywne : Boolean := False with atomic;
	
	protected Bufor_Pomiar_Temperatury is
		entry Wstaw(T : in Float);
		entry Pobierz(T : out Float);
	private 
		Temp : Float;
		Pusty : Boolean := True;
	end Bufor_Pomiar_Temperatury;
	
	protected body Bufor_Pomiar_Temperatury is
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
	end Bufor_Pomiar_Temperatury;
	
	task Termometr;
	task Czytaj_Termometr;
	
	task body Termometr is
		Okres : constant Duration := 0.01;
		Temperatura : Float := 18.0;
		Aktualny_Czas_Termometr : Ada.Calendar.Time;
		begin
		Aktualny_Czas_Termometr := Ada.Calendar.Clock;
		loop
			delay until Aktualny_Czas_Termometr;
			Aktualny_Czas_Termometr := Aktualny_Czas_Termometr + Okres;
			Temperatura := Temperatura + 1.0;
			Bufor_Pomiar_Temperatury.Wstaw(Temperatura);
		end loop;
	end Termometr;
	
	task body Czytaj_Termometr is
		Okres_Odczytu : constant Duration := 0.5;
		Aktualny_Czas_Odczyt_Temperatury : Ada.Calendar.Time;
		Temp_Tymczasowa : Float := 19.0;
		begin
		Aktualny_Czas_Odczyt_Temperatury := Ada.Calendar.Clock;
		loop
			delay until Aktualny_Czas_Odczyt_Temperatury;
			Aktualny_Czas_Odczyt_Temperatury := Aktualny_Czas_Odczyt_Temperatury + Okres_Odczytu;	
			Bufor_Pomiar_Temperatury.Pobierz(Temp_Tymczasowa);
			Aktualna_Temperatura := Temp_Tymczasowa;
			Put_Line(Aktualna_Temperatura'Img);
		end loop;
	end Czytaj_Termometr;
	
	begin 
	--delay 0.05;
	--Put_Line(Aktualna_Temperatura'Img);
	null;
	end Projekt;