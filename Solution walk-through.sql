## **SQL Game from [Knight Lab] (https://mystery.knightlab.com/)** ##
***Warning: Game Spoilers Ahead**

# *First, study the schema*
-Pay special attention to where the data of one column leaves one table (blue arrow) to join another table (gold key) to keep track of how the tables are joined.

(add Schema here)

# *Since it's a murder, open the crime_scene_report*

SELECT *
FROM crime_scene_report

# *Notice the city locations. One of them is 'SQL City'. That's probably the spot for a SQL murder.*
# Search by type 'murder' so you don't find other crimes

SELECT *
FROM crime_scene_report
WHERE type = 'murder'
AND city = 'SQL City';

# Out of the three records in the data output, one of the interview descriptions looks the most promising

date: 20180115, 
type: murder, 
description: Security footage shows that there were 2 witnesses. The first witness lives at the last house on "Northwestern Dr". The second witness, named Annabel, lives somewhere on "Franklin Ave". 
City: SQL City

# Using the addresses of each witness, we can search for their names and ids.
  NOTE: Because this game is using SQL lite, we can't search with almost-matches, for instance, ILIKE 

# First Witness Information: Last house on Northwestern Dr.
There are a lot of houses on that street name so we search by the last address number.

SELECT *
FROM person
WHERE address_street_name = 'Northwestern Dr'
ORDER BY address_number DESC
LIMIT 1;

Output:  
id	name	license_id	address_number	address_street_name	ssn
14887	Morty Schapiro	118009	4919	Northwestern Dr	111564949

# Second Witness Information: On Franklin Ave and her name is Annabel

SELECT *
FROM person
WHERE address_street_name = 'Franklin Ave'
AND name LIKE '%Annabel%';

Output:
id	name	license_id	address_number	address_street_name	ssn
16371	Annabel Miller	490173	103	Franklin Ave	318771143

# Now we can look up the interviews for these two witnessess

SELECT *
FROM interview
WHERE person_id = 16371 OR person_id = 14887

**Output: 
Note: I added their names to the person_id in the interview table so we can remember who is giving information

person_id	--transcript
Morty -- 14887 --	I heard a gunshot and then saw a man run out. He had a "Get Fit Now Gym" bag. The membership number on the bag started with "48Z". Only gold members have those bags. The man got into a car with a plate that included "H42W".

Annabel -- 16371 --	I saw the murder happen, and I recognized the killer from my gym when I was working out last week on January the 9th.

# This information leads to more questions:
-What people were working out on at the gym January 9th at the same time as Annabel?

SELECT *
FROM get_fit_now_check_in
WHERE check_in_date LIKE '%20180109%'
AND membership_id LIKE '%48Z%'

Output:  
membership_id	check_in_date	check_in_time	check_out_time
48Z7A	20180109	1600	1730
48Z55	20180109	1530	1700

# We need to narrow down Annabel's workout time  so we can cross reference to other gym users at the same time. 
- We can start by using Annabel's person_id number (16371) to find her gym membership id number

SELECT *
FROM get_fit_now_member
WHERE person_id = 16371

Output:
  id	person_id	name	membership_start_date	membership_status
90081	16371	Annabel Miller	20160208	gold

-Annabel's get_fit_now id number (90081 ) 

#Find Annabel's workout time
SELECT *
FROM get_fit_now_check_in
WHERE membership_id = '90081'
  
Output:
 membership_id	check_in_date	check_in_time	check_out_time
90081	20180109	1600	1700

-Looks like she worked out on January 9th from 4pm to 5 pm

# Who at the gym has a gold membership of "48Z" on their member number AND 
  
# Does this person have a license plate that include "H42W"?
