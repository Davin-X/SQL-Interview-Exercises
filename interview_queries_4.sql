
/* nterview questions


*/

CREATE TABLE tmp (id int );
/*
1Q) input data
  ID
  1
  2
  3
  4
  5
Output
--------------
 1,2
 2,3
 3,4
 4,5
 */


select sum(case when id >=0 then id else 0 end) as positive,
sum(case when id  <0 then id else 0 end) as negative
from tmp;


/* 
2Q) calculate positive numbers and negative numbers.
Input data
-------------------
ID
1
2
3
-1
-2
-3

Output
--------------
6,-6
*/

Select id as A ,lead(id) over (ORDER BY id) as B FROM tmp;

/*

3Q) in hive I have external table. I want to change external to manage table. With use alter command and tblproperties()
What will be happen  internally in Hadoop?

ans = ALTER TABLE table_name  SET TBLPROPERTIES('EXTERNAL'='TRUE');
* /