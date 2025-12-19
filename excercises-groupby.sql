CREATE TABLE IF NOT EXISTS groups (
    group_id SERIAL PRIMARY KEY,
    group_name VARCHAR(50) NOT NULL,
    year_of_study INT NOT NULL
);

CREATE TABLE IF NOT EXISTS students (
    student_id SERIAL PRIMARY KEY,
    student_name VARCHAR(100) NOT NULL,
    group_id INT,
    FOREIGN KEY (group_id) REFERENCES groups(group_id)
);

CREATE TABLE IF NOT EXISTS courses (
    course_id SERIAL PRIMARY KEY,
    course_name VARCHAR(100) NOT NULL,
    year_of_study INT NOT NULL
);

CREATE TABLE IF NOT EXISTS grades (
    grade_id SERIAL PRIMARY KEY,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    grade DECIMAL(5,2) CHECK (grade >= 0 AND grade <= 100),
    grade_date DATE NOT NULL,
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
);

INSERT INTO groups (group_name, year_of_study) VALUES
('IM-43', 1),
('IM-44', 2);

INSERT INTO students (student_name, group_id) VALUES
('Іваненко Петро', 1),
('Петренко Олена', 1),
('Сахнюк Юлія', 2),
('Франко Іван', 2);

INSERT INTO courses (course_name, year_of_study) VALUES
('Основи програмування', 1),
('Математичний аналіз', 1),
('Обєктно-орієнтоване програмування', 2),
('Бази даних', 2);

INSERT INTO grades (student_id, course_id, grade, grade_date) VALUES
(1, 1, 85.5, '2025-01-15'),
(1, 2, 78.0, '2025-01-20'),
(2, 1, 91.0, '2025-01-15'),
(2, 2, 88.5, '2025-01-20'),
(3, 3, 88.0, '2025-02-10'),
(3, 4, 92.5, '2025-02-15'),
(4, 3, 76.5, '2025-02-10'),
(4, 4, 81.0, '2025-02-15');

SELECT 
    groups.year_of_study,
    COUNT(DISTINCT students.student_id) AS number_of_students,
    ROUND(AVG(grades.grade), 2) AS average_score,
    ROUND(COUNT(CASE WHEN grades.grade >= 60 THEN 1 END) * 100.0 / COUNT(grades.grade), 2) AS success_rate
FROM groups
JOIN students ON groups.group_id = students.group_id
JOIN grades ON students.student_id = grades.student_id
GROUP BY groups.year_of_study
ORDER BY groups.year_of_study;



WITH averagescore_student AS (
    SELECT 
        students.student_id,
        students.student_name,
        groups.group_name,
        groups.year_of_study,
        ROUND(AVG(grades.grade), 2) AS average_score_student
    FROM students
    JOIN groups ON students.group_id = groups.group_id
    JOIN grades ON students.student_id = grades.student_id
    GROUP BY students.student_id, students.student_name, groups.group_name, groups.year_of_study
),
averagescore_group AS (
    SELECT 
        groups.year_of_study,
        groups.group_name,
        ROUND(AVG(grades.grade), 2) AS average_score_group
    FROM students
    JOIN groups ON students.group_id = groups.group_id
    JOIN grades ON students.student_id = grades.student_id
    GROUP BY groups.year_of_study, groups.group_name
)
SELECT 
    ast.student_id,
    ast.student_name,
    ast.group_name,
    ast.year_of_study,
    ast.average_score_student,
    ag.average_score_group,
    ROUND(ast.average_score_student - ag.average_score_group, 2) AS difference
FROM averagescore_student ast
JOIN averagescore_group ag ON ast.year_of_study = ag.year_of_study 
                  AND ast.group_name = ag.group_name
ORDER BY ast.year_of_study, ast.average_score_student DESC;


SELECT 
    groups.year_of_study,
    COUNT(DISTINCT courses.course_id) AS number_of_courses,
    COUNT(grades.grade_id) AS number_of_ratings,
    COUNT(DISTINCT CASE WHEN grades.grade IS NOT NULL THEN students.student_id END) AS students_with_grades,
    COUNT(DISTINCT students.student_id) AS total_students
FROM groups
JOIN students ON groups.group_id = students.group_id
JOIN courses ON groups.year_of_study = courses.year_of_study
LEFT JOIN grades ON students.student_id = grades.student_id AND courses.course_id = grades.course_id
GROUP BY groups.year_of_study
ORDER BY groups.year_of_study;

