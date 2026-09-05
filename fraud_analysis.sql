create database fraud_analysis;
use fraud_analysis;
create table Customer_Data(Customer_ID varchar(20) Primary key,
						   Customer_Name varchar(100) not null,
                           Gender varchar(20) check(Gender in('Female','Male')),
                           Age int,
                           Marital_Status varchar(30),
                           Occupation varchar(100),
                           Annual_income int,
                           Customer_Segment varchar(50),
                           State varchar(50),
                           City varchar(50),
                           Account_Type Varchar(50),
                           Customer_Since date);
                           
create table Cards_Data(Card_ID varchar(20) primary key,
                        Customer_ID varchar(20),
                        Card_Type varchar(20) not null,
                        Card_Network varchar(50) not null,
                        Credit_Limit int not null,
                        Card_Status varchar(80) not null,
                        Contactless varchar(20),
                        Car_Mode varchar(50),
                        Issue_Date Date not null,
                        Expiry_Date Date not null,
                        foreign key(Customer_ID) references Customer_Data(Customer_ID)); 
                        
create table  Merchant_Data(Merchant_ID varchar(20) primary key,
							Merchant_Name varchar(100),
                            Merchant_Category varchar(50),
                            State varchar(50),
                            City varchar(50),
							Merchant_Risk_Level varchar(20),
                            Merchant_Rating float CHECK(Merchant_Rating BETWEEN 1 AND 5),
                            Merchant_Status varchar(20),
                            Merchant_Since date);
                            
create table Transaction_Data(Transaction_ID varchar(20) Primary key,
							  Customer_ID varchar(20),
                              Card_ID varchar(20),
                              Merchant_ID varchar(20),
                              Transaction_Date date,
                              Transaction_Time time,
                              Transaction_Amount decimal(12,2),
                              Payment_Method varchar(50),
                              Transaction_Channel varchar(50),
                              Device_Type Varchar(100),
                              Transaction_Status varchar(50),
                              Is_International tinyint,
                              Fraud_Flag tinyint,
                              Fraud_Reason varchar(255),
                              Merchant_Risk_Level varchar(50),
                              Merchant_Category varchar(100),
                              Customer_State varchar(100),
                              Customer_City varchar(50),
                              Merchant_State varchar(100),
                              Merchant_City varchar(50),
                             CONSTRAINT FK_CUSTOMER Foreign key(Customer_ID) REFERENCES Customer_Data(Customer_ID),
							 CONSTRAINT FK_CARD Foreign key(Card_ID) references Cards_Data(Card_ID),
                             CONSTRAINT FK_MERCHANT Foreign key(Merchant_ID) REFERENCES Merchant_Data(Merchant_ID)) ;
                             
                             show tables;
                             describe cards_data;
                             select * from cards_data;
                             select * from customer_data;
                             select * from merchant_data;
                             select * from transaction_data;
                             select count(*) from customer_data;
                             describe customer_data;
SELECT * FROM Customer_Data LIMIT 5;
use fraud_analysis;
select count(*) from Customer_Data;
SELECT * FROM Customer_Data;
select max(Customer_ID) AS highest_customer from Customer_Data;
select count(*) from Cards_Data;
select count(*) from Merchant_Data;
select count(*) from Transaction_Data;
SELECT COUNT(DISTINCT Transaction_ID) AS unique_transaction_ids
FROM Transaction_Data;
TRUNCATE TABLE Transaction_Data;
SELECT COUNT(*) AS transaction_rows FROM Transaction_Data;
SHOW VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile = 1;
DESCRIBE Transaction_Data;
LOAD DATA LOCAL INFILE 'C:/End_to_End_Project/financial fraud datasets(EDA)/Transaction_Data_250k.csv'
INTO TABLE Transaction_Data
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    Transaction_ID,
    Customer_ID,
    Card_ID,
    Merchant_ID,
    Transaction_Date,
    Transaction_Time,
    Transaction_Amount,
    Payment_Method,
    Transaction_Channel,
    Device_Type,
    Transaction_Status,
    Is_International,
    Fraud_Flag,
    Fraud_Reason,
    Merchant_Risk_Level,
    Merchant_Category,
    Customer_State,
    Customer_City,
    Merchant_State,
    Merchant_City
);
use fraud_analysis;
select count(*) from Transaction_Data;
SELECT COUNT(*) AS transaction_rows
FROM Transaction_Data;
TRUNCATE TABLE Transaction_Data;
SHOW VARIABLES LIKE 'secure_file_priv';

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Transaction_Data_250k.csv'
INTO TABLE Transaction_Data
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(
    Transaction_ID,
    Customer_ID,
    Card_ID,
    Merchant_ID,
    Transaction_Date,
    Transaction_Time,
    Transaction_Amount,
    Payment_Method,
    Transaction_Channel,
    Device_Type,
    Transaction_Status,
    Is_International,
    Fraud_Flag,
    Fraud_Reason,
    Merchant_Risk_Level,
    Merchant_Category,
    Customer_State,
    Customer_City,
    Merchant_State,
    Merchant_City
);

SELECT COUNT(*) FROM Transaction_Data;

select * from Transaction_Data limit 5;
select * from Transaction_Data order by Transaction_ID DESC limit 5;

-- DATA VALIDATION

SELECT COUNT(*) FROM Customer_Data;
SELECT COUNT(*) FROM Cards_Data;
SELECT COUNT(*) FROM Merchant_Data;
SELECT COUNT(*) FROM Transaction_Data;
 
