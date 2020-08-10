classdef Confine
	% Defines a confined segment of code. All variables that are created
	% within the confined segment are cleared upon exiting the segment.
    %
    % EXAMPLE:
    %
    %   a = 1; % variable initalized outside confied segment
    %   Confine.open();
    %   b = 3; % variable initalized inside confied segment
    %   a = a + b ;
    %   Confine.close();
    %
    %   exist('a','var') % returns true
    %   exist('b','var') % returns false

    methods (Static)
        
        function open
            % begin confined code segment.
            % saves a list all current variable names
            
            global confineVars
            confineVars{end+1} = evalin('caller','who') ;
        end
        
        function close(varargin)
            % terminate confined code segment.
            % clears all variables that didn't exist on confined opening
            % variable names that are given as input are not cleared
            % INPUT:
            %   variable names to leave intact
            % EXAMPLE:
            %   Confine.close(); % clear all confined variables
            %   Confine.close('x','y') % clear all except 'x' and 'y'
            
            global confineVars
            exvars = [ confineVars{end} ; varargin(:) ];
            cmd = ['clearvars -except ' sprintf('%s ',exvars{:})];
            evalin('caller',cmd) ;
            confineVars = confineVars(1:end-1);
        end
        
    end
    
end