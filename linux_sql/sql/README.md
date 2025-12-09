# Introduction
(about 100-150 words)
Discuss the design of the project. What does this project/product do? Who are the users? What are the technologies you have used? (e.g. bash, docker, git, etc..)

# SQL Queries

###### Table Setup (DDL)
```sql
CREATE TABLE IF NOT EXISTS cd.members
    (
       memid integer NOT NULL, 
       surname character varying(200) NOT NULL, 
       firstname character varying(200) NOT NULL, 
       address character varying(300) NOT NULL, 
       zipcode integer NOT NULL, 
       telephone character varying(20) NOT NULL, 
       recommendedby integer,
       joindate timestamp NOT NULL,
       CONSTRAINT members_pk PRIMARY KEY (memid),
       CONSTRAINT fk_members_recommendedby FOREIGN KEY (recommendedby)
            REFERENCES cd.members(memid) ON DELETE SET NULL
    );

CREATE IF NOT EXISTS TABLE cd.facilities
    (
       facid integer NOT NULL, 
       name character varying(100) NOT NULL, 
       membercost numeric NOT NULL, 
       guestcost numeric NOT NULL, 
       initialoutlay numeric NOT NULL, 
       monthlymaintenance numeric NOT NULL, 
       CONSTRAINT facilities_pk PRIMARY KEY (facid)
    );

CREATE TABLE IF NOT EXISTS cd.bookings
    (
       bookid integer NOT NULL, 
       facid integer NOT NULL, 
       memid integer NOT NULL, 
       starttime timestamp NOT NULL,
       slots integer NOT NULL,
       CONSTRAINT bookings_pk PRIMARY KEY (bookid),
       CONSTRAINT fk_bookings_facid FOREIGN KEY (facid) REFERENCES cd.facilities(facid),
       CONSTRAINT fk_bookings_memid FOREIGN KEY (memid) REFERENCES cd.members(memid)
    );
```

## Modifying Data
### Question 1: Insert some data into a table
```sql
INSERT INTO cd.facilities 
(facid, name, membercost, guestcost, initialoutlay, monthlymaintenance)
VALUES (9, 'Spa', 20, 30, 100000, 800);
```

### Question 2: Insert in select
```sql
INSERT INTO cd.facilities 
(facid, name, membercost, guestcost, initialoutlay, monthlymaintenance)
VALUES ((SELECT MAX(facid) FROM cd.facilities)+1, 'Spa', 20, 30, 100000, 800)
```

### Question 3: Update
```sql
UPDATE cd.facilities SET initialoutlay=10000 WHERE name='Tennis Court 2';
```

### Question 4: Update with calculation
```sql
UPDATE cd.facilities
SET membercost=1.1*(
  SELECT membercost FROM cd.facilities WHERE name='Tennis Court 1'
  ),
  guestcost=1.1*(
  SELECT guestcost FROM cd.facilities WHERE name='Tennis Court 1'
  )
WHERE name='Tennis Court 2';
```

### Question 5: Delete all
```sql
DELETE FROM cd.bookings;
```

### Question 6: Delete with condition
```sql
DELETE FROM cd.members WHERE memid=37;
```

## Basics 
### Question 1
```sql
SELECT facid, name, membercost, monthlymaintenance
FROM cd.facilities
WHERE membercost > 0 AND membercost < (monthlymaintenance/50);
```

### Question 2
```sql
SELECT * FROM cd.facilities
WHERE name LIKE '%Tennis%';
```

### Question 3
```sql
SELECT * FROM cd.facilities
WHERE facid = 1 OR facid = 5;
```

### Question 4
```sql
SELECT memid, surname, firstname, joindate
FROM cd.members
WHERE joindate > '2012-09-01';
```

### Question 5
```sql
(SELECT surname
FROM cd.members)
UNION
(SELECT name FROM cd.facilities);
```

## Join
### Question 1: Simple join
```sql
SELECT cdb.starttime 
FROM cd.members AS cdm 
JOIN
cd.bookings AS cdb
ON cdm.memid = cdb.memid
WHERE cdm.firstname = 'David' AND
cdm.surname = 'Farrell';
```

### Question 2: Simple join 2
```sql
SELECT cdb.starttime AS start, cdf.name AS name
FROM cd.bookings AS cdb JOIN
cd.facilities AS cdf
ON cdb.facid = cdf.facid
WHERE DATE(cdb.starttime) = '2012-09-21' AND
cdf.name LIKE 'Tennis Court%'
ORDER BY start ASC;
```