-- CHECK THE RELATIONSHIP

SELECT COUNT(*) AS UNMATCHED_DATA 
FROM Transaction_Data T 
LEFT JOIN Customer_Data CS
ON T.Customer_ID=CS.Customer_ID
WHERE CS.Customer_ID=NULL;

SELECT COUNT(*) AS UNMATCHED_DATA 
FROM Transaction_Data T 
LEFT JOIN Cards_Data CA
ON T.Card_ID=CA.Card_ID
WHERE CA.Card_ID=NULL;

SELECT COUNT(*) AS UNMATCHED_DATA 
FROM Transaction_Data T 
LEFT JOIN Merchant_Data M
ON T.Merchant_ID=M.Merchant_ID
WHERE M.Merchant_ID=NULL;

SELECT COUNT(*) AS UNMATCHED_DATA 
FROM Cards_Data CA 
LEFT JOIN Customer_Data CS
ON CA.Customer_ID=CS.Customer_ID
WHERE CS.Customer_ID=NULL;

-- 1. Overall Transaction & Fraud Performance

select * from Transaction_Data;

-- What is the total number of transactions?

SELECT COUNT(Transaction_ID) AS Total_Transaction FROM Transaction_Data;

-- How many transactions are fraudulent and how many are legitimate?

SELECT COUNT(*) AS Fraudlent from Transaction_Data where Fraud_Flag = 1;
SELECT COUNT(*) AS Legitimate from Transaction_Data where Fraud_Flag = 0;

-- What is the overall fraud rate (%)?

select round(sum(Fraud_Flag)/count(*) * 100,2) as Fraud_Rate from Transaction_Data;


-- What is the total transaction amount?

SELECT SUM(Transaction_Amount) as Total_Transaction_Amount from Transaction_Data;

-- What is the total amount involved in fraudulent transactions?

SELECT SUM(Transaction_Amount) as Fraudlent_Transaction_Amount FROM Transaction_Data WHERE Fraud_Flag=1;

-- What is the average transaction amount? 

SELECT round(AVG(Transaction_Amount),2) AS Average_Transaction_Amount FROM Transaction_Data;

-- What is the average transaction amount for fraudulent vs legitimate transactions?

SELECT Fraud_Flag ,round(AVG(Transaction_Amount),2) as Avg_Transaction_Amount
FROM Transaction_Data
GROUP BY Fraud_Flag;

-- 2. Time-Based Fraud Analysis

select * from Transaction_Data;

--  Daily analysis

-- How many total transactions and how many fraudulent transactions occurred on each date?

select count(Transaction_ID) as Total_Transaction,
	   sum(Fraud_Flag) as Fraudlent_Transaction ,
       Transaction_Date
       from Transaction_Data
       group by Transaction_Date
       order by sum(Fraud_Flag) desc;
       
-- Monthly fraud count       

-- Which month had the highest number of fraudulent transactions?

select Date_Format(Transaction_Date,"%Y-%M") AS MONTH,
	  SUM(Fraud_Flag) as Highest_Fraudlent_Transaction 
      from Transaction_Data 
	      group by Date_Format(Transaction_Date,"%Y-%M")
          ORDER BY Highest_Fraudlent_Transaction desc;
  
 -- Monthly fraud rate
  
-- Which month had the highest fraud rate (%)?

select Date_Format(Transaction_Date,"%Y-%M") AS MONTH, 
            round((sum(Fraud_Flag)/count(*))*100,2) as Fraud_Rate
            from Transaction_Data
            group by Date_Format(Transaction_Date,"%Y-%M")
            order by Fraud_Rate desc ;
            
-- Fraud by hour
		
-- At which hour of the day did the highest number of fraudulent transactions occur?

select HOUR(Transaction_Time) AS HOURS,
	  SUM(Fraud_Flag) as Fraudlent_Transaction 
      from Transaction_Data 
	      group by  HOUR(Transaction_Time)
          ORDER BY Fraudlent_Transaction desc LIMIT 1;
          
-- Hourly fraud rate

-- Which hour of the day had the highest fraud rate (%)?

select hour(Transaction_Time), 
            round((sum(Fraud_Flag)/count(*))*100,2) as Fraud_Rate
            from Transaction_Data
            group by hour(Transaction_Time)
            order by Fraud_Rate desc ;

-- Day vs night

-- Are fraudulent transactions more common during daytime or nighttime?

select Case when hour(Transaction_Time) between 6 and 17 then "Day"
                      else "Night"
		end as Time_period,
       sum(Fraud_Flag) as Fraudlent_Transaction
       from Transaction_Data
       group by Case when hour(Transaction_Time) between 6 and 17 then "Day"
                      else "Night"
				end ;

-- Average transaction amount by month

-- What was the average transaction amount for each month?

select  date_format(Transaction_Date,"%Y-%M") as Months,
       round(avg(Transaction_Amount),2) as Average_Amount
       from Transaction_Data
       group by date_format(Transaction_Date,"%Y-%M")
       order by Average_Amount desc;
       
-- Fraud trend over time

-- How did the fraud rate change over the transaction period?

select date_format(Transaction_Date,"%Y-%m") as Time_Period,
           count(Transaction_ID) AS Total_Transactions,
           round(sum(Fraud_Flag)/count(*) *100,2) as fraud_rate
           from Transaction_Data
           group by date_format(Transaction_Date,"%Y-%m")
           order by 1;







