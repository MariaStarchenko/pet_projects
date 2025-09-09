3.3 База данных «Абитуриент», запросы на выборку

1.

/*Вывести абитуриентов, которые хотят поступать на образовательную программу «Мехатроника и робототехника» в отсортированном по фамилиям виде.*/

SELECT name_enrollee
FROM enrollee
    INNER JOIN program_enrollee USING(enrollee_id)
    INNER JOIN program USING(program_id)
WHERE name_program = 'Мехатроника и робототехника'
ORDER BY name_enrollee;

2.

/*Вывести образовательные программы, на которые для поступления необходим предмет «Информатика». Программы отсортировать в обратном алфавитном порядке.*/

SELECT name_program
FROM program p
    INNER JOIN program_subject ps ON p.program_id = ps.program_id
    INNER JOIN subject s ON s.subject_id = ps.subject_id
WHERE name_subject = 'Информатика'
ORDER BY name_program DESC;

3.

/*Выведите количество абитуриентов, сдавших ЕГЭ по каждому предмету, максимальное, минимальное и среднее значение баллов по предмету ЕГЭ. 
Вычисляемые столбцы назвать Количество, Максимум, Минимум, Среднее. Информацию отсортировать по названию предмета в алфавитном порядке, 
среднее значение округлить до одного знака после запятой.*/

SELECT name_subject,
    COUNT(enrollee_id) Количество,
    MAX(result) Максимум,
    MIN(result) Минимум,
    ROUND(AVG(result), 1) Среднее
FROM subject
    INNER JOIN enrollee_subject USING(subject_id)
GROUP BY name_subject
ORDER BY name_subject;

4.

/*Вывести образовательные программы, для которых минимальный балл ЕГЭ по каждому предмету больше или равен 40 баллам. 
Программы вывести в отсортированном по алфавиту виде.*/

SELECT name_program
FROM program
    INNER JOIN program_subject USING(program_id)
GROUP BY name_program
HAVING MIN(min_result) >= 40
ORDER BY name_program;

5.

/*Вывести образовательные программы, которые имеют самый большой план набора,  вместе с этой величиной.*/

SELECT name_program, plan
FROM program
WHERE plan IN (SELECT MAX(plan) FROM program);

6.

/*Посчитать, сколько дополнительных баллов получит каждый абитуриент. Столбец с дополнительными баллами назвать Бонус. 
Информацию вывести в отсортированном по фамилиям виде.*/

SELECT name_enrollee, 
    IFNULL(SUM(bonus), 0) Бонус
FROM enrollee
    LEFT JOIN enrollee_achievement USING(enrollee_id)
    LEFT JOIN achievement USING(achievement_id)
GROUP BY name_enrollee
ORDER BY name_enrollee;

/* Другой вариант решения. Функция COALESCE более универсальная ф-ция для разных СУБД, возвращает первое ненулевое непустое значение 
из предоставленного списка выражений.*/

SELECT name_enrollee, 
    SUM(COALESCE(bonus, 0)) Бонус     -- COALESCE ищет NULL значения в столбце bonus и заменяет их на ноль
FROM enrollee
    LEFT JOIN enrollee_achievement USING(enrollee_id)
    LEFT JOIN achievement USING(achievement_id)
GROUP BY name_enrollee
ORDER BY name_enrollee;

7.

/*Выведите сколько человек подало заявление на каждую образовательную программу и конкурс на нее (число поданных заявлений деленное на количество мест
по плану), округленный до 2-х знаков после запятой. В запросе вывести название факультета, к которому относится образовательная программа, 
название образовательной программы, план набора абитуриентов на образовательную программу (plan), количество поданных заявлений (Количество) и Конкурс. 
Информацию отсортировать в порядке убывания конкурса.*/

SELECT name_department,
    name_program,
    plan,
    COUNT(enrollee_id) AS Количество,
    ROUND(COUNT(enrollee_id)/plan, 2) AS Конкурс
FROM department
    INNER JOIN program USING(department_id)
    LEFT JOIN program_enrollee USING(program_id)
GROUP BY program_id
ORDER BY Конкурс DESC;

/*После GROUP BY задаются ВСЕ столбцы, указанные после SELECT,  к которым не применяются групповые функции или выражения с групповыми функциями. 
В этом запросе это name_department, name_program и plan. Но можно обойтись и program_id*/

8.

/*Вывести образовательные программы, на которые для поступления необходимы предмет «Информатика» и «Математика» в отсортированном по названию программ виде.*/

SELECT name_program
FROM subject s
    INNER JOIN program_subject ps ON s.subject_id = ps.subject_id
    INNER JOIN program p ON ps.program_id = p.program_id
