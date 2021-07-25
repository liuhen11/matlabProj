%% 摆钟模拟
%  Script by adqeor@XJTU
%  理论力学课程的第二次大作业, 探究物理摆的周期诸元的关系.
%  影响因素包括温度(摆长), 重力扰动, 阻尼.
%  
%%% 模型介绍
%  
%  单摆是具有 1 自由度的系统, 摆角 theta 为状态参数. 重力加速度 g 在纸面内向下指; 
%  以摆自然悬垂位置为 0 度, 纸面内做正螺旋的角速度垂直向外;
%  扰动主矢 x 分量水平向右, y 分量垂直向上, 扰动主矩使摆角速度增大.
%  
%  摆的质量为 m, 质心到转轴的距离为 L, 质心对转轴具有转动惯量 J.
%  阻尼系数为 rho, 阻尼力 f_Damp = - rho * theta' 作用于质心.
%  
%  [phyPend]质量集中分布的物理单摆, 满足微分方程: theta'' + g/L * sin(theta) = 0
% 
% $$\frac{d^2 \theta}{dt^2}+\frac{g}{L}\cdot sin(\theta)=0$$
% 
%  [phyMiniPend]质量集中分布的微小摆幅物理单摆, 满足微分方程: theta'' + g/L * theta = 0
% 
% $$\frac{d^2 \theta}{dt^2}+\frac{g}{L}\cdot \theta=0$$
% 
%  [rigidPend]刚体单摆, 满足微分方程: theta'' + mgL/J * sin(theta) 0
% 
% $$\frac{d^2 \theta}{dt^2}+\frac{mgL}{J}\cdot sin(\theta)=0$$
% 
%  [rigidDampPend]空气阻尼刚体单摆, 在上述微分方程左侧增加阻尼项 rho/J * theta': theta'' + mgL/J * sin(theta) + rho/J * theta' = 0
% 
% $$\frac{d^2 \theta}{dt^2}+\frac{mgL}{J}\cdot sin(\theta)+\frac{\rho}{J}\cdot\frac{d \theta}{dt}=0$$
% 
%  [rigidDampTurbPend]受随扰动的空气阻尼刚体单摆, 在上述微分方程左侧继续增加随机扰动项 - L/J*(Fx * cos(theta)+Fy*sin(theta)) - M/J
% 
% $$\frac{d^2 \theta}{dt^2}+\frac{mgL}{J}\cdot sin(\theta)+\frac{\rho}{J}\cdot\frac{d \theta}{d t}-\frac{L}{J} \cdot(F_x\cdot cos(\theta)+F_y\cdot sin(\theta))-\frac{M}{J}= 0$$
% 
%  其中 F_x, F_y 为扰动的主矢, M 为扰动的主矩. 扰动的幅值谱密度给定.
%  
%%%  History:
%  新增 ode 事件位置, 实现碰撞;
%  移除 Deprecated 部分的被注释代码;
%  将可视化部分的 %%% 分节变为 %% 分节, 便于评估代码;
%  更正文档错误:
%    要更改参数的值, 必须创建一个新匿名函数, 即使参数是全局变量.
%    因而在[rev0.1.0]架构下, 不能简单地通过修改扰动量 Fx Fy M 的值以得到动态扰动.
%    可能的解决方法:
%    - 将求解过程定义为函数, f_modelName 等成为嵌套函数, 可以访问扰动量的实时值;
%    - 将扰动量变为接收参数 t 的(匿名)函数, 如扰动频率为 f 则返回形如 A*sin(2*pi*f*t) 的式子.
%        如果仍坚持使用匿名函数, 扰动频率将不能时变.
%    - 将扰动量定义为 global, f_rigidDampTurbPend 定义为本地函数. global 变量可能引发问题
%    - 手动实现微分方程求解, 每步迭代 d2ydt2 和 dydt 的值. 最自由的土方法, 不考虑.
%  [rev0.1.0] 6 Feb. 2021:
%  重建项目. 实现 phyPend, phyMiniPend, rigidPend, rigidDampPend; rigidDampTurbPend
%  模型暂时没有动态扰动;
%  建立文档;
%  发布;
%  28 Oct. 2020:
%  Create file.

