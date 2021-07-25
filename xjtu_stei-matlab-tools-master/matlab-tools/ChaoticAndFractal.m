%% ChaoticAndFractal
%  Script by adqeor@XJTU
%  混沌, 分形
%  为方便可视化实验和效果调试, 计算和绘图尽量分开; 没有标题的节是上节的绘图实现

%% Logistic 混沌映射
%  X[n+1] = mu * X[n] * (1 - X[n]), mu 0-4, X 0-1
%  以一定的 X[0] 开始迭代若干次, mu 为横坐标, X 为纵坐标绘图

muL = 2.5; % 0-2 是平凡的收敛到直线, 建议从 2.5 开始
muU = 4;
muStep = .005;
muArr = muL:muStep:muU;
muCount = length(muArr);

X = zeros(maxIter, muCount);
X(1,:) = .5;

maxIter = 200;
dispInit = floor(.6*maxIter);
% 分叉图应该是收敛点的作图, 但收敛判定比较麻烦, 于是跳过前若干个震荡值,
% 剩下的无论收敛与否一律绘制. 改变此值, 观察图形变化

for muIndex = 1:muCount
	for iter = 2:maxIter
		X(iter, muIndex) = muArr(muIndex) * ...
		X(iter-1, muIndex) * (1 - X(iter-1, muIndex));
	end
end
%%
f = figure; ax = axes(f);
plot(ax, muArr, X(dispInit:end,:), '.'); % 比较 'k.' 和 '.'
xlabel(ax, '\mu'); ylabel('x');
ax.Color = [0.8706    0.9333    0.8471];

%% 姜饼人
%  Inspired by BV1uy4y1S7UG@bilibili
%  
%  给定 X[0], Y[0], 进行若干次如下迭代, 构建 X Y 序列并作图:
%  - X[n+1] = 1 - Y[n] + abs(X[n])
%  - Y[n+1] = X[n]

iterCount = 1e4; % 迭代次数, 即一张图绘制的点数

X = zeros(iterCount, 1); % 大的向量最好预先确定尺度并分配空间
Y = zeros(iterCount, 1); % 改变尺寸的开销相当可观

X(1) = 1;
Y(1) = -0.2;
% 这种迭代的傻算, 建议用 C 语言编程计算后导入
% 或者用 MATLAB Online, 迫害服务器
for iter = 1:iterCount-1 
	X(iter+1) = 1 - Y(iter) + abs(X(iter));
	Y(iter+1) = X(iter);
end

scatter(X, Y, '.');

%% 姜饼人 - 动图

rng(0); % 实验用, 初始化随机数核心至定值, 可复现

imgCount = 7;		% 帧数
iterCount = 1e3;	% 每帧迭代次数(点数)

X = zeros(iterCount, 1);
Y = zeros(iterCount, 1);

s = scatter(X, Y, '.');
t = title('0');

for img = 1:imgCount
	X(1) = randn(1,1);
	Y(1) = randn(1,1);
	for iter=1:iterCount-1
		X(iter+1) = 1 - Y(iter) + abs(X(iter));
		Y(iter+1) = X(iter);
	end
	s.XData = X; s.YData = Y;
	t.String = sprintf('%d  x_0=%+03.2f, y_0=%+03.2f',img, X(1), Y(1));
	drawnow limitrate;
	pause(0.5);
end

%% Fractal - Julia Set
%  进行 z = z^2 + C 迭代而不发散的 z 的集合
%  剧透:
%  下面的两个 Variant 的性能逐步提高. 第一个可视化实现的速度实在太慢, 只作为展示.
%  C 是 Julia 集的参数, 请在 Variant#2 中改变它的取值, 观察图形的变化.

c = -.82 + .1*1j;

pointCount = 1e4; % 参与试验的 z 的个数
testMaxIter = 20; % 每个点迭代 testMaxIter 次后判断半径是否大于 rThreshold
rThreshold = 10;
% 大于此值即认为发散. 这是很粗略的收敛判定, 
% 但考虑到测试点多半发散的很猛, 一点杂散也是可以接受的
% 另外, https://julialang.org/learning/code-examples/ last visit: 2021 May
% 也使用了类似的 threshold 判定; 使用的值是 2

