USE [Main]

-- 6. Использование CASE, PIVOT и UNPIVOT.

-- 6.1 Привести примеры получения сводных (итоговых) таблиц с использованием CASE

-- Категория цены продажи
SELECT id, price,
	CASE
		WHEN price < 600 THEN N'дешёвая'
		WHEN price BETWEEN 600 AND 900 THEN N'средняя'
		ELSE N'дорогая'
	END AS price_category
FROM Sale

-- Количество продаж по книгам и категориям цены
SELECT b.title,
	SUM(CASE WHEN s.price < 600 THEN s.[count] ELSE 0 END) AS cheap,
	SUM(CASE WHEN s.price BETWEEN 600 AND 900 THEN s.[count] ELSE 0 END) AS [medium],
	SUM(CASE WHEN s.price > 900 THEN s.[count] ELSE 0 END) AS expensive
FROM Book b
	LEFT JOIN Edition e ON e.book_code = b.code
	LEFT JOIN Sale s ON s.edition_id = e.id
GROUP BY b.title

-- 6.2 Привести примеры получения сводных (итоговых) таблиц с использованием PIVOT и UNPIVOT.

-- Кол-во книг по языкам
SELECT [русский], [английский], [испанский], [японский]
FROM (
	SELECT [language], 1 AS one
    FROM Book
) AS src
PIVOT (
    COUNT(one)
    FOR [language] IN ([русский], [английский], [испанский], [японский])
) AS pvt

-- Столбцы -> строки (из предыдущего)
SELECT [language], cnt
FROM (
    SELECT [русский], [английский], [испанский], [японский]
    FROM (
        SELECT [language], 1 AS one
        FROM Book
    ) AS src
    PIVOT (
        COUNT(one)
        FOR [language] IN ([русский], [английский], [испанский], [японский])
    ) AS pvt
) AS p
UNPIVOT (
    cnt FOR [language] IN ([русский], [английский], [испанский], [японский])
) AS unpvt