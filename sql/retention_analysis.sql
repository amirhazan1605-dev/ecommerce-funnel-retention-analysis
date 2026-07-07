-- ============================================================
-- RETENTION PREP: Verify the data's time span
-- ------------------------------------------------------------
-- Purpose: Confirm the data covers enough weeks to justify
--          WEEKLY cohorts (rather than daily). Checked before
--          designing the cohort analysis - do not assume span.
-- Result:  first event 2020-09-24, last 2021-02-28 (~22.5 weeks)
--          -> comfortably enough for weekly cohorts.
-- ============================================================

SELECT
    MIN(event_time) AS first_event,
    MAX(event_time) AS last_event,
    ROUND(EXTRACT(EPOCH FROM (MAX(event_time) - MIN(event_time))) / (60*60*24*7), 1)
        AS span_in_weeks
FROM events;

-- ============================================================
-- RETENTION: Weekly cohort table (raw user counts)
-- ------------------------------------------------------------
-- Purpose: For every shopper, find the week they first appeared
--          (their "cohort"), then count how many unique shoppers
--          from each cohort were active in each following week.
-- Output:  A tall summary table with 3 columns:
--          cohort_week  = the Monday of the shopper's first week
--          week_number  = weeks since that cohort started (0,1,2...)
--          unique_users = count of distinct active shoppers
-- Note:    This small summary is exported to CSV and reshaped in
--          Python (pandas/NumPy) into the final retention % matrix.
--          "Active" = any event (view, cart, or purchase).
-- ============================================================

WITH user_first_week AS (
    SELECT
        user_id,
        DATE_TRUNC('week', MIN(event_time)) AS cohort_week
    FROM events
    GROUP BY user_id
),
events_with_cohort AS (
    SELECT
        e.user_id,
        u.cohort_week,
        FLOOR(
            EXTRACT(EPOCH FROM (DATE_TRUNC('week', e.event_time) - u.cohort_week))
            / (60*60*24*7)
        ) AS week_number
    FROM events e
    JOIN user_first_week u ON e.user_id = u.user_id
)
SELECT
    cohort_week,
    week_number,
    COUNT(DISTINCT user_id) AS unique_users
FROM events_with_cohort
GROUP BY cohort_week, week_number
ORDER BY cohort_week, week_number;