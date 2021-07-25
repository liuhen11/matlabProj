%% 复映射可视化
%  Script by adqeor@XJTU
%  绘制复映射下, 坐标轴, 正交参考线和像的变化.
%  
%  绘制动态增长的线. 按推荐程度递减, 可以使用:
%  - animatedline 对象, addpoints + drawnow 更新;
%  - comet 对象, 好处是一键生成具有彗头, 尾迹的动态彗星图, 坏处是几乎不能指定
%    参数, 不能同时生成多幅动画, 且运行 comet 时必须获得所有待绘制的数据;
%  - plot 对象, 每次更新将 plot 对象的 XData, YData 更新, drawnow 重绘;
%  - plot 对象, 每次更新删除上次 [y], 重绘为 [y, yNewElement], 并进行 pause;
%  - plot 对象, 每次绘制 [y(n-1) y(n)] 的线段;
%  
%  尽量不要用 pause 控制刷新率. 这是因为:
%  1.性能低;
%  2.需要手动调整 pause 时长.
%    如果仿真迭代计算复杂, 或仿真步进粒度太细, 动画进程会很慢;
%    反之, 动画会一闪而过;
%    并且, 如实际刷新率接近 20 Hz 会出现闪屏.
%  
%  History:
%  [rev0.1.2] 6 Feb. 2021:
%  调整代码: 使用 animatedline 重写动画, 绘图句柄, 动画循环流程;
%  [rev0.1.1] 6 Feb. 2021:
%  增加说明;
%  调整代码: 命名, 注释, 缩进, 分节, 绘图句柄;
%  [rev0.1.0] 5 Sept. 2020:
%  Create file.

clc;
close all;
clear variables;

%% 确定被映射函数, 映射变换, 参考线等

SUPRESS_CLI = true;

% 复变换, 像生成
if SUPRESS_CLI
	Trans = @(z) z.^2;
	disp('使用的变换函数为');
	disp(Trans);
else
	fprintf('输入复变换函数名或函数句柄, 如 @(z) log(z) 或 @(z) z.*z\n');
	Trans = input('z = ');
end

% 原象的参数方程
if SUPRESS_CLI
	fx = @(t) 1.*cos(2.*t);
	fy = @(t) 1.*sin(3.*t);
	disp('使用的原象函数为');
	disp('周期利萨如图形');
else
	fprintf('\n输入原象的参数方程, 应为函数名或函数句柄\n');
	fx = input('x = ');
	fy = input('y = ');
end

% 函数 绘制区间与精度
t_lb = 0;
t_ub = 2*pi;
t_prec = .04;
t = t_lb:t_prec:t_ub;

% 坐标轴 和 正交参考线 绘制区间与精度
line_ub = 1;
line_lb = -line_ub;
line_prec = .05;
t_line = line_lb:line_prec:line_ub;

% 正交参考线位置
ref = [.5 -.5 1 -1];

%% 计算

% 原象坐标
x_curve = fx(t);
y_curve = fy(t);

% 象坐标
z_tran = complex(Trans(fx(t) + 1j*fy(t)));

%% 可视化-建立图窗, 坐标区

% 绘图区设定
figure('Name', '复映射可视化', 'NumberTitle', 'off', ...
		'Menubar', 'none', 'Units', 'normalized');

%%% 指定并取出 lines 配色
%   或自行设定颜色. 这里取出了 lines 配色的前三种, 每一行为一种颜色的 R G B 分量
%   plot 等绘图通常接收 RGB 格式的颜色, uipanel 等 ui 组件接收 HEX 格式的颜色
% colormap(lines);
% cmap = colormap;

cmap = [0    0.447    0.741
    0.850    0.325    0.098
    0.929    0.694    0.125];

%%% 
%  在 15b 版本建立 subplot 坐标区要这样: subplot(121, 'Position', [.04 .05 .4 .9])
%  即使指定了 position 也要重复指定 121 的屑
ax0 = subplot('Position', [.04 .05 .4 .9]);
ax0.NextPlot = 'add';
title(ax0, '原象平面');

ax1 = subplot('Position', [.54 .05 .4 .9]);
ax1.NextPlot = 'add';
title(ax1, '象平面');

axis([ax0, ax1], 'equal');
grid([ax0, ax1], 'on');

% 绘图边界系数
% 用绘图上下界之差乘以该系数, 为绘图边界宽
marginRatio = .05;

% 设置原象坐标绘图范围
x_lb = min(x_curve); x_ub = max(x_curve);
y_lb = min(y_curve); y_ub = max(y_curve);
xlim(ax0, [x_lb - (x_ub-x_lb)*marginRatio, x_ub + (x_ub-x_lb)*marginRatio]);
ylim(ax0, [y_lb - (y_ub-y_lb)*marginRatio, y_ub + (y_ub-y_lb)*marginRatio]);

