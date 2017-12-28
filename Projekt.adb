with Ada.Text_IO, Ada.Calendar, Ada.Numerics.Discrete_Random;
use Ada.Text_IO, Ada.Calendar;

procedure Projekt is
Aktualna_Temperatura : Float := 18.0 with atomic;
Chlodzenie_Aktywne : Boolean := False with atomic;

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
				Delta_Temp := -0.1;
			else
				Delta_Temp := 0.01;
			end if;
				Temperatura := Temperatura + Delta_Temp;
				Bufor_Pomiar_Temperatury_Fermentor.Wstaw(Temperatura);
		end loop;
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
		end loop;
	end Czytaj_Termometr_Fermentor;
	
------------------------------------------------------
------------Pomiar temperatury otoczenia -------------

	protected Bufor_Pomiar_Temperatury_Otoczenie is
		entry Wstaw(T : in Integer);
		entry Pobierz(T : out Integer);
	private 
		Temp : Integer;
		Pusty : Boolean := True;
	end Bufor_Pomiar_Temperatury_Otoczenie;
	
	protected body Bufor_Pomiar_Temperatury_Otoczenie is
		entry Wstaw(T : in Integer)
			when Pusty is
				begin
					Temp := T;
					Pusty := False;
		end Wstaw;
		
		entry Pobierz (T : out Integer)
			when not Pusty is
				begin	
					T := Temp;
					Pusty := True;
		end Pobierz;
	end Bufor_Pomiar_Temperatury_Otoczenie;
	
	task Termometr_Otoczenie;
	task Czytaj_Termometr_Otoczenie;	
	
	task body Termometr_Otoczenie is
		Temperatura : Integer := 18;
		subtype Delta_Temp_Otoczenie is Integer range -4..4;
		package Losuj_Delte is new Ada.Numerics.Discrete_Random(Delta_Temp_Otoczenie);
		use Losuj_Delte;
		Temp_Los : Delta_Temp_Otoczenie;
		Gen: Generator; 		
		begin
		Reset(Gen);
		loop	
			Temp_Los := Random(Gen);
			Temperatura := 18 + Temp_Los;
			Bufor_Pomiar_Temperatury_Otoczenie.Wstaw(Temperatura);
		end loop;
	end Termometr_Otoczenie;	
	
		task body Czytaj_Termometr_Otoczenie is
		Okres_Odczytu : Duration := 10.0;
		Aktualny_Czas_Odczyt_Temperatury : Ada.Calendar.Time;
		Temp_Tymczasowa : Integer;
		begin
		Aktualny_Czas_Odczyt_Temperatury := Ada.Calendar.Clock;
		loop
			delay until Aktualny_Czas_Odczyt_Temperatury;		
			Aktualny_Czas_Odczyt_Temperatury := Aktualny_Czas_Odczyt_Temperatury + Okres_Odczytu;	
			Bufor_Pomiar_Temperatury_Otoczenie.Pobierz(Temp_Tymczasowa);
			Put_Line(Temp_Tymczasowa'Img);
		end loop;
	end Czytaj_Termometr_Otoczenie;
	
	begin 
	null;
	end Projekt;