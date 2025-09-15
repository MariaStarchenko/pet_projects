-- 8 Урок "JOIN"


1. /*Объедините таблицы user_actions и users по ключу user_id. В результат включите две колонки с user_id из обеих таблиц. Эти две 
колонки назовите соответственно user_id_left и user_id_right. Также в результат включите колонки order_id, time, action, sex, birth_date. 
Отсортируйте получившуюся таблицу по возрастанию id пользователя (в любой из двух колонок с id).*/

SELECT u.user_id AS user_id_left,
	ua.user_id AS user_id_right,
	order_id,
	time,
	action,
	sex,
	birth_date
FROM users u
	INNER JOIN user_actions ua ON u.user_id=ua.user_id
ORDER BY user_id_left;

2./*А теперь попробуйте немного переписать запрос из прошлого задания и посчитать количество уникальных id в объединённой таблице. То есть 
снова объедините таблицы, но в этот раз просто посчитайте уникальные user_id в одной из колонок с id. Выведите это количество в качестве 
результата. Колонку с посчитанным значением назовите users_count.*/

SELECT COUNT(DISTINCT u.user_id) AS users_count
FROM users u
	INNER JOIN user_actions ua ON u.user_id=ua.user_id;

3. /*С помощью LEFT JOIN объедините таблицы user_actions и users по ключу user_id. Обратите внимание на порядок таблиц — слева user_actions,
справа users. В результат включите две колонки с user_id из обеих таблиц. Эти две колонки назовите соответственно user_id_left 
и user_id_right. Также в результат включите колонки order_id, time, action, sex, birth_date. Отсортируйте получившуюся таблицу по 
возрастанию id пользователя (в колонке из левой таблицы).*/

SELECT ua.user_id AS user_id_left,
	u.user_id AS user_id_right,
	order_id,
	time,
	action,
	sex,
	birth_date
FROM user_actions ua
	LEFT JOIN users u ON u.user_id=ua.user_id
ORDER BY user_id_left;

4. /*Теперь снова попробуйте немного переписать запрос из прошлого задания и посчитайте количество уникальных id в колонке user_id, 
пришедшей из левой таблицы user_actions. Выведите это количество в качестве результата. Колонку с посчитанным значением назовите users_count.*/

SELECT COUNT(DISTINCT ua.user_id) AS users_count
FROM user_actions ua
	LEFT JOIN users u ON u.user_id=ua.user_id;

5. /*Возьмите запрос из задания 3, где вы объединяли таблицы user_actions и users с помощью LEFT JOIN, добавьте к запросу оператор WHERE 
 исключите NULL значения в колонке user_id из правой таблицы. Включите в результат все те же колонки и отсортируйте получившуюся таблицу 
 по возрастанию id пользователя в колонке из левой таблицы.*/

SELECT ua.user_id AS user_id_left,
	u.user_id AS user_id_right,
	order_id,
	time,
	action,
	sex,
	birth_date
FROM user_actions ua
	LEFT JOIN users u ON u.user_id=ua.user_id
WHERE u.user_id IS NOT NULL
ORDER BY user_id_left;

6. /*С помощью FULL JOIN объедините по ключу birth_date таблицы, полученные в результате вышеуказанных запросов (то есть объедините друг с 
другом два подзапроса). Не нужно изменять их, просто добавьте нужный JOIN. В результат включите две колонки с birth_date из обеих таблиц. 
Эти две колонки назовите соответственно users_birth_date и couriers_birth_date. Также включите в результат колонки с числом пользователей 
и курьеров — users_count и couriers_count. Отсортируйте получившуюся таблицу сначала по колонке users_birth_date по возрастанию, затем 
по колонке couriers_birth_date — тоже по возрастанию.*/

SELECT a.birth_date AS users_birth_date,
	b.birth_date AS couriers_birth_date,
	a.users_count,
	b.couriers_count
FROM ( 
        SELECT birth_date, COUNT(user_id) AS users_count 
        FROM users 
        WHERE birth_date IS NOT NULL 
        GROUP BY birth_date 
    ) a 
	FULL JOIN ( 
        SELECT birth_date, COUNT(courier_id) AS couriers_count 
        FROM couriers 
        WHERE birth_date IS NOT NULL 
        GROUP BY birth_date 
    ) b 
    USING(birth_date) 
