USE [Main]
GO

IF OBJECT_ID('SalesView', 'V') IS NOT NULL DROP VIEW SalesView
IF OBJECT_ID('EditionsView', 'V') IS NOT NULL DROP VIEW EditionsView
GO

-- 3. Представления

-- 3.1  На основе любых запросов из п. 2 создать два представления (VIEW).

-- Продажи с книгами
CREATE VIEW SalesView AS
SELECT s.id AS sale_id,
	s.[date] AS sale_date,
	b.code AS book_code,
    b.title AS book_title,
    s.[count] AS [count],
    s.price,
    s.discount,
    s.[count] * s.price * (1 - s.discount/100.0) AS total_cost
FROM Sale s
	JOIN Edition e ON e.id = s.edition_id
	JOIN Book b ON b.code = e.book_code
GO

-- Тиражи с книгами и издательством
CREATE VIEW EditionsView AS
SELECT e.id AS edition_id,
    e.arrival_date,
    e.[count] AS [count],
    e.purchase_price,
    b.code AS book_code,
    b.title AS book_title,
    p.[name] AS publisher
FROM Edition e
    JOIN Book b ON e.book_code = b.code
    JOIN Publisher p ON e.publisher_id = p.id
GO

SELECT * FROM SalesView;
SELECT * FROM EditionsView;

-- 3.2  Привести примеры использования общетабличных выражений (СТЕ) (2-3 запроса)

-- Книги с более чем 20 продажами
WITH BookSales AS (
    SELECT b.code, b.title, SUM(s.[count]) AS sold
    FROM Book b
        JOIN Edition e ON e.book_code = b.code
        JOIN Sale s ON s.edition_id = e.id
    GROUP BY b.code, b.title
)
SELECT * FROM BookSales
WHERE sold > 20
ORDER BY sold DESC

-- Книги, выпущенные после 1900 года
WITH NewerBooks AS (
    SELECT code, title, year_published
    FROM Book
    WHERE year_published > 1900
)
SELECT * FROM NewerBooks
ORDER BY year_published

-- Продажи со скидкой
WITH SalesWithDiscount AS (
    SELECT id, [date], [count], price, discount
    FROM Sale
    WHERE discount > 0
)
SELECT * FROM SalesWithDiscount
ORDER BY discount DESC