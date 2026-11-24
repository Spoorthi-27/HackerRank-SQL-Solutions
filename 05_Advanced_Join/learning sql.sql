
WITH DailyCounts AS (
    SELECT
        submission_date,
        hacker_id,
        COUNT(*) AS total_submissions
    FROM Submissions
    GROUP BY submission_date, hacker_id
),

RankedHackers AS (
    SELECT
        submission_date,
        hacker_id,
        total_submissions,
        ROW_NUMBER() OVER (
            PARTITION BY submission_date
            ORDER BY total_submissions DESC, hacker_id ASC
        ) AS rn
    FROM DailyCounts
),

StreakCounts AS (
    SELECT
        d.submission_date,
        COUNT(DISTINCT s.hacker_id) AS total_hackers
    FROM (
        SELECT DISTINCT submission_date
        FROM Submissions
    ) d
    JOIN Submissions s
        ON s.submission_date = d.submission_date
    WHERE (
        SELECT COUNT(DISTINCT s2.submission_date)
        FROM Submissions s2
        WHERE s2.hacker_id = s.hacker_id
          AND s2.submission_date <= d.submission_date
    ) = DATEDIFF(d.submission_date, '2016-03-01') + 1
    GROUP BY d.submission_date
)

SELECT
    r.submission_date,
    s.total_hackers,
    r.hacker_id,
    h.name
FROM RankedHackers r
JOIN StreakCounts s
    ON r.submission_date = s.submission_date
JOIN Hackers h
    ON r.hacker_id = h.hacker_id
WHERE r.rn = 1
ORDER BY r.submission_date;