ORDER BY users_birth_date, couriers_birth_date;


/*Theory. Операции над множествами
В языке SQL их три:

Операция UNION объединяет записи из двух запросов в один общий результат (объединение множеств).

Операция EXCEPT возвращает все записи, которые есть в первом запросе, но отсутствуют во втором (разница множеств).

Операция INTERSECT возвращает все записи, которые есть и в первом, и во втором запросе (пересечение множеств).

При этом по умолчанию эти операции исключают из результата строки-дубликаты. Чтобы дубликаты не исключались из результата, необходимо 
после имени операции указать ключевое слово ALL. Например, UNION ALL.

Синтаксис:

SELECT column_1, column_2
FROM table_1
UNION
SELECT column_1, column_2
FROM table_2


SELECT column_1, column_2
FROM table_1
EXCEPT
SELECT column_1, column_2
FROM table_2


SELECT column_1, column_2
FROM table_1
INTERSECT
SELECT column_1, column_2
FROM table_2*/



7. /*Объедините два следующих запроса друг с другом так, чтобы на выходе получился набор уникальных дат из таблиц users и couriers:
Поместите в подзапрос полученный после объединения набор дат и посчитайте их количество. Колонку с числом дат назовите dates_count.
Поле в результирующей таблице: dates_count*/

SELECT COUNT(birth_date) AS dates_count
FROM (
	SELECT birth_date
	FROM users
	WHERE birth_date IS NOT NULL
	UNION
	SELECT birth_date
	FROM couriers
	WHERE birth_date IS NOT NULL
) q1;

8. /*Из таблицы users отберите id первых 100 пользователей (просто выберите первые 100 записей, используя простой LIMIT) и с помощью 
CROSS JOIN объедините их со всеми наименованиями товаров из таблицы products. Выведите две колонки — id пользователя и наименование товара.
Результат отсортируйте сначала по возрастанию id пользователя, затем по имени товара — тоже по возрастанию.
Поля в результирующей таблице: user_id, name*/

SELECT user_id,
	name
FROM (
	SELECT user_id
	FROM users
	LIMIT 100
) q1
	CROSS JOIN (SELECT name FROM products) q2
ORDER BY user_id, name;

9. /*Для начала объедините таблицы user_actions и orders — это вы уже умеете делать. В качестве ключа используйте поле order_id. 
Выведите id пользователей и заказов, а также список товаров в заказе. Отсортируйте таблицу по id пользователя по возрастанию, затем по 
id заказа — тоже по возрастанию. Добавьте в запрос оператор LIMIT и выведите только первые 1000 строк результирующей таблицы.*/

SELECT user_id,
	order_id,
	product_ids
FROM user_actions LEFT JOIN orders USING(order_id)
ORDER BY user_id, order_id
LIMIT 1000;

10. /*Снова объедините таблицы user_actions и orders, но теперь оставьте только уникальные неотменённые заказы. Остальные условия задачи 
те же: вывести id пользователей и заказов, а также список товаров в заказе. Отсортируйте таблицу по id пользователя по возрастанию, 
затем по id заказа — тоже по возрастанию. Добавьте в запрос оператор LIMIT и выведите только первые 1000 строк результирующей таблицы.*/

SELECT user_id,
  order_id,
  product_ids
FROM
  (
    SELECT user_id,
      order_id
    FROM user_actions
    WHERE order_id NOT IN (
        SELECT order_id
        FROM user_actions
        WHERE action = 'cancel_order'
      )
  ) q1
  LEFT JOIN orders USING(order_id)
ORDER BY user_id, order_id
LIMIT 1000;

11. /*Используя запрос из предыдущего задания, посчитайте, сколько в среднем товаров заказывает каждый пользователь. Выведите id 
пользователя и среднее количество товаров в заказе. Среднее значение округлите до двух знаков после запятой. Колонку посчитанными 
значениями назовите avg_order_size. Результат выполнения запроса отсортируйте по возрастанию id пользователя. 
Добавьте в запрос оператор LIMIT и выведите только первые 1000 строк результирующей таблицы.

Поля в результирующей таблице: user_id, avg_order_size*/

