%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PCA before withening the EMG signal

% Input: 
% signal: row-wise signal

% Output:
%   E = full matrix E whose columns are the corresponding eigenvectors
%   D = diagonal matrix D of eigenvalues EIG(A) produces a diagonal matrix D of eigenvalues  
%   covarianceMatrix*E = E*D

% eigenvalue decomposition performed with a regularization factor fixed
% to the average of the smallest half of the eigenvalues of the covariance matrix
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [E, D] = pcaesig(signal)

% Calculate PCA
% Calculate the covariance matrix.
covarianceMatrix = cov(signal', 1);
[E, D] = eig(covarianceMatrix);

% Sort the eigenvalues - decending.
eigenvalues = sort(diag(D),'descend');
rankTolerance = mean(eigenvalues((length(eigenvalues)/2):end));
if rankTolerance < 0
    rankTolerance = 0;
end

maxLastEig = sum(diag(D) > rankTolerance);
if maxLastEig < size(signal, 1)
  lowerLimitValue = (eigenvalues(maxLastEig) + eigenvalues(maxLastEig + 1)) / 2;
end

% Select the colums which correspond to the desired range
% of eigenvalues.
E = E(:,diag(D) > lowerLimitValue);
D = D(diag(D) > lowerLimitValue, diag(D) > lowerLimitValue);