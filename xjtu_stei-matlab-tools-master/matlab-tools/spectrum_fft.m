%% spectrum_fft.m
%  Script by adqeor@XJTU
%  获取一个等间隔信号样本的单边FFT振幅频谱. 
%  
%  [freq, y_spectrum_amp] = spectrum_fft(y, Fs)
%  获取单端振幅谱. 
%  [freq, y_spectrum_amp] = spectrum_fft(__, 'plot', 'linear'/'dB')
%  增加绘图选项. 
%  [freq, y_spectrum_amp] = spectrum_fft(__, 'Maxs', n)
%  找出结果中最大的 n 个频率分量, 并在命令行窗口输出. 
%  
%  History
%  调整文档格式
%  27 Jan. 2021:
%  使用中位数/平均数设定绘图范围, 掩盖本底噪声, 优化对数坐标绘图; 
%  使用maxk查找最大频率分量; 
%  问题：
%  1.简单的查找最大值, 对具有一定dither的频率成分/频率精度低的样本, 会对一个峰找到多个大值; 
%  2.按照固定个数查找, 可能多找(找到噪声的几个成分)或漏找(个数被上述情况占据); 
%  26 Jan. 2021:
%  创建了函数, 实现参数解析; 
function [freq, y_spectrum_amp] = spectrum_fft(y, Fs, varargin)

	p = inputParser;
	% y 应当为向量
	addRequired(p, 'y', @(x) isvector(x) );
	% Fs 应当为正数值标量
	addRequired(p, 'Fs',@(x) isnumeric(x) && isscalar(x) && (x > 0) );
	% 可选plot参数
	addParameter(p, 'plot', false, @(x) ischar(x) || isstring(x) );
	% 可选输出若干个最大分量
	addParameter(p, 'Maxs', false, @(x) isnumeric(x) && isscalar(x) && (x > 0) );
	parse(p, y, Fs, varargin{:});

	sample_count = length(y);
	y_spectrum_amp = abs(fft(y)/sample_count); % 双侧振幅频谱
	y_spectrum_amp = y_spectrum_amp(1:floor(sample_count/2) + 1);
	y_spectrum_amp(2:end-1) = 2 .* y_spectrum_amp(2:end-1); % 单侧振幅频谱
	% 上一句等效为
	% y_spectrum_amp = 2 .* y_spectrum_amp;
	% y_spectrum_amp(1) = y_spectrum_amp(1) / 2;
	freq = (0:sample_count/2) .* (Fs/sample_count);
	
	% 可选, 找出最大的几个频率分量
	if p.Results.Maxs
		freq_component_count = p.Results.Maxs;
		[ValK, FreqIndexK] = maxk(y_spectrum_amp, freq_component_count);
		for i = 1:freq_component_count
			fprintf('%d\t%.2fHz%.8f\n', i, freq(FreqIndexK(i)), ValK(i));
		end
	end
	
	% 可选, 绘图
	if p.Results.plot
		f = figure();
		ax = axes(f);
		
		switch p.Results.plot
			case 'linear'
				p = plot(ax, freq, y_spectrum_amp);
			case {'log-lin', 'dB'}
				p = semilogy(ax, freq, y_spectrum_amp);
				
				% 纵坐标为对数值, 则控制y最小取值
				y_bounds = ylim(ax);
				if y_bounds(1) < 1e-2
					y_bounds(1) = 1e-2;
				end
				% y_bounds(1) = median(y_spectrum_amp);
				% 也可以将判断替换成这个语句
				ylim(y_bounds);
				
			case 'lin-log'
				p = semilogx(ax, freq, y_spectrum_amp);
			case 'log-log'
				p = loglog(ax, freq, y_spectrum_amp);
				
				y_bounds = ylim(ax);
				if y_bounds(1) < 1e-2
					y_bounds(1) = 1e-2;
				end
				ylim(y_bounds);
				
			otherwise
		end
		
		ax.XGrid = 'on'; ax.YGrid = 'on';
	end
	
end
