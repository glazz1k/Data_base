USE [Main]

-- 4. Функции ранжирования

-- 4.1 Привести примеры 3-4 запросов с использованием ROW_NUMBER, RANK, DENSE_RANK (c  PARTITION BY и без)

-- Нумерация продаж по дате
SELECT id, [date], [count], price,
	ROW_NUMBER() OVER (ORDER BY [date]) AS sale_num
FROM Sale

-- Рейтинг книг по продажам
SELECT b.title,
    SUM(s.[count]) AS sold,
    RANK() OVER (ORDER BY SUM(s.[count]) DESC) AS rnk
FROM Book b
    LEFT JOIN Edition e ON e.book_code = b.code
    LEFT JOIN Sale s ON s.edition_id = e.id
GROUP BY b.title

-- Рейтинг кол-ва продаж внутри тиража
SELECT edition_id, id, [date], [count],
    DENSE_RANK() OVER (PARTITION BY edition_id ORDER BY [count] DESC) AS rnk
FROM Sale

-- Нумерация тиражей внутри книги
SELECT book_code, id, arrival_date,
    ROW_NUMBER() OVER (PARTITION BY book_code ORDER BY arrival_date) AS edition_num
FROM Edition