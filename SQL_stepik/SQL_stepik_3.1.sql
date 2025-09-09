3.1 База данных «Тестирование», запросы на выборку

1. 

/*Вывести студентов, которые сдавали дисциплину «Основы баз данных», указать дату попытки и результат. Информацию вывести 
по убыванию результатов тестирования.*/

SELECT name_student, date_attempt, result
FROM subject s
    INNER JOIN attempt a ON s.subject_id = a.subject_id AND name_subject = 'Основы баз данных'
    INNER JOIN student st ON a.student_id = st.student_id
ORDER BY result DESC;

2.

/*Вывести, сколько попыток сделали студенты по каждой дисциплине, а также средний результат попыток, который округлить до 2 знаков после запятой. 
Под результатом попытки понимается процент правильных ответов на вопросы теста, который занесен в столбец result.  
В результат включить название дисциплины, а также вычисляемые столбцы Количество и Среднее. Информацию вывести по убыванию средних результатов.*/

SELECT name_subject, 
    COUNT(attempt_id) Количество,
    ROUND(AVG(result), 2) Среднее
FROM attempt
    RIGHT JOIN subject USING(subject_id)
GROUP BY name_subject
ORDER BY Среднее DESC;

3.

/*Вывести студентов (различных студентов), имеющих максимальные результаты попыток. Информацию отсортировать в алфавитном порядке по фамилии студента.
Максимальный результат не обязательно будет 100%, поэтому явно это значение в запросе не задавать.*/

SELECT DISTINCT name_student, result
FROM attempt
    RIGHT JOIN student USING(student_id)
WHERE result = (
    SELECT MAX(result)
    FROM attempt
    )
ORDER BY name_student;

4.

/*Если студент совершал несколько попыток по одной и той же дисциплине, то вывести разницу в днях между первой и последней попыткой. 
В результат включить фамилию и имя студента, название дисциплины и вычисляемый столбец Интервал. Информацию вывести по возрастанию разницы. 
Студентов, сделавших одну попытку по дисциплине, не учитывать. */

SELECT name_student, name_subject,
    DATEDIFF(MAX(date_attempt), MIN(date_attempt)) Интервал
FROM attempt
    INNER JOIN student USING(student_id)
    INNER JOIN subject USING(subject_id)
GROUP BY name_student, name_subject
HAVING COUNT(date_attempt) > 1
ORDER BY Интервал;

5.

/*Студенты могут тестироваться по одной или нескольким дисциплинам (не обязательно по всем). Вывести дисциплину и количество уникальных студентов 
(столбец назвать Количество), которые по ней проходили тестирование . Информацию отсортировать сначала по убыванию количества, 
а потом по названию дисциплины. В результат включить и дисциплины, тестирование по которым студенты еще не проходили, 
в этом случае указать количество студентов 0.*/

SELECT DISTINCT name_subject,
    COUNT(DISTINCT student_id) Количество
FROM subject
    LEFT JOIN attempt USING(subject_id)
GROUP BY name_subject
ORDER BY Количество DESC, name_subject;

6.

/*Случайным образом отберите 3 вопроса по дисциплине «Основы баз данных». В результат включите столбцы question_id и name_question.*/

SELECT question_id, name_question
FROM question
    INNER JOIN subject USING(subject_id)
WHERE name_subject = 'Основы баз данных'
ORDER BY RAND()
LIMIT 3;

7.

/*Вывести вопросы, которые были включены в тест для Семенова Ивана по дисциплине «Основы SQL» 2020-05-17  (значение attempt_id для этой попытки равно 7).
Указать, какой ответ дал студент и правильный он или нет (вывести Верно или Неверно). В результат включить вопрос, ответ и вычисляемый столбец  Результат.*/

SELECT 
	name_question, 
	answer.name_answer, 
	IF(is_correct, 'Верно', 'Неверно') Результат 
FROM 
	answer 
	INNER JOIN testing ON answer.answer_id = testing.answer_id 
	INNER JOIN question ON testing.question_id = question.question_id 
WHERE testing.attempt_id = (
    SELECT 
      attempt_id 
    FROM 
      attempt 
      INNER JOIN subject USING(subject_id) 
      INNER JOIN student USING(student_id) 
    WHERE 
      date_attempt = '2020-05-17' 
      AND name_student = 'Семенов Иван' 
      AND name_subject = 'Основы SQL'
  );

8.

/*Посчитать результаты тестирования. Результат попытки вычислить как количество правильных ответов, деленное на 3 (количество вопросов в каждой попытке) 
и умноженное на 100. Результат округлить до двух знаков после запятой. Вывести фамилию студента, название предмета, дату и результат. 
Последний столбец назвать Результат. Информацию отсортировать сначала по фамилии студента, потом по убыванию даты попытки.*/

SELECT name_student,
    name_subject,
    date_attempt,
    ROUND(SUM(is_correct)/3*100, 2) Результат
