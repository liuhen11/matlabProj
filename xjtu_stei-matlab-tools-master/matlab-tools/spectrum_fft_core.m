%% 无参数解析的简版spectrum_fft
function [freq, y_spectrum_amp] = spectrum_fft_core(y, Fs)

	sample_count = length(y);
	y_spectrum_amp = abs(fft(y)/sample_count); % 双侧振幅频谱
	y_spectrum_amp = y_spectrum_amp(1:sample_count/2 + 1);
	y_spectrum_amp(2:end-1) = 2 .* y_spectrum_amp(2:end-1); % 单侧振幅频谱
	freq = (0:sample_count/2) .* (Fs/sample_count);
	
end