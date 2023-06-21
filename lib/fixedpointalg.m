%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fixed point algorithm to iteratively optimize a set of weights (MU
% filter) to maximize the sparseness of the source (MU pulse train)

% Input: 
%   w = initial weigths
%   X = whitened signal
%   B = separation matrix of MU filters
%   maxiter = maximal number of iteration before convergence
%   contrastfunc = contrast function


% Output:
%   w = weigths (MU filter)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function w = fixedpointalg(w, X, B , maxiter, contrastfunc)

k = 1;
% delta(k) = 1;
delta = ones(1,maxiter);
TOL = 0.0001; % tolerance between two iterations
BBT = B * B';

switch contrastfunc
    case 'square'
        gp = @(x) 2*x;
        g = @(x) x.^2;
    case 'skew'
        gp = @(x) (2*x.^2)/3;
        g = @(x) (x.^3)/3;
    case 'logcosh'
        gp = @(x) tanh(x);
        g = @(x) log(cosh(x));
end

while delta(k) > TOL && k < maxiter
    % Update weights
    wlast = w; % Save last weights
    
    % Contrast function
    wTX = w' * X;
    A = mean(gp(wTX));
    w = X * (g(wTX')) - A * w;

%   3b: Orthogonalization
    w = w - BBT * w;

%   3c: Normalization
    w = w / norm(w);

    % Update convergence criteria
    k = k + 1;
    delta(k) = abs(w' * wlast - 1);    
end