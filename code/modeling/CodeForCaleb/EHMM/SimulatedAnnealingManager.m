classdef SimulatedAnnealingManager < handle
	% Manages the simulated annealing process:
    %   - Estimates initial temprature
    %	- Keeps track of temprature schedule
    %   - Determines whether or not a candidate state should be accpeted
    
    properties
        time
        T
        dE
        update_time
        converge_th
        max_chance_accpetance
        min_duration
        min_init_duration
        max_duration
        dE_history
        T_history
        T_logic_history
        action_history
        schedule_params
        type % anneal type. 'none' / 'linear'
        p % parameters array. default = scalar, slope of linear anneal
    end
    
    methods (Static)
        
        function stats(actionsVec,ax)
            actionsVec = actionsVec(actionsVec>=0);
            pBetter = mean( actionsVec == 2 )*100;
            pChance = mean( actionsVec == 1 )*100;
            actionsVec = actionsVec(mod(length(actionsVec),3)+1:end);
            L = length(actionsVec)/3;
            c1 = mean(actionsVec(1:L)==1)*100;
            c2 = mean(actionsVec(L+1:2*L)==1)*100;
            c3 = mean(actionsVec(2*L+1:end)==1)*100;
            disp('-- Annealing statistics:');
            fprintf('Candidates that were better: %.0f%%\n',pBetter);
            fprintf('Candidates chosen by chance: %.0f%%\n',pChance);
            fprintf('Chance by thirds: %.0f%%, %.0f%%, %.0f%%\n',c1,c2,c3);
            disp('--');
            
            if exist('ax','var') && ~isempty(ax)
                ax = getaxes(ax);
                L = round(length(actionsVec)/4);
                plot(ax,...
                    1:length(actionsVec),smooth(actionsVec==1,L),'m.-',...
                    1:length(actionsVec),smooth(actionsVec==2,L),'g.-');
                legend('Chance','Better','location','best');
            end
        end
    
    end
    
    methods
        
        function obj = SimulatedAnnealingManager(varargin)
            
            INIT_SIZE = 10^4 ;
            
            defaultparams.type = 'linear' ;
            defaultparams.p = 0.1;
            defaultparams.max_chance_accpetance = 0.2 ;
            defaultparams.converge_th = 10^-6 ;
            
            if mod(length(varargin),2)~=0
                varargin = [ 'type' varargin ];
            end
            params = parseinput(defaultparams,varargin);
            flds = fields(params);
            for i = 1 : length(flds)
                obj.(flds{i}) = params.(flds{i});
            end
            
            obj.setScheduleParams();
            obj.time = 0 ;
            obj.update_time = inf;
            obj.dE = nan;
            obj.T = nan;
            
            obj.dE_history = nan(1,INIT_SIZE);
            obj.T_history = nan(1,INIT_SIZE);
            obj.T_logic_history = nan(1,INIT_SIZE);
            obj.action_history = nan(1,INIT_SIZE);
            
            fprintf('- Initalized simulated annealing with params:\n');
            disp(obj.getDisplayParams());
            fprintf('--\n');
        end
        
        function out = getDisplayParams(obj)
            DISP_PARAMS = {
                'type'
                'max_chance_accpetance'
                'min_duration'
                'min_init_duration'
                'max_duration'
                'converge_th'
                };
            for i = 1 : length(DISP_PARAMS)
                out.(DISP_PARAMS{i}) = obj.(DISP_PARAMS{i});
            end
        end
        
        function [action,msg] = step(obj,dE_in)
            % perform anneal step:
            % decide on action and update temprature according to scheudle.
            % INPUT:
            %   dE - current energy difference. sign convention: dE>0 iff
            %       current state is better than candidate state.
            % OUTPUT:
            %   action - action code:
            %       0 = reject candidate
            %       1 = accept candidate
            %      -1 = redo iteration (used for inital exploration)
 
            % *
            % update variables:
            obj.time = obj.time + 1 ;
            obj.dE = dE_in ;
            obj.dE_history(obj.time) = dE_in ;
            
            % *
            % temprature:
            % if time spent in current temprature is sufficient for
            % estimating convergence, and if convergence is accuring, get
            % the next temprature. else: stay in current temprature.
            if obj.collectingInitialStatistics()
                if obj.time >= obj.min_init_duration
                    obj.setInitParams();
                end
            else
                duration = obj.time - obj.update_time ;
                h = obj.getHistory() ;
                if ...
                        (duration >= obj.max_duration) || (...
                        (duration >= obj.min_duration) && (...
                        mean(abs(h.dE(obj.update_time:obj.time))) > ...
                        obj.converge_th ) ...
                        )
                    obj.changeTempratureBySchedule();
                else
                    if (obj.time>=obj.annealStartTime+obj.min_duration) ...
                            && (obj.lastTempratureLogic ~= 2) ...
                        obj.resetTempratureByChanceAcceptanceRate();
                    end
                end
                
            end
            
            obj.T_history(obj.time) = obj.T;
            
            % *
            % action:
            action = obj.voteOnCandidate() ;
            obj.action_history(obj.time) = action;
            
            msg = obj.getMsgForLastStep();
        end
        
        function r = collectingInitialStatistics(obj)
            r = isnan(obj.T);
        end
        
        function r = isAnneal(obj)
            r = ~strcmpi(obj.type,'none') ;
        end
        
        function action = voteOnCandidate(obj,dE)
            % if currently collecting statistics, action is to go back and
            % collect more dE values. else: action is determined by
            % acceptance criteria.
            %
            % INPUT:
            %   dE - current energy difference. sign convention: dE>=0 iff
            %       current state is better than candidate state.
            % OUTPUT:
            %   action - action code:
            %      -1 = redo iteration (used for inital exploration)
            %       0 = reject candidate
            %       1 = accept (chance)
            %       2 = accept (candidate is better)

            if obj.collectingInitialStatistics()
                action = -1;
                return
            end
            if ~exist('dE','var'), dE = obj.dE; end
            if dE<=0
                action = 2;
            else
                action = double(rand < exp(-dE/obj.T));
            end
        end
        
        function msg = getMsgForLastStep(obj)
            MSGS = { 
                'collecting statistics'
                'candidate was rejected'
                'candidate was chosen by chance'
                'candidate was better'
                };
            s = obj.getHistory(true);
            candMsg = MSGS{s.action+2};
            msg = sprintf('T=%.2f, dE=%.2f, %s',s.T,s.dE,candMsg);
        end
        
        function r = chanceAcceptenceRate(obj)
            h = obj.getHistory();
            r = mean(h.action(h.action>=0)==2);
        end
        
        function T = computeInitTemprature(obj)
            MIN_POSITIVE_DE = 4 ;
            h = obj.getHistory();
            dEpos = h.dE(h.dE>0);
            if length(dEpos)<MIN_POSITIVE_DE
                T = obj.T;
                return;
            end
            dE_rep = mean(dEpos)-std(dEpos);
            if dE_rep < 0
                dE_rep = 0.5*median(dEpos);
            end
            T = -dE_rep/log(obj.max_chance_accpetance);
        end
        
        function resetTempratureByChanceAcceptanceRate(obj)
            chanceRate = obj.chanceAcceptenceRate() ;
            if chanceRate > obj.max_chance_accpetance
                TT = obj.T*log(chanceRate)/log(obj.max_chance_accpetance);
                obj.setTemprature(TT,2);
                obj.setScheduleParams();
            end
        end
        
        function th = estimateConvergeThresh(obj)
            FCTR = 0.5 ;
            h = obj.getHistory();
            th = FCTR*median(abs(h.dE));
        end
                
        function setTemprature(obj,Tnew,logicCode)
            if obj.T ~= Tnew && ~isnan(Tnew)
                obj.T = Tnew;
                obj.update_time = obj.time ;
                obj.T_history(obj.time) = obj.T ;
                obj.T_logic_history(obj.time) = logicCode ;
            end
        end
        
        function setInitParams(obj)
            obj.setTemprature(obj.computeInitTemprature(),0);
            obj.setScheduleParams();
        end
        
        function setScheduleParams(obj)
            if strcmpi(obj.type,'none')
                return
            elseif strcmpi(obj.type,'linear')
                obj.schedule_params.dT = -obj.p(1)*obj.T;
                obj.min_duration = 5;
                obj.min_init_duration = 5;
                obj.max_duration = 11;
            else
                error([ 'Unknown anneal type: ' obj.type ])
            end  
        end
        
        function r = getHistory(obj,onlylast)
            if exist('onlylast','var') && onlylast
                ind = obj.time;
            else
                ind = 1 : obj.time;
            end
            r.dE = obj.dE_history(ind);
            r.action = obj.action_history(ind);
            r.T = obj.T_history(ind);
            r.T_logic = obj.T_logic_history(ind);
        end
        
        function changeTempratureBySchedule(obj)
            obj.setTemprature(obj.getNextTempratureInSchedule(),1);
        end
        
        function r = lastTempratureLogic(obj)
            h = obj.getHistory();
            lgc = h.T_logic(~isnan(h.T_logic)) ;
            r = lgc(end);
        end
        
        
        function t = annealStartTime(obj)
            h = obj.getHistory();
            t = find(h.action>=0,1,'first');
        end
        
        
        function T = getNextTempratureInSchedule(obj)
            if ~obj.isAnneal()
            	T = obj.T ;
            elseif strcmpi(obj.type,'linear')
            	T = obj.T + obj.schedule_params.dT ;
                if T<0, T = 0; end
            end
        end
        
        
        
    end
    
end