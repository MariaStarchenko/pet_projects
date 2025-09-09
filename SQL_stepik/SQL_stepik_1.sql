1. База данных "Продажи книг"



1.1 Таблица (создание, добавление строк)


-- Создать таблицу book

CREATE TABLE book(
    book_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(50),
    author VARCHAR(30),
    price DECIMAL(8, 2),
    amount INT
    );


-- Добавить в конец таблицы book строку со значениями

INSERT INTO book (title, author, price, amount)
VALUES ('Мастер и Маргарита', 'Булгаков М.А.', 670.99, 3)


-- Добавить в конец таблицы book несколько строк со значениями

INSERT INTO book (title, author, price, amount)
VALUES 
('Белая гвардия', 'Булгаков М.А.', 540.50, 5),
('Идиот', 'Достоевский Ф.М.', 460.00, 10),
('Братья Карамазовы', 'Достоевский Ф.М.', 799.01, 2);



1.2 Выборка данных

-- Выбрать все строки и столбцы из таблицы

SELECT * FROM book;

-- Выбрать конкретные столбцы из таблицы

SELECT author, title, price FROM book;

-- Выбрать конкретные столбцы и заменить их названия при выводе

SELECT title AS Название, author AS Автор
FROM book;

/*Можно опустить alias (псевдоним) и всё равно всё будет работать*/

SELECT title Название, author Автор
FROM book;

-- Выбрать конкретные столбцы и добавить новый расчетный столбец

SELECT title, amount,
    amount * 1.65 AS pack
FROM book;

/*В конце года цену каждой книги на складе пересчитывают – снижают ее на 30%. Написать SQL запрос, который из таблицы book выбирает 
названия, авторов, количества и вычисляет новые цены книг. Столбец с новой ценой назвать new_price, цену округлить до 2-х знаков после запятой*/

SELECT title,
    author,
    amount,
    ROUND((price - price * 0.3), 2) AS new_price
FROM book;

/*При анализе продаж книг выяснилось, что наибольшей популярностью пользуются книги Михаила Булгакова, на втором месте книги Сергея Есенина. 
Исходя из этого решили поднять цену книг Булгакова на 10%, а цену книг Есенина - на 5%. Написать запрос, куда включить автора, название книги и новую цену, 
последний столбец назвать new_price. Значение округлить до двух знаков после запятой*/

SELECT author, title,
    ROUND(
        IF(author='Булгаков М.А.', price * 1.1,
            IF(author='Есенин С.А.', price * 1.05, price))
    ,2) AS new_price
FROM book;

-- Выбрать строки из таблицы с условием WHERE

SELECT author, title, price
FROM book
WHERE amount < 10; 

/*Вывести название, автора,  цену  и количество всех книг, цена которых меньше 500 или больше 600, 
а стоимость всех экземпляров этих книг больше или равна 5000.*/

SELECT title, author, price, amount
FROM book
WHERE (price NOT BETWEEN 500 AND 600) AND (price * amount >= 5000)

/*Вывести название и авторов тех книг, цены которых принадлежат интервалу от 540.50 до 800 (включая границы),  а количество или 2, или 3, или 5, или 7 .*/

SELECT title, author
FROM book
WHERE (price BETWEEN 540.50 AND 800) AND (amount IN (2, 3, 5, 7));

/* Вывести  автора и название  книг, количество которых принадлежит интервалу от 2 до 14 (включая границы). Информацию  отсортировать сначала по авторам 
(в обратном алфавитном порядке), а затем по названиям книг (по алфавиту).*/

SELECT author, title
FROM book
WHERE amount BETWEEN 2 AND 14
ORDER BY author DESC, title

-- Вывести название и автора тех книг, название которых состоит из двух и более слов, а инициалы автора содержат букву «С».

SELECT title, author
FROM book
WHERE (title LIKE '_% %_') AND (author LIKE '% _.С.' OR author LIKE '% С._.') 
ORDER BY title



1.3 Запросы, групповые операции

-- Отобрать уникальные элементы столбца amount таблицы book.

SELECT DISTINCT amount
FROM book;

/*Тоже отбираем уникальные значения, но через GROUP BY*/

SELECT amount
FROM book
GROUP BY amount;

