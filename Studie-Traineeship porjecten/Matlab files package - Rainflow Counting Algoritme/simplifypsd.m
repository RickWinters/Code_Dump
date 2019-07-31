function[fit,knotloc,knotamp,slm] = simplifypsd(pxx,f,flim,nk)
% This function simplifies a power spectrum by cutting up the power
% spectrum in multiple pieces and finding a lineair fit to all the pieces.
% The places where the PSD is cut up are called knots. These knots are
% automatically placed on the x-axis for the best fit.
% =========================================================================
% SYNTAX
%   simplifypsd(pxx,f)
%   simplifypsd(pxx,f,flim)
%   simplifypsd(pxx,f,flim,nk)
%   fit = simplifypsd(pxx,f,flim,nk)
%   [fit,knotloc] = simplify(pxx,f,flim,nx)
%   [fit,knotloc,knotamp] = simplify(pxx,f,flim,nx)
% =========================================================================
% OUTPUTS
% fit     = array;
%           data arry of linear lines between knots, represents the linear
%           fit lines of all the pieces
% knotloc = array;
%           the locations on the x-axis of the knots.
% knotamp = array;
%           the locations on the y-axis of the knots.
% slm     = data structure;
%           Data structure of the Shape Language Model
% =========================================================================
% INPUTS
% pxx     = array;
%           data array of the power spectrum
% f       = array;
%           frequency axis of the power spectrum
% flim    = array;
%           [flow, fhigh] limit the frequency axis of the power spectrum,
%           simplification only happens between the frequency limit. as
%           such the smaller the limits, the faster.
%           optional
%           default = limits of frequency axis 
% nk      = integer between 3 and 10;
%           number of knots used for simplification
%           suggested; 5 for single peak
%                      8 for two peaks
%                      6 for table shape
%           optional
%           default = 5


if nargin < 3 %if no frequency limit is given, use the edges of the frequency axis as limit
    flim(1) = f(1); 
    flim(2) = f(length(f));
end

indstart = find(f>=flim(1)); %find the indices where the frequency is higher or equal to the lower frequency limit
indstart = indstart(1); %exctract first valid index
indstop = find(f<=flim(2)); %find the indices where the frequency is lower or equeal to the higher frequency limit
indstop = indstop(length(indstop)); %extract last valid index
ind = indstart:indstop; %all indices for which the frequency axis is within frequency limits

f = f(ind); %overwrite frequency axis with only the part within frequency limits
pxx = pxx(ind); %overwrite psd values with indices within frequency limits

prescription = slmset; %creates a precsription class for the spline fit engine
if nargin < 4 %if no number of knots are given, use 5
    prescription.Knots = 5;
else
    prescription.Knots = nk;
end
prescription.Plot = 'off'; %turn off result plotting
prescription.Degree = 1; %prescribe linear curve fitting
prescription.Verbosity = 0; %if 1, output some fit logging to the matlab workspace
prescription.InteriorKnots = 'free'; %if 'free', knots are free to be placed for best fit, otherwise knots are equally spaced throughout frequency axis
slm = slmengine(f,pxx,prescription); %creates a fit model of pxx on the f axis according to the prescription
fit = slmeval(f,slm); %evaluates fit model, creating the actual simplified lines

for i = 1:length(slm.knots')
    knotloc(i) = slm.knots(i); %extract the locations of the knots on the frequency axis
    locind = find(f >= knotloc(i)); %finds the index of the frequency axis coinciding with the knot
    locind = locind(1);
    knotamp(i) = fit(locind); %finds the amplitude of the knots
end

end




