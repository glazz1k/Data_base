USE [Main]

-- 2. Выборка из нескольких таблиц.

/* 
2.1 Вывести информацию подчиненной (дочерней) таблицы, заменяя коды
(значения внешних ключей) соответствующими символьными значениями из
родительских таблиц. Привести 2-3 запроса с использованием классического
подхода соединения таблиц (where).
*/

-- Тираж + книга + издательство
SELECT e.id, e.arrival_date, e.[count],
	b.title,
	p.[name] AS publisher
FROM Edition e, Book b, Publisher p
WHERE e.book_code = b.code
	AND e.publisher_id = p.id

-- Продажи + тираж + книга
SELECT s.id, s.[date], b.title, s.[count], s.price, s.discount
FROM Sale s, Edition e, Book b
WHERE s.edition_id = e.id
	AND e.book_code = b.code
ORDER BY s.[date]

-- 2.2. Реализовать запросы пункта 2.1 через внутреннее соединение inner join

-- Тираж + книга + издательство
SELECT e.id, e.arrival_date, e.[count],
	b.title,
	p.[name] AS publisher
FROM Edition e 
	INNER JOIN Book b ON e.book_code = b.code
	INNER JOIN Publisher p ON e.publisher_id = p.id

-- Продажи + тираж + книга
SELECT s.id, s.[date], b.title, s.[count], s.price, s.discount
FROM Sale s
	INNER JOIN Edition e ON s.edition_id = e.id
	INNER JOIN Book b ON e.book_code = b.code
ORDER BY s.[date];

-- 2.3. Левое внешнее соединение left join. Привести 2-3 запроса

-- Все книги, даже без тиражей
SELECT b.code, b.title,
	e.id AS edition_id,
	e.arrival_date,
	e.[count]
FROM Book b LEFT JOIN Edition e ON b.code = e.book_code

-- Все тиражи, даже без продаж
SELECT e.id AS edition_id, 
    s.id AS sale_id, 
	s.price, s.[count], s.[date]
FROM Edition e LEFT JOIN Sale s ON e.id = s.edition_id

-- 2.4. Правое внешнее соединение right join. Привести 2-3 запроса

-- Все книги, даже без тиражей
SELECT b.code, b.title,
	e.id AS edition_id,
	e.arrival_date,
	e.[count]
FROM Edition e RIGHT JOIN Book b ON b.code = e.book_code

-- Все тиражи, даже без продаж
SELECT e.id AS edition_id, 
    s.id AS sale_id, 
	s.price, s.[count], s.[date]
FROM Sale s RIGHT JOIN Edition e ON e.id = s.edition_id

-- 2.5. Привести примеры 2-3 запросов с использованием агрегатных функций
-- и группировки

-- Продажи по книгам
SELECT b.code, b.title,
	COUNT(s.id) AS sales_count,
	SUM(s.[count]) AS sold_books_count,
	SUM(s.[count] * s.price) AS total_price
FROM Book b
	LEFT JOIN Edition e ON b.code = e.book_code
	LEFT JOIN Sale s ON s.edition_id = e.id
GROUP BY b.code, b.title

-- Автор и кол-во книг у него
SELECT a.full_name,
	COUNT(ba.book_code) AS books_count
FROM Author a
	JOIN Book_Author ba ON a.id = ba.author_id
GROUP BY a.full_name
ORDER BY books_count DESC

-- 2.6. Привести примеры 2-3 запросов с использованием
-- группировки и условия отбора групп (Having)

-- Книги с более 30 проданными экземплярами
SELECT b.code, b.title, SUM(s.[count]) AS sold_books_count
FROM Book b
	JOIN Edition e ON b.code = e.book_code
	JOIN Sale s ON s.edition_id = e.id
GROUP BY b.code, b.title
HAVING SUM(s.[count]) > 30
ORDER BY sold_books_count DESC

-- Издательства с более чем одним тиражом
SELECT p.[name], COUNT(e.id) AS editions_count
FROM Edition e JOIN Publisher p ON e.publisher_id = p.id
GROUP BY p.[name]
HAVING COUNT(e.id) > 1
ORDER BY editions_count DESC

-- 2.7. Привести примеры 3-4 вложенных 
-- (соотнесенных, c использованием IN, EXISTS) запросов.

-- Книги жанра "Фантастика"
SELECT code, title
FROM Book
WHERE code IN (
	SELECT bg.book_code
	FROM Book_Genre bg
		JOIN Genre g ON bg.genre_id = g.id
	WHERE g.[name] = N'Фантастика'
)

-- Книги, у которых есть продажи
SELECT b.code, b.title
FROM Book b
WHERE EXISTS (
	SELECT 1
	FROM Edition e
		JOIN Sale s ON e.id = s.edition_id
	WHERE e.book_code = b.code
)

-- Книги, у которых нет продаж
SELECT b.code, b.title
FROM Book b
WHERE NOT EXISTS (
	SELECT 1
	FROM Edition e
		JOIN Sale s ON e.id = s.edition_id
	WHERE e.book_code = b.code
)