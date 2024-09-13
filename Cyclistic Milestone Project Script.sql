-- I used Excel to clean duplicates and adjust the data type. Since there are over three million data rows available, SQL is the best way to manipulate this data. To do so, I had to: 

-- Create a table to house the bikeshare data to be imported into MySQL

-- I have divided the bikeshare table into two categories - bikeshare data (focused on duration data) and location data (focused on location data). The dataset for this analysis is 12-month worth, extending from May 2020 to April 2021.;

-- Duration data…

CREATE TABLE september_2020_bikeshare
	(rider_id VARCHAR(50) NOT NULL,
    Membership_type VARCHAR (50) NOT NULL,
    Bike_type VARCHAR (50) NOT NULL,
    start_time_stamp datetime NOT NULL,
    start_date date NOT NULL,
    start_time time NOT NULL,
    start_day VARCHAR (50) NOT NULL,
    start_month VARCHAR (50) NOT NULL,
    return_time_stamp datetime NOT NULL);

-- Location data…
CREATE TABLE april_2021_Location (
    rider_id VARCHAR (50) NOT NULL,
    bike_type VARCHAR(50) NOT NULL,
    start_station_name VARCHAR(100),
    start_station_id VARCHAR (50),
    end_station_name VARCHAR(100),
    end_station_id VARCHAR (50),
    start_lat DECIMAL(10, 8) NOT NULL,
    start_lng DECIMAL(11, 8) NOT NULL,
    end_lat DECIMAL(10, 8) NOT NULL,
    end_lng DECIMAL(12, 8) NOT NULL,
    membership_type VARCHAR(50) NOT NULL,
    duration INT NOT NULL
);

-- Import the data into MySQL Workbench… 

LOAD DATA INFILE 'April_2021_Location.csv' INTO TABLE april_2021_location 
	FIELDS TERMINATED BY ','
	IGNORE 1 LINES;

-- The analysis process for this SQL duration dataset

-- First, we must combine all 12 months of data, from May 2020 to April 2021. 

CREATE TABLE bikeshare_project_trips AS (
	SELECT *
    FROM bikeshare_project.may_2020_bikeshare
    UNION DISTINCT  ( SELECT *
					FROM bikeshare_project.june_2020_bikeshare)
    UNION DISTINCT ( SELECT *
					FROM bikeshare_project.july_2020_bikeshare)
    UNION DISTINCT ( SELECT *
					FROM bikeshare_project.august_2020_bikeshare)
    UNION DISTINCT ( SELECT *
					FROM bikeshare_project.september_2020_bikeshare)
    UNION DISTINCT ( SELECT *
					FROM bikeshare_project.october_2020_bikeshare)
    UNION DISTINCT ( SELECT *
					FROM bikeshare_project.november_2020_bikeshare)
    UNION DISTINCT ( SELECT *
					FROM bikeshare_project.december_2020_bikeshare)
    UNION DISTINCT ( SELECT *
					FROM bikeshare_project.january_2021_bikeshare)
    UNION DISTINCT ( SELECT *
					FROM bikeshare_project.february_2021_bikeshare)
    UNION DISTINCT ( SELECT *
					FROM bikeshare_project.march_2021_bikeshare)
    UNION DISTINCT ( SELECT *
					FROM bikeshare_project.april_2021_bikeshare));

-- Now that our dataset has been combined, we can mass-check for data integrity

-- Checking If Trips are within the right time frame (GENERAL DATA INTEGRITY)

SELECT 
MIN(start_time_stamp) AS min_started_at,
MAX(start_time_stamp) AS max_started_at,
MIN(return_time_stamp) AS min_started_at,
MAX(return_time_stamp) AS max_ended_at
FROM bikeshare_project.bikeshare_project_trips;

-- Members Average Ride Length: 14.1022

SELECT AVG(duration)
FROM bikeshare_project_trips 
WHERE duration > 0
	  AND membership_type = 'member';
      
-- Casual Average Ride Length: 21.0473
SELECT AVG(duration)
FROM bikeshare_project_trips
WHERE duration > 0
	  AND membership_type = 'casual';

-- Average duration by month // members

SELECT return_month,
	  AVG(duration) AS member_average_ride_duration
