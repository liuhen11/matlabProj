%% Time series forcasting using LSTM
%  script by adqeor@XJTU, Mar. 2021
%  使用 LSTM (long short-term memory networks, 长-短期记忆神经网络) 进行时间序列预测
%  训练一个序列到序列映射的 LSTM 网络. 对比马尔科夫链, 它能学习(序列值的)长相期关性
%  需要 MATLAB Deep Learning Toolbox.
%  代码内容来自 MATLAB 文档: "Time Series Forecasting Using Deep Learning"
%  
%  
%  Reference:
%  
%  
%  https://intellipaat.com/blog/what-is-lstm/
%  
%  LSTM 是 RNN 循环神经网络的一种. RNN 的神经元输出不仅取决于当前输入, 还受先前输出影响. 有点 IIR 的感觉
%  
%  https://blog.csdn.net/u011060119/article/details/71082015 链接使用 MATLAB 实现了 LSTM 而不使用深度学习工具箱.

%% 数据输入和可视化
data = chickenpox_dataset;
data = [data{:}];

figure;
plot(data);
xlabel("Month");
ylabel("Cases");
title("Monthly Cases of Chickenpox");

%% 数据划分
%  前 90% 用于训练, 剩余 10% 作为验证
numTimeStepsTrain = floor(0.5*numel(data));

dataTrain = data(1:numTimeStepsTrain+1);
dataTest = data(numTimeStepsTrain+1:end);

% 观察"小样本学习"的效果
% numTimeStepsTrain = 200;
% dataTrain = data(1:numTimeStepsTrain);
% dataTest = data(numTimeStepsTrain:numTimeStepsTrain+50);
%% 数据标准化
[dataTrainStd, mu, sigma] = zscore(dataTrain);

%% 准备神经网络训练用数据
%  模式: 输入一组序列, 输出下一个数据点
%  在此基础上使用 predictAndUpdateState 获得多个预测
XTrain = dataTrainStd(1:end-1);
YTrain = dataTrainStd(2:end);

%% 定义 LSTM 网络结构
numFeatures = 1;
numResponses = 1;
numHiddenUnits = 200;

layers = [ ...
    sequenceInputLayer(numFeatures)
    lstmLayer(numHiddenUnits)
    fullyConnectedLayer(numResponses)
    regressionLayer];

options = trainingOptions('adam', ...
    'MaxEpochs',250, ...
    'GradientThreshold',1, ...
    'InitialLearnRate',0.005, ...
    'LearnRateSchedule','piecewise', ...
    'LearnRateDropPeriod',125, ...
    'LearnRateDropFactor',0.2, ...
    'Verbose',0, ...
    'Plots','training-progress');

%% LSTM 网络迭代学习
net = trainNetwork(XTrain, YTrain, layers, options);

%% 训练完成后预测未来若干步
%  对已经训练完成的, 进行序列预测的 RNN, 输入上一个观测数据就能得到新的预测值;
%  或者输入上一个预测值得到进一步预测值, 以实现多步预测.
%  RNN 的每一步预测都需要输入序列前一个值. 预测过程会同步修改内部神经元的数据.
dataTestStd = (dataTest - mu) / sigma;
XTest = dataTestStd(1:end-1);

net = predictAndUpdateState(net,XTrain);
[net,YPred] = predictAndUpdateState(net,YTrain(end));

numTimeStepsTest = numel(XTest);
for i = 2:numTimeStepsTest
    [net, YPred(i)] = predictAndUpdateState(net, YPred(i-1),'ExecutionEnvironment','cpu');
	% 单时间步预测, 在 CPU 上进行预测计算通常更快
end

%% 将预测结果从 zscore 标准化中恢复

YPred = sigma*YPred + mu;

YTest = dataTest(2:end);
rmse = rms(YPred-YTest)

%% 可视化: 在源数据集下显示预测结果
figure('Name','可视化: 在源数据集下显示预测结果');
plot(dataTrain(1:end-1));
hold on;
idx = numTimeStepsTrain:numTimeStepsTrain+numTimeStepsTest;
plot(idx, [data(numTimeStepsTrain) YPred], '.-');
hold off;
xlabel("Month");
ylabel("Cases");
title("Forecast");
legend(["Observed" "Forecast"]);

%% 可视化: 预测结果与实际值比较
figure('Name','可视化: 预测结果与实际值比较');
subplot(2,1,1);
plot(YTest);
hold on;
plot(YPred,'.-');
hold off;
legend(["Observed" "Forecast"]);
ylabel("Cases");
title("Forecast");

subplot(2,1,2);
stem(YPred - YTest);
xlabel("Month");
ylabel("Error");
title("RMSE = " + rmse);

%% 使用观测值刷新网络参数
%  之前的多步预测已经更改了网络的内部参数, 需要重置.
net = resetState(net);
net = predictAndUpdateState(net,XTrain);

YPred = [];
numTimeStepsTest = numel(XTest);
for i = 1:numTimeStepsTest
    [net,YPred(i)] = predictAndUpdateState(net,XTest(i),'ExecutionEnvironment','cpu');
end

YPred = sigma*YPred + mu;
rmse = rms(YPred-YTest);

%% 可视化: 更新参数后的预测结果与实际值比较
figure('Name','可视化: 更新参数后的预测结果与实际值比较');
subplot(2,1,1);
plot(YTest);
hold on;
plot(YPred,'.-');
hold off;
legend(["Observed" "Forecast"]);
ylabel("Cases");
title("Forecast");

subplot(2,1,2);
stem(YPred - YTest);
xlabel("Month");
ylabel("Error");
title("RMSE = " + rmse);
