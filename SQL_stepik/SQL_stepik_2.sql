2. База данных "Продажи книг"


2.1 Связи между таблицами


1.Создать таблицу author следующей структуры

CREATE TABLE author (
    author_id INT PRIMARY KEY AUTO_INCREMENT,
    name_author VARCHAR(50)
    );


2. Заполнить таблицу author

INSERT INTO author (name_author)
VALUES 
    ('Булгаков М.А.'), 
    ('Достоевский Ф.М.'), 
    ('Есенин С.А.'), 
    ('Пастернак Б.Л.');


3. Создание таблицы с внешними ключами

-- Создать таблицу book следующей структуры

CREATE TABLE book (
    book_id INT PRIMARY KEY AUTO_INCREMENT, 
    title VARCHAR(50), 
    author_id INT NOT NULL, 
    genre_id INT,
    price DECIMAL(8,2), 
    amount INT, 
    FOREIGN KEY (author_id)  REFERENCES author (author_id),
    FOREIGN KEY (genre_id) REFERENCES genre (genre_id)
);

-- Посмотреть, какие есть столбцы в таблице
DESCRIBE book; 
-- или вот так
SHOW COLUMNS FROM book;


4. Действия при удалении записи главной таблицы

/*С помощью выражения ON DELETE можно установить действия, которые выполняются для записей подчиненной таблицы 
при удалении связанной строки из главной таблицы. При удалении можно установить следующие опции:

*CASCADE: автоматически удаляет строки из зависимой таблицы при удалении  связанных строк в главной таблице.
*SET NULL: при удалении  связанной строки из главной таблицы устанавливает для столбца внешнего ключа значение NULL. 
(В этом случае столбец внешнего ключа должен поддерживать установку NULL).
*SET DEFAULT похоже на SET NULL за тем исключением, что значение  внешнего ключа устанавливается не в NULL, а в значение по умолчанию 
для данного столбца.
*RESTRICT: отклоняет удаление строк в главной таблице при наличии связанных строк в зависимой таблице.*/ 

CREATE TABLE book (
    book_id INT PRIMARY KEY AUTO_INCREMENT, 
    title VARCHAR(50), 
    author_id INT NOT NULL, 
    genre_id INT,
    price DECIMAL(8,2), 
    amount INT, 
    FOREIGN KEY (author_id)  REFERENCES author (author_id) ON DELETE CASCADE,
    FOREIGN KEY (genre_id) REFERENCES genre (genre_id) ON DELETE SET NULL
);


-- Добавьте записи в таблицу book

INSERT INTO book (title, author_id, genre_id, price, amount)
VALUES
    ('Стихотворения и поэмы', 3, 2, 650.00, 15),
    ('Черный человек', 3, 2, 570.20, 6),
    ('Лирика', 4, 2, 518.99, 2);



2.2 Запросы на выборку, соединение таблиц


1. Соединение INNER JOIN

-- Вывести название, жанр и цену тех книг, количество которых больше 8, в отсортированном по убыванию цены виде.

SELECT title, name_genre, price
FROM
    book b INNER JOIN genre g
    ON g.genre_id = b.genre_id
WHERE amount > 8
ORDER BY price DESC;


2. Внешнее соединение LEFT и RIGHT OUTER JOIN

-- Вывести все жанры, которые не представлены в книгах на складе.

SELECT name_genre
FROM
    genre g LEFT JOIN book b
    ON g.genre_id = b.genre_id
WHERE b.genre_id IS NULL;


3. Перекрестное соединение CROSS JOIN

/*Необходимо в каждом городе провести выставку книг каждого автора в течение 2020 года. Дату проведения выставки выбрать случайным образом. 
Создать запрос, который выведет город, автора и дату проведения выставки. Последний столбец назвать Дата. 
Информацию вывести, отсортировав сначала в алфавитном порядке по названиям городов, а потом по убыванию дат проведения выставок.*/

