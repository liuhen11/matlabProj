%% Tips of MATLAB on misc. issues
% Script by AD1394
% 
% 文中关于性能提升的内容参考了知乎问题'31028195'下若干回答
% 大量参考了 MATLAB 官方文档, 不一一列举
% History:
% Feb. 2, 2021:
% Merged with misc_3.m and misc_2.m
% Jul 12, 2020:
% Created misc_2.m
% Jul. 8, 2020:
% Created misc.m

% 版本和备份命名方法：
% 版本号参考 https://semver.org/lang/zh-CN/
% 如index.m的rev0.1.1alpha，命名为index__rev0.1.1alpha.m
% 
% 一些注释规范：
% 独立行的注释推荐使用行首百分号；大段注释可以采用 %{ %}以允许折叠。
% 第一行注明文件名，其后用连续的注释内容作为帮助文档。这些内容可以使用
% help命令查看，如 'help index.m'。注意，%{ %}不会被help解析为注释。
% 第二行说明文件性质（脚本/函数），作者。
% 第三行概括文件功能。
% 其后是帮助内容，函数应描述输入、输出、特性等。脚本应使用分节功能，每个小节
% 的'标题'应进行简要描述。小节和代码段应有一个空行分隔。
% 接下来是文件历史/版本说明。
% 行首百分号与注释内容间至少有一个空格。代码段末注释的百分号前后都需要空格。

%% MATLAB 彩蛋/测试程序
% BV1ZU4y1W75h
logo
membrane
peaks
image
spy
knot
cruller
xpklein
earthmap
wrldtv
vibes
lorenz
truss
xpquad
xpsound
life
travel
xpbombs
%% 程序运行前的准备

clc;
% 清除命令行屏幕内容

clear all;
% 注意编辑器中的语法提示：clear all 可能会降低代码性能, 且通常没有必要
% clear all会清除当前工作区域的变量、函数、类等, 而通常只需要清理变量
clear;
clear variables;
clearvars;
% 上面的语句等价, 只会清理变量
clear -regexp a[\w].
% 使用正则表达式匹配变量名称, 定点清除
close all;
% 有可视化时可能需要此语句以关闭不要的图窗

%% 一行不能太长
% 通常的做法是72/80字符, Sublime Text 3, Notepad++, MATLAB编辑器等均有此功能
% 这是为了避免打印程序时, 某一行长到下一行

% 这个语句实现了一个绘图, 可方便的复制到命令行测试, 但对修改非常不利友好。不要这样写。
x = (-2*pi:.15:2*pi); figure; hold on; y1 = sin(x); subplot(2, 1, 1); plot(x, y1, 'k-', 'LineWidth', 0.7); ylabel('sin(x)'); title('sin(x)', 'FontSize', 12, 'FontWeight', 'light'); y2 = acos(cos(x)); y3 = asin(sin(x)); subplot(2, 1, 2); plot(x, y2, 'b', x, y3, 'r-.', 0, 0, 'ko', pi/2, pi/2, 'ko', pi, pi, 'ko', 'LineWidth', 2);  text(0 + .5, 0, '(0, 0)', 'FontSize', 10); text(pi/2 + .5, pi/2, '(\pi/2, \pi/2)', 'FontSize', 10); text(pi + .5, pi, '(\pi, \pi)', 'FontSize', 10); xlabel('-2\pi < x < 2\pi', 'FontAngle', 'italic'); legend({'acos・cos', 'asin・sin'}, 'FontSize', 12, 'FontWeight', 'light', 'Location', 'northwest'); legend('boxon'); title('acos・cos(x) & asin・sin(x)', 'FontSize', 12, 'FontWeight', 'light');

%% 不要吝惜缩进和空格
% 不要这样
x=zeros(1,10000); %双目运算符, 赋值等, 建议在符号左右留空格
plot(x, y1, 'k-', 'LineWidth', 0.7); %函数参数字段之间, 建议仅用逗号, 不需要加空格
yy = randn(1,5) .* randi(1,5) + sin((1:5)) .* exp(-2*(1:5)); %空格太多了

