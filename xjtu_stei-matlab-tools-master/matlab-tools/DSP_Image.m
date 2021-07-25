%% ImagePlayground.m
%  Script by adqeor@XJTU
%  图像简单处理实验. 
%  
%%% History:
%  7 Feb. 2021:
%  建立文件, 实现图像读写, rgb hsv 分量转化和显示;
%  建立文档;
%%% 图像基础知识
%  最基本的图像以矩阵的形式存储. 记矩阵为 X, 则 X(12, 345) 表示图片在 x=12, y=345 处像素的颜色.
%  颜色有多种表示方法. (色彩空间)
%  常用的有 RGB(红, 绿, 蓝), HSI(色度, 饱和度, 亮度), YUV(亮度, 色度参数), CMY(青, 品红, 黄)
%  因而上述 X(12, 345) 是有三个元素的数组, 数值取决于色彩空间的编制方案.
%  
%  HSI 色彩空间的 色度, 饱和度, 亮度 三个分量间具有最小的耦合.
%  由于颜色本质上是复色光的功率谱分布, 其自由度是无限的; 而常见的 RGB 使用三个分量描述, 因此出现同色异谱现象.
%  
%  HSI, HSV, HSL 色彩空间的区别 https://stackoverflow.com/questions/20853527/hsi-and-hsv-color-space
%  三者对 H 的计算均为 H = atan((sqrt(3)⋅(G-B))/2(R-G-B))
%  
%  下面所有的图像默认表示形式为 RGB, 这是因为:
%  - 人眼感知彩色的生理结构是 RGB 分量;
%  - MATLAB imread 读取图像后以 RGB 存储, 并提供了其他若干色彩空间与 RGB 互相转换的函数;
%  
%  image 对图像的处理:
%  uint8 类型, 通道饱和度从 0 - 255
%  int8 类型, 通道饱和度从 -128 - 127
%  double 类型, 通道饱和度从 0 - 1
%  
%% 实验图像导入
clc;
close all;
clear variables;

format compact;
format short;

cd 'D:'\matlab-tools'\';
% 与实验电脑的设置有关, 根据实际情况自行修改
% 或屏蔽该命令, 在 MATLAB 中手动进入 matlabTools 根目录

%%% pepp - peppers.png
pepp = imread('peppers.png');
figure(100);
image(pepp);
title('经典辣椒图像 - pepp');
fprintf('经典辣椒图像.\n具有鲜艳的红绿黄紫颜色.\n\n');

%%% pic1 - pic1.jpg
pic1 = imread('.\Material\pic1.jpg');
figure(101);
image(pic1);
title('海上作业 - pic1');
fprintf('海上作业\n海, 反光的金属管道, 太阳, 船. 高分辨率的大尺寸图片.\n\n');

%%% pic2 - pic2.jpg
pic2 = imread('.\Material\pic2.jpg');
figure(102);
image(pic2);
title('人物像 - pic2');
fprintf('人物像\n迎光全身像, 红色色调.\n');

%% 图像导出

imfinfo('.\Material\pic1.jpg')
imwrite(pic1, '.\Material\pic1_q0.jpg', 'jpg', 'Mode','lossy', 'Quality',0);
imwrite(pic1, '.\Material\pic1_q20.jpg', 'jpg', 'Mode','lossy', 'Quality',20);
imwrite(pic1, '.\Material\pic1_q60.jpg', 'jpg', 'Mode','lossy', 'Quality',60);
imwrite(pic1, '.\Material\pic1_q100.jpg', 'jpg', 'Mode','lossy', 'Quality',100);
% imwrite(pic1, '.\pic1_q101.jpg', 'jpg', 'Mode','lossless'); % Windows 10 1909 打不开
% 不讲究的, Quality 20 即可.

%% 颜色分量, 色彩空间实验
%  https://www.cnblogs.com/gkh-whu/p/10668494.html
%  伪彩色处理针对灰度图像，假彩色处理是针对彩色图像
%  真彩色: R, G, B 三波段的合成显示图，
%  假彩色: 任意非 R, G, B 波段的合成图，
%  伪彩色: 只含有一个任意波段的图像显示

