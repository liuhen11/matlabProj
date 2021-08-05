function [y] = show_diff_mask_result(result,mask)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

x=result;
X1=x(1);Y1=x(2);A1=x(3);B1=x(4);
X2=x(5);Y2=x(6);A2=x(7);B2=x(8);
X3=x(9);Y3=x(10);A3=x(11);B3=x(12);
tmpCircle = 0*mask;
Mask_model = ellipse(X1,Y1,A1,B1,tmpCircle); 
Mask_model = ellipse(X2,Y2,A2,B2,Mask_model); 
Mask_model = ellipse(X3,Y3,A3,B3,Mask_model);
Mask_model  = binary_rgb(101,101,Mask_model,255,255,0);
mask  = binary_rgb( 101,101,mask,255,0,0 );
% Mask_model(:,:,1) = Mask_model
% Mask_model(:,:,2) = 0
% Mask_model(:,:,3) = 0
% mask(:,:,1) = mask
% mask(:,:,2) = 0
% mask(:,:,3) = 255
cd = size(Mask_model);
figure,subplot(1,3,1),imshow(Mask_model)
subplot(1,3,2),imshow(mask)
% overlap_cells is the given cell mask;  Mask_model is the created mask

Error=int8(Mask_model/255) - int8(mask/255);
yingyingying = double(abs(Error))*255
% wrong: imshow(abs(Error*255))
subplot(1,3,3),imshow(double(abs(Error))*255)
count = 0;
count1 = 0;
count2 = 0;
for mmmm = 1:101
    for mmmm1 = 1:101
        if yingyingying(mmmm,mmmm1,1)==0 & yingyingying(mmmm,mmmm1,2) == 255 & yingyingying(mmmm,mmmm1,3) == 0
            count2 = count2 + 1;
        end
        if yingyingying(mmmm,mmmm1,1)==255 & yingyingying(mmmm,mmmm1,2) == 255 & yingyingying(mmmm,mmmm1,3) == 0
                count1 = count1 + 1;
        end
        if yingyingying(mmmm,mmmm1,1)==255 & yingyingying(mmmm,mmmm1,2) == 0 & yingyingying(mmmm,mmmm1,3) == 0
                count = count + 1;
        end
    end
end
y=sum(sum(abs(Error)));
count
count1
count2
end