/*Посчитать, количество различных книг и количество экземпляров книг каждого автора , хранящихся на складе.  
Столбцы назвать Автор, Различных_книг и Количество_экземпляров соответственно.*/

SELECT author AS Автор,
    COUNT(DISTINCT title) AS Различных_книг,
    SUM(amount) AS Количество_экземпляров
FROM book
GROUP BY author;

/*Вывести фамилию и инициалы автора, минимальную, максимальную и среднюю цену книг каждого автора . 
Вычисляемые столбцы назвать Минимальная_цена, Максимальная_цена и Средняя_цена соответственно.*/

SELECT author,
    MIN(price) AS Минимальная_цена,
    MAX(price) AS Максимальная_цена,
    AVG(price) AS Средняя_цена
FROM book
GROUP BY author

/*Для каждого автора вычислить суммарную стоимость книг S (имя столбца Стоимость), а также вычислить налог на добавленную стоимость  
для полученных сумм (имя столбца НДС ) , который включен в стоимость и составляет 18% (k=18),  а также стоимость книг  (Стоимость_без_НДС) без него. 
Значения округлить до двух знаков после запятой.*/

SELECT author,
    ROUND(SUM(price * amount), 2) AS Стоимость,
    ROUND(SUM(price * amount) * 18 / 118, 2) AS НДС,
    ROUND(SUM(price * amount) / 1.18, 2) AS Стоимость_без_НДС   
FROM book
GROUP BY author

/*Вывести цену самой дешевой книги, цену самой дорогой и среднюю цену всех книг на складе. Названия столбцов Минимальная_цена, 
Максимальная_цена, Средняя_цена соответственно. Среднюю цену округлить до двух знаков после запятой.*/

SELECT MIN(price) AS Минимальная_цена,
    MAX(price) AS Максимальная_цена,
    ROUND(AVG(price), 2) AS Средняя_цена
FROM book;

/*Вычислить среднюю цену и суммарную стоимость тех книг, количество экземпляров которых принадлежит интервалу от 5 до 14, включительно. 
Столбцы назвать Средняя_цена и Стоимость, значения округлить до 2-х знаков после запятой.*/

SELECT 
    ROUND(AVG(price), 2) AS Средняя_цена,
    ROUND(SUM(price * amount), 2) AS Стоимость
FROM book
WHERE amount BETWEEN 5 AND 14;

/*Посчитать стоимость всех экземпляров каждого автора без учета книг «Идиот» и «Белая гвардия». В результат включить только тех авторов, 
у которых суммарная стоимость книг (без учета книг «Идиот» и «Белая гвардия») более 5000 руб. Вычисляемый столбец назвать Стоимость. 
Результат отсортировать по убыванию стоимости.*/

SELECT author, 
    SUM(price * amount) AS Стоимость
FROM book
WHERE title <> 'Идиот' AND title <> 'Белая гвардия'
GROUP BY author
HAVING SUM(price * amount) > 5000
ORDER BY Стоимость DESC;


1.4 Вложенные запросы


1. Вложенный запрос, возвращающий одно значение

/*Вывести информацию о самых дешевых книгах, хранящихся на складе.*/

SELECT title, author, price, amount
FROM book
WHERE price = (
         SELECT MIN(price) 
         FROM book
      );

/*Вывести информацию (автора, название и цену) о  книгах, цены которых меньше или равны средней цене книг на складе. 
Информацию вывести в отсортированном по убыванию цены виде. Среднее вычислить как среднее по цене книги.*/

SELECT author, title, price
FROM book
-- Вложенный запрос (отбираем среднюю цену книги, которая становится условием для основного запроса)
WHERE price <= (
    SELECT AVG(price)
    FROM book
    )
ORDER BY price DESC;


2. Использование вложенного запроса в выражении

/*Вывести информацию о книгах, количество экземпляров которых отличается от среднего количества экземпляров книг на складе более чем на 3. 
То есть нужно вывести и те книги, количество экземпляров которых меньше среднего на 3, или больше среднего на 3.*/

SELECT title, author, amount 
FROM book
WHERE ABS(amount - (SELECT AVG(amount) FROM book)) >3;

/*Вывести информацию (автора, название и цену) о тех книгах, цены которых превышают минимальную цену книги на складе не более чем на 150 рублей 
в отсортированном по возрастанию цены виде.*/