-- identifies the highest-risk month 
select date_format(Transaction_Date,"%Y-%m") as Time_Period,
           count(Transaction_ID) AS Total_Transactions,
           round(sum(Fraud_Flag)/count(*) *100,2) as fraud_rate
           from Transaction_Data
           group by date_format(Transaction_Date,"%Y-%m")
           order by fraud_rate desc;
           


 -- 3. Transaction Characteristics  
 
           select * from Transaction_Data;
           
-- 16.Payment Method

-- Which payment method has the highest fraud rate?
		
select Payment_Method,
       round((sum(Fraud_Flag)/count(*)) *100,2) as Fraud_Rate
       from Transaction_Data
       group by Payment_Method
       order by 2 desc limit 1;
       
  -- 17. Transaction Channel

-- Which transaction channel has the highest fraud rate?     

select Transaction_Channel,
       round((sum(Fraud_Flag)/count(*)) *100,2) as Fraud_Rate
       from Transaction_Data
       group by Transaction_Channel
       order by 2 desc limit 1;
       
-- 18. Device Type

-- Which device type has the highest fraud rate?

select Device_Type,
       round((sum(Fraud_Flag)/count(*)) *100,2) as Fraud_Rate
       from Transaction_Data
       group by Device_Type
       order by 2 desc limit 1;
       
-- 19. Transaction Status

-- Which transaction status has the highest number of fraudulent transactions?

select * from Transaction_Data;


SELECT Transaction_Status ,
       count(*) as Fraudulent_Transactions
       from Transaction_Data
       where Fraud_Flag=1
       group by Transaction_Status
       order by 2 desc limit 1;
       
-- 20. International vs Domestic

-- Are international transactions more likely to be fraudulent than domestic transactions?
   
   select Is_International,
          count(Transaction_ID) AS Total_Transactions,
		  sum(Fraud_Flag) as Fraudulant_Transactions,
          round((sum(Fraud_Flag)/count(*))*100,2) as Fraud_Rate
         from Transaction_Data 
         group by Is_International 
         order by 4 desc;
         
-- 21. Merchant Risk Level

-- Which merchant risk level has the highest fraud rate?
   
select Merchant_Risk_Level,
       round((sum(Fraud_Flag)/count(*))*100,2) as Fraud_Rate
         from Transaction_Data 
         group by Merchant_Risk_Level
         order by 2 desc limit 1;
         
-- 22. Merchant Category

-- Which merchant category has the highest fraud rate?
select * from Transaction_Data;

select Merchant_Category,
       round((sum(Fraud_Flag)/count(*))*100,2) as Fraud_Rate
         from Transaction_Data 
         group by Merchant_Category
         order by 2 desc limit 1;
         
-- 23. Fraudulent Transaction Value

-- Which merchant category has the highest total amount involved in fraudulent transactions?

select Merchant_Category,
       ROUND(sum(Transaction_Amount),2) AS Total_Amount,
       sum(Fraud_Flag) as Fraudulant_Transactions
       from Transaction_Data
       group by Merchant_Category
       order by 2 desc;
       
        -- or
	
select Merchant_Category,
       ROUND(sum(Transaction_Amount),2) AS Total_Amount
       from Transaction_Data
       WHERE Fraud_Flag =1
       group by Merchant_Category
       order by 2 desc;
       
       
       
       
       
-- 24. Transaction Amount vs Fraud

-- Are higher-value transactions more likely to be fraudulent?

select min(Transaction_Amount) from Transaction_Data;
select max(Transaction_Amount) from Transaction_Data;

select case when Transaction_Amount between 100 and 100000 then "too_lower-level"
            when Transaction_Amount between 100001 and 500000 then "lower-level"
            when Transaction_Amount between 500001 and 1000000 then "intermediate-level"
            when Transaction_Amount between 1000001 and 2000000 then "higher-level"
		end as Transaction_interval,
        count(Transaction_ID) AS Total_Transaction,
        sum(Fraud_Flag) as Fraudulant_Transactions,
        round((sum(Fraud_Flag)/count(*)) *100,2) as Fraud_Rate
        from Transaction_Data
        group by  case when Transaction_Amount between 100 and 100000 then "too_lower-level"
            when Transaction_Amount between 100001 and 500000 then "lower-level"
            when Transaction_Amount between 500001 and 1000000 then "intermediate-level"
            when Transaction_Amount between 1000001 and 2000000 then "higher-level"
		          end
		order by 4 desc;
                  
-- 25. Largest Fraudulent Transactions

-- What are the top 10 largest fraudulent transactions by transaction amount?

-- This one should return details such as:

-- Transaction ID
-- Customer ID
-- Transaction date
-- Transaction amount
-- Payment method
-- Merchant category
-- Fraud reason
       
       select Transaction_ID,
       Customer_ID,
       Transaction_Date,
       Transaction_Amount,
       Payment_Method,
       Merchant_Category,
       Fraud_Reason
       from Transaction_Data
       where Fraud_Flag =1
       order by 4 desc limit 10;
       
use fraud_analysis;

select * from Transaction_Data;

-- What are the different Fraud_Reason values associated with fraudulent transactions?       

select Distinct Fraud_Reason from Transaction_Data where Fraud_Flag=1;

-- How many fraudulent transactions are associated with each Fraud_Reason?

select Fraud_Reason,count(*) AS FRAUDULENT_TRANSACTION from Transaction_Data where Fraud_Flag=1 group by Fraud_Reason;

