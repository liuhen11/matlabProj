# 有待实现的功能

多元线性回归 regress
逐步回归 stepwiselm
线性回归 LinearModel
fitlm
mvregress
fitnlm

geobubble
text lstm

PCA

使用 @ 进行函数调用能提高速度

- 使用 C++ 图形库绘制

- 使用 Javascript 绘制

- 动画

getframe, addframe

- MATLAB 内置函数寻踪

	MATLAB 的部分内置函数以 .m 文件的形式储存在安装目录下 toolbox 文件夹中. 其中对算法, MATLAB 技巧等的运用, 值得借鉴研究.

- spectrum\_fft.m 工具函数和 Spectrum3D.m 脚本的优化
	
	增加相位显示, 优化幅频峰值检索, 增加信噪比计算

- MATLAB 参数解析教程
	
	参数验证, 可选选项, 可选参数('名称-值'对, name-value pair).

- 词云图 wordcloud

- Java libs

- interp, resamp

	MATLAB 中很多信号是等间隔采样的. 给定信号矢量 signalVect 和采样率 Fs, 即可确定信号在开始采样后若干均匀分布的离散时间上的情况.

	将一个采样率的信号变为另一个, 成为重采样 resample. 内建的 resample 函数接收两个整数 p/q, 将采样率变为原信号的 p/q. interp 函数接收一个整数 r, 采样率变为 r 倍.

	一个技巧: 如果信号前后的采样率(之比)不是整数, 则将信号前后向量的长度之倒数比作为 p/q (向量长度必然是整数). 阅读 resample 函数的文档, 发现 resample 并非简单通过插值得到输出, 而是插值后 1.通过一个 FIR 抗混叠滤波器, 2.补偿滤波器迟滞. 上面的方法指定了(通常很大的) p, q, 对 FIR 阶数有影响.

	resample 可以对 ode 求解器输出的非等间隔采样 signalVect, timeVect 进行重采样, 变为等间隔采样信号.

	如果待求解的微分方程含有不能公式化的项(它们以一段关于 t, y, ... 变量的样本出现), ode 求解器只需要一个点处的值. 无论样本是否等间隔采样, 都可以通过 y_hat = interp1(t, y, x_hat) 得到.