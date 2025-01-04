COPY company_dim
FROM 'C:\Users\Lenovo\OneDrive\Documents\SQL TUTORIALS\SQL_Project_Data_Job_Analysis\csv_files\company_dim.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

COPY skills_dim
FROM 'C:\Users\Lenovo\OneDrive\Documents\SQL TUTORIALS\SQL_Project_Data_Job_Analysis\csv_files\job_postings_fact.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

COPY job_postings_fact
FROM 'C:\Users\Lenovo\OneDrive\Documents\SQL TUTORIALS\SQL_Project_Data_Job_Analysis\csv_files\skills_dim.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

COPY skills_job_dim
FROM 'C:\Users\Lenovo\OneDrive\Documents\SQL TUTORIALS\SQL_Project_Data_Job_Analysis\csv_files\skills_job_dim.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

SELECT * 
FROM job_postings_fact
LIMIT 100; 

SELECT
    COUNT(job_id) AS job_posted_count,
    EXTRACT(MONTH FROM job_posted_date) AS month
FROM
    job_postings_fact
WHERE
    job_title_short = 'Data Analyst'
GROUP BY
    month
ORDER BY
    job_posted_count DESC;



CREATE TABLE january_jobs AS 
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 1;

CREATE TABLE february_jobs AS 
    SELECT * 
    FROM job_postings_fact 
    WHERE EXTRACT(MONTH FROM job_posted_date) = 2;

CREATE TABLE march_jobs AS 
    SELECT * 
    FROM job_postings_fact 
    WHERE EXTRACT(MONTH FROM job_posted_date) = 3;

SELECT job_posted_date
FROM march_jobs;


SELECT
    COUNT(job_id) AS number_of_jobs,
    CASE
        WHEN job_location = 'Anywhere' THEN 'Remote'
        WHEN job_location = 'New York, NY' THEN 'Local'
        ELSE 'Onsite'
    END AS location_category
FROM job_postings_fact
WHERE 
    job_title_short = 'Data Analyst'
GROUP BY
    location_category;


SELECT *
FROM (
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 1
)  AS january_jobs;



/*  */
WITH january_jobs AS (
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 1
)

SELECT *
FROM january_jobs;
/*  */



/*  */
SELECT
    company_id,
    name AS company_name
FROM 
    company_dim
WHERE 
    company_id IN (
    SELECT 
            company_id
    FROM
            job_postings_fact
    WHERE
            job_no_degree_mention = true
)
/*  */



/*  */
WITH company_job_count AS (
    SELECT
            company_id,
            COUNT(*)
    FROM
            job_postings_fact
    GROUP BY
            company_id
)

SELECT *
FROM company_job_count
/*  */



/*  */
WITH company_job_count AS (
    SELECT
            company_id,
            COUNT(*) AS total_jobs
    FROM
            job_postings_fact
    GROUP BY
            company_id
)

SELECT 
        company_dim.name AS company_name,
        company_job_count.total_jobs
FROM company_dim
INNER JOIN company_job_count ON company_job_count.company_id = company_dim.company_id
ORDER BY
    company_job_count.total_jobs DESC
/*  */


/* step-1 */
SELECT
    skill_id,
    COUNT(*) AS skill_count
FROM
    skills_job_dim AS skills_to_job
INNER JOIN job_postings_fact AS job_postings ON job_postings.job_id = skills_to_job.job_id
WHERE
    job_postings.job_work_from_home = True
GROUP BY
    skill_id
/*  */

/* step-2 */
WITH remote_job_skills AS (
    SELECT
        skill_id,
        COUNT(*) AS skill_count
    FROM
        skills_job_dim AS skills_to_job
    INNER JOIN job_postings_fact AS job_postings ON job_postings.job_id = skills_to_job.job_id
    WHERE
        job_postings.job_work_from_home = True AND
        job_postings.job_title_short = 'Data Analyst'
    GROUP BY
        skill_id
)

SELECT 
    skills.skill_id,
    skills AS skill_name,
    skill_count
FROM remote_job_skills
INNER JOIN skills_dim AS skills ON skills.skill_id = remote_job_skills.skill_id
ORDER BY
    skill_count DESC
LIMIT 5;
/*  */



/*  */
SELECT
    job_title_short,
    company_id,
    job_location
FROM
    january_jobs

UNION ALL

SELECT
    job_title_short,
    company_id,
    job_location
FROM
    february_jobs

UNION ALL

SELECT
    job_title_short,
    company_id,
    job_location
FROM
    march_jobs
/*  */



/*  */
/*
FInd the job postings from the first quarter that have a salary greater than $70K
- Combine job posting tables from the first quarter of 2023 (Jan-Mar)
- Get job postings with average yearly salary > $70,000 
 */

SELECT
    quarter1_job_postings.job_location,
    quarter1_job_postings.job_via,
    quarter1_job_postings.job_posted_date::DATE,
    quarter1_job_postings.salary_year_avg AS avg_yearly_salary
FROM (
    SELECT *
    FROM january_jobs
    UNION ALL
    SELECT *
    FROM february_jobs
    UNION ALL
    SELECT *
    FROM march_jobs
) AS quarter1_job_postings
WHERE
    salary_year_avg > 70000 AND
    quarter1_job_postings.job_title_short = 'Data Analyst'
ORDER BY
    quarter1_job_postings.salary_year_avg DESC

/*  */