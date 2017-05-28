function [ initialAbst ] = computeIA( rainfallEvent, runoffEvent )
%Compute Initial Abstraction 
%   InitialAbst = computeIA(RainfallEvent, RunoffEvent) return a number of
%   initial abstraction of rainfall. Initial abstraction is defined as the
%   total amount of rainfall before runoff start. 
%   
%   The rainfall is better to a non-NaN array. Otherwise, the value of
%   initial abstraction can be inaccurate. 
    
    if ~isempty(rainfallEvent)
        initialAbst = rainfallEvent(rainfallEvent(:, 1) < runoffEvent(1, 1), 2);
        initialAbst = nansum(initialAbst); 
    else 
        initialAbst = 0; 
    end 

end

