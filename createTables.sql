
USE shop;
DROP TABLE dostêpnoœæ;
DROP TABLE pozycja_dostawy;
DROP TABLE dostawa;
DROP TABLE hurtownia;
DROP TABLE stan;
DROP TABLE pozycja_zamówienia;
DROP TABLE zamówienie;
DROP TABLE produkt;
DROP TABLE magazyn;
DROP TABLE klient;
DROP TABLE adres;

CREATE TABLE hurtownia (
	ID_hurtowni INT PRIMARY KEY IDENTITY(1, 1),
	/* hurtownia dostarcza produkty w konkretnym dniu tygodnia */
	dzieñ_dostawa CHAR(255) CHECK(dzieñ_dostawa IN('poniedzia³ek', 'wtorek', 'œroda', 'czwartek', 'pi¹tek', 'sobota', 'niedziela')),
	/* godziny wyjazdu w formacie HH:mm-HH:mm */
	godziny_wyjazdu CHAR(11) CHECK(godziny_wyjazdu LIKE '[0-2][0-9]:[0-5][0-9]-[0-2][0-9]:[0-5][0-9]'),
	/* iloœæ ciê¿arówek jakie posiada hurtownia, nie mo¿e byæ >= 0 */
	iloœæ_ciê¿arówek INT CHECK(iloœæ_ciê¿arówek >= 0)
);

