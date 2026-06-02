-- Section 1: Modifying data
-- Question 1: Inserting some data into a table
INSERT INTO cd.facilities (facid, name, membercost, guestcost, initialoutlay, monthlymaintenance)
VALUES (9, 'Spa', 20, 30, 100000, 800);

-- Question 2: Select in insert
INSERT INTO cd.facilities (facid, name, membercost, guestcost, initialoutlay, monthlymaintenance)
VALUES ((SELECT MAX(facid) FROM cd.facilities)+1, 'Spa', 20, 30, 100000, 800)

-- Question 3: Update
UPDATE cd.facilities SET initialoutlay=10000 WHERE name='Tennis Court 2';

-- Question 4: Update with calculation
UPDATE cd.facilities
SET membercost=1.1*(
  SELECT membercost FROM cd.facilities WHERE name='Tennis Court 1'
  ),
  guestcost=1.1*(
  SELECT guestcost FROM cd.facilities WHERE name='Tennis Court 1'
  )
WHERE name='Tennis Court 2';

-- Question 5: Delete all
DELETE FROM cd.bookings;

-- Question 6: Delete with condition
DELETE FROM cd.members WHERE memid=37;

-- Section 2: Basics
-- Question 1
SELECT facid, name, membercost, monthlymaintenance
FROM cd.facilities
WHERE membercost > 0 AND membercost < (monthlymaintenance/50);

-- Question 2
SELECT * FROM cd.facilities
WHERE name LIKE '%Tennis%';

-- Question 3
SELECT * FROM cd.facilities
WHERE facid = 1 OR facid = 5;

-- Question 4
SELECT memid, surname, firstname, joindate
FROM cd.members
WHERE joindate > '2012-09-01';

-- Question 5
(SELECT surname
FROM cd.members)
UNION
(SELECT name FROM cd.facilities);

-- Section 3: Join
-- Question 1
SELECT cdb.starttime
FROM cd.members AS cdm
JOIN
cd.bookings AS cdb
ON cdm.memid = cdb.memid
WHERE cdm.firstname = 'David' AND
cdm.surname = 'Farrell';

-- Question 2
SELECT cdb.starttime AS start, cdf.name AS name
FROM cd.bookings AS cdb JOIN
cd.facilities AS cdf
ON cdb.facid = cdf.facid
WHERE DATE(cdb.starttime) = '2012-09-21' AND
cdf.name LIKE 'Tennis Court%'
ORDER BY start ASC;

-- Question 3
SELECT cdm1.firstname AS memfname,
cdm1.surname AS memsname,
cdm2.firstname AS recfname,
cdm2.surname AS recsname
FROM cd.members AS cdm1 LEFT JOIN
cd.members AS cdm2
ON cdm1.recommendedby = cdm2.memid
ORDER BY memsname, memfname ASC;

-- Question 4
SELECT DISTINCT cdm2.firstname, cdm2.surname
FROM cd.members cdm1 JOIN
cd.members cdm2 ON
cdm1.recommendedby = cdm2.memid
ORDER BY cdm2.surname, cdm2.firstname ASC;

-- Question 5
SELECT DISTINCT CONCAT(cdm1.firstname, ' ', cdm1.surname) AS member,
(SELECT CONCAT(cdm2.firstname, ' ', cdm2.surname)
 FROM cd.members AS cdm2
WHERE cdm1.recommendedby = cdm2.memid)
 FROM cd.members AS cdm1
 ORDER BY member ASC;

-- Section 3: Aggregation
-- Question 1
SELECT recommendedby, COUNT(*)
FROM cd.members
WHERE recommendedby > 0
GROUP BY recommendedby
ORDER BY recommendedby ASC;

-- Question 2
SELECT cdf.facid, SUM(cdb.slots) AS "Total Slots"
FROM cd.bookings cdb JOIN
cd.facilities cdf
ON cdb.facid = cdf.facid
GROUP BY cdf.facid
ORDER BY cdf.facid;

-- Question 3
SELECT cdf.facid, SUM(cdb.slots) AS "Total Slots"
FROM cd.facilities AS cdf JOIN
cd.bookings AS cdb
ON cdb.facid = cdf.facid
WHERE DATE(cdb.starttime) BETWEEN '2012-09-01' AND '2012-09-30'
GROUP BY cdf.facid
ORDER BY 2 ASC;

-- Question 4
SELECT cdf.facid, EXTRACT(MONTH FROM cdb.starttime), SUM(cdb.slots) AS "Total Slots"
FROM
cd.bookings AS cdb JOIN
cd.facilities AS cdf
ON cdb.facid = cdf.facid
WHERE EXTRACT(YEAR FROM cdb.starttime) = 2012
GROUP BY cdf.facid, 2
ORDER BY cdf.facid, 2 ASC;

-- Question 5
SELECT COUNT(memid) FROM
(SELECT memid, COUNT(*)
FROM cd.bookings
GROUP BY memid)
WHERE count > 1

-- Question 6
SELECT cdm.surname, cdm.firstname, cdm.memid, MIN(cdb.starttime)
FROM cd.bookings AS cdb
JOIN
cd.members AS cdm
ON cdm.memid = cdb.memid
WHERE cdb.starttime > '2012-09-01'
GROUP BY cdm.surname, cdm.firstname, cdm.memid
ORDER BY 3 ASC;

-- Question 7
SELECT COUNT(memid) OVER (), firstname, surname
FROM cd.members;

-- Question 8
SELECT ROW_NUMBER() OVER (), firstname, surname
FROM cd.members;

-- Question 9
SELECT facid, total FROM
(SELECT facid, total, RANK () OVER (ORDER BY total DESC)
FROM
(SELECT facid, SUM(slots) AS total
FROM cd.bookings
GROUP BY facid
ORDER BY 2 DESC))
LIMIT 1;

-- Section 5: String
-- Question 1
SELECT CONCAT(surname, ', ' , firstname)
FROM cd.members;

-- Question 2
SELECT memid, telephone
FROM cd.members
WHERE telephone LIKE '(___)%'
ORDER BY memid ASC;

-- Question 3
SELECT SUBSTR(surname, 1, 1) AS letter, COUNT(*)
FROM cd.members
GROUP BY letter
ORDER BY letter ASC;