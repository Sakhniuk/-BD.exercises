DROP TABLE IF EXISTS student_grades;
DROP TABLE IF EXISTS university_students;
DROP TABLE IF EXISTS university_courses;
DROP TABLE IF EXISTS student_groups;

CREATE TABLE student_groups (
    group_id SERIAL PRIMARY KEY,
    group_name VARCHAR(50) NOT NULL,
    study_year INT NOT NULL
);

CREATE TABLE university_students (
    student_id SERIAL PRIMARY KEY,
    student_name VARCHAR(100) NOT NULL,
    group_id INT,
    FOREIGN KEY (group_id) REFERENCES student_groups(group_id)
);

CREATE TABLE university_courses (
    course_id SERIAL PRIMARY KEY,
    course_name VARCHAR(100) NOT NULL,
    study_year INT NOT NULL,
    min_semester INT DEFAULT 1
);

CREATE TABLE student_grades (
    grade_id SERIAL PRIMARY KEY,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    grade DECIMAL(5,2) CHECK (grade >= 0 AND grade <= 100),
    grade_date DATE NOT NULL,
    FOREIGN KEY (student_id) REFERENCES university_students(student_id),
    FOREIGN KEY (course_id) REFERENCES university_courses(course_id)
);

INSERT INTO student_groups (group_name, study_year) VALUES
('IM-43', 1),
('IM-44', 2);

INSERT INTO university_students (student_name, group_id) VALUES
('Іваненко Петро', 1),
('Петренко Олена', 1),
('Сахнюк Юлія', 2);

INSERT INTO university_courses (course_name, study_year, min_semester) VALUES
('Основи програмування', 1, 1),
('Математичний аналіз', 1, 1),
('Обєктно-орієнтоване програмування', 2, 3),
('Бази даних', 2, 3);

INSERT INTO student_grades (student_id, course_id, grade, grade_date) VALUES

(1, 1, 85.5, '2025-01-15'),
(1, 2, 78.0, '2025-01-20'),
(1, 3, 91.0, '2025-02-10'),

(2, 1, 91.0, '2025-01-15'),
(2, 2, 88.5, '2025-01-20'),

(3, 3, 94.0, '2025-02-10'),
(3, 4, 89.0, '2025-02-15'),
(3, 1, 76.0, '2025-01-25'),
(3, 2, 82.5, '2025-01-30');


SELECT 
    course_name AS course,
    study_year AS year,
    min_semester AS minimum_semester
FROM university_courses
ORDER BY study_year, min_semester, course_name;


WITH student_enrollment_count AS (
    SELECT 
        university_students.student_id,
        university_students.student_name,
        COUNT(DISTINCT student_grades.course_id) AS enrolled_courses
    FROM university_students
    LEFT JOIN student_grades ON university_students.student_id = student_grades.student_id
    GROUP BY university_students.student_id, university_students.student_name
),
average_enrollment AS (
    SELECT AVG(enrolled_courses) AS average_courses
    FROM student_enrollment_count
)
SELECT 
    student_enrollment_count.student_id,
    student_enrollment_count.student_name,
    student_enrollment_count.enrolled_courses,
    ROUND(average_enrollment.average_courses::numeric, 2) AS average_courses_per_student
FROM student_enrollment_count, average_enrollment
WHERE student_enrollment_count.enrolled_courses > average_enrollment.average_courses
ORDER BY student_enrollment_count.enrolled_courses DESC;


WITH course_student_ranking AS (
    SELECT 
        university_courses.course_name,
        university_students.student_name,
        student_grades.grade,
        ROW_NUMBER() OVER (
            PARTITION BY university_courses.course_id 
            ORDER BY student_grades.grade DESC
        ) AS rank_position
    FROM student_grades
    JOIN university_students ON student_grades.student_id = university_students.student_id
    JOIN university_courses ON student_grades.course_id = university_courses.course_id
    WHERE student_grades.grade IS NOT NULL
)
SELECT 
    course_name,
    student_name,
    grade,
    rank_position
FROM course_student_ranking
WHERE rank_position <= 3
ORDER BY course_name, rank_position;