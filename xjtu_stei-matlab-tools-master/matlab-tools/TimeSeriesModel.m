%% 时间序列模型
%  Script by adqeor@XJTU
%  
%  时间序列, 是一系列等间隔采样的数据.
%  时间序列模型可以运用在经济预测, 销售预测, 预算分析, 股票市场分析, 产量预测, 工艺与质量控制,
%  库存研究, 工作量预测, 效用研究, 人口分析等领域.
%  时间序列模型通过拟合等方式, 了解数据的潜在变化趋势和周期性成分, 从而进行预测.
%  
%  由于时间序列分析方法较多, 数字信号处理/神经网络的某些技术手段也可以理解为时间序列分析, 
%  本文件作为目录, 对(广义上)时间序列的一些方法进行归档.
%  
%  TS_AdaptiveFilter.m
%  自适应滤波器进行时间序列预测. 就是训练一个 FIR 用于前向预测.
%
%  TS_GrayModel.m
%  灰色模型 GM(1,1) 进行时间序列预测.
%  
%  平稳非白序列: AR, MA, ARMA;
%  非平稳序列: 做差分平稳化, ARIMA;
%  
%  基本步骤:
%  - 平稳性检验
%    单位根检验
%    自相关图, 偏.... ACF, PACF
%    不平稳则差分, 或其他方式转换.
%  - 白噪声检验
%    是白噪声, 则停止分析, 无预测价值
%  - 计算 ACF, PACF
%  - 模型识别
%    根据 ACF, PACF 截尾, 拖尾选择
%  - 参数估计
%  - 模型检验
%  - 模型优化
%  - 模型预测
%  

%% 简单/加权移动平均法
% 只适合近期预测，且相当于低通滤波器，存在相移/滞后
% 数值受周期变动、不规则因素影响较大，不易展示发展趋势
% y[n] = a0 * x[n] + a1 * x[n-1] + ... + ak * x[n-k] 就是 FIR
% 简单移动平均法就是 a0 ... ak 相等; 要求 a0+...+ak=1, 即滤波器直流增益为 0dB

t = 0:.5:10;
y = .5.*t + 3.*sin(t).*exp(-.05.*t) + .5.*randn(size(t));

n = length(y);
n_more = 10;	% 向后预测样本数
b = [.4 .4 .2]';
n_wl = length(b); % wl = window length

y_hat = filter(b, a, y);

y_hat_ = y;

for i = 1:n_more
	y_hat_(n+i) = y_hat_(n+i-1:-1:n+i-n_wl) * b;
end

figure;
hold on;
plot(y, '-d', 'LineWidth',2);
plot(y_hat, '*', 'MarkerSize',12);
plot(y_hat_, 'o', 'MarkerSize',22);
legend({'历史数据','以历史数据检验','预测未来数据'});
hold off;

%% 一次指数平滑法
% y_(t+1) = a*y(t) + (1-a)y_(t), 使用新一期数据和旧的预测得到新数据
%  由于 y_(t+1) 与 y_(t) 有关, 使用了过去无穷远的预测值, 就成为 IIR
%  y[n] = a0 * x[n] + (a1 * x[n-1] + b1 * y[n-1]) + (a2 + b2) + ...

t = linspace(0,7,18);
y = 8.*exp(-t).*sin(t) + randn(size(t));

alpha_range = .2:.2:.8; 	% 值越大，越看重近期信息
n_more = 1; 				% 必须为1，FIR 一次只能预测1格。
% 从递推式看出，如果没有新的信息，使用预测值代替观测值，后续预测值将保持
n = length(y);
y_hat = zeros(1,n+n_more);
y_hat(1) = y(1);

figure;
hold on;
ax = gca;
plot(y, '-d', 'LineWidth', 1.5);
legend_word = cell(1,length(alpha_range)+1);
legend_word{1} = '测量数据'; legendIndex = 2;
for alpha = alpha_range
	y_hat = filter([alpha, 1-alpha], 1, y);
	plot(y_hat, '-o');
	legend_word{legendIndex} =  ['alpha = ' num2str(alpha)];
	legendIndex = legendIndex + 1;
end
legend(ax, legend_word, 'Location','best');
