CREATE DATABASE InsuranceDatabase;
USE InsuranceDatabase;

create table Individual_Budgets
(
Branch	varchar(20),
Account_Exe_ID INT,
Employee_Name	varchar(30),
New_Role2 varchar(30),
New_Budget	float,
Cross_sell_bugdet float,
Renewal_Budget float)
;

LOAD DATA INFILE  'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/New Insurance Project/Individual Budgets.csv'
INTO TABLE Individual_Budgets
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
SHOW VARIABLES LIKE "secure_file_priv"; 

select * from  Individual_Budgets;


create table brokerage(
client_name	varchar(20),
policy_number varchar(100),
policy_status varchar(30),
policy_start_date Date,
policy_end_date Date,
product_group varchar(30),
Account_Exe_ID  INT,
Exe_Name Varchar(30),
branch_name varchar(10),
solution_group	varchar(50),
income_class varchar(10),
Amount	float,
income_due_date date,
revenue_transaction_type	varchar(10),
renewal_status	varchar(30),
last_updated_date date)
;
drop table brokerage;
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/New Insurance Project/brokerage.csv'
INTO TABLE brokerage
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;
select * from brokerage;

create table fees( 
client_name	varchar(20),
branch_name	varchar (20),
solution_group	varchar(100),
Account_Exe_ID	int,
Account_Executive	varchar(50),
income_class	varchar(50),
Amount	float,
income_due_date	date,
revenue_transaction_type varchar(30)
)
;
drop table fees;
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/New Insurance Project/fees.csv'
into table fees
fields terminated by  ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;
select * from fees;


create table invoice(
invoice_number	int,
invoice_date	date,
revenue_transaction_type	varchar(50),
branch_name	varchar(50),
solution_group	varchar(50),
Account_Exe_ID	int,
Account_Executive	varchar(50),
income_class	varchar(50),
client_name	varchar(100),
policy_number	varchar(100),
Amount	float,
income_due_date date)
;

drop table invoice;
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/New Insurance Project/invoice.csv'
into table invoice
fields terminated by  ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;
select * from invoice;


create table meeting(
Account_Exe_ID	int,
Account_Executive	varchar(50),
branch_name	varchar(50),
global_attendees	varchar(200),
meeting_date date)
;

drop table meeting;
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/New Insurance Project/meeting.csv'
into table meeting
fields terminated by  ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;
select * from meeting;



create table opportunity(
opportunity_name	varchar(100),
opportunity_id	varchar(50),
Account_Exe_Id	int,
Account_Executive	varchar(100),
premium_amount	int,
revenue_amount	int,
closing_date	date,
stage	varchar(100),
branch	varchar(50),
specialty	varchar(100),
product_group	varchar(100),
product_sub_group	varchar(50),
risk_details varchar(200)
)
; 

drop table opportunity;
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/New Insurance Project/opportunity.csv'
into table opportunity
fields terminated by  ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;
select * from opportunity;

