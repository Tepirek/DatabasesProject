
USE shop;
DROP TABLE dost�pno��;
DROP TABLE pozycja_dostawy;
DROP TABLE dostawa;
DROP TABLE hurtownia;
DROP TABLE stan;
DROP TABLE pozycja_zam�wienia;
DROP TABLE zam�wienie;
DROP TABLE produkt;
DROP TABLE magazyn;
DROP TABLE klient;
DROP TABLE adres;

CREATE TABLE hurtownia (
	ID_hurtowni INT PRIMARY KEY IDENTITY(1, 1),
	/* hurtownia dostarcza produkty w konkretnym dniu tygodnia */
	dzie�_dostawa CHAR(255) CHECK(dzie�_dostawa IN('poniedzia�ek', 'wtorek', '�roda', 'czwartek', 'pi�tek', 'sobota', 'niedziela')),
	/* godziny wyjazdu w formacie HH:mm-HH:mm */
	godziny_wyjazdu CHAR(11) CHECK(godziny_wyjazdu LIKE '[0-2][0-9]:[0-5][0-9]-[0-2][0-9]:[0-5][0-9]'),
	/* ilo�� ci�ar�wek jakie posiada hurtownia, nie mo�e by� >= 0 */
	ilo��_ci�ar�wek INT CHECK(ilo��_ci�ar�wek >= 0)
);

