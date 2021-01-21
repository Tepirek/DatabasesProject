USE shop;

/* 
	1. Wykaz dost�pno�ci wszystkich produkt�w z hurtowni X.
	Pobrane dane pozwalaj� zaplanowa� schemat zamawiania produkt�w z hurtownii. Wiedza o tym czy wybrany produkt jest dost�pny w danej hurtownii jest w tym celu niezb�dna. 
*/
SELECT	ID_hurtowni AS Hurtownia, 
		ID_produktu AS EAN, 
		produkt.nazwa AS 'Nazwa produktu', 
		warto��_dost�pno�� AS 'Status produktu',
		ilo�� AS 'Stan magazynowy'
		FROM dost�pno�� INNER JOIN produkt ON ID_hurtowni = 5 AND dost�pno��.ID_produktu = produkt.ean 
		ORDER BY(
		CASE warto��_dost�pno�� 
			WHEN 'niedost�pny' THEN 1 
			WHEN 'wkr�tce dost�pny' THEN 2 
			WHEN 'dost�pny' THEN 3 
		END) DESC, 'Nazwa produktu' ASC;

/* 
	2. Wy�wietl zam�wienia z�o�one przez klienta X.
	Dane, kt�re zwraca poni�sze zapytanie s� niezb�dne w celu wy�wietlenia historii zam�wie� wybranego klienta. Pozwala si� na wybieranie tylko zam�wie� o danym statusie zam�wienia.	
*/
SELECT	* 
		FROM zam�wienie 
		WHERE ID_adresu = (SELECT ID_adresu FROM klient WHERE ID_klienta = 2) 
		AND status_zam�wienie = 'dostarczono'
		ORDER BY data_dostawa DESC;

/* 
	3. Podaj dane magazyn�w, wy�wietlane wed�ug dost�pnego miejsca. 
	Poni�sze zapytanie jest niezb�dne w celu zaplanowania r�wnomiernego rozk�adu dostaw na najbli�szy czas aby doprowadzi� do r�wnomiernego rozk�adu towar�w mi�dzy magazynami.
*/
SELECT	magazyn.ID_magazynu AS 'Numer magazynu',
		magazyn.dost�pne_miejsce AS 'Dost�pne miejsce',
		adres.ulica AS 'Ulica',
		adres.nr_budynku AS 'Numer budynku',
		adres.kod_pocztowy AS 'Kod pocztowy',
		adres.miasto AS 'Miasto',
		adres.kraj AS 'Kraj'
		FROM adres 
		INNER JOIN magazyn ON magazyn.ID_adresu = adres.ID_adresu
		ORDER BY dost�pne_miejsce DESC;

/* 
	4. Pobranie danych o klientach kt�rzy zam�wili najwi�cej produkt�w w sklepie.
	Poni�sze zapytanie jest niezb�dne w celu wprowadzenia spersonalizowanych promocji dla najaktywniejszych klient�w.
*/
DROP VIEW clientOrders;
CREATE VIEW clientOrders AS 
SELECT	klient.ID_klienta,
		klient.imie,
		klient.nazwisko,
		klient.adres_email,
		zam�wienie.kwota
		FROM zam�wienie
		INNER JOIN adres ON adres.ID_adresu = zam�wienie.ID_adresu
		INNER JOIN klient ON klient.ID_adresu = adres.ID_adresu;
-- SELECT	* FROM clientOrders;
SELECT	ID_klienta AS 'Identyfikator',
		imie AS 'Imie',
		nazwisko AS 'Nazwisko',
		adres_email AS 'Adres email',
		SUM(kwota) AS '��czna kwota zam�wie�',
		COUNT(ID_klienta) AS 'Ilo�� zam�wie�'
		FROM clientOrders
		GROUP BY ID_klienta, imie, nazwisko, adres_email
		ORDER BY 'Ilo�� zam�wie�' DESC, 'Nazwisko' ASC, 'Imie' ASC;