% 设置象坐标绘图范围
x_lb = min(real(z_tran)); x_ub = max(real(z_tran));
y_lb = min(imag(z_tran)); y_ub = max(imag(z_tran));
xlim(ax1, [x_lb - (x_ub-x_lb)*marginRatio, x_ub + (x_ub-x_lb)*marginRatio]);
ylim(ax1, [y_lb - (y_ub-y_lb)*marginRatio, y_ub + (y_ub-y_lb)*marginRatio]);

%% 绘制坐标轴及其映射

h0_ax_X = animatedline(ax0, 'Color',cmap(1,:), 'LineWidth',1.5);
h0_ax_Y = animatedline(ax0, 'Color',cmap(2,:), 'LineWidth',1.5); % 原象坐标下的 X Y 轴
h1_ax_X = animatedline(ax1, 'Color',cmap(1,:), 'LineWidth',1.5);
h1_ax_Y = animatedline(ax1, 'Color',cmap(2,:), 'LineWidth',1.5); % 象坐标下的 X Y 轴

for i = 1:length(t_line)-1
	
	addpoints(h0_ax_X, t_line(i+1), 0);
	addpoints(h0_ax_Y, 0, t_line(i+1));
	addpoints(h1_ax_X, real(Trans(t_line(i+1))), imag(Trans(t_line(i+1))));
	addpoints(h1_ax_Y, real(Trans(1j*t_line(i+1))), imag(Trans(1j*t_line(i+1))));
	
	drawnow limitrate;
	pause(0.03);
	
	%%%
	%  如果直接 plot(h1, tran(t(i:i+1)), 'Color', ...); 是不能画出x轴的。
	%  但 plot(double, double) 或 plot(complex double)都可.
	%  一定要确保传入的复数的确具有非0虚部. 如果曲线变换后的虚部恒为0, 会退化为
	%  double. plot(double) 是不能得到想要的效果的.
	%  解决方案:
	%  1.如上面那样使用 complex() 进行显式转换, 将 double 变成 double + 1j * 0
	%  2.手动分离实部虚部 plot(ax1, real(tran(t(i:i+1))), imag(tran(t(i:i+1))), 'Color', ...);
	
end

%% 绘制正交参考线及其映射

for n = 1:length(ref)
	title(ax1, sprintf('象平面  绘制第%d簇参考线',n));
	for i = 1:length(t_line)-1
		plot(ax0, t_line(i:i+1), ref(n).*[1 1], '-.', 'Color',cmap(1,:), 'LineWidth',.1); 		%x簇原象
		plot(ax0, ref(n).*[1 1], t_line(i:i+1), '-.', 'Color',cmap(2,:), 'LineWidth',.1); 		%y簇原象
		plot(ax1, Trans(t_line(i:i+1) + 1j*ref(n)), '-.', 'Color',cmap(1,:), 'LineWidth',.1); 	%x簇映像
		plot(ax1, Trans(1j.*t_line(i:i+1) + ref(n)), '-.', 'Color',cmap(2,:), 'LineWidth',.1); 	%y簇映像
		
		pause(0.007);
	end
end

%% 绘制原象和象

title(ax1, '象平面  绘制曲线');

% 两个光标指示当前绘图位置
cursor0 = plot(ax0, x_curve(1), y_curve(1), 'o', 'MarkerSize',18, 'LineWidth',2, 'Color',cmap(3,:));
cursor1 = plot(ax1, z_tran(1), 'x', 'MarkerSize',18, 'LineWidth',2, 'Color',cmap(3,:));

h0_curve = animatedline(ax0, 'Color','k', 'LineWidth', 2.2);
h1_curve = animatedline(ax1, 'Color','k', 'LineWidth', 2.2); 	% 原象和象

for i = 1:length(t)
	
	addpoints(h0_curve, x_curve(i), y_curve(i));
	addpoints(h1_curve, real(z_tran(i)), imag((z_tran(i))));
	
	cursor0.XData = x_curve(i);
	cursor0.YData = y_curve(i);
	cursor1.XData = real(z_tran(i));
	cursor1.YData = imag(z_tran(i));
	% set(cursor0, 'XData',x_val(i), 'YData',y_val(i)); 		% 15b 需要这样
	
	drawnow limitrate;
	pause(0.001);
	
	%%%
	%  drawnow limitrate + pause 是我目前认为最有效的迭代逐帧绘制可视化方法
	%  前者使 plot 对象重绘, 并指定最大刷新率为 20 Hz 以防止闪屏 / 过度占用资源;
	%  后者降低数据迭代速度, 否则对这样计算并不复杂的仿真, 在 drawnow limitrate 作用下, 动画进度会过快.
end

% comet(ax0, x_curve, y_curve);
% comet(ax1, real(z_tran), imag(z_tran));
