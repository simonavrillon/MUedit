%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% To remove the mean of the signal

% Input:
% signals: row-wise emg signal

% Output: 
% demsignals: detrended row-wise emg signal

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function demsignals = demean(signals)

Values = mean(signals,2);
demsignals = signals - Values;
