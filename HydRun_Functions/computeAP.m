function [antecedentPrecip_Vol, numNA, pNA] = computeAP(precip, runoffEvent, ADay, n)
%Compute Antecendent Preciptation
%   AP = computeAP(Precip, RunoffEvent, ADay, n) returns the total amount
%   of precipitation (AP) in a pre-defined antecedent period (ADay) in day. 
%   ADay is acutally defines the left edge of search window for antecedent
%   precipiation, and n, an optional parameter with a value of 0 in default,
%   determines the right edge. 
%
%   Note: 
%   1) ADay is in day, while n is in hour.
%   2) It is suggested to be the same with the n selected for 
%   matchrianfall.m function.


    if nargin < 4, n = 0; end 

    % Set searching window
    leftEdge = runoffEvent(1, 1) - ADay; 
    rightEdge = runoffEvent(1, 1) - n/24; 

    % Calculate total preciptation in the searching window
    antecedentPrecip = precip(precip(:, 1) > leftEdge & precip(:, 1) < rightEdge, 2); 
    antecedentPrecip_Vol = nansum(antecedentPrecip); 
    numNA = sum(isnan(antecedentPrecip)); 
    pNA= numNA/length(antecedentPrecip);

end