-- Which fraud reason occurs most frequently? 

SELECT Fraud_Reason,Count(Fraud_Reason) as Count from Transaction_Data where Fraud_Flag =1 group by Fraud_Reason order by 2 desc limit 1;

-- What is the total fraudulent transaction amount associated with each Fraud_Reason?

Select Fraud_Reason, Round(SUM(Transaction_Amount ),2) as Total_Fraudulent_Amount FROM Transaction_Data where Fraud_Flag=1 Group by Fraud_Reason;

-- Which fraud reason has the highest average transaction amount?

select Fraud_Reason,round(avg(Transaction_Amount),2) as Average_Fraudulent_Amount from Transaction_Data where Fraud_Flag=1 group by Fraud_Reason order by 2 desc limit 1;


-- Section 5 — Customer Analysis

select * from Transaction_Data;

Select * FROM  Customer_Data;

-- Which customer segment has the highest fraud rate ?

select CD.Customer_Segment, 
       Round((sum(Fraud_Flag) /count(Transaction_ID)) * 100,2) AS Fraud_Rate
       FROM Transaction_Data TD
       join Customer_Data CD
       ON TD.Customer_ID=CD.Customer_ID
       GROUP BY CD.Customer_Segment
       order by 2 desc limit 1;
       
-- Which State has the highest fraud rate?

select CD.State, 
       Round((sum(Fraud_Flag) /count(Transaction_ID)) * 100,2) AS Fraud_Rate
       FROM Transaction_Data TD
       join Customer_Data CD
       ON TD.Customer_ID=CD.Customer_ID
       GROUP BY CD.State
       order by 2 desc limit 1;
       
-- Which city has the highest number of fraudulent transactions?

select CD.City, 
       sum(Fraud_Flag) AS Fraudulent_Transactions
       FROM Transaction_Data TD
       join Customer_Data CD
       ON TD.Customer_ID=CD.Customer_ID
       GROUP BY CD.City
       order by 2 desc limit 1;
       
-- Which customer occupation has the highest fraud rate?      

select CD.Occupation, 
       Round((sum(Fraud_Flag) /count(Transaction_ID)) * 100,2) AS Fraud_Rate
       FROM Transaction_Data TD
       join Customer_Data CD
       ON TD.Customer_ID=CD.Customer_ID
       GROUP BY CD.Occupation
       order by 2 desc limit 1;
       
-- Does age group have any relationship with fraud?

select max(Age) from Customer_Data;
select min(Age) from Customer_Data;

select case when Age Between 18 and 29 then "Young-Adult"
				   when Age Between 30 and 59 then "Adult"
                   else "Senior"
			  end as Age_Group,
	   count(Transaction_ID) AS Total_Transaction,
       sum(Fraud_Flag) as Fraudulent_Transaction,
       Round((sum(Fraud_Flag) /count(Transaction_ID)) * 100,2) AS Fraud_Rate
       FROM Transaction_Data TD
       join Customer_Data CD
       ON TD.Customer_ID=CD.Customer_ID
       GROUP BY case when Age Between 18 and 29 then "Young-Adult"
				   when Age Between 30 and 59 then "Adult"
                   else "Senior"
				end ;
	   
-- Does annual income group have any relationship with fraud?

select * from Customer_Data;
select max(Annual_income) from Customer_Data;
select min(Annual_income) from Customer_Data;

select case when Annual_income < 50000 then "Low Income"
            when Annual_income Between 50000 and 199999 then "Lower-Middle Income"
			when Annual_income Between 200000 and 499999 then "Middle Income"
            when Annual_income Between 500000 and 999999 then "Upper-Middle Income"
            when Annual_income Between 1000000 and 4999999 then "High Income"
			when Annual_income >= 5000000 then "Very High Income"
			  end as Income_Group,
	   count(Transaction_ID) AS Total_Transaction,
       sum(Fraud_Flag) as Fraudulent_Transaction,
       Round((sum(Fraud_Flag) /count(Transaction_ID)) * 100,2) AS Fraud_Rate
       FROM Transaction_Data TD
       join Customer_Data CD
       ON TD.Customer_ID=CD.Customer_ID
       GROUP BY case when Annual_income < 50000 then "Low Income"
            when Annual_income Between 50000 and 199999 then "Lower-Middle Income"
			when Annual_income Between 200000 and 499999 then "Middle Income"
            when Annual_income Between 500000 and 999999 then "Upper-Middle Income"
            when Annual_income Between 1000000 and 4999999 then "High Income"
			when Annual_income >= 5000000 then "Very High Income"
			  end ;
			
-- Which Account_Type has the highest fraud rate?

select CD.Account_Type, 
       Round((sum(Fraud_Flag) /count(Transaction_ID)) * 100,2) AS Fraud_Rate
       FROM Transaction_Data TD
       join Customer_Data CD
       ON TD.Customer_ID=CD.Customer_ID
       GROUP BY CD.Account_Type
       order by 2 desc limit 1;
       
-- Which marital-status group has the highest fraud rate?

select CD.Marital_Status, 
       Round((sum(Fraud_Flag) /count(Transaction_ID)) * 100,2) AS Fraud_Rate
       FROM Transaction_Data TD
       join Customer_Data CD
       ON TD.Customer_ID=CD.Customer_ID
       GROUP BY CD.Marital_Status
       order by 2 desc limit 1;
       
-- Which customers have the highest total transaction value?

