function MotionSim
%% Script by AD1394@XJTU, Oct 10, 2020
%  使用MATLAB进行运动学仿真, 实现了用户友好的图形界面交互.
%  
%  需使用比 MATLAB 16b 更新的版本.
%
%  虽然冠名 'Script', 本文件的实质是一个没有输入参数的 Function.
%  这是为了定义交互组件的回调函数(它们必须为嵌套在主函数中).
%  为提高可读性, 取消第一级缩进.
%
%  [rev0.1.1] 4 Feb. 2021:
%  重建文档;
%  调整循环流程;
%  更改帧率设置方法: 将 pause 方法改为 drawnow limitrate;
%  变更部分代码: 缩进, 命名, 可选代码;
%  使用小节分隔代码, 提高可读性;
%  [rev0.1.0] 20 Nov. 2020:
%  Last known archive.
%  9 Oct. 2020:
%  Create file.
	
clc;
close all;
debugMode = false;

%% 建立主窗口对象

disp('建立主窗口对象');
% 仿真主窗口
f_Main = figure(1);
f_Main.Visible = 'off';
f_Main.Name = 'Motion Simulation on MATLAB';
f_Main.Units = 'pixels';
f_Main.Position = [150,150,800,480];
f_Main.Pointer = 'crosshair';
f_Main.NumberTitle = 'off';
f_Main.DeleteFcn = @figDelete;
if debugMode
	f_Main.ToolBar = 'figure';
	f_Main.MenuBar = 'figure';
else
	f_Main.ToolBar = 'none';
	f_Main.MenuBar = 'none';
end

%% 交互组件对象构建

disp('建立交互组件对象');

btnHeight = 0.1;
btnWidth = 0.15;

h_reset = uicontrol('Style','Pushbutton','String','RESET',...
		'Units','normalized', 'Position',[0,0,btnWidth,btnHeight],...
		'Callback',@btnResetCallback, 'Interruptible','off');

h_play = uicontrol('Style','Togglebutton','String','Play', 'FontWeight','bold',...
		'Units','normalized', 'Position',[btnWidth,0,2*btnWidth,btnHeight],...
		'Callback',@btnPlayCallback, 'Interruptible','off');

h_plot = uicontrol('Style','Pushbutton','String','Plot',...
		'Units','normalized', 'Position',[3*btnWidth,0,btnWidth,btnHeight],...
		'Callback',@btnPlotCallback, 'Interruptible','off');

h_status = uicontrol('Style','text',...
		'Units','normalized', 'Position',[4.2*btnWidth,0,1-4*btnWidth,btnHeight]);

h_statusLight= uipanel('Position',[0.5*btnWidth,btnHeight,3*btnWidth,.15-btnHeight]);

%% 程序运行参数设定

% 土法实现的枚举类型, 用于表示运行状态
running = int8(1);
paused = int8(2);
halted = int8(0);
reseted = int8(-1);

status = reseted;
EXIT = false;

% HEX 颜色常量
color_green = '#77AC30';
color_red = '#A2142F';
color_blue = '#4DBEEE';
color_yellow = '#EDB120';

% 运动仿真参数
dt = 0.05;
t = 0;
omega = 2;
theta0 = pi/3;
theta = theta0;
L1 = 0.6; % 曲柄长度
L2 = 1.5; % 连杆长度

f_Main.Visible = 'on';
disp('主窗完成绘制');
% 应当等所有组件完成绘制, 才对根对象 f 启用可见性.

%% 绘图区及动态对象建立

h_ax = axes(f_Main, 'Units','normalized', 'Position',[0,.2,1,.8],...
		'XColor','none', 'YColor','none', 'NextPlot','add');

axis equal;
xlim(h_ax, [-1 3]);

disp('绘图区完成, 设置范围并取消刻度');
% input('键入回车以开始');

% 绘图区对象尺寸
r_piston = 0.1;		% 活塞圆角半径
d_cylinder = 0.12;	% 气缸(活塞)直径

% 建立绘图动态对象
motionObjects = []; % 动态显示, 需要更新的对象加入列表

viscircles(h_ax, [0 0], L1, 'Color','r', 'LineStyle','-.', 'LineWidth',.5);
% rectangle(h_ax, 'Position',[-L1+L2-.1 r_piston 2*L1+.4 d_cylinder],...
%		'Curvature',0.12, 'FaceColor','#E2DAAC');
rectangle(h_ax, 'Position',[-L1+L2-.1 -r_piston-d_cylinder 2*L1+.4 d_cylinder],...
		'FaceColor','#E2DAAC');

h12 = plot(h_ax, L1*cos(theta),L1*sin(theta), 'O', 'Color','r', 'LineWidth',1.7);
motionObjects = [motionObjects, h12]; % 动态显示, 需要更新的对象加入列表

