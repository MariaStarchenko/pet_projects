-- 7 Урок "Подзапросы"


1. /*Используя данные из таблицы user_actions, рассчитайте среднее число заказов всех пользователей нашего сервиса.
Для этого сначала в подзапросе посчитайте, сколько заказов сделал каждый пользователь, а затем обратитесь к результату подзапроса
в блоке FROM и уже в основном запросе усредните количество заказов по всем пользователям.
Полученное среднее число заказов всех пользователей округлите до двух знаков после запятой. Колонку с этим значением назовите orders_avg.*/

SELECT ROUND(AVG(order_count), 2) AS orders_avg
FROM (
	SELECT COUNT(order_id) AS order_count
	FROM user_actions
	WHERE action = 'create_order'
	GROUP BY user_id
	 ) AS subquery_1;


/*Theory. CTE
Табличные выражения — это временные таблицы, существующие только для одного запроса. Их основное предназначение заключается в разбиении 
сложных запросов на несколько частей. Табличные выражения создаются так:
WITH 
subquery_1 AS (
    SELECT column_1, column_2
    FROM table
)

Оператор WITH может содержать несколько табличных выражений, причём к указанным ранее выражениям можно обращаться в последующих выражениях:

WITH 
subquery_1 AS (
    SELECT column_1, column_2, column_3
    FROM table
),
subquery_2 AS (
    SELECT column_1, column_2
    FROM subquery_1
)

SELECT column_1
FROM subquery_2  */

2. /*Повторите запрос из предыдущего задания, но теперь вместо подзапроса используйте оператор WITH и табличное выражение.
Условия задачи те же: используя данные из таблицы user_actions, рассчитайте среднее число заказов всех пользователей.
Полученное среднее число заказов округлите до двух знаков после запятой. Колонку с этим значением назовите orders_avg.*/

WITH 
subquery_1 AS (
	SELECT COUNT(order_id) AS order_count
	FROM user_actions
	WHERE action = 'create_order'
	GROUP BY user_id
)

SELECT ROUND(AVG(order_count), 2) AS orders_avg
FROM subquery_1;

3. /*Выведите из таблицы products информацию о всех товарах кроме самого дешёвого. Результат отсортируйте по убыванию id товара.*/

SELECT product_id,
	name,
	price
FROM products
WHERE price <> (SELECT MIN(price) FROM products)
ORDER BY product_id desc;

4. /*Выведите информацию о товарах в таблице products, цена на которые превышает среднюю цену всех товаров на 20 рублей и более. 
Результат отсортируйте по убыванию id товара.*/

SELECT product_id,
	name,
	price
FROM products
WHERE price - (SELECT AVG(price) FROM products) >= 20
ORDER BY product_id desc;

5. /*Посчитайте количество уникальных клиентов в таблице user_actions, сделавших за последнюю неделю хотя бы один заказ.
Полученную колонку с числом клиентов назовите users_count. В качестве текущей даты, от которой откладывать неделю, используйте последнюю 
дату в той же таблице user_actions.*/

SELECT COUNT(DISTINCT user_id) AS users_count
FROM user_actions
WHERE time >= (SELECT MAX(time) FROM user_actions) - INTERVAL '1 week'
	AND action = 'create_order' 

6. /*С помощью функции AGE и агрегирующей функции снова определите возраст самого молодого курьера мужского пола в таблице couriers, 
но в этот раз при расчётах в качестве первой даты используйте последнюю дату из таблицы courier_actions.
Чтобы получить именно дату, перед применением функции AGE переведите последнюю дату из таблицы courier_actions в формат DATE.
Возраст курьера измерьте количеством лет, месяцев и дней и переведите его в тип VARCHAR. Полученную колонку со значением возраста назовите
min_age.*/

SELECT MIN(AGE((SELECT MAX(time)::date
                FROM courier_actions), birth_date))::varchar AS min_age
FROM couriers
WHERE sex = 'male';

7. /*Из таблицы user_actions с помощью подзапроса или табличного выражения отберите все заказы, которые не были отменены пользователями.
Выведите колонку с id этих заказов. Результат запроса отсортируйте по возрастанию id заказа.
Добавьте в запрос оператор LIMIT и выведите только первые 1000 строк результирующей таблицы.*/

-- 1 вариант

WITH
t1 AS (
	SELECT order_id
	FROM user_actions
	WHERE action = 'cancel_order'
)

