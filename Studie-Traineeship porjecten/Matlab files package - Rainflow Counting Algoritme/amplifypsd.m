function[pxx] = amplifypsd(pxx)
% this function amplifies a PSD by converting it to dB scale, adding 3 dB
% and converting in back to linear scale. This is the same as doubling it,
% but i like it fancy
% =========================================================================
% SYNTAX
%   amplifypsd(pxx)
%   pxx = amplifypsd(pxx)
% =========================================================================
% OUTPUTS
% pxx = array;
%       amplified power spectrum
% =========================================================================
% INPUTS
% pxx = array;
%       power spectrum, or simplified fit array
pxx = 10*log10(pxx);
pxx = pxx+3;
pxx = 10.^(pxx/10);

end