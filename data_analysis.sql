#tenure- how many year he/she have	bank account in abc bank
#products_number-number of the product from bank
#credit_card- is this customer have credit card.
#acitve_number- is he/she is active member

create database bank;
use bank;
select * from bank_churn;
select count(*) as no_records from bank_churn;
describe bank_churn;
select distinct count(customer_id) as unique_id from bank_churn;
select count(country) from bank_churn where not null;



# there is no missing values
#there is no deplicate record.
#to check the presence of the outliers
select "credit_score" as column_name ,avg(credit_score) as avarage,
max(credit_score) as maximum, min(credit_score) as minimum from bank_churn
union
select "age" as column_name,avg(age) as avarage,max(age) as maximum, 
min(age) as minimum from bank_churn
union
select "tenure" as column_name,avg(tenure) as avarage,
max(tenure) as maximum, min(tenure) as minimum from bank_churn
union
select "products_numbers" as column_name,avg(products_number) as avarage,
max(products_number) as maximum, min(products_number) as minimum from bank_churn
union
select "credit_card" as column_name, avg(credit_card) as avarage,
max(credit_card) as maximum, min(credit_card) as minimum from bank_churn
union
select "active_member" as column_name, avg(active_member) as avarage,
max(active_member) as maximum, min(active_member) as minimum from bank_churn;

select distinct country from bank_churn;
select distinct gender from bank_churn;
select distinct tenure from bank_churn order by tenure;
select distinct products_number from bank_churn;
select distinct credit_card from bank_churn;
select distinct active_member from bank_churn;



#Firstly convert the numeric into catagorical
#convert the field churn from 1,0 to yes and no
# here we observed that churn has int data types so im converting into varchar
alter table bank_churn modify churn varchar(5);
update bank_churn set churn=
case when churn=1 then "yes"
else "no"
end;

alter table bank_churn  modify column credit_card varchar(5);
update bank_churn set credit_card =
case when credit_card=1 then "yes"
else "no"
end;

alter table bank_churn modify column active_member varchar(5);
update bank_churn set active_member=
case when active_member=1 then "yes"
else "no"
end;

ALTER table bank_churn modify COLUMN credit_score varchar(10) ;

UPDATE bank_churn SET credit_score=
CASE WHEN credit_score BETWEEN 350 AND 579
THEN 'poor'
WHEN credit_score BETWEEN 580 AND 669
THEN 'fair'
WHEN credit_score BETWEEN 670 AND 739
THEN 'good'
WHEN credit_score BETWEEN 740 AND 799
THEN 'Very good'
ELSE
'excellent'
END;

ALTER TABLE bank_churn MODIFY age VARCHAR(20);

UPDATE bank_churn SET age=
CASE
WHEN age BETWEEN 18 AND 35 
THEN 'teenager'
WHEN age BETWEEN 36 AND 50
THEN 'adults'
WHEN age BETWEEN 51 AND 65
THEN 'senior citizen'
ELSE
'old senior citizen'
END;
# renameing the class of some column is done to easily understand the class.

#firstly we look into the churn rate

SELECT 
	churn,no_customer,ROUND((no_customer/total)*100,2)
    "churn_rate in (%)" 
FROM 
	(SELECT churn,COUNT(churn) AS no_customer FROM 
	bank_churn GROUP BY churn) AS total,
	(SELECT COUNT(churn) AS total FROM bank_churn) AS churned;
    
#20.37% of the churn are churned  and 79.63% of customer are not churned


#In which country has highest churn rate 
SELECT country,COUNT(customer_id) AS total FROM bank_churn  GROUP BY country;
#france-5014
#spain-2477
#germany-2509

SELECT 
    total.country,total "number of customer",no_cust 'number_customer(churned)',
    ROUND((no_cust / total) * 100, 2) AS churn_rate
FROM
    (SELECT country, COUNT(customer_id) AS no_cust
    FROM bank_churn
    WHERE churn = 'yes'
    GROUP BY country) AS churned_customer 
