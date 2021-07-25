%% gredge.m
%  Function by adqeor@XJTU
%  阶跃边沿的缓变包络. Gradual Rising Edge
%  lim = gredge(length, 'method', params)
%  有 'linear'/'lin', 'eclipse_1_4'/'ecl_4', 'eclipse_1_2'/'ecl_2', 'log', 'exp',
%  'atan', 'sinc', 'Gaussian'/'bell' 方法.
%  在一个长度为length的1向量基础上, 上升沿从0连续升至1. 可以作为一个函数的包络, 令其在边沿强制过零, 实现软开启, 避免相位不连续.
%  
%  
%  注意：
%  1.函数形能否严格通过指定的(1,0)和(sampleCount,1)点? 
%  2.MATLAB数组下标从1开始.
%  3.函数形能否构建对称边沿? 
%  4.参数变化时是否成比例缩放? 
%  
%  History
%  调整文档格式;
%  [rev0.1.2] 31 Jan. 2021:
%  从 'GRE' Gradual Rising Edge 更名为 gredge
%  增加了简单的参数验证;
%  实现了高斯钟形函数;
%  进行备份, 并生成了核心函数文件(无注释、参数验证和解析);
%  [rev0.1.1] 26 Jan. 2021:
%  实现了1/2椭圆, 对数, 指数, sinc;
%  优化了异常输入行为, 和非整参数行为;
%  更改了生成行为, 平移了上升沿函数的自变量：即使MATLAB数组从1
%  开始, 也能构造严格过零的边沿.(前提是函数支持)
%  进一步思考：对于斜率不高的边沿, 即使第一个限幅样本不是0, 也
%  远小于1, 没有必要严格过零;而斜率高的1/4椭圆形, 则很有必要.
%  [rev0.1.0] 24 Jan. 2021:
%  创建了函数;
%  实现了线性和1/4椭圆;
function lim = gredge(length, method, params)
	
	if ~(isnumeric(length) && isscalar(length) && (length > 0))
		error('Array length must be positive numeric scalar');
	end
	
	params = floor(params); % 消除警告: 警告: 当用作索引时, 冒号运算符需要整数操作数. 
	
	lim = ones(1, length);
		% x = 0:params-1
	switch method
		case {'linear','lin'}
		% 线性: 在 params 内线性上升到1
		% y = x/p
			lim(1:params) = (0:params-1)./params;
		case {'eclipse_1_4','ecl_4'}
		% 1/4椭圆: 半纵轴=1, 半横轴=params
		% /( (x/p-1)^2+y^2=1 /)
			lim(1:params) = sqrt( 1 - ((0:params-1)./params - 1).^2);
		case {'eclipse_1_2','ecl_2'}
		% 两个1/4椭圆: 半纵轴=1/2, 半横轴=params/2 
			% /( y = .5 - sqrt(.25 - (x/p)^2)/)
			% /( y = .5 + sqrt(.25 - (x/p-1)^2)/)
			lim(1:params/2) = 0.5 - sqrt(.25 - ((1:params/2)./params).^2);
			lim(params/2:params) = .5 + sqrt(.25 - ((params/2:params)./params-1).^2);
		case 'log'
		% 对数 (1,0) -> (p,1)
			lim(1:params) = log(1:params)./log(params);
		case 'exp'
		% 反对数  (1,0) -> (p,1)
			% /( y = \frac{e^x - e}{e^p - e} /)
			% lim(1:params) = (exp(1:params) - exp(1))./(exp(params) - exp(1));
			% /( y = -.5 + .5*e^(x * ln(3) / P) /)
			lim(1:params) = exp( (0:params-1).*(log(3)/params) )./2 - .5;
			% lim(1:params) = flip(exp(-1.*(0:params-1)));
		case {'Gaussian', 'Normal', 'Norm', 'bell'}
		% 钟形函数 exp(-((x)/c)^2)
			% 归一化后, x = (0:params(1)-1)./params(1)
			% 同时, 令 sigma数 = params(2)
			% 问题：只能使用整数sigma数
			lim(1:params) = flip( exp( -((0:params(1)-1) .* (params(2)/params(1))).^2 ) );
		case 'atan'
		% 反正切 (1,0) -> (p(1), p(2))
			k*atan(x);
		case 'sinc'
		% sinc
			lim(1:params) = flip( sinc((1:params)./(params)) );
		case 'sigmoid'
		% sigmoid 函数 1/(1+e^-x)
		otherwise
		% 不指定方法则为阶跃
			return;
	end
	
end