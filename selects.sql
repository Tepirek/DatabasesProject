USE shop;

/* 
	1. Wykaz dostêpnoœci wszystkich produktów z hurtowni X.
	Pobrane dane pozwalaj¹ zaplanowaæ schemat zamawiania produktów z hurtownii. Wiedza o tym czy wybrany produkt jest dostêpny w danej hurtownii jest w tym celu niezbêdna. 
*/
SELECT	ID_hurtowni AS Hurtownia, 
		ID_produktu AS EAN, 
		produkt.nazwa AS 'Nazwa produktu', 
		wartoœæ_dostêpnoœæ AS 'Status produktu',
		iloœæ AS 'Stan magazynowy'
		FROM dostêpnoœæ INNER JOIN produkt ON ID_hurtowni = 5 AND dostêpnoœæ.ID_produktu = produkt.ean 
		ORDER BY(
		CASE wartoœæ_dostêpnoœæ 
			WHEN 'niedostêpny' THEN 1 
			WHEN 'wkrótce dostêpny' THEN 2 
			WHEN 'dostêpny' THEN 3 
		END) DESC, 'Nazwa produktu' ASC;

/* 
	2. Wyœwietl zamówienia z³o¿one przez klienta X.
	Dane, które zwraca poni¿sze zapytanie s¹ niezbêdne w celu wyœwietlenia historii zamówieñ wybranego klienta. Pozwala siê na wybieranie tylko zamówieñ o danym statusie zamówienia.	
*/
SELECT	* 
		FROM zamówienie 
		WHERE ID_adresu = (SELECT ID_adresu FROM klient WHERE ID_klienta = 2) 
		AND status_zamówienie = 'dostarczono'
		ORDER BY data_dostawa DESC;

/* 
	3. Podaj dane magazynów, wyœwietlane wed³ug dostêpnego miejsca. 
	Poni¿sze zapytanie jest niezbêdne w celu zaplanowania równomiernego rozk³adu dostaw na najbli¿szy czas aby doprowadziæ do równomiernego rozk³adu towarów miêdzy magazynami.
*/
SELECT	magazyn.ID_magazynu AS 'Numer magazynu',
		magazyn.dostêpne_miejsce AS 'Dostêpne miejsce',
		adres.ulica AS 'Ulica',
		adres.nr_budynku AS 'Numer budynku',
		adres.kod_pocztowy AS 'Kod pocztowy',
		adres.miasto AS 'Miasto',
		adres.kraj AS 'Kraj'
		FROM adres 
		INNER JOIN magazyn ON magazyn.ID_adresu = adres.ID_adresu
		ORDER BY dostêpne_miejsce DESC;

/* 
	4. Pobranie danych o klientach którzy zamówili najwiêcej produktów w sklepie.
	Poni¿sze zapytanie jest niezbêdne w celu wprowadzenia spersonalizowanych promocji dla najaktywniejszych klientów.
*/
DROP VIEW clientOrders;
CREATE VIEW clientOrders AS 
SELECT	klient.ID_klienta,
		klient.imie,
		klient.nazwisko,
		klient.adres_email,
		zamówienie.kwota
		FROM zamówienie
		INNER JOIN adres ON adres.ID_adresu = zamówienie.ID_adresu
		INNER JOIN klient ON klient.ID_adresu = adres.ID_adresu;
-- SELECT	* FROM clientOrders;
SELECT	ID_klienta AS 'Identyfikator',
		imie AS 'Imie',
		nazwisko AS 'Nazwisko',
		adres_email AS 'Adres email',
		SUM(kwota) AS '£¹czna kwota zamówieñ',
		COUNT(ID_klienta) AS 'Iloœæ zamówieñ'
		FROM clientOrders
		GROUP BY ID_klienta, imie, nazwisko, adres_email
		ORDER BY 'Iloœæ zamówieñ' DESC, 'Nazwisko' ASC, 'Imie' ASC;

/* 
	5. Która hurtownia ma najwiêcej dostêpnych produktów.
	Brak specjalnej przydatnoœci, propozycja jednego z kolegów ;)
*/
DROP VIEW hurtownieMax;
CREATE VIEW hurtownieMax AS 
SELECT	ID_hurtowni AS Hurtownia, 
		COUNT(ID_hurtowni) AS 'productCount'
		FROM dostêpnoœæ
		WHERE wartoœæ_dostêpnoœæ = 'dostêpny'
		GROUP BY ID_hurtowni;
-- SELECT * FROM hurtownieMax ORDER BY productCount DESC;
SELECT	Hurtownia, 
		productCount AS 'Iloœæ dostêpnych produktów'
		FROM hurtownieMax 
		WHERE productCount = (SELECT MAX(productCount) FROM hurtownieMax);

/* 
	6. Wykaz obci¹¿enia magazynów.
	Poni¿sze zapytanie jest niezbêdne w celu odci¹¿enia tych magazynów, które otrzymuj¹ zbyt wiele dostaw w porównaniu do innych. Pobrana dane pozwalaj¹ lepiej zorganizowaæ kolejne dostawy tak, aby wszystkie magazyny wype³nia³y siê równomiernie z przybli¿on¹ iloœci¹ dostaw.
*/
SELECT	magazyn.ID_magazynu AS Magazyn, 
		COUNT(dostawa.ID_dostawa) AS 'Iloœæ dostaw', 
		magazyn.dostêpne_miejsce AS 'Dostêpne miejsce' 
		FROM magazyn
			LEFT JOIN dostawa ON magazyn.ID_magazynu = dostawa.ID_magazynu
			LEFT JOIN hurtownia ON hurtownia.ID_hurtowni = dostawa.ID_dostawa 
		GROUP BY magazyn.ID_magazynu, magazyn.dostêpne_miejsce 
		ORDER BY 'Iloœæ dostaw' DESC, 'Dostêpne miejsce' DESC;

/* 
	7. Wykaz zainteresowania produktami.
	Poni¿sze zapytanie s³u¿y w celach marketingowych. Pobrane dane wykazuj¹, które produkty ciesz¹ siê najwiêkszym zainteresowaniem. 
*/
SELECT	* FROM produkt 
		ORDER BY iloœæ_sprzedanych_artyku³ów DESC, nazwa ASC;

/* 
	8. Wykaz produków które zosta³y dostarczone do magazynu X w wybranym przedziale czasowym.
	Poni¿sze zapytanie pozwala oszacowaæ zapotrzebowanie na produkty w wybranym rejonie, zak³adaj¹c, ¿e produkty dostarczane s¹ do klientów z najbli¿szego mo¿liwego magazynu, który posiada zamawiane towary.
*/
SELECT	magazyn.ID_magazynu AS Magazyn, 
		dostawa.ID_dostawa AS 'Numer dostawy',
		dostawa.status_dostawa AS 'Status dostawy',
		dostawa.data_realizacji AS 'Data realizacji',
		pozycja_dostawy.iloœæ AS 'Iloœæ',
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