LEFT JOIN    
    (SELECT country,COUNT(customer_id) AS total
    FROM bank_churn
    GROUP BY country) AS total
ON churned_customer.country=total.country;

# look at here number of the customer in germany is lowest but there is an chance of highest number of customer leave.
#the germany has highest churn rate compared to other two country

#before
#overall male or female churn rate

SELECT 
    total.gender, number_churned_customer, 
    (number_churned_customer / total) * 100 AS churn_rate
FROM
    (SELECT gender, COUNT(customer_id) AS number_churned_customer
    FROM bank_churn WHERE churn="yes" GROUP BY gender) AS gender_details
INNER join
    (SELECT gender, COUNT(customer_id) AS total
    FROM bank_churn GROUP BY gender) AS total
ON gender_details.gender=total.gender;



#Let us mainly focus of country germany. Now how many no of customer male or female.

WITH churned_customer AS
	(SELECT gender, COUNT(customer_id)  as churned_cust FROM
	bank_churn where country="Germany" and churn="yes"
	GROUP BY gender),
number_customer AS
	(SELECT gender, COUNT(customer_id) as no_cust FROM
    bank_churn WHERE country="Germany"
    GROUP BY gender)
SELECT 
	cc.gender, churned_cust, (churned_cust/no_cust)*100 "churn rate(%)"
	FROM churned_customer as cc
LEFT JOIN
	number_customer as nc ON cc.gender=nc.gender;

#here we clearly observed that highest percentage of risk of leaving
# abc bank is female customer than male customer.

#age
SELECT age,COUNT(age) AS "number customer" FROM bank_churn GROUP BY age ORDER BY COUNT(age);

SELECT 
	churned_customer.age,total_churn.total "number of customer",churned_customer, 
    ROUND((churned_customer/total)*100 ,2) "churn_rate in (%)"
FROM 
	(SELECT age, COUNT(customer_id) as total FROM bank_churn  
	GROUP BY age) as total_churn
LEFT JOIN
	(SELECT age, COUNT(age) AS churned_customer From bank_churn
	WHERE churn="yes" GROUP BY age) as churned_customer
ON 
    total_churn.age=churned_customer.age;


# the age range between 51 and 65 having the highest percentage of risk of leaving the bank.

/*SELECT 
	churned_customer.age,total_churn.total "number of customer",churned_customer, 
    ROUND((churned_customer/total)*100 ,2) "churn_rate in (%)"
FROM 
	(SELECT age, COUNT(customer_id) as total FROM bank_churn  
	WHERE country="Germany" GROUP BY age) as total_churn
LEFT JOIN
	(SELECT age, COUNT(age) AS churned_customer From bank_churn
	WHERE churn="yes" and country="Germany" GROUP BY age) as churned_customer
ON 
    total_churn.age=churned_customer.age; */

#Based on credit 
#to know the number of person havinng credit card

SELECT credit_card, COUNT(credit_card) FROM bank_churn GROUP BY credit_card;

WITH total AS
	(SELECT credit_card, count(customer_id) AS total FROM
	bank_churn GROUP BY credit_card),
	churned_customer AS 
	(SELECT credit_card,count(customer_id) AS no_churned_customers FROM 
	bank_churn WHERE churn="yes" GROUP BY credit_card)
SELECT 
	tt.credit_card,tt.total"number of customer",
    cc.no_churned_customers " number of churned customer",
	(cc.no_churned_customers/tt.total)*100 "churn_rate(%)"FROM total AS tt
LEFT JOIN
	churned_customer AS cc ON tt.credit_card=cc.credit_card;


# here we observed that percentage of the churn rate almost same.
# here we need to focus on both the churned customer who are having the same.

SELECT active_member, COUNT(active_member) FROM bank_churn GROUP BY active_member;

WITH total AS
	(SELECT active_member, count(customer_id) AS total FROM
	bank_churn GROUP BY active_member),
	churned_customer AS 
	(SELECT active_member,count(customer_id) AS no_churned_customers FROM 
	bank_churn WHERE churn="yes" GROUP BY active_member)
