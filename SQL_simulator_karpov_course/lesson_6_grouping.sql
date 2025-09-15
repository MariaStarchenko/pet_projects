-- 6 Урок "Группировка данных"


1. /*Посчитайте количество курьеров мужского и женского пола в таблице couriers.Новую колонку с числом курьеров назовите couriers_count.
Результат отсортируйте по этой колонке по возрастанию.*/

SELECT sex, 
	COUNT(DISTINCT courier_id) AS couriers_count
FROM couriers
GROUP BY sex
ORDER BY couriers_count;

2. /*Посчитайте количество созданных и отменённых заказов в таблице user_actions. Новую колонку с числом заказов назовите orders_count.
Результат отсортируйте по числу заказов по возрастанию.*/

SELECT action,
	COUNT(order_id) AS orders_count
FROM user_actions
GROUP BY action
ORDER BY orders_count;


/*Theory.
DATE_TRUNC() — функция в PostgreSQL, которая обрезает дату или временную метку до указанного уровня точности. она работает аналогично 
округлению ROUND, только для типов данных TIMESTAMP и INTERVAL. Синтаксис у неё такой же, как и у DATE_PART:

SELECT DATE_TRUNC(part, column)

Примеры:

SELECT DATE_TRUNC('month', TIMESTAMP '2022-01-12 08:55:30')

Результат:
01/01/22 00:00

SELECT DATE_TRUNC('day', TIMESTAMP '2022-01-12 08:55:30')

Результат:
12/01/22 00:00	

SELECT DATE_TRUNC('hour', TIMESTAMP '2022-01-12 08:55:30')

Результат:
12/01/22 08:00*/



3. /*Используя группировку и функцию DATE_TRUNC, приведите все даты к началу месяца и посчитайте, сколько заказов было сделано в 
каждом из них. Расчёты проведите по таблице orders. Колонку с усечённой датой назовите month, колонку с количеством заказов — orders_count.
Результат отсортируйте по месяцам — по возрастанию.*/

SELECT DATE_TRUNC('month', creation_time) AS month,
	COUNT(order_id) AS orders_count
FROM orders
GROUP BY DATE_TRUNC('month', creation_time)
ORDER BY month;

4. /*Приведите все даты к началу месяца и посчитайте, сколько заказов было сделано и сколько было отменено в каждом из них.
В этот раз расчёты проведите по таблице user_actions. Колонку с усечённой датой назовите month, колонку с количеством заказов — orders_count.
Результат отсортируйте сначала по месяцам — по возрастанию, затем по типу действия — тоже по возрастанию.*/

SELECT DATE_TRUNC('month', time) AS month,
	action,
	COUNT(order_id) AS orders_count
FROM user_actions
GROUP BY DATE_TRUNC('month', time), action
ORDER BY month, action;

5. /*По данным в таблице users посчитайте максимальный порядковый номер месяца среди всех порядковых номеров месяцев рождения пользователей 
сервиса. С помощью группировки проведите расчёты отдельно в двух группах — для пользователей мужского и женского пола.
Новую колонку с максимальным порядковым номером месяца рождения в группах назовите max_month. Преобразуйте значения в новой колонке 
в формат INTEGER, чтобы порядковый номер был выражен целым числом. Результат отсортируйте по колонке с полом пользователей.*/

SELECT sex,
	MAX(date_part('month', birth_date))::INTEGER AS max_month
FROM users
GROUP BY sex
ORDER BY sex;

6. /*По данным в таблице users посчитайте порядковый номер месяца рождения самого молодого пользователя сервиса. С помощью группировки 
проведите расчёты отдельно в двух группах — для пользователей мужского и женского пола. Новую колонку c порядковым номером месяца рождения 
самого молодого пользователя в группах назовите max_month. Преобразуйте значения в новой колонке в формат INTEGER, чтобы порядковый 
номер был выражен целым числом. Результат отсортируйте по колонке с полом пользователей.*/

SELECT sex,
	date_part('month', MAX(birth_date))::INTEGER AS max_month
FROM users
GROUP BY sex
ORDER BY sex;

7. /*Посчитайте максимальный возраст пользователей мужского и женского пола в таблице users. Возраст измерьте числом полных лет.
Новую колонку с возрастом назовите max_age. Преобразуйте значения в новой колонке в формат INTEGER, чтобы возраст был выражен целым числом.
Результат отсортируйте по новой колонке по возрастанию возраста.*/

