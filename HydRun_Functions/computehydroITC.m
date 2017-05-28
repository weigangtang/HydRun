function TimeInstant = computehydroITC(runoffEvent)
%Identify time instants for a runoff event
%   TimeInstant = computehydroITC(RunoffEvent) returns a structure with
%   start, end, peak, and centroid of a runoff event. 
%   
%   Note: 1) RunoffEvent is required to be a non-NaN array. Otherwise, the
%            centroid will certainly be a NaN. 
%         2) For a multiple-peak event, the peak is refered to as the 
%            highest one. 
  
    % Find the highest peak
    [~, iPeak] = max(runoffEvent(:, 2));
    
    % Identify the time instants for runoff event
    TimeInstant.start = runoffEvent(1, 1); 
    TimeInstant.end = runoffEvent(end, 1); 
    TimeInstant.peak = runoffEvent(iPeak, 1); 
    TimeInstant.centroid = sum(runoffEvent(:, 1) .* runoffEvent(:, 2)) / sum(runoffEvent(:, 2)); 

end

