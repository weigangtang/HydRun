function [runoffRatio, runoffVol, precipVol] = computeRR(rainfallEvent, runoffEvent, drainageArea)
%Compute Runoff Ratio
%   [RunoffRatio, RunoffVol, PrecipVol] = computeRR(RainfallEvent, RunoffEvent, DrainageArea)
%   returns runoff ratio of a given event, and the total volume (in m^3) of
%   runoff and rainfall.
%   
%   Note: 
%   The unit of rainfall, runoff, and drainage area are important for the 
%   calculation of runoff ratio.
%   The required unit for: 
%       rainfall (mm);
%       runoff (m^3/s); 
%       drainage area (km^2). 
%   The rainfall, runoff, and drainage area must be converted into the
%   required unit before using this function. 

    

    % Calculate total volumn of runoff (in unit of m^3)
    interval = diff(runoffEvent(1:2, 1))  * 86400; 
    runoffVol = sum(runoffEvent(:, 2) * interval); 
    
    
    % Calculate total volumn of runoff (in unit of m^3)
    if ~isempty(rainfallEvent)
        precipVol = nansum(rainfallEvent(:, 2)) * drainageArea * 1000; 
    else 
        precipVol = 0; 
    end 
    
    % Calculate the runoff ratio
    runoffRatio = runoffVol/precipVol; 
    
end