select CD.Customer_ID, 
       SUM(Transaction_Amount) AS Transaction_Amount
       FROM Transaction_Data TD
       join Customer_Data CD
       ON TD.Customer_ID=CD.Customer_ID
       GROUP BY CD.Customer_ID
       order by 2 desc limit 1;

-- Which customers have the highest number of fraudulent transactions?

select CD.Customer_ID,
       sum(Fraud_Flag) as Fraudulent_Transaction
       from Transaction_Data TD
       join Customer_Data CD
       ON TD.Customer_ID = CD.Customer_ID
       group by CD.Customer_ID
       ORDER BY 2 DESC
       LIMIT 1;
-- Who are the top 10 customers by fraudulent transaction amount?

select CD.Customer_ID,
       sum(Transaction_Amount) as Transaction_Amount
       from Transaction_Data TD
       join Customer_Data CD
       ON TD.Customer_ID = CD.Customer_ID
       where Fraud_Flag=1
       group by CD.Customer_ID
       ORDER BY 2 DESC
       LIMIT 10;
       
-- Card Analysis
select * from Transaction_Data;
select * from Cards_Data;

-- Which Card_Type has the highest fraud rate?

select CAD.Card_Type,
       round(sum(TD.Fraud_Flag)/count(TD.Transaction_ID) *100,2) AS Fraud_Rate
       From Transaction_Data TD
       JOIN Cards_Data CAD
       ON CAD.Card_ID=TD.Card_ID
       Group by CAD.Card_Type
       ORDER BY 2 desc
       limit 1;
       
-- Which card type has the highest fraudulent transaction amount?

select CAD.Card_Type,
       SUM(TD.Transaction_Amount) AS Fraudulent_Transaction
       From Transaction_Data TD
       JOIN Cards_Data CAD
       ON CAD.Card_ID=TD.Card_ID
       where TD.Fraud_Flag=1
       Group by CAD.Card_Type
       ORDER BY 2 desc
       limit 1;
       
-- Does credit limit appear to be associated with fraud?

SELECT max(Credit_Limit) from Cards_Data;
SELECT min(Credit_Limit) from Cards_Data;

select case when CAD.Credit_Limit between 50000 and 349999 then "Low"
            when CAD.Credit_Limit between 350000 and 649999 then "Lower-Mid"
            when CAD.Credit_Limit between 650000 and 949999 then "Mid"
            when CAD.Credit_Limit between 950000 and 1249999 then "Upper-Mid"
            when CAD.Credit_Limit between 1250000 and 1499999 then "High"
		end as limit_group,
        count(TD.Transaction_ID) AS Total_Transactions,
        sum(TD.Fraud_Flag) as Fraudulent_Transactions,
        round(sum(TD.Fraud_Flag)/count(*)*100,2) as Fraud_Rate
        FROM Transaction_Data TD
        JOIN Cards_Data CAD
        ON CAD.Card_ID=TD.Card_ID
        GROUP BY case when CAD.Credit_Limit between 50000 and 349999 then "Low"
            when CAD.Credit_Limit between 350000 and 649999 then "Lower-Mid"
            when CAD.Credit_Limit between 650000 and 949999 then "Mid"
            when CAD.Credit_Limit between 950000 and 1249999 then "Upper-Mid"
            when CAD.Credit_Limit between 1250000 and 1499999 then "High"
		end ;
        
-- Which cards have the highest number of fraudulent transactions?
select * from Transaction_Data;
select * from Cards_Data;
SELECT CAD.*,
      SUM(TD.Fraud_Flag) AS Fraudulent_Transaction
      from Transaction_Data TD
      join Cards_Data CAD
      ON CAD.Card_ID=TD.Card_ID
      group by CAD.Card_ID
      ORDER BY Fraudulent_Transaction desc limit 1;
      
-- Which cards have the highest total transaction amount?

SELECT CAD.*,
      SUM(TD.Transaction_Amount) AS Transaction_Amount
      from Transaction_Data TD
      join Cards_Data CAD
      ON CAD.Card_ID=TD.Card_ID
      group by CAD.Card_ID
      ORDER BY Transaction_Amount desc limit 1;
      
-- Are international transactions more common for certain card types?

select CAD.Card_Type,
           sum(TD.Is_International) AS International_Transaction,
           (count(*)- sum(TD.Is_International)) as Domestic_Transactions,
           COUNT(*) as Total_Transactions,
           round(sum(Is_International)/count(*) *100,2) as International_Transaction_Rate
           from Transaction_Data TD
           JOIN Cards_Data CAD
           ON CAD.Card_ID=TD.Card_ID
           group by CAD.Card_Type;
           
-- Merchant Analysis

-- Which merchant has the highest number of fraudulent transactions?

select * from Merchant_Data;

select MD.* ,
       sum(TD.Fraud_Flag) as Fraudulent_Transaction
       from Transaction_Data TD
       JOIN Merchant_Data MD
       ON MD.Merchant_ID=TD.Merchant_ID
       Group by MD.Merchant_ID
       ORDER BY Fraudulent_Transaction DESC LIMIT 1;
       
-- Which merchant has the highest fraudulent transaction amount?

select MD.* ,
       sum(TD.Transaction_Amount) as Fraudulent_Transaction
       from Transaction_Data TD
       JOIN Merchant_Data MD
       ON MD.Merchant_ID=TD.Merchant_ID
       where Fraud_Flag=1
       Group by MD.Merchant_ID
       ORDER BY Fraudulent_Transaction DESC LIMIT 1;
       
