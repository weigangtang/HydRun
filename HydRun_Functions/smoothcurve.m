function [Y] = smoothcurve(X, Pass)
%Smooth Response Data
%
%   [Y] = smoothcurve(X, Pass) smooths the data in the column vector X
%   using a moving average filter. Result is returned in the column vector Y. 
%   The size of the moving average (window) is 3. Pass is the number of
%   filter passing through data. 
    
    if Pass > 0     
        for n = 1:Pass
            for i = 2:length(X)-1
                X(i) = (X(i-1) + 2*X(i) + X(i+1))/4;
            end 
        end         
    end 
    Y = X;
    
end