SELECT name_city, name_author,
    DATE_ADD('2020-01-01', INTERVAL (FLOOR(RAND() * 365)) DAY) AS Дата
FROM city CROSS JOIN author
ORDER BY name_city, Дата DESC;


4. Запросы на выборку из нескольких таблиц

/*Вывести информацию о книгах (жанр, книга, автор), относящихся к жанру, включающему слово «роман» в отсортированном по названиям книг виде.*/

SELECT name_genre, title, name_author
FROM genre g
     INNER JOIN book b ON g.genre_id = b.genre_id
     INNER JOIN author a ON b.author_id = a.author_id 
WHERE g.name_genre = 'Роман'
ORDER BY title;


5. Запросы для нескольких таблиц с группировкой

/*Посчитать количество экземпляров  книг каждого автора из таблицы author.  Вывести тех авторов,  количество книг которых меньше 10, 
в отсортированном по возрастанию количества виде. Последний столбец назвать Количество.*/

SELECT name_author, SUM(amount) AS Количество
FROM author a LEFT JOIN book b
    ON a.author_id = b.author_id
GROUP BY name_author
HAVING SUM(amount) < 10 OR SUM(amount) IS NULL
ORDER BY Количество;


6. Запросы для нескольких таблиц со вложенными запросами

/*Вывести в алфавитном порядке всех авторов, которые пишут только в одном жанре*/

SELECT name_author, Количество
FROM author a INNER JOIN (
        SELECT author_id, COUNT(DISTINCT genre_id) AS Количество
        FROM book
        GROUP BY author_id
        ) query_in 
    ON a.author_id = query_in.author_id
WHERE Количество = 1
ORDER BY name_author;

-- Другой вариант решения

SELECT name_author
FROM author
WHERE author_id IN (
    SELECT author_id     -- Отбираем из таблицы query_in только author_id
    FROM (
        SELECT author_id, COUNT(DISTINCT genre_id) AS Количество
        FROM book
        GROUP BY author_id
        ) query_in            -- Получаем таблицу с author_id и количеством жанров, в котором он пишет
    WHERE Количество = 1
    )
ORDER BY name_author;


7. Вложенные запросы в операторах соединения

/*Вывести информацию о книгах (название книги, фамилию и инициалы автора, название жанра, цену и количество экземпляров книги), 
написанных в самых популярных жанрах, в отсортированном в алфавитном порядке по названию книг виде. 
Самым популярным считать жанр, общее количество экземпляров книг которого на складе максимально.*/

SELECT  title, name_author, name_genre, price, amount
FROM 
    author 
    INNER JOIN book ON author.author_id = book.author_id
    INNER JOIN genre ON  book.genre_id = genre.genre_id
WHERE
    genre.genre_id IN
         (/* выбираем автора, если он пишет книги в самых популярных жанрах*/
          SELECT query_in_1.genre_id
          FROM 
              ( /* выбираем код жанра и количество произведений, относящихся к нему */
                SELECT genre_id, SUM(amount) AS sum_amount
                FROM book
                GROUP BY genre_id
               )query_in_1
          INNER JOIN 
              ( /* выбираем запись, в которой указан код жанр с максимальным количеством книг */
                SELECT genre_id, SUM(amount) AS sum_amount
                FROM book
                GROUP BY genre_id
                ORDER BY sum_amount DESC
                LIMIT 1
               ) query_in_2
          ON query_in_1.sum_amount = query_in_2.sum_amount
         )
ORDER BY title; 


8. Операция соединение, использование USING()

/*Если в таблицах supply  и book есть одинаковые книги, которые имеют равную цену,  вывести их название и автора, а также посчитать 
общее количество экземпляров книг в таблицах supply и book,  столбцы назвать Название, Автор  и Количество.*/

SELECT s.title Название, 
    a.name_author Автор, 
    b.amount + s.amount AS Количество
FROM author a
    INNER JOIN book b USING (author_id)
    INNER JOIN supply s ON b.price = s.price AND 
                           b.title = s.title AND
                           a.name_author = s.author;




