function [varargout] = batchprocessing(func, iParam, varargin)
%Batch Process Cell Array with a Given Function
%   [varargout] = batchprocessing(func, iParam, varargin) process a
%   bactch of events using a designated function (func). The outputs from
%   'batchprocessing' are exactly the same with 'func'. However, instead of
%   a scalar, 'batchprocessing' return an array containing the value for
%   each event.
%   
%   func: function handle (e.g. @computeRC)
%   iParam: the sequence number of the event variable(s) in varargin (e.g. [2, 3])
%   varargin: a set of required variables for 'func'. it contains fixed
%   variables and event variables (e.g. RainfallEvents and RunoffEvents). 
%
%   Application: 
%   Many function compute event-based hydrometrics or parameter can only
%   process one event at a time. This function allow to process a cell
%   array of many events at one stop.    
%   
%   Note: 
%   1) the input event variables must be in the length. 
%   2) the length of ouput is the same with the length of input event variable


    % Put event variable together (the event variable must be in the same length
    eventVars = varargin(iParam); 
    eventVars = [eventVars{:}]; 
    
    nEvent = size(eventVars, 1); 

    vars = varargin; 

    nOut = nargout(func);
    outMat = cell(nEvent, nOut); 

    for i = 1:nEvent
        % replace the cell array of events with a single event
        vars(iParam) = eventVars(i, :);
        % compute the parameter(s) for a single event
        [outMat{i, :}] = func(vars{:}); 
    end 

    for i = 1:nOut

        tmp = outMat(:, i); 

        % identify the number of elements in each cell
        t1 = cellfun(@numel, tmp, 'uniform', 0); 
        % Does each cell contain only one element?
        t2 = cell2mat(t1); 
        t2 = t2 < 2; 
        % Criterion 1 - if each cell only has one or less element
        c1 = all(t2); 

        % Is the content in each cell numeric? 
        t3 = cellfun(@isnumeric, tmp, 'uniform', 0); 
        t3 = cell2mat(t3); 
        % Criterion 2 - if the content in each cell is numeric
        c2 = all(t3); 

        if c1 && c2, tmp = cell2mat(tmp); end

        varargout{i} = tmp; 

    end 
    
   

end

