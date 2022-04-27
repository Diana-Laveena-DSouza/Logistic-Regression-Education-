/* import csv file */
proc import datafile='/home/u61251187/sasuser.v94/Education.csv'
out=Education replace dbms=csv;
run;

/* structure of data */
proc contents data=Education;
run;

/*Task 1: Run logistic model to determine the factors that influence the admission process of a student (Drop insignificant variables) */
proc glm data=Education;
class Gender_Male Race gpa gre rank ses;
model admit= Gender_Male Race gpa gre rank ses;
means Gender_Male Race gpa gre rank ses / alpha=0.05;
run;

proc glm data=Education;
class rank;
model admit= rank;
means rank / alpha=0.05;
run;

/*Logistic Model Building*/
proc logistic data=Education descending;
class rank;
model admit = rank/selection=stepwise expb stb lackfit;
output out =temp p=new;
store admit_logistic;
run;

proc plm source=admit_logistic;
score data=Education out=test_scored predicted=p/ilink;
run;

/*Predictions*/
data test_scored;
set test_scored;
if p>0.5 then predict=1;
else predict=0;
keep Gender_Male Race gpa gre rank ses admit predict;

proc print data=test_scored;
run;

/*confusion matrix*/
proc freq data=test_scored;
table predict * admit/ nocol norow nopercent;
run;

/*Task 2: Categorize the records as a high, med, low based on gre value and draw a point chart */
data category;
set Education;
if gre > 580 then category='high';
else if gre >=440 and gre <=580 then category='medium';
else category='low';
keep gre gpa category;
run;

proc sgscatter data=category;
plot gre * gpa / group = category;
run;