2.3 Запросы корректировки, соединение таблиц 

1. Запросы на обновление, связанные таблицы

/*Для книг, которые уже есть на складе (в таблице book), но по другой цене, чем в поставке (supply),  необходимо в таблице book 
увеличить количество на значение, указанное в поставке,  и пересчитать цену. А в таблице  supply обнулить количество этих книг.*/

UPDATE book b
    INNER JOIN author a USING (author_id)
    INNER JOIN supply s ON b.title = s.title AND a.name_author = s.author AND b.price <> s.price
SET b.price = (b.price * b.amount + s.price * s.amount) / (b.amount + s.amount),
    b.amount = b.amount + s.amount,
    s.amount = 0;


2. Запросы на добавление, связанные таблицы

/*Включить новых авторов в таблицу author с помощью запроса на добавление, а затем вывести все данные из таблицы author.  
Новыми считаются авторы, которые есть в таблице supply, но нет в таблице author.*/

INSERT INTO author (name_author)
SELECT author
FROM supply s
    LEFT JOIN author a ON s.author = a.name_author
WHERE a.name_author IS NULL;


3. Запрос на добавление, связанные таблицы

-- Добавить новые книги из таблицы supply в таблицу book на основе сформированного выше запроса.

INSERT INTO book (title, author_id, price, amount)
SELECT title, author_id, price, amount
FROM supply s
    INNER JOIN author a ON s.author = a.name_author
WHERE amount <> 0;


4. Запрос на обновление, вложенные запросы

/* Занести для книги «Стихотворения и поэмы» Лермонтова жанр «Поэзия», а для книги «Остров сокровищ» Стивенсона - «Приключения».*/
-- Решение двумя отдельными запросами

UPDATE book
SET genre_id = 
    (SELECT genre_id FROM genre WHERE name_genre = 'Поэзия')
WHERE title = 'Стихотворения и поэмы';

UPDATE book
SET genre_id = 
    (SELECT genre_id FROM genre WHERE name_genre = 'Приключения')
WHERE title = 'Остров сокровищ';

-- Решение одним запросом

UPDATE book b
INNER JOIN author a USING (author_id)
SET b.genre_id = (
    SELECT g.genre_id
    FROM genre g
    WHERE g.name_genre = CASE
          WHEN b.title = 'Стихотворения и поэмы' AND a.name_author LIKE 'Лермонтов%' THEN 'Поэзия'
          WHEN b.title = 'Остров сокровищ' AND a.name_author LIKE 'Стивенсон%' THEN 'Приключения'
          END)
WHERE a.name_author LIKE 'Лермонтов%' OR a.name_author LIKE 'Стивенсон%';

SELECT * FROM book;


5. Каскадное удаление записей связанных таблиц

/*Удалить всех авторов и все их книги, общее количество книг которых меньше 20.*/

DELETE FROM author
WHERE author_id IN (
    SELECT author_id
    FROM book
    GROUP BY author_id
    HAVING SUM(amount) < 20
);


6. Удаление записей главной таблицы с сохранением записей в зависимой

-- Удалить все жанры, к которым относится меньше 4-х наименований книг. В таблице book для этих жанров установить значение Null.

DELETE FROM genre
WHERE genre_id IN (
    SELECT genre_id
    FROM book
    GROUP BY genre_id
    HAVING COUNT(title) < 4
    );


7. Удаление записей, использование связанных таблиц

/*Удалить всех авторов, которые пишут в жанре "Поэзия". Из таблицы book удалить все книги этих авторов. 
В запросе для отбора авторов использовать полное название жанра, а не его id.*/

DELETE FROM author
USING author
    INNER JOIN book USING (author_id)
    INNER JOIN genre USING (genre_id)
WHERE name_genre = 'Поэзия';

-- Другой вариант решения

DELETE FROM author
USING author
    INNER JOIN book USING (author_id)
