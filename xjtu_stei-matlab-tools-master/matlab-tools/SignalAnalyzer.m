%% SignalAnalyzer.m
%  Script by AD1394 @XJTU
%  
%  请先运行 SignalGenerator 中的某一节, 生成信号;
%  此脚本仅接受以 y, Fs 表征的等间距采样信号.
%  

%% 信号包络提取 - envelope 函数
%  建议使用 SignalGenerator 中 OOK 调制信号实验
%  内置 envelope 从 15b 引入. 可指定使用 Hilbert FIR 滤波/滑窗最大/滑窗RMS寻找大值

% envelope(y); % 不指定参数则寻找解析包络并绘图.

figure;
hold on;
plot(y);
plot(envelope(y, 200, 'analytic'));
plot(envelope(y, 20, 'rms'));
legend({'signal','env u', 'env rms'});

%% 信号包络提取 - 奇怪的方法
%  转自 https://www.ilovematlab.cn/thread-18145-1-1.html 并进行修改
%  想法是找到信号的极大, 极小值, 对这些点进行插值. 2003 年, 上古作品
%  极大值=导数先正后负, 因而导数符号的差分为 -2. 这种方法有缺陷, 某些点找不到

% 测试数据
t = ((1:100)/512);
T0 = 0.01; f0 = 12.7;
T1 = 0.026; f1 = 35.8;
y = exp(-T0*t) .* 5 .* sin(2*pi * f0*t) + exp(-T1*t).*4.*sin(2*pi*f1*t);

% 找到信号极大, 小值和对应索引值.
extrMaxIndex = find(diff(sign(diff(y)))==-2)+1;
extrMaxValue = y(extrMaxIndex);

extrMinIndex = find(diff(sign(diff(y)))==+2)+1;
extrMinValue = y(extrMinIndex);

% 找到最值对应的横坐标
up_x = t(extrMaxIndex);
down_x = t(extrMinIndex);

% 插值绘制曲线
plot(t, y, t(extrMaxIndex), extrMaxValue, t(extrMinIndex), extrMinValue);
% interpMethod = 'linear';
% up = interp1(up_x, extrMaxValue, t, interpMethod);
% down = interp1(down_x, extrMinValue, t,interpMethod);
% plot(t, y, t, up, t, down);

%% 傅里叶变换 - FFT
%  FFT 获得整段样本上的频率分布平均状况. 通常的情景是查看信号的振幅/相位谱

% spectrum_fft(y, Fs, 'plot','dB'); % 抽象整理为此函数

sample_count = length(y);
y_spectrum_amp = abs(fft(y)/sample_count); 					% 双侧振幅频谱
y_spectrum_amp = y_spectrum_amp(1:floor(sample_count/2) + 1);
y_spectrum_amp(2:end-1) = 2 .* y_spectrum_amp(2:end-1);		% 单侧振幅频谱
freq = (0:sample_count/2) .* (Fs/sample_count); 			% 对应点的频率

f = figure; ax = axes(f);
p = plot(ax, freq, y_spectrum_amp);
% p = semilogy(ax, freq, y_spectrum_amp);
ax.XGrid = 'on'; ax.YGrid = 'on';
% 纵坐标为对数值, 则需要控制y最小取值
% 纵坐标为线性, 该操作会造成线性纵轴不过零, 因而不利于观察
y_bounds = ylim(ax); y_bounds(1) = median(y_spectrum_amp);
ylim(y_bounds);

%  由奈奎斯特采样定理, FFT 可计算的频谱范围: 0-Fs/2
%  采样率确定后, 样本长度/样本时间决定频谱计算精度. 样本越长, 信噪比越高.
%  这是因为减少了样本窗口截断信号造成的频谱泄露.
%  使用高斯噪声, 增加采样率也能提高频谱计算信噪比
%  （高斯噪声的频谱随采样率展宽, 于是带内噪声密度减小. 类同 sigma-delta 调制器降噪技术）