SELECT sex,
	date_part('year', AGE(current_date, MIN(birth_date))) AS max_age
FROM users
GROUP BY sex
ORDER BY max_age;

8. /*Разбейте пользователей из таблицы users на группы по возрасту (возраст по-прежнему измеряем числом полных лет) и посчитайте количество
пользователей каждого возраста. Колонку с возрастом назовите age, а колонку с числом пользователей — users_count. Преобразуйте значения 
в колонке с возрастом в формат INTEGER, чтобы возраст был выражен целым числом.
Результат отсортируйте по колонке с возрастом по возрастанию.*/

SELECT date_part('year', AGE(birth_date))::INTEGER AS age,
	COUNT(user_id) AS users_count
FROM users
GROUP BY date_part('year', AGE(birth_date))::INTEGER         -- можно было сгруппировать по алиасу age
ORDER BY age;

9./*Вновь разбейте пользователей из таблицы users на группы по возрасту (возраст по-прежнему измеряем количеством полных лет), только 
теперь добавьте в группировку ещё и пол пользователя. Затем посчитайте количество пользователей в каждой половозрастной группе.
Все NULL значения в колонке birth_date заранее отфильтруйте с помощью WHERE.
Колонку с возрастом назовите age, а колонку с числом пользователей — users_count, имя колонки с полом оставьте без изменений. Преобразуйте 
значения в колонке с возрастом в формат INTEGER, чтобы возраст был выражен целым числом.
Отсортируйте полученную таблицу сначала по колонке с возрастом по возрастанию, затем по колонке с полом — тоже по возрастанию.*/

SELECT date_part('year', AGE(birth_date))::INTEGER AS age,
	sex,
	COUNT(user_id) AS users_count
FROM users
WHERE birth_date IS NOT NULL
GROUP BY age, sex
ORDER BY age, sex;

10. /*Посчитайте количество товаров в каждом заказе, примените к этим значениям группировку и рассчитайте количество заказов в каждой 
группе за неделю с 29 августа по 4 сентября 2022 года включительно. Для расчётов используйте данные из таблицы orders.
Выведите две колонки: размер заказа и число заказов такого размера за указанный период. Колонки назовите соответственно order_size 
и orders_count. Результат отсортируйте по возрастанию размера заказа.*/

SELECT array_length(product_ids, 1) AS order_size,
	COUNT(order_id) AS orders_count
FROM orders
WHERE creation_time BETWEEN '2022-08-29' AND '2022-09-05'
GROUP BY order_size
ORDER BY order_size;

11. /*Посчитайте количество товаров в каждом заказе, примените к этим значениям группировку и рассчитайте количество заказов в каждой 
группе. Учитывайте только заказы, оформленные по будням. В результат включите только те размеры заказов, общее число которых превышает 2000. Для расчётов используйте данные из таблицы orders.
Выведите две колонки: размер заказа и число заказов такого размера. Колонки назовите соответственно order_size и orders_count.
Результат отсортируйте по возрастанию размера заказа.*/

-- 1 вариант

SELECT array_length(product_ids, 1) AS order_size,
	COUNT(order_id) AS orders_count
FROM orders
WHERE date_part('dow', creation_time) NOT IN (0, 6)
GROUP BY order_size
HAVING COUNT(order_id) > 2000
ORDER BY order_size;

-- 2 вариант

SELECT array_length(product_ids, 1) as order_size,
       count(order_id) as orders_count
FROM   orders
WHERE  to_char(creation_time, 'Dy') not in ('Sat', 'Sun')
GROUP BY order_size having count(order_id) > 2000
ORDER BY order_size

12. /*По данным из таблицы user_actions определите пять пользователей, сделавших в августе 2022 года наибольшее количество заказов.
Выведите две колонки — id пользователей и число оформленных ими заказов. Колонку с числом оформленных заказов назовите created_orders.
Результат отсортируйте сначала по убыванию числа заказов, сделанных пятью пользователями, затем по возрастанию id этих пользователей.*/

SELECT user_id,
	COUNT(DISTINCT order_id) AS created_orders