WHERE genre_id = (
    SELECT genre_id
    FROM genre
    WHERE name_genre = 'Поэзия'
    );



2.4 База данных «Интернет-магазин книг», запросы на выборку

1. Запросы на основе трех и более связанных таблиц

/*Вывести все заказы Баранова Павла (id заказа, какие книги, по какой цене и в каком количестве он заказал) в отсортированном 
по номеру заказа и названиям книг виде.*/

SELECT buy.buy_id, title, price, buy_book.amount
FROM buy
    INNER JOIN client ON buy.client_id = client.client_id
    INNER JOIN buy_book ON buy.buy_id = buy_book.buy_id
    INNER JOIN book ON buy_book.book_id = book.book_id
WHERE client.name_client = 'Баранов Павел'
ORDER BY buy_id, title;


2. /*Посчитать, сколько раз была заказана каждая книга, для книги вывести ее автора (нужно посчитать, в каком количестве заказов 
фигурирует каждая книга).  Вывести фамилию и инициалы автора, название книги, последний столбец назвать Количество. 
Результат отсортировать сначала  по фамилиям авторов, а потом по названиям книг.*/

SELECT name_author, title, COUNT(buy_book.book_id) Количество
FROM book
    INNER JOIN author USING (author_id)
    LEFT JOIN buy_book USING (book_id)
GROUP BY book.title, name_author
ORDER BY name_author, title;


3. /*Вывести города, в которых живут клиенты, оформлявшие заказы в интернет-магазине. Указать количество заказов в каждый город, 
этот столбец назвать Количество. Информацию вывести по убыванию количества заказов, а затем в алфавитном порядке по названию городов.*/

SELECT name_city, COUNT(buy_id) Количество
FROM city
      INNER JOIN client ON city.city_id = client.city_id
      INNER JOIN buy ON client.client_id = buy.client_id
GROUP BY name_city
ORDER BY Количество DESC, name_city;


4.-- Вывести номера всех оплаченных заказов и даты, когда они были оплачены.

SELECT buy_id, date_step_end
FROM step
    INNER JOIN buy_step ON step.step_id = buy_step.step_id
WHERE name_step = 'Оплата' AND date_step_end IS NOT NULL;


5. /*Вывести информацию о каждом заказе: его номер, кто его сформировал (фамилия пользователя) и его стоимость (сумма произведений 
количества заказанных книг и их цены), в отсортированном по номеру заказа виде. Последний столбец назвать Стоимость.*/

SELECT buy_book.buy_id, name_client,
    SUM(buy_book.amount * query_1.price) Стоимость
FROM buy
    INNER JOIN client ON buy.client_id = client.client_id
    INNER JOIN buy_book ON buy.buy_id = buy_book.buy_id
    INNER JOIN (
        SELECT book_id, price
        FROM book
        ) query_1 ON buy_book.book_id = query_1.book_id
GROUP BY buy_book.buy_id
ORDER BY buy_id;

-- Другой вариант решения

SELECT buy_book.buy_id, name_client, 
	SUM(buy_book.amount * book.price) AS Стоимость
FROM buy
    INNER JOIN client ON buy.client_id = client.client_id
    INNER JOIN buy_book ON buy.buy_id = buy_book.buy_id
    INNER JOIN book ON book.book_id = buy_book.book_id
GROUP BY buy.buy_id;


6. /*Вывести номера заказов (buy_id) и названия этапов,  на которых они в данный момент находятся. Если заказ доставлен –  информацию 
о нем не выводить. Информацию отсортировать по возрастанию buy_id.*/

SELECT buy_id, name_step
FROM buy_step
    INNER JOIN step USING(step_id)
WHERE date_step_beg IS NOT NULL AND date_step_end IS NULL
ORDER BY buy_id;


