% Bepalen van een tijdsignaal uit een PSD Spectrum
%
% [amp,time]=psd2time(Pyy,B,n)
%
% Pyy=Power Spectral Density Spectrum
% n=number of spectral lines
% B=Bandwith

function[amp,time]=psd2time(Pyy,B,n)

%n = 50001;
%T = 10; 

%dt = 10/50001 
%B = 50001/10 = length(f)/t(length(t))

dt=1/B;				    %Bemonsteringsinterval
T=n*dt;				    %Lengte Tijdsvenster
df=B/n; 			    %Freqeuntie interval
time=linspace(0,T,n);					

                                    % Het spectrum vermenigvuldigen met zijn toegevoegd
                                    % complexe levert het PSD niveau op
                                    % Pyy = (a+bj)*(a-bj) = a²+b²
                                    %
                                    % Terug naar het tijdsignaal met een PSD spectrum 
                                    % a²+b² De toegevoegde complexe b² term is vervallen 
                                    % Om deze terug te construeren worden de fase
                                    % vershuivingen van een vlak spectrum genomen

	y1=rand(size(time));	    %Random getallen
	Y1=fft(y1);		    %Spectrum
	r=angle(Y1);		    %Vector van de fase van het spectrum is een
				    %vector tussen -pi en +pi


a=sqrt(Pyy).*cos(r);	            %
b=sqrt(Pyy).*sin(r);		    %PSD waarde ontleden in a+bj
Y2=(a+b*j)*sqrt(n);		    %

amp=ifft(Y2);

					%De rms waarde uitgerekend in het PSD
					%spectrum moet hetzelfde zijn als in het
					%tijdomein.
					%Voorlopig snap ik nog niet waarom dit niet zo
					%is daarom volgt hier de meest botte methode
					%om dit te corrigeren.


rms_a=sqrt(mean(abs(amp).^2));		%rms waarde tijdsignaal        
rms_b=max(sqrt(cumsum(Pyy.*df)));	%rms uit PSD spectrum    
factor=(rms_b/rms_a);			%verhoudingsfactor
amp=amp*factor;				%correctie