h1 = plot(h_ax, [0,h12.XData],[0,h12.YData], '-Ok', 'LineWidth',3);
motionObjects = [motionObjects, h1];

h_cyl = rectangle(h_ax, 'Position',[h12.XData+sqrt(L2^2-(h12.YData)^2),-.1,.35,.2],...
		'Curvature',0.25, 'FaceColor','#A2AAAC');
motionObjects = [motionObjects, h_cyl];

h2 = plot(h_ax, [h12.XData,h_cyl.Position(1)],[h12.YData,0], 'k', 'LineWidth',2);
motionObjects = [motionObjects, h2];

%% 仿真流程

xdata = [];
tdata = [];

while true
	
	if EXIT, return, end

	switch status
		case running
			motionObjectBlanking(); % 消隐并开始下次重绘
			
			motionObjectUpdate(); % 更新动态对象数据

			motionObjectDisplay(); % 开启显示

			theta = theta0 + omega*t;				
			t = t + dt; % 时间, 角度步进更新

			drawnow limitrate nocallbacks;
		case {paused, halted, reseted}
			% 在暂停阶段保持显示
			motionObjectDisplay();

			drawnow limitrate nocallbacks;
		otherwise
			error('No proper status %s.', status);
	end

	pause(.02); % 没有 pause 会跑的太快, 不能及时响应按钮命令
end

%% 嵌套函数定义

function motionObjectBlanking
% 		h1.Visible = 'off';
% 		h12.Visible = 'off';
% 		h2.Visible = 'off';
% 		h_cyl.Visible = 'off';
% % 旧的写法, 不好用
	for i = 1:length(motionObjects), motionObjects(i).Visible = 'off'; end
end

function motionObjectDisplay
	for i = 1:length(motionObjects), motionObjects(i).Visible = 'on'; end
end

function motionObjectUpdate
	h12.XData = L1 * cos(theta);
	h12.YData = L1 * sin(theta);

	h1.XData = [0, h12.XData];
	h1.YData = [0, h12.YData];

	h_cyl.Position(1) = h12.XData + sqrt(L2^2 - (h12.YData)^2);

	h2.XData = [h12.XData,h_cyl.Position(1)];
	h2.YData = [h12.YData,0];

	xdata = [xdata, h_cyl.Position(1)];
	tdata = [tdata, t];
end

function btnResetCallback(~,~)
	status = reseted;

	h_statusLight.BackgroundColor = color_red;
	h_status.String = 'RESET';
	h_play.String = 'Replay';
	h_play.Value = 0;
	h_pause.Value = 0;
	
	t = 0;
	tdata = [];
	xdata = [];
end

function btnPlayCallback(~,~)
	if status ~= running
		status = running;

		h_statusLight.BackgroundColor = color_green;
		h_status.String = 'Running';
		h_play.String = 'Pause';
	else
		status = paused;

		h_statusLight.BackgroundColor = color_yellow;
		h_status.String = 'Paused';
		h_play.String = 'Play';
	end
end

function btnPlotCallback(~,~)
	status = paused;

	h_statusLight.BackgroundColor = color_blue;
	h_status.String = 'Halted';
	h_play.String = 'Play';
	h_play.Value = 0;
	h_pause.Value = 1;

	f_Plot = figure(2); clf('reset'); % 清除旧的绘图, 如果存在
	f_Plot.NumberTitle = 'off';
	f_Plot.Name = 'SimPlot';
	f_Plot.MenuBar = 'none';
	f_Plot.ToolBar = 'none';
	f_Plot.Units = 'Normalized';
	f_Plot.Position = [.1 .1 .5 .4];

	ax_X = subplot(311); % 分别为 角度, 角速度, 角加速度 的坐标轴句柄
	ax_dX = subplot(312);
	ax_d2X = subplot(313);

	plot(ax_X, theta0 + omega*tdata, xdata);
	xticks(ax_X, 0:pi:floor(omega*t(end) + theta0));
	xtickformat(ax_X, '%.2f');
	ylabel(ax_X, '活塞位移 m', 'FontWeight','bold');
	ylim('auto');

	plot(ax_dX, theta0 + omega*tdata(3:end), diff(xdata(2:end),1));
	ylabel(ax_dX, '速度 m\cdot s^{-1}', 'FontWeight','bold');
	ylim('auto');

	plot(ax_d2X, theta0 + omega*tdata(3:end-1), diff(xdata(2:end),2));
	xlabel('主动曲柄转角 rad');
	ylabel(ax_d2X, '加速度 m\cdot s^{-2}', 'FontWeight','bold');
	ylim('auto');
end

function figDelete(~,~)
	EXIT = true;
	try
		close(2); % 如存在绘图窗口, 一并关闭
		disp('仿真被用户关闭');
	catch
	end
end

end
