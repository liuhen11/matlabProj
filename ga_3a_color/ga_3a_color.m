% Dr. G. Pang
% Example on the MATLAB implementation of the Genetic Algorithm for determining cell locations
% April 23, 2020


% Part A: Setup and initialization
clear all,close all

%------- stage 1 ----
% Change directory to the location where you all your files
% cd  'D:\gpang\.....'

original=imread('cells_3a.bmp'); figure(1),imshow(original)
mask=imread('cells_3a_mask.bmp');figure(2),imshow(mask)
[aa,bb]=size(mask); %101 by 101
% for sd=1:aa
%     for sf = 1:bb
%         if mask(sd,sf)==0
%             mask(sd,sf)=1;
%         else
%             mask(sd,sf)=0;
%         end
%     end
% end
% mask = mask * 255;figure(3),imshow(mask);
[XXX,YYY]=show_projection(mask);
[XX,YY]=projection(mask);

% X projection is from XX(1) to XX(2), highest height is XX(3) located at X = XX(4)
% Y projection is from YY(1) to YY(2), highest height is YY(3) located at Y = YY(4)

Guess=[ 60    35    12    13    50    50    10    11    40    65    10     9 ];

yy = error_fun3(Guess,mask);  % yy=315
yy = show_diff_mask_result(Guess,mask);

% --- stage 2 ----- Hyperparameter setup and Generate the initial population

popsize = 100; Y_min=23;Y_max=75;X_min=34;X_max=76;AA=3;BB=20;  popK = 40; 

%
NumGeneration = 500; Elite = 1; %  if elite evolution process is chosen, Elite = 1

M = 20; N = 20; 

% pop contains the initial populations
pop=initialise(popsize,mask,Y_min,Y_max,X_min,X_max,AA,BB);

% Sort the initial population and pick the best portion (popK) for the next stage
[A,index]=sort(pop(:,13),1,'ascend');
   popsort=pop(index,:);
   pop=popsort([1:popK],:);

% For storing the results
 plotdata=zeros(1,NumGeneration+1);
 plotdata(1)=pop(1,13);  % best from random generation of 100
 bestsofar =pop(1,[1:12]);

% For storing the results from random generation
 plotdatarandom=zeros(1,NumGeneration+1);
 plotdatarandom(1)=pop(1,13);  % best from random generation of 100
 bestsofarrandom =pop(1,[1:12]);
 bestsofarrandomValue = pop(1,13);

% --- stage 3 ---- mutation and crossover

% Canonical Main Loop----------------------------------------------------


for igen = 1:NumGeneration

  % Part B1: from pop, crossover to generate newpop2
  childpop1=[]; % empty matrix
  for i=1:M
    tmp = randi([1,popK],1,2); % choose TWO items from population
    parent1 = pop(tmp(1),:);  parent2 = pop(tmp(2),:);
    % crossover to generate new children
    [child1,child2]=crossover(parent1,parent2,mask);
    childpop1= [childpop1;child1];
    childpop1= [childpop1;child2];
  end

% Part B2: from pop, mutation to generate newpop3
% mutations to generate new children
childpop2=[];
for i=1:N
   tmp = randi([1,popK]); % choose one item from population
   parent = pop(tmp,:);
  [child]=mutation(parent,Y_min,Y_max,X_min,X_max,AA,BB,mask);
  childpop2= [childpop2;child];
end

% Part B3: for Elite evolution, the parents are also considered for the next generation 
if (Elite == 1)
    newpop = [pop ; childpop1 ; childpop2 ];
else
    newpop = [childpop1 ; childpop2 ];
end

  [A,index]=sort(newpop(:,13),1,'ascend');
   newpopsort=newpop(index,:);
   pop=newpopsort([1:popK],:);

 plotdata(1,igen+1)=pop(1,13);  % best of current generation
 bestsofar =pop(1,[1:12]);

% Part B4: The last part is for generating results from random generation of 100 cases

poprandom=initialise(popsize,mask,Y_min,Y_max,X_min,X_max,AA,BB);

% Sort the population and pick the best 
   [A,index]=sort(poprandom(:,13),1,'ascend');
   popsortrandom=poprandom(index,:);
   plotdatarandom(1,igen+1)=popsortrandom(1,13);
   if (popsortrandom(1,13) < bestsofarrandomValue)
     bestsofarrandom = popsortrandom(1,[1:12]);
     bestsofarrandomValue = popsortrandom(1,13);
     disp('random best'),igen,popsortrandom(1,13)
   end


end % END of the FOR loop

% --- stage 4 ----  display of results of Elite = 0 or 1
% display GA search result
figure,plot(plotdata)
plotdata(1,NumGeneration+1);
bestsofar
pop(1,:)
yy = show_diff_mask_result(bestsofar,mask)

% display random result
figure,plot(plotdatarandom)
min(plotdatarandom)
bestsofarrandom
yy = show_diff_mask_result(bestsofarrandom,mask)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