SELECT order_id
FROM user_actions
WHERE order_id NOT IN (SELECT * FROM t1)
ORDER BY order_id
LIMIT 1000;

-- 2 вариант

SELECT order_id
FROM user_actions
WHERE order_id NOT IN (SELECT order_id
					   FROM user_actions
					   WHERE action = 'cancel_order')
ORDER BY order_id
LIMIT 1000;

8. /*Используя данные из таблицы user_actions, рассчитайте, сколько заказов сделал каждый пользователь и отразите это в столбце orders_count.
В отдельном столбце orders_avg напротив каждого пользователя укажите среднее число заказов всех пользователей, округлив его до двух знаков 
после запятой. Также для каждого пользователя посчитайте отклонение числа заказов от среднего значения. Отклонение считайте так: число 
заказов «минус» округлённое среднее значение. Колонку с отклонением назовите orders_diff. Результат отсортируйте по возрастанию id 
пользователя. Добавьте в запрос оператор LIMIT и выведите только первые 1000 строк результирующей таблицы.
Поля в результирующей таблице: user_id, orders_count, orders_avg, orders_diff*/

WITH
t1 AS (
	SELECT user_id,
		COUNT(order_id) AS orders_count
	FROM user_actions
	WHERE action = 'create_order'
	GROUP BY user_id
)

SELECT user_id,
       orders_count,
       ROUND((SELECT AVG(orders_count) FROM   t1), 2) AS orders_avg, 
       orders_count - ROUND((SELECT AVG(orders_count) FROM   t1), 2)  AS orders_diff
FROM t1
ORDER BY user_id limit 1000;

9. /*Назначьте скидку 15% на товары, цена которых превышает среднюю цену на все товары на 50 и более рублей, а также скидку 10% на 
товары, цена которых ниже средней на 50 и более рублей. Цену остальных товаров внутри диапазона (среднее - 50; среднее + 50) оставьте 
без изменений. При расчёте средней цены, округлите её до двух знаков после запятой.
Выведите информацию о всех товарах с указанием старой и новой цены. Колонку с новой ценой назовите new_price.
Результат отсортируйте сначала по убыванию прежней цены в колонке price, затем по возрастанию id товара.*/

WITH
t1 AS(
	SELECT ROUND(AVG(price), 2)
	FROM products
)

SELECT product_id,
	name,
	price,
	CASE
	WHEN price - (SELECT * FROM t1) >= 50 THEN price - price * 0.15
	WHEN (SELECT * FROM t1) - price >= 50 THEN price - price * 0.10
	ELSE price
	END AS new_price
FROM products
ORDER BY price desc, product_id;

10. /* Выясните, есть ли в таблице courier_actions такие заказы, которые были приняты курьерами, но не были созданы пользователями. 
Посчитайте количество таких заказов. Колонку с числом заказов назовите orders_count.*/

SELECT COUNT(order_id) AS orders_count
FROM courier_actions
WHERE action = 'accept_order'
	AND order_id NOT IN (SELECT order_id FROM user_actions);

11. /*Выясните, есть ли в таблице user_actions такие заказы, которые были приняты курьерами, но не были доставлены пользователям. 
Посчитайте количество таких заказов. Колонку с числом заказов назовите orders_count.*/

SELECT COUNT(order_id) as orders_count
FROM courier_actions
WHERE order_id NOT IN (SELECT order_id
                       FROM courier_actions
                       WHERE action = 'deliver_order');

12. /*Определите количество отменённых заказов в таблице courier_actions и выясните, есть ли в этой таблице такие заказы, которые 
были отменены пользователями, но при этом всё равно были доставлены. Посчитайте количество таких заказов.
Колонку с отменёнными заказами назовите orders_canceled. Колонку с отменёнными, но доставленными заказами назовите 
orders_canceled_and_delivered. */

SELECT COUNT(DISTINCT order_id) AS orders_canceled,
       COUNT(order_id) FILTER (WHERE action = 'deliver_order') AS orders_canceled_and_delivered
FROM courier_actions
WHERE order_id in (SELECT order_id
                    FROM   user_actions
                    WHERE  action = 'cancel_order');

13. /*По таблицам courier_actions и user_actions снова определите число недоставленных заказов и среди них посчитайте количество 
отменённых заказов и количество заказов, которые не были отменены (и соответственно, пока ещё не были доставлены).
Колонку с недоставленными заказами назовите orders_undelivered, колонку с отменёнными заказами назовите orders_canceled, колонку 
с заказами «в пути» назовите orders_in_process.*/

