# PROJECT - GLOBAL CYPER SECURITY THREATS

A client from Germany is thinking about reworking their defense system to be more effective towards the most common cyber threats. He wants us to answer three tasks and put them all in an interactive dashboard portraying the results.

1. What Cyber threats propose the biggest threat in scale, Financial Loss and Number of Affected Users? 

2. What Cyber threats happen most often in Europe and Germany?

3. Which Defense Mechanism is most effective against said attacks?

STEP 1 = Create a Database in SSMS and import the data to Query the data and explore for duplicates or things that can cause problems in future visualizations.

STEP 2 = First we Query the data and conduct a little Exploratory Data Analysis, on stuff like which attack type is the most frequent across the dataset, as well as Average Millions Lost. And on important Data such as how many Cyber Attacks there were each year.

	SELECT Attack_Type, ROUND(AVG(Financial_Loss_in_Million),2) as Average_Loss_Millions, AVG(Number_of_Affected_Users) as Average_Affected_users, COUNT(*) as 	Number_of_Attacks
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

STEP 3 = We use a CASE statement to add the Continents to the countries by hand, in which we want to use in our bulk code for the Power BI import. 

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


STEP 4 = Then we start making the bulk of our code, which we want to Import into Power BI, where we group the information by the separate countries, their most common attack type against them, how many there has been, and then what the percentage is compared to the other attacks they experience.

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

STEP 5 = Last part of the EDA is checking which defense mechanisms were used the most for each attacking type.

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

STEP 6 = Go into Power BI and connect to the SQL Server and import the whole table from the database, and in addition we will also add the same table but with the SQL statement from STEP 4. Power BI immediately creates a relationship between the countries, which is what we want.

STEP 7 = We then start making the outline for the Dashboard, splitting it into 3 parts so we can answer all 3 questions that the client gave us. 

STEP 8 = Create a Card visual of Average millions lost by cyber attacks, as well as a line graph portraying the different Attack types, how many people they affected and the average financial loss in millions. As well as a small graph under the card visual, portraying average loss in millions per year, so we can see the trend.

STEP 9 = Create a card visual for number of Attacks in Germany, with a line visual under to portray Cyber attacks on Germany over the years. As well as a Bar visual showing us the number of Attack types for the two European Countries in our dataset.

STEP 10 = We take the two Attack types with the highest number in Germany, SQL injection and Man-in-the-middle and make pie charts on which defense mechanisms were most used for those attacks. 

STEP 11 = For our last visual we want to create a table that groups the attack types and shows us the most used defense mechanism to that attack. So we create a measure by writing; 

	
	Most Used Defence = 
	VAR Attack = SELECTEDVALUE('Global_Cybersecurity_Threats_2015-2024'[Attack_Type])
	RETURN 
	CALCULATE(
   	 	MAXX(
       	 		TOPN(
           		 1,
            		 SUMMARIZE(
                		'Global_Cybersecurity_Threats_2015-2024','Global_Cybersecurity_Threats_2015-2024'[Defense_Mechanism_Used],
                		"Count", COUNTROWS('Global_Cybersecurity_Threats_2015-2024')
            	 	),
            	 	[Count], DESC
         	 ),
        	 'Global_Cybersecurity_Threats_2015-2024'[Defense_Mechanism_Used]
    		),
    		'Global_Cybersecurity_Threats_2015-2024'[Attack_Type] = Attack
	)

STEP 12 = Then lastly we want to create a column in the table that portrays the percentage that the most used defense mechanism was compared to the whole; 
	
	
	Most Used Defense Percentage = 
	VAR Attack = SELECTEDVALUE('Global_Cybersecurity_Threats_2015-2024'[Attack_Type])

	-- Count of the most used defense
	VAR TopDefenseCount = 
    		CALCULATE(
        		MAXX(
            			TOPN(
                			1,
               		 		SUMMARIZE(
                    				'Global_Cybersecurity_Threats_2015-2024','Global_Cybersecurity_Threats_2015-2024'[Defense_Mechanism_Used],
                    				"Count", COUNTROWS('Global_Cybersecurity_Threats_2015-2024')
                			),
                			[Count], DESC
            			),
            			[Count]
        		),
        		'Global_Cybersecurity_Threats_2015-2024'[Attack_Type] = Attack
    		)

	-- Total number of defenses for this attack type
	VAR TotalDefenseCount = 
   		CALCULATE(
        		COUNTROWS('Global_Cybersecurity_Threats_2015-2024'),
        		'Global_Cybersecurity_Threats_2015-2024'[Attack_Type] = Attack
    		)

	RETURN 
	ROUND(DIVIDE(TopDefenseCount, TotalDefenseCount, 0) *100, 2)


STEP 13 = Then lastly we create a Slider that filters based on Year on the whole dataset. 

# INSIGHT / SUMMARY -
In the interactive dashboard that we created, we have highlighted the 3 separate tasks that was asked of us by the client from Germany, so lets take it step by step. 
Task number 1 was to find which Cyber threats propose the biggest threat in scale, Financial Loss and Number of Affected Users. If we look at the Line visual at the dashboard e can see that DDoS seems to be the one Cyber threat that both affects the most people, but also costs the companies the most money on average. That being said, all of the Cyber threats are hovering around $50 million on average, which gives us an understanding of the scale of the situation. 

Task number 2 was to find out which Cyber attack was the most common in Europe and more specifically Germany. In the dataset that we were given there were only 2 European countries being France and Germany, which makes our point of reference quite small. However since the client is from Germany, we can still get vital information from the Bar visual. As we can see, in Germany the most common Cyber attack is SQL Injection, while in France it is Phishing. If we combine the numbers we can see that SQL Injection is on top, and is therefore important for us to focus on further. As the little Line visual shows us the number of Cyber attacks per year, and based off of the trend line it seems to be a rising number, further showing the importance of establishing a good Defense Mechanism.

Task number 3 was to find out which Defense Mechanism was the most effective against said Cyber Attack, something in which we visualized in both a Table visual and a Pie visual. We can see the percentage of the amount of times Antivirus was used as a Defense Mechanism for SQL Injection in both the Table and Pie visual, telling us that a total of 22.47% of times, the Antivirus was the Defense Mechanism of choice. However, as we can see with the other Attack types as well, the percentage is lying around 20%, meaning that they're barely beating out the other Defense Mechanisms.

All in all, Cyber Attacks are in the rise in Germany, and they are slowly getting more and more dangerous in terms of money lost. The main problem for Germany is SQL Injection and the main choice of Defense is Antivirus (22.47%). Even though we could be satisfied in the information we found out, I would suggest the client to conduct a more in depth Defense Mechanism project, in order to get a firmer grasp on which Defense Mechanisms are the best for the said scenario, why they're the best, how much money it would cost to set up such a Defense, and if the client's company has the capacity to set it up.