%% 对 RGB 单一分量作图, 假彩色
%  直接对 R 红色分量作图, 会以当前的 colormap 着色
%  能够展示颜色通道内的强度, 但不能展示正确的颜色
%  14b 以后, 默认的 colormap 从 jet 变为 parula
%  parula 是颜色较为柔和的假彩色方案, jet 相对刺眼.

colormap('parula');
figure('Name','R 分量假彩色图', 'ToolBar','none');
image(pepp(:,:,1));

%% 对 RGB 单一分量作图, 灰度
%  将颜色图设置为 gray, 灰度图

figure('Name','R 分量灰度图', 'ToolBar','none');
colormap('parula');
image(pepp(:,:,1));

%% 对 RGB 若干分量作图, 真彩色
%  要使作图中用红色展示红色分量, 需要传入 m x n x 3 的矩阵,
%  对应位置分别为 R G B, 不显示的分量用 0 填充.

% % 第一种方法, 使用 cat 拼接各个颜色通道, 程序化水平较低.
% figure('Name','R 分量真彩色图', 'ToolBar','none');
% zfill_size = size(pepp(:,:,1));
% image( cat(3, pepp(:,:,1), zeros(zfill_size), zeros(zfill_size) ) );

% % 第二种方法, 
% 舍去第二通道, 即 R + B. 试试 [1 2 3] 和 [1], 是不是和上面的一样?
channel = [1 3];
% 初始化为 uint8 型的零矩阵, 与 pepp 数据类型相符
% image 接收 uint 或 double
peppPseudoColor = zeros(size(pepp), 'uint8');
% 仅复制需要的分量
for idx = 1:length(channel), peppPseudoColor(:,:,channel(idx)) = pepp(:,:,channel(idx)); end
figure('Name','R 分量真彩色图', 'ToolBar','none');
image( peppPseudoColor );
% 由此可抽象一个函数: pseudoColor
% 输入 m x n x 3 的 RGB 矩阵图像, 显示其一个或几个分量的真彩色图
% 见文档尾部

%% 对 HSV 若干分量作图, 灰度

pic2_hsv = rgb2hsv(pic2);

% % 直接这样画, 只能看到一团黑.
% colormap('gray');
% image(pepp_hsv(:,:,2));
% colorbar('Ticks', [0 64 128 192 256]);

% % pepp_hsv 为动态范围 0 - 1 的 double, 应该缩放为 uint8 的动态范围
f = figure(201);
axH = subplot(131);
axS = subplot(132);
axV = subplot(133);
colormap('gray');
image(axH, (pic2_hsv(:,:,1)*255));
image(axS, (pic2_hsv(:,:,2)*255));
image(axV, (pic2_hsv(:,:,3)*255));
% 由此可见 HSV 各个分量间耦合程度比较低

%% 假彩色着色
% 一些图像数据可能只有强度信息, 而不能直接可视化, 如红外图像
% 此时可以使用假彩色进行着色; 这也是 colormap 存在的意义
% 以强度高者填充颜色不同, 通常有 red hot, white hot, black hot; 还可以有伪彩色 pseudo color

%% pseudoColor
%  输入 m x n x 3 的 RGB 矩阵图像, 显示其一个或几个分量的真彩色图

function imageOut = pseudoColor(imageIn, channel)

	channelCount = size(imageIn, 3);
	
	if channelCount == 1
		warning('图像仅有一个分量');
		imageOut = imageIn;
		return;
	elseif channelCount ~= 3
		error('不能识别的通道数目');
	end
	
	% 用相同数据类型的 0 初始化所有颜色通道
	imageOut = zeros(size(imageIn), class(imageIn));
	
	% 指定的通道用原图片对应通道填充
	for idx = 1:length(channel)
		imageOut(:,:,channel(idx)) = imageIn(:,:,channel(idx));
	end
	
	image(imageOut);
end