SELECT author, title, price
FROM book
WHERE price - (SELECT MIN(price) FROM book) <= 150
ORDER BY price;


3. Вложенный запрос, оператор IN

/*Вывести информацию о книгах тех авторов, общее количество экземпляров книг которых не менее 12.*/

SELECT title, author, amount, price
FROM book
WHERE author IN (
        SELECT author 
        FROM book 
        GROUP BY author 
        HAVING SUM(amount) >= 12
      );

/*Вывести информацию (автора, книгу и количество) о тех книгах, количество экземпляров которых в таблице book не дублируется.*/

SELECT author, title, amount
FROM book
WHERE amount IN (
        SELECT amount
        FROM book
        GROUP BY amount
        HAVING COUNT(author) = 1
    );


4. Вложенный запрос, операторы ANY и ALL

/*Вывести информацию о тех книгах, количество которых меньше самого маленького среднего количества книг каждого автора.*/

SELECT title, author, amount, price
FROM book
WHERE amount < ALL (
        SELECT AVG(amount) 
        FROM book 
        GROUP BY author 
      );

/*Вывести информацию о тех книгах, количество которых меньше самого большого среднего количества книг каждого автора.*/

SELECT title, author, amount, price
FROM book
WHERE amount < ANY (
        SELECT AVG(amount) 
        FROM book 
        GROUP BY author 
      );

/*Вывести информацию о книгах(автор, название, цена), цена которых меньше самой большой из минимальных цен, вычисленных для каждого автора.*/

SELECT author, title, price
FROM book
WHERE price < ANY(
        SELECT MIN(price)
        FROM book
        GROUP BY author
    )


5. Вложенный запрос после SELECT

/*Вывести информацию о книгах, количество экземпляров которых отличается от среднего количества экземпляров книг на складе более чем на 3,  
а также указать среднее значение количества экземпляров книг.*/

SELECT title, author, amount, 
    (
     SELECT AVG(amount) 
     FROM book
    ) AS Среднее_количество 
FROM book
WHERE abs(amount - (SELECT AVG(amount) FROM book)) >3;

/*Посчитать сколько и каких экземпляров книг нужно заказать поставщикам, чтобы на складе стало одинаковое количество экземпляров каждой книги, 
равное значению самого большего количества экземпляров одной книги на складе. Вывести название книги, ее автора, текущее количество экземпляров на складе 
и количество заказываемых экземпляров книг. Последнему столбцу присвоить имя Заказ. В результат не включать книги, которые заказывать не нужно.*/

SELECT title, author, amount,
    ((SELECT MAX(amount) FROM book) - amount) AS Заказ
FROM book
WHERE amount < (SELECT MAX(amount) FROM book)


1.5 Запросы корректировки данных


1. Создать таблицу supply

CREATE TABLE supply (
    supply_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(50),
    author VARCHAR(30),
    price DECIMAL (8,2),
    amount INT
);


2. Внести в таблицу supply значения

INSERT INTO supply (title, author, price, amount)
VALUES 
    ('Лирика', 'Пастернак Б.Л.', 518.99, 2),
    ('Черный человек', 'Есенин С.А.', 570.20, 6),
    ('Белая гвардия', 'Булгаков М.А.', 540.50, 7),
    ('Идиот', 'Достоевский Ф.М.', 360.80, 3);


3. Добавление записей из другой таблицы

/*Добавить из таблицы supply в таблицу book, все книги, кроме книг, написанных Булгаковым М.А. и Достоевским Ф.М.*/

INSERT INTO book (title, author, price, amount)
SELECT title, author, price, amount
FROM supply
WHERE author NOT IN ('Булгаков М.А.', 'Достоевский Ф.М.');


4. Добавление записей, вложенные запросы

/*Занести из таблицы supply в таблицу book только те книги, авторов которых нет в  book.*/

INSERT INTO book (title, author, price, amount)
SELECT title, author, price, amount
FROM supply
WHERE author NOT IN (
            SELECT DISTINCT author
            FROM book
            );


5. Заросы на обновление

-- Уменьшить на 30% цену книг в таблице book.

UPDATE book 
SET price = 0.7 * price;

-- Уменьшить на 30% цену тех книг в таблице book, количество которых меньше 5.