CREATE TABLE produkt (
	ean CHAR(255) PRIMARY KEY CHECK(ean LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
	/* nazwa produktu musi rozpoczyna� si� wielk� liter� */
	nazwa CHAR(255) CHECK(nazwa LIKE '[A-Z]%'),
	/* ka�dy produkt musi mie� jaki� opis */
	opis TEXT NOT NULL,
	/* cena produktu w formacie do ________,__ */
	cena DECIMAL(10, 2) CHECK(cena >= 0),
	/* definiuje ile zosta�o sprzedanych dotychczas produkt�w, przydatne do promowania wybranych produkt�w, nie mo�e by� > 0 */
	ilo��_sprzedanych_artyku��w INT CHECK(ilo��_sprzedanych_artyku��w >= 0)
);

CREATE TABLE dost�pno�� (
	ID_dost�pno�� INT IDENTITY(1, 1) PRIMARY KEY,
	/* definiuje w kt�rej hurtowni dost�pny jest wybrany produkt */
	ID_hurtowni INT REFERENCES hurtownia(ID_hurtowni) ON DELETE CASCADE NOT NULL,
	/* definiuje w kt�rej hurtowni dost�pny jest wybrany produkt */
	ID_produktu CHAR(255) REFERENCES produkt(ean) ON UPDATE CASCADE ON DELETE CASCADE NOT NULL,
	/* okre�la czy hurtownia ma wybrany produkt na stanie */
	ilo�� INT CHECK(ilo�� >= 0),
	/* okre�la stan dost�pno�ci wybranego produktu w hurtowni, 'niedost�pny' != 0(ilo��) */
	warto��_dost�pno�� VARCHAR(16) CHECK(warto��_dost�pno�� IN('dost�pny', 'wkr�tce dost�pny', 'niedost�pny'))
);

CREATE TABLE adres (
	ID_adresu INT PRIMARY KEY IDENTITY(1, 1), 
	/* nazwa ulicy musi rozpoczyna� si� wielk� liter� lub cyfr� (adresy zagraniczne) */
	ulica CHAR(255) CHECK(ulica LIKE '[A-Z0-9]%'),
	/* budynek musi posiada� numer */
	nr_budynku CHAR(255) NOT NULL,
	/* dopuszcza si� brak numeru drzwi (adres jest adresem domu) */
	nr_drzwi INT,
	/* kod pocztowy jest wymagany, brak specyfikacji formatu polskiego kodu pocztowego [0-9][0-9]-[0-9][0-9][0-9], dopuszcza si� zagraniczne kody pocztowe */
	kod_pocztowy CHAR(255) NOT NULL,
	/* nazwa miasta nie mo�e by� pusta */
	miasto CHAR(255) CHECK(miasto LIKE '[A-Z]%'),
	/* nazwa kraju nie mo�e by� pusta */
	kraj CHAR(255) CHECK(kraj LIKE '[A-Z]%')
);

CREATE TABLE klient (
	ID_klienta INT PRIMARY KEY IDENTITY(1, 1),
	/* klient posiada adres wysy�kowy, dopuszcza si� brak adresu dla nowo utworzonego konta klienta */
	ID_adresu INT REFERENCES adres(ID_adresu) ON DELETE CASCADE,
	/* klient musi posiada� adres email potrzebny do logowania si� */
	adres_email CHAR(255) UNIQUE CHECK(adres_email LIKE '%[A-Za-z0-9][@][A-Za-z0-9]%[.][A-Za-z0-9]%'),
	/* imi� musi zaczyna� si� wielk� liter� */
	imie CHAR(255) CHECK(imie LIKE '[A-Z]%'),
	/* nazwisko musi zaczyna� si� wielk� liter� */
	nazwisko CHAR(255) CHECK(nazwisko LIKE '[A-Z]%'),
	/* data rejestracji konta klienta w systemie, przydatne do tworzenia indywidualnych kod�w rabatowych dla sta�ych klient�w */
	data_rejestracji DATE NOT NULL,
);

CREATE TABLE magazyn (
	ID_magazynu INT PRIMARY KEY IDENTITY(1, 1),
	/* wymagana jest lokalizacja magazynu */
	ID_adresu INT REFERENCES adres(ID_adresu) ON DELETE CASCADE NOT NULL,
	/* definiuje ilo�� wolnego miejsca w magazynie, nie mo�e by� > 0 */
	dost�pne_miejsce INT CHECK(dost�pne_miejsce >= 0),
	/* numer telefonu jest wymagany w formacie +48_________ gdzie _ to cyfra [0-9] */
	telefon CHAR(12) CHECK(telefon LIKE '+48[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
);

CREATE TABLE stan (
	ID_stanu INT PRIMARY KEY IDENTITY(1, 1),
	/* definiuje w kt�rym magazynie dost�pny jest wybrany produkt */
	ID_magazynu INT REFERENCES magazyn(ID_magazynu) ON DELETE CASCADE NOT NULL,
	/* definiuje w kt�rym magazynie dost�pny jest wybrany produkt */
	ID_produktu CHAR(255) REFERENCES produkt(ean) ON UPDATE CASCADE ON DELETE CASCADE NOT NULL,
	/* definiuje w jakiej ilo�ci wyst�puje dany produkt w wybranym magazynie */
	ilo�� INT NOT NULL,
	/* okre�la stan dost�pno�ci wybranego produktu w magazynie, 'niedost�pny' != 0(ilo��) */
	dost�pno�� VARCHAR(16) CHECK(dost�pno�� IN ('dost�pny', 'wkr�tce dost�pny', 'niedost�pny'))
); 

CREATE TABLE dostawa (
	ID_dostawa INT PRIMARY KEY IDENTITY(1, 1),
	/* definiuje do kt�rego magazynu ma dotrze� dostawa */
	ID_magazynu INT REFERENCES magazyn(ID_magazynu) ON DELETE CASCADE NOT NULL,
	/* definiuje z kt�rej hurtowni ma dotrze� dostawa */
	ID_hurtowni INT REFERENCES hurtownia(ID_hurtowni) NOT NULL,
	/* ��czna kwota dostawy, nie mo�e by� > 0 */
	kwota DECIMAL(10, 2) CHECK(kwota >= 0),
	/* definuje status dostarczenia dostawy */
	status_dostawa CHAR(13) CHECK(status_dostawa IN('przyj�to', 'jest pakowana', 'w drodze', 'dostarczono')),
	/* okre�la szacunkow� dat� dostawy dla 'przyj�to', 'jest pakowana', 'w drodze', dla 'dostarczono' okre�la kiedy dostawa dotar�a */
	data_realizacji DATE NOT NULL
);

CREATE TABLE zam�wienie (
	ID_zam�wienie INT PRIMARY KEY IDENTITY(1, 1),
	/* definiuje pod jaki adres ma dotrze� przesy�ka, dlatego nie mo�e by� NULL */
	ID_adresu INT REFERENCES adres(ID_adresu) ON DELETE CASCADE NOT NULL,
	/* okre�la dat� z�o�enia zam�wienia */
	data_zam�wienie DATE NOT NULL,
	/* ��czna kwota dostawy, nie mo�e by� > 0 */
	kwota DECIMAL(10, 2) CHECK(kwota >= 0),
	/* okre�la szacunkow� dat� dostawy dla 'przyj�to', 'jest pakowana', 'w drodze', dla 'dostarczono' okre�la kiedy przesy�ka dotar�a */
	data_dostawa DATE NOT NULL,
	/* definuje status dostarczenia przesy�ki */
	status_zam�wienie CHAR(255) CHECK(status_zam�wienie IN('przyj�to', 'jest pakowana', 'w drodze', 'dostarczono'))
);

CREATE TABLE pozycja_dostawy (
	ID_pozycji INT,
	/* definuje jaki produkt znajduje si� wewn�trz wybranej dostawy */
	ID_produktu CHAR(255) FOREIGN KEY REFERENCES produkt(ean) ON UPDATE CASCADE ON DELETE CASCADE NOT NULL,
	/* definiuje cz�ci� jakiej dostawy jest dana pozycja dostawy */
	ID_dostawa INT FOREIGN KEY REFERENCES dostawa(ID_dostawa) ON DELETE CASCADE NOT NULL,
	/* okre�la ile danego produktu ma zosta�/zosta�o dostarczone, nie mo�e by� > 0 */
	ilo�� INT CHECK(ilo�� >= 0),
	/* klucz z�o�ony, kt�ry pilnuje aby wybrane produkty wewn�trz danej dostawy by�y grupowane i nie wyst�powa�y osobno na wykazie dostawy */
	PRIMARY KEY(ID_pozycji, ID_dostawa, ID_produktu)
);

CREATE TABLE pozycja_zam�wienia (
	ID_pozycji INT,
	/* definuje jaki produkt znajduje si� wewn�trz wybranego zam�wienia */
	ID_produktu CHAR(255) FOREIGN KEY REFERENCES produkt(ean) ON UPDATE CASCADE ON DELETE CASCADE NOT NULL,
	/* definiuje cz�ci� jakiego zam�wienia jest dana pozycja zam�wienia */
	ID_zam�wienie INT FOREIGN KEY REFERENCES zam�wienie(ID_zam�wienie) ON DELETE CASCADE NOT NULL,
	/* okre�la ile danego produktu ma zosta�/zosta�o zam�wione, nie mo�e by� > 0 */
	ilo�� INT CHECK(ilo�� >= 0),
	/* klucz z�o�ony, kt�ry pilnuje aby wybrane produkty wewn�trz danego zam�wienia by�y grupowane i nie wyst�powa�y osobno na wykazie zam�wienia */
	PRIMARY KEY(ID_pozycji, ID_zam�wienie, ID_produktu)
);