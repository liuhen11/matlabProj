%% GrayModel
%  Script by adqeor @XJTU
%  使用GM(1,1)模型, 进行时间序列预测
%  输入等间隔采样的 x_0
%  对指数型数据更有效

clc;
close all;
fprintf('GM(1,1)模型预测\n');

%% 样本输入

% 线性增长 + 正弦
% t = 0:.5:10;
% x0 = 5 + t + sin(t);

% 简单指数增长, 带噪声
t = 2.5:.4:5;
x0 = 1 + 2*exp(.5*t) + 2*randn(size(t));

% % 两个指数增长, 带噪声
% t = 3:.3:5;
% x0 = 2*exp(.5*t) + 1*exp(.2*t) + 4*randn(size(t)) + 7;

% % 线性
% t = 0:.1:2;
% x0 = 2*t + 18 + 1*randn(size(t));

n_sampleCount = length(x0);
n_succPredict = 8;		% 希望向后预测的代数
alpha = .8;				% 生成系数 通常不小于0.5, 即最近的数据更具参考价值

if n_sampleCount < 4
    error('预测需要至少4个样本, 当前仅有%d个\n', n_sampleCount);
elseif min(x0) < 0
    error('样本值应非负, 可考虑手动增加偏置');
end

%% 级比检验, 并对不通过者做试探性偏置
bias = 0;
biasFlag = false;
biasTrialCount = 0;
biasTrialMax = 200;

while ~ratioTrial(x0 + bias, n_sampleCount)
	biasFlag = true;
	biasTrialCount = biasTrialCount + 1;
	if biasTrialCount > biasTrialMax, error('级比检验失败, %d次尝试仍未找到合适的偏置', biasTrialMax), end
	bias = mean(x0) * (1+ randn());
end

if biasFlag
	x0 = x0 + bias;
	fprintf('%d次尝试后找到偏置 %.2f 满足级比检验.\n', biasTrialCount, bias);
	disp('务必检验结果, 避免动态范围丢失');
	fprintf('参考: 差模动态范围%f, 原始共模幅度%f\n\n',max(x0)-min(x0),mean(x0));
end		

%% 系数计算

% AGO算子作用, Accumulating Generation Operation 等价于数值变上限积分
x1 = cumsum(x0);

% z1 = alpha*x1 + (1-alpha)*[0,x1(1:end-1)]; % 滑窗均值低通滤波
z1 = filter([alpha, 1-alpha], 1, x1); % 也可用 filter 函数实现
% z1 = conv(x1, [alpha, 1-alpha], 'full')(1:end-1); % conv 也可, 但需要排除最后一个元素.
% 无法索引临时数组, 因而被注释掉


Y = x0';
B = [-z1',ones(n_sampleCount,1)];
coeff = B\Y;
a = coeff(1); b = coeff(2);

%% 预测, 通过一阶差分
% x_hat_1 = (x0(1)-b/a) * exp( -a.*(1:n_succPredict+n_sampleCount) ) + b/a;
% % IAGO算符等价于数值差分, 进行零阶预测值恢复, 并对首个数据还原
% x_hat_0 = diff([0,x_hat_1]);
% x_hat_0(1) = x0(1);

x_hat_0 = (1-exp(a)) * (x0(1)-b/a) .* exp( -a.*(1:n_succPredict+n_sampleCount) ); % 也直接算出最终预测值

%% 残差检验
residual = max( abs(1-x_hat_0(1:n_sampleCount)./x0) );
fprintf('残差极大为 %.3f, ',residual);
if residual < .1
    fprintf('达到较高要求.\n');
elseif residual < .2
    fprintf('达到一般要求.\n');
else
    warning('未能达到要求.');
end

%% 极比偏差检验
ratio = x0(1:end-1) ./ x0(2:end);
ratioDeviation = max( ratio .* abs(1-(1-.5*a)/(1+.5*a)) );
fprintf('级比偏差极大为 %.3f, ',ratioDeviation);
if ratioDeviation < .1
    disp('达到较高要求.');
elseif ratioDeviation < .2
    disp('达到一般要求.');
else
    warning('未能达到要求.');
end

%% 取消偏置
if biasFlag
    x0 = x0 - bias;
    x_hat_0 = x_hat_0 - bias;
end

%% 预测结果图示
figure('Name','使用 GM(1,1) 模型的预测');
hold on;
plot(x0,'-.O', 'LineWidth',1.5);
plot(x_hat_0, '*', 'MarkerSize',8);
xlabel('代数', 'FontSize',13); % 'FontWeight','bold'
ylabel('测值', 'FontSize',13);
legend({'Observed','Predicted'}, 'FontSize',12, 'Location','best');
title('灰色预测 GM(1,1)');
hold off;

function status = ratioTrial(x, n)
	ratio = x(1:end-1) ./ x(2:end);
	status = max(ratio) < exp(2/(n+1)) && min(ratio) > exp(-2/(n+1));
end
