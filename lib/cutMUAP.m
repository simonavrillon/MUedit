%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Extracts cosecutive MUAPs out of signal Y 

% INPUTS:
%   MUPulses = triggering positions (in samples) for rectangular window used in extraction of MUAPs (MU firring patterns);
%   len = radius of rectangular window (window length = 2*len+1)
%   Y = single signal channel (raw vector containing a single channel of a recorded signals)
%
% OUTPUTS:
%   MUAPs = row-wise matrix of extracted MUAPs (aligned signal intervals of length 2*len+1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function MUAPs=cutMUAP(MUPulses, len, Y)
    
    MUPulses(MUPulses<(1+2*len) | MUPulses>length(Y)-1-2*len) = [];
    
    MUAPs=zeros(length(MUPulses),1+2*len);   
    if ~isempty(MUPulses)
        for k=1:length(MUPulses)
            MUAPs(k,1:1+2*len)= Y(MUPulses(k)-len:MUPulses(k)+len);
        end
    end
end