FROM user_actions
WHERE action = 'create_order' 
   AND date_part('month', time) = 8
   AND date_part('year', time) = 2022 
GROUP BY user_id
ORDER BY created_orders desc, user_id
LIMIT 5; 

13. /*По данным таблицы courier_actions определите курьеров, которые в сентябре 2022 года доставили только по одному заказу.
В этот раз выведите всего одну колонку с id курьеров. Колонку с числом заказов в результат включать не нужно.
Результат отсортируйте по возрастанию id курьер*/

SELECT courier_id
FROM courier_actions
WHERE action = 'deliver_order' 
   AND date_part('month', time) = 9
   AND date_part('year', time) = 2022 
GROUP BY courier_id
HAVING COUNT(DISTINCT order_id) = 1
ORDER BY courier_id; 

14. /*Из таблицы user_actions отберите пользователей, у которых последний заказ был создан до 8 сентября 2022 года.
Выведите только их id, дату создания заказа выводить не нужно. Результат отсортируйте по возрастанию id пользователя.*/

SELECT user_id
FROM user_actions
WHERE action = 'create_order'
GROUP BY user_id
HAVING MAX(time) < '2022-09-08'
ORDER BY user_id;

15. /*Разбейте заказы из таблицы orders на 3 группы в зависимости от количества товаров, попавших в заказ:
Малый (от 1 до 3 товаров);
Средний (от 4 до 6 товаров);
Большой (7 и более товаров).
Посчитайте число заказов, попавших в каждую группу. Группы назовите соответственно «Малый», «Средний», «Большой» (без кавычек).
Выведите наименования групп и число товаров в них. Колонку с наименованием групп назовите order_size, а колонку с числом заказов — 
orders_count. Отсортируйте полученную таблицу по колонке с числом заказов по возрастанию.*/

-- 1 вариант

SELECT
	CASE
	WHEN array_length(product_ids, 1) BETWEEN 1 AND 3 THEN 'Малый'
	WHEN array_length(product_ids, 1) BETWEEN 4 AND 6 THEN 'Средний'
	WHEN array_length(product_ids, 1) >= 7 THEN 'Большой'
	END AS order_size,
	COUNT(DISTINCT order_id) AS orders_count
FROM orders
GROUP BY order_size
ORDER BY orders_count;

-- 2 вариант

SELECT case when array_length(product_ids, 1) >= 7 then 'Большой'
            when array_length(product_ids, 1) >= 4 then 'Средний'
            else 'Малый' end as order_size,
       count(order_id) as orders_count
FROM   orders
GROUP BY order_size
ORDER BY orders_count

16. /*Разбейте пользователей из таблицы users на 4 возрастные группы:
от 18 до 24 лет;
от 25 до 29 лет;
от 30 до 35 лет;
не младше 36.
Посчитайте число пользователей, попавших в каждую возрастную группу. Группы назовите соответственно «18-24», «25-29», «30-35», «36+».
В расчётах не учитывайте пользователей, у которых не указана дата рождения. Как и в прошлых задачах, в качестве возраста учитывайте 
число полных лет. Выведите наименования групп и число пользователей в них. Колонку с наименованием групп назовите group_age, а колонку 
с числом пользователей — users_count. Отсортируйте полученную таблицу по колонке с наименованием групп по возрастанию.*/

-- 1 вариант

SELECT 
	CASE
	WHEN date_part('year', AGE(birth_date))::INTEGER >= 36 THEN '36+'
	WHEN date_part('year', AGE(birth_date))::INTEGER >= 30 THEN '30-35'
	WHEN date_part('year', AGE(birth_date))::INTEGER >= 25 THEN '25-29'
	WHEN date_part('year', AGE(birth_date))::INTEGER >= 18 THEN '18-24'
	END AS group_age,	
	COUNT(DISTINCT user_id) AS users_count
FROM users
WHERE birth_date IS NOT NULL
GROUP BY group_age
ORDER BY group_age;

-- 2 вариант

SELECT CASE 
	WHEN date_part('year', age(birth_date)) between 18 and 24 THEN '18-24'
    WHEN date_part('year', age(birth_date)) between 25 and 29 THEN '25-29'
    WHEN date_part('year', age(birth_date)) between 30 and 35 THEN '30-35'
    WHEN date_part('year', age(birth_date)) >= 36 THEN '36+' 
	END as group_age,
    COUNT(user_id) as users_count