-- Does merchant rating have any relationship with fraud?
 
 select MD.Merchant_Rating,
        COUNT(Transaction_ID) AS Total_Transaction,
        sum(Fraud_Flag) AS Fraudulent_Transaction,
        round(sum(Fraud_Flag)/count(*)*100,2) as Fraud_Rate
        from Transaction_Data TD
        JOIN Merchant_Data MD
        ON MD.Merchant_ID=TD.Merchant_ID
        GROUP BY MD.Merchant_Rating
        order by 4 desc;

-- Which merchant states have the highest fraud rate?

select MD.State ,
       round(sum(TD.Fraud_Flag)/count(*)*100,2) as Fraud_Rate
        from Transaction_Data TD
        JOIN Merchant_Data MD
        ON MD.Merchant_ID=TD.Merchant_ID
        GROUP BY MD.State
        order by 2 desc limit 1;   
        
-- Which merchant cities have the highest fraud rate?

select MD.City ,
       round(sum(TD.Fraud_Flag)/count(*)*100,2) as Fraud_Rate
        from Transaction_Data TD
        JOIN Merchant_Data MD
        ON MD.Merchant_ID=TD.Merchant_ID
        GROUP BY MD.City
        order by 2 desc limit 1;  



-- Which merchants have a high transaction volume AND a high fraud rate? (CTE -Calculate the AVG OR Subquery)

WITH Merchant_Analysis as(
	  select MD.Merchant_ID ,
       COUNT(TD.Transaction_ID) as Total_Transaction,
       sum(Fraud_Flag) as Fraudulent_Transaction,
       round(sum(TD.Fraud_Flag)/count(*) *100,2) as Fraud_Rate
       from Transaction_Data TD
       join Merchant_Data MD
       ON MD.Merchant_ID=TD.Merchant_ID
       group by Merchant_ID) ,
Merchant_Average as
( select avg(Total_Transaction) as AVG_Total_Transaction,
              avg(Fraud_Rate) as AVG_Fraud_Rate 
              from Merchant_Analysis)
select MA.* FROM Merchant_Analysis MA
         cross join Merchant_Average AV
         where MA.Total_Transaction > AV.AVG_Total_Transaction
              and MA.Fraud_Rate > AV.AVG_Fraud_Rate
               order by MA.Fraud_Rate desc,
                        MA.Total_Transaction desc;
                        
                        
-- Which Customer Segment + Merchant Category combination has the highest fraud rate?
        
select * from merchant_Data;
select * from Customer_data;
select * from Cards_data;
select * from Transaction_data;

select CD.Customer_Segment ,
       MD.Merchant_Category,
       count(Transaction_ID) AS Total_Transactions,
       sum(Fraud_Flag) as Fraudulent_Transactions,
       round(sum(Fraud_Flag)/count(*) * 100,2) as Fraud_Rate
       from Transaction_Data TD
       JOIN Customer_Data CD
       on CD.Customer_ID=TD.Customer_ID
       JOIN Merchant_Data MD
       ON MD.Merchant_ID=TD.Merchant_ID
       group by CD.Customer_Segment,MD.Merchant_Category
       order by 5 desc limit 1;
       
-- Which Customer_State + Merchant_State combinations have the highest fraud rate?
       
       select CD.State,
       MD.State,
       count(Transaction_ID) AS Total_Transactions,
       sum(Fraud_Flag) as Fraudulent_Transactions,
       round(sum(Fraud_Flag)/count(*) * 100,2) as Fraud_Rate
       from Transaction_Data TD
       JOIN Customer_Data CD
       on CD.Customer_ID=TD.Customer_ID
       JOIN Merchant_Data MD
       ON MD.Merchant_ID=TD.Merchant_ID
       group by CD.State,MD.State
       order by 5 desc limit 1;

-- Are transactions where the customer state and merchant state differ more likely to be fraudulent than transactions where they are in the same state?

   select case when CD.State=MD.State then "Transaction of Customer and Merchant are in same state"
				when CD.State <> MD.State then "Transaction of Customer and Merchant are in different state"
		  end as  State_Group,
          count(Transaction_ID) AS TOTAL_TRANSACTIONS,
          SUM(Fraud_Flag) as FRAUDULENT_TRANSACTIONS,
          ROUND(SUM(Fraud_Flag)/COUNT(*) *100,2) AS FRAUD_RATE
          FROM Transaction_Data TD
          join Customer_Data CD
          ON CD.Customer_ID=TD.Customer_ID
          JOIN Merchant_Data MD
          ON MD.Merchant_ID=TD.Merchant_ID
          Group by  case when CD.State=MD.State then "Transaction of Customer and Merchant are in same state"
				when CD.State <> MD.State then "Transaction of Customer and Merchant are in different state"
		  end ;
          
-- Which payment method is most commonly used for fraudulent transactions at high-risk merchants?

select * from merchant_Data;
select * from Customer_data;
select * from Cards_data;
select * from Transaction_data;


select TD.Payment_Method,
       MD.Merchant_Risk_Level,
       SUM(Fraud_Flag) as FRAUDULENT_TRANSACTIONS
       from Transaction_Data TD
       JOIN Merchant_Data MD
       ON TD.Merchant_ID=MD.Merchant_ID
       WHERE MD.Merchant_Risk_Level="High"
       group by TD.Payment_Method,MD.Merchant_Risk_Level
       order by 3 desc limit 1;

