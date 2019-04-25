--1.Use non-correlated sub-query, 
--find the names of employees who are not working on any projects.
SELECT EMP_NAME
FROM EMPLOYEES E
WHERE EMP_ID NOT IN (SELECT EMP_ID
                  FROM WORKON);
                  
--2.	Use correlated sub-query, find the names of employees 
--who are not working on any projects.
SELECT EMP_NAME
FROM EMPLOYEES E
WHERE NOT EXISTS(SELECT PROJECT_NUMBER
                  FROM WORKON W
                  WHERE W.EMP_ID = E.EMP_ID);  
                  
--3.Use non-correlated sub-query, find the names of the employees 
--who work on projects that are located in the same city where the employees are located.

--SELECT * FROM EMPLOYEES;
--SELECT * FROM PROJECTS;

SELECT EMP_NAME
FROM EMPLOYEES E
WHERE EMP_ID IN (SELECT EMP_ID
                  FROM WORKON W
                  WHERE PROJECT_NUMBER IN
                  (SELECT PROJECT_NUMBER FROM PROJECTS P
                  WHERE  E.emp_city = P.project_city));

--ALTERNATIVE SOLUTION            
SELECT EMP_NAME
FROM EMPLOYEES E
WHERE EMP_ID IN (SELECT EMP_ID
                  FROM WORKON W                 
                  LEFT JOIN PROJECTS P
                  on W.project_number = P.project_number
                  WHERE E.emp_city = P.project_city);  
                  
        
--4.Use correlated sub-query, find the names of the employees 
--who work on projects that are located in the same city where the employees are located.
SELECT EMP_NAME
FROM EMPLOYEES E
WHERE EXISTS (SELECT EMP_ID
                  FROM WORKON W                 
                  LEFT JOIN PROJECTS P
                  on W.project_number = P.project_number
                  WHERE E.emp_city = P.project_city); 
                  
--5. Use sub-query, find the names of the employees with the highest rate.
--SELECT * FROM EMPLOYEES;
--SELECT * FROM RATE;

 SELECT EMP_NAME FROM EMPLOYEES E
 inner join rate r
 on e.rate_category=r.rate_category
 where rownum < 2
 order by r.rate desc;
  
--6.Use sub-query and the ALL operator, find the names of the employees with the highest rate.
SELECT DISTINCT EMP_NAME
FROM EMP_NAME = ( SELECT E.EMP_NAME,R.RATE FROM EMPLOYEES E, RATE R
WHERE E.RATE_CATEGORY IN
( SELECT RATE_CATEGORY FROM RATE WHERE RATE > = ALL
( SELECT MAX(R.RATE) FROM RATE R, EMPLOYEES E
WHERE R.RATE_CATEGORY =E.RATE_CATEGORY)
))
;               
 
 --7. Use inline views and sub-query, find the names of employees with the highest rate.
SELECT W.EMP_NAME
FROM (SELECT E.EMP_NAME, R.RATE_CATEGORY, R.rate FROM EMPLOYEES E
      inner join rate R 
      on e.rate_category =R.rate_category
      where rownum <2
      order by rate desc) W

------Alternative ---------
SELECT DISTINCT EMP_NAME
FROM ( SELECT E.EMP_NAME,R.RATE FROM EMPLOYEES E, RATE R
WHERE E.RATE_CATEGORY IN
( SELECT RATE_CATEGORY FROM RATE WHERE RATE > =
( SELECT MAX(R.RATE) FROM RATE R, EMPLOYEES E
WHERE R.RATE_CATEGORY =E.RATE_CATEGORY)));

--- End one better---
SELECT E.EMP_NAME
FROM Employees E
right join (SELECT EP.emp_id,EP.EMP_NAME, R.RATE_CATEGORY, R.rate FROM EMPLOYEES EP
      inner join rate R 
      on ep.rate_category =R.rate_category
      where rownum <2
      order by R.rate desc) W 
      on E.emp_id=W.emp_id
    
      
--8.Use self-join, find the names of the employees who work on more than one project.
SELECT EMP_NAME
FROM EMPLOYEES WHERE EMP_ID IN
                         (SELECT C1.EMP_ID
                         FROM WORKON C1 
                         INNER JOIN WORKON C2
                         ON (C1.EMP_ID = C2.EMP_ID)
                         GROUP BY C1.EMP_ID
                         HAVING COUNT(C1.EMP_ID) > 1);

--9.Use non-correlated sub-query, find the names of the employees who work on more than one project.
SELECT EMP_NAME
from employees  
where emp_id in (select EMP_ID from workon 
                GROUP BY EMP_ID 
                HAVING COUNT(EMP_ID) > 1)


--10.Use correlated sub-query, find the names of the employees who work on more than one project.
SELECT EMP_NAME
from employees E
where EXISTS (select NULL from workon W 
WHERE E.EMP_ID = W.EMP_ID 
GROUP BY E.EMP_ID 
HAVING COUNT(E.EMP_ID) > 1)




