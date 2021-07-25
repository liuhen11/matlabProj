%% ElasticSim
%  Script by adqeor@XJTU
%  弹性体/弹性介质/弹性系统仿真, 有限差分法
%  
%  根据实际需要, 仿真建模有多种层级. 通常来说, 模型越复杂, 解算成本增加, 精度增加.
%  在 Verilog HDL 模型中, 有 5 层抽象级别: 系统级, 算法级, RTL级, 门级, 开关级. 开关级将各个信号节点作为模拟信号求解,
%  精度更高, 但不一定是你所需要的. 在精度, 成本等诸元之间进行取舍是工程师的基本素养.
%  在模拟电子仿真话题下, 也有类似的建模精度取舍. 下面的视频很有启发意义.
%  LTspice 教程: 将数据手册变为模型 https://www.bilibili.com/video/BV1c5411W7ST?p=8
%  原始地址: https://www.youtube.com/watch?v=rVAvW1Jh2AE&list=PLT84nve2j1g_wgGcm0Bv3K4RSl2Jdj
%
%  求解一个实际问题, 模型应从简单到复杂, 层层迭代. 机理变复杂, 参数变多, (通常)模型变得更精确.
%  求解模型, 可以列解(微分)方程, 也可以直接有限元仿真(在时间/空间上划分粒度, 变微分为差分, 迭代步进).
%
%  求解过程定义的物理常数均为 SI 单位.
% 
%  History:
%  7 Feb. 2021:
%  建立文件目录;

%% 准备

clc;
close all;
global k d m d_axis;
global x v F t;
% 方便本地函数访问变量

%% 轻弹簧射滑块, 仿真法
%  弹性系数 k 的轻质弹簧, 压缩 d 后推进物块 m 前进.
%  弹簧原长定义为位移零点, 物块坐标 x 速度 v.

k = 200;
d = 0.702;
m = 50e-3;

x = -d;
v = 0;
F = k*abs(x(end));

t = 0;
t_step = 1e-3;

while x(end) < 0
	F = [F; k*abs(x(end))];
	v = [v; v(end) + F(end)/m * t_step];
	x = [x; x(end) + v(end) * t_step];
	t = [t; t(end) + t_step];
end

figure;
xlabel('时间');
yyaxis left; plot(t,x, 'LineWidth',2, 'DisplayName','位移');
yyaxis right; hold on;
plot(t,v, 'LineWidth',2, 'DisplayName','速度');
plot(t,F, 'LineWidth',2, 'DisplayName','应力');
legend('Location','northwest');

% 不讲究的快速绘图: plot(t, [x,v]);

fprintf('拉距 %.1f 英寸, %.1f磅, %.1f FPS\n', d*(39.37), max(F)/9.8/0.454, v(end)*3.28);

%% 重弹簧射滑块



%% 弹弓
% 弓架轴距 d_axis, 输入英寸后转换到 SI
% 拉距 d, 输入英寸后转换到 SI
% 无拉力时皮筋刚好绷紧弓架

d_axis = 32;	d_axis = d_axis * 0.0254;
d = 27;			d = d * 0.0254;

k = 300;
m = 50e-3;
x = -d;
v = 0;
f_string = @(x) k * ( norm([x,d_axis/2]) - d_axis/2 );
F = f_string(x(end)) * 2 * abs(x(end)) / norm([x(end),d_axis/2]);

t = 0;
t_step = 1e-4;

while x(end) < 0
	F = [F; f_string(x(end)) * 2 * abs(x(end)) / norm([x(end),d_axis/2])];
	v = [v; v(end) + F(end) /m * t_step];
	x = [x; x(end) + v(end) * t_step];
	t = [t; t(end) + t_step];
end

figure;
xlabel('时间');
yyaxis left; plot(t,x, 'LineWidth',2, 'DisplayName','位移');
yyaxis right; hold on;
plot(t,v, 'LineWidth',2, 'DisplayName','速度');
plot(t,F, 'LineWidth',2, 'DisplayName','箭应力');
legend('Location','northwest');

% figure;
% plot(x, F)

fprintf('拉距 %.1f 英寸, %.1f磅, %.1f FPS\n', d*(39.37), max(F)/9.8/0.454, v(end)*3.28);

%% 复合弓 behavioral model

%% 史莱姆
%  向量化计算的实例
%  
%  一根史莱姆柱, 截面形状恒定, 但弹性模量, 密度沿截面变化. 现将其竖直放置, 求其微小形变分布.
%  显然这是一维问题
%  弹性模量和密度按照形变前坐标给定, 以地面为 0.
%  自重造成原位置为 x 的 dx 厚度史莱姆片元的压缩率为 ddx
%  则 ddx(x) = g * int(rho*S, x, L) / S(x) / E(x)
%  片元的现在高度为 y(x) = x - int(R, 0, x)
%  在微小形变假设下, 可以简单的绘制 R 对 x 的图, 而不必考虑 x -> y 的变换


L = 0.5; 	% 原长
g = 9.8;

S = @(x) ones(size(x)); 	% 截面积
E = @(x) 0.5e9 * ones(size(x)); 	% 弹性模量, PTFE->.5GPa
rho = @(x) 2.2e3 * ones(size(x));  	% 密度, PTFE->2.2g/cm3
% 输入多少元素, 就返回多少元素.

dx = 0.02;  % 几何元尺度
x = 0:dx:L;

M = dx * cumsum(rho(x) .* S(x));
% 访问 M 的 n 号元素, 得到 0 - n/length(M)*L 的质量累计, 因而 M(end) 为总质量
sigma = -g * ((M(end) - M)) ./ S(x);
% 应力分布, 负号表示压应力. 将 x-L 的积分转换为 0-x, 方便用 cumsum 做向量化计算
% 数值积分: (cum)sum 矩形法, (cum)trapz 梯形法. dx 足够小, 没有区别.
ddx = dx * sigma ./E(x);
% 微元型变量 = 微元长度 * 应力 / 弹性模量
y = x - cumsum(ddx);

figure;
plot(x, ddx/dx);
xlabel('线度'); ylabel('应变');

figure; axes;
colormap('parula'); 
sigmaU = max(sigma);
sigmaL = min(sigma);
image( (sigma-sigmaL)/(sigmaU-sigmaL) * 255);
title('应力分布');
colorbar('Location','southoutside', 'Ticks',[1 256], 'TickLabels',...
	{num2str(sprintf('%03.2G',sigmaL)), num2str(sprintf('%03.2G',sigmaU))} );