7./*В таблице city для каждого города указано количество дней, за которые заказ может быть доставлен в этот город (рассматривается только этап 
Транспортировка). Для тех заказов, которые прошли этап транспортировки, вывести количество дней за которое заказ реально доставлен в город. 
А также, если заказ доставлен с опозданием, указать количество дней задержки, в противном случае вывести 0. В результат включить номер заказа 
(buy_id), а также вычисляемые столбцы Количество_дней и Опоздание. Информацию вывести в отсортированном по номеру заказа виде.*/

SELECT buy.buy_id,
    DATEDIFF(date_step_end, date_step_beg) Количество_дней,
    IF(days_delivery < (DATEDIFF(date_step_end, date_step_beg)), 
          (ABS((days_delivery - (DATEDIFF(date_step_end, date_step_beg))))), 0) Опоздание     
FROM city
    INNER JOIN client USING (city_id)
    INNER JOIN buy USING (client_id)
    INNER JOIN buy_step USING (buy_id)
    INNER JOIN step USING (step_id)
WHERE name_step = 'Транспортировка' AND date_step_end IS NOT NULL
ORDER BY buy.buy_id;

-- Другой вариант решения. GREATEST() - возвраащет наибольшее из значений в скобках

SELECT
    buy_id,
    DATEDIFF(date_step_end, date_step_beg) AS Количество_дней,
    GREATEST(DATEDIFF(date_step_end, date_step_beg) - days_delivery, 0) AS Опоздание
FROM city
    INNER JOIN client USING (city_id)
    INNER JOIN buy USING (client_id)
    INNER JOIN buy_step USING (buy_id)
    INNER JOIN step USING (step_id)
WHERE 
	name_step = 'Транспортировка' AND date_step_end IS NOT NULL
ORDER BY buy.buy_id;


8./*Выбрать всех клиентов, которые заказывали книги Достоевского, информацию вывести в отсортированном по алфавиту виде. 
В решении используйте фамилию автора, а не его id.*/

SELECT DISTINCT name_client
FROM author a
    INNER JOIN book b ON a.author_id = b.author_id AND name_author LIKE 'Достоевский%'
    INNER JOIN buy_book bb ON b.book_id = bb.book_id
    INNER JOIN buy ON bb.buy_id = buy.buy_id
    INNER JOIN client c ON buy.client_id = c.client_id
ORDER BY name_client;


9. /*Вывести жанр (или жанры), в котором было заказано больше всего экземпляров книг, указать это количество. Последний столбец 
назвать Количество.*/

SELECT 
  name_genre, 
  SUM(buy_book.amount) Количество 
FROM 
  genre 
  INNER JOIN book USING (genre_id) 
  INNER JOIN buy_book USING (book_id) 
GROUP BY 
  name_genre 
HAVING 
  Количество = (
    SELECT 
      MAX(sum_amount) 
    FROM 
      (
        SELECT 
          SUM(buy_book.amount) AS sum_amount 
        FROM 
          buy_book 
          INNER JOIN book USING (book_id) 
        GROUP BY 
          genre_id
      ) query_in
  );


10. Оператор UNION

-- Вывести всех клиентов, которые делали заказы или в этом, или в предыдущем году.
-- С UNION клиенты будут выведены без повторений:

  SELECT name_client
FROM 
    buy_archive
    INNER JOIN client USING(client_id)
UNION
SELECT name_client
FROM 
    buy 
    INNER JOIN client USING(client_id)


-- C UNION ALL будут выведены клиенты с повторением (для тех, кто заказывал книги в обоих годах, а также несколько раз в одном году)

SELECT name_client
FROM 
    buy_archive
    INNER JOIN client USING(client_id)
UNION ALL
SELECT name_client
FROM 
    buy 
    INNER JOIN client USING(client_id)


-- Вывести информацию об оплаченных заказах за предыдущий и текущий год, информацию отсортировать по  client_id.

SELECT buy_id, client_id, book_id, date_payment, amount, price
FROM 
    buy_archive