/* 
	5. Kt�ra hurtownia ma najwi�cej dost�pnych produkt�w.
	Brak specjalnej przydatno�ci, propozycja jednego z koleg�w ;)
*/
DROP VIEW hurtownieMax;
CREATE VIEW hurtownieMax AS 
SELECT	ID_hurtowni AS Hurtownia, 
		COUNT(ID_hurtowni) AS 'productCount'
		FROM dost�pno��
		WHERE warto��_dost�pno�� = 'dost�pny'
		GROUP BY ID_hurtowni;
-- SELECT * FROM hurtownieMax ORDER BY productCount DESC;
SELECT	Hurtownia, 
		productCount AS 'Ilo�� dost�pnych produkt�w'
		FROM hurtownieMax 
		WHERE productCount = (SELECT MAX(productCount) FROM hurtownieMax);

/* 
	6. Wykaz obci��enia magazyn�w.
	Poni�sze zapytanie jest niezb�dne w celu odci��enia tych magazyn�w, kt�re otrzymuj� zbyt wiele dostaw w por�wnaniu do innych. Pobrana dane pozwalaj� lepiej zorganizowa� kolejne dostawy tak, aby wszystkie magazyny wype�nia�y si� r�wnomiernie z przybli�on� ilo�ci� dostaw.
*/
SELECT	magazyn.ID_magazynu AS Magazyn, 
		COUNT(dostawa.ID_dostawa) AS 'Ilo�� dostaw', 
		magazyn.dost�pne_miejsce AS 'Dost�pne miejsce' 
		FROM magazyn
			LEFT JOIN dostawa ON magazyn.ID_magazynu = dostawa.ID_magazynu
			LEFT JOIN hurtownia ON hurtownia.ID_hurtowni = dostawa.ID_dostawa 
		GROUP BY magazyn.ID_magazynu, magazyn.dost�pne_miejsce 
		ORDER BY 'Ilo�� dostaw' DESC, 'Dost�pne miejsce' DESC;

/* 
	7. Wykaz zainteresowania produktami.
	Poni�sze zapytanie s�u�y w celach marketingowych. Pobrane dane wykazuj�, kt�re produkty ciesz� si� najwi�kszym zainteresowaniem. 
*/
SELECT	* FROM produkt 
		ORDER BY ilo��_sprzedanych_artyku��w DESC, nazwa ASC;

/* 
	8. Wykaz produk�w kt�re zosta�y dostarczone do magazynu X w wybranym przedziale czasowym.
	Poni�sze zapytanie pozwala oszacowa� zapotrzebowanie na produkty w wybranym rejonie, zak�adaj�c, �e produkty dostarczane s� do klient�w z najbli�szego mo�liwego magazynu, kt�ry posiada zamawiane towary.
*/
SELECT	magazyn.ID_magazynu AS Magazyn, 
		dostawa.ID_dostawa AS 'Numer dostawy',
		dostawa.status_dostawa AS 'Status dostawy',
		dostawa.data_realizacji AS 'Data realizacji',
		pozycja_dostawy.ilo�� AS 'Ilo��',
		produkt.ean AS 'EAN',
		produkt.nazwa AS 'Nazwa produktu',
		produkt.cena AS Cena 
		FROM magazyn
			INNER JOIN dostawa ON dostawa.ID_magazynu = magazyn.ID_magazynu
			INNER JOIN pozycja_dostawy ON pozycja_dostawy.ID_dostawa = dostawa.ID_dostawa
			INNER JOIN produkt ON produkt.ean = pozycja_dostawy.ID_produktu
		WHERE magazyn.ID_magazynu = 9 
			AND MONTH(dostawa.data_realizacji) >= 1
			AND MONTH(dostawa.data_realizacji) <= 12
			AND dostawa.status_dostawa = 'dostarczono'
		ORDER BY dostawa.data_realizacji ASC;