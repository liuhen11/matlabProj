function [ Xout, Yout ] = projection( Image_input)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
[aa,bb]=size(Image_input);
tmp=Image_input/255;
xx=sum(tmp'); %figure(2),plot(1:aa,xx), title('X projection')
yy=sum(tmp); % figure(3),plot(1:bb,yy), title('Y projection')

MaxValX = [ 0 0 ];FindFinish = 0; StartX = -1; FinishX = -1;
for i = 1:aa
  if (xx(i) ~= 0 )
   if (StartX == -1), StartX = i; end
   val1 = xx(i);
    if (val1 > MaxValX(1)), MaxValX = [val1 i]; end
      FindFinish = 1;
    end
  if (xx(i) == 0 && FindFinish == 1 )
   if (FinishX == -1), FinishX = i;end
  end
end

Xout=[StartX FinishX MaxValX(1) MaxValX(2) ];

MaxValY = [ 0 0 ];FindFinish = 0; StartY = -1; FinishY = -1;
for i = 1:bb
  if (yy(i) ~= 0 )
   if (StartY == -1), StartY = i; end
   val1 = yy(i);
    if (val1 > MaxValY(1)), MaxValY = [val1 i]; end
      FindFinish = 1;
    end
  if (yy(i) == 0 && FindFinish == 1 )
   if (FinishY == -1), FinishY = i;end
  end
end

Yout=[StartY FinishY MaxValY(1) MaxValY(2) ];

end