%% 方程形式变换和可视化的一些讨论
%  MATLAB ode 求解器接收的方程 f 满足 y' = f(t, y)
%  但摆的微分方程形如 y'' = f(t, y, y'), 为二阶微分方程.
%  
%  使用换元技巧: 
%  记 x1 = y, x2 = y'; X = [x1; x2] = [y; y'],
%  有 [X]' = [y; y']' = [y'; y''] = [x2; f(t, x1, x2)]
%  式子中 [X]' = [x2; f(t, x1, x2)] 即可表示为 X' = F(T, X), 
%  以存储空间加倍, 评估时间增加为代价, 实现降阶.
%  
%  使用形如 f_modelName 的(匿名)函数句柄表示各个模型中除theta'' 的项, 即
%  theta'' = f_modelName(t, theta, theta'). 但这样得到的参数是句柄定义时的'快照'.
%  注意函数参数中 y 的微分阶次顺次升高, 因而送入 ode 求解器的函数形如
%  modelName = @(t, X) [X(2); f_modelName(t, X(1), X(2))];
%  
%  由于摆可能围绕支点发生翻滚, 解出的 y 不能直接用于作图
%  提问: 能否在方程中对 y 进行判定, 发现超出 +-pi 范围, 则进行相应的加减呢?
%  回答: 不行. trim 过程会造成该点的微分(数值差分)很大, 导致错误的解.
%  解决方案:
%  - 对 L * sin(y) 作图, 利用正余弦的有界性(下称'三角限幅');
%  - 或对 y' 作图, 只要系统机械能不发散(下称'能量限幅');
%  - 也可以对角度变量进行 unwrap 后绘图. 这将对角度进行强制限幅.
%  

%% 定义参数和方程
clc;
close all;

% 物理模型参数
g = 9.8;
L = 1;
m = 5;
J = m * L * L;
rho = 5;
Fx = -m*g;
Fy = 0;
M = 0;

% 仿真时间尺度参数
tStart = 0;
tFinal = 8;

% 物理模型初值
y0 = pi/3;
dydt0 = -.1;

% f_modelName		= @(t, y, dydt) 这些项在原微分方程中等于 y''
f_phyPend			= @(~, y, ~)	-g/L * sin(y);
f_phyMiniPend		= @(~, y, ~)	-g/L * y;
f_rigidPend			= @(~, y, ~)	-m*g*L/J * sin(y);
f_rigidDampPend		= @(~, y, dydt)	-m*g*L/J * sin(y) - rho/J * dydt;
f_rigidDampTurbPend = @(~, y, dydt) -m*g*L/J * sin(y) - rho/J * dydt + M/J + L/J * (Fx*cos(y)+Fy*(sin(y)));

% modelName			= @(t, X) [X(2); f_modelName(t, X(1), X(2))];
phyPend				= @(t, X) [X(2); f_phyPend(t, X(1), X(2))];
phyMiniPend			= @(t, X) [X(2); f_phyMiniPend(t, X(1), X(2))];
rigidPend			= @(t, X) [X(2); f_rigidPend(t, X(1), X(2))];
rigidDampPend		= @(t, X) [X(2); f_rigidDampPend(t, X(1), X(2))];
rigidDampTurbPend	= @(t, X) [X(2); f_rigidDampTurbPend(t, X(1), X(2))];

%% 一些求解例子和可视化
%  非刚性问题, MATLAB 内建了 ode23, ode45, ode113 三种求解器.
%  MATLAB 帮助页:
%  对于大多数非刚性问题，ode45 的性能最佳。
%  但对于允许较宽松的误差容限或刚度适中的问题，建议使用 ode23。
%  同样，对于具有严格误差容限的问题，ode113 可能比 ode45 更加高效。

%% 严格求解的单摆, odeset 参数一览
%  未指定输出参数会自行绘图

fprintf('\ntheta_0 = %.3f, theta_0'' = %.3f\n', y0, dydt0);
options = odeset('Refine', 10, ... 	% Refine 的值增加求解器输出点数. Refine 值对速度影响甚微. 指定求解时刻时不适用.
		'AbsTol',[1e-6 1e-1], ... 	% 绝对误差, 一个或变量个数的正标量. 只关心位置, 不关心速度(但在本例中它们是紧密耦合的).
		'RelTol',1e-3, ... 			% 相对误差, 接受一个正标量
		'OutputFcn',@odeplot, ...
		'Stats','on');
tic; ode45(rigidPend, [tStart, tFinal], [y0, dydt0], options); toc;
% also try: ode23, ode113, ode23s, ...
% 对于一般的问题, ode45 确实是综合性能较好的解算器

%% 小角近似的单摆

fprintf('theta_0 = %.3f\ntheta_0'' = %.3f\n', y0, dydt0);
[t, y] = ode45(phyMiniPend, [tStart, tFinal], [y0, dydt0]);
figure;
plot(t, y);
legend({'theta','dtheta/dt'});

%% 有常值扰动的刚体摆
%  使用两种方法避免摆角数值成周期跑飞
%  使用了新的 legend 图例指定方法

y0 = pi;
dydt0 = 10; % 指定一个比较大的初速度, 确保会围绕转轴多圈, 造成角度原始值跑飞

[t, y] = ode45(rigidDampTurbPend, [tStart, tFinal], [y0, dydt0]);

figure;
hold on;
plot(t, y(:,1), 'DisplayName','原始角度');
plot(t, L * sin(y(:,1)), 'DisplayName','水平位置投影 - 三角限幅');
plot(t, y(:,2), 'DisplayName','角速度 - 能量限幅');
hold off;
legend;

%% 单摆, 小角近似的单摆, 刚体摆的对比
%  在同一坐标下叠加绘制角速度

figure;
colormap(lines);
hold on;
[t, y1] = ode45(phyPend, [tStart, tFinal], [y0, dydt0]);
plot(t, y1(:,2), ':', 'LineWidth',3);
[t, y2] = ode45(phyMiniPend, [tStart, tFinal], [y0, dydt0]);
plot(t, y2(:,2));
[t, y3] = ode45(rigidPend, [tStart, tFinal], [y0, dydt0]);
plot(t, y3(:,2), 'o-', 'LineWidth',1);
legend({'单摆','小角近似单摆','刚体摆'},'Location','northwest');

%% 使用 pspectrum 对比分析
%  上述三种情况, 角速度和角加速度的功率谱

disp('角速度和角加速度的功率谱');
figure(1); [t, y1] = ode45(phyPend, [tStart, tFinal], [y0, dydt0]); pspectrum(y1, t, 'power');
figure(2); [t, y2] = ode45(phyMiniPend, [tStart, tFinal], [y0, dydt0]); pspectrum(y2, t, 'power');
figure(3); [t, y3] = ode45(rigidPend, [tStart, tFinal], [y0, dydt0]); pspectrum(y3, t, 'power');

%% 角度图示
%  在极坐标下, 更友好的展示摆的位置

y0 = pi/2;
dydt0 = 0;

[t, y] = ode45(rigidDampTurbPend, [tStart, tFinal], [y0, dydt0]);
pendulumPlot(t, y);

%% 阻尼摆的相图
%  指定 OutputFcn 可以避免自行画图
%  odeplot, 绘图; odephas2/3, 相图
%  注意拼写, phas2 不是 phase2

y0 = pi/2;
dydt0 = 1;

refine = 6;
options = odeset('OutputFcn',@odephas2, 'Refine',refine);

[t, y] = ode45(rigidPend, [tStart, tFinal], [y0, dydt0], options);
% also try: rigidPend, phyMiniPend, rigidDampPend
% 比较物理摆小角近似与否的相图差异
% 比较耗散系统和保守系统的相图差异
%     严格说, 保守系统应当是周期相图.
%     但如果能量足矣转动多圈, odephas2 没有处理 theta + n*2pi 的机制, 于是...
%     变更初始条件, 相图可能很不一样

%% ode 事件位置
%  检测到解的 t, y 出现某些特征, 用户定义的事件函数就返回 0 从而停止当前积分.
%  停止后根据条件重设初值, 再次开始求解. 重复操作, 就可以实现弹球效果.
%  更详细的信息请参考文档和官方示例 ballode.

refine = 6;

options = odeset('Events',@bounceEvent,...
		'OutputFcn',@odeplot,... 
		'OutputSel',[1],... 		% 仅绘制第一个分量, 对 odephase 不适用
		'Refine',refine);
			
f = figure;
ax = axes;
hold on;
box on;

% 有可能重复运行当前小节, 必须将初值清零.
tStart = 0;

y0 = pi/2;
dydt0 = 0;

tout = tStart;
yout = [y0, dydt0];

teout = [];
yeout = [];
ieout = [];

% 求解 5 次碰撞
for i = 1:5
	
	% Solve until the first terminal event.
	[t,y,te,ye,ie] = ode23(rigidDampPend, [tStart, tFinal], [y0, dydt0], options);
	
	% Accumulate output.  This could be passed out as output arguments.
	tout = [tout; t(2:end)];
	yout = [yout; y(2:end,:)];
	teout = [teout; te];          % Events at tstart are never reported.
	yeout = [yeout; ye];
	ieout = [ieout; ie];
	
	if ~ishold, hold on; end
	if f.UserData.stop, break; end
	
	% 重设初始值, 速度 0.8 衰减
	y0 = 0;
	dydt0 = -.8*y(end,2);

	% A good guess of a valid first timestep is the length of the last valid
	% timestep, so use it for faster computation.  'refine' is 4 by default.
	options = odeset(options, 'InitialStep',t(end)-t(end-refine), 'MaxStep',t(end)-t(1));

	tStart = t(end);
end

% 落点绘制, 添加坐标轴说明, 标题等闲杂事项. 如果指定绘制相图则不适用
plot(teout,yeout(:,1),'ro'); 
xlabel('time');
ylabel('height');
title('有阻尼的摆撞墙');
hold off
odeplot([],[],'done');

% 结束时再次清零, 避免影响下面小节的解算.
tStart = 0;

%% 本地函数

% 在极坐标下绘制摆的位置
function pendulumPlot(t, y)
	dt = diff(t);
	figure('NumberTitle','off', 'MenuBar','none', 'ToolBar','none');
	p = polarplot(y(1), 'o', 'MarkerSize',10, 'LineWidth',2);
	for i = 1:length(dt)
		pause(dt(i));
		p.ThetaData = y(i+1);
		drawnow limitrate;
	end
end

% ode 事件位置, 从正向过 0 则停止
function [value,isterminal,direction] = bounceEvent(t,y)
	value = y(1);     % theta 即 y(1) 过零, 则触发事件
	isterminal = 1;   % 事件触发则停止当前解算
	direction = -1;   % 过零方向为向负向才触发
end