-- Are international + high-risk merchant transactions particularly associated with fraud?

select TD.Is_International,
       MD.Merchant_Risk_Level,
       count(Transaction_ID) AS TOTAL_TRANSACTIONS,
	   SUM(Fraud_Flag) as FRAUDULENT_TRANSACTIONS,
	   ROUND(SUM(Fraud_Flag)/COUNT(*) *100,2) AS FRAUD_RATE
       from Transaction_Data TD
       JOIN Merchant_Data MD
       ON TD.Merchant_ID=MD.Merchant_ID
       WHERE MD.Merchant_Risk_Level="High"
       group by TD.Is_International,MD.Merchant_Risk_Level;
       
-- Which combination of Device_Type + Payment_Method has the highest fraud rate?

select Device_Type,
       Payment_Method,
       round(sum(Fraud_Flag)/count(*) * 100,2) as FRAUD_RATE
       from Transaction_Data
       group by Device_Type,Payment_Method
       order by 3 desc limit 1;
       
-- Which combination of Transaction_Channel + Merchant_Risk_Level has the highest fraud rate?
 
 select TD.Transaction_Channel,
        MD.Merchant_Risk_Level,
        round(sum(Fraud_Flag)/count(*) * 100,2) as FRAUD_RATE
        from Transaction_Data TD
        JOIN Merchant_Data MD
        ON MD.Merchant_ID=TD.Merchant_ID
        GROUP BY TD.Transaction_Channel,MD.Merchant_Risk_Level
        ORDER BY 3 DESC LIMIT 1;
        
SELECT COUNT(*) AS Total_Transactions,
SUM(Fraud_Flag) AS Fraudulent_Transactions FROM Transaction_Data;


-- advanced sql
-- Top 10 customers by fraudulent transaction amount

select CD.Customer_ID,
       sum(TD.Transaction_Amount) as Total_Fraudulent_Amount
       from Transaction_Data TD
       Join Customer_Data CD
       ON CD.Customer_ID=TD.Customer_ID
       where TD.Fraud_Flag=1
       GROUP BY CD.Customer_ID
       ORDER BY Total_Fraudulent_Amount DESC LIMIT 10;
       
-- Rank merchant categories by their fraud rate.
with merchant_category as
(
SELECT MD.Merchant_Category,
	round(sum(TD.Fraud_Flag)/count(*) * 100,2) as Fraud_Rate
    from Transaction_Data TD
    JOIN Merchant_Data MD
    on MD.Merchant_ID=TD.Merchant_ID
    group by MD.Merchant_Category)
    
 select Merchant_Category,
      Fraud_Rate,
      rank() over(order by Fraud_Rate desc) as Ranks
 FROM merchant_category
 order by Ranks;
 
 -- For each customer, calculate their total transactions, fraudulent transactions, and fraud rate, then rank customers by fraud rate.

WITH CUSTOMER_ANALYSIS AS 
(Select CD.Customer_ID,
	   COUNT(TD.Transaction_ID) AS TOTAL_TRANSACTIONS,
       SUM(TD.Fraud_Flag) AS FRAUDULENT_TRANSACTIONS,
       ROUND(SUM(Fraud_Flag)/count(*) * 100,2) as FRAUD_RATE
       FROM Transaction_Data TD
       JOIN Customer_Data CD
       ON CD.Customer_ID=TD.Customer_ID
       Group by CD.Customer_ID)
SELECT Customer_ID,TOTAL_TRANSACTIONS,FRAUDULENT_TRANSACTIONS,FRAUD_RATE,
       RANK() OVER(ORDER BY FRAUD_RATE DESC) AS RANKS
       FROM CUSTOMER_ANALYSIS
       ORDER BY RANKS;
       
	
       
-- What percentage of the total fraudulent amount comes from the top 10 customers?

with TOP_CUSTOMERS as
(
select CD.Customer_ID,
       sum(TD.Transaction_Amount) as fraudulent_amount
       from Transaction_Data TD
       JOIN Customer_Data CD
       ON CD.Customer_ID=TD.Customer_ID
       where TD.Fraud_Flag=1
       GROUP BY CD.Customer_ID
       ORDER BY 2 DESC LIMIT 10
),
TOP_10 AS
( SELECT sum(fraudulent_amount) as Top_Fraudulent_Amount
        from TOP_CUSTOMERS),
        
OVERALL AS
( SELECT sum(Transaction_Amount) as Total_Fraudulent_Amount from Transaction_Data where Fraud_Flag=1)
         
select round(tp.Top_Fraudulent_Amount/ov.Total_Fraudulent_Amount* 100,2) as fraudulent_percentage
        from  TOP_10 tp
        cross join OVERALL OV;
        
-- Find transactions whose amount is above the overall average transaction amount. How many of these are fraudulent?

WITH TRANSACTION_ANALYSIS AS
(
SELECT Transaction_ID,
	   Transaction_Amount,
       Fraud_Flag
       from Transaction_Data),
AVERAGE_ANALYSIS AS
(SELECT AVG( Transaction_Amount) AS AVERAGE_OF_AMOUNT FROM TRANSACTION_ANALYSIS)

select  COUNT(*) AS Fraudulent_Transactions_Above_Average
from TRANSACTION_ANALYSIS TA CROSS JOIN AVERAGE_ANALYSIS AA
 WHERE TA.Transaction_Amount >  AA.AVERAGE_OF_AMOUNT and TA.Fraud_Flag =1;

