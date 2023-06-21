%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Band pass filter 

% Input: 
% signal: row-wise signal
% fsamp: sampling frequency
% emgtype: 1 = surface, 2 = intra

% Output:
% filteredsignal: row-wise filtered signal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function filteredsignal = bandpassingals(signal,fsamp, emgtype)

if emgtype == 1
    [b,a] = butter(2, [20 500]/(fsamp/2)); % Bandpass Butterworth 2nd order, Cutoff 10-500Hz
    filteredsignal = filtfilt(b, a, signal.').';
else
    [b,a] = butter(3, [100 4400]/(fsamp/2)); % Bandpass Butterworth 3rd order, Cutoff 100-4400Hz
    filteredsignal = filtfilt(b, a, signal.').';
end

end