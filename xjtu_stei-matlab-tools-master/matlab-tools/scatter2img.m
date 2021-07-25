%% scatter2img.m
%  Function by adqeor@XJTU
%  img = scatter2img(xVect, yVect, xRes, yRes)
%  
%  MATLAB 原生 scatter 在绘制点数很多的散点图时比较慢, 缩放卡顿,
%  并且用黑点着色, 密度过高的地方看不清, 损失动态范围.
%  将其转换为像素图片, 而后显示, 效果更好.
%  
%  转换算法: 
%  在 x y 方向上, 分别进行 xmin xmax 到 0 xRes 的线性映射, 而后取整, 即为像素坐标
%  对应坐标像素自加 1.
%  由于数组下标过 0, 取整的问题走了弯路, 各种 dirty tricks, 什么 eps, marginRatio 的.
%  其实是到 1 xRes, 重写映射就好了,
%  形如 i = ceil((x - x_lb)/(x_ub - x_lb) * (xRes - 1) + 1);
%  
%  被注释的函数可读性更好, 但性能略差. 正式采用的版本通过减少重复估值
%  速度在 batch = 500G, 提升 23%; batch = 5M, 提升18%.
%  
%  History:
%  [rev1.0.0] 10 Feb. 2021:
%  从文件内抽取为独立函数;
%  增加文档;
function img = scatter2img(xVect, yVect, xRes, yRes)
	img = zeros(xRes, yRes, 'uint8');
	x_lb = min(xVect);
	y_lb = min(yVect);
	x_K = (xRes-1)/(max(xVect)-x_lb); x_H = .5-x_K*x_lb;
	y_K = (yRes-1)/(max(yVect)-y_lb); y_H = .5-y_K*y_lb;
	pointCount = length(xVect);
	for index = 1:pointCount
		x = xVect(index);
		y = yVect(index);
		i = ceil(x*x_K+x_H);
		j = ceil(y*y_K+y_H);
		img(i,j) = img(i,j) + 1;
	end
end

% function img = scatter2img(xVect, yVect, xRes, yRes)
% 	img = zeros(xRes, yRes, 'uint8');
% 	x_lb = min(xVect);
% 	x_ub = max(xVect);
% 	y_lb = min(yVect);
% 	y_ub = max(yVect);
% 	for index = 1:length(xVect)
% 		x = xVect(index); i = ceil((x - x_lb)/(x_ub - x_lb) * (xRes - 1) + 1);
% 		y = yVect(index); j = ceil((y - y_lb)/(y_ub - y_lb) * (yRes - 1) + 1);
% 		img(i,j) = img(i,j) + 1;
% 	end
% end

% 未实现
% function pixelize(x, y, varargin)
% 
% 	p = inputParser;
% 	addRequired(p, 'x', @(x) isnumeric(x) );
% 	addRequired(p, 'y', @(x) isnumeric(x) );
% 
% 	addOptional(p, 'drawnow', false);
% 	addParameter(p, 'size', [480 360], @(x) isvector(x) && isnumeric(x) );
% 	parse(p, 'x', 'y', varargin{:});
% 
% 	persistent ptLog;
% 
% 	if p.Results.drawnow
% 
% 	else
% 		ptLog = [ptLog; p.Results.x, p.Results.y];
% 	end
% end