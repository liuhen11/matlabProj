%% harmonics.m
%  Function by adqeor@XJTU
%
%  y = harmonics(frequencies, amplitudes, phases, timeVect)
%  以指定的若干个频率、振幅、初始相位, 叠加形成一端正弦波形.
%  要求输入的参数均为行向量. 核心版函数不做参数检查.
%  
%  frequencies, 频率 Hz
%  amp, 振幅 1
%  phases, 初始相位 rad
%  
%  直接合成 y = amplitudes * sin(2*pi * frequencies' * timeVect + phases');
%  直接合成法会建立一个临时矩阵. 对其作用 sin 后乘振幅, 降维为向量. 可能造成内存不足
%  下面的逐个叠加没有使用向量化(在此为矩阵化?)技巧, 测试发现性能更好, 9s : 8s 附近
%
%  History:
%  9 Mar. 2021:
%  移除带有输入解析的 harmonics, harmonics_core 更名为 harmonics
function y = harmonics(frequencies, amplitudes, phases, timeVect)
	y = zeros(size(timeVect));
	for i = 1:length(frequencies)
		y = y + amplitudes(i) .* sin(2*pi * frequencies(i) .* timeVect + phases(i));
	end
end