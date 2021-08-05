function [ new_tmp ] = ellipse(x,y,a,b,tmp)
%
%tmp_ = zeros(101,101,3);
for i = x-a:x+a
    for j = y-b:y+b
        if ( ((i-x)^2)/a^2 + ((j-y)^2)/b^2 < 1 )
            tmp(i,j) = 255;
        end
    end
end
new_tmp = tmp;
end