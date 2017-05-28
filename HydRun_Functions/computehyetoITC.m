function TimeInstant = computehyetoITC(rainfallEvent)
%Identify time instants for a rainfall event
%   TimeInstant = computehyetoITC(RainfallEvent) returns a structure with
%   start, end, and centroid of a rainfall event. The start of rainfall is
%   considered at the first non-zero record, and end is at the last
%   non-zero record. 
%   
%   Note: Though this function could handle with NaNs, RainfallEvent is better 
%         to be a non-NaN array. Otherwise, the centroid could be inaccurate. 
    
    if isempty(rainfallEvent) || all(rainfallEvent(:, 2) == 0)
        TimeInstant.start = nan;
        TimeInstant.end = nan; 
        TimeInstant.centroid = nan;
        
    else
        intv = mode(diff(rainfallEvent(:, 1))); 
        startDate = rainfallEvent(find(rainfallEvent(:, 2), 1), 1); 
        endDate = rainfallEvent(find(rainfallEvent(:, 2), 1, 'last'), 1); 
        centroid = nansum(rainfallEvent(:, 1).*rainfallEvent(:, 2))/nansum(rainfallEvent(:, 2));  

        TimeInstant.start = startDate - intv;
        TimeInstant.end = endDate; 
        TimeInstant.centroid = centroid - intv/2;
    end


end

