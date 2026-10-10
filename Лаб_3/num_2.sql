USE [Main]

-- Часть 2

-- a) Выдать список книг Л.Н.Толстого, поступивших в продажу в годы его юбилеев (род. в 1828г.)

SELECT b.code, b.title, e.arrival_date, e.id AS edition_id
FROM Book b
	JOIN Book_Author ba ON b.code = ba.book_code
	JOIN Author a ON a.id = ba.author_id
	JOIN Edition e ON e.book_code = b.code
WHERE a.full_name = N'Лев Толстой'
	AND (YEAR(e.arrival_date) - 1828) % 10 = 0
	AND YEAR(e.arrival_date) > 1828
ORDER BY e.arrival_date

-- b) Найти наиболее популярные жанры за последний месяц 
-- (все тиражи, поступившие не более месяца назад, уже распроданы)

SELECT g.[name] AS genre,
    COUNT(DISTINCT e.id) AS editions_count,
    SUM(s.[count]) AS total_sold
FROM Genre g
    JOIN Book_Genre bg ON bg.genre_id = g.id
    JOIN Book b ON b.code = bg.book_code
    JOIN Edition e ON e.book_code = b.code
    JOIN Sale s ON s.edition_id = e.id
WHERE e.arrival_date >= DATEADD(
    MONTH, -1, (SELECT MAX([date]) FROM Sale)
)
GROUP BY g.id, g.[name]
HAVING NOT EXISTS (
    SELECT 1
    FROM Book_Genre bg2
        JOIN Edition e2 ON e2.book_code = bg2.book_code
        LEFT JOIN Sale s2 ON s2.edition_id = e2.id
    WHERE bg2.genre_id = g.id
        AND e2.arrival_date >= DATEADD(
        MONTH, -1, (SELECT MAX([date]) FROM Sale)
    )
    GROUP BY e2.id, e2.[count]
    HAVING ISNULL(SUM(s2.[count]), 0) < e2.[count]
)
ORDER BY total_sold DESC

-- c) Найти тиражи книг с минимальной и максимальной
-- торговой наценкой (вывести: книга, номер тиража, издательство, наценка)

WITH EditionMarkup AS (
    SELECT b.title,
        e.id AS edition_id,
        p.[name] AS publisher,
        (AVG(s.price) - e.purchase_price) / e.purchase_price * 100 AS markup
    FROM Edition e
        JOIN Book b ON b.code = e.book_code
        JOIN Publisher p ON p.id = e.publisher_id
        JOIN Sale s ON s.edition_id = e.id
    GROUP BY b.title, e.id, p.[name], e.purchase_price
)
SELECT *
FROM EditionMarkup
WHERE markup = (SELECT MIN(markup) FROM EditionMarkup)
    OR markup = (SELECT MAX(markup) FROM EditionMarkup)
ORDER BY markup DESC

-- d) Определить убыточные тиражи, поступившие более года назад (издательство, книга, номер тиража, убыток)

WITH EditionProfit AS (
    SELECT b.title AS book,
        p.[name] AS publisher,
        e.id AS edition_id,
        e.purchase_price * e.[count] - ISNULL(SUM(s.[count] * s.price * (1 - s.discount/100.0)), 0) AS loss
    FROM Edition e
        JOIN Book b ON b.code = e.book_code
        JOIN Publisher p ON p.id = e.publisher_id
        LEFT JOIN Sale s ON s.edition_id = e.id
    WHERE e.arrival_date < DATEADD(YEAR, -1, (SELECT MAX([date]) FROM Sale))
    GROUP BY b.title, e.id, p.[name], e.purchase_price, e.[count]
)
SELECT book, edition_id, publisher,
    CAST(loss AS DECIMAL(10,2)) AS loss
FROM EditionProfit
WHERE loss > 0
ORDER BY loss DESC

-- e) Найти самую продаваемую книгу (наибольшее кол-во проданных экземпляров во всех тиражах)

SELECT /* TOP 1 */ b.code, b.title, ISNULL(SUM(s.[count]), 0) AS total_sold
FROM Book b
    LEFT JOIN Edition e ON e.book_code = b.code
    LEFT JOIN Sale s ON s.edition_id = e.id
GROUP BY b.code, b.title
ORDER BY total_sold DESC