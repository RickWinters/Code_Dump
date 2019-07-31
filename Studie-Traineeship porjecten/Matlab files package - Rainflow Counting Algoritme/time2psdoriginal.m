% Bepalen van een PSD spectrum uit een Tijdsignaal
%
% [Pxx,f]=time2psd(x,t)
%
% x=Amplitude vector
% t=Tijdvector
%
% zie ook psd2time

function[px,f]=time2psd(x,t);

if nargin < 2
    tend = length(x);
    t = 0:1:tend;
end

samples   =length(t);
samplefreq=round(1/(t(2)-t(1)));
window    =round(length(t)/5);
n_overlap =round(length(t)/window);

[px,f] = psd(x,samples,samplefreq,window,n_overlap);

df=f(2)-f(1);
rms_x=sqrt(mean(x.^2));		        %rms waarde tijdsignaal
rms_psd=max(sqrt(cumsum(px.*df)));	%rms uit PSD spectrum
factor=(abs(rms_x/rms_psd))^2;		%verhoudingsfactor
px=px.*factor;                      %correctie