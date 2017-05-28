% loading the matlab data: time series of streamflow and precip (rainfall)
load('BB_data.mat'); 

filter = 0.995; % filter coefficient for baseflow separation
PKThreshold = 0.03; % peak threshold for runoff events
ReRa = 0.1; % return ratio

% baseflow separation using digital filter method
[stormflow, baseflow] = separatebaseflow(streamflow, filter, 4); 

% extract runoff events from stormflow (baseflow-free hydrograph)
[runoffEvents, nRunoffEvent] = extractrunoff(stormflow, PKThreshold, ReRa, 0.001, 0.0001, 4); 

% plot the extracted runoff events on the hydrograph
plotrunoffevent(runoffEvents, streamflow); 

% extract the rainfall events from the time series of precipitation
[rainEvents, nRainEvent, Rain_pNA] = extractprecipevent(precip, 6); 

% match runoff events with rainfall events
n = 5; % define search window left edge; here, it is 5 hours before the start of runoff event
[RR_Events, relaTab] = matchrainfallrunoff(rainEvents, runoffEvents, n); 

% compute the time characteristics for the rainfall-runoff events
TC = batchprocessing(@computeTC, [1, 2], RR_Events(:, 1), RR_Events(:, 2)); 

% compute the event-based runoff ratio for the rainfall-runoff events
da = 3.6; % drainage area in km^2
RR = batchprocessing(@computeRR, [1, 2], RR_Events(:, 1), RR_Events(:, 2), da); 

% Recession Analysis (only need runoff events)
% compute recession constant for the runoff events
[RC, NRMSE, rlimbs, sims] = batchprocessing(@computeRC, 1, RR_Events(:, 2)); 

% compute the MRC curve
[gRC, rsq, f, MRC, rlimb_norm] = generalizerecession(rlimbs); 
% plot the MRC curve with normlized recession limbs of runoff events
plotMRC(MRC, rlimb_norm); 