SELECT 
	tt.active_member,cc.no_churned_customers "numberof churned customer",
	(cc.no_churned_customers/tt.total)*100 "churn_rate(%)"FROM total AS tt
LEFT JOIN
	churned_customer AS cc ON tt.active_member=cc.active_member;

  
  
# Now lets us we know percentage of the  active member in each country.

WITH country_total AS
	(SELECT country, COUNT(customer_id) AS total FROM
    bank_churn WHERE active_member="no"  GROUP BY country),
churned_cust AS
	(SELECT country, COUNT(customer_id) AS churned_cust FROM 
    bank_churn WHERE active_member="no" and churn="yes" GROUP BY
    country)
SELECT 
	tt.country,cc.churned_cust,(cc.churned_cust/tt.total)*100
    "churn rate (%)" from country_total as tt
LEFT JOIN 
	churned_cust as cc ON tt.country=cc.country;


# by looking at the table in germeny only less active members compaered to other country.

#In which age group customer is less active.

WITH country_total AS
	(SELECT age, COUNT(customer_id)  AS total FROM
    bank_churn GROUP BY age),
churned_cust AS
	(SELECT age, COUNT(customer_id) AS churned_cust FROM 
    bank_churn WHERE active_member="yes" GROUP BY
    age)
SELECT 
	tt.age,tt.total "number of person",cc.churned_cust,(cc.churned_cust/tt.total)*100
    "percentage of active members" from country_total as tt
LEFT JOIN 
	churned_cust as cc ON tt.age=cc.age;

# we know that senior citizen customer having a high chances of leaving the abc bank
# but `here we can see that old senior citizen is less active. 

#3 tenure rate
SELECT  DISTINCT tenure FROM bank_churn ORDER BY tenure;

WITH TotalCustomers AS (
    SELECT tenure, count(tenure) AS no_customer
    FROM bank_churn GROUP BY tenure
),
ChurnedCustomers AS (
    SELECT tenure, COUNT(tenure) AS no_churned_customer
    FROM bank_churn WHERE churn = "yes"
    GROUP BY tenure
)
SELECT TC.tenure, TC.no_customer, CC.no_churned_customer,
 (CC.no_churned_customer / TC.no_customer) * 100 AS churn_rate
FROM TotalCustomers TC
LEFT JOIN ChurnedCustomers CC ON TC.tenure = CC.tenure order by tenure;  

# almost same.

# 6 credit_score
SELECT credit_score,count(credit_score) FROM bank_churn GROUP BY credit_score 
ORDER BY count(credit_score);

SELECT 
	total_churn.credit_score,churned_customer, 
    ROUND((churned_customer/total)*100 ,2) "churn_rate in (%)"
FROM 
	(SELECT credit_score, COUNT(customer_id) as total FROM bank_churn  
	GROUP BY credit_score) as total_churn
LEFT JOIN
	(SELECT credit_score, COUNT(customer_id) AS churned_customer From bank_churn
	WHERE churn="yes" GROUP BY credit_score) as churned_customer
ON total_churn.credit_score=churned_customer.credit_score;

#almost same.
#HERE WE DONT NEED TO SPECILLY FOCUS ON PERTICULAR CREDIT SCORE.


#products numbers
SELECT products_number, COUNT(products_number) FROM bank_churn GROUP BY products_number;

SELECT 
	total_churn.products_number,total"number of customer",churned_customer, 
    ROUND((churned_customer/total)*100 ,2) "churn_rate in (%)"
FROM 
	(SELECT products_number, COUNT(customer_id) as total FROM bank_churn  
	GROUP BY products_number) as total_churn
LEFT JOIN
	(SELECT products_number, COUNT(customer_id) AS churned_customer From bank_churn
	 WHERE churn="yes" GROUP BY products_number) as churned_customer
ON 
	total_churn.products_number=churned_customer.products_number;

#what do mean by product number in bank



#balance
#estimated salary
