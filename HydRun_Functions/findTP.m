function [TP] = findTP(LINE)
%Identify Turning Points for a Line
%   
%   [TP] = findTP(LINE) returns an two-column array of turning points,
%   where the 1st column is the index of turning point in LINE, and the 2nd
%   column is the label for peak and valley (peak = 1, valley = 0).  
%
%   Note: LINE is supposed to be a vector (one column). 
%   This function replaces the 'findinflect.m'

    FOD = diff(LINE); % first order derivative
    sDiff = diff(sign(FOD)); % sign difference 
    idx = find(sDiff ~= 0); % find the index of the turning points

    % Turning Points (TP):
    %   1st column is the index of turing point in the orginal data (LINE)
    %   2nd the label for peak and valley
    TP(:, 1) = idx + 1; 
    TP(:, 2) = sDiff(idx); 
    TP(TP(:, 2) > 0, 2) = 0; % mark local min (valley) with 0
    TP(TP(:, 2) < 0, 2) = 1; % mark local max (peak) with 1

end