FROM answer
    INNER JOIN testing USING(answer_id)
    INNER JOIN attempt USING(attempt_id)
    INNER JOIN subject USING(subject_id)     
    INNER JOIN student USING(student_id)
GROUP BY date_attempt, name_student, name_subject
ORDER BY name_student, date_attempt DESC;

9.

/*Для каждого вопроса вывести процент успешных решений, то есть отношение количества верных ответов к общему количеству ответов, значение округлить до
2-х знаков после запятой. Также вывести название предмета, к которому относится вопрос, и общее количество ответов на этот вопрос. 
В результат включить название дисциплины, вопросы по ней (столбец назвать Вопрос), а также два вычисляемых столбца Всего_ответов и Успешность. 
Информацию отсортировать сначала по названию дисциплины, потом по убыванию успешности, а потом по тексту вопроса в алфавитном порядке.
Поскольку тексты вопросов могут быть длинными, обрезать их 30 символов и добавить многоточие "...".*/

/*1. Чтобы выделить крайние левые n символов из строки используется функция LEFT(строка, n):
LEFT("abcde", 3) -> "abc"

2. Соединение строк осуществляется с помощью функции CONCAT(строка_1, строка_2):
CONCAT("ab","cd") -> "abcd"*/

SELECT name_subject,
    CONCAT(LEFT(name_question, 30), '...') Вопрос,
    COUNT(testing.answer_id) Всего_ответов,
    ROUND(SUM(is_correct)/COUNT(testing.answer_id)*100, 2) Успешность
FROM subject
    INNER JOIN question  USING(subject_id)
    INNER JOIN testing  USING(question_id)
    INNER JOIN answer  USING(answer_id)
GROUP BY name_question, name_subject
ORDER BY name_subject, Успешность DESC, name_question;



3.2 База данных «Тестирование», запросы корректировки

1. 

/*В таблицу attempt включить новую попытку для студента Баранова Павла по дисциплине «Основы баз данных». 
Установить текущую дату в качестве даты выполнения попытки.*/

INSERT INTO attempt (student_id, subject_id, date_attempt)
SELECT student_id, 
    subject_id,
    CURDATE()
FROM attempt
    INNER JOIN subject USING(subject_id)
    INNER JOIN student USING(student_id)
WHERE name_student = 'Баранов Павел' AND name_subject = 'Основы баз данных';

2.

/*Случайным образом выбрать три вопроса (запрос) по дисциплине, тестирование по которой собирается проходить студент, занесенный в таблицу 
attempt последним, и добавить их в таблицу testing. id последней попытки получить как максимальное значение id из таблицы attempt.*/

INSERT INTO testing (attempt_id, question_id) 
SELECT attempt_id, question_id 
FROM attempt 
	INNER JOIN question USING(subject_id) 
WHERE attempt_id = (
    SELECT MAX(attempt_id) 
    FROM attempt
  ) 
	AND question_id IN (
    SELECT question_id 
    FROM question 
    WHERE subject_id = (
        SELECT subject_id 
        FROM attempt 
        WHERE attempt_id = (
            SELECT MAX(attempt_id) 
            FROM attempt
          )
      )
  ) 
ORDER BY RAND() 
LIMIT 3;

-- Другой вариант решения

-- Объявляем переменные
SET @attempt_id = (SELECT MAX(attempt_id) FROM attempt);
SET @subject_id = (SELECT subject_id FROM attempt WHERE attempt_id = @attempt_id);

INSERT INTO testing (attempt_id, question_id)
SELECT
    @attempt_id,
    question_id
FROM
    question
WHERE
    subject_id = @subject_id
ORDER BY
    RAND()
LIMIT 3;

-- Другой вариант решения

INSERT testing (attempt_id, question_id) 
SELECT attempt_id, question_id 
FROM attempt a 
	INNER JOIN question q ON attempt_id = (
    SELECT MAX(attempt_id) 
    FROM attempt
  ) 
	AND q.subject_id = a.subject_id 
ORDER BY RAND() 
LIMIT 3;

3.

/*Студент прошел тестирование (то есть все его ответы занесены в таблицу testing), далее необходимо вычислить результат(запрос) и 
занести его в таблицу attempt для соответствующей попытки.  Результат попытки вычислить как количество правильных ответов, деленное 
на 3 (количество вопросов в каждой попытке) и умноженное на 100. Результат округлить до целого.
Будем считать, что мы знаем id попытки,  для которой вычисляется результат, в нашем случае это 8.*/

UPDATE attempt
SET result = (
    SELECT
        ROUND(SUM(is_correct)/3*100) res
    FROM
        testing
        LEFT JOIN answer USING(answer_id)
    WHERE attempt_id = 8
)
WHERE attempt_id = 8;

4.

/*Удалить из таблицы attempt все попытки, выполненные раньше 1 мая 2020 года. Также удалить и все соответствующие 
этим попыткам вопросы из таблицы testing*/

DELETE FROM attempt
WHERE date_attempt < '2020.05.01';