UPDATE book 
SET price = 0.7 * price 
WHERE amount < 5;

-- Уменьшить на 10% цену тех книг в таблице book, количество которых принадлежит интервалу от 5 до 10, включая границы.

UPDATE book
SET price = price - price * 0.10
WHERE amount BETWEEN 5 AND 10;


6. Запросы на обновление нескольких столбцов

/*В столбце buy покупатель указывает количество книг, которые он хочет приобрести. Для каждой книги, выбранной покупателем, необходимо уменьшить ее 
количество на складе на указанное в столбцеbuy количество, а в столбец buy занести 0.*/

UPDATE book 
SET amount = amount - buy,
    buy = 0;

/*В таблице book необходимо скорректировать значение для покупателя в столбце buy таким образом, чтобы оно не превышало количество экземпляров книг, 
указанных в столбце amount. А цену тех книг, которые покупатель не заказывал, снизить на 10%.*/

UPDATE book
SET buy = (IF(buy > amount, amount, buy)),
    price = (IF(buy = 0, price * 0.9, price));


7. Запросы на обновление нескольких таблиц

/*Если в таблице supply  есть те же книги, что и в таблице book, добавлять эти книги в таблицу book не имеет смысла. 
Необходимо увеличить их количество на значение столбца amountтаблицы supply.*/

UPDATE book, supply 
SET book.amount = book.amount + supply.amount
WHERE book.title = supply.title AND book.author = supply.author;

/*Для тех книг в таблице book , которые есть в таблице supply, не только увеличить их количество в таблице book ( увеличить их количество
на значение столбца amountтаблицы supply), но и пересчитать их цену (для каждой книги найти сумму цен из таблиц book и supply и разделить на 2).*/

UPDATE book, supply
SET book.amount = book.amount + supply.amount,
    book.price = (book.price + supply.price) / 2
WHERE book.title = supply.title AND book.author = supply.author;


8. Запросы на удаление

-- Удалить из таблицы supply все книги, названия которых есть в таблице book.

DELETE FROM supply 
WHERE title IN (
        SELECT title 
        FROM book
      );

-- Удалить из таблицы supply книги тех авторов, общее количество экземпляров книг которых в таблице book превышает 10.

DELETE FROM supply
WHERE author IN (
    SELECT author
    FROM book
    GROUP BY author
    HAVING SUM(amount) > 10
    );


9. Запросы на создание таблиц

/*Создать таблицу заказ (ordering), куда включить авторов и названия тех книг, количество экземпляров которых в таблице book меньше 4. 
Для всех книг указать одинаковое количество экземпляров 5.*/

CREATE TABLE ordering AS
SELECT author, title, 5 AS amount
FROM book
WHERE amount < 4;

/*Создать таблицу заказ (ordering), куда включить авторов и названия тех книг, количество экземпляров которых в таблице book меньше 4. 
Для всех книг указать одинаковое значение - среднее количество экземпляров книг в таблице book.*/

CREATE TABLE ordering AS
SELECT author, title, 
   (
    SELECT ROUND(AVG(amount)) 
    FROM book
   ) AS amount
FROM book
WHERE amount < 4;

/*Создать таблицу заказ (ordering), куда включить авторов и названия тех книг, количество экземпляров которых в таблице book меньше среднего 
количества экземпляров книг в таблице book. В таблицу включить столбец   amount, в котором для всех книг указать одинаковое 
значение - среднее количество экземпляров книг в таблице book.*/

CREATE TABLE ordering AS
SELECT author, title,
    (
    SELECT ROUND(AVG(amount))
    FROM book
    ) AS amount
FROM book
WHERE amount < (
    SELECT (ROUND(AVG(amount)))
    FROM book
    );



1.6 Таблица "Командировки", запросы на выборку


1.
/*Вывести из таблицы trip информацию о командировках тех сотрудников, фамилия которых заканчивается на букву «а», 
в отсортированном по убыванию даты последнего дня командировки виде. В результат включить столбцы name, city, per_diem, date_first, date_last.*/

SELECT name, city, per_diem, date_first, date_last
FROM trip
WHERE name LIKE '%а %'
ORDER BY date_last DESC;

/*Вывести в алфавитном порядке фамилии и инициалы тех сотрудников, которые были в командировке в Москве.*/

