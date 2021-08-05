function [xx,yy] = show_projection(Image_input)

%   Detailed explanation goes here
[aa,bb]=size(Image_input)
tmp=Image_input/255;
size(tmp)
xx=sum(tmp'); figure,plot(1:aa,xx), title('X projection')
yy=sum(tmp);figure,plot(1:bb,yy), title('Y projection')
end

