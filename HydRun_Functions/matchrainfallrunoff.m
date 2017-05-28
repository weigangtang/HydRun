function [RR_Events, relaTab] = matchrainfallrunoff(RainEvents, RunoffEvents, n)
%Match Rainfall and Runoff Events
%   [RR_Events, relaTab] = matchrainfallrunoff(RainEvents, RunoffEvents, n) 
%   returns a two-column cell array of rainfall-runoff events.
%
%   n defines the range of search window. The left edge of the winodw is n 
%       hours ahead the start of the correpsonding runoff event. 
%   RR_Events is a two-column cell array, where 1st and 2nd column contains 
%       the rainfall and runoff events, respectively. If no rainfall matches 
%       with the runoff event, the 1st column is empty []. 
%   relaTab shows the number of rainfall events associated to a runoff
%       event, and their index in 'RainEvents' cell arrey. Note: a runoff event 
%       may relates to multiple rainfall events. 


    stRainEvent = cellfun(@(x)x(1, 1), RainEvents, 'uniform', 0);
    stRainEvent = cell2mat(stRainEvent); 
    edRainEvent = cellfun(@(x)x(end, 1), RainEvents, 'uniform', 0);
    edRainEvent = cell2mat(edRainEvent); 

    nRunoffEvent = length(RunoffEvents); 

    nMRE = nan(nRunoffEvent, 1); % number of matched rainfall events
    idxMRE = nan(nRunoffEvent, 20); % index of the matched rainfall event

    RR_Events = cell(nRunoffEvent, 2); 

    for i = 1:nRunoffEvent

        runoff = RunoffEvents{i}; 
        runoffITC = computehydroITC(runoff); 

        swb = runoffITC.start - n/24; % the beginning of search window

        tmp = smoothcurve(runoff(:, 2), 2); 
        infl = findTP(tmp); 
        idxPeak = infl(infl(:, 2) == 1, 1);    
        swe = runoff(idxPeak(end), 1); % the end of search window (the last peak of runoff event)

        if i > 1
            pre_runoff = RunoffEvents{i-1}; 
            pre_runoffITC = computehydroITC(pre_runoff); 
            swb = max([runoffITC.start - n/24, pre_runoffITC.centroid]); 
        end 

        % Find the rainfall event that overlaped with the runoff events
        col_1 = sign(stRainEvent - swb) + sign(stRainEvent - swe);     
        col_2 = sign(edRainEvent - swb) + sign(edRainEvent - swe); 

        idx = col_1 == 0 | col_2 == 0 | (col_1 .* col_2) < 0; 

        tmp = find(idx); 
        nMRE(i) = length(tmp);
        if nMRE(i) > 0, idxMRE(i, 1:nMRE(i)) = tmp; end

        rainfall = RainEvents(idx); 
        rainfall = cell2mat(rainfall); 

        if ~isempty(rainfall), RR_Events(i, 1) = {rainfall}; end
        RR_Events(i, 2) = {runoff};

    end

    idxMRE = idxMRE(:, 1:max(nMRE)); 

    tmp = {}; 
    for i = 1:max(nMRE), tmp = [tmp, {['Event_', num2str(i)]}]; end
    colname = ['Runof_Index', 'Num_of_Rain_Event', tmp]; 

    runoffIdx = (1:nRunoffEvent)'; 
    relaTab = array2table([runoffIdx, nMRE, idxMRE], 'VariableNames', colname); 

end 





