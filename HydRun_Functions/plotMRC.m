function [h, lh] = plotMRC(MRC, rlimb_norm)
%Plot Master Recession Curve
%   [h, lh] = plotMRC(MRC, rlimb_norm) plots master recession curve together 
%   with the normalized recession limbs. This function takes the output 
%   from 'generalizerecession.m' as inputs.
%
%   'h': the handle of axis. 
%   'lh': contains the handles of regular recession line and MRC line 
%   (useful for set legend). 

    nEvent = length(rlimb_norm);
    
    h = axes(); 
    hold on 
    for i = 1:nEvent
        rl = rlimb_norm{i}; 
        lh(1) = plot(rl(:, 1), rl(:, 2), 'color', [0.7, 0.7, 0.7]); 
    end

    lh(2) = plot(MRC(:, 1), MRC(:, 2), 'b', 'linewidth', 1.2); 
    set(gca, 'xlim', [MRC(1, 1), MRC(end, 1)], 'ylim', [0, 1]); 
    xlabel('Hours', 'FontSize', 14); 
    ylabel('Normalized Discharge', 'FontSize', 14); 
    legend([lh(1), lh(2)], 'Individual Recession', 'MRC')
    hold off

end

