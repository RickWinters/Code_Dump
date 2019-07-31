function[D, T, sigaf, m, Nk] = damagecalculation(rfdata, T0, sigaf, m, Nk)
% This function calculates the damage of a rfdata and estimates the time.
% The damagecalculation is derived from D = sum(n_i / N_i), where n_i is
% the measured amount of cycles, or rfdata(3,:). and N_i is the amount of
% cycles to failure. This is derived by using data from an S-N curve. By
% using the amount of cycles to failure at the lower stress limit of fatige
% (or the kneepoint) as input data, N_i can be estimated and as such the
% damage can be calculated
% =========================================================================
% SYNTAX
%   damagecalculation(rfdata)
%   damagecalculation(rfdata,T0)
%   damagecalculation(rfdata,T0,sigaf)
%   damagecalculation(rfdata,T0,sigaf,m)
%   damagecalculation(rfdata,T0,sigaf,m,Nk)
%   D = damagecalculation(rfdata,T0,sigaf,m,Nk)
%   [D, T] = damagecalculation(rfdata,T0,sigaf,m,Nk)
%   [D, T, sigaf, m, Nk] = damagecalculation(rfdata,T0,sigaf,m,Nk)
% =========================================================================
% OUTPUTS
% D           = float;
%               represents the damage number, if > 1, part has
%               theoretically broken
% T           = float;
%               Represents time estimation in units of T0;
% sigaf       = float / integer;
%               lower fatigue limit of material in MPa
%               can be 'asked for' if not inputted to function but default
%               needs to be known
% m           = integer;
%               fatigue exponent
%               can be 'asked for' if not inputted to function but default
%               needs to be known
% Nk          = integer;
%               amount of cycles to failure at kneepoint/sigaf
%               can be 'asked for' if not inputted to function but default
%               needs to be known
% =========================================================================
% INPUTS
% rfdata      = matrix;
%               rainflow data, stresscorrection needs to be applied to
%               rfdata firstly
% T0          = float / integer;
%               length of the measurede signal in seconds, i.e. if
%               measurement took 10 seconds, T0 = 10
%               optional
%               default = 1
% sigaf       = integer;
%               lower fatigue limit of material in MPa
%               optional
%               default = 320
% m           = integer;
%               fatigue exponent
%               optional
%               default = 5
% Nk          = integer;
%               number of cycles to failure an kneepoint of S-N curve of
%               material / sigaf
%               optional
%               default = 2e6

% by Rick Winters
% Feb-Jul 2017




if nargin < 5
    Nk = 2e6;  %number of cycles at kneepoint of
    if nargin < 4
        m = 1;  %fatigue exponent
        if nargin < 3
            sigaf = 320;    %lower stress limit of fatigue in MPa
            if nargin < 2
                T0 = 1;  %length of the measured signal in seconds
            end
        end
    end
end
% length in second of the time history

CycleRate=rfdata(3,:);   % number of cycles
siga=rfdata(6,:);        % cycle amplitudes

% calculation of the damage
D=sum((CycleRate/Nk).*(real((siga/sigaf).^m)));

% expected time to failure in seconds
T=T0/D;