SELECT DISTINCT name
FROM trip
WHERE city = 'Москва'
ORDER BY name;

/*Для каждого города посчитать, сколько раз сотрудники в нем были.  Информацию вывести в отсортированном в алфавитном порядке по названию городов. 
Вычисляемый столбец назвать Количество. */

SELECT city,
    COUNT(name) AS Количество
FROM trip
GROUP BY city
ORDER BY city;


2. Оператор LIMIT

-- Вывести информацию о первой  командировке из таблицы trip. "Первой" считать командировку с самой ранней датой начала.

SELECT *
FROM trip
ORDER BY  date_first
LIMIT 1;


-- Вывести два города, в которых чаще всего были в командировках сотрудники. Вычисляемый столбец назвать Количество.

SELECT city,
    COUNT(name) AS Количество
FROM trip
GROUP BY city
ORDER BY Количество DESC
LIMIT 2;


/*Вывести информацию о командировках во все города кроме Москвы и Санкт-Петербурга (фамилии и инициалы сотрудников, город ,  длительность командировки 
в днях, при этом первый и последний день относится к периоду командировки). Последний столбец назвать Длительность. Информацию вывести в упорядоченном 
по убыванию длительности поездки, а потом по убыванию названий городов (в обратном алфавитном порядке).*/

SELECT name, city,
    DATEDIFF(date_last, date_first) + 1 AS Длительность
FROM trip
WHERE city NOT IN ('Москва', 'Санкт-Петербург')
ORDER BY Длительность DESC, city DESC;


/*Вывести информацию о командировках сотрудника(ов), которые были самыми короткими по времени. В результат включить столбцы name, city, date_first, date_last.*/

SELECT name, city, date_first, date_last
FROM trip
WHERE DATEDIFF(date_last, date_first) IN (
    SELECT MIN(DATEDIFF(date_last, date_first))
    FROM trip
);


/*Вывести информацию о командировках, начало и конец которых относятся к одному месяцу (год может быть любой). 
В результат включить столбцы name, city, date_first, date_last. Строки отсортировать сначала  в алфавитном порядке по названию города,
 а затем по фамилии сотрудника .*/

-- MONTH('2020-04-12')=4 возвращает из даты номер месяца

SELECT name, city, date_first, date_last
FROM trip
WHERE MONTH(date_first) = MONTH(date_last)
ORDER BY city, name;


/*Вывести название месяца и количество командировок для каждого месяца. Считаем, что командировка относится к некоторому месяцу, 
если она началась в этом месяце. Информацию вывести сначала в отсортированном по убыванию количества, а потом в алфавитном порядке по названию месяца виде. 
Название столбцов – Месяц и Количество.*/

-- MONTHNAME('2020-04-12')='April' возвращает из даты название месяца

SELECT MONTHNAME(date_first) AS Месяц,
    COUNT(name) AS Количество
FROM trip
GROUP BY MONTHNAME(date_first)
ORDER BY Количество DESC, Месяц;


/*Вывести сумму суточных (произведение количества дней командировки и размера суточных) для командировок, первый день которых пришелся на февраль 
или март 2020 года. Значение суточных для каждой командировки занесено в столбец per_diem. Вывести фамилию и инициалы сотрудника, город, первый день 
командировки и сумму суточных. Последний столбец назвать Сумма. Информацию отсортировать сначала  в алфавитном порядке по фамилиям сотрудников, 
а затем по убыванию суммы суточных.*/

SELECT name, city, date_first,
    per_diem * (DATEDIFF(date_last, date_first) + 1) AS Сумма
FROM trip
WHERE (MONTH(date_first) = 2 OR MONTH(date_first) = 3) AND (YEAR(date_first) = 2020) 
ORDER BY name, Сумма DESC;


-- То же самое, но по-другому WHERE

SELECT name, city, date_first,
    per_diem * (DATEDIFF(date_last, date_first) + 1) AS Сумма
FROM trip
WHERE (MONTHNAME(date_first) IN ('February', 'March')) AND (YEAR(date_first) = 2020) -- WHERE date_first LIKE '2020-02-%' OR date_first LIKE '2020-03-%'
ORDER BY name, Сумма DESC; 