FROM bikeshare_project_trips
WHERE membership_type = 'member'
GROUP BY return_month
ORDER BY return_month;

-- Average duration by month // casual

SELECT return_month,
	  AVG(duration) AS member_average_ride_duration
FROM bikeshare_project_trips
WHERE membership_type = 'casual'
GROUP BY return_month
ORDER BY return_month;

-- Checking for surprise values in the data 

SELECT 
DISTINCT 
  bike_type, 
  membership_type
FROM bikeshare_project.bikeshare_project_trips;

-- Aggregate the total ride number for both members and casuals. 
Casual riders were - 877,824
Cyclistic Members were - 1,253,752
    
SELECT COUNT(membership_type)
FROM bikeshare_project.bikeshare_project_trips
WHERE (membership_type='casual' OR membership_type='member')
	AND ( (return_date BETWEEN '2020-05-01' AND '2020-05-31') OR
		(return_date BETWEEN '2020-06-01' AND '2020-06-31') OR
        (return_date BETWEEN '2020-07-01' AND '2020-07-31') OR
		(return_date BETWEEN '2020-08-01' AND '2020-08-31') OR
        (return_date BETWEEN '2020-09-01' AND '2020-09-31') OR 
        (return_date BETWEEN '2020-10-01' AND '2020-10-31') OR
        (return_date BETWEEN '2020-11-01' AND '2020-11-31') OR
        (return_date BETWEEN '2020-12-01' AND '2020-12-31') OR
        (return_date BETWEEN '2021-01-01' AND '2021-01-31') OR
        (return_date BETWEEN '2021-02-01' AND '2021-02-31') OR
        (return_date BETWEEN '2021-03-01' AND '2021-03-31') OR 
        (return_date BETWEEN '2021-04-01' AND '2021-04-31'))
	GROUP BY 
		membership_type; 

– What sort of bikes do bikeshare customers use?

SELECT 
	DISTINCT(bike_type)
FROM bikeshare_project.bikeshare_project_trips; 

-- Members vs Casual Bikeshare Riders Comparison over the 12 months data of our data collection cycle - May 2020 to April 2021. 

--  Members 
SELECT COUNT(membership_type)
FROM bikeshare_project.bikeshare_project_trips
WHERE Membership_Type='member' 
	  AND return_month='__';
      
-- Casual 
SELECT COUNT(membership_type)
FROM bikeshare_project.bikeshare_project_trips
WHERE Membership_Type='casual'
	AND return_month='__';

-- After obtaining comparison data, we need to create a table to view this data better… 

CREATE TABLE MONTHLY_MEMBERSHIP_MEMBERS_VS_CASUAL (
	MONTH VARCHAR(50),
    MEMBERS_RIDE INT,
    CASUAL_RIDE INT);

ALTER TABLE monthly_membership_members_vs_casual
ADD YEAR INT;

INSERT INTO monthly_membership_members_vs_casual
Values ('May', 113170, 85693, 2020),
	   ('June', 186863, 151602, 2020),
	   ('July',  280122, 260582, 2020),
	   ('August', 294828, 256562, 2020),
	   ('September', 282920, 211640, 2020),
	   ('October', 242893, 144685, 2020),
	   ('November', 171191, 88029, 2020), 
	   ('December', 100978, 29829, 2020), 
	   ('January', 78566, 17996, 2021),
	   ('February', 39355, 10004, 2021),
	   ('March', 144449, 84012, 2021),
	   ('April', 200606, 136550, 2021);

-- Which Day of the week had the most member riders - Saturday, 331,011

SELECT count(rider_id), return_day
FROM bikeshare_project.bikeshare_project_trips
WHERE membership_type='member'
GROUP BY return_day
ORDER BY return_day;

-- Which day of the week has the most casual rides - Saturday, 343,146

SELECT count(rider_id), return_day
FROM bikeshare_project.bikeshare_project_trips
WHERE membership_type='casual'
GROUP BY return_day
ORDER BY return_day;

-- Average duration (in minutes) of ride for members and casual by month 

SELECT AVG(duration) as average_ride_duration,
	return_month
FROM bikeshare_project_new.bikeshare_project_trips
GROUP BY return_month;


# average_ride_duration
return_month
16.3240	 September
18.9632  July
19.6232  June
20.2713	 May
15.4825	 April
17.7422  August
15.1415  March
12.4719	 December
14.4484	 October
14.3559	 November
11.8513	 January
14.1505	 February

About Cyclistic Bikeshare Bikes. 

-- First the total number of bikes
 
SELECT count(bike_type)
FROM bikeshare_project.bikeshare_project_trips; -- 3,613,089

-- Number of docked_bike users 

SELECT count(bike_type)
FROM bikeshare_project_new.bikeshare_project_trips
WHERE bike_type='docked_bike'; -- 2,407,052

-- Number of classic_bike users

SELECT count(bike_type)
FROM bikeshare_project_new.bikeshare_project_trips
WHERE bike_type='classic_bike'; -- 534,032

-- Number of electric_bike users 

SELECT count(bike_type)
FROM bikeshare_project_new.bikeshare_project_trips
WHERE bike_type='electric_bike'; -- 672,005 

Now, let’s figure out how members and casual cyclistic customers use these bikes… 

-- Number of docked_bike users // Members 

SELECT count(bike_type)
FROM bikeshare_project.bikeshare_project_trips
WHERE bike_type='docked_bike'
	AND membership_type = 'member'; ---1,338,372

-- Number of classic_bike users // Members 

SELECT count(bike_type)
FROM bikeshare_project.bikeshare_project_trips
WHERE bike_type='classic_bike'
	AND membership_type = 'member'; --- 392,605


-- Number of electric_bike users // Members 

SELECT count(bike_type)
FROM bikeshare_project.bikeshare_project_trips
WHERE bike_type='electric_bike'
	AND membership_type = 'member'; ---403,728

-- Number of docked_bike users // Casuals

SELECT count(bike_type)
FROM bikeshare_project.bikeshare_project_trips
WHERE bike_type='docked_bike'
	AND membership_type = 'casual';  -- 1,066,675

-- Number of electric_bike users // Casuals

SELECT count(bike_type)
FROM bikeshare_project.bikeshare_project_trips
WHERE bike_type='electric_bike'
	AND membership_type = 'casual';  -- 267,564

-- Number of classic_bike users // Casuals

SELECT count(bike_type)
FROM bikeshare_project.bikeshare_project_trips
WHERE bike_type='classic_bike'
	AND membership_type = 'casual';  -- 141,427

-- Figuring out how the use of each bike type varies over months 

SELECT 
    DATE_FORMAT(start_date, '%Y-%m') AS month,
    bike_type,
    Membership_type,
    COUNT(*) AS total_trips
FROM 
    bikeshare_project.bikeshare_project_trips
GROUP BY 
    month, membership_type, bike_type
ORDER BY 
    month, bike_type;

-- Number of rides taken for each day of the week // members  

SELECT return_day,
	COUNT(*) AS ride_taken_by_members
FROM bikeshare_project_trips
WHERE duration > 0
	AND duration < 59 
    AND membership_type = 'member'
GROUP BY return_day; 

-- Number of rides taken for each day of the week // casual  

SELECT return_day,
	COUNT(*) AS ride_taken_by_members
FROM bikeshare_project_trips
WHERE duration > 0
	AND duration < 59 
    AND membership_type = 'casual'
GROUP BY return_day; 

-- How many rides are taken at each hour of the day // members 

SELECT start_day,
	   EXTRACT(hour FROM start_time) AS hour, 
	   Count(*) AS rides_taken 
FROM bikeshare_project_trips 
WHERE membership_type = 'member'
	  AND duration > 0
      AND duration < 59 
GROUP BY start_day, hour 
ORDER BY start_day, hour;

-- How many rides are taken at each hour of the day // casuals 

SELECT start_day,
	   EXTRACT(hour FROM start_time) AS hour, 
	   Count(*) AS rides_taken 
FROM bikeshare_project_trips 
WHERE membership_type = 'casual'
	  AND duration > 0
      AND duration < 59 
GROUP BY start_day, hour 
ORDER BY start_day, hour;

-- Do Members and casuals ride different bike types // members 

SELECT bike_type,
	COUNT(*) AS member_rides
FROM bikeshare_project_trips
WHERE duration > 0
	  AND duration < 59
      AND membership_type = 'member'
GROUP BY bike_type;

-- Do Members and casuals ride different bike types // casual 

SELECT bike_type,
	COUNT(*) AS member_rides
FROM bikeshare_project_trips
WHERE duration > 0
	  AND duration < 59
      AND membership_type = 'casual'
GROUP BY bike_type;


-- Before we complete our SQL exploration, let’s figure out how members and casuals behave using the location data 
-- and if we can gather any insights from them. 
    
-- We need to add deductive columns to help us understand the location data better, before that, let’s perform some integrity checks on the location data. 

-- Checking long/lat coordinates 
SELECT *
FROM bikeshare_project.bikeshare_project_locations
WHERE (end_lat = 0.0 OR end_lng = 0.0 OR 
		start_lat = 0.0 OR start_lng = 0.0); -- Every record has the appropriate valies thanks to data cleaning on excel;

-- Now, let's add some inferred metrics for analytical purposes 

ALTER TABLE 
	bikeshare_project.bikeshare_project_locations
ADD COLUMN start_geopoint VARCHAR(50),
ADD COLUMN end_geopoint VARCHAR(50),
ADD COLUMN distance FLOAT4;

-- Populating The Empty Columns 

UPDATE bikeshare_project.bikeshare_project_locations
SET start_geopoint = concat(start_lat, " , " , start_lng),
	end_geopoint = concat(end_lat, " , " , end_lng)
WHERE TRUE;

-- Calculating the distance travelled between the geopoint (rounded) 

UPDATE bikeshare_project.bikeshare_project_locations
SET
	distance=round(st_distance(end_geopoint, start_geopoint))
WHERE TRUE; 

-- Assess the test stations — Exclude them? 

SELECT 
	end_station_id,
	end_station_name,
    start_station_id,
    start_station_name,
    membership_type
FROM bikeshare_project.bikeshare_project_locations
WHERE 
	end_station_id LIKE '%Test%' OR 
    end_station_name LIKE '%Test%' OR 
    start_station_id LIKE '%Test%' OR 
    start_station_name LIKE '%Test%';

-- Bikeshare Trips - 3,610,371 vs Bikeshare_Locations - 3,422,978 -- This means over 200,000 bikeshare users did not have their location data recorded. 

-- What are the popular locations like for members and casuals? // members

SELECT start_station_name, 
	   COUNT(*) AS number_of_rides
FROM bikeshare_project_locations
WHERE duration < 59 
	AND duration > 0
    AND membership_type = 'member'
    AND start_station_name != 'Null'
GROUP BY start_station_name 
ORDER BY number_of_rides DESC; -- Clark St. & Elm St. seem most popular among members

-- What are the popular locations like for members and casuals? // casuals

SELECT start_station_name, 
	   COUNT(*) AS number_of_rides
FROM bikeshare_project_locations
WHERE duration < 59 
	AND duration > 0
    AND membership_type = 'casual'
    AND start_station_name != 'Null'
GROUP BY start_station_name 
ORDER BY number_of_rides DESC; -- Streeter Dr & Grand Ave seems to be the most popular stations for casual riders.

-- Most Popular End_Stations for // Members 

SELECT end_station_name, 
	   COUNT(*) AS number_of_rides
FROM bikeshare_project_locations
WHERE duration < 59 
	AND duration > 0
    AND membership_type = 'member'
    AND start_station_name != 'Null'
GROUP BY end_station_name 
ORDER BY number_of_rides DESC; -- Clark St & Elm St 	is the most popular end_station for members 

-- Most Popular End_Stations for // casuals 

SELECT end_station_name, 
	   COUNT(*) AS number_of_rides
FROM bikeshare_project_locations
WHERE duration < 59 
	AND duration > 0
    AND membership_type = 'casual'
    AND start_station_name != 'Null'
GROUP BY end_station_name 
ORDER BY number_of_rides DESC; -- Streeter Dr & Grand Ave is the most popular end_station for casuals.

-- Now, we shall export the data for Power BI Exploration. 

LOAD DATA INFILE 'bikeshare_project_trips' INTO TABLE bikeshare_project_trips 
	FIELDS TERMINATED BY ','
	IGNORE 1 LINES;

