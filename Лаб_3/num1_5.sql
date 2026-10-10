USE [Main]

-- 5. Объдинение, пересечение, разность

-- 5.1 Привести примеры 3-4 запросов с использованием UNION / UNION ALL, EXCEPT, INTERSECT. 
-- Данные в одном из запросов отсортируйте по произвольному признаку.

-- Русские и английские книги (с сортировкой по названию)
SELECT code, title, N'русская' AS category 
FROM Book 
WHERE [language] = N'русский'
UNION
SELECT code, title, N'английская' 
FROM Book 
WHERE [language] = N'английский'
ORDER BY title

-- Книги на русском и книги до 1900 года (с дублями)
SELECT code, title
FROM Book 
WHERE [language] = N'русский'
UNION ALL
SELECT code, title
FROM Book 
WHERE year_published < 1900

-- Книги не с жанром "Фантастика"
SELECT code
FROM Book
EXCEPT
SELECT book_code
FROM Book_Genre bg
	JOIN Genre g ON g.id = bg.genre_id
WHERE g.[name] = N'Фантастика'

-- Книги с жанром "Классика" и "Роман"
SELECT book_code
FROM Book_Genre bg
    JOIN Genre g ON g.id = bg.genre_id
WHERE g.[name] = N'Роман'
INTERSECT
SELECT book_code FROM Book_Genre bg
    JOIN Genre g ON g.id = bg.genre_id
WHERE g.[name] = N'Классика'
ORDER BY book_code