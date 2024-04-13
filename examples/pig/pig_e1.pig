books = LOAD 'prehisMarzo2019.txt' using PigStorage('\t') as (id, id2, id3, id4, id5, id6, id7, id8, id9, title, autor);
A = FILTER books BY title MATCHES '.*Madrid.*';
STORE A INTO 'data_pig/output/e1_a' USING PigStorage(',');

B = GROUP A BY title;
C = FOREACH B GENERATE group, COUNT(A) as num;
STORE C INTO 'data_pig/output/e1_b' USING PigStorage(',');