WHERE name_subject = 'Математика' OR name_subject = 'Информатика'
GROUP BY ps.program_id
HAVING COUNT(ps.subject_id) = 2
ORDER BY name_program;

-- Другой вариант решения

/*В шагах:
1) создаётся столбец логического типа, который ставит true, когда name_subject in ('Математика', 'Информатика'), и который не выводится в select - 
это name_subject = 'Информатика' or name_subject = 'Математика'

2) после столбец суммируется по name_program. И если для образовательной программы надо будет сдавать Информатику и Математику (2 предмета), то в сумме 
будет 2. Если образовательная программа не включает сдачу нужных предметов или включает только один из них, то в сумме будет 0 или 1.

3) поэтому having оставляет только те name_program, у которых сумма признаков нужных предметов = 2*/

SELECT name_program
FROM subject 
	INNER JOIN program_subject USING (subject_id)
	INNER JOIN program USING (program_id)
GROUP BY name_program 
HAVING SUM(name_subject = 'Информатика' OR name_subject = 'Математика') = 2 
ORDER BY name_program;

9.

/*Посчитать количество баллов каждого абитуриента на каждую образовательную программу, на которую он подал заявление, по результатам ЕГЭ. 
В результат включить название образовательной программы, фамилию и имя абитуриента, а также столбец с суммой баллов, который назвать itog. 
Информацию вывести в отсортированном сначала по образовательной программе, а потом по убыванию суммы баллов виде.*/

SELECT name_program,
    name_enrollee,
    SUM(result) AS itog
FROM enrollee e
    INNER JOIN program_enrollee pe ON e.enrollee_id = pe.enrollee_id
    INNER JOIN program p ON p.program_id = pe.program_id
    INNER JOIN program_subject ps ON ps.program_id = p.program_id
    INNER JOIN subject s ON s.subject_id = ps.subject_id
    INNER JOIN enrollee_subject es ON es.subject_id = s.subject_id AND es.enrollee_id = e.enrollee_id
GROUP BY ps.program_id, es.enrollee_id
ORDER BY name_program, itog DESC;

10.

/*Вывести название образовательной программы и фамилию тех абитуриентов, которые подавали документы на эту образовательную программу, но не могут быть 
зачислены на нее. Эти абитуриенты имеют результат по одному или нескольким предметам ЕГЭ, необходимым для поступления на эту образовательную программу, 
меньше минимального балла. Информацию вывести в отсортированном сначала по программам, а потом по фамилиям абитуриентов виде.

Например, Баранов Павел по «Физике» набрал 41 балл, а  для образовательной программы «Прикладная механика» минимальный балл по этому предмету определен
в 45 баллов. Следовательно, абитуриент на данную программу не может поступить.*/

SELECT name_program,
    name_enrollee
FROM enrollee
    INNER JOIN program_enrollee USING (enrollee_id)
    INNER JOIN program USING (program_id)
    INNER JOIN program_subject USING (program_id)
    INNER JOIN subject USING (subject_id)
    INNER JOIN enrollee_subject USING (subject_id, enrollee_id)
WHERE result < min_result
ORDER BY name_program, name_enrollee;



3.4 База данных «Абитуриент», запросы корректировки

1.

/*Создать вспомогательную таблицу applicant,  куда включить id образовательной программы, id абитуриента, сумму баллов абитуриентов (столбец itog) 
в отсортированном сначала по id образовательной программы, а потом по убыванию суммы баллов виде */

CREATE TABLE applicant
SELECT program_id, enrollee_id, SUM(result) itog
FROM program_enrollee JOIN program_subject USING (program_id)
                      JOIN enrollee_subject USING (subject_id, enrollee_id)
GROUP BY  enrollee_id, program_id
ORDER BY program_id, itog DESC;

2.

/*Из таблицы applicant, созданной на предыдущем шаге, удалить записи, если абитуриент на выбранную образовательную программу не набрал
минимального балла хотя бы по одному предмету*/

DELETE FROM applicant
USING applicant 
	INNER JOIN program_subject USING(program_id)
    INNER JOIN enrollee_subject USING(enrollee_id, subject_id)
WHERE result < min_result;

3.

/*Повысить итоговые баллы абитуриентов в таблице applicant на значения дополнительных баллов */

UPDATE applicant
    LEFT JOIN 
        (
            SELECT enrollee_id, 
                IFNULL(SUM(bonus), 0) Бонус
            FROM enrollee
                LEFT JOIN enrollee_achievement USING(enrollee_id)
                LEFT JOIN achievement USING(achievement_id)
            GROUP BY enrollee_id
        ) query_in USING (enrollee_id)