SELECT user_id,
	ROUND(AVG(array_length(product_ids, 1)), 2) AS avg_order_size
 FROM
  (
    SELECT user_id,
      order_id
    FROM user_actions
    WHERE order_id NOT IN (
        SELECT order_id
        FROM user_actions
        WHERE action = 'cancel_order'
      )
  ) q1
  LEFT JOIN orders USING(order_id)
GROUP BY user_id
ORDER BY user_id
LIMIT 1000;

12. /*Для начала к таблице с заказами (orders) примените функцию unnest, как мы делали в прошлом уроке. Колонку с id товаров назовите 
product_id. Затем к образовавшейся расширенной таблице по ключу product_id добавьте информацию о ценах на товары (из таблицы products). 
Должна получиться таблица с заказами, товарами внутри каждого заказа и ценами на эти товары. Выведите колонки с id заказа, id товара и 
ценой товара. Результат отсортируйте сначала по возрастанию id заказа, затем по возрастанию id товара.
Добавьте в запрос оператор LIMIT и выведите только первые 1000 строк результирующей таблицы.*/

SELECT order_id,
	product_id,
	price
FROM (
	SELECT unnest(product_ids) AS product_id,
		order_id
	FROM orders
) q1
	LEFT JOIN products USING(product_id)
ORDER BY order_id, product_id
LIMIT 1000;

13. /*Используя запрос из предыдущего задания, рассчитайте суммарную стоимость каждого заказа. Выведите колонки с id заказов и их 
стоимостью. Колонку со стоимостью заказа назовите order_price. Результат отсортируйте по возрастанию id заказа.
Добавьте в запрос оператор LIMIT и выведите только первые 1000 строк результирующей таблицы.*/

SELECT order_id,
	SUM(price) AS order_price
FROM (
	SELECT unnest(product_ids) AS product_id,
		order_id
	FROM orders
) q1
	LEFT JOIN products USING(product_id)
GROUP BY order_id
ORDER BY order_id
LIMIT 1000;

14. /*Объедините запрос из предыдущего задания с частью запроса, который вы составили в задаче 11, то есть объедините запрос со стоимостью 
заказов с запросом, в котором вы считали размер каждого заказа из таблицы user_actions.
На основе объединённой таблицы для каждого пользователя рассчитайте следующие показатели:

общее число заказов — колонку назовите orders_count
среднее количество товаров в заказе — avg_order_size
суммарную стоимость всех покупок — sum_order_value
среднюю стоимость заказа — avg_order_value
минимальную стоимость заказа — min_order_value
максимальную стоимость заказа — max_order_value
Полученный результат отсортируйте по возрастанию id пользователя. Добавьте в запрос оператор LIMIT и выведите только первые 1000 строк результирующей таблицы.

Помните, что в расчётах мы по-прежнему учитываем только неотменённые заказы. При расчёте средних значений, округляйте их до двух знаков 
после запятой.*/

SELECT
  user_id,
  COUNT(order_price) AS orders_count,
  ROUND(AVG(order_size), 2) AS avg_order_size,
  SUM(order_price) AS sum_order_value,
  ROUND(AVG(order_price), 2) AS avg_order_value,
  MIN(order_price) AS min_order_value,
  MAX(order_price) AS max_order_value
FROM
  (
    SELECT
      user_id,
      order_id,
      ARRAY_LENGTH(product_ids, 1) AS order_size
    FROM
      (
        SELECT
          user_id,
          order_id
        FROM user_actions
        WHERE
          order_id NOT IN (
            SELECT order_id
            FROM user_actions
            WHERE action = 'cancel_order'
          )
      ) t1
      LEFT JOIN orders USING(order_id)
  ) t2
  LEFT JOIN (
    SELECT
      order_id,
      SUM(price) AS order_price
    FROM
      (
        SELECT
          order_id,
          product_ids,
          UNNEST(product_ids) AS product_id
        FROM orders
        WHERE order_id NOT IN (
            SELECT order_id
            FROM user_actions
            WHERE action = 'cancel_order'
          )
      ) t3
      LEFT JOIN products USING(product_id)
    GROUP BY order_id
  ) t4 USING(order_id)
GROUP BY user_id
ORDER BY user_id
LIMIT 1000;

15. /*По данным таблиц orders, products и user_actions посчитайте ежедневную выручку сервиса. Под выручкой будем понимать стоимость 
всех реализованных товаров, содержащихся в заказах. Колонку с датой назовите date, а колонку со значением выручки — revenue.
В расчётах учитывайте только неотменённые заказы. Результат отсортируйте по возрастанию даты.

Поля в результирующей таблице: date, revenue*/

