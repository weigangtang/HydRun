function [h1, h2] = plotevent(rainfall, runoff)
%Plot rainfall-runoff event
%   [h1, h2] = plotevent(rainfall, runoff) produce a plot with rainfall and
%   runoff togther. 
%   Different with plotevent2, the start, end, and centroid of rainfall and 
%   runoff are marked as a grey dash line. 

    if isempty(rainfall)
        rainfall = runoff; 
        rainfall(:, 2) = NaN; 
    end 
    
    if isempty(runoff)
        runoff = rainfall; 
        runoff(:, 2) = NaN; 
    end
        
       
    Flow = computehydroITC(runoff); 
    Rain = computehyetoITC(rainfall); 
    
    intRain = diff(rainfall(1:2, 1)); % time interval of rainfall data
    intRunoff = diff(runoff(1:2, 1)); % time interval of runoff data
    intv = max([intRain, intRunoff]); 
    
    xmin = min([rainfall(1, 1), runoff(1, 1)])-intv;
    xmax = max([rainfall(end, 1), runoff(end, 1)])+intv;
    xlim = [xmin, xmax];
    
    % Plot Rainfall Plot
    h1 = subplot(2, 1, 1); 
    bar(rainfall(:, 1), rainfall(:, 2), 'FaceColor', [0, 0, 139/255], ...
        'EdgeColor', [30/255, 144/255, 255/255])
    
    hold on 
    
    ymax_1 = max([rainfall(:, 2); 0])+0.1; % set y upper limit for rainfall plot
    
    plot([Rain.start, Rain.start]-intRain/2, [0, ymax_1], '--', 'color', [0, 128, 128]/255);
    plot([Rain.end, Rain.end]+intRain/2, [0, ymax_1], '--', 'color', [0, 128, 128]/255);
    plot([Rain.centroid, Rain.centroid], [0, ymax_1], '--m', 'linewidth', 1.5);
    
    datetick('x', 'mmmdd')
    set(h1, 'xlim', xlim, 'ylim', [0, ymax_1])
    title(['From ', datestr(rainfall(1, 1), 'yyyy/mmm/dd'), ...
                ' To ', datestr(runoff(end, 1), 'yyyy/mmm/dd')], 'FontSize', 12, 'FontWeight', 'bold');
    ylabel('Precipitation (mm)', 'FontSize', 10); 
    hold off
    
  
    % Plot Runoff Hydrograph
    h2 = subplot(2, 1, 2); 
    plot(runoff(:, 1), runoff(:, 2), 'linewidth', 2)
    
    ymax_2 = 1.1*max(runoff(:, 2)); % set y upper limit for runoff plot
     
    hold on
    plot([Flow.start, Flow.start], [0, ymax_2], '--', 'color', [0, 128, 128]/255);
    plot([Flow.end, Flow.end], [0, ymax_2], '--', 'color', [0, 128, 128]/255);
    plot([Flow.peak, Flow.peak], [0, ymax_2], '--m'); 
    
 
    set(h2, 'xlim', xlim, 'ylim', [0, ymax_2])
    xlabel('Time', 'FontSize', 10)
    ylabel('Discharge (m^3/s)', 'FontSize', 10)
    xTick = floor(rainfall(1, 1)*24)/24:5/24:ceil(runoff(end, 1)*24)/24; 
    set(h2, 'xtick', xTick)
    datetick('x', 'HH:MM', 'keeplimits')
    
    
    hold off
    
       
    h = [h1, h2]; 
    set(h(1), 'xticklabel', []);
    pos=get(h,'position');  
    bottom = pos{2}(2); 
    top = pos{1}(2) + pos{1}(4); 
    height = (top-bottom)/3; 

    for k = 1:2
        pos{k}(4) = height*k; 
        pos{k}(2) = top - (2*k - 1) * height;
        set(h(k), 'position', pos{k}); 
    end 
   

end