SET itog = itog + Бонус;

4. Запросы на удаление (DROP, DELETE, TRUNCATE)

Запрос DROP удаляет полностью таблицу безвозвратно, запрос DELETE удаляет необходимые нам строки либо все строки из таблицы, я
запрос TRUNCATE очищает всю таблицу целиком

1 Используйте DROP, если:

Нужно полностью удалить таблицу (или другую структуру) из базы данных.
Больше не требуется использовать эту таблицу.

2 Используйте DELETE, если:

Нужно удалить только определенные строки (с условием WHERE).
Важно сохранить возможность отката изменений.
Таблица имеет внешние ключи.

3 Используйте TRUNCATE, если:

Нужно быстро удалить все строки из таблицы.
Необходимо сбросить значения автоинкремента.
Таблица не имеет внешних ключей или они временно отключены.

/*Поскольку при добавлении дополнительных баллов, абитуриенты по каждой образовательной программе могут следовать не в порядке убывания суммарных баллов, 
необходимо создать новую таблицу applicant_order на основе таблицы applicant. При создании таблицы данные нужно отсортировать сначала по id образовательной 
программы, потом по убыванию итогового балла. А таблицу applicant, которая была создана как вспомогательная, необходимо удалить.*/

CREATE TABLE applicant_order AS
SELECT program_id, enrollee_id, itog     -- или просто SELECT * FROM applicant
FROM applicant
ORDER BY program_id, itog DESC;

DROP TABLE applicant;

5. Изменение структуры таблиц (ALTER TABLE)

Для изменения структуры таблицы используется оператор ALTER TABLE. С его помощью можно вставить новый столбец, удалить существующий, 
переименовать столбец и пр.

- Для вставки нового столбца используется SQL запросы:

ALTER TABLE таблица ADD имя_столбца тип; - вставляет столбец после последнего
ALTER TABLE таблица ADD имя_столбца тип FIRST; - вставляет столбец перед первым
ALTER TABLE таблица ADD имя_столбца тип AFTER имя_столбца_1; - вставляет столбец после укзанного столбца

- Для удаления столбца используется SQL запросы:

ALTER TABLE таблица DROP COLUMN имя_столбца; - удаляет столбец с заданным именем
ALTER TABLE таблица DROP имя_столбца; - ключевое слово COLUMN не обязательно указывать
ALTER TABLE таблица DROP имя_столбца,
                    DROP имя_столбца_1; - удаляет два столбца

- Для переименования столбца используется  запрос (тип данных указывать обязательно):

ALTER TABLE таблица CHANGE имя_столбца новое_имя_столбца ТИП ДАННЫХ;

- Для изменения типа  столбца используется запрос (два раза указывать имя столбца обязательно): 

ALTER TABLE таблица CHANGE имя_столбца имя_столбца НОВЫЙ_ТИП_ДАННЫХ;

- Для переименования таблицы используется оператор RENAME:

ALTER TABLE имя_таблицы RENAME TO новое_имя_таблицы;


/*Включить в таблицу applicant_order новый столбец str_id целого типа , расположить его перед первым.*/

ALTER TABLE applicant_order ADD str_id INT FIRST;

6. Переменные

Переменные задаются с помощью ключевого слова SET,  перед именем указывается символ @. Например, создадим переменную @row_num и присвоим ей значение 1:

SET @row_num := 1;

Теперь эту переменную можно использовать в запросах,  кроме того в запросах можно изменить ее значение. 
Пример: пронумеруем записи в таблице applicant_order.

SET @row_num := 0;

SELECT *, (@row_num := @row_num + 1) AS str_num
FROM  applicant_order;

/*Занести в столбец str_id таблицы applicant_order нумерацию абитуриентов, которая начинается с 1 для каждой образовательной программы.*/

SET @num_pr := 1;
SET @row_num := 0;

UPDATE applicant_order
SET str_id= if( @num_pr = program_id, @row_num := @row_num + 1, @row_num := 1 AND @num_pr := program_id);

7.

/*Создать таблицу student,  в которую включить абитуриентов, которые могут быть рекомендованы к зачислению  в соответствии с планом набора. 
Информацию отсортировать сначала в алфавитном порядке по названию программ, а потом по убыванию итогового балла.*/

CREATE TABLE student AS
SELECT name_program,
    name_enrollee,
    itog
FROM enrollee
    JOIN applicant_order USING (enrollee_id)
    JOIN program USING (program_id)  
WHERE str_id <= plan
ORDER BY name_program, itog DESC;


