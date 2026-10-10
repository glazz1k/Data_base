USE [Main]

-- 1. Выборка из одной таблицы.

-- 1.1 Выбрать из произвольной таблицы данные и отсортировать их по двум 
-- произвольным имеющимся в таблице признакам (разные направления сортировки).

-- Сортировка по году (убывание) и названию (возрастание)
SELECT title, year_published, [language]
FROM Book
ORDER BY year_published DESC, title ASC

-- 1.2 Выбрать из произвольной таблицы те записи, которые удовлетворяют
-- условию отбора (where). Привести 2-3 запроса.

-- Книги на русском языке
SELECT title, [language]
FROM Book
WHERE [language] = N'русский'

-- Продажи с ценой > 900 и скидкой > 0
SELECT id, price, [count], discount
FROM Sale
WHERE price > 900 AND discount > 0

-- Авторы, род. в 19 веке
SELECT full_name, birthday_date
FROM Author
WHERE birthday_date BETWEEN '1800-01-01' AND '1899-12-31'

-- 1.3 Привести примеры 2-3 запросов с использованием агрегатных функций
-- (count, max, sum и др.) с группировкой и без группировки. 

-- Статистика продаж без группировки (общая)
SELECT COUNT(*) AS total_sold,
	SUM([count]) AS sold_books_count,
	AVG(price) AS avg_price,
	MAX(price) AS max_price,
	MIN(price) AS min_price
FROM Sale

-- Статистика продаж с группировкой (по каждому тиражу)
SELECT edition_id,
	COUNT(*) AS total_sold,
	SUM([count]) AS sold_books_count,
	AVG(price) AS avg_price,
	MAX(price) AS max_price,
	MIN(price) AS min_price
FROM Sale
GROUP BY edition_id

-- 1.4  Привести примеры подведения подытога с использованием
-- GROUP BY [ALL] [ CUBE | ROLLUP](2-3 запроса). В ROLLUP и CUBE использовать не менее 2-х столбцов.

-- ROLLUP по продажам (подытоги по тиражам + общий итог)
SELECT edition_id,
	discount,
	COUNT(*) AS total_sold,
	SUM([count]) AS sold_books_count,
	SUM([count] * price) AS total_price
FROM Sale
GROUP BY ROLLUP (edition_id, discount)

-- CUBE по тиражам (подытоги по издательствам / книгам + общий итог)
SELECT book_code,
	publisher_id,
	COUNT(*) AS editions_count,
	SUM([count]) AS books_count
FROM Edition
GROUP BY CUBE (book_code, publisher_id)

-- 1.5 Выбрать из таблиц информацию об объектах,
-- в названиях которых нет заданной последовательности букв (LIKE).

-- Названия книг, в которых нет буквосочетания "ст"
SELECT code, title
FROM Book
WHERE title NOT LIKE N'%ст%'

-- Названия книг, в которых есть буквосочетание "ст"
SELECT code, title
FROM Book
WHERE title LIKE N'%ст%'