clear all
clc
fismat = newfis('student_selecy');
fismat = addvar(fismat,'input','math',[0 100]);
fismat = addvar(fismat,'input','height',[0 10]);
fismat = addvar(fismat,'output','pass',[0 100]);
fismat = addmf(fismat,'input',1,'bad','trapmf',[0 0 60 80]);
fismat = addmf(fismat,'input',1,'good','trapmf',[60 80 100 100]);
fismat = addmf(fismat,'input',2,'regular','trimf',[0 1 5]);
fismat = addmf(fismat,'input',2,'higher','trapmf',[1 5 10 10]);
fismat = addmf(fismat,'output',1,'lower','trimf',[0 30 50]);
fismat = addmf(fismat,'output',1,'regular','trimf',[30 50 80]);
fismat = addmf(fismat,'output',1,'higher','trimf',[50 80 100]);

rulelist = [1 2 3 1 1;2 2 1 1 1;0 1 2 1 0];
fismat = addrule(fismat,rulelist);
gensurf(fismat);

in = [50 1.5;80 2;70 3;56 0.56;62 8];
out = evalfis(in,fismat)
z = [50 80 70 56 62;1.5 2 3 0.56 8;56.6979 45.1905 51.1905 53.7827 68.3616]
surf(z)