### Question 3: Self join
```sql
SELECT cdm1.firstname AS memfname,
cdm1.surname AS memsname,
cdm2.firstname AS recfname,
cdm2.surname AS recsname
FROM cd.members AS cdm1 LEFT JOIN
cd.members AS cdm2
ON cdm1.recommendedby = cdm2.memid
ORDER BY memsname, memfname ASC;
```

### Question 4: Three joins
```sql
SELECT DISTINCT cdm2.firstname, cdm2.surname
FROM cd.members cdm1 JOIN
cd.members cdm2 ON
cdm1.recommendedby = cdm2.memid
ORDER BY cdm2.surname, cdm2.firstname ASC;
```

### Question 5: Subquery
```sql
SELECT DISTINCT CONCAT(cdm1.firstname, ' ', cdm1.surname) AS member,
(SELECT CONCAT(cdm2.firstname, ' ', cdm2.surname) 
 FROM cd.members AS cdm2
WHERE cdm1.recommendedby = cdm2.memid)
 FROM cd.members AS cdm1
 ORDER BY member ASC;
```

## Section 3: Aggregation
### Question 1: Group by Order by
```sql
SELECT recommendedby, COUNT(*) 
FROM cd.members
WHERE recommendedby > 0
GROUP BY recommendedby
ORDER BY recommendedby ASC;
```

### Question 2: Group by Order by
```sql
SELECT cdf.facid, SUM(cdb.slots) AS "Total Slots"
FROM cd.bookings cdb JOIN
cd.facilities cdf
ON cdb.facid = cdf.facid
GROUP BY cdf.facid
ORDER BY cdf.facid;
```

### Question 3: Group by with condition
```sql
SELECT cdf.facid, SUM(cdb.slots) AS "Total Slots"
FROM cd.facilities AS cdf JOIN
cd.bookings AS cdb
ON cdb.facid = cdf.facid
WHERE DATE(cdb.starttime) BETWEEN '2012-09-01' AND '2012-09-30'
GROUP BY cdf.facid
ORDER BY 2 ASC;
```

### Question 4: Group by multi col
```sql
SELECT cdf.facid, EXTRACT(MONTH FROM cdb.starttime), SUM(cdb.slots) AS "Total Slots"
FROM
cd.bookings AS cdb JOIN
cd.facilities AS cdf
ON cdb.facid = cdf.facid
WHERE EXTRACT(YEAR FROM cdb.starttime) = 2012
GROUP BY cdf.facid, 2 
ORDER BY cdf.facid, 2 ASC;
```

### Question 5: Count distinct
```sql
SELECT COUNT(memid) FROM
(SELECT memid, COUNT(*) 
FROM cd.bookings
GROUP BY memid)
WHERE count > 1
```

### Question 6: Group by multi col, join
```sql
SELECT cdm.surname, cdm.firstname, cdm.memid, MIN(cdb.starttime)
FROM cd.bookings AS cdb
JOIN
cd.members AS cdm
ON cdm.memid = cdb.memid
WHERE cdb.starttime > '2012-09-01'
GROUP BY cdm.surname, cdm.firstname, cdm.memid
ORDER BY 3 ASC;
```

### Question 7: Window function 1
```sql
SELECT COUNT(memid) OVER (), firstname, surname
FROM cd.members;
```

### Question 8: Window function 2
```sql
SELECT ROW_NUMBER() OVER (), firstname, surname 
FROM cd.members;
```

### Question 9: Window function, group by, subquery
```sql
SELECT facid, total FROM
(SELECT facid, total, RANK () OVER (ORDER BY total DESC)
FROM 
(SELECT facid, SUM(slots) AS total
FROM cd.bookings
GROUP BY facid
ORDER BY 2 DESC))
LIMIT 1;
```

## Section 5: String
### Question 1: Format string
```sql
SELECT CONCAT(surname, ', ' , firstname)
FROM cd.members;
```

### Question 2: Where + string function
```sql
SELECT memid, telephone
FROM cd.members
WHERE telephone LIKE '(___)%'
ORDER BY memid ASC;
```

### Question 3: Substr, group by
```sql
SELECT SUBSTR(surname, 1, 1) AS letter, COUNT(*)
FROM cd.members
GROUP BY letter
ORDER BY letter ASC;
```