FROM   users
WHERE  birth_date IS NOT NULL
GROUP BY group_age
ORDER BY group_age;

17. /*По данным из таблицы orders рассчитайте средний размер заказа по выходным и будням. Группу с выходными днями (суббота и воскресенье) 
назовите «weekend», а группу с будними днями (с понедельника по пятницу) — «weekdays» (без кавычек).
В результат включите две колонки: колонку с группами назовите week_part, а колонку со средним размером заказа — avg_order_size. 
Средний размер заказа округлите до двух знаков после запятой. Результат отсортируйте по колонке со средним размером заказа — по возрастанию.*/

SELECT 
	CASE 
	WHEN date_part('dow', creation_time) IN (0, 6) THEN 'weekend'
	ELSE 'weekdays'
	END AS week_part,
	ROUND(AVG(array_length(product_ids, 1)), 2) AS avg_order_size
FROM orders
GROUP BY week_part
ORDER BY avg_order_size;

18. /*Для каждого пользователя в таблице user_actions посчитайте общее количество оформленных заказов и долю отменённых заказов.
Новые колонки назовите соответственно orders_count и cancel_rate. Колонку с долей отменённых заказов округлите до двух знаков после запятой.
В результат включите только тех пользователей, которые оформили больше трёх заказов и у которых показатель cancel_rate составляет не менее 0.5.
Результат отсортируйте по возрастанию id пользователя.
Поля в результирующей таблице: user_id, orders_count, cancel_rate*/

SELECT user_id,
	COUNT(DISTINCT order_id) AS orders_count,
	ROUND(COUNT(DISTINCT order_id) FILTER (WHERE action = 'cancel_order') / COUNT(DISTINCT order_id)::DECIMAL, 2) AS cancel_rate
FROM user_actions
GROUP BY user_id
HAVING COUNT(DISTINCT order_id) > 3
	AND ROUND(COUNT(DISTINCT order_id) FILTER (WHERE action = 'cancel_order') / COUNT(DISTINCT order_id)::DECIMAL, 2) >=0.5
ORDER BY user_id;

19. /*Для каждого дня недели в таблице user_actions посчитайте:
Общее количество оформленных заказов.
Общее количество отменённых заказов.
Общее количество неотменённых заказов (т.е. доставленных).
Долю неотменённых заказов в общем числе заказов (success rate).
Новые колонки назовите соответственно created_orders, canceled_orders, actual_orders и success_rate. Колонку с долей неотменённых заказов 
округлите до трёх знаков после запятой. Все расчёты проводите за период с 24 августа по 6 сентября 2022 года включительно, чтобы во 
временной интервал попало равное количество разных дней недели. Группы сформируйте следующим образом: выделите день недели из даты с 
помощью функции to_char с параметром 'Dy', также выделите порядковый номер дня недели с помощью функции DATE_PART с параметром 'isodow'. 
Далее сгруппируйте данные по двум полям и проведите все необходимые расчёты.
В результате должна получиться группировка по двум колонкам: с порядковым номером дней недели и их сокращёнными наименованиями.
Результат отсортируйте по возрастанию порядкового номера дня недели.

Поля в результирующей таблице: weekday_number, weekday, created_orders, canceled_orders, actual_orders, success_rate*/

SELECT 
	date_part('isodow', time)::INT AS weekday_number,
    to_char(time, 'Dy') AS weekday,
	COUNT(DISTINCT order_id) FILTER (WHERE action = 'create_order') AS created_orders,
	COUNT(DISTINCT order_id) FILTER (WHERE action = 'cancel_order') AS canceled_orders,
    COUNT(order_id) FILTER (WHERE action = 'create_order') - COUNT(order_id) FILTER (WHERE action = 'cancel_order') AS actual_orders,
    ROUND((COUNT(order_id) FILTER (WHERE action = 'create_order') 
    		- COUNT(order_id) FILTER (WHERE action = 'cancel_order'))::DECIMAL 
    		/ COUNT(order_id) FILTER (WHERE action = 'create_order'),
         3) AS success_rate
FROM user_actions
WHERE time BETWEEN '2022-08-24' AND '2022-09-07'
GROUP BY weekday_number, weekday
ORDER BY weekday_number;