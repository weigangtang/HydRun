function [h] = plotrunoffevent(runoffEvents, HY, hasTxt)
%Plot Runoff Events on a Base Hydrograph
%   [h] = plotrunoffevent(runoffEvents, HY, hasTxt) plot runoff events (runoffEvents)
%   on a base hydrograph (HY). 
%   
%   h: the handle of the plot
%   runoffEvents: a cell array. each cell contains an runoff event (time series segment of streamflow)
%   HY: streamflow time series
%   hasTxt (optional): display event ID or not. default is False (not display).

    
    if nargin < 3, hasTxt = 0; end
    
    nEvent = length(runoffEvents); 

    h = plot(HY(:, 1), HY(:, 2), 'color', [0, 0.4470, 0.7410], 'linewidth', 1); 
    ymax = 1.05 * max(HY(:, 2));

    hold on 
    for i = 1:nEvent
        runoff = runoffEvents{i}; 
        st = runoff(1, 1); 
        ed = runoff(end, 1);

        [~, ipeak] = max(runoff(:, 2)); 
        pt = runoff(ipeak, 1); % peak time

        idx = HY(:, 1) >= st & HY(:, 1) <= ed; 
        runoff = HY(idx, :);

        plot(runoff(:, 1), runoff(:, 2), 'g', 'linewidth', 1.5); 
        plot(runoff(1, 1), runoff(1, 2), 'r.', 'markersize', 15); 
        plot(runoff(end, 1), runoff(end, 2), 'r.', 'markersize', 15);  
        
        if logical(hasTxt)
            text((2*pt/3 + ed/3), max(runoff(:, 2)), num2str(i), 'FontSize', 14, 'FontWeight', 'bold');  
        end 
        
    end 
    xlim([HY(1, 1), HY(end, 1)]); 
    ylim([0, ymax]);
    legend('streamflow', 'runoff event'); 
    hold off

end

