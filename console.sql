CREATE DATABASE javaguru;

CREATE SCHEMA library;

CREATE TABLE books
(
    id        bigserial PRIMARY KEY,
    title     varchar(80) NOT NULL,
    year      smallint,
    pages     smallint,
    author_id bigint REFERENCES authors (id) ON DELETE CASCADE
);

CREATE TABLE authors
(
    id      bigserial PRIMARY KEY,
    name    varchar(40) NOT NULL,
    surname varchar(40) NOT NULL
);

DROP TABLE authors CASCADE;
DROP TABLE books;

TRUNCATE TABLE authors CASCADE;
TRUNCATE TABLE books;

INSERT INTO authors (name, surname)
VALUES ('John', 'Doe'),
       ('Jane', 'Smith'),
       ('Michael', 'Johnson'),
       ('Emily', 'Brown'),
       ('David', 'Wilson'),
       ('Olivia', 'Jones'),
       ('James', 'Davis');

INSERT INTO books (title, year, pages, author_id)
VALUES ('The Amazing Gatsby', 1925, 180, 1),
       ('To Kill a Mocker', 1960, 281, 2),
       ('Nineteen Eighty-Five', 1949, 328, 3),
       ('Pride and Prejudgment', 1813, 279, 4),
       ('The Catcher in the Wheat', 1951, 234, 5),
       ('Henry Trotter and the Wizard''s Stone', 1997, 223, 6),
       ('The Lords of the Kingdoms', 1954, 1178, 7),
       ('The Little Hobbit', 1937, 310, 1),
       ('Moby-Docker', 1851, 585, 2),
       ('Brave Other World', 1932, 311, 3),
       ('The Chronicles of Fernia', 1950, 767, 4),
       ('To the Beach House', 1927, 209, 5),
       ('Frankenfriend', 1818, 280, 6),
       ('The Oddysey', 1950, 324, 7),
       ('The Picture of Dorian Grey', 1890, 254, 1);

-- 2. Выбрать название книги, год, ФИО автора отсортированные по году издания по убыванию
SELECT b.title, b.year, a.name || ' ' || a.surname AS fio
from books b
         JOIN authors a ON b.author_id = a.id
ORDER BY year DESC;

-- 3. Выбрать книги заданного автора по его имени и фамилии.
SELECT b.id, b.title, b.year, b.pages, a.name, a.surname
FROM books b
         JOIN authors a on b.author_id = a.id
WHERE a.name = 'Jane'
  AND a.surname = 'Smith';

-- 4. Выбрать книги у которых страниц больше чем среднее количество страниц у всех книг.
-- Дополнительный столбец для демонстрации
SELECT id, title, year, pages, (SELECT round(avg(pages)) as avg_pages from books)
from books
WHERE pages > (SELECT avg(pages) FROM books);

-- 5. Выбрать 3 самые старые книги и вывести суммарное количество страниц в этих книгах.
-- 5.1 Три самые старые книги
SELECT *
from books
ORDER BY year
LIMIT 3;

SELECT sum(t.pages)
from (SELECT pages
      from books
      ORDER BY year
      LIMIT 3) t;

-- 6. Написать запрос, изменяющий год издания на текущую дату для одной самой маленькой книги каждого автора.
-- 6.1 айди автора и количество страниц в его самой малой книге / книгах
SELECT author_id, min(pages)
from books
GROUP BY author_id;

UPDATE books b
SET year = date_part('Year', now())
FROM (SELECT author_id, min(pages) AS pages
      from books
      GROUP BY author_id) t
WHERE b.author_id = t.author_id
  AND b.pages = t.pages;

-- 7. Написать запрос, удаляющий автора, написавшего самую большую книгу.
-- 7.1 Находим автора с самой большой книгой
SELECT author_id
from authors a
         JOIN books b ON a.id = b.author_id
ORDER BY pages DESC
LIMIT 1;

-- 7.2 Проверяем все его книги
SELECT *
from books
where author_id = (SELECT author_id
                   from authors a
                            JOIN books b ON a.id = b.author_id
                   ORDER BY pages DESC
                   LIMIT 1);

-- 7.3 Удаляем эти книги
DELETE
from books
WHERE author_id = (SELECT author_id
            from authors a
                     JOIN books b ON a.id = b.author_id
            ORDER BY pages DESC
            LIMIT 1);