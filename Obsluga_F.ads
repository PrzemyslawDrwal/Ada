package Obsluga_F is 
type Style is (Lager, Ale, Hefeweizen, Abbaye, Kveik);
	procedure Fermentacja(Nazwa_Piwa : in String; Styl : in Style; Czas_Fermentacji : in Duration; Temp_Otoczenia : in Integer; Temp_Min_O : in Float; Temp_Max_O : in Float);
end Obsluga_F;