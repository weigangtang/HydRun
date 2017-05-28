function [TimeCharac]  = computeTC(rainfallEvent, runoffEvent, type)
%Compute Time Characteristic(s)
%
%   [TC] = computeTC(RainfallEvent, RunoffEvent, Type) returns a set of
%   time characteristics of a rainfall-runoff event. 
%
%   The output time characteristics include: 
%   1)T_w: rainfall duration              2)T_LR: response lag 
%   3)T_r: time of rise                   4)T_LP: lag-to-peak
%   5)T_LPC: centroid lag-to-peak         6)T_LC: centroid lag
%   7)T_b: time base (runoff duration)    8)T_c: time of concentration
%
%   This function is able to calculate ONE or ALL of these time characteristics. 
%   Type is an optional input, which is used to specify the time characteristic 
%   to be calculated. If no argument is supplied to 'Type', all time characteristics 
%   will be calculated. 
%   
%   Note: The unit of time characteristics is in hour. 

     
     rainITC = computehyetoITC(rainfallEvent); 
     runoffITC = computehydroITC(runoffEvent); 
    
     if nargin < 3
         
         TimeCharac = nan(1, 8); 
         TimeCharac(1) = rainITC.end - rainITC.start; 
         TimeCharac(2) = runoffITC.start - rainITC.start;
         TimeCharac(3) = runoffITC.peak - runoffITC.start; 
         TimeCharac(4) = runoffITC.peak - rainITC.start;
         TimeCharac(5) = runoffITC.peak - rainITC.centroid; 
         TimeCharac(6) = runoffITC.centroid - rainITC.centroid; 
         TimeCharac(7) = runoffITC.end - runoffITC.start;
         TimeCharac(8) = runoffITC.end - rainITC.end; 
         
     else 
     
         switch (type) 
             case 'w' 
                 TimeCharac = rainITC.end - rainITC.start; 
             case 'LR' 
                 TimeCharac = runoffITC.start - rainITC.start; 
             case 'r'
                 TimeCharac = runoffITC.peak - runoffITC.start; 
             case 'LP' 
                 TimeCharac = runoffITC.peak - rainITC.start; 
             case 'LPC' 
                 TimeCharac = runoffITC.peak - rainITC.centroid; 
             case 'LC'
                 TimeCharac = runoffITC.centroid - rainITC.centroid; 
             case 'b' 
                 TimeCharac = runoffITC.end - runoffITC.start; 
             case 'c'
                 TimeCharac = runoffITC.end - rainITC.end; 
             otherwise 
                 TimeCharac = NaN; 
         end 

     end 
     
     % Convert to an unit of hour
     TimeCharac = TimeCharac * 24; 

end

