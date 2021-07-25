%% dog_chase_fox
%  Script by adqeor @XJTU
%  狗追狐狸的仿真和可视化.
%  1. 狐狸在圆周匀速率运动, 狗从中心出发追击;
%  2. 狐狸直线逃跑, 狗垂直出发追击;
%  3. 狐狸避开狗逃跑, 但可惜眼神不太好;
%  
%  类似的仿真问题, 可以列解微分方程, 数值/符号求解后可视化;
%  也可直接仿真.
%  
%  History:
%  [rev0.1.3] 7 Feb. 2021:
%  增加狐狸两种运动模式;
%  调整代码: 向量化, 文档格式, 缩进, 变量命名;
%  移除了在 VCA.m 中重复的动态线绘制方法教程;
%  增加排错模式, 观察参数不匹配时的情况;
%  [rev0.1.2] 1 Feb. 2021:
%  建立了文档;
%  6 Sept. 2020:
%  Last known modification timestamp. 更改了绘图方法
%  更久之前:
%  实现了效果

%% 1. 狐狸在圆周匀速率运动, 狗从中心出发追击;

clc;
clear variables;
close all;

t = 0;
t_step = 20e-3;
d_limit = 200e-3;

radius = 10;
omega = 2;
velocity = 30;
%%%
%  注意参数取值的搭配:
%  如果狗的追击速度过快, 将会发生过冲乃至震荡, 围着狐狸左右横跳, 或是追而不击(其实是跑过了)
%  这些参数同时还要和仿真时间步进 t_step 和 d_limit 匹配. 仿真精度, 速度, 准确性(避免震荡), 自行权衡.
%  使能 DEBUG_MODE 可以在控制台打印距离 d, 以 d 是否单调下降辅助判断震荡; 也有助于选择 d_limit 取值.
%  后面小节不再重复此说明.
%  典型的震荡取值为: r=5,omeg=1,v=400, dt=1e-3,d=1e-3
DEBUG_MODE = true;
if DEBUG_MODE, format compact, format shortEng, end

% initial position
fox = [radius, 0];
dog = [0, 0];

% drawing properties setup
title('Fox and Dog: Wild Chase');
hold on;
axis equal;
h_fox = animatedline('Color', 'b', 'LineWidth', 2);
h_dog = animatedline('Color', 'r', 'LineStyle', '--');
legend({'fox', 'dog'}, 'Location','northwest', 'FontSize',12);
legend('boxoff');

d = norm(fox - dog);
% 求 fox - dog 向量的 2-范数, 即欧几里得距离
% also try: dist

while d > d_limit
	
    fox = radius*[cos(omega*t), sin(omega*t)];
    dog = dog + (fox-dog)*(velocity*t_step/d);
    
    addpoints(h_fox, fox(1), fox(2));
    addpoints(h_dog, dog(1), dog(2));
    drawnow;
	
	d = norm(fox - dog);
    t = t + t_step;
	if DEBUG_MODE,disp(d),end
end

fprintf('Terminated after %.3f seconds, caught successully.\n', t);

clear variables;

%% 2. 狐狸直线逃跑, 狗垂直出发追击;

clc;
clear variables;
close all;

t = 0;
t_step = 20e-3;
d_limit = 200e-3;

D = 10;
v_fox = 20;
v_dog = 40;

DEBUG_MODE = true;
if DEBUG_MODE, format compact, format shortEng, end

% initial position
fox = [D, 0];
dog = [0, 0];

% drawing properties setup
title('Fox and Dog: Wild Chase');
hold on;
axis equal;
h_fox = animatedline('Color', 'b', 'LineWidth', 2);
h_dog = animatedline('Color', 'r', 'LineStyle', '--');
legend({'fox', 'dog'}, 'Location','northwest', 'FontSize',12);
legend('boxoff');

d = norm(fox - dog);

while d > d_limit
	
    fox = [D, v_fox * t]; % 或是 fox(2) = fox(2) + t_step * v_fox;
    dog = dog + (fox-dog)*(v_dog*t_step/d);
    
    addpoints(h_fox, fox(1), fox(2));
    addpoints(h_dog, dog(1), dog(2));
    drawnow;
	
	d = norm(fox - dog);
    t = t + t_step;
	if DEBUG_MODE,disp(d),end
end

fprintf('Terminated after %.3f seconds, caught successully.\n', t);

clear variables;

%% 3. 狐狸避开狗逃跑, 但可惜眼神不太好;

clc;
clear variables;
close all;

t = 0;
t_step = 10e-3;
d_limit = 100e-3;

D = 10;
D_alarm = 2;
v_fox_relax = 1;
v_fox = 2;
v_dog = 4;

DEBUG_MODE = true;
if DEBUG_MODE, format compact, format shortEng, end

% initial position
fox = [D, D];
dog = [0, 0];

% drawing properties setup
title('Fox and Dog: Wild Chase');
hold on;
axis equal;
h_fox = animatedline();
h_dog = animatedline('LineStyle', ':', 'LineWidth', 2);
legend({'fox', 'dog'}, 'Location','northwest', 'FontSize',12);
legend('boxoff');

d = norm(fox - dog);

while d > d_limit
	
    if d > D_alarm
		% % 狗还很远, 看不到, 很悠闲的跑
		% fox(2) = fox(2) - v_fox_relax*t_step;
		
		% % 或是做随机漫步
		fox_dir = randn(1, 2); fox_dir = fox_dir / norm(fox_dir); % 速度方向矢量归一化
		fox = fox + fox_dir * (v_fox*t_step);
	else
		fox = fox - (dog-fox)*(v_fox*t_step/d); % 在 D_alarm 范围内, 避开狗全力跑
	end
	
    dog = dog + (fox-dog)*(v_dog*t_step/d); % 注意和狐狸式子的对偶性
    
    addpoints(h_fox, fox(1), fox(2));
    addpoints(h_dog, dog(1), dog(2));
    drawnow;
	
	d = norm(fox - dog);
    t = t + t_step;
	if DEBUG_MODE,disp(d),end
end

fprintf('Terminated after %.3f seconds, caught successully.\n', t);

clear variables;