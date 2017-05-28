function [runoffEvents, nEvent] = extractrunoff(stormflow, MINDIFF, RETURNRATIO, BSLOPE, ESLOPE, SC, MINDUR, dyslp)
%Extract Runoff Events from Stormflow
%   [RunoffEvent, nEvent] = extractrunoff(stormflow, MINDIFF, RETURNRATIO,
%   BSLOPE, ESLOPE, SC, MINDUR) returns extracted runoff events in a cell
%   array (RunoffEvent) and the number of extracted events (nEvent). 
%   
%   Explanation of Input Variables
%   Stormflow: = streamflow - baseflow
%   MINDIFF: minimum difference between start (or end) and peak of runoff.
%       It ensures that the extracted runoff events always have (at least)
%       one distinct peak. 
%   RETURNRATIO: determine where runoff terminates. In this case, runoff is
%       considered terminated when declining below a dynamic threshould, A.
%       A = Fmax (Peak Discharge) * RETURNRATIO.
%   BSlope and ESlope: Beigining Slope and End Slope. They are threshoulds
%       of slope, used to cut flat head and end of the runoff event. 
%   SC: smooth coeffcient. It determine how many passes will apply on
%       stormflow. More passes result smoother hydrograph. 
%   MINDUR (optional): minimun duration. It define the minimum duration of selected 
%       runoff events, so spiky, narrow events will be ignored automatically. 
%       MINDUR's value represents the number of element, so the minimum
%       duration is actually equal to MINDUR * TimeInterval. 
%   dyslp (optional): dynamic slope threshold used to cut the flat head and
%       end of the runoff event.  

if nargin < 7, MINDUR = 0; end
if nargin < 8, dyslp = 0.001; end

RETURNCONSTANT = MINDIFF/3; 

% Step 1: Hydorgraph Smoothing
hy = stormflow;  
hy(:, 2) = smoothcurve(hy(:, 2), SC); 


% Step 2: Turning Points (TP) Identification and Extraction
% % Identify local max and min (peak and valley)
TP = findTP(hy(:, 2)); % 1st column: index; 2nd column: label (valley = 0, peak = 1)
TP(:, 3) = hy(TP(:, 1), 2); % 3rd column: discharge value

% % the first element in 'hy' array is considered a 'valley point' no matter what, 
% % if it is at a very low level (< Q_avg/10). 
if TP(1, 2) == 1 && hy(1, 2) < mean(hy(:, 2))/10, 
    TP = [[1, 0, hy(1, 2)]; TP]; 
end 
% % the last element in 'hy' array is considered a 'valley point' no matter what, 
% % if it is at a very low level (< Q_avg/10). 
if TP(end, 2) == 1 && hy(end, 2) < mean(hy(:, 2))/10, 
    TP = [TP; [size(hy, 1), 0, hy(end, 2)]]; 
end 

% % Remove incomplete event(s) at the beginning and at the end
while TP(1, 2) == 1, TP(1, :) = []; end 
while TP(end, 2) == 1, TP(end, :) = []; end 


% Step 3: Identify the Start and End Points of Runoff Event 
% % Get difference between peak and valley
TP(:, 4) = [diff(TP(:, 3)); 0]; 
% % Find out start and end points of event flows
i = 1;
c = 1; 
isComplete = 1; 
nInflect = size(TP, 1); 
while i < nInflect -1
        j = 1; 
        d = TP(i, 4) + TP(i+j, 4);
        while d > max(RETURNRATIO * max(abs(TP(i:i+j, 4))), RETURNCONSTANT)
            if i + j < nInflect - 1 
                j = j + 1; 
                d = d + TP(i+j, 4);
            else 
                isComplete = 0; 
                break
            end 
        end 
        st(c) = i; 
        ed(c) = i + j; 
        i = i + j + 1; 
        c = c + 1;   
end 

if isComplete == 0
    st = st(1:end - 1); 
    ed = ed(1:end - 1); 
end 


% Step 4: Extract Runoff Events and Put Each of Them into a Cell
nEvent = 0;
runoffEvents = {}; 
for i = 1:length(st)
    
    date = stormflow(TP(st(i), 1):TP(ed(i)+1, 1), 1); 
    event_smooth = hy(TP(st(i), 1):TP(ed(i)+1, 1), 2);
    event = stormflow(TP(st(i), 1):TP(ed(i)+1, 1), 2); 
    
    eventflow = [date, event, event_smooth]; 
    temp1 = diff(eventflow(:, 3)); 
    
    
    % % Select runoff events whose peak exceeds threshold (minDiff) 
    if max(eventflow(:, 2)) - eventflow(1, 2) > MINDIFF && max(eventflow(:, 2)) - eventflow(end, 2) > MINDIFF
        
        dyslp = dyslp * range(eventflow(:, 2)); % dynamic slope threhould
        % % Shorten runoff event by removing flat head and end 
        % % %Check slope on smoothed flow data
        while numel(temp1) > 0 && temp1(1) < min([BSLOPE, dyslp])
           eventflow = eventflow(2:end, :); 
           temp1 = temp1(2:end);
        end 
        
        while numel(temp1) > 0 && temp1(end) > -min([ESLOPE, dyslp])
            eventflow = eventflow(1:end-1, :); 
            temp1 = temp1(1:end-1);
        end 
        
        % % % Check slope on orginal flow data      
        if numel(temp1 > 0) 
            temp2 = diff(eventflow(:, 2));
            while numel(temp2) > 0 && temp2(1) <= min([BSLOPE, dyslp])
                eventflow = eventflow(2:end, :); 
                temp2 = temp2(2:end); 
            end 

            while numel(temp2) > 0 && temp2(end) >= -min([ESLOPE, dyslp])
                eventflow = eventflow(1:end-1, :); 
                temp2 = temp2(1:end-1); 
            end 
            % % Select Runoff Events whose duration exceeds threshold (minDur)
            if numel(temp2) > MINDUR 
                nEvent = nEvent + 1; 
                runoffEvents(nEvent) = {eventflow(:, 1:2)};
            end 
        end 
    end 
    
end 
runoffEvents = runoffEvents';  

end