%% 频谱图, 短时傅里叶变换 - STFT
%  FFT 只能给出窗口内功率密度的总体状况. 希望观察如啁啾信号(就是扫频)的功率谱密度随时间的变化, 
%  可以将样本在时间上'切段', 对每一段进行 FFT, 随后合成频率瀑布图.
%  直接切段的过程, 就是使用矩形窗函数对信号进行采样. 即对一系列加窗的原始数据进行 DCT
%  记信号为 f(t), 窗函数为 w(t), 则上述 STFT 相当于得到 Fourier(f数乘w) = 1/2pi Four(f) 卷积 Four(w)
%  我们希望得到 Four(f), 但它被 Four(w) 卷了, 就不再是它了 23333 (就会发生频率泄露
%  最理想的情况, Four(w) 是冲激函数, 卷后不变; 则...
%  https://zhuanlan.zhihu.com/p/24318554
%  涉及课程: 高等数学, 复变函数, 信号系统, 数字信号处理... 

windowLength = 2e3;
overlapRatio = 0.8;

trimLength = ceil( windowLength * (1-overlapRatio));
windowCount = ceil( length(y) / trimLength );
% 不到整数个窗口的, 末尾补齐 0 (zero-padding)
y_zpad = [y, zeros(1, (windowCount-1)*trimLength + windowLength - length(y))];

t = (0:windowCount-1) * trimLength / Fs;
freq = (0:windowLength/2) .* (Fs/windowLength);
sp = zeros(windowCount, length(freq));

for i = 0:windowCount-1
	windowSample = y_zpad(i*trimLength+1:i*trimLength+windowLength);
	[~, sp(i+1,:)] = spectrum_fft_core(windowSample, Fs);
end

waterfall(freq, t, sp); % 可视化效果更精密的, 有用 mesh
xlabel('Frequency');
ylabel('Time');
zlabel('Amp');

% % 也可以用 image
% image(sp ./ max(max(sp)) .* 255); % 见 ImagePlayground.m
% xlabel('Frequency');
% ylabel('Time');
% colorbar;

%%% 终于实现了频谱图!
%  可以观察频率随时间的变化
%  注意 zero-padding 导致最后一个样本的变化
%  注意扫频由上升到下降处的泄露
%  尝试调整窗口大小和重合率, 观察峰的高度. 高度的物理意义是什么? 功率? 能量?
%  但这样的好东西其实已经被实现了, 能一键画图那种: 

%% 功率谱, 频谱, 频谱余晖 - PSpectrum
% 在频域, 或时-频域分析信号; 后者指可以获得频率分量的强度关于时间的信息. 
% fft(x, Fs) 和 pspectrum(x, Fs) 需要等间隔样本, pspectrum(x, t) 允许非等间隔采样（通过线性插值实现）

% pspectrum(y, Fs); % 未指定输出会进行绘图. 一键频谱展示
% [p,freq,t] = pspectrum(y, fs, 'spectrogram'); % 也可以输出结果, 自行绘图

% 三种模式
figure; pspectrum(y, Fs, 'power');			% 类似FFT, 是默认模式
figure; pspectrum(y, Fs, 'spectrogram');	% 频率对时间的情况, 对样本切段后做 STFT
figure; pspectrum(y, Fs, 'persistence');	% 频域的荧光余晖

% 精度选项
% pspectrum(y, Fs, 'spectrogram', 'FrequencyResolution', 100);
% pspectrum(y, Fs, 'spectrogram', 'TimeResolution', 0.1);

%% Spectrum
% Deprecated. Use pspectrum or periodogram instead.

%% Periodogram

%% Spectrogram

%% thd
%  fft 后提取本振和若干次谐波, 计算谐波失真

thd(y, Fs); % 未指定输出参数则直接绘图

%% 相位信息
%  cross-correlation 互相关, 参考 https://www.zhihu.com/question/47989245/answer/108542003
%  必须知道参考频率才能开始计算.
%  用那个参考频率构建参考信号, 计算结果就是哪个频率的相移.
%  其他频率分量幅值很强会使计算精度下降.
%  因此可以先做 FFT, 取得几个感兴趣的频率值后手动构建参考信号, 再做互相关
%  参考信号和待测信号幅度不匹配略微影响相位精度

close all;
figure;

Fs = .4e3;
tSpan = 200e-3;
t = 0:1/Fs:tSpan;

freq = 30;
freq1 = 41;
tDelay = 1.56 / freq;

y1 = sin(2*pi*freq .* t);
y2 = sin(2*pi*freq .* (t + tDelay)) ...
	+ 8.1*sin(2*pi*freq1 .* (t + 5*tDelay));
%	+ 1.1*sin(2*pi*freq1 .* t + 5.*randn(1));
subplot(211); plot(t, [y1; y2]');
legend({'sin f*t','sin f*(t+tDelay)'});
title(sprintf('t_{delay unified} = %.5f', mod(tDelay, 1/freq)));

cor = xcorr(y1, y2, 'normalized');
tcor = -tSpan:1/Fs:tSpan;
subplot(212); plot(tcor, cor);
hold on; [maxVal, maxIndex] = max(cor);
title(sprintf('@%.3f, unified = %.5f', tcor(maxIndex), mod(tcor(maxIndex), 1/freq)));
plot(tcor(maxIndex), maxVal, 'bx', 'MarkerSize', 10, 'LineWidth', 2);

%% 正交调制解调
pwelch

%% 小波变换, 尺度图 scalogram
% cwt 函数在 16b 版本引入. wscalogram: deprecated, use cwt instead

y = load('mtlb.mat');
soundsc(y.mtlb, y.Fs);

cwt(y.mtlb, y.Fs); % 同样, 可以一键绘图

%% 常数 Q 变换 - CQT
% 常数 Q 变换类似于傅里叶变换, 但后者的频率分布为等差, 而前者为等比.
% 由于人耳听觉对频率的响应近似为对数关系(即等比, 可以参考一些乐理知识), 使用对数表示频率更合理. 即 Mel 频率
%  cqt 函数自 18a 版本引入, 自此无需自行实现.
% 

% The Constant Q Transform by Benjamin Blankertz

%% 信号恢复

ifft