SELECT 
	COUNT(DISTINCT order_id) AS orders_undelivered,
	COUNT(DISTINCT order_id) 
		FILTER (WHERE order_id IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order')) AS orders_canceled,
	COUNT(DISTINCT order_id) 
		FILTER (WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order')) AS orders_in_process
FROM courier_actions
WHERE order_id NOT IN (SELECT order_id
                       FROM courier_actions
                       WHERE action = 'deliver_order');

14. /*Отберите из таблицы users пользователей мужского пола, которые старше всех пользователей женского пола.
Выведите две колонки: id пользователя и дату рождения. Результат отсортируйте по возрастанию id пользователя.*/

SELECT user_id,
	birth_date
FROM users
WHERE sex = 'male'
	AND birth_date < (SELECT MIN(birth_date) 
					  FROM users 
					  WHERE sex = 'female')
ORDER BY user_id;

15. /*Выведите id и содержимое 100 последних доставленных заказов из таблицы orders.
Содержимым заказов считаются списки с id входящих в заказ товаров. Результат отсортируйте по возрастанию id заказа.*/

SELECT order_id,
	product_ids
FROM orders
WHERE order_id IN (SELECT order_id 
				   FROM courier_actions 
				   WHERE action = 'deliver_order'
				   ORDER BY time desc
				   LIMIT 100)
ORDER BY order_id;

16. /*Из таблицы couriers выведите всю информацию о курьерах, которые в сентябре 2022 года доставили 30 и более заказов. 
Результат отсортируйте по возрастанию id курьера.*/

SELECT courier_id,
       birth_date,
       sex
FROM couriers
WHERE courier_id in (SELECT courier_id
                     FROM courier_actions
                     WHERE date_part('month', time) = 9
                         AND date_part('year', time) = 2022
                         AND action = 'deliver_order'
                     GROUP BY courier_id 
                     HAVING COUNT(DISTINCT order_id) >= 30)
ORDER BY courier_id;

17. /*Рассчитайте средний размер заказов, отменённых пользователями мужского пола.
Средний размер заказа округлите до трёх знаков после запятой. Колонку со значением назовите avg_order_size.

Поле в результирующей таблице: avg_order_size*/

SELECT
  ROUND(AVG(array_length(product_ids, 1)), 3) AS avg_order_size
FROM orders
WHERE order_id IN 
  (
    SELECT order_id
    FROM user_actions
    WHERE action = 'cancel_order'
      AND user_id IN 
      (
        SELECT user_id
        FROM users
        WHERE sex = 'male'
      )
  );

18. /*Посчитайте возраст каждого пользователя в таблице users.
Возраст измерьте числом полных лет, как мы делали в прошлых уроках. Возраст считайте относительно последней даты в таблице user_actions.
Для тех пользователей, у которых в таблице users не указана дата рождения, укажите среднее значение возраста всех остальных пользователей, 
округлённое до целого числа. Колонку с возрастом назовите age. В результат включите колонки с id пользователя и возрастом. 
Отсортируйте полученный результат по возрастанию id пользователя.
Поля в результирующей таблице: user_id, age*/

WITH user_age AS(
  SELECT user_id,
    date_part('year',
      AGE(
        (
          SELECT
            MAX(time)
          FROM
            user_actions
        ),
        birth_date
      )
    ) :: INTEGER AS age
  FROM users
)

SELECT user_id,
  COALESCE(age,
    (
      SELECT ROUND(AVG(age), 3) :: INT
      FROM user_age
    )
  ) AS age
FROM user_age
ORDER BY user_id;

19. /*Для каждого заказа, в котором больше 5 товаров, рассчитайте время, затраченное на его доставку. 
В результат включите id заказа, время принятия заказа курьером, время доставки заказа и время, затраченное на доставку. 
Новые колонки назовите соответственно time_accepted, time_delivered и delivery_time.
В расчётах учитывайте только неотменённые заказы. Время, затраченное на доставку, выразите в минутах, округлив значения до целого числа. 
Результат отсортируйте по возрастанию id заказа.

Поля в результирующей таблице: order_id, time_accepted, time_delivered и delivery_time*/

SELECT order_id,
       MIN(time) AS time_accepted,
       MAX(time) AS time_delivered,
       (EXTRACT (epoch FROM max(time) - min(time))/60)::INT AS delivery_time
FROM courier_actions
WHERE order_id 
		IN (SELECT order_id
            FROM   orders
            WHERE  array_length(product_ids, 1) > 5
           )
   	  AND order_id 
   	  	NOT IN (SELECT order_id
             	FROM user_actions
                WHERE action = 'cancel_order'
                )
GROUP BY order_id
ORDER BY order_id;

20. /*Для каждой даты в таблице user_actions посчитайте количество первых заказов, совершённых пользователями.
Первыми заказами будем считать заказы, которые пользователи сделали в нашем сервисе впервые. В расчётах учитывайте только неотменённые 
заказы. В результат включите две колонки: дату и количество первых заказов в эту дату. Колонку с датами назовите date, а колонку с 
первыми заказами — first_orders. Результат отсортируйте по возрастанию даты.

Поля в результирующей таблице: date, first_orders*/

WITH first_orders AS (
    SELECT user_id, 
    	MIN(time)::date AS first_order_date
    FROM user_actions 
    WHERE order_id NOT IN(
        SELECT order_id
        FROM user_actions 
        WHERE action = 'cancel_order'
        )
    GROUP BY user_id
)
 
SELECT first_order_date AS date,
	   COUNT(user_id) AS first_orders
FROM first_orders
GROUP BY date
ORDER BY date;


/*Theory. Unnest()
Функция unnest предназначена для разворачивания массивов и превращения их в набор строк:

SELECT unnest(ARRAY['one','two','three'])

Результат:
one
two
three

Если бы в исходной таблице помимо списка был столбец с каким-либо значением, то это значение автоматически проставилось бы напротив 
значений в каждой образовавшейся строке:

SELECT 'row', unnest(ARRAY['one','two','three'])

Результат:
row    one
row    two
row    three */


21. /*Выберите все колонки из таблицы orders и дополнительно в качестве последней колонки укажите функцию unnest, применённую к 
колонке product_ids. Эту последнюю колонку назовите product_id. Больше ничего с данными делать не нужно.
Добавьте в запрос оператор LIMIT и выведите только первые 100 записей результирующей таблицы.
Поля в результирующей таблице: creation_time, order_id, product_ids, product_id.
Посмотрите на результат работы функции unnest и постарайтесь разобраться, что произошло с исходной таблицей.*/

-- 1 вариант

SELECT *,
	unnest(product_ids) AS product_id
FROM orders
LIMIT 100;

-- 2 вариант

SELECT creation_time,
       order_id,
       product_ids,
       unnest(product_ids) as product_id
FROM orders 
LIMIT 100;

22. /*Используя функцию unnest, определите 10 самых популярных товаров в таблице orders.
Самыми популярными товарами будем считать те, которые встречались в заказах чаще всего. Если товар встречается в одном заказе несколько 
раз (когда было куплено несколько единиц товара), это тоже учитывается при подсчёте. Учитывайте только неотменённые заказы.
Выведите id товаров и то, сколько раз они встречались в заказах (то есть сколько раз были куплены). Новую колонку с количеством 
покупок товаров назовите times_purchased. Результат отсортируйте по возрастанию id товара.
Поля в результирующей таблице: product_id, times_purchased*/

SELECT product_id,
	times_purchased
FROM (
	SELECT unnest(product_ids) as product_id,
		   COUNT(*) AS times_purchased
	FROM orders
	WHERE order_id NOT IN (SELECT order_id
					   	   FROM user_actions
					       WHERE action = 'cancel_order')
	GROUP BY product_id
	ORDER BY times_purchased desc
	LIMIT 10
) q1
ORDER BY product_id;


23. /*Из таблицы orders выведите id и содержимое заказов, которые включают хотя бы один из пяти самых дорогих товаров, доступных в 
нашем сервисе. Результат отсортируйте по возрастанию id заказа. Поля в результирующей таблице: order_id, product_ids*/

WITH 
max_pr AS (
	SELECT product_id
	FROM products
	ORDER BY price desc
	LIMIT 5
),

prod_id AS (
	SELECT order_id, 
		product_ids,
		unnest(product_ids) AS product
	FROM orders
)

SELECT DISTINCT order_id,
	product_ids
FROM prod_id
WHERE product = ANY(SELECT * FROM max_pr)
ORDER BY order_id;