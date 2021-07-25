%% Adaptive Filter
%  Script by AD1394@XJTU
%  自适应滤波法的时间序列预测, 对迭代进行动态可视化
%  对具有本征周期的数据更有效
%  
%  自适应滤波就是用在学习迭代中得到系数的FIR做预测.
%  预测时, 令观测值X[n] = 对应点预测值Y[n]. 需要手动指定FIR阶数.
%  学习是 weight 滑窗每走一格学一次, 从 n_filterOrder 到 n_sampleCount 称学一轮.
%  因而, 样本靠后的数据(对当前轮数的预测)影响更高.
%  
%  数据格式:
%  时间序列的输入数据 sample 和预测 y_hat 是列向量, 权重 weight 是行向量. 如果不是, 则进行转换.
%  

%% 数据准备
clc;
close all;
fprintf('自适应滤波法的时间序列预测\n\n');

% 数据输入: 只需要一个名为 sample 的向量
t = 0:.08:2.5;
% sample = 5.*exp(-.2.*t).*sin(8.*t) + .8.*randn(size(t));

pix2 = 6.283185307179586;
sample = 2.*sin(pix2 * t) + 2.*sin(pix2 * 3.*t) + .8.*randn(size(t)) + t;

n_sampleCount = length(sample);
% 时间序列转换为列向量. 只要1行, 大概率是行向量
if size(sample, 1) == 1, sample = sample'; end

%% 可视化

f = figure('Name','自适应滤波', 'Units','normalized', 'Position',[.5 0 .5 .4]);
f.Visible = 'off'; % 绘图完成前不显示, 同时避免影响用户向命令行输入

% axData = subplot('position', [.05 .55 .9 .4]);
axData = subplot(3,1,[1 2]);
axData.NextPlot = 'add'; title(axData, '数据视图');
% axError = subplot('Position', [.05 .05 .9 .4]);
axError = subplot(3,1,3);
axError.NextPlot = 'add'; title(axError, 'SSE误差');
plot(axData, sample, '-d', 'LineWidth', 1.1, 'MarkerSize', 5);
f.Visible = 'on'; % 让用户观察数据以确定代数/FIR阶数

n_filterOrder = input('预测阶数, 建议为信号的整周期.\n过低则低通滤波, 过高则学习太少:');
n_succPredict = input('向后预测代数:');

figure(f); % 将图示窗口恢复为上层活动窗口. 如果Visible = 'off', 那么自动变为'on'

%% (可选)指定初始权重

weight = ones(1,n_filterOrder) / n_filterOrder; % 归一化, 就是让FIR的增益为0dB
k= 1/n_filterOrder; % 黑魔法的取值
atten = max(abs(sample));
atten = max(atten, 1)^2;
k = k/atten;
% 对动态范围大的数据必须这样处理，避免莫名其妙的发散

%% 通过迭代优化权重

maxIter = 50;				% 最大迭代次数
convFailCount = 0;			% 单次收敛失败记录
convWarningThreshold = 3;	% 最大收敛失败次数, 超出则步进速度减半
sampleRange = max(sample) - min(sample);
sseThreshold = n_sampleCount*(0.1 * sampleRange).^2;	% sse值预警
iterAnimPause = 0.5;		% 动态绘制的帧间暂停

y_hat = zeros(n_sampleCount + n_succPredict, 1);
y_hat(1:n_filterOrder) = sample(1:n_filterOrder);
% 预测器/滤波器需要至少 n_filterOrder 个样本, 于是前面这些点无法预测, 
% 或者说预测值就是样本实际值

err = zeros(n_sampleCount, 1); % 一个遍历轮次中, 每个预测点的预测误差
sse_log = zeros(1, maxIter); % 记录每一轮中预测误差, 为err的内积

p_yhat = plot(axData, y_hat);
legend(axData,'测量值','预测值');
fprintf('开始迭代：请查看图形窗口\nGen\tSSE\n');

iter = 1; % 根据现有数据学习第一次. 单独写出来是为了避免对数组的0号元素进行索引
for t = n_filterOrder + 1 : n_sampleCount
	y_hat(t) = weight * sample(t-1:-1:t-n_filterOrder); % FIR发挥作用
	err(t) = sample(t) - y_hat(t);
	weight = weight + 2*k*err(t).*sample(t-1:-1:t-n_filterOrder)';
end
for t = n_sampleCount + 1 : n_sampleCount + n_succPredict % 预测未来
	y_hat(t) = weight * y_hat(t-1:-1:t-n_filterOrder);
end
sse_log(1) = dot(err,err);
fprintf('%d\t%.4f\n', iter, sse_log(iter));

for iter = 2:maxIter
	
	% 其实就是卷积conv，但每卷一个就要实时更新权重 因而不能使用conv()命令. 类似于 Gauss 迭代和 Sidel 迭代的区别
	% 对既有数据的可预测部分（n_filterOrder 到 n_sampleCount）顺序遍历以完成本轮权重更新
	for t = n_filterOrder + 1 : n_sampleCount % 学习过去
		y_hat(t) = weight * sample(t-1:-1:t-n_filterOrder);
		err(t) = sample(t) - y_hat(t);
		weight = weight + 2*k*err(t).*sample(t-1:-1:t-n_filterOrder)';
	end
	
	for t = n_sampleCount + 1 : n_sampleCount + n_succPredict % 预测未来
		y_hat(t) = weight * y_hat(t-1:-1:t-n_filterOrder);
	end
	
	% 迭代计算完成, 误差核算
	sse_log(iter) = dot(err,err);
	
	% 更新可视化
	p_yhat.YData = y_hat; % set(p_yhat, 'YData', y_hat); 从MATLAB 14b开始支持f.attribute写法; set应弃用
	title(axError, sprintf('误差视图 迭代%d, SSE=%.4f', iter, sse_log(iter)));
	plot(axError, [iter-1 iter],[sse_log(iter-1) sse_log(iter)], 'LineWidth',2);
	% 可选: 'Color',cmap(4,:), 得到均一的线条颜色。否则获得彩虹色线段
	% cmap = colormap(autumn(6)); 可以指定rgb
	fprintf('%d\t%.4f\n', iter, sse_log(iter));
	drawnow limitrate;
	
	% SSE绝对值检查: 检查本次sse是否超差, 发送警告; 或足够小, 可以结束
	if sse_log(iter) > sseThreshold
		warning('SSE过大。检查数据噪声/依赖代数/学习率？');
	elseif sse_log(iter) < 0.01 * sseThreshold
		if input('SSE已经足够小, 是否结束训练? [Y/N]:', 's') == 'y'
			break;
		else
			figure(f); % 恢复绘图为活动窗口
		end
	end
	
	% SSE差分值检查: 检查sse是否下降, 不下降可能发散或过冲; 或下降很小, 可以结束
	if sse_log(iter) > sse_log(iter-1)
		convFailCount = convFailCount + 1;
		if convFailCount > convWarningThreshold
			convFailCount = 0;
			k = k/2;
			warning('k halved');
		end
	elseif sse_log(iter-1) - sse_log(iter) < 0.002 * sseThreshold
		break;
		if input('SSE变化量已经足够小, 是否结束训练? [Y/N]:', 's') == 'y'
			break;
		else
			figure(f); % 恢复绘图为活动窗口
		end
	end
	
end

fprintf('\n学习结束, 历经%d轮, 残差%.4f\n', iter, sse_log(iter));
figure(f);
