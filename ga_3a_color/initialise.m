function [pop]=initialise(popsize,mask,Y_min,Y_max,X_min,X_max,AA,BB)

pop = [ ];
TY=randi([Y_min,Y_max],popsize,1);TX=randi([X_min,X_max],popsize,1);TT=randi([AA,BB],popsize,2);
pop = [TY TX TT];
TY=randi([Y_min,Y_max],popsize,1);TX=randi([X_min,X_max],popsize,1);TT=randi([AA,BB],popsize,2);
pop = [pop TY TX TT];
TY=randi([Y_min,Y_max],popsize,1);TX=randi([X_min,X_max],popsize,1);TT=randi([AA,BB],popsize,2);
pop = [pop TY TX TT];

for i = 1:popsize
  pop(i, 13)=error_fun3( pop(i,:),mask) ; 
end

end