-- Identify customers whose fraud rate is higher than the overall customer-level average fraud rate.

with customer_analysis as(
select Customer_ID,
      ROUND(SUM(Fraud_Flag)/count(*) * 100,2) as Fraud_Rate
      from Transaction_Data TD
      group by Customer_ID),
      
average as(
select avg(Fraud_Rate) as avg_fraud_rate from customer_analysis)

select CA.Customer_ID,Fraud_Rate FROM customer_analysis CA CROSS JOIN average AV WHERE CA.Fraud_Rate >AV.avg_fraud_rate
ORDER BY Fraud_Rate DESC;
      
      
-- Identify merchants that have both high transaction volume and above-average fraud rate.
      
WITH MERCHANT_ANALYSIS AS
(SELECT Merchant_ID,
             COUNT(Transaction_ID) AS TOTAL_TRANSACTIONS,
             ROUND(SUM(Fraud_Flag)/count(*) * 100,2) as FRAUD_RATE
             FROM TRANSACTION_DATA 
             GROUP BY Merchant_ID),
             
TRANSACTION_VOLUME AS
(SELECT AVG(TOTAL_TRANSACTIONS) AS AVG_NBR_TRANSACTIONS FROM MERCHANT_ANALYSIS),

FRAUD_RATE_ANALYSIS AS
(SELECT AVG(FRAUD_RATE) AS AVG_FRAUD_RATE FROM MERCHANT_ANALYSIS)

SELECT MA.Merchant_ID, MA.TOTAL_TRANSACTIONS,MA.FRAUD_RATE 
      FROM MERCHANT_ANALYSIS MA
      CROSS JOIN TRANSACTION_VOLUME	TV	
      CROSS JOIN  FRAUD_RATE_ANALYSIS FRA
      WHERE MA.TOTAL_TRANSACTIONS > TV.AVG_NBR_TRANSACTIONS AND MA.FRAUD_RATE > FRA.AVG_FRAUD_RATE
      ORDER BY MA.FRAUD_RATE DESC;
	
-- Find the highest-value fraudulent transaction for each merchant category.

select MD.Merchant_Category,
       max(TD.Transaction_Amount) as Fraudulent_Transaction
       from Transaction_Data TD
       JOIN Merchant_Data MD
       ON MD.Merchant_ID=TD.Merchant_ID
       where Fraud_Flag=1
       GROUP BY MD.Merchant_Category;
       
-- Find the first fraudulent transaction for each customer.

select CD.Customer_ID, MIN(TD.Transaction_Date) as Fraudulent_Transaction
       from Transaction_Data TD
       JOIN Customer_Data CD
       ON CD.Customer_ID=TD.Customer_ID
       where Fraud_Flag=1
       GROUP BY CD.Customer_ID;
       
-- Find customers who experienced multiple fraudulent transactions.

select Customer_ID ,
       count(*) as Fraudulent_Transactions
       from Transaction_Data
       where Fraud_Flag=1 
       group by Customer_ID
       HAVING COUNT(*) >1
       ORDER BY 2 DESC;
       
-- Find customers who had a legitimate transaction followed by a fraudulent transaction.

SELECT Distinct TD1.Customer_ID
	   FROM Transaction_Data TD1
       JOIN Transaction_Data TD2
       ON TD1.Customer_ID=TD2.Customer_ID
       WHERE TD1.Fraud_Flag=0
       and TD2.Fraud_Flag=1
      AND TIMESTAMP(TD2.Transaction_Date, TD2.Transaction_Time)
      > TIMESTAMP(TD1.Transaction_Date, TD1.Transaction_Time);
      
-- Calculate the monthly fraud rate and compare each month with the previous month
   
with MONTH_ANALYSIS AS
(
select Date_format(Transaction_Date,"%Y-%m") AS MONTHS,
    count(Transaction_ID) Total_Transactions,
    sum(Fraud_Flag) as Fraudulent_Transactions,
     ROUND(SUM(Fraud_Flag)/count(*)* 100,2) as Fraud_Rate
    from Transaction_Data
    GROUP BY Date_format(Transaction_Date,"%Y-%m")
    )
SELECT MONTHS,
		Total_Transactions,
		Fraudulent_Transactions,
		Fraud_Rate,
        LAG(Fraud_Rate) over(order by MONTHS) as previous_fraud_rate,
		Fraud_Rate -LAG(Fraud_Rate) over(order by MONTHS) as DIFFERENCE 
          FROM MONTH_ANALYSIS ;
          
-- Find the month with the largest increase in fraud rate compared with the previous month.

with MONTH_ANALYSIS AS
(
select Date_format(Transaction_Date,"%Y-%m") AS MONTHS,
    count(Transaction_ID) Total_Transactions,
    sum(Fraud_Flag) as Fraudulent_Transactions,
     ROUND(SUM(Fraud_Flag)/count(*)* 100,2) as Fraud_Rate
    from Transaction_Data
    GROUP BY Date_format(Transaction_Date,"%Y-%m")
    )
SELECT MONTHS,
		Total_Transactions,
		Fraudulent_Transactions,
		Fraud_Rate,
        LAG(Fraud_Rate) over(order by MONTHS) as previous_fraud_rate,
		Fraud_Rate -LAG(Fraud_Rate) over(order by MONTHS) as DIFFERENCE 
          FROM MONTH_ANALYSIS 
          ORDER BY DIFFERENCE DESC LIMIT 1;
          
          use fraud_analysis;
          
    
	   
       
       