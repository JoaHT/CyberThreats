
-- We check which Attack type is the most frequent, as well as the one with the most Average Millions Lost.
SELECT Attack_Type, ROUND(AVG(Financial_Loss_in_Million),2) as Average_Loss_Millions, AVG(Number_of_Affected_Users) as Average_Affected_users, COUNT(*) as Number_of_Attacks
FROM [Global_Cybersecurity_Threats_2015-2024]
GROUP BY Attack_Type
ORDER BY Average_Loss_Millions DESC;


SELECT Year, COUNT(*) as Number_per_year
FROM [Global_Cybersecurity_Threats_2015-2024]
GROUP BY Year
ORDER BY Number_per_year DESC;

SELECT Attack_Type, AVG(Incident_Resolution_Time_in_Hours) AS Average_of_Hours_taken
FROM [Global_Cybersecurity_Threats_2015-2024]
GROUP BY Attack_Type
ORDER BY Average_of_Hours_taken;


-- Use a CASE Statement to add the countries into respective Continents, so we can figure out which Cyber Threats are the most frequent.
SELECT Country,
	CASE 
		WHEN Country IN ('Germany','France','UK','Russia') THEN 'Europe'
		WHEN Country IN ('China','Japan','India') THEN 'Asia'
		WHEN Country IN ('Australia') THEN 'Oceania'
		WHEN Country IN ('USA') THEN 'North America'
		WHEN Country IN ('Brazil') THEN 'South America'
		ELSE 'Other'
	END AS Continent
FROM [Global_Cybersecurity_Threats_2015-2024]
GROUP BY Country
ORDER BY Continent
;

-- Query the countries most frequent Attack Type - Germany's biggest problem is SQL Injection, which is 21.31% of their attacks.
WITH Ranked_Attack_type AS (
			SELECT 
				Country,
				Attack_type,
				COUNT(*) as Attack_Count,
				ROW_NUMBER() OVER (PARTITION BY Country ORDER BY COUNT(*) DESC) as rn
			FROM [Global_Cybersecurity_Threats_2015-2024]
			GROUP BY Country, Attack_Type
	),

Total_Attacks AS ( 
		SELECT
			Country,
			COUNT(*) AS Total_Attacks
		FROM [Global_Cybersecurity_Threats_2015-2024]
		GROUP BY Country
	)
	
SELECT 
	r.Country, 
	CASE 
		WHEN r.Country IN ('Germany','France','UK','Russia') THEN 'Europe'
		WHEN r.Country IN ('China','Japan','India') THEN 'Asia'
		WHEN r.Country IN ('Australia') THEN 'Oceania'
		WHEN r.Country IN ('USA') THEN 'North America'
		WHEN r.Country IN ('Brazil') THEN 'South America'
		ELSE 'Other'
	END AS Continent,
	r.Attack_Type as Most_Common_Attack_Type,
	r.Attack_Count as Number_of_Attacks,
	t.Total_Attacks,
	CAST(ROUND(1.0 * r.Attack_Count / t.Total_Attacks * 100, 2) AS DECIMAL(5,2)) AS Attack_Percentage
FROM Ranked_Attack_type as r
JOIN Total_attacks as t ON r.Country = t.Country
WHERE r.rn = 1
ORDER BY Attack_Percentage DESC;



-- Which defence mechanism is the most effective - It turns out that for SQL Injection, which was Germany's biggest problem, is the best defence.

WITH Ranked_Defense_Mechanicsm AS (
			SELECT 
				Attack_Type,
				Defense_Mechanism_Used,
				COUNT(*) as Attack_Count,
				ROW_NUMBER() OVER (PARTITION BY Attack_type ORDER BY COUNT(*) DESC) as rd
			FROM [Global_Cybersecurity_Threats_2015-2024]
			GROUP BY Attack_Type, Defense_Mechanism_Used
	)

SELECT 
	d.Attack_Type,
	d.Defense_Mechanism_Used
FROM Ranked_Defense_Mechanicsm d
WHERE d.rd = 1
GROUP BY d.Attack_Type, d.Defense_Mechanism_Used;
