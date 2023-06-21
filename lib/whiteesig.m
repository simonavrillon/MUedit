%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Withening the EMG signal

% Input: 
% signal: row-wise signal
%   E = full matrix E whose columns are the corresponding eigenvectors
%   D = diagonal matrix D of eigenvalues EIG(A) produces a diagonal matrix D of eigenvalues  
%   covarianceMatrix*E = E*D


% Output:
%   whitensignals = whitened EMG signal
%   whiteningMatrix = whitening Matrix
%   dewhiteningMatrix = dewhitening Matrix

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [whitensignals, whiteningMatrix, dewhiteningMatrix] = whiteesig(signal, E, D)

whiteningMatrix = E * inv(sqrt (D)) * E';
dewhiteningMatrix = E * sqrt (D) * E';
whitensignals =  whiteningMatrix * signal;