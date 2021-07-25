%% 使用 蒙特卡洛法 计算概率的若干实例
%  by adqeor @XJTU
%  
%  MATLAB 的官方文档质量很高, 多看多练大有裨益.
%  
%  History:
%  [rev0.1.0] 4 Feb. 2021:
%  建立文档, 更改编码为 UTF-8, 重新命名;
%  3 Jul. 2020:
%  Last known archive found.
%  7 Jun. 2020:
%  Creat file.

%% 蒙特卡洛法估算圆周率
close all; clc;
N = 1e2; count = 0;

figure('name', 'Pi using Monte-Carlo');
hold on; axis equal; ezplot('x^2 + y^2 = 1', [0,1]);
rng(sum(10*clock)); % initialize random generator with seed
for i = 1:N
    x = rand; y = rand;
    if norm([x,y]) <= 1
        count = count + 1;
        plot(x,y,'Or');
    else
        plot(x,y,'Ob');
    end
end

fprintf('--------------------------\n');
fprintf('Estimated pi result: %.3f\n', 4*count/N);

%% 生日同天概率
%  求在s人中，p个人生日同天的概率
N = 1e6; count = 0;
s = 50; p = 3;
rng(sum(10*clock));

for i = 1:N
    stat = zeros(1, 365);
    for j = 1:s
        date = ceil(rand * 365);
        % Notice: why use ceil instead of floor or round?
        % For matrix indices in matlab begins from 1, not 0
        % while using floor may result in indice 0
        stat(date) = stat(date) + 1;
        if stat(date) >= p
            count = count + 1;
            break;
        end
    end
end
fprintf('--------------------------\n');
fprintf('%d人中，%d人生日同天的概率是%.5f%%\n', s, p, 100*count/N);

%% MATLAB 中随机数的生成
% rand(), 0-1均匀分布的随机数
% 用法和下面randn()基本相似

% randi(), 整数随机数
x = randi(7); %1-7的随机整数
x = randi([0, 10], 1, 7); %从[0, 10]随机找出整数，填充1x5矩阵

A = [1 2 3; 4 5 9];
x = rand(size(A));

% randn(), normal distribution 正态分布的随机数
x = randn; %单个赋值
x = randn(7); %给一个7x7阵赋值
x = randn(3,4); %给一个3x4阵赋值，以两个数为参数
x = randn([3,4]); %给一个3x4阵赋值，以向量为参数
x = randn(1, 9, 'single'); %1x9的正态随机数阵，单精度元素

% randperm(), 随机排列
x = randperm(7); %返回1-7的整数的一个排列

% randerr
% randsrc

% random

x = random('exp', 1, 9999);

% name: exp, geo, logistic, norm, 

%% nchoosek(n, k)

s = 0;
format rat;
for k = 0:15
    s = s + nchoosek(100, k) * 0.1^k * 0.9^(100-k);
end

disp(s);
%% reliability of system obeying X ~ B(n, 0.1) distribution
clc;
close all;
figure('name', 'Rate of Failure');
hold on;
N = 50;
fail_dat = zeros(1, N);

for n = 1:N % When simulating a system of n uncoupled parts,
    fail_rate = 1;
    for k = 0:(n*.2) % we allow 0 to 20% * n of parts to fail.
        fail_rate = fail_rate - nchoosek(n, k) * 0.1^k * 0.9^(n-k);
        % fail rate of a single part is 1%
        fprintf('%d-%d, ', n, k);
    end
    fprintf('%f\n', fail_rate);
    fail_dat(n) = fail_rate;
end

disp('');
set(gca, 'yscal', 'log');
% to use log scaled plot, we not necessarily usesemilogx/y / loglog
% which are all line-styled plot()
% use 'set scal' instead, which can modify x&y scale for even bar plot, etc
plot(fail_dat, 'r-o', 'LineWidth', 1.2);
plot([0 N], [.05 .05], 'b--', 'LineWidth', 2);
text(36, .07, {'criteria of', 'overall reliability'});

xlabel('System part count');
ylabel({'Rate of system failure', '(linear)'});
ylim([0, .36]);

legend({'rate of system failure'}, 'FontSize', 12);
title('System reliability versus part count');
hold off;

%% plot err of pi compute using monte method

clc;
close all;
figure('name', 'Err of pi using Monte-Carol');
hold on;

set(gca, 'xscal', 'log');
set(gca, 'yscal', 'log');

plot(monte_pi(:,1), abs(monte_pi(:,2)), 'ro', 'LineWidth', 1.2);
% plot(monte_pi_(:,1), abs(monte_pi_(:,2)), 'ro', 'LineWidth', 1.2);
xlabel({'Number of each simulation', '(in log)'}, 'FontSize', 12);
ylabel({'Deviation from pi', '(in log)'}, 'FontSize', 12);

ylim([0, 2]);

legend({'abs-err of pi, Monte-Carol'}, 'FontSize', 12);
title('Err of pi using Monte-Carol');
hold off;
