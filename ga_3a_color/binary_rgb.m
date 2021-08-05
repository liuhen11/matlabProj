function [ binary_rgb ] = binary_rgb( a,b,initial_image,r_value,g_value,b_value )
%BINARY_RGB 此处显示有关此函数的摘要
%   此处显示详细说明
    binary_rgb = zeros(a,b,3);
    for i=1:a
        for j=1:b
            if initial_image(i,j)==255
                binary_rgb(i,j,1)=r_value;
                binary_rgb(i,j,2)=g_value;
                binary_rgb(i,j,3)=b_value;
            else
                binary_rgb(i,j,1)=0;
                binary_rgb(i,j,2)=0;
                binary_rgb(i,j,3)=0;
            end
        end
    end


end