UNION ALL
SELECT buy.buy_id, client_id, book_id, date_step_end, buy_book.amount, price
FROM 
    book 
    INNER JOIN buy_book USING(book_id)
    INNER JOIN buy USING(buy_id) 
    INNER JOIN buy_step USING(buy_id)
    INNER JOIN step USING(step_id)                  
WHERE  date_step_end IS NOT Null and name_step = "Оплата" 


/*Сравнить ежемесячную выручку от продажи книг за текущий и предыдущий годы. Для этого вывести год, месяц, сумму выручки в 
отсортированном сначала по возрастанию месяцев, затем по возрастанию лет виде. Название столбцов: Год, Месяц, Сумма.*/

SELECT
    YEAR(date_payment) Год,
    MONTHNAME(date_payment) Месяц,
    SUM(price * amount) Сумма
FROM
    buy_archive
GROUP BY 
    YEAR(date_payment),
    MONTHNAME(date_payment)
    
UNION ALL

SELECT
    YEAR(date_step_end) Год,
    MONTHNAME(date_step_end) Месяц,
    SUM(book.price * buy_book.amount) Сумма
FROM
    step
    INNER JOIN buy_step ON step.step_id = buy_step.step_id AND name_step = 'Оплата' AND date_step_end IS NOT NULL
    INNER JOIN buy ON buy_step.buy_id = buy.buy_id
    INNER JOIN buy_book ON buy_step.buy_id = buy_book.buy_id
    INNER JOIN book ON buy_book.book_id = book.book_id
GROUP BY 
    YEAR(date_step_end),
    MONTHNAME(date_step_end)
ORDER BY
    Месяц,
    Год


11. /*Для каждой отдельной книги необходимо вывести информацию о количестве проданных экземпляров и их стоимости за 2020 и 2019 год . 
За 2020 год проданными считать те экземпляры, которые уже оплачены. Вычисляемые столбцы назвать Количество и Сумма. 
Информацию отсортировать по убыванию стоимости.*/

SELECT
    title,
    SUM(amount) Количество,
    SUM(book_cost) Сумма
FROM (
    SELECT title,
        buy_archive.amount,
        buy_archive.price * buy_archive.amount AS book_cost
    FROM buy_archive
        INNER JOIN book ON buy_archive.book_id = book.book_id
    UNION ALL
    SELECT title,
        buy_book.amount,
        price * buy_book.amount AS book_cost
    FROM 
        step
        INNER JOIN buy_step ON step.step_id = buy_step.step_id 
                                    AND name_step = 'Оплата' 
                                        AND date_step_end IS NOT NULL
        INNER JOIN buy ON buy_step.buy_id = buy.buy_id
        INNER JOIN buy_book ON buy_step.buy_id = buy_book.buy_id
        INNER JOIN book ON buy_book.book_id = book.book_id
     ) query_in
GROUP BY title
ORDER BY Сумма DESC;    



2.5 База данных «Интернет-магазин книг», запросы корректировки

1.

/*Включить нового человека в таблицу с клиентами. Его имя Попов Илья, его email popov@test, проживает он в Москве.*/

INSERT INTO client (name_client, city_id, email)
SELECT 'Попов Илья', city_id, 'popov@test'
FROM city
WHERE name_city = 'Москва';

2.

/*Создать новый заказ для Попова Ильи. Его комментарий для заказа: «Связаться со мной по вопросу доставки».*/

INSERT INTO buy (buy_description, client_id)
SELECT 'Связаться со мной по вопросу доставки', client_id
FROM client
WHERE name_client = 'Попов Илья';

3.

/*В таблицу buy_book добавить заказ с номером 5. Этот заказ должен содержать книгу Пастернака «Лирика» в количестве двух экземпляров 
и книгу Булгакова «Белая гвардия» в одном экземпляре.*/

INSERT INTO buy_book (buy_id, book_id, amount)
SELECT '5', 
    (
    SELECT book_id
    FROM book
    WHERE title = 'Лирика' AND author_id = 
    	(
        SELECT author_id
        FROM author
        WHERE name_author LIKE 'Пастернак%'
        )
    ),
    '2'   
UNION
SELECT '5', 
    (
    SELECT book_id
    FROM book
    WHERE title = 'Белая Гвардия' AND author_id = 
    	(
        SELECT author_id
        FROM author
        WHERE name_author LIKE 'Булгаков%'
        )
    ),
    '1';

4. 

/*Количество тех книг на складе, которые были включены в заказ с номером 5, уменьшить на то количество, которое в заказе с номером 5  указано.*/

UPDATE book b
    INNER JOIN buy_book bb ON b.book_id = bb.book_id
SET b.amount = b.amount - bb.amount 
WHERE buy_id = 5;

-- Функция EXPLAIN ANALYZE - измеряет производительность запроса

5.

/*Создать счет (таблицу buy_pay) на оплату заказа с номером 5, в который включить название книг, их автора, цену, количество заказанных книг 
и  стоимость. Последний столбец назвать Стоимость. Информацию в таблицу занести в отсортированном по названиям книг виде.*/

CREATE TABLE buy_pay AS
SELECT title, 
    name_author, 
    price, 
    buy_book.amount, 
    book.price * buy_book.amount AS Стоимость
FROM buy_book
    INNER JOIN book USING (book_id)
    INNER JOIN author USING (author_id)
WHERE buy_id = 5
ORDER BY title;

6.

/*Создать общий счет (таблицу buy_pay) на оплату заказа с номером 5. Куда включить номер заказа, количество книг в заказе 
(название столбца Количество) и его общую стоимость (название столбца Итого). Для решения используйте ОДИН запрос.*/

CREATE TABLE buy_pay AS
SELECT buy_id,
    SUM(buy_book.amount) Количество,
    SUM(buy_book.amount * price) Итого
FROM buy_book
    INNER JOIN book USING (book_id)
WHERE buy_id = 5
GROUP BY buy_id;

7.

/*В таблицу buy_step для заказа с номером 5 включить все этапы из таблицы step, которые должен пройти этот заказ. 
В столбцы date_step_beg и date_step_end всех записей занести Null.*/

INSERT INTO buy_step (buy_id, step_id)
SELECT buy_id, step_id
FROM buy
    CROSS JOIN step
WHERE buy_id = 5;
SELECT * FROM buy_step;

8. 

/*В таблицу buy_step занести дату 12.04.2020 выставления счета на оплату заказа с номером 5.*/

UPDATE buy_step bs
    INNER JOIN step s ON bs.step_id = s.step_id AND name_step = 'Оплата'
SET date_step_beg = '2020.04.12'   -- Формат даты "ГОД.МЕСЯЦ.ДЕНЬ"
WHERE buy_id = 5;

9.

/*Завершить этап «Оплата» для заказа с номером 5, вставив в столбец date_step_end дату 13.04.2020, и начать следующий этап («Упаковка»), 
задав в столбце date_step_beg для этого этапа ту же дату.
Реализовать два запроса для завершения этапа и начала следующего. Они должны быть записаны в общем виде, чтобы его можно было применять для 
любых этапов, изменив только текущий этап. Для примера пусть это будет этап «Оплата».*/

UPDATE buy_step
    INNER JOIN step USING(step_id)
SET date_step_end = '2020.04.13'
WHERE name_step = 'Оплата' AND buy_id = 5;

UPDATE buy_step
    INNER JOIN step USING(step_id)
SET date_step_beg = '2020.04.13'
WHERE step_id = (
    SELECT step_id + 1
    FROM step
    WHERE name_step = 'Оплата'
    ) AND buy_id = 5;

-- Другой вариант решения

UPDATE buy_step
       INNER JOIN step USING(step_id)
SET date_step_end = IF(name_step = 'Оплата', '2020-04-13', date_step_end),
    date_step_beg = IF(name_step = 'Упаковка', '2020-04-13', date_step_beg)
WHERE buy_id = 5;