CREATE TABLE produkt (
	ean CHAR(255) PRIMARY KEY CHECK(ean LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
	/* nazwa produktu musi rozpoczynaæ siê wielk¹ liter¹ */
	nazwa CHAR(255) CHECK(nazwa LIKE '[A-Z]%'),
	/* ka¿dy produkt musi mieæ jakiœ opis */
	opis TEXT NOT NULL,
	/* cena produktu w formacie do ________,__ */
	cena DECIMAL(10, 2) CHECK(cena >= 0),
	/* definiuje ile zosta³o sprzedanych dotychczas produktów, przydatne do promowania wybranych produktów, nie mo¿e byæ > 0 */
	iloœæ_sprzedanych_artyku³ów INT CHECK(iloœæ_sprzedanych_artyku³ów >= 0)
);

CREATE TABLE dostêpnoœæ (
	ID_dostêpnoœæ INT IDENTITY(1, 1) PRIMARY KEY,
	/* definiuje w której hurtowni dostêpny jest wybrany produkt */
	ID_hurtowni INT REFERENCES hurtownia(ID_hurtowni) ON DELETE CASCADE NOT NULL,
	/* definiuje w której hurtowni dostêpny jest wybrany produkt */
	ID_produktu CHAR(255) REFERENCES produkt(ean) ON UPDATE CASCADE ON DELETE CASCADE NOT NULL,
	/* okreœla czy hurtownia ma wybrany produkt na stanie */
	iloœæ INT CHECK(iloœæ >= 0),
	/* okreœla stan dostêpnoœci wybranego produktu w hurtowni, 'niedostêpny' != 0(iloœæ) */
	wartoœæ_dostêpnoœæ VARCHAR(16) CHECK(wartoœæ_dostêpnoœæ IN('dostêpny', 'wkrótce dostêpny', 'niedostêpny'))
);

CREATE TABLE adres (
	ID_adresu INT PRIMARY KEY IDENTITY(1, 1), 
	/* nazwa ulicy musi rozpoczynaæ siê wielk¹ liter¹ lub cyfr¹ (adresy zagraniczne) */
	ulica CHAR(255) CHECK(ulica LIKE '[A-Z0-9]%'),
	/* budynek musi posiadaæ numer */
	nr_budynku CHAR(255) NOT NULL,
	/* dopuszcza siê brak numeru drzwi (adres jest adresem domu) */
	nr_drzwi INT,
	/* kod pocztowy jest wymagany, brak specyfikacji formatu polskiego kodu pocztowego [0-9][0-9]-[0-9][0-9][0-9], dopuszcza siê zagraniczne kody pocztowe */
	kod_pocztowy CHAR(255) NOT NULL,
	/* nazwa miasta nie mo¿e byæ pusta */
	miasto CHAR(255) CHECK(miasto LIKE '[A-Z]%'),
	/* nazwa kraju nie mo¿e byæ pusta */
	kraj CHAR(255) CHECK(kraj LIKE '[A-Z]%')
);

CREATE TABLE klient (
	ID_klienta INT PRIMARY KEY IDENTITY(1, 1),
	/* klient posiada adres wysy³kowy, dopuszcza siê brak adresu dla nowo utworzonego konta klienta */
	ID_adresu INT REFERENCES adres(ID_adresu) ON DELETE CASCADE,
	/* klient musi posiadaæ adres email potrzebny do logowania siê */
	adres_email CHAR(255) UNIQUE CHECK(adres_email LIKE '%[A-Za-z0-9][@][A-Za-z0-9]%[.][A-Za-z0-9]%'),
	/* imiê musi zaczynaæ siê wielk¹ liter¹ */
	imie CHAR(255) CHECK(imie LIKE '[A-Z]%'),
	/* nazwisko musi zaczynaæ siê wielk¹ liter¹ */
	nazwisko CHAR(255) CHECK(nazwisko LIKE '[A-Z]%'),
	/* data rejestracji konta klienta w systemie, przydatne do tworzenia indywidualnych kodów rabatowych dla sta³ych klientów */
	data_rejestracji DATE NOT NULL,
);

CREATE TABLE magazyn (
	ID_magazynu INT PRIMARY KEY IDENTITY(1, 1),
	/* wymagana jest lokalizacja magazynu */
	ID_adresu INT REFERENCES adres(ID_adresu) ON DELETE CASCADE NOT NULL,
	/* definiuje iloœæ wolnego miejsca w magazynie, nie mo¿e byæ > 0 */
	dostêpne_miejsce INT CHECK(dostêpne_miejsce >= 0),
	/* numer telefonu jest wymagany w formacie +48_________ gdzie _ to cyfra [0-9] */
	telefon CHAR(12) CHECK(telefon LIKE '+48[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
);

CREATE TABLE stan (
	ID_stanu INT PRIMARY KEY IDENTITY(1, 1),
	/* definiuje w którym magazynie dostêpny jest wybrany produkt */
	ID_magazynu INT REFERENCES magazyn(ID_magazynu) ON DELETE CASCADE NOT NULL,
	/* definiuje w którym magazynie dostêpny jest wybrany produkt */
	ID_produktu CHAR(255) REFERENCES produkt(ean) ON UPDATE CASCADE ON DELETE CASCADE NOT NULL,
	/* definiuje w jakiej iloœci wystêpuje dany produkt w wybranym magazynie */
	iloœæ INT NOT NULL,
	/* okreœla stan dostêpnoœci wybranego produktu w magazynie, 'niedostêpny' != 0(iloœæ) */
	dostêpnoœæ VARCHAR(16) CHECK(dostêpnoœæ IN ('dostêpny', 'wkrótce dostêpny', 'niedostêpny'))
); 

CREATE TABLE dostawa (
	ID_dostawa INT PRIMARY KEY IDENTITY(1, 1),
	/* definiuje do którego magazynu ma dotrzeæ dostawa */
	ID_magazynu INT REFERENCES magazyn(ID_magazynu) ON DELETE CASCADE NOT NULL,
	/* definiuje z której hurtowni ma dotrzeæ dostawa */
	ID_hurtowni INT REFERENCES hurtownia(ID_hurtowni) NOT NULL,
	/* ³¹czna kwota dostawy, nie mo¿e byæ > 0 */
	kwota DECIMAL(10, 2) CHECK(kwota >= 0),
	/* definuje status dostarczenia dostawy */
	status_dostawa CHAR(13) CHECK(status_dostawa IN('przyjêto', 'jest pakowana', 'w drodze', 'dostarczono')),
	/* okreœla szacunkow¹ datê dostawy dla 'przyjêto', 'jest pakowana', 'w drodze', dla 'dostarczono' okreœla kiedy dostawa dotar³a */
	data_realizacji DATE NOT NULL
);

CREATE TABLE zamówienie (
	ID_zamówienie INT PRIMARY KEY IDENTITY(1, 1),
	/* definiuje pod jaki adres ma dotrzeæ przesy³ka, dlatego nie mo¿e byæ NULL */
	ID_adresu INT REFERENCES adres(ID_adresu) ON DELETE CASCADE NOT NULL,
	/* okreœla datê z³o¿enia zamówienia */
	data_zamówienie DATE NOT NULL,
	/* ³¹czna kwota dostawy, nie mo¿e byæ > 0 */
	kwota DECIMAL(10, 2) CHECK(kwota >= 0),
	/* okreœla szacunkow¹ datê dostawy dla 'przyjêto', 'jest pakowana', 'w drodze', dla 'dostarczono' okreœla kiedy przesy³ka dotar³a */
	data_dostawa DATE NOT NULL,
	/* definuje status dostarczenia przesy³ki */
	status_zamówienie CHAR(255) CHECK(status_zamówienie IN('przyjêto', 'jest pakowana', 'w drodze', 'dostarczono'))
);

CREATE TABLE pozycja_dostawy (
	ID_pozycji INT,
	/* definuje jaki produkt znajduje siê wewn¹trz wybranej dostawy */
	ID_produktu CHAR(255) FOREIGN KEY REFERENCES produkt(ean) ON UPDATE CASCADE ON DELETE CASCADE NOT NULL,
	/* definiuje czêœci¹ jakiej dostawy jest dana pozycja dostawy */
	ID_dostawa INT FOREIGN KEY REFERENCES dostawa(ID_dostawa) ON DELETE CASCADE NOT NULL,
	/* okreœla ile danego produktu ma zostaæ/zosta³o dostarczone, nie mo¿e byæ > 0 */
	iloœæ INT CHECK(iloœæ >= 0),
	/* klucz z³o¿ony, który pilnuje aby wybrane produkty wewn¹trz danej dostawy by³y grupowane i nie wystêpowa³y osobno na wykazie dostawy */
	PRIMARY KEY(ID_pozycji, ID_dostawa, ID_produktu)
);

CREATE TABLE pozycja_zamówienia (
	ID_pozycji INT,
	/* definuje jaki produkt znajduje siê wewn¹trz wybranego zamówienia */
	ID_produktu CHAR(255) FOREIGN KEY REFERENCES produkt(ean) ON UPDATE CASCADE ON DELETE CASCADE NOT NULL,
	/* definiuje czêœci¹ jakiego zamówienia jest dana pozycja zamówienia */
	ID_zamówienie INT FOREIGN KEY REFERENCES zamówienie(ID_zamówienie) ON DELETE CASCADE NOT NULL,
	/* okreœla ile danego produktu ma zostaæ/zosta³o zamówione, nie mo¿e byæ > 0 */
	iloœæ INT CHECK(iloœæ >= 0),
	/* klucz z³o¿ony, który pilnuje aby wybrane produkty wewn¹trz danego zamówienia by³y grupowane i nie wystêpowa³y osobno na wykazie zamówienia */
	PRIMARY KEY(ID_pozycji, ID_zamówienie, ID_produktu)
);