figure; ax = axes;
hold on; axis equal;
for point = 1:pointCount
	z_test = randn(1,1) + randn(1,1)*1j;
	z = z_test; % zTest 保存迭代初值, z 参与实际迭代
	
	%  下图所示的'紧凑型'写法适用于 for, if, while 等. 不推荐, 可能影响可读性.
	for iter = 1:testMaxIter-1, z = z.^2 + c; end
	if abs(z) < rThreshold, plot(ax, real(z_test), imag(z_test), '.'); end
	% 不指定颜色, 用 lines 颜色图, 有点像甜点...
end
hold off;
% 像这样不捕捉句柄的绘图, 一定要闭包: 有借有还.

%% Fractal - Julia Set - Variant#1
%  由于 z 是被最终绘制的目标, z 不应该随机生成, 而是在矩阵格点上进行扫描
%  出图速度, 精度明显比上面优秀

c = -.82 + .2*1j;

zRealL = -2; zRealU = -zRealL;
zImagL = -1; zImagU = -zImagL;
dzReal = .01;
dzImag = .01;

testMaxIter = 20;
rThreshold = 10;

data = [];		% 先爆算, 而后集中画图

for zReal = zRealL:dzReal:zRealU
	for zImag = zImagL:dzImag:zImagU
		z = zReal + 1j*zImag;
		z_ = z; % z_ 保留原值, z 进行迭代
		for iter = 1:testMaxIter-1
			z = z.^2 + c;
			if abs(z) > rThreshold, break; end % 如果已经跑飞, 就不再继续算
		end
		if abs(z) < rThreshold, data = [data; [real(z_), imag(z_)]]; end
	end
end

f = figure; ax = axes(f);
scatter(ax, data(:,1), data(:,2), '.');

%% Fractal - Julia Set - Variant#1.5
%  使用假彩色着色. 每一个点最多迭代若干次;
%  在哪一次开始跑出范围就记录次数, 作为着色依据.

c = -.82 + .2*1j;

zRealL = -2; zRealU = -zRealL;
zImagL = -9/8; zImagU = -zImagL;
ppi = 50; % 复平面步进单位长度对应的像素数
dzReal = 1/ppi; dzImag = 1/ppi; % 单像素步进
xPixelCount = floor(ppi*(zRealU-zRealL)); % 横纵像素数
yPixelCount = floor(ppi*(zImagU-zImagL));

testMaxIter = 40;
rThreshold = 10;

xData = zeros(1, xPixelCount * yPixelCount);
yData = zeros(1, xPixelCount * yPixelCount);
cData = zeros(1, xPixelCount * yPixelCount);

for x = 1:xPixelCount
	for y = 1:yPixelCount
		z = (x*dzReal+zRealL) + 1j*(y*dzImag+zImagL);
		z_ = z; % z_ 保留原值, z 进行迭代
		for iter = 1:testMaxIter-1
			z = z.^2 + c;
			if abs(z) > rThreshold
				n = (x-1) * yPixelCount + y;
				xData(n) = real(z_);
				yData(n) = imag(z_);
				cData(n) = iter;
				break;
			end
		end
	end
end

f = figure; ax = axes(f);
colormap('copper');
scatter(ax, xData, yData, [], cData, '.');
% scatter 给定着色矢量后会自动缩放并用 colormap 对应的着色

%% Fractal - Julia Set - Variant#1.6
%  既然是固定步进, 那么就没有必要存储 x y 坐标, 只需在二维矩阵存储色彩值

c = -.82 + .2*1j;

zRealL = -4; zRealU = -zRealL;
zImagL = -9/4; zImagU = -zImagL;
ppi = 150; 
dzReal = 1/ppi; dzImag = 1/ppi;
xPixelCount = floor(ppi*(zRealU-zRealL));
yPixelCount = floor(ppi*(zImagU-zImagL));

testMaxIter = 20;		% No more than 255 if specified 'uint8' below
rThreshold = 10;

cData = zeros(xPixelCount, yPixelCount, 'uint8');