% 比较好的写法
x = zeros(1,10000);
plot(x,y1,'k-','LineWidth',0.7); % 删除多余空格, 长度大大缩短。下同。
y = randn(1,5).*randi(1,5) + sin((1:5)).*exp(-2*(1:5)); %每项间加空格, 项内可不加

% 不要这样
if a > b
compute1;
end

% 要这样
if a > b
	compute1;
end

% 如果你愿意, 可以这样
if a > b, compute1, end

%% 优先使用本地函数
% 即 Local Function, 从 16b 开始支持。
% 尽可能避免使用文件外在定义函数, 比如 fc.m 定义一个待求解的微分方程
% 如果可以, 请定义匿名函数句柄anonymous, 或行内函数inline。

% inline函数在新版本MATLAB中移除。注意编辑器中的语法提示。
f = inline('x.^5 + x - 1');
df = inline('5*x.^4 + 1');
d2f = inline('20*x.^3');

% 匿名函数是推荐的写法
f = @(x)(x.^5+x-1);

% 在绝大多数场合, 匿名函数可以直接替代inline、文件函数。此时不需要加函数句柄'@'
% 但匿名函数中不能包括if-else语句。

%% 符号函数实现的阶跃, 冲激, 开关函数

step_sgn = @(x, x_0)(sign(x - x_0)/2 + .5);
% 大于x_0时开启, 幅值为1；否则为0

pulse_sgn = @(x, x_0, delta)((sign(x - x_0)/2 - sign(x - x_0 - delta)/2)/delta);
% x_0右侧宽为delta的冲激函数

switch_sgn = @(x, x_0, width)((sign(x - x_0) - sign(x - x_0 - width))/2);
% x_0右侧延伸width区间, 幅值为1；否则为0

%% 使用符号函数, 在匿名函数中实现类似if的功能

% 请看下面的函数是如何被匿名函数实现的：
% function ret = v(x)
%     if x < 5
%         ret = 1.9
%     else
%         ret = 2.1
%     end
% end

v = @(x)(-1.9*step_sgn(x, 5) + 2.1*step_sgn(x, 5));
% 可以进一步化简, 但损失可读性, 也不利于更改

%% 优化（最小值）问题的单指令方法
% 一些优化算法已经有官方实现。
% fmin[xxx] SQP
% ga 遗传算法
% particleswarm 粒子群
% simulannealbnd 模拟退火
% 另外, 请参考 Optimization Toolbox

%% wordcloud
% 文字云图

%% geo
% 地理、地图相关
gscatter

%% 输入输出
ginput % 在图像上选点输入
msg

%% input陷阱
msg = input('SSE变化量已经足够小, 是否结束训练? [Y/N]:');
%{
一直卡在这一句, 反复输出'SSE...', 任何输入都不能改出.
msg = input('SSE变化量已经足够小, 是否结束训练? [Y/N]:', 's');
增加s参数后, 以文本模式处理输入, 即可.
%}

%% 一个语句绘制多个图形
% 如果向量是关于其自然下标的函数, 不需要时间之类的 XData
% y1, y2均为行向量, 
plot( [y1; y2; ...; yn]' );
% 自然, 对列向量y1, ..., 就是
plot( [y1  y2  ... yn] );

%% 积分
% 使用 trapz 和 cumtrapz 对离散数据集执行数值积分
% 如果数据可以用函数表达式表示, 则改用 integral、integral2 或 integral3

%% MATLAB Java Functionalities
% Java 提供了一些很好的io功能, 比如控制鼠标
% 使用Java进行MATLAB和其他语言的交流

%% GPU array, tall


%% 动态绘图
%1.
p = plot();
% 更新数据
p.YData = newData;
pause(0.05);
%2.
pause(0.05);
% 换成
drawnow limitrate; % 限制20FPS刷新率
%3.
animatedlines
addpoint
drawnow
%4. 对更新越来越慢的, 使用时间步进

%% static 静态变量
% 可以使用 persistent 声明

%% 并行计算性能比较
% 测试平台： core i9-9400 6C6T
% 跑分前使用 parpool 启动 4 个核心, 下面的并行运算使用这4个核心。
% 将下面的代码中的for 改为 parfor 即可测量 parfor 的运算时间
clear freq amp
tic
for i = 1:24
	[freq(i,:) , amp(i,:) ] = spectrum_fft_core(y, Fs);
end
toc

% 结论：
% parfor首先进行序列化, 分配内存, 而后进行计算。
% 这些预操作消耗客观的资源, 因而数据量比较小时, 不需要使用并行工具
% 作者的意见是, 如果不使用并行工具, 需要花费 9400 等级的平台超过 1 小时, 
% 才值得部署并行计算
%
% 另外, 单次数据集大小, 循环轮数, 并行进程数应匹配

% 原始数据

% length = 16e6, loop = 24
% parfor
% 21.527403	22.052112
% for
% 23.708402	23.602609	24.273839 - 任务管理器高刷新率

% length = 16e6, loop = 16
% parfor
% 15.238242	14.701056	13.986229
% for
% 14.417973	14.120883	14.181881

% length = 16e6, loop = 4
% parfor
% 4.813213	4.777788	4.687374
% for
% 3.643009	3.037938	3.153579

% length = 250e3, loop = 4
% parfor
% 0.100400	0.173708	0.179318
% for
% 0.104529	0.070114	0.050463

% length = 20e3, loop = 4
% parfor
% 1.238926	0.187212	0.162296	0.183699	0.166920
% for
% 0.053248	0.010066	0.007530	0.008649

%% Optimization Tool


%% 提高MATLAB代码性能

% 1.安装新版本的程序。简单有效。
% 如果你的MATLAB版本在15b及以前, 装最新版的吧/是我了/我太难了

% 2.MATLAB与C混合编程, MEX

% 2.5.减少语义分析, 使用pcode
pcode misc_2.m
% pcode 据称可以保护代码。其文件本身是十六进制。
% 移除注释、语义分析后，其体积大大缩小。同时适用于脚本和函数
% 作为脚本执行的p代码会在结束执行/interrupt后暴露变量名称和内容; 使用clearvars可部分解决
% 作为函数执行的p代码会在interrput后暴露本地变量名称和内容。
% 可以对变量重命名，增大逆向工程难度。

% 3.向量化计算
% 参见官方文档，写的非常详细了

% 4.GPU加速
% 大矩阵用gpuArray, 特别是在深度学习中

% 5.变量精度降级, double变single, 内存占用立即减半
% MATLAB默认使用双精度浮点double, 但在一些情形下单精度浮点提供的
% 精度和动态范围已经足够。转换为单精度浮点可以有效降低存储和计算开销。
% 据称, 如果使用GPU进行运算, 单精度浮点会有更明显的性能提升

% 6.并行计算
% parfor 替代 for

% 7.为矩阵进行内存初始化, 避免随循环改变大小

% 8.矩阵优于cell
% 处理 cell, struct 这些高级对象的开销高于数值矩阵（高于数值向量）

% 10.使用函数句柄
% 使用文件定义的函数，MATLAB会在定义的路径中寻找, 降低性能。句柄的使用可避免无用查找。
% 不用匿名函数也可(?有反对意见。有待验证)
% feval('@fun',var1, ...) % better
% fun(args) % hmmm

% 11.稀疏矩阵
% 降低存储负担, 提高计算性能

% 12.避免重复计算常数
% 1/pi, 1/e, 1/sqrt(2) 等, 在脚本初始化时计算并存储为'常量'。避免不必要的常数除法。

% 13.Run and Time, 在Profiler中揪出瓶颈

% x.
% 如果Ax=b有唯一解, 使用 x = A \ b; 而不是 x = inv(A) * b;

%% In-place 原位 内存 优化
%  https://blogs.mathworks.com/loren/2007/03/22/in-place-operations-on-data/
%  输入输出同维度, 如果可以, 在原位修改
%  减少中间变量消耗内存
%
%  fun x = funName(x)
%      x = sin(x);
%  fun y = funName(x)
%      y = sin(x);
% 
%  原位修改减少内存重分配 
%  https://undocumentedmatlab.com/articles/internal-matlab-memory-optimizations
%  https://www.mathworks.com/help/matlab/matlab_prog/avoid-unnecessary-copies-of-data.html