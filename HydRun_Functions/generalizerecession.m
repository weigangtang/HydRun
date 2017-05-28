function [RC, rsq, f, MRC, rlimb_norm] = generalizerecession(rlimbs)
%Compute Master Recession Curve (MRC)
%   [RC, rsq, f, MRC, rlimb_norm] = generalizerecession3(rlimbs) returns 
%   the recession constant of the MRC (RC), r sqare (rsq), exponential 
%   coefficients (f), an array of master recession curve (MRC), and 
%   normalized recession limbs (rlimb_norm). 'lsqcurvefit' is applied to 
%   fit the many recession limbs.
%
%   Note: for ploting MRC with recession limbs, see 'plotMSC.m'

    nEvent = length(rlimbs); 
    rlimb_norm = cell(nEvent, 1); % nornalize recession limb
    for i = 1:nEvent
        rl = rlimbs{i}; 
        x = (rl(:, 1) - rl(1, 1))*24; 
        y = rl(:, 2)/max(rl(:, 2)); 
        rlimb_norm{i} = [x, y];
    end 

    myfun = @(p, x) p(1) * exp(p(2) * x);
    all_rlimb = cell2mat(rlimb_norm); 
    
    x0 = all_rlimb(:, 1); % time vector 
    y0 = all_rlimb(:, 2); % original value
    
    % fit data with an exponential equation
    opts = optimset('Display', 'off'); % hide the warning message
    f = lsqcurvefit(myfun, [0, 0], x0, y0, [], [], opts); 
    RC = -1/f(2); % an generalized recession constant
    y1 = myfun(f, x0); % simulated value
    rsq = 1 - sum((y0 - y1).^2) / sum((y0 - mean(y0)).^2); 
    
    % create master recession curve with 500 data point
    x2 = linspace(0, max(x), 500)'; 
    y2 = myfun(f, x2); 
    MRC = [x2, y2]; 

end