for x = 1:xPixelCount
	for y = 1:yPixelCount
		z = (x*dzReal+zRealL) + 1j*(y*dzImag+zImagL);
		z_ = z; % z_ 保留原值, z 进行迭代
		for iter = 1:testMaxIter-1
			z = z.^2 + c;
			if abs(z) > rThreshold
				cData(x, y) = iter;
				break;
			end
		end
	end
end

f = figure; ax = axes(f);
colormap('pink');
imagesc(cData');
ax.XTick = []; % 属性要在 imagesc 之后指定
ax.YTick = [];

%% Fractal - Julia Set - Variant#2
%  使用布尔型矩阵存储格点上信息, 再将矩阵作为图片显示
%  速度明显比 Variant#1 使用 MATLAB 对象逐点绘图快

c = -.82 + .2*1j;

zRealL = -2; zRealU = -zRealL;
zImagL = -1; zImagU = -zImagL;
ppi = 250; % 复平面步进单位长度对应的像素数
dzReal = 1/ppi; dzImag = 1/ppi; % 单像素步进
xPixelCount = floor(ppi*(zRealU-zRealL)); % 横纵像素数
yPixelCount = floor(ppi*(zImagU-zImagL));
img = zeros(xPixelCount, yPixelCount, 'logical');
% 指定数据类型, logical 或 uint8 这些占据空间小的. 默认的 double 再此略显臃肿
% 用 uint8, 数值应写成 uint8(255). 参见 image 文档, ImagePlayground.m

testMaxIter = 20;
rThreshold = 10;

for x = 1:xPixelCount
	for y = 1:yPixelCount
		z = (x*dzReal+zRealL) + 1j*(y*dzImag+zImagL); % 由像素偏移得到复平面内位置
		z = z; % z_ 参与迭代测试, z 保留原值
		for iter = 1:testMaxIter-1
			z = z.^2 + c;
			if abs(z) > rThreshold, break; end % 如果已经跑飞, 就不再继续算
		end
		if abs(z) < rThreshold, img(x, y)=true; end
	end
end

imshow(img);
%%% 
%  图像为什么竖起来了?
%  运算的顺序: x, y; 因而数组存储的顺序, x, y
%  但 m x n 的矩阵作为图像数据展示时, 是 m 行 n 列, x 从横轴跑到纵轴了...
%  解决方案: 在 imshow 时, 简单的进行转置即可.

%% Fractal - Julia Set - Variant#2.1
%  使用外置函数 scatter2img 将浮点列转换为离散像素点.
%  扫描时可以使用更正常的对 z 实部虚部步进, 而不必对像素步进, 再进行转换.
%  
%  注意最终出图分辨率和迭代精度需要自行匹配, 不如 Variant#2 方便
%  但如果设定分辨率比较小, 点的密度信息会通过颜色反应, 而不是阴间的黑白.

c = -.82 + .2*1j;

zRealL = -2; zRealU = -zRealL;
zImagL = -1.5; zImagU = -zImagL;
ppi = 20;
resX = 48;
resY = 36;
dzReal = 1/ppi;
dzImag = 1/ppi;

zPass = zeros(0, 2);

testPreIter = 5;
testMaxIter = 20;
rThreshold = 10;

for zReal = zRealL:dzReal:zRealU
	for zImag = zImagL:dzImag:zImagU
		z = zReal + 1j*zImag;
		for iter = 1:testPreIter, z = z.^2 + c; end % 先算几次再加入判定, 提高了 13-20% 性能
		
		for iter = 1:testMaxIter-1 % 如果已经跑飞, 就不再继续算
			z = z.^2 + c; if abs(z) > rThreshold, break; end 
		end
		
		if abs(z) < rThreshold, zPass = [zPass; zReal, zImag]; end
	end
end

img = scatter2img(zPass(:,1), zPass(:,2), resX, resY)';

imagesc(img);

%% Fractal - Mandelbrot Set
%  从 z = 0 起进行 z = z^2 + C 迭代而不发散的 C 的集合

% Mandelbrot 集的 x 分量主要在 -2 - 1, y 对称分布在 -1 - 1
cRealL = -2; cRealU = .5;
cImagL = -1.5; cImagU = 1.5;
ppi = 150; % 复平面步进单位长度对应的像素数
dzReal = 1/ppi; dzImag = 1/ppi; % 单像素步进
xPixelCount = floor(ppi*(cRealU-cRealL)); % 横纵像素数
yPixelCount = floor(ppi*(cImagU-cImagL));

img = zeros(xPixelCount, yPixelCount, 'logical');

testMaxIter = 40;
rThreshold = 50;

for x = 1:xPixelCount
	for y = 1:yPixelCount
		c = (x*dzReal+cRealL) + 1j*(y*dzImag+cImagL);
		z = c;
		for iter = 1:testMaxIter-1
			z = z.^2 + c;
			if abs(z) > rThreshold, break; end
		end
		if abs(z) < rThreshold, img(x, y)=true; end
	end
end

imshow(img');

%% 数字迭代
%  Inspired by 湍鉴, 上海交通大学出版社, 2015, pp.67
%  从一个数开始, X_{n+1} = 2*X_{n}; 每次迭代只取小数部分
%  由于有限字长效应, 以 0.707070 开始时, 原文中 17 次迭代后回归并未出现.
%  有一个解决方法: 如果输入位数有限, 可以每次迭代后删除位数之后的尾数

clc;
format long; format compact;

x = double(0.91);

iterCount = 80;
xList = zeros(1, iterCount, 'like', x);

for iter = 1:iterCount
	x = mod(2 * x, 2);
	xList(iter) = x;
	fprintf('%d\t%.6f\n', iter, x);
end

f = figure; ax = axes(f);
imagesc(xList);
ax.YTick = [];

%% 洛伦兹模型
%  参考 数值分析与科学计算, 科学出版社, 2011, pp.389

sigma = 10;
rho = 28;
beta = 8/3;

lorenz = @(~,x) [-beta*x(1)+x(2)*x(3); -sigma*(x(2)-x(3)); -x(1)*x(2)+rho*x(2)-x(3)];

x0 = [0 0 1e-3]; tSpan = 100;

% 关于 option 的更多属性, 参考 Sim_Pendulum.m
options = odeset('Refine', 10, 'AbsTol',1e-3, ... 	% 绝对误差. 本例中不能太大, 否则解是错误的.
		'RelTol',1e-4, 'Stats','on'); %'OutputFcn',@odephas3, ...);
	
[t, x] = ode45(lorenz, [0 tSpan], x0, options);
plot(t, x);

%% 洛伦兹模型-相空间
f = figure; ax = axes(f);
plot3(ax, x(:,1),x(:,2),x(:,3), 'w-');
xlabel(ax, 'X');
ylabel(ax, 'dX/dt');
zlabel(ax, 'd2X/dt2');
% ax.Color = [0.8706    0.9333    0.8471];
ax.Color = .4*[1 1 1];
plot3(ax, x(:,1), x(:,2), x(:,3), '-');

%% 洛伦兹模型-相空间动态
%  also try: comet3(x(:,1), x(:,2), x(:,3));

f = figure; ax = axes(f);
plot3(ax, x(1,1), x(1,2), x(1,3), 'o');
ax.NextPlot = 'add';
xlabel(ax, 'X');
ylabel(ax, 'dX/dt');
zlabel(ax, 'd2X/dt2');
ax.Color = [0.8706    0.9333    0.8471]; % .2*[1 1 1]; % 

idxCount = length(t);
%idxStep = 10;

for idx = 2:idxCount-1
	plot3(ax, x(idx:idx+1,1), x(idx:idx+1,2), x(idx:idx+1,3), 'k-');
	ax.Title.String = sprintf('t=%.1f', t(idx));
	drawnow limitrate;
end

%% IFS - Barnsley Fern 巴恩斯利蕨
%  source: https://blog.csdn.net/weixin_42943114/article/details/87552879
%  未完待续
%  K = [a b; c d]; 
%  H = [e; f];
%  X[n+1] = K * X[n] + H

iterCount = 100;

X = zeros(iterCount, 2);
X(1,:) = [-1; .3];

K = [.1 .2; .3 .4]; % K = K ./ max(abs(K));
H = [-5; 6]; H = H ./ max(abs(H));

for iter = 1:iterCount-1 
	X(iter+1,:) = (K * X(iter,:)' + H)';
end

scatter(X(:,1), X(:,2));
