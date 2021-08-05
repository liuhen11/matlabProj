function [y] = error_fun3(x,mask)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

x = round(x);
X1=x(1);Y1=x(2);A1=x(3);B1=x(4);
X2=x(5);Y2=x(6);A2=x(7);B2=x(8);
X3=x(9);Y3=x(10);A3=x(11);B3=x(12);
% X1
% X2
% X3
% Y1
% Y2
% Y3
% A1
% A2
% A3
% B1
% B2
% B3
tmpCircle = 0*mask;
Mask_model = ellipse(X1,Y1,A1,B1,tmpCircle);
Mask_model = ellipse(X2,Y2,A2,B2,Mask_model);
Mask_model = ellipse(X3,Y3,A3,B3,Mask_model);
% Mask_model  = binary_rgb(101,101,Mask_model,255,255,0)
% mask  = binary_rgb( 101,101,mask,255,0,0 )
% ad = size(Mask_model/255)
% bd = size(mask/255)

% mask is the given cell mask;  Mask_model is the created mask

Error=int8(Mask_model/255) - int8(mask/255);
y=sum(sum(abs(Error)));

% wrong: imshow(abs(Error*255))
% figure,subplot(1,3,1), imshow(Mask_model)
% subplot(1,3,2),imshow(mask),subplot(1,3,3),imshow(double(abs(Error))*255)

end

