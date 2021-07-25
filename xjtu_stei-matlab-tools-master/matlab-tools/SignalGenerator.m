%% SignalGenerator.m
%  Script by AD1394@XJTU
%  
%  测试信号发生. 

%% 衰减正弦
Fs = 2e3;
tSpan = 50e-3;
t = 0:1/Fs:tSpan;

f = 400;
tau = .05;
y = sin(2*pi*f*t) .* exp(-t ./ tau);

%% 正弦混合加噪
Fs = 4e3;
tSpan = 50e-3;
t = 0:1/Fs:tSpan;

amp  = [10	8	5	2];
freq = [1	2	3	4] .* 1e2;
phi0 = [0	0	0	pi/2];

y = harmonics(freq, amp, phi0, t); % 合成, 使用 harmonics.m

epsilon = 0.2;
y = y + (epsilon * rms(y)) * randn(size(y)); % 加噪
%  Communications Toolbox 中 wgn awgn 可一键加噪

%% 调制
%  使用 modulate 函数实现
Fs = 20e3;
fCarrier = 550;		% 载波频率
fModulate = 20;		% 调制频率
tSpan = 0.4;		% 信号长度
sgn = sin(2*pi*fModulate .*(0:1/Fs:tSpan/2));

% AM 简单调制
y = modulate(sgn, fCarrier, Fs, 'am');

% AM LSB 调制
y = modulate(sgn, fCarrier, Fs, 'amssb');

%% OOK 调制
Fs = 5e3;
fCarrier = 550;		% 载波频率
fModulate = 20;		% 调制频率
duty = 80;			% 占空比, 0-100
tSpan = 0.4;		% 信号长度
epsilonW = .1;		% 调制平滑指数. 为滑窗长与键控信号周期长的比例
t = 0:1/Fs:tSpan/2;

% 硬开关
y = (square(2*pi*fModulate .* t, duty)./2 + .5) .* sin(2*pi*fCarrier .* t);

% 软开关, 边沿由滑窗均值平滑
% y = movmean(square(2*pi*fModulate .* t, duty)./2 + .5, Fs*epsilonW/fModulate) .* sin(2*pi*fCarrier .* t);

%% 啁啾, 扫频
Fs = 40e3;
tSpan = 4;
t = 0:1/Fs:tSpan;

freq1 = 10;
freq2 = 20e3;

% 线性扫频, f1 扫到 f2
% y = chirp(t, freq1, tSpan, freq2, 'linear');

% 对数扫频, f1 扫到 f2
y = chirp(t, freq1, tSpan, freq2, 'logarithmic');
