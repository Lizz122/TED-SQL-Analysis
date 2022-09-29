/*
TED Talks Data Exploration

Skills used: Joins, CTEs, Window Functions, Aggregate Functions, Creating Tables, Creating Views.
*/



CREATE TABLE TED 
(
  Speaker character varying(255),
  Talk_title character varying(255),
  When_posted character varying(255),
  Talk_duration timestamp,
  Likes_number integer,
  Views_number integer,
  Event_name character varying(255),
  Links character varying(255)
)

COPY TED (Speaker,
  Talk_title,
  When_posted,
  Talk_duration,
  Likes_number,
  Views_number,
  Event_name,
  Links 
) 
FROM 'C:\Users\Public\TEDtalks1.csv' DELIMITER ',' CSV HEADER;


CREATE TABLE TED2 (
	Speaker character varying(255),
    Occupation character varying(255)
)

COPY TED2 (
	Speaker,
    Occupation   
) 
FROM 'C:\Users\Public\TEDtalks2.csv' DELIMITER ',' CSV HEADER;


-- We'll work with the first table (TED) first. We will then join the other table (TED2) later on.

-- Checking if we have duplicate data 
-- Duplicate records may cause the results of the analysis to be marred

SELECT talk_title
FROM TED
GROUP BY talk_title
HAVING COUNT(*) > 1   --No duplicate data found.

-- Speakers that have presented more than one Ted talk

SELECT speaker, COUNT(talk_title) AS talk_count
FROM TED
GROUP BY speaker
HAVING COUNT(talk_title) > 1
ORDER BY COUNT(talk_title) DESC

-- Most viewed talks of all time

SELECT speaker, talk_title, MAX(views_number) AS max_views
FROM TED
GROUP BY speaker, talk_title
ORDER BY MAX(views_number) DESC

-- Comparing the first ever Ted Talks (June & July 2006) with the latest Ted Talks(September 2022)

SELECT * 
FROM TED 
WHERE when_posted IN ('22-Sep', '6-Jun', '6-Jul')
ORDER BY likes_number 

-- Total number of Ted talks per year

SELECT when_posted,
SUM(views_number) AS total_views
FROM TED
GROUP BY when_posted
ORDER BY SUM(views_number) DESC

-- Exploring the busiest times of the year for TED Talks by events

SELECT event_name, when_posted,
COUNT(when_posted)OVER(PARTITION BY event_name) AS posted_count
FROM TED
GROUP BY event_name,when_posted
ORDER BY posted_count DESC


--Most popular TED events as per the total number of views and total number of talks at those events. 
 
WITH CTE AS (
	SELECT speaker, talk_title,event_name,
    SUM(views_number) OVER(PARTITION BY event_name ORDER BY views_number) AS total_views
    FROM TED
),

CTE2 AS (
	SELECT event_name, MAX(total_views) AS max_views
    FROM CTE
    GROUP BY event_name
    ORDER BY MAX(total_views) DESC
),

CTE3 AS (
	SELECT event_name, COUNT(talk_title) AS talk_count
    FROM TED
    GROUP BY event_name 
    ORDER BY COUNT(talk_title) DESC
)

SELECT CTE.event_name, CTE2.max_views, CTE3.talk_count
FROM CTE
INNER JOIN CTE2 ON CTE.event_name = CTE2.event_name
INNER JOIN CTE3 ON CTE.event_name = CTE3.event_name
GROUP BY CTE.event_name, CTE2.max_views, CTE3.talk_count
ORDER BY max_views DESC, talk_count


-- Create view by joining data from the two tables for further analysis 

CREATE VIEW TED_3 AS
SELECT TED2.speaker, TED2.occupation, TED.talk_title, TED.views_number, TED.event_name, TED.when_posted,TED.talk_duration
FROM TED2
INNER JOIN TED
ON TED2.speaker = TED.speaker


-- Most represented occupations in TED Talks and the total number of views for those occupations

WITH CTE AS (
	SELECT occupation, SUM(views_number) AS sum_views
    FROM TED_3
    GROUP BY occupation
    ORDER BY SUM(views_number)DESC
),

CTE2 AS (
	SELECT occupation, COUNT(occupation) AS occupation_count
    FROM TED_3 
    GROUP BY occupation
    ORDER BY COUNT(occupation) DESC
) 

SELECT CTE.occupation, CTE.sum_views, CTE2.occupation_count
FROM CTE
INNER JOIN CTE2 ON CTE.occupation = CTE2.occupation
GROUP BY CTE.occupation, CTE.sum_views, CTE2.occupation_count
ORDER BY sum_views DESC, occupation_count