/*Вывести фамилию с инициалами и общую сумму суточных, полученных за все командировки для тех сотрудников, которые были в командировках больше 
чем 3 раза, в отсортированном по убыванию сумм суточных виде. Последний столбец назвать Сумма.*/

SELECT name,
    SUM(per_diem * (DATEDIFF(date_last, date_first) + 1)) AS Сумма
FROM trip
GROUP BY name
HAVING COUNT(name) > 3
ORDER BY Сумма Desc;



1.7 Таблица "Нарушения ПДД", запросы корректировки


-- Создать таблицу fine следующей структуры

CREATE TABLE fine (
    fine_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(30),
    number_plate VARCHAR(6),
    violation VARCHAR(50),
    sum_fine DECIMAL(8, 2),
    date_violation DATE,
    date_payment DATE
);


-- Добавить в таблицу fine записи.

INSERT INTO fine (name, number_plate, violation, date_violation)
VALUES 
('Баранов П.Е.', 'Р523ВТ', 'Превышение скорости(от 40 до 60)', '2020-02-14'),
('Абрамова К.А.', 'О111АВ', 'Проезд на запрещающий сигнал', '2020-02-23'),
('Яковлев Г.Р.', 'Т330ТТ', 'Проезд на запрещающий сигнал', '2020-03-03');


/*Занести в таблицу fine суммы штрафов, которые должен оплатить водитель, в соответствии с данными из таблицы traffic_violation. 
При этом суммы заносить только в пустые поля столбца  sum_fine.*/

UPDATE fine AS f, traffic_violation AS tr
SET f.sum_fine = tr.sum_fine
WHERE (f.sum_fine IS NULL) AND (f.violation = tr.violation);


/*Вывести фамилию, номер машины и нарушение только для тех водителей, которые на одной машине нарушили одно и то же правило   два и более раз. 
При этом учитывать все нарушения, независимо от того оплачены они или нет. Информацию отсортировать в алфавитном порядке, 
сначала по фамилии водителя, потом по номеру машины и, наконец, по нарушению.*/

SELECT name, number_plate, violation
FROM fine
GROUP BY name, number_plate, violation
HAVING COUNT(*) >= 2
ORDER BY name, number_plate, violation;


/*В таблице fine увеличить в два раза сумму неоплаченных штрафов для отобранных на предыдущем шаге записей*/

UPDATE fine,
    (
      SELECT name, number_plate, violation    -- Вложенный запрос, который отбирает водителей, у которых 2 и более одинаковых нарушений
      FROM fine
      GROUP BY name, number_plate, violation
      HAVING COUNT(*) >= 2
      ORDER BY name, number_plate, violation
    ) query_in      -- Отобранные записи используются, как новая таблица с названием query_in
SET fine.sum_fine = fine.sum_fine * 2
WHERE (fine.date_payment IS NULL) AND (fine.name = query_in.name) AND (fine.number_plate = query_in.number_plate);

SELECT * FROM fine;


/*в таблицу fine занести дату оплаты соответствующего штрафа из таблицы payment; 
уменьшить начисленный штраф в таблице fine в два раза  (только для тех штрафов, информация о которых занесена в таблицу payment) , 
если оплата произведена не позднее 20 дней со дня нарушения.*/

UPDATE 
    fine f, payment p   -- Используем алиасы
SET 
    f.date_payment = p.date_payment,
    f.sum_fine = IF(DATEDIFF(p.date_payment, p.date_violation) <= 20, f.sum_fine / 2, f.sum_fine) 
WHERE (f.date_payment IS NULL)
        AND (f.name = p.name)
        AND (f.number_plate = p.number_plate)   -- Сопоставляем значения из таблицы fine  с таблицей payment
        AND (f.violation = p.violation);

SELECT * FROM fine;


/*Создать новую таблицу back_payment, куда внести информацию о неоплаченных штрафах (Фамилию и инициалы водителя, номер машины, 
нарушение, сумму штрафа  и  дату нарушения) из таблицы fine.*/

CREATE TABLE back_payment AS
SELECT name, number_plate, violation, sum_fine, date_violation
FROM fine
WHERE date_payment IS NULL;


/*Удалить из таблицы fine информацию о нарушениях, совершенных раньше 1 февраля 2020 года. */

DELETE FROM fine
WHERE date_violation < '2020-02-01';