SELECT date(creation_time) AS date,
       sum(price) AS revenue
FROM (SELECT order_id,
             creation_time,
             product_ids,
             unnest(product_ids) as product_id
      FROM   orders
      WHERE  order_id NOT IN (SELECT order_id
                              FROM   user_actions
                              WHERE  action = 'cancel_order')
     ) q1
    LEFT JOIN products USING(product_id)
GROUP BY date;

16. /*По таблицам courier_actions , orders и products определите 10 самых популярных товаров, доставленных в сентябре 2022 года.
Самыми популярными товарами будем считать те, которые встречались в заказах чаще всего. Если товар встречается в одном заказе несколько 
раз (было куплено несколько единиц товара), то при подсчёте учитываем только одну единицу товара.
Выведите наименования товаров и сколько раз они встречались в заказах. Новую колонку с количеством покупок товара назовите times_purchased.*/

SELECT name,
       COUNT(product_id) AS times_purchased
FROM (SELECT order_id,
             product_id,
             name
      FROM (SELECT DISTINCT order_id,
                   unnest(product_ids) AS product_id
            FROM orders
                LEFT JOIN courier_actions using (order_id)
            WHERE  action = 'deliver_order'
                AND date_part('month', time) = 9
                AND date_part('year', time) = 2022
            ) q1
        LEFT JOIN products USING (product_id)
      ) q2
GROUP BY name
ORDER BY times_purchased desc 
LIMIT 10;

17. /*Возьмите запрос, составленный на одном из прошлых уроков, и подтяните в него из таблицы users данные о поле пользователей таким 
образом, чтобы все пользователи из таблицы user_actions остались в результате. Затем посчитайте среднее значение cancel_rate для каждого 
пола, округлив его до трёх знаков после запятой. Колонку с посчитанным средним значением назовите avg_cancel_rate.
Помните про отсутствие информации о поле некоторых пользователей после join, так как не все пользователи из таблицы user_action есть в 
таблице users. Для этой группы тоже посчитайте cancel_rate и в результирующей таблице для пустого значения в колонке с полом укажите 
‘unknown’ (без кавычек). Возможно, для этого придётся вспомнить, как работает COALESCE.
Результат отсортируйте по колонке с полом пользователя по возрастанию.

Поля в результирующей таблице: sex, avg_cancel_rate*/

SELECT COALESCE(sex, 'unknown') AS sex,
	ROUND(AVG(cancel_rate), 3) AS avg_cancel_rate
FROM (
	SELECT user_id,
       COUNT(distinct order_id) FILTER (WHERE action = 'cancel_order') / COUNT(DISTINCT order_id)::decimal AS cancel_rate
	FROM user_actions
	GROUP BY user_id 
) q1
	LEFT JOIN users USING(user_id)
GROUP BY sex
ORDER BY sex;

18. /*По таблицам orders и courier_actions определите id десяти заказов, которые доставляли дольше всего.
Поле в результирующей таблице: order_id*/

SELECT order_id
FROM (
	SELECT order_id,
		time - creation_time AS diff_time
	FROM orders
		LEFT JOIN courier_actions USING(order_id)
	WHERE action = 'deliver_order'
	ORDER BY diff_time desc
	LIMIT 10
) q1;


/*Theory. ARRAY_AGG()
ARRAY_AGG() — это агрегатная функция, которая объединяет значения из нескольких строк в массив (противоположность unnest()). Она полезна,
когда нужно вернуть несколько значений в одной строке или сгруппировать значения из связанных записей. */


19. /*Произведите замену списков с id товаров из таблицы orders на списки с наименованиями товаров. Наименования возьмите из таблицы 
products. Колонку с новыми списками наименований назовите product_names. 
Добавьте в запрос оператор LIMIT и выведите только первые 1000 строк результирующей таблицы.

Поля в результирующей таблице: order_id, product_names*/

SELECT order_id,
	array_agg(name) AS product_names
FROM (
	SELECT order_id,
		unnest(product_ids) AS product_id
	FROM orders
) q1
LEFT JOIN products USING(product_id)
GROUP BY order_id
LIMIT 1000;

20./*Выясните, кто заказывал и доставлял самые большие заказы. Самыми большими считайте заказы с наибольшим числом товаров.
Выведите id заказа, id пользователя и id курьера. Также в отдельных колонках укажите возраст пользователя и возраст курьера. Возраст 
измерьте числом полных лет, как мы делали в прошлых уроках. Считайте его относительно последней даты в таблице user_actions — как для 
пользователей, так и для курьеров. Колонки с возрастом назовите user_age и courier_age. Результат отсортируйте по возрастанию id заказа.

Поля в результирующей таблице: order_id, user_id, user_age, courier_id, courier_age*/

WITH order_size AS ( 
    SELECT order_id
    FROM orders
    WHERE array_length(product_ids, 1) = (
        SELECT MAX(array_length(product_ids, 1))
        FROM orders
    )
)

SELECT DISTINCT order_id,
  user_id,
  DATE_PART('year', age(
      (SELECT MAX(time) FROM user_actions),
      users.birth_date
  ))::int AS user_age,
  courier_id,
  DATE_PART('year', age(
      (SELECT MAX(time) FROM user_actions),
      couriers.birth_date
  ))::int AS courier_age
FROM (
    SELECT order_id, user_id
    FROM user_actions
    WHERE order_id IN (
        SELECT order_id
        FROM order_size
    )
) q1
LEFT JOIN (
    SELECT order_id, courier_id
    FROM courier_actions
    WHERE order_id IN (
        SELECT order_id
        FROM order_size
    )
) q2 USING(order_id)
LEFT JOIN users USING(user_id)
LEFT JOIN couriers USING(courier_id)
ORDER BY order_id;

21. /*Выясните, какие пары товаров покупают вместе чаще всего. Пары товаров сформируйте на основе таблицы с заказами. Отменённые заказы 
не учитывайте. В качестве результата выведите две колонки — колонку с парами наименований товаров и колонку со значениями, показывающими,
сколько раз конкретная пара встретилась в заказах пользователей. Колонки назовите соответственно pair и count_pair.
Пары товаров должны быть представлены в виде списков из двух наименований. Пары товаров внутри списков должны быть отсортированы в 
порядке возрастания наименования. Результат отсортируйте сначала по убыванию частоты встречаемости пары товаров в заказах, затем по 
колонке pair — по возрастанию.

Поля в результирующей таблице: pair, count_pair*/

-- 1 вариант

WITH list AS (
    SELECT order_id, name
    FROM (
        SELECT order_id,
               unnest(product_ids) AS product_id
        FROM orders
    ) q1
    JOIN products p USING(product_id)
    WHERE order_id NOT IN (
        SELECT order_id
        FROM user_actions
        WHERE action = 'cancel_order'
    )
),

pairs AS (
    SELECT DISTINCT
           l1.order_id,
           ARRAY[
               LEAST(l1.name, l2.name),
               GREATEST(l1.name, l2.name)
           ] AS pair          -- упорядывачиваем названия в паре
    FROM list l1
    JOIN list l2 ON l1.order_id = l2.order_id
    WHERE l1.name < l2.name   -- гарантируем уникальность пары в заказе
)

SELECT pair,
       COUNT(*) AS count_pair
FROM pairs
GROUP BY pair
ORDER BY count_pair DESC, pair;

-- 2 вариант

WITH table AS (
	SELECT DISTINCT order_id,
        product_id,
        name
    FROM (SELECT order_id,
            	unnest(product_ids) AS product_id
          FROM orders
          WHERE order_id NOT IN (SELECT order_id
                                 FROM user_actions
                                 WHERE action = 'cancel_order')) q1
        LEFT JOIN products using(product_id)
    ORDER BY order_id, name)

SELECT pair,
       COUNT(order_id) AS count_pair
FROM (SELECT DISTINCT a.order_id,
                      CASE WHEN a.name > b.name THEN STRING_TO_ARRAY(CONCAT(b.name, '+', a.name), '+')
                      ELSE STRING_TO_ARRAY(CONCAT(a.name, '+', b.name), '+') 
                  	  END AS pair
      FROM table a 
      	JOIN table b ON a.order_id = b.order_id AND a.name != b.name
      ) q2
GROUP BY pair
ORDER BY count_pair desc, pair;