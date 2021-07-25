%% AudioPlayground
%  Script by adqeor@XJTU

%% 强制限幅引发失真

close all;

t_span = 0.5;
Fs = 48e3;
t = 0:1/Fs:t_span;
f = 440;

SC = 1;
clipRatio = .19;

y = SC*sin(2*pi*f*t);

yClipped = y;
yClipped( yClipped > SC*clipRatio) = SC*clipRatio;
yClipped( yClipped < -SC*clipRatio) = -SC*clipRatio;

figure; ax1 = subplot(211); ax2 = subplot(212);
plot(ax1, t(1:1000), y(1:1000)); ylim([-SC SC]);
plot(ax2, t(1:1000), yClipped(1:1000)); ylim([-SC SC]);

% soundsc(y, Fs); % soundsc 将音频信号摆幅缩放到正负 1 后播放
% pause(t_span); % sound 和 soundsc 是非阻塞播放, 接连两个 sound 会让两段声音叠起来
% pause(t_span);
% soundsc(yClipped, Fs);


figure; pspectrum([y; yClipped]', Fs, 'power', 'FrequencyLimits', [20, 8e3] ); % MATLAB 以列向量为信号通道划分 
legend({'y','yClipped'});

% figure('Name','y'); thd(yClipped, Fs); figure('Name','yClipped'); thd(yClipped, Fs);

%% 音响共振测试程序

Fs = 40e3;
tSpan = 0.5;
t = 0:1/Fs:tSpan;

f0 = 200;
f1 = 400;
n = 20;

freqs = logspace(log10(f0), log10(f1), n);
% freqs = 12e3:.5e3:20e3;

for freq = freqs
	disp(freq);
	y = sin(2*pi*freq .* t);
	audioplayer(y, Fs).playblocking();
end

%% 扫频测试

Fs = 40e3;
tSpan = 4;
t = 0:1/Fs:tSpan;

freq1 = 200;
freq2 = 5e3;

% 线性扫频, f1 扫到 f2
y = chirp(t, freq1, tSpan, freq2, 'linear');

soundsc(y, Fs);

%% Musical_Instrument.m
% 16 Mar, 2021 合并至 AudioPlayground

Fs = 44100;

f = logspace(log10(440), log10(880), 8);

t_span = 0.22;
t = 0:1/Fs:t_span;

y = [];


for i = 1:length(f)
	y = [y, 1.2 .* note( f(i), t) .* flip( gredge(length(t), 'ecl_4', length(t)*.4) )];
end

sound(y, Fs);

function arr = note(baseFreq, timeVect)
	arr = harmonics(baseFreq*[1 2 3 4], [1 .2 .4 .05], [pi 0 0 0], timeVect);
end
