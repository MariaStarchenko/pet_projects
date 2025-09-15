-- 3 Урок "Базовые запросы SQL"


1. /*Выведите все записи из таблицы products. Поля в результирующей таблице: product_id, name, price*/

SELECT * FROM products;

2. /*Выведите все записи из таблицы products, отсортировав их по наименованиям товаров в алфавитном порядке, т.е. по возрастанию. 
Для сортировки используйте оператор ORDER BY.*/

SELECT * FROM products
ORDER BY name;

3. /*Отсортируйте таблицу courier_actions сначала по колонке courier_id по возрастанию id курьера, потом по колонке action 
(снова по возрастанию), а затем по колонке time, но уже по убыванию — от самого последнего действия к самому первому.
Добавьте в запрос оператор LIMIT и выведите только первые 1000 строк результирующей таблицы.*/

SELECT * FROM courier_actions
ORDER BY courier_id, action, time DESC
LIMIT 1000;

4. /*Используя операторы SELECT, FROM, ORDER BY и LIMIT, определите 5 самых дорогих товаров в таблице products, 
которые доставляет наш сервис. Выведите их наименования и цену.*/

SELECT name, price
FROM products
ORDER BY price desc
LIMIT 5;

5. /*Как в прошлом задании определите 5 самых дорогих товаров в таблице products. Но теперь колонки name и price переименуйте 
соответственно в product_name и product_price.*/ 

SELECT name AS product_name, price AS product_price
FROM products
ORDER BY price desc
LIMIT 5;

6. /*Определите товар с самым длинным названием в таблице products. Выведите его наименование, длину наименования в символах, 
а также цену этого товара. Колонку с длиной наименования в символах назовите name_length.*/

SELECT name, 
    LENGTH(name) AS name_length,
    price
FROM products
ORDER BY name_length desc
LIMIT 1;

7. /*Преобразуйте наименования товаров в таблице products так, чтобы от названий осталось только первое слово, 
записанное в верхнем регистре. Колонку с новым названием, состоящим из первого слова, назовите first_word. Результат отсортируйте 
по возрастанию исходного наименования товара в колонке name.*/

SELECT name, 
    UPPER(SPLIT_PART(name, ' ', 1)) AS first_word,
    price
FROM products
ORDER BY name;

8. /*Измените тип колонки price из таблицы products на VARCHAR. Выведите колонки с наименованием товаров, ценой в исходном формате
и ценой в формате VARCHAR. Новую колонку с ценой в новом формате назовите price_char. Результат отсортируйте по возрастанию 
исходного наименования товара в колонке name.*/

-- 1 вариант

SELECT name, 
    price,
    CAST(price AS VARCHAR) AS price_char
FROM products
ORDER BY name;

-- 2 вариант

SELECT name, 
    price,
    price::VARCHAR AS price_char
FROM products
ORDER BY name;

9. /*Для первых 200 записей из таблицы orders выведите информацию в следующем виде (обратите внимание на пробелы):
Заказ № [id заказа] создан [дата]. Полученную колонку назовите order_info.*/

SELECT CONCAT('Заказ № ', order_id, ' создан ', DATE(creation_time)) AS order_info
FROM orders
LIMIT 200;

10. /*Выведите id всех курьеров и их годы рождения из таблицы couriers. Год рождения необходимо получить из колонки birth_date. 
Новую колонку с годом назовите birth_year. Результат отсортируйте сначала по убыванию года рождения курьера,
 затем по возрастанию id курьера.*/

SELECT courier_id,
       date_part('year', birth_date) as birth_year
FROM   couriers
ORDER BY birth_year desc, courier_id;

11. /*Как и в предыдущем задании, снова выведите id всех курьеров и их годы рождения, только теперь к извлеченному году примените 
функцию COALESCE. Укажите параметры функции так, чтобы вместо NULL значений в результат попадало текстовое значение unknown. 
Названия полей оставьте прежними.Отсортируйте итоговую таблицу сначала по убыванию года рождения курьера, затем по возрастанию id курьера.*/

SELECT courier_id,
    COALESCE(CAST(DATE_PART('year', birth_date) AS VARCHAR), 'unknown') AS birth_year
FROM couriers
ORDER BY birth_year desc, courier_id;

12. /*Давайте представим, что по какой-то необъяснимой причине мы вдруг решили в одночасье повысить цену всех товаров в таблице 
products на 5%. Выведите id и наименования всех товаров, их старую и новую цену. Колонку со старой ценой назовите old_price, 
а колонку с новой — new_price. Результат отсортируйте сначала по убыванию новой цены, затем по возрастанию id товара.*/

SELECT product_id,
    name,
    price AS old_price,
    price + price * 0.05 AS new_price
FROM products
ORDER BY new_price desc, product_id;

13. /*Вновь, как и в прошлом задании, повысьте цену всех товаров на 5%, только теперь к колонке с новой ценой примените функцию ROUND. 
Выведите id и наименования товаров, их старую цену, а также новую цену с округлением. Новую цену округлите до одного знака после 
запятой, но тип данных не меняйте. Результат отсортируйте сначала по убыванию новой цены, затем по возрастанию id товара.*/

SELECT product_id,
    name,
    price AS old_price,
    ROUND(price * 1.05, 1) AS new_price
FROM products
ORDER BY new_price desc, product_id;

14. /*Повысьте цену на 5% только на те товары, цена которых превышает 100 рублей. Цену остальных товаров оставьте без изменений. 
Также не повышайте цену на икру, которая и так стоит 800 рублей. Выведите id и наименования всех товаров, их старую и новую цену. 
Цену округлять не нужно. Результат отсортируйте сначала по убыванию новой цены, затем по возрастанию id товара.*/

SELECT product_id,
    name,
    price AS old_price,
    case 
    when price <= 100 or name = 'икра' then price
    when price > 100 then price*1.05
    else 0 
	end new_price
FROM   products
ORDER BY new_price desc, product_id;

15. /*Вычислите НДС каждого товара в таблице products и рассчитайте цену без учёта НДС. Выведите всю информацию о товарах, 
включая сумму налога и цену без его учёта. Колонки с суммой налога и ценой без НДС назовите соответственно tax и price_before_tax. 
Округлите значения в этих колонках до двух знаков после запятой.
Результат отсортируйте сначала по убыванию цены товара без учёта НДС, затем по возрастанию id товара.*/

SELECT product_id,
       name,
       price,
       ROUND(price / 120 * 100, 2) AS price_before_tax,
       ROUND(price / 120 * 20, 2) AS tax
FROM   products
ORDER BY price_before_tax desc, product_id;
