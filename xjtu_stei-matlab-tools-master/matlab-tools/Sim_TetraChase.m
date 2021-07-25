%% TetraChase.m
%  Script by adqeor@XJTU
%  正方形四角有四个动物, 以编号顺序追赶. 使用仿真方法, 速度可指定. 
%
%  History:
%  [rev0.1.2] 7 Feb. 2021:
%  调整代码: 缩进, 命名;
%  [rev0.1.1] 10 Sept. 2020:
%  增加了文档

clc;
clear variables;
close all;

% controlling variables of t and distance limit
t = 0;
t_step = 4e-4;
d_limit = 2e-2;

% 四个点的速度
v1 = 30;
v2 = 24;
v3 = 22;
v4 = 50;

% 点的初始位置
D = 2;
point1 = [-D, D];
point2 = [D, D];
point3 = [D, -D];
point4 = [-D, -D];
% drawing properties setup
title('Tetra Chase', 'FontSize', 14, 'FontWeight', 'bold'); hold on; axis equal;

h_point1 = animatedline('Color', 'r', 'LineStyle', '-', 'LineWidth', 1.2);
h_point2 = animatedline('Color', 'g', 'LineStyle', '--', 'LineWidth', 1.2);
h_point3 = animatedline('Color', 'b', 'LineStyle', ':', 'LineWidth', 1.2);
h_point4 = animatedline('Color', 'k', 'LineStyle', '-.', 'LineWidth', 1.2);

legend({sprintf('P1@%d',v1),sprintf('P2@%d',v2), ...
		sprintf('P3@%d',v3),sprintf('P4@%d',v4)}, ...
		'Location', 'northwest', 'FontSize', 12);
legend('boxoff');

% 两个向量的距离计算通过做差后求模实现 norm or abs
d12 = norm(point1 - point2);
d23 = norm(point2 - point3);
d34 = norm(point3 - point4);
d41 = norm(point4 - point1);

disp_ctrl = 0;

while(d12 > d_limit && d23 > d_limit && d34 > d_limit && d41 > d_limit)
    
    point1 = point1 + [point2(1)-point1(1), point2(2)-point1(2)]*(v1*t_step/d12); 
    d12 = norm(point1 - point2);
    
    point2 = point2 + [point3(1)-point2(1), point3(2)-point2(2)]*(v2*t_step/d23);
    d23 = norm(point2 - point3);
    
    point3 = point3 + [point4(1)-point3(1), point4(2)-point3(2)]*(v3*t_step/d34);
    d34 = norm(point3 - point4);
    
    point4 = point4 + [point1(1)-point4(1), point1(2)-point4(2)]*(v4*t_step/d41);
	d41 = norm(point4 - point1);
	
	% 每一次步进之后都重新计算距离. 其实也可以先更新动物位置, 再计算距离. 精度考虑.
    t = t + t_step;
	
	% 限制刷新率, 加快动画进度的一种手段.
	% 对单纯的可视化, 改用 'drawnow limitrate; pause(0.001);'.
    disp_ctrl = disp_ctrl + 1;
    if(disp_ctrl == 2)
        disp_ctrl = 0;
        addpoints(h_point1, point1(1), point1(2));
        addpoints(h_point2, point2(1), point2(2));
        addpoints(h_point3, point3(1), point3(2));
        addpoints(h_point4, point4(1), point4(2));
        drawnow;
	end
end

fprintf('Terminated after %.3f seconds, caught successully.\n', t);
clear variables;