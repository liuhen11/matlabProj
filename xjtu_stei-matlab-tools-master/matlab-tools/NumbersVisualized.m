%% NumbersVisualized
%  Script by adqeor@XJTU
%  常数可视化
%  Inspired by BV1Sz4y1U7x4 and BV1Qy4y117B7 @bilibili
%  
%  顺便展示使用 MATLAB 读取外部文本数据的方法(不建议. 这种任务建议使用 Python 完成)
%  并演示使用 .mat 文件更高效地存储数据.
%  
%  
%  History:
%  12 Feb. 2021:
%  创建文件;
%  实现 pi 的'随机游走';
%% 数据导入
%  演示过程使用的 1k+ 位的数学常数不好自己算, 使用了网络数据.
%  圆周率 pi 存储在 ./Material/pi.txt
%  欧拉常数 e 存储在 ./Material/e.txt
%  黄金分隔 phi 存储在 ./Material/phi.txt; 可另外参照 http://goldenratio.org/
%  首行为引用信息.
%  
%  如果直接导入位浮点数, 会直接丧失这么高的精度. IEEE 754 标准下的双精度浮点 double
%  仅仅具有 52 个 bit 的尾数, 即 log10(2**57) = 16 位的十进制精度(或称动态范围)
%  
%  故原始数据以文本形式处理. 使用 char 而非 string.
%  后者将字符串作为整体, 而本例中希望以单个字符形式方位 (但在 C++, string 比 char 方便多了的说)
%  操作方法参考 MATLAB 文档和网络资源: https://stackoverflow.com/questions/9195716/read-txt-file-in-matlab

'导入 pi'
piFile = fopen('./Material/pi.txt', 'rt');		% 善用 [Tab] 自动补全. 注意, 要首先进入 /matlab-tools/ 目录
piStr = textscan(piFile, '%s', 'Delimiter', '\n');% 文件里 78 个数字一列. 首行有小数点, 尾行不齐.
exitStatus = fclose(piFile)						% 释放文件资源. Python 可用简单的用 with open(...) as, 更方便.
piStr = piStr{1};			% 读到的是以 cell 组织的多个 char 数组, 一个数组代表原文件的一行
textCellSize = size(piStr)
firstElement = piStr{1}	% 第一行为引用
secondElement = piStr{2}	% 数据从第二行开始
lastElement = piStr{end}	% 最后一行不齐
piStr{2}(2) = '0';		% 移除小数点, 避免未定义行为

'导入 e'
eFile = fopen('./Material/e.txt', 'rt');
eStr = textscan(eFile, '%s', 'Delimiter', '\n');
exitStatus = fclose(piFile)
eStr = eStr{1};			% 读到的是以 cell 组织的多个 char 数组, 一个数组代表原文件的一行
textCellSize = size(eStr)
firstElement = eStr{1}	% 第一行为引用
secondElement = eStr{2}	% 数据从第二行开始
lastElement = eStr{end}	% 最后一行不齐
eStr{2}(2) = '0';		% 移除小数点, 避免未定义行为

%% Visualizing Pi with Non-random Walk
%  类似随机游走的形式进行可视化
%  在平面格点上游走, 起点 (0,0).
%  偶数: 左转步进, 奇数: 右转步进
%  这个程序的逻辑没有绘制初始点 (0,0), 但不是做题, 问题不大

clc;
close all;
format short;
format compact;

position = [0;0];
direction = [1;0];

f = figure; ax = axes; t = title('Pi');
hold on; grid on; axis equal;
set(gca, 'Color',[.4 .6 .8]*1.2);
for rowNumber = 2:15					% 从第二行开始才是数字, 画到第五行
	rowNumber, segment = piStr{rowNumber}
	for columnNumber = 1:length(segment)
		piChar = segment(columnNumber);
		
		direction = [0 -1; 1 0] * direction;					% 默认 *= i, 偶数左转
		if mod(str2num(piChar),2), direction = -direction; end	% 如果是奇数右转, *= -i, 只需将上述变号
		
		% positionNew = position + direction;						% 步进为 1
		positionNew = position + str2num(piChar) .* direction;	% 步进为当前位数值
		
		% plot(positionNew(1), positionNew(2), '.', 'MarkerSize',15); % 绘制点
		% 注意, 即使坐标缩放, 点的大小在画布里也是这么多 px
		
		line('XData',[position(1), positionNew(1)], 'YData',[position(2), positionNew(2)]); % 绘制线
		
		position = positionNew;
		
		pause(.01);
		drawnow limitrate;
	end
end

%%% 原本以为很快就能做出效果, 结果花的时间超出预料
%  最后发现是 plot([7;3]) 并不是描 (7,3) 点, 而是画 (1,7) - (2,3) 的直线
%  如此低级的错误, 简直荒唐

%% Visualizing E with Non-random Walk
%  上面程序的复制粘贴

clc;
close all;
format short;
format compact;

position = [0;0];
direction = [1;0];

f = figure; ax = axes; t = title('E');
hold on; grid on; axis equal;
set(gca, 'Color',[.4 .6 .8]*1.2);
for rowNumber = 2:15					% 从第二行开始才是数字, 画到第五行
	rowNumber, segment = eStr{rowNumber}
	for columnNumber = 1:length(segment)
		eChar = segment(columnNumber);
		
		direction = [0 -1; 1 0] * direction;					% 默认 *= i, 偶数左转
		if mod(str2double(eChar),2), direction = -direction; end	% 如果是奇数右转, *= -i, 只需将上述变号
		
		positionNew = position + direction;						% 步进为 1
		% positionNew = position + str2double(eChar) .* direction;	% 步进为当前位数值
		
		% plot(positionNew(1), positionNew(2), '.', 'MarkerSize',15); % 绘制点
		% 注意, 即使坐标缩放, 点的大小在画布里也是这么多 px
		
		line('XData',[position(1), positionNew(1)], 'YData',[position(2), positionNew(2)]); % 绘制线
		
		position = positionNew;
		
		drawnow limitrate;
	end
end

%% 素数可视化
%  素数的可视化试验：沿直线每步一格，逢素数则右转，会有一步回到原点吗？ BV1Qy4y117B7
%  文章 cv9735258@bilibili 也很值得阅读, 提出对 animatedline 对象应用 MaximunNumPoints 实现贪吃蛇效果

clc;
close all;
format short;
format compact;

position = [0;0];
direction = [1;0];

f = figure; ax = axes; t = title('Prime');
hold on; grid on; axis equal;
set(gca, 'Color',[.4 .6 .8]*1.2);

for n = 1:1000

	if isprime(n), n,direction = -[0 -1; 1 0] * direction; end	% 如是质数右转, *= -i, 将上述变号
	
	positionNew = position + direction;						% 步进为 1

	line('XData',[position(1), positionNew(1)], 'YData',[position(2), positionNew(2)]); % 绘制线

	position = positionNew;

	drawnow limitrate; % 有时会出现 ^C 停不下来的情况, 这是因为 .05s 太短了. 此时应疯狂连击 ^C.

end

%%%
%  发现 MATLAB 导出图片为 svg 格式时, 当绘图元素比较少, 才会以 svg 形式绘制; 元素多的, 就直接偷懒, 插一张 base64
%  的图片... 那我为什么不存储为 png 呢?