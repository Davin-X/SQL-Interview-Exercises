-- Active: 1671859768936@@127.0.0.1@3306@complex
CREATE DATABASE IF NOT EXISTS complex ;

---------------------------------------------
create database if not exists complex_qr ; 
use complex_qr;
---------------------------------------------
-- Derive Points table for ICC tournament
---------------------------------------------
create table icc_world_cup
(
Team_1 Varchar(20),
Team_2 Varchar(20),
Winner Varchar(20)
);

INSERT INTO icc_world_cup values('India','SL','India');
INSERT INTO icc_world_cup values('SL','Aus','Aus');
INSERT INTO icc_world_cup values('SA','Eng','Eng');
INSERT INTO icc_world_cup values('Eng','NZ','NZ');
INSERT INTO icc_world_cup values('Aus','India','India');

select * from icc_world_cup;

with winner as (
SELECT  Team_1 as team , 
CASE  when Team_1 = winner then 1 else 0 end as win_flag from icc_world_cup 
union all 
SELECT  Team_2 as team , 
CASE  when Team_2 = winner then 1 else 0 end as win_flag from icc_world_cup 
)

select  team, 
COUNT(1) as match_played,
SUM(win_flag) as wins, 
( COUNT(1)- SUM(win_flag) ) as losses  
from winner group by team ; 

------------------------------------------------
-- find new and repeat customers
------------------------------------------------
create table customer_orders (
order_id integer,
customer_id integer,
order_date date,
order_amount integer
);

insert into customer_orders values
(1,100,cast('2022-01-01' as date),2000),
(2,200,cast('2022-01-01' as date),2500),
(3,300,cast('2022-01-01' as date),2100),
(4,100,cast('2022-01-02' as date),2000),
(5,400,cast('2022-01-02' as date),2200),
(6,500,cast('2022-01-02' as date),2700),
(7,100,cast('2022-01-03' as date),3000),
(8,400,cast('2022-01-03' as date),1000),
(9,600,cast('2022-01-03' as date),3000);

select * from customer_orders;

with visits as (
        SELECT
            co.*, fv.first_visit
        from  customer_orders co
            join (
                SELECT customer_id, MIN(order_date) as first_visit
                from customer_orders
                GROUP BY customer_id
            ) fv on co.customer_id = fv.customer_id
    ),
    visits_flag as (
      select
        customer_id,order_date,
        CASE
            WHEN order_date = FIRST_VISIT THEN 1 ELSE 0 END as New_customer_flag,
        CASE
            WHEN order_date <> FIRST_VISIT THEN 1 ELSE 0 END as Repeat_customer_flag
    from visits
    )
select order_date , 
SUM(New_customer_flag) as NEW_customer,
SUM(Repeat_customer_flag) as Repeat_customer
FROM visits_flag GROUP BY order_date 
;

with visits as (
        SELECT
            co.*, fv.first_visit
        from  customer_orders co
            join (
                SELECT customer_id, MIN(order_date) as first_visit
                from customer_orders
                GROUP BY customer_id
            ) fv on co.customer_id = fv.customer_id
    )

      select
        order_date,
        sum (CASE WHEN order_date = FIRST_VISIT THEN 1 ELSE 0 END  ) as New_customer_flag,
        sum (CASE  WHEN order_date <> FIRST_VISIT THEN 1 ELSE 0 END ) as Repeat_customer_flag
    from visits GROUP BY order_date 
;

------------------------------------------------
-- find out total visits for a person,
-- the floor he visited the most and number of visits
------------------------------------------------

create table entries ( 
name varchar(20),
address varchar(20),
email varchar(20),
floor int,
resources varchar(10));

insert into entries values 
('A','Bangalore','A@gmail.com',1,'CPU'),
('A','Bangalore','A1@gmail.com',1,'CPU'),
('A','Bangalore','A2@gmail.com',2,'DESKTOP'),
('B','Bangalore','B@gmail.com',2,'DESKTOP'),
('B','Bangalore','B1@gmail.com',2,'DESKTOP'),
('B','Bangalore','B2@gmail.com',1,'MONITOR');


 with total_visits as (
    SELECT name , count(1) as total_visit, 
     group_concat(distinct resources) as RESOURCES_USED 
    FROM entries GROUP BY name 
),
floor_visits as (
    select name , floor, count(1)  as fl_vsits,
    RANK() over (PARTITION BY NAME order by count(1) desc ) as rn 
    from entries GROUP BY name , floor 
)
SELECT fv.name , 
tv.total_visit,
fv.floor as most_visited_floor ,
tv.RESOURCES_USED 
from total_visits tv 
inner join 
floor_visits fv
on tv.name = fv.name where fv.rn = 1   ;

----------------------------------------------------------
-----------------------------------------------------------
-- write  a query to provide the date for nth occurance of sunday from  given date
-- datepart
-- sunday- 1
-- monday- 2
-- friday- 6
-- saturday- 7

set @today_date='2023-07-11';
set @n =5 ;

SELECT DATE_ADD(@today_date, INTERVAL (8 - DAYOFWEEK(@today_date) +  7 * (@n - 1)) DAY) AS sunday_date;

--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------

--
/* The Pareto principle states that for many outcomes, roughly 80% of consequences come from 20% of causes.
eg:
80 % of the productivity come from 20 % of the employees.
80 % of your sales come from 20 % of your clients.
80 % of decisions in a meeting are made in 20 % of the time
80 % of your sales comes from 20 % of your products or services.
*/
CREATE TABLE IF NOT EXISTS  `superstore_orders` (
  `Row_ID` int DEFAULT NULL,
  `Order_ID` text,
  `Order_Date` text,
  `Ship_Date` text,
  `Ship_Mode` text,
  `Customer_ID` text,
  `Customer_Name` text,
  `Segment` text,
  `Country/Region` text,
  `City` text,
  `State` text,
  `Postal_Code` int DEFAULT NULL,
  `Region` text,
  `Product_ID` text,
  `Category` text,
  `Sub_Category` text,
  `Product_Name` text,
  `Sales` double DEFAULT NULL,
  `Quantity` int DEFAULT NULL,
  `Discount` double DEFAULT NULL,
  `Profit` double DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci
;

select * from superstore_orders limit 3 ;

select SUM(sales) * 0.8 from superstore_orders ;

with product_wise_sales as (
    SELECT product_id , sum(Sales) as product_sale 
FROM superstore_orders 
GROUP BY `Product_ID` ORDER BY `Product_sale` desc 
),
cal_sales as ( 
SELECT SUM(product_sale) over (order by `product_sale` desc ROWS BETWEEN UNBOUNDED PRECEDING AND 0 PRECEDING) as running_sales , 
 0.8 * SUM(`product_sale`) over() as total_sales
FROM product_wise_sales 
)

select * FROM cal_sales where running_sales <= total_sales ; 

--------------------------------------------------------------------------------------
--- Scenario based on join, group by and having clauses 
/* write a query to find PersonID, Name, number of friends, sum of marks
of person who have friends with total score greater than 100. * /

*/
--------------------------------------------------------------------------------------
CREATE TABLE Persons (
    PersonID INT PRIMARY KEY,
    Name VARCHAR(50),
    Email VARCHAR(100),
    Score INT
);
INSERT INTO Persons (PersonID, Name, Email, Score) VALUES (1, 'Alice', 'alice2018@hotmail.com', 88);
INSERT INTO Persons (PersonID, Name, Email, Score) VALUES (2, 'Bob', 'bob2018@hotmail.com', 11);
INSERT INTO Persons (PersonID, Name, Email, Score) VALUES (3, 'Davis', 'davis2018@hotmail.com', 27);
INSERT INTO Persons (PersonID, Name, Email, Score) VALUES (4, 'Tara', 'tara2018@hotmail.com', 45);
INSERT INTO Persons (PersonID, Name, Email, Score) VALUES (5, 'John', 'john2018@hotmail.com', 63);

CREATE TABLE PersonFriends (
    PersonID INT,
    FriendID INT
   );
INSERT INTO PersonFriends (PersonID, FriendID) VALUES (1, 2);
INSERT INTO PersonFriends (PersonID, FriendID) VALUES (1, 3);
INSERT INTO PersonFriends (PersonID, FriendID) VALUES (2, 1);
INSERT INTO PersonFriends (PersonID, FriendID) VALUES (2, 3);
INSERT INTO PersonFriends (PersonID, FriendID) VALUES (3, 5);
INSERT INTO PersonFriends (PersonID, FriendID) VALUES (4, 2);
INSERT INTO PersonFriends (PersonID, FriendID) VALUES (4, 3);
INSERT INTO PersonFriends (PersonID, FriendID) VALUES (4, 5);

with score_details as (
    SELECT pf.PersonID, 
    COUNT(1) as num_of_friend,
    SUM(P.Score) as Total_friens_score 
    FROM persons P 
    join  PersonFriends pf 
    on P.PersonID = pf.FriendID
    GROUP BY pf.PersonID  having SUM(P.Score) > 100
) 

select s.* , P.name 
from persons P 
join score_details s
 ON p.PersonID = s.PersonID ;
;

--------------------------------------------------------------------------------------
--- Trips and Users

/* Write a SQL query to find the cancellation rate of requests with unbanned users
(both client and driver must not be banned) each day between "2913-10-01" and "2013-1903" .
Round Cancelation Rate to two decimal points.
The cancellation rate is computed by dividing the number of canceled (by client or driver)
requests with unbanned users by the total number of requests with unbanned users on that day.
*/
--------------------------------------------------------------------------------------
Create table  Trips (id int, client_id int, driver_id int, city_id int, status varchar(50), request_at varchar(50));
Create table Users (users_id int, banned varchar(50), role varchar(50));
Truncate table Trips;
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values ('1', '1', '10', '1', 'completed', '2013-10-01');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values ('2', '2', '11', '1', 'cancelled_by_driver', '2013-10-01');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values ('3', '3', '12', '6', 'completed', '2013-10-01');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values ('4', '4', '13', '6', 'cancelled_by_client', '2013-10-01');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values ('5', '1', '10', '1', 'completed', '2013-10-02');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values ('6', '2', '11', '6', 'completed', '2013-10-02');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values ('7', '3', '12', '6', 'completed', '2013-10-02');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values ('8', '2', '12', '12', 'completed', '2013-10-03');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values ('9', '3', '10', '12', 'completed', '2013-10-03');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values ('10', '4', '13', '12', 'cancelled_by_driver', '2013-10-03');
Truncate table Users;
insert into Users (users_id, banned, role) values ('1', 'No', 'client');
insert into Users (users_id, banned, role) values ('2', 'Yes', 'client');
insert into Users (users_id, banned, role) values ('3', 'No', 'client');
insert into Users (users_id, banned, role) values ('4', 'No', 'client');
insert into Users (users_id, banned, role) values ('10', 'No', 'driver');
insert into Users (users_id, banned, role) values ('11', 'No', 'driver');
insert into Users (users_id, banned, role) values ('12', 'No', 'driver');
insert into Users (users_id, banned, role) values ('13', 'No', 'driver');



SELECT  request_at ,
COUNT(1) as total_trips,
count( case WHEN status in ('cancelled_by_client','cancelled_by_driver') then 1 else null end ) as cancelled_trips_count,
count( case WHEN status in ('cancelled_by_client','cancelled_by_driver') then 1 else null end ) / count(1) * 100 as cancel_percentage
from trips t 
join Users u on t.client_id = u.users_id
join users d on t.driver_id = d.users_id 
where u.banned = 'NO' and d.banned='NO'
group by request_at ;

--------------------------------------------------------------------------------------------
-- Write an SQL query to find the winner in each group.
-- The winner in each group is the player who scored the maximum total points within the group. In the case of a tie,
-- the lowest player_id wins in case of tie.
------------------------------------------------------------------------------------------------


create table players
(player_id int,
group_id int)
;
insert into players values (15,1);
insert into players values (25,1);
insert into players values (30,1);
insert into players values (45,1);
insert into players values (10,2);
insert into players values (35,2);
insert into players values (50,2);
insert into players values (20,3);
insert into players values (40,3);

create table matches
(
match_id int,
first_player int,
second_player int,
first_score int,
second_score int)
;

insert into matches values (1,15,45,3,0);
insert into matches values (2,30,25,1,2);
insert into matches values (3,30,15,2,0);
insert into matches values (4,40,20,5,2);
insert into matches values (5,35,50,1,1);

with P_scores as (
select first_player as player , first_score as score from matches 
UNION ALL  
select second_player as player , second_score as score from matches 
)
,final_scores as (
select p.group_id,  ps.player , sum(score) as total_score 
 from P_scores ps
join players p on p.player_id = ps.player
group by p.group_id, ps.player order by total_score desc
)
, final_ranking as (
SELECT * , rank() over (partition by group_id  ORDER BY total_score desc, player desc ) as rnk 
from final_scores
)
select * from final_ranking where rnk = 1;

 ;
------------------------------------------------------------------------------------------------
/* MARKET ANALYSIS : Write an SQL query to find for each seller, whether the brand of the second item (by date) they
sold is their favorite brand.
note :- If a seller sold less than two items, report the answer for that seller as no. 
o/ p :- 
seller_id   2nd item fav brand
1            yes/no
2            yes/no
*/
;
------------------------------------------------------------------------------------------------
create table market_users (
user_id         int     ,
 join_date       date    ,
 favorite_brand  varchar(50));

 create table orders (
 order_id       int     ,
 order_date     date    ,
 item_id        int     ,
 buyer_id       int     ,
 seller_id      int 
 );

 create table items
 (
 item_id        int     ,
 item_brand     varchar(50)
 );


 insert into market_users values 
 (1,'2019-01-01','Lenovo'),
 (2,'2019-02-09','Samsung'),
 (3,'2019-01-19','LG'),
 (4,'2019-05-21','HP');

 insert into items values 
 (1,'Samsung'),
 (2,'Lenovo'),
 (3,'LG'),
 (4,'HP');

 insert into orders values 
 (1,'2019-08-01',4,1,2),
 (2,'2019-08-02',2,1,3),
 (3,'2019-08-03',3,2,3),
 (4,'2019-08-04',1,4,2),
 (5,'2019-08-04',1,3,4),
 (6,'2019-08-05',2,2,4);

with rnk_orders as (
    select *, rank() over (partition by seller_id order by order_date asc )as rnk
    FROM orders
)
 select ro.order_id,
  CASE 
    WHEN  i.item_brand = u.favorite_brand THEN  "YES"
    ELSE  "NO"
 END as SECOND_item_is_favorit_brand 
  from market_users  u  
 left join rnk_orders ro  on ro.seller_id = u.user_id and  ro.rnk =2
 left join items i on i.item_id = ro.item_id
  
;

-------------------------------------------------------------------------------------------------
--- An Awesome Tricky SQL Logic | Complex SQL 10
-------------------------------------------------------------------------------------------------

create table tasks (
date_value date,
state varchar(10)
);

insert into tasks  values 
('2019-01-01','success'),
('2019-01-02','success'),
('2019-01-03','success'),
('2019-01-04','fail'),
('2019-01-05','fail'),
('2019-01-06','success') ;


with all_dates as (
SELECT *,
    ROW_NUMBER() OVER (PARTITION BY state ORDER BY date_value) AS ro,
    DATE_ADD(date_value, INTERVAL -1.0 * (ROW_NUMBER() OVER (PARTITION BY state ORDER BY date_value)) DAY) AS group_date
FROM 
    tasks
ORDER BY 
    date_value
)
select  min (date_value) as start_date, state  , max(date_value) as end_date 
from all_dates GROUP BY GROUP_DATE , state 
;

-------------------------------------------------------------------------------------------------
---  User Purchase Platform | Complex SQL
/* User purchase platform.
-- The table logs the spendings history of users that make purchases from an online shopping website which has a desktop
and a mobile application.
-- Write an SQL query to find the total number of users and the total amount spent using mobile only, desktop only
and both mobile and desktop together for each date.
*/
-------------------------------------------------------------------------------------------------

create table spending 
(
user_id int,
spend_date date,
platform varchar(10),
amount int
);

insert into spending values
(1,'2019-07-01','mobile',100),
(1,'2019-07-01','desktop',100),
(2,'2019-07-01','mobile',100),
(2,'2019-07-02','mobile',100),
(3,'2019-07-01','desktop',100),
(3,'2019-07-02','desktop',100);


/* User purchase platform.
-- The table logs the spendings history of users that make purchases from an online shopping website which has a desktop 
and a mobile application.
-- Write an SQL query to find the total number of users and the total amount spent using mobile only, desktop only 
and both mobile and desktop together for each date.
*/

with all_spend as (
SELECT 
    spend_date ,
    user_id,  
    SUM(amount) as amount , 
    max(platform) as platform
 FROM spending 
  GROUP BY spend_date , user_id HAVING COUNT(DISTINCT platform)=1 
  
  UNION  
  SELECT 
    spend_date ,
    user_id,  
    SUM(amount) as amount , 
    "Both" as platform
 FROM spending 
  GROUP BY spend_date , user_id HAVING COUNT(DISTINCT platform)=2 
 UNION  
 SELECT DISTINCT
    spend_date , 
    NULL as user_id , 
    0 as amount,
    "Both" as platform 
     FROM spending  
)
SELECT spend_date ,platform , SUM(amount) as total_amt,
COUNT(DISTINCT user_id ) as total_user 
from all_spend 
GROUP BY spend_date ,platform 
ORDER BY spend_date , platform desc 
  ;

-------------------------------------------------------------------------------------------------
--- Recursive CTE | Leetcode Hard SQL Problem 5 | Complex SQL 12
--- total sales by year 
-------------------------------------------------------------------------------------------------
--recursive CTE
WITH RECURSIVE cte_numbers AS (
  SELECT 1 AS num -- anchor query
  UNION ALL
  SELECT num + 1 -- recursive query
  FROM cte_numbers
  WHERE num < 6 -- filter to stop the recursion
)

SELECT num FROM cte_numbers;

create table sales (
product_id int,
period_start date,
period_end date,
average_daily_sales int
);

insert into sales values
(1,'2019-01-25','2019-02-28',100),
(2,'2018-12-01','2020-01-01',10),
(3,'2019-12-01','2020-01-31',1);

SET max_sp_recursion_depth = 1000; -- Set the maximum recursion limit to 500


WITH RECURSIVE cte as 
(
  SELECT MIN(period_start) as dates ,
  MAX(period_end) as max_date 
  from sales 
  UNION ALL 
  SELECT  DATE_ADD(dates,INTERVAL 1 DAY) as dates , max_date 
  FROM cte  where dates < max_date 
)
select product_id,
YEAR(dates) as reported_year, 
SUM(average_daily_sales) as total_amount from cte 
JOIN
sales on dates BETWEEN period_start and period_end
GROUP BY product_id,YEAR(dates)
order by product_id ,YEAR(dates)
;

-------------------------------------------------------------------------------------------------
--Data Science SQL Interview Question | Recommendation System | Complex SQL 13
-------------------------------------------------------------------------------------------------
create table orders_re
(
order_id int,
customer_id int,
product_id int
);

insert into orders_re VALUES 
(1, 1, 1),
(1, 1, 2),
(1, 1, 3),
(2, 2, 1),
(2, 2, 2),
(2, 2, 4),
(3, 1, 5);

create table products (
id int,
name varchar(10)
);
insert into products VALUES 
(1, 'A'),
(2, 'B'),
(3, 'C'),
(4, 'D'),
(5, 'E');

SELECT CONCAT (pr1.name," " ,pr2.name) as pair, COUNT(1) as purchase_freq
FROM orders_re o1 
join orders_re o2 
on o1.order_id = o2.order_id  
join products pr1 on pr1.id = o1.product_id 
join products pr2 on pr2.id = o2.product_id 
where  o1.product_id > o2.product_id
GROUP BY pr1.name , pr2.name 

;

-------------------------------------------------------------------------------------------------
/*Prime subscription rate by product action
Given the following two tables, return the fraction of users, rounded to two decimal places,
who accessed Amzon music and upgraded to prime mebership within the first 3B days of signing up. */
-------------------------------------------------------------------------------------------------
create table users_amz
(
user_id integer,
name varchar(20),
join_date date
);
INSERT INTO users_amz
VALUES
  (1, 'Jon', '2020-02-14'),
  (2, 'Jane', '2020-02-14'),
  (3, 'Jill', '2020-02-15'),
  (4, 'Josh', '2020-02-15'),
  (5, 'Jean', '2020-02-16'),
  (6, 'Justin', '2020-02-17'),
  (7, 'Jeremy', '2020-02-18');


create table events
(
user_id integer,
type varchar(10),
access_date date
);

INSERT INTO events
VALUES
  (1, 'Pay', '2020-03-01'),
  (2, 'Music', '2020-03-02'),
  (2, 'P', '2020-03-12'),
  (3, 'Music', '2020-03-15'),
  (4, 'Music', '2020-03-15'),
  (1, 'P', '2020-03-16'),
  (3, 'P', '2020-03-22');


--*,DATEDIFF(e.access_date,ua.join_date)
 SELECT  
 count( DISTINCT ua.user_id ) as total_user ,
 count( DISTINCT case WHEN DATEDIFF(ua.join_date,e.access_date) <=30 then ua.user_id end ) as p,
 1.0 * count( DISTINCT case WHEN DATEDIFF(ua.join_date,e.access_date) <=30 then ua.user_id end ) / count( DISTINCT ua.user_id ) * 100
from users_amz ua
 left join events e on ua.user_id = e.user_id
 and  e.type ='P' 
 where ua.user_id  in ( select user_id from events where type = 'Music')
 ;

-------------------------------------------------------------------------------------------------
--customer retention
/* Customer retention and customer churn metrics

customer retention refers to a company's ability to turn customers into repeat buyers
and prevent them from switching to a competitor.
It indicates whether your product and the quality of your service please your existing customers
reward programs (cc companies)
wallet cash back (paytm/gpay)
zomato pro / swiggy super
retention period
*/

create table transactions(
order_id int,
cust_id int,
order_date date,
amount int
);
delete from transactions;
insert into transactions values 
(1,1,'2020-01-15',150)
,(2,1,'2020-02-10',150)
,(3,2,'2020-01-16',150)
,(4,2,'2020-02-25',150)
,(5,3,'2020-01-10',150)
,(6,3,'2020-02-20',150)
,(7,4,'2020-01-20',150)
,(8,5,'2020-02-20',150)
;


SELECT month(this_month.order_date) as month_date,
count(DISTINCT last_month.cust_id)
FROM transactions this_month 
left join transactions last_month
on this_month.cust_id = last_month.cust_id 
and TIMESTAMPDIFF(MONTH, last_month.order_date , this_month.order_date) =1
group by month(this_month.order_date)
;


SELECT month(last_month.order_date) as month_date,
count(DISTINCT last_month.cust_id)
FROM transactions  last_month
left join transactions this_month
on this_month.cust_id = last_month.cust_id 
and TIMESTAMPDIFF(MONTH, last_month.order_date , this_month.order_date) =1
where this_month.cust_id is NULL
group by month(last_month.order_date)
;

SELECT 
    MONTH(last_month.order_date) AS month_date,
    COUNT(DISTINCT CASE WHEN last_month.cust_id IS NOT NULL THEN last_month.cust_id END) AS count
FROM 
    transactions last_month
LEFT JOIN 
    transactions this_month ON this_month.cust_id = last_month.cust_id 
    AND TIMESTAMPDIFF(MONTH, last_month.order_date, this_month.order_date) = 1
WHERE 
    this_month.cust_id IS NULL
GROUP BY 
    MONTH(last_month.order_date);
;;
-------------------------------------------------------------------------------------------------
--- Second Most Recent Activity | SQL Window Analytical Functions
-------------------------------------------------------------------------------------------------
create table UserActivity
(
username      varchar(20) ,
activity      varchar(20),
startDate     Date   ,
endDate      Date
);

insert into UserActivity values 
('Alice','Travel','2020-02-12','2020-02-20')
,('Alice','Dancing','2020-02-21','2020-02-23')
,('Alice','Travel','2020-02-24','2020-02-28')
,('Bob','Travel','2020-02-11','2020-02-18');

with cte as (
  SELECT *, count(1) over (PARTITION BY username ) as total_activities ,
  RANK() over (PARTITION BY username ORDER BY `startDate` desc) as rnk
  from useractivity
  ) SELECT * FROM cte where total_activities =1 or rnk = 2;

-------------------------------------------------------------------------------------------------
-- Scenario Based SQL Question | Solving Using SCD Type 2 Concept | SQL Interview Question
--- total charges as per billing rate 
-------------------------------------------------------------------------------------------------
create table billings 
(
emp_name varchar(10),
bill_date date,
bill_rate int
);
delete from billings;
/*
insert into billings values
('Sachin','01-JAN-1990',25)
,('Sehwag' ,'01-JAN-1989', 15)
,('Dhoni' ,'01-JAN-1989', 20)
,('Sachin' ,'05-Feb-1991', 30)
;
*/

INSERT INTO billings
VALUES
    ('Sachin', '1990-01-01', 25),
    ('Sehwag', '1989-01-01', 15),
    ('Dhoni', '1989-01-01', 20),
    ('Sachin', '1991-02-05', 30);



create table HoursWorked 
(
emp_name varchar(20),
work_date date,
bill_hrs int
);
/*insert into HoursWorked values
('Sachin', '01-JUL-1990' ,3)
,('Sachin', '01-AUG-1990', 5)
,('Sehwag','01-JUL-1990', 2)
,('Sachin','01-JUL-1991', 4)
*/
INSERT INTO HoursWorked 
VALUES
    ('Sachin', '1990-07-01', 3),
    ('Sachin', '1990-08-01', 5),
    ('Sehwag', '1990-07-01', 2),
    ('Sachin', '1991-07-01', 4);

with date_range as (
  SELECT *,
  LEAD(DATE_ADD( bill_date, INTERVAL -1 day ) ,1,'9999-12-31') over (PARTITION BY emp_name ORDER BY bill_date asc) as bill_date_end
  FROM billings 
  ) 
   select hw.emp_name ,sum(dr.bill_rate * hw.bill_hrs )FROM date_range dr 
   join hoursworked hw 
   on dr.emp_name = hw.emp_name 
   And  hw.work_date BETWEEN dr.bill_date and dr.bill_date_end
   GROUP BY hw.emp_name 
   ;

-------------------------------------------------------------------------------------------------
 -- -- the activity table shows the app-installed and app purchase acrivities for spotify app along with country details
-------------------------------------------------------------------------------------------------
CREATE table activity
(
user_id varchar(20),
event_name varchar(20),
event_date date,
country varchar(20)
);
delete from activity;
insert into activity values
 (1,'app-installed','2022-01-01','India')
,(1,'app-purchase','2022-01-02','India')
,(2,'app-installed','2022-01-01','USA')
,(3,'app-installed','2022-01-01','USA')
,(3,'app-purchase','2022-01-03','USA')
,(4,'app-installed','2022-01-03','India')
,(4,'app-purchase','2022-01-03','India')
,(5,'app-installed','2022-01-03','SL')
,(5,'app-purchase','2022-01-03','SL')
,(6,'app-installed','2022-01-04','Pakistan')
,(6,'app-purchase','2022-01-04','Pakistan');

/*Question 1: find total active users each day */

select event_date, count( distinct user_id) as active_user
from activity GROUP BY event_date;

-- Question 2: find total active user each week ADD

select  WEEK(event_date)+1 , count(DISTINCT user_id)
from activity GROUP BY (WEEK(event_date)+1) ;

--- date wise total number of user who made the purchase same day they installed the app 
with cte as (
 SELECT user_id,event_date,
 case when  count(DISTINCT event_name) =2 then user_id else null end as  new_users
 FROM activity 
 GROUP BY user_id,event_date 
 
)
SELECT event_date , count(new_users) as total_user 
from cte
GROUP BY event_date ;

--- percentage of paid users in india , USA and any other country shhould be tagged as other country
with cte as (
SELECT 
CASE WHEN  country in ('USA','India') THEN  country  else 'other' END as new_country,
COUNT(DISTINCT user_id) as user_count 
FROM activity 
WHERE event_name = 'app-purchase'
GROUP BY CASE 
    WHEN  country in ('USA','India') THEN  country  else 'other' END
)
,
total as 
( 
    SELECT sum(user_count) as total_user FROM cte 
)
SELECT new_country,user_count/total_user as perc_user FROM cte , total;

----- Among  all the users who installed the ap on a given DAY
-- how many did app purchase on the very next day 
-- day wise results are expected 
with pre_data as (
    SELECT *,
    LAG(event_name, 1) over (PARTITION BY user_id order by event_date) as pre_event_name,
    LAG(event_date, 1) over (PARTITION BY user_id order by event_date) as pre_event_date
    from activity
)
select event_date,
count(DISTINCT user_id) from pre_data 
where event_name='app-purchase'
and pre_event_name='app-installed'
and DATEDIFF(event_date, pre_event_date) = 1
GROUP BY event_date
;

with pre_data as (
    SELECT *,
    LAG(event_name, 1) over (PARTITION BY user_id order by event_date) as pre_event_name,
    LAG(event_date, 1) over (PARTITION BY user_id order by event_date) as pre_event_date
    from activity
)
select event_date,
count(case when event_name = 'app-purchase' 
                  and pre_event_name= 'app-installed' 
                  and DATEDIFF(event_date , pre_event_date) = 1 then event_date else null end ) as cnt_users
    from pre_data
GROUP BY event_date
; 

-------------------------------------------------------------------------------------------------
--- How to Write Advance SQL Queries | Consecutive Empty Seats | SQL Interview Questions
--- 3 or more consecutive empty set 
-- method 1 - lead , LAG
-- method 2 - advanced AGGREGATION 
-- method 3 - analytical row number function --?
-------------------------------------------------------------------------------------------------

create table bms (seat_no int ,is_empty varchar(10));
insert into bms values
(1,'N')
,(2,'Y')
,(3,'N')
,(4,'Y')
,(5,'Y')
,(6,'Y')
,(7,'N')
,(8,'Y')
,(9,'Y')
,(10,'Y')
,(11,'Y')
,(12,'N')
,(13,'Y')
,(14,'Y');

--- 3 comsecutive empty using lead lag 
with cte as (
    SELECT *,
        LAG(is_empty,1) OVER(ORDER BY seat_no) as prev_1,
        LAG(is_empty,2) OVER(ORDER BY seat_no) as prev_2,
        LEAD(is_empty,1) OVER(ORDER BY seat_no) as next_1,
        LEAD(is_empty,2) OVER(ORDER BY seat_no) as next_2
 FROM bms )
 SELECT * FROM cte WHERE is_empty='Y' and prev_1 ='Y' and prev_2 ='Y'
 or ( is_empty='Y' and next_1 ='Y' and next_2 ='Y')
 or ( is_empty='Y' and prev_1 ='Y' and next_1 ='Y') 
 ORDER BY seat_no;

 --- 3 consecutive empty using advanced AGGREGATION
WITH cte AS (
    SELECT *,
        SUM(CASE WHEN is_empty = 'Y' THEN 1 ELSE 0 END) OVER (ORDER BY seat_no ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS prev_2,
        SUM(CASE WHEN is_empty = 'Y' THEN 1 ELSE 0 END) OVER (ORDER BY seat_no ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING) AS prev_next_1,
        SUM(CASE WHEN is_empty = 'Y' THEN 1 ELSE 0 END) OVER (ORDER BY seat_no ROWS BETWEEN CURRENT ROW and 2 FOLLOWING) AS next_2
    FROM bms
)
SELECT * FROM cte where prev_2 = 3 or prev_next_1 = 3 or next_2=3 ;


--- 3 3 comsecutive empty using analytical row num function 

with diff_num as (
    SELECT * , ROW_NUMBER() over (ORDER BY seat_no) as rn ,
    seat_no - ROW_NUMBER() over (ORDER BY seat_no) as diff
    FROM bms 
    WHERE is_empty = "Y"
),
cnt as(
    SELECT diff , COUNT(1) as c from diff_num
    GROUP BY diff HAVING COUNT(1) >=3
)
SELECT * FROM diff_num where diff in ( SELECT diff from cnt)
;

-------------------------------------------------------------------------------------------------
 -- for each store find the quarter in which that store was closed fro maintenence
-------------------------------------------------------------------------------------------------

-- DDL and DML:
CREATE TABLE STORES (
Store varchar(10),
Quarter varchar(10),
Amount int);

INSERT INTO STORES (Store, Quarter, Amount) VALUES 
('S1', 'Q1', 200),
('S1', 'Q2', 300),
('S1', 'Q4', 400),
('S2', 'Q1', 500),
('S2', 'Q3', 600),
('S2', 'Q4', 700),
('S3', 'Q1', 800),
('S3', 'Q2', 750),
('S3', 'Q3', 900);

--- method 1 
SELECT store, CONCAT('Q' , 10-SUM(CAST(RIGHT(QUARTER, 1) AS UNSIGNED)) ) AS Missing_Quarter
FROM stores
GROUP BY store;


--- method 2 using recusrsive CTE 
with RECURSIVE  cte as (
    SELECT DISTINCT store , 1 as q_no FROM stores
    UNION ALL 
    SELECT store,q_no + 1 as q_no from cte
    where q_no <4
)
,
Q as (
    SELECT store , CONCAT('Q',cast(q_no as char)) as q_no 
    FROM cte order by store
)   
select q.*
 from Q q
 LEFT join stores s on Q.store = s.store 
 and Q.q_no = s.Quarter 
 where s.`Store` is null ;

 -- ALTER TABLE stores CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
 
 --- mrthod 3 using cross join 
WITH cte AS (
    SELECT DISTINCT s1.store, s2.`QUARTER`
    FROM stores s1, stores s2
)
SELECT q.*
FROM cte q
LEFT JOIN stores s ON q.store = s.store AND q.`QUARTER` = s.`QUARTER`
WHERE s.`Store` IS NULL;

------------------------------------------------------------------------------------------------------
 --- Deadly Combination of Group By and Having Clause in SQL | SQL Interview Questions and Answers
 ------------------------------------------------------------------------------------------------------
 create table exams (student_id int, subject varchar(20), marks int);
delete from exams;
insert into exams values
 (1,'Chemistry',91),
 (1,'Physics',91),
 (2,'Chemistry',80),
(2,'Physics',90),
(3,'Chemistry',80),
(4,'Chemistry',71),
(4,'Physics',54);


SELECT student_id 
FROM exams 
WHERE subject in ('Chemistry','Physics')
GROUP BY student_id 
HAVING COUNT(DISTINCT subject) = 2 
and COUNT(DISTINCT marks) = 1 ;

-----------------------------------------------------------------------------
--- Beauty of SQL RANK Function | SQL Interview Question and Answers | Covid Cases
-----------------------------------------------------------------------------


create table covid(city varchar(50),days date,cases int);
delete from covid;
insert into covid values
('DELHI','2022-01-01',100),
('DELHI','2022-01-02',200),
('DELHI','2022-01-03',300),
('MUMBAI','2022-01-01',100),
('MUMBAI','2022-01-02',100),
('MUMBAI','2022-01-03',300),
('CHENNAI','2022-01-01',100),
('CHENNAI','2022-01-02',200),
('CHENNAI','2022-01-03',150),
('BANGALORE','2022-01-01',100),
('BANGALORE','2022-01-02',300),
('BANGALORE','2022-01-03',200),
('BANGALORE','2022-01-04',400);

/*
WITH cte AS (
    SELECT *,
        RANK() OVER (PARTITION BY city ORDER BY days ASC) AS rn,
        RANK() OVER (PARTITION BY city ORDER BY cases ASC) AS rn_cases,
        RANK() OVER (PARTITION BY city ORDER BY days ASC) -
            RANK() OVER (PARTITION BY city ORDER BY cases ASC) AS diff
    FROM covid
    ORDER BY city, days
)
SELECT *
FROM cte;

*/
WITH cte AS (
    SELECT *,
        CAST(RANK() OVER (PARTITION BY city ORDER BY days) AS SIGNED) AS rn,
        CAST(RANK() OVER (PARTITION BY city ORDER BY cases) AS SIGNED) AS rn_cases,
        CAST(RANK() OVER (PARTITION BY city ORDER BY days) AS SIGNED) -
            CAST(RANK() OVER (PARTITION BY city ORDER BY cases) AS SIGNED) AS diff
    FROM covid
    ORDER BY city, days
)
SELECT city 
FROM cte
GROUP BY city 
HAVING COUNT(DISTINCT diff) = 1 
and min(diff) = 0;

--------------------------------------------------------------------------------------------------
--Coog1e SQL interview question
--find companies who have atleast 2 users who speaks English and German both the languages
---------------------------------------------------------------------------------------------------

create table company_users 
(
company_id int,
user_id int,
language varchar(20)
);

insert into company_users values 
(1,1,'English')
,(1,1,'German')
,(1,2,'English')
,(1,3,'German')
,(1,3,'English')
,(1,4,'English')
,(2,5,'English')
,(2,5,'German')
,(2,5,'Spanish')
,(2,6,'German')
,(2,6,'Spanish')
,(2,7,'English');

with cte as (
    SELECT company_id , user_id, COUNT(1) as Lc
    FROM company_users 
    WHERE language in("English","German")
    GROUP BY company_id,user_id 
    having COUNT(1) = 2
)
SELECT company_id, COUNT(1) 
FROM cte
GROUP BY company_id HAVING COUNT(user_id) >= 2;
--------------------------------------------------------------------------------------------------
----- MEESHO HACKERRANK ONLINE SQL TEST
-- find how many products falls into customer budget along with list of products
-- In case of clash choose the less costly product
----------------------------------------------------------------------------------------------------
create table products_Mesho (product_id varchar(20) ,cost int);
insert into products_Mesho values 
('P1',200),
('P2',300),
('P3',500),
('P4',800);

create table customer_budget(customer_id int,budget int);

insert into customer_budget values (100,400),(200,800),(300,1500);

with running_cost as (
SELECT *,
SUM(cost) over (order BY cost) as r_cost 
from products_Mesho
)
 SELECT customer_id ,budget, COUNT(1) as num_products ,
 GROUP_CONCAT(product_id) as list_of_products
  FROM customer_budget cb 
 LEFT JOIN running_cost rc
 on rc.r_cost < cb.budget
GROUP BY customer_id ,budget
;

--------------------------------------------------------------------------------------------------
 --- Horizontal Sorting in SQL | Amazon Interview Question for BIE position
-- Amazon SQL Inteview question for BIE position
-- find total no of messages exchanged between each person per day
----------------------------------------------------------------------------------------------------
CREATE TABLE subscriber (
 sms_date date ,
 sender varchar(20) ,
 receiver varchar(20) ,
 sms_no int
);
-- insert some values
INSERT INTO subscriber VALUES ('2020-4-1', 'Avinash', 'Vibhor',10);
INSERT INTO subscriber VALUES ('2020-4-1', 'Vibhor', 'Avinash',20);
INSERT INTO subscriber VALUES ('2020-4-1', 'Avinash', 'Pawan',30);
INSERT INTO subscriber VALUES ('2020-4-1', 'Pawan', 'Avinash',20);
INSERT INTO subscriber VALUES ('2020-4-1', 'Vibhor', 'Pawan',5);
INSERT INTO subscriber VALUES ('2020-4-1', 'Pawan', 'Vibhor',8);
INSERT INTO subscriber VALUES ('2020-4-1', 'Vibhor', 'Deepak',50);

with cte as (
    select sms_date,
    CASE WHEN sender < receiver THEN  sender     ELSE  receiver  END as p1, 
    CASE WHEN sender > receiver THEN  sender     ELSE  receiver  END as p2 ,
    sms_no
    from subscriber
)
SELECT sms_date , p1, p2 , SUM(sms_no) as total_sms 
FROM cte GROUP BY sms_date, p1,p2
  ;
--------------------------------------------------------------------------------------------------
--- Solving 4 Tricky SQL Problems
----------------------------------------------------------------------------------------------------
CREATE TABLE students(
 studentid int NULL,
 studentname nvarchar(255) NULL,
 subject nvarchar(255) NULL,
 marks int NULL,
 testid int NULL,
 testdate date NULL
);

insert into students values
(2,'Max Ruin','Subject1',63,1,'2022-01-02'),
(3,'Arnold','Subject1',95,1,'2022-01-02'),
(4,'Krish Star','Subject1',61,1,'2022-01-02'),
(5,'John Mike','Subject1',91,1,'2022-01-02'),
(4,'Krish Star','Subject2',71,1,'2022-01-02'),
(3,'Arnold','Subject2',32,1,'2022-01-02'),
(5,'John Mike','Subject2',61,2,'2022-11-02'),
(1,'John Deo','Subject2',60,1,'2022-01-02'),
(2,'Max Ruin','Subject2',84,1,'2022-01-02'),
(2,'Max Ruin','Subject3',29,3,'2022-01-03'),
(5,'John Mike','Subject3',98,2,'2022-11-02');

--- 1- write as SQL query to get the list of the students who scored 
--- above the average marks in each subject

with avg_cte as (
    SELECT SUBJECT , AVG( marks) as avg_marks 
    from students GROUP BY subject
)

select s.* , ac.* from students s 
join avg_cte ac 
on s.subject = ac.subject 
where s.marks > ac.avg_marks
;

--- write a sql query o get the percentage of students who score more than 90 in 
--- any subject amongst the total students

SELECT 
COUNT ( DISTINCT CASE WHEN  marks > 90 THEN studentid  ELSE null   END ) / count(DISTINCT studentid) * 100 as PERCENTAGE
FROM students ;


--- write a sql query to get second highest and SECOND lowest marks for each subject 
with ranked as (
    SELECT 
    subject , marks,
    DENSE_RANK() over ( PARTITION BY subject ORDER BY marks desc) as rnk_desc ,
    DENSE_RANK() over ( PARTITION BY subject ORDER BY marks asc) as rnk_asc
    from students 
)
 SELECT subject,
 SUM( CASE     WHEN rnk_desc =2  THEN marks     ELSE  null  END )as SECOND_highest_marks ,
 SUM( CASE     WHEN rnk_asc =2  THEN marks     ELSE  null  END ) as SECOND_Lowest_marks 
 
 FROM ranked  GROUP BY subject ;

 --- for EACH student and test , identify if their marks incresed or descreded from the previous test 
with cte as (
    SELECT * ,
    LAG(marks,1) over (PARTITION BY studentid order by testdate,subject) as prev_marks
    FROM students
)
  SELECT  * ,
  CASE 
    WHEN marks > prev_marks THEN  "inc"     
    WHEN marks < prev_marks THEN  "dec"  
    else null  END
  FROM cte ;

--------------------------------------------------------------------------------------------------
--- Brilliant SQL Interview Question | Solve it without using CTE, Sub Query, Window functions
/* Find the largest order by value for each salesperson and display order details
Get the result without using sub query , cte, window functions, temp tables */
----------------------------------------------------------------------------------------------------
CREATE TABLE int_orders(
 order_number int NOT NULL,
 order_date date NOT NULL,
 cust_id int NOT NULL,
 salesperson_id int NOT NULL,
 amount float NOT NULL
);

INSERT INTO int_orders (order_number, order_date, cust_id, salesperson_id, amount) 
VALUES 
  (30, CAST('1995-07-14' AS Date), 9, 1, 460),
  (10, CAST('1996-08-02' AS Date), 4, 2, 540),
  (40, CAST('1998-01-29' AS Date), 7, 2, 2400),
  (50, CAST('1998-02-03' AS Date), 6, 7, 600),
  (60, CAST('1998-03-02' AS Date), 6, 7, 720),
  (70, CAST('1998-05-06' AS Date), 9, 7, 150),
  (20, CAST('1999-01-30' AS Date), 4, 8, 1800);

SELECT a.order_number, a.order_date ,a.cust_id,
a.amount
FROM int_orders a 
LEFT join int_orders b 
on a.salesperson_id = b.salesperson_id
GROUP BY a.order_number, a.order_date ,a.cust_id ,a.amount
HAVING a.amount >= max(b.amount)
;

--------------------------------------------------------------------------------------------------
--- Solving A Hard SQL Problem | SQL ON OFF Problem | Magic of SQL
----------------------------------------------------------------------------------------------------
create table event_status
(
event_time varchar(10),
status varchar(10)
);
insert into event_status values
('10:01','on'),
('10:02','on'),
('10:03','on'),
('10:04','off'),
('10:07','on'),
('10:08','on'),
('10:09','off'),
('10:11','on'),
('10:12','off')
;

 WITH cte1 AS (
    SELECT *,
           LAG(status, 1, status) OVER (ORDER BY event_time) AS prev_status
    FROM event_status
)
,cte2 as (
SELECT *,
       SUM(CASE WHEN status = 'on' AND prev_status = 'off' THEN 1 ELSE 0 END)
           OVER (ORDER BY event_time) AS groupkey
FROM cte1
)
 SELECT MIN(event_time) AS login_
 ,MAX(event_time) AS logout_
 ,COUNT(1) - 1 AS on_count 
 FROM cte2 GROUP BY groupkey
 ;

--------------------------------------------------------------------------------------------------
--LeetCode Hard SQL problem | Students Reports By Geography | Pivot Ka Baap
--------------------------------------------------------------------------------------------------
create table players_location ( name varchar(20), city varchar(20) );

delete from players_location;

insert into players_location
values ('Sachin', 'Mumbai')
, ('Virat', 'Delhi')
, ('Rahul', 'Bangalore')
, ('Rohit', 'Mumbai')
, ('Mayank', 'Bangalore')
;

WITH cte as (
    SELECT *
    ,ROW_NUMBER() OVER (PARTITION BY city ORDER BY name asc) as player_group
    FROM players_location
)
SELECT 
MAX(CASE WHEN city='Bangalore' THEN  name END )AS Bangalore
,MAX(CASE WHEN city='Mumbai' THEN  name END) AS Mumbai
,MAX(CASE WHEN city='Delhi' THEN  name END )AS Delhi
 FROM cte 
 GROUP BY player_group
 ORDER BY player_group;

--------------------------------------------------------------------------------------------------
---- -- write a SQL query to find the median salary of each company.
--Bonus points if you can solve it without using any built-in SQL functions.
--------------------------------------------------------------------------------------------------
create table employee 
(
emp_id int,
company varchar(10),
salary int
);

insert into employee values 
(1,'A',2341)
,(2,'A',341)
,(3,'A',15)
,(4,'A',15314)
,(5,'A',451)
,(6,'A',513)
,(7,'B',15)
,(8,'B',13)
,(9,'B',1154)
,(10,'B',1345)
,(11,'B',1221)
,(12,'B',234)
,(13,'C',2345)
,(14,'C',2645)
,(15,'C',2645)
,(16,'C',2652)
,(17,'C',65)
;

WITH cte as (
    SELECT * 
        ,ROW_NUMBER() OVER (PARTITION BY company ORDER BY salary ASC ) AS rn
        ,COUNT(1) OVER (PARTITION BY company) AS total_cnt
    FROM employee 
)
SELECT company,AVG(salary) AS Med_sal
FROM cte
WHERE rn BETWEEN total_cnt /2 AND total_cnt/2 +1
GROUP BY company
;

--------------------------------------------------------------------------------------------------
-- Groww SQL Interview Question based on Stock Market Transactions
--------------------------------------------------------------------------------------------------

Create Table Buy (
Date Int,
Time Int,
Qty Int,
per_share_price int,
total_value int );

Create Table sell(
Date Int,
Time Int,
Qty Int,
per_share_price int,
total_value int );

INSERT INTO Buy (date, time, qty, per_share_price, total_value)
VALUES
(15, 10, 10, 10, 100),
(15, 14, 20, 10, 200);

INSERT INTO Sell(date, time, qty, per_share_price, total_value)
VALUES (15, 15, 15, 20, 300);

WITH cte AS (
    SELECT
        buy.`Time` AS buy_time,
        buy.`Qty` AS buy_qty,
        sell.`Qty` AS sell_qty,
        SUM(buy.`Qty`) OVER (ORDER BY buy.`Time`) AS r_buy_qty,
        COALESCE(SUM(buy.`Qty`) OVER (ORDER BY buy.`Time` ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING), 0) AS r_buy_qty_prev
    FROM buy
    JOIN sell ON buy.`Date` = sell.`Date` AND buy.`Time` < sell.`Time`
) 
SELECT buy_time,
    r_buy_qty -sell_qty as buy_qty ,
    '' AS sell_qty
 from cte where sell_qty < r_buy_qty
 UNION ALL
SELECT buy_time,
    CASE WHEN sell_qty >= r_buy_qty THEN  buy_qty  ELSE  sell_qty - r_buy_qty_prev END AS buy_qty,
    CASE WHEN sell_qty >= r_buy_qty THEN  buy_qty  ELSE  sell_qty - r_buy_qty_prev END AS shell_qty
From cte 
 
   ;

--------------------------------------------------------------------------------------------------
-- window functions 
-- write an sql to find details of employees with 3rd highest salary in each department,
-- in ase there are less then 3 employees in a department then return employee details with lowest salary in that dep.
--------------------------------------------------------------------------------------------------
CREATE TABLE emp (
  emp_id int,
  emp_name varchar(50),
  salary int,
  manager_id int,
  emp_age int,
  dep_id int,
  dep_name varchar(20),
  gender varchar(10)
);

INSERT INTO emp VALUES
(1, 'Ankit', 14300, 4, 39, 100, 'Analytics', 'Female'),
(2, 'Mohit', 14000, 5, 48, 200, 'IT', 'Male'),
(3, 'Vikas', 12100, 4, 37, 100, 'Analytics', 'Female'),
(4, 'Rohit', 7260, 2, 16, 100, 'Analytics', 'Female'),
(5, 'Mudit', 15000, 6, 55, 200, 'IT', 'Male'),
(6, 'Agam', 15600, 2, 14, 200, 'IT', 'Male'),
(7, 'Sanjay', 12000, 2, 13, 200, 'IT', 'Male'),
(8, 'Ashish', 7200, 2, 12, 200, 'IT', 'Male'),
(9, 'Mukesh', 7000, 6, 51, 300, 'HR', 'Male'),
(10, 'Rakesh', 8000, 6, 50, 300, 'HR', 'Male'),
(11, 'Akhil', 4000, 1, 31, 500, 'Ops', 'Male');

WITH cte as (
    SELECT emp_id, 
        emp_name,
        salary,
        dep_id,
        dep_name,
        rank() OVER(PARTITION BY dep_id ORDER BY salary desc )as rn,
        COUNT(1) OVER(PARTITION BY dep_id) AS cnt
    FROM emp 
) 
  SELECT * FROM cte WHERE rn = 3 
  OR ( cnt < 3 and rn = cnt) ;
  
--------------------------------------------------------------------------------------------------
-- Leetcode Hard SQL Problem | Human Traffic of Stadium
-- write a query to display the records which have 3 or more consecutive rows
-- with the amount of people mare than 100(inclusive) each day

--------------------------------------------------------------------------------------------------
create table stadium (
    id int,
    visit_date date,
    no_of_people int
);

insert into stadium
values (1,'2017-07-01',10)
,(2,'2017-07-02',109)
,(3,'2017-07-03',150)
,(4,'2017-07-04',99)
,(5,'2017-07-05',145)
,(6,'2017-07-06',1455)
,(7,'2017-07-07',199)
,(8,'2017-07-08',188);

WITH group_nums as (
    SELECT * ,
        ROW_NUMBER() OVER (ORDER BY visit_date ) as rn ,
        id - ROW_NUMBER() OVER (ORDER BY visit_date ) AS grps
    FROM stadium 
    WHERE no_of_people >= 100
)
 SELECT * FROM group_nums 
 WHERE grps in (
        SELECT grps
        FROM group_nums 
        GROUP BY grps
        HAVING COUNT(1) > 3
 )
     ; 

--------------------------------------------------------------------------------------------------
--- business_city table has data from the day udaan has started operation
--- write a SQL to identify yearwise count of new cities where udaan started their operations
--------------------------------------------------------------------------------------------------
create table business_city (
    business_date date,
    city_id int
);
delete from business_city;
insert into business_city
values(cast('2020-01-02' as date),3)
,(cast('2020-07-01' as date),7)
,(cast('2021-01-01' as date),3)
,(cast('2021-02-03' as date),19)
,(cast('2022-12-01' as date),3)
,(cast('2022-12-15' as date),3)
,(cast('2022-02-28' as date),12);

WITH cte AS (
    SELECT 
        YEAR(business_date)  as bus_year,
        city_id
    FROM business_city 
) 
    SELECT 
        c1.bus_year,
        COUNT(DISTINCT CASE 
          WHEN c2.city_id is NULL  THEN  c1.city_id  END) as no_of_new_cities
    FROM cte c1 
    LEFT JOIN cte c2 
    ON c1.bus_year > c2.bus_year 
        AND c1.city_id = c2.city_id
    GROUP BY bus_year;

--------------------------------------------------------------------------------------------------
--- PharmEasy SQL Interview Question | Consecutive Seats in a Movie Theatre | Data Analytics
---  there are 3 rows in a movie hall each with 18 seats in each row
---  write a SQL to find 4 consecutive empty seats
--------------------------------------------------------------------------------------------------
CREATE TABLE movie (
  seat varchar(50),
  occupancy int
);

INSERT INTO movie (seat, occupancy)
VALUES
  ('a1', 1), ('a2', 1), ('a3', 0), ('a4', 0), ('a5', 0),
  ('a6', 0), ('a7', 1), ('a8', 1), ('a9', 0), ('a10', 0),
  ('b1', 0), ('b2', 0), ('b3', 0), ('b4', 1), ('b5', 1),
  ('b6', 1), ('b7', 1), ('b8', 0), ('b9', 0), ('b10', 0),
  ('c1', 0), ('c2', 1), ('c3', 0), ('c4', 1), ('c5', 1),
  ('c6', 0), ('c7', 1), ('c8', 0), ('c9', 0), ('c10', 1);


WITH cte1 as(
    SELECT *,
       LEFT(seat, 1) AS row_id,
       CAST(SUBSTR(seat, 2, 2) AS SIGNED) AS seat_id
    FROM movie

)
, cte2 as (
    SELECT *,
        MAX(occupancy) OVER(PARTITION BY row_id ORDER BY seat_id ROWS BETWEEN CURRENT ROW AND 3 FOLLOWING) as is_4_empty
        ,COUNT(occupancy) OVER(PARTITION BY row_id ORDER BY seat_id ROWS BETWEEN CURRENT ROW AND 3 FOLLOWING) as cnt
 FROM cte1 
)
, cte3 AS   (
    SELECT * FROM cte2 WHERE is_4_empty = 0 and cnt =4 
)
   
   SELECT cte2.* 
   FROM cte2 
   join cte3 
   on cte2.row_id = cte3.row_id AND cte2.seat_id BETWEEN cte3.seat_id and cte3.seat_id +3 

   ;


--------------------------------------------------------------------------------------------------
--- Bosch Scenario Based SQL Interview Question | Solving Using 3 Methods | Data Analytics
--- write a sq to etermrne phone numbers that satisfy beoow conditions
-- 1- the numbers have both incoming and outgoing calls
-- 2- the sum of duration of outgoing calls should be greater than sum of duration of incoming calls 
--------------------------------------------------------------------------------------------------

create table call_details  (
    call_type varchar(10),
    call_number varchar(12),
    call_duration int
);

insert into call_details
values ('OUT','181868',13)
,('OUT','2159010',8)
,('OUT','2159010',178)
,('SMS','4153810',1)
,('OUT','2159010',152)
,('OUT','9140152',18)
,('SMS','4162672',1)
,('SMS','9168204',1)
,('OUT','9168204',576)
,('INC','2159010',5)
,('INC','2159010',4)
,('SMS','2159010',1)
,('SMS','4535614',1)
,('OUT','181868',20)
,('INC','181868',54)
,('INC','218748',20)
,('INC','2159010',9)
,('INC','197432',66)
,('SMS','2159010',1)
,('SMS','4535614',1);


--- method -1 using cte and filter , case when 
with cte as (
    SELECT call_number,
    SUM(CASE WHEN call_type='OUT' THEN  call_duration ELSE  null END) as out_dur
    ,SUM(CASE WHEN call_type='INC' THEN  call_duration ELSE  null END) as in_dur
FROM call_details 
GROUP BY call_number
)
    SELECT call_number from cte 
        where in_dur is not null 
        AND out_dur is not null 
        AND out_dur > in_dur
;       


---- method 2 using having clause 

SELECT call_number 
 FROM call_details
 GROUP BY call_number 
 having SUM(CASE WHEN call_type='OUT' THEN  call_duration ELSE  null END) > SUM(CASE WHEN call_type='INC' THEN  call_duration ELSE  null END) 
    AND SUM(CASE WHEN call_type='OUT' THEN  call_duration ELSE  null END) > 0
    AND SUM(CASE WHEN call_type='INC' THEN  call_duration ELSE  null END) > 0
;
---- method 3 using cte ang join 

with cte_out as (
    SELECT call_number,
         SUM (call_duration ) as duration
    FROM call_details 
    WHERE call_type = 'OUT'
    GROUP BY call_number
),
 cte_in as (
        SELECT call_number,
            SUM (call_duration ) as duration
        FROM call_details 
        WHERE call_type = 'INC'
        GROUP BY call_number
    )
    SELECT cte_out.call_number from cte_out
    join cte_in 
        ON cte_out.call_number = cte_in.call_number
    WHERE cte_out.duration > cte_in.duration
    ;

--------------------------------------------------------------------------------------------------
--- Cricket Analytics with SQL | Find Sachin's Milestone Matches | Advance SQL
--------------------------------------------------------------------------------------------------

CREATE TABLE sachin_batting_scores (
  `Match` VARCHAR(255),
  Innings INT,
  match_date VARCHAR(255),
  Versus VARCHAR(255),
  Ground VARCHAR(255),
  How_Dismissed TEXT,
  Runs INT,
  Balls_faced INT,
  strike_rate DOUBLE
);

LOAD DATA INFILE "C:\\Users\\dev30\\Downloads\\sachin_batting_scores.csv"
INTO TABLE sachin_batting_scores
FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n'
IGNORE 1 LINES; 
-- To skip the header row if present

SELECT COUNT(*) FROM sachin_batting_scores ;

WITH cte1 AS (
    SELECT
        `Match`,
        `Innings`,
        `Runs`,
        SUM(`Runs`) OVER (ORDER BY `Match` ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as rolling_sum
    FROM sachin_batting_scores 
),
cte2 AS (
    SELECT 1 AS milestone_num, 1000 as milestone_runs
    UNION ALL 
    SELECT 2 AS milestone_num, 5000 as milestone_runs
    UNION ALL
    SELECT 3 AS milestone_num, 10000 as milestone_runs
    UNION ALL
    SELECT 4 AS milestone_num, 15000 as milestone_runs
) 
SELECT
    cte2.milestone_num,
    cte2.milestone_runs,
    MIN(cte1.`Match`) as milestone_match,
    (SELECT cte1_inner.`Innings` FROM cte1 cte1_inner WHERE cte1_inner.rolling_sum > cte2.milestone_runs LIMIT 1) as milestone_innings
FROM cte2 
INNER JOIN cte1 ON cte1.rolling_sum > cte2.milestone_runs 
GROUP BY cte2.milestone_num, cte2.milestone_runs
ORDER BY cte2.milestone_num;


----------------------------------------------------------------------------------------------------------------
--- This SQL Problem I Could Not Answer in Deloitte Interview | Last Not Null Value | Data Analytics
--- write a sq1 to populate category values to the last not null value
-----------------------------------------------------------------------------------------------------------------
create table brands (
    category varchar(20),
    brand_name varchar(20)
);

insert into brands values
('chocolates','5-star')
,(null,'dairy milk')
,(null,'perk')
,(null,'eclair')
,('Biscuits','britannia')
,(null,'good day')
,(null,'boost');
---------------------------------------
with cte1 AS (
    SELECT *,
        ROW_NUMBER() OVER(ORDER BY (SELECT null)) as rn
    FROM brands 
)
, cte2 as (
        SELECT *, 
             LEAD(rn, 1 ) OVER(ORDER BY rn) as next_rn
        FROM cte1 WHERE category is NOT NULL

) 
     SELECT cte2.category
     ,cte1.brand_name
     FROM cte1 
     JOIN cte2 ON cte1.rn >= cte2.rn 
     and (cte1.rn <= cte2.next_rn-1
     or cte2.next_rn is NULL )
;

----------------------------------------------------------------------------------------------------------------
--- - Write an SQL query to report the students (student id, student _ name) being "quietl in ALL exams.
-- A "quite" student is the one who took at least one exam and didn't score neither the high score nor the low score in any of the exam.
-- Don't return the student who has never taken any exam. Return the result table ordered by student id.
-----------------------------------------------------------------------------------------------------------------
create table students
(
student_id int,
student_name varchar(20)
);
insert into students values
(1,'Daniel'),(2,'Jade'),(3,'Stella'),(4,'Jonathan'),(5,'Will');

create table exams_q(
    exam_id int,
    student_id int,
    score int
    );

insert into exams_q values
(10,1,70),(10,2,80),
(10,3,90),(20,1,80),
(30,1,70),(30,3,80),
(30,4,90),(40,1,60),
(40,2,70),(40,4,80)
;

WITH cte as (    
    SELECT exam_id ,
        MIN(score) as min_score,
        MAX(score) as max_score
    FROM exams_q GROUP BY exam_id 
) 
    SELECT exams_q.student_id
    FROM exams_q 
    JOIN cte 
    ON exams_q.exam_id = cte.exam_id
    GROUP BY student_id 
    having max(case WHEN score = min_score or score = max_score then 1 else 0 end ) = 0
   
    ;

---------------------------------------------------------------------------------------------------
---    Walmart Labs SQL Interview Question for Senior Data Analyst Position | Data Analytics
/*there is a phonelog table that has information about callers' call history.
write a SQL to find out callers whose first and last call was to the same person on a given day.*/
----------------------------------------------------------------------------------------------------

create table phonelog(
    Callerid int, 
    Recipientid int,
    Datecalled datetime
);

insert into phonelog(Callerid, Recipientid, Datecalled)
values(1, 2, '2019-01-01 09:00:00.000'),
       (1, 3, '2019-01-01 17:00:00.000'),
       (1, 4, '2019-01-01 23:00:00.000'),
       (2, 5, '2019-07-05 09:00:00.000'),
       (2, 3, '2019-07-05 17:00:00.000'),
       (2, 3, '2019-07-05 17:20:00.000'),
       (2, 5, '2019-07-05 23:00:00.000'),
       (2, 3, '2019-08-01 09:00:00.000'),
       (2, 3, '2019-08-01 17:00:00.000'),
       (2, 5, '2019-08-01 19:30:00.000'),
       (2, 4, '2019-08-02 09:00:00.000'),
       (2, 5, '2019-08-02 10:00:00.000'),
       (2, 5, '2019-08-02 10:45:00.000'),
       (2, 4, '2019-08-02 11:00:00.000');

WITH calls as (
    SELECT `Callerid`, 
        CAST(`Datecalled` as date) as called_date,
        MIN(`Datecalled`) as first_call,
        MAX(`Datecalled`) as last_call 
    FROM phonelog
    GROUP BY `Callerid`,CAST(`Datecalled` as date)
) 
SELECT c.*,
    p1.`Recipientid` as first_recipient
FROM calls c
INNER JOIN phonelog p1 
    on c.`Callerid` = p1.`Callerid` and c.first_call=p1.`Datecalled`
INNER JOIN phonelog p2 
    ON c.`Callerid` = p2.`Callerid` and c.last_call=p2.`Datecalled`
where p1.`Recipientid` = p2.`Recipientid`
;

---------------------------------------------------------------------------------------------------
---Microsoft SQL Interview Question for Data Engineer Position | Data Analytics
/*A company wants to hire new employees. The budget of the company for the salaries is $70000.
The company's criteria for hiring are:
Keep hiring the senior with the smallest salary until you cannot hire any more seniors.
Use the remaining budget to hire the junior with the smallest salary.
Keep hiring the junior with the smallest salary until you cannot hire any more juniors.
Write an SQL query to find the seniors and juniors hired under the mentioned criteria.*/
---------------------------------------------------------------------------------------------------


create table candidates (
emp_id int,
experience varchar(20),
salary int
);

delete from candidates;

insert into candidates values
(1,'Junior',10000)
,(2,'Junior',15000)
,(3,'Junior',40000)
,(4,'Senior',16000)
,(5,'Senior',20000)
,(6,'Senior',50000);

with cte as (
    select * 
         ,sum(salary) over (partition by experience order by salary  rows between UNBOUNDED PRECEDING and CURRENT row) as running_sal
    from candidates 
),
seniors as (
    select * from   cte 
    where experience ='Senior' 
    and running_sal <= 70000
)
select * from cte 
where  experience ='Junior' 
and running_sal <= 70000 - (select sum(salary) from seniors)
union all 
select * from seniors 
;

---------------------------------------------------------------------------------------------------
--Double Self Join in SQL | Amazon Interview Question | Excel Explanation Included | Data Analytics
--write a SQL to list emp name along with thier manager and senior manager name
--senior manager is manager's manager
---------------------------------------------------------------------------------------------------

create table emp_n(
    emp_id int,
    emp_name varchar(20),
    department_id int,
    salary int,
    manager_id int,
    emp_age int
    );

INSERT INTO emp_n VALUES 
(1, 'Ankit', 100, 10000, 4, 39),
(2, 'Mohit', 100, 15000, 5, 48),
(3, 'Vikas', 100, 12000, 4, 37),
(4, 'Rohit', 100, 14000, 2, 16),
(5, 'Mudit', 200, 20000, 6, 55),
(6, 'Agam', 200, 12000, 2, 14),
(7, 'Sanjay', 200, 9000, 2, 13),
(8, 'Ashish', 200, 5000, 2, 12),
(9, 'Mukesh', 300, 6000, 6, 51),
(10, 'Rakesh', 500, 7000, 6, 50);

select 
    e.emp_id,
    e.emp_name,
    e.salary,
    m.emp_name as manager_name ,
    sm.emp_name as senior_manager,
    m.salary as manager_salary,
    sm.salary as Senior_manager_salary
from emp_n e 
LEFT join emp_n m 
on e.manager_id = m.emp_id
left join emp_n sm
on m.manager_id = sm.emp_id
;

---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
-- Create the rental_amenities table
CREATE TABLE rental_amenities (
    rental_id INT,
    amenity VARCHAR(50)
);

-- Insert data into the rental_amenities table
INSERT INTO rental_amenities (rental_id, amenity)
VALUES
    (1, 'Pool'),
    (1, 'Gym'),
    (1, 'Balcony'),
    (2, 'Gym'),
    (3, 'Pool'),
    (3, 'Balcony'),
    (4, 'Gym'),
    (4, 'Balcony'),
    (5, 'Pool'),
    (5, 'Gym'),
    (6, 'Gym'),
    (7, 'Pool'),
    (8, 'Gym'),
    (9, 'Balcony'),
    (10, 'Pool');

-- The query

DELIMITER //
CREATE FUNCTION factorial(n INT)
RETURNS INT
BEGIN
    DECLARE result INT;
    DECLARE i INT;
    
    SET result = 1;
    SET i = 1;
    
    WHILE i <= n DO
        SET result = result * i;
        SET i = i + 1;
    END WHILE;
    
    RETURN result;
END;
//
DELIMITER ;


SELECT CAST(SUM(factorial(cnt) / (factorial(cnt - 2) * factorial(2))) AS SIGNED) AS result
FROM (
    SELECT amenity_list, COUNT(rental_id) AS cnt
    FROM (
        SELECT rental_id, GROUP_CONCAT(amenity ORDER BY amenity) AS amenity_list
        FROM rental_amenities
        GROUP BY rental_id
    ) AS A
    GROUP BY amenity_list
    HAVING COUNT(rental_id) > 1
) AS B;

---------------------------------------------------------------------------------------------------
--Uber Very Interesting SQL Interview Problem | Solving Using 2 Methods | Data Analytics
--write a query to print total rides and profit rides for each driver
--profit ride is when the end location of current ride is same as start location on next ride
---------------------------------------------------------------------------------------------------
create table drivers(id varchar(10), start_time time, end_time time, start_loc varchar(10), end_loc varchar(10));
insert into drivers values
('dri_1', '09:00', '09:30', 'a','b')
,('dri_1', '09:30', '10:30', 'b','c')
,('dri_1','11:00','11:30', 'd','e');

insert into drivers values
('dri_1', '12:00', '12:30', 'f','g'),
('dri_1', '13:30', '14:30', 'c','h');
insert into drivers values
('dri_2', '12:15', '12:30', 'f','g'),
('dri_2', '13:30', '14:30', 'c','h');

-- method 1 using lead window function 
with cte as (
SELECT *, 
LEAD(start_loc,1) OVER(PARTITION BY id ORDER BY start_time) as next_start_loc
FROM drivers
) 
SELECT id, COUNT(1) as total_rides,
SUM( case WHEN end_loc = next_start_loc then 1 else 0 end ) profit_ride
from cte GROUP BY id
;

-- method 1 using self join 
with rides as (
SELECT *, 
ROW_NUMBER() OVER(PARTITION BY id ORDER BY start_time ) as rn
 FROM drivers
)
  SELECT r1.id , 
  count(1) as total_rides,
  count(r2.id ) as profit_ride
  FROM rides r1 
  LEFT JOIN rides r2 
  ON r1.id = r2.id and r1.end_loc = r2.start_loc and r1.rn +1 = r2.rn
  GROUP BY r1.id 
;

---------------------------------------------------------------------------------------------------
-- Write a sql query to find users who purchased different products on different dates
--ie products purchased on any given day are not repeated on any other day
---------------------------------------------------------------------------------------------------

create table purchase_history
(userid int
,productid int
,purchasedate date
);

INSERT INTO purchase_history 
(userid, productid, purchasedate) VALUES
(1, 1, '2012-01-23'),
(1, 2, '2012-01-23'),
(1, 3, '2012-01-25'),
(2, 1, '2012-01-23'),
(2, 2, '2012-01-23'),
(2, 2, '2012-01-25'),
(2, 4, '2012-01-25'),
(3, 4, '2012-01-23'),
(3, 1, '2012-01-23'),
(4, 1, '2012-01-23'),
(4, 2, '2012-01-25');

WITH cte as (
    SELECT
    userid,
    COUNT(DISTINCT purchasedate) no_of_dates,
    COUNT(productid) cnt_product,
    COUNT(DISTINCT productid) count_dist_product
 FROM purchase_history 
 GROUP BY userid
)
  SELECT * FROM cte WHERE no_of_dates > 1 
  AND  cnt_product = count_dist_product
  ;


  SELECT
    userid,
    COUNT(DISTINCT purchasedate) no_of_dates,
    COUNT(productid) cnt_product,
    COUNT(DISTINCT productid) count_dist_product
 FROM purchase_history 
 GROUP BY userid
 HAVING COUNT(DISTINCT purchasedate) >1
 AND COUNT(productid) = COUNT(DISTINCT productid);

 ---------------------------------------------------------------------------------------------------
 --- 
 ---------------------------------------------------------------------------------------------------