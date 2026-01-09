-- Data Job & Skills Analytics Project
-- Author: Nitish Saini

-- STEP 1: Inspect Raw Data
SELECT *
FROM job_postings_fact
LIMIT 10;

SELECT
    job_id,
    job_title,
    job_location,
    job_schedule_type,
    job_work_from_home,
    salary_year_avg,
    job_posted_date
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL;

-- STEP 2: Filter to Relevant Roles
SELECT
    job_id,
    job_title,
    job_location,
    job_work_from_home,
    salary_year_avg
FROM job_postings_fact
WHERE
    salary_year_avg IS NOT NULL
    AND job_title_short = 'Data Analyst'
    AND job_work_from_home = 'True'
ORDER BY salary_year_avg DESC;

-- STEP 3: Top Paying Remote Data Analyst Jobs
SELECT
    job_id,
    job_title,
    job_location,
    job_schedule_type,
    job_work_from_home,
    salary_year_avg
FROM job_postings_fact
WHERE
    salary_year_avg IS NOT NULL
    AND job_title_short = 'Data Analyst'
    AND job_work_from_home = 'True'
ORDER BY salary_year_avg DESC
LIMIT 10;

-- STEP 4: Most In-Demand Skills
SELECT
    s.skills,
    COUNT(sj.job_id) AS demand_count
FROM job_postings_fact j
JOIN skills_job_dim sj ON j.job_id = sj.job_id
JOIN skills_dim s ON sj.skill_id = s.skill_id
WHERE
    j.job_title_short = 'Data Analyst'
    AND j.job_work_from_home = 'True'
GROUP BY s.skills
ORDER BY demand_count DESC
LIMIT 10;

-- STEP 5: Highest Paying Skills
SELECT
    s.skills,
    ROUND(AVG(j.salary_year_avg), 0) AS avg_salary,
    COUNT(sj.job_id) AS job_count
FROM job_postings_fact j
JOIN skills_job_dim sj ON j.job_id = sj.job_id
JOIN skills_dim s ON sj.skill_id = s.skill_id
WHERE
    j.job_title_short = 'Data Analyst'
    AND j.job_work_from_home = 'True'
    AND j.salary_year_avg IS NOT NULL
GROUP BY s.skills
ORDER BY avg_salary DESC
LIMIT 25;

-- STEP 6: Optimal Skills (Demand + Salary)
WITH skills_demand AS (
    SELECT
        s.skill_id,
        s.skills,
        COUNT(sj.job_id) AS demand_count
    FROM job_postings_fact j
    JOIN skills_job_dim sj ON j.job_id = sj.job_id
    JOIN skills_dim s ON sj.skill_id = s.skill_id
    WHERE
        j.job_title_short = 'Data Analyst'
        AND j.job_work_from_home = 'True'
    GROUP BY s.skill_id, s.skills
),
skills_salary AS (
    SELECT
        s.skill_id,
        s.skills,
        ROUND(AVG(j.salary_year_avg), 0) AS avg_salary
    FROM job_postings_fact j
    JOIN skills_job_dim sj ON j.job_id = sj.job_id
    JOIN skills_dim s ON sj.skill_id = s.skill_id
    WHERE
        j.job_title_short = 'Data Analyst'
        AND j.job_work_from_home = 'True'
        AND j.salary_year_avg IS NOT NULL
    GROUP BY s.skill_id, s.skills
)
SELECT
    d.skills,
    d.demand_count,
    s.avg_salary,
    ROUND((d.demand_count * s.avg_salary) / 1000, 0) AS opportunity_score
FROM skills_demand d
LEFT JOIN skills_salary s ON d.skill_id = s.skill_id
WHERE d.demand_count > 10
ORDER BY d.demand_count DESC, s.avg_salary DESC
LIMIT 25;
