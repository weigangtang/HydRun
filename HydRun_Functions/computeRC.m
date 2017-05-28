function [RC, NRMSE, rlimb, sim] = computeRC(runoffEvent, peak_choice)
%Compute recession constant for a given runoff event (using 'lsqcurvefit')
%   [RC, NRMSE, rlimb, sim] = computeRC(runoffEvent, peak_choice) returns 
%   the recession constant (RC), NRMSE, recession limb segment (rlimb), and
%   simulated recession limb (sim) for an given runoff event (runoffEvent).
%   'lsqcurvefit' function is applied to fit recession limb with an 
%   exponential equation. 
%  
%   RC: recession constant
%   NRMSE: normalized root mean square, representing the goodness of fit
%   rlimb: cut-out recession limb
%   sim: simulated recession limb using exponential equation 
%   runoffEvent: runoff event, a segment of time series
%   peak_choice (optional): determin the start of recession limb. 'last'
%   (default option) cuts the recession limb from the last peak; 'highest'
%   cuts the recession limb from the highest peak. This parameter is useful
%   for multi-peak events. 
%   
%   Note: this function does not need ezyfit package anymore. 

    if nargin < 2, peak_choice = 'last'; end

    %Clip out recession limb
    switch peak_choice
        case 'last'
            hy = smoothcurve(runoffEvent(:, 2), 4);  
            tp = findTP(hy); % find turing point
            iPeak = tp(tp(:, 2) == 1, 1); 
            rlimb = runoffEvent(iPeak(end):end, :); 
            [~, pidx] = max(rlimb(:, 2)); % identify the max of the recession limb
            rlimb = rlimb(pidx:end, :); % refine recession limb
        
        case 'highest'
            [~, iPeak] = max(runoffEvent(:, 2)); 
            rlimb = runoffEvent(iPeak:end, :);  
    end 
    
    % Remove zero from end of recession limb. 
    % (This is because some fitting function can't handle curve ends with a zero.)
    while(rlimb(end, 2) == 0),  rlimb = rlimb(1:end-1, :); end     
    
    x = (rlimb(:, 1) - rlimb(1, 1)) * 24; 
    y = rlimb(:, 2); 
    
    % Define an exponential function
    myfun = @(p, x) p(1) * exp(p(2) * x); 
    % Fit recession limb with exponential equation
    opts = optimset('Display','off'); % hide the warning message
    coef = lsqcurvefit(myfun, [0, 0], x, y, [], [], opts); 
    y1 = myfun(coef, x);  
    
    NRMSE= rms(y-y1)/(max(y) - min(y));
    RC = -1/coef(2); 
    sim = [rlimb(:, 1), y1]; 
    
end

