
--VARCHAR CHAR	1 byte per tecken, 256 kombinationer
--Unicode
--NVARCHAR NCHAR 2 byte per tecken 256 x256 ~65.000 kombinationer

CREATE TABLE sprak
(
namn	VARCHAR(50)
)

INSERT INTO sprak VALUES ('Україна')
SELECT * FROM sprak--???????

DROP TABLE IF EXISTS sprak
CREATE TABLE sprak
(
namn	NVARCHAR(50)
)

INSERT INTO sprak VALUES (N'Україна')--Konvertera till unicode
SELECT * FROM sprak--Україна
