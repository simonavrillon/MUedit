%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% To extend the signal to reach the nb of extended channels (1000 in Negro 2016, 
% can be higher to improve the decomposition)

% Input:
% eY: row-wise emg signal
% exfactor: extension factor

% Output: 
% esample: extended signal

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function esample = extend(eY, exfactor)
    [rows_eY, cols_eY] = size(eY);
    esample = zeros(rows_eY*exfactor, cols_eY+exfactor-1);
    for m = 1:exfactor
        esample((m-1)*rows_eY+1:m*rows_eY,m:cols_eY+m-1) = eY;            
    end 
end