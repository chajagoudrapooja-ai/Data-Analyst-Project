use airline;
select *from maindata;
select Date(concat_ws('-',Year,Month,Day)) as Date from maindata;
describe maindata;
drop table if exists date;
create table date as select Year,Month,Day from maindata;
alter table date add column Date_Column date;
update date set Date_Column=concat_ws('-',Year,Month,Day);
select * from date;

drop table if exists Calendar;

-- Calender table
CREATE TABLE Calendar AS
SELECT 
    Date_Column,  
    -- Extracting Year
    YEAR(Date_Column) AS Year,

    -- Extracting Month Number
    MONTH(Date_Column) AS MonthNo,

    -- Extracting Month Full Name Manually
    CASE MONTH(Date_Column)
        WHEN 1 THEN 'January' WHEN 2 THEN 'February' WHEN 3 THEN 'March'
        WHEN 4 THEN 'April' WHEN 5 THEN 'May' WHEN 6 THEN 'June'
        WHEN 7 THEN 'July' WHEN 8 THEN 'August' WHEN 9 THEN 'September'
        WHEN 10 THEN 'October' WHEN 11 THEN 'November' WHEN 12 THEN 'December'
    END AS MonthFullName,

    -- Extracting Quarter Manually
    CASE 
        WHEN MONTH(Date_Column) BETWEEN 1 AND 3 THEN 'Q1'
        WHEN MONTH(Date_Column) BETWEEN 4 AND 6 THEN 'Q2'
        WHEN MONTH(Date_Column) BETWEEN 7 AND 9 THEN 'Q3'
        WHEN MONTH(Date_Column) BETWEEN 10 AND 12 THEN 'Q4'
    END AS Quarter,

    -- Formatting Year-Month as 'YYYY-MMM'
    CONCAT(YEAR(Date_Column), '-', 
        CASE MONTH(Date_Column)
            WHEN 1 THEN 'Jan' WHEN 2 THEN 'Feb' WHEN 3 THEN 'Mar'
            WHEN 4 THEN 'Apr' WHEN 5 THEN 'May' WHEN 6 THEN 'Jun'
            WHEN 7 THEN 'Jul' WHEN 8 THEN 'Aug' WHEN 9 THEN 'Sep'
            WHEN 10 THEN 'Oct' WHEN 11 THEN 'Nov' WHEN 12 THEN 'Dec'
        END
    ) AS YearMonth,

    -- Manually Extracting Weekday Number (Sunday = 1, Monday = 2, ..., Saturday = 7)
    (1 + (YEAR(Date_Column) * 365 + MONTH(Date_Column) * 31 + DAY(Date_Column)) % 7) AS WeekdayNo,

    -- Extracting Weekday Name Manually
    CASE (1 + (YEAR(Date_Column) * 365 + MONTH(Date_Column) * 31 + DAY(Date_Column)) % 7)
        WHEN 1 THEN 'Sunday' WHEN 2 THEN 'Monday' WHEN 3 THEN 'Tuesday'
        WHEN 4 THEN 'Wednesday' WHEN 5 THEN 'Thursday' WHEN 6 THEN 'Friday'
        WHEN 7 THEN 'Saturday'
    END AS WeekdayName,

    -- Financial Month (Starting in April)
    CASE 
        WHEN MONTH(Date_Column) >= 4 THEN MONTH(Date_Column) - 3
        ELSE MONTH(Date_Column) + 9
    END AS FinancialMonth,

    -- Financial Quarter (Starting in April)
    CASE 
        WHEN MONTH(Date_Column) BETWEEN 4 AND 6 THEN 'Q1'
        WHEN MONTH(Date_Column) BETWEEN 7 AND 9 THEN 'Q2'
        WHEN MONTH(Date_Column) BETWEEN 10 AND 12 THEN 'Q3'
        WHEN MONTH(Date_Column) BETWEEN 1 AND 3 THEN 'Q4'
    END AS FinancialQuarter

FROM date;
select *from Calendar;
#Question-2------------
SELECT 
    cal.Year,
    cal.MonthNo,
    cal.Quarter,
    SUM(md.Transported_Passengers) AS Total_TransportedPassengers,
    SUM(md.Available_Seats) AS Total_AvailableSeats,
    (SUM(md.Transported_Passengers) * 100.0 / NULLIF(SUM(md.Available_Seats), 0)) AS LoadFactorPercentage
FROM Calendar cal join maindata md 
WHERE cal.Year =2008
GROUP BY cal.Year, cal.MonthNo, cal.Quarter
ORDER BY cal.Year, cal.Quarter, cal.MonthNo limit 5;

set global wait_timeout=28800;
set global interactive_timeout=28800;
#Question 3-------
SELECT 
    md.Carrier_Name,
    SUM(md.Transported_Passengers) AS Total_TransportedPassengers,
    SUM(md.Available_Seats) AS Total_AvailableSeats,
    (SUM(md.Transported_Passengers) * 100.0 / NULLIF(SUM(md.Available_Seats), 0)) AS LoadFactorPercentage
FROM maindata md
GROUP BY md.Carrier_Name
ORDER BY LoadFactorPercentage DESC;  -- Optional: Orders by load factor percentage, descending
----------------
#Question 4----
SELECT Carrier_Name, COUNT(*) AS Transported_Passengers
FROM maindata
GROUP BY Carrier_Name
ORDER BY Transported_Passengers DESC
LIMIT 10;
-----------------
#Question 5------
SELECT Origin_city, destination_city, COUNT(*) AS Transported_Passenger
FROM maindata
GROUP BY origin_city, destination_city
ORDER BY Transported_Passenger DESC
LIMIT 10;
#Question 6----
SELECT 
    CASE 
        WHEN MOD((YEAR(cal.Date_Column) - 1900) * 365 + 
                 (YEAR(cal.Date_Column) - 1900) DIV 4 + 
                 MONTH(cal.Date_Column) * 31 - 
                 (MONTH(cal.Date_Column) * 4 + 23) DIV 10 + 
                 DAY(cal.Date_Column), 7) IN (5, 6) 
        THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,
    SUM(md.transported_Passengers) AS total_seats_sold,
    SUM(md.available_seats) AS total_seats_available,
    ROUND((SUM(md.transported_passengers) / SUM(md.available_seats)) * 100, 2) AS load_factor_percentage
FROM maindata md join calendar cal
WHERE md.available_seats > 0  -- Avoid division by zero
GROUP BY day_type;
#Question 7--------
SELECT 
    CASE 
        WHEN distance BETWEEN 0 AND 500 THEN '0-500 km'
        WHEN distance BETWEEN 501 AND 1000 THEN '501-1000 km'
        WHEN distance BETWEEN 1001 AND 2000 THEN '1001-2000 km'
        WHEN distance BETWEEN 2001 AND 5000 THEN '2001-5000 km'
        ELSE '5001+ km'
    END AS distance_group,
    COUNT(*) AS `%Airline ID`
FROM maindata
GROUP BY distance_group
ORDER BY `%Airline ID` DESC;









     


