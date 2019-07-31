clear all
close all
clc
warning off

%Dit is een voorbeeld van hoe 'analysePSDsignal' gebruikt kan worden. In
%het begin worden eerst 2 gemaakt, dan word 'analysePSDsignal' twee keer
%aangeroepen om 1 figuur te maken.


%Eerst word de tijdas gemaak
Fsample = 100000;                                                           
Mtime = 5;
dt = 1/Fsample;
Fac = 1000;
time = dt:dt:Mtime;   

%De as waaring de amplitude van de sinus op staat
amp = ones(size(time));                                                     
amp(:,length(amp)/4:end) = 0.5;
amp(:,length(amp)/2:end) = 1;
amp(:,length(amp)/4*3:end) = 0.5;

%maak het signaal
signal1 = amp.*sin(2*pi*Fac.*time);                                   %
signal2 = 0.5*signal1 + randn(size(signal1));

%De indices op de tijdas waarin de analyse gesplitst word
ind1 = find(time < Mtime/4);
ind1 = ind1(end);
ind2 = find(time < Mtime/2);
ind2 = ind2(end);
ind3 = find(time < Mtime/4*3);
ind3 = ind3(end);
timeinds = [ind1, ind2, ind3];

%Low pass filter frequency
LPFF = 20;

%signal,Mtime,Fac,timeinds,LPFF,doplot,titlestring,saveplot,newfigure,linecolor,legendstring

%Bij de eerste keer aanroepen van de frequentie wordt signaal 1
%geanalyseerd. De eerste drie argumenten van deze functie zijn verplicht en
%in volgorde moeten zijn 1): array van meting, 2): meet tijd, 3):
%Frequentie die geanalyseerd moet worden. Daarna komen in volgorde een
%array van indices op de tijd as waar de analyse gesplitst moet worden en
%welke frequentie de low-pass filter moet aanhouden. De '1' die er nu staat
%geeft aan dat er een plot gemaak moet worden. Dit is niet perse nodig. Het
%is namelijk mogelijk om variabelen terug te krijgen. Kijk hiervoor in de
%comments van de functie. Hierna moet een titel string worden doorgegeven,
%omdat we hier het figuur nog niet willen opslaan is dit tijdelijk 'titel'.
%%De '0' geeft aan dat het figuur nog niet opgeslagen wordt, anders moet
%hier een '1' staan. De '1' geeft aan dat een nieuw figuur gemaakt moeten
%worden. Als op deze plek een '0' staat dan worden de grafieken geplaatst
%in het huidige actieve figuur. Het laatste argument geeft aan welke kleur
%de lijnen moeten hebben. Hierna kan nog een cell array aan strings worden
%ingevoerd om een legenda te maken. Echter is dit alleen van belang als het
%figuur ook wordt opgeslagen
analysePSDsignal(signal1,Mtime,Fac,timeinds,LPFF,1,'titel',0,1,'blue');

%Nu word signaal 2 geanalyseerd, Dit keer wordt geen nieuw figuur geopend,
%maar deze wordt ook nog niet opgeslagen. 
analysePSDsignal(signal2,Mtime,Fac,timeinds,LPFF,1,'titel',0,0,'red');

%Als laasts word een combinatie van beide signalen geanalyseerd. Nu word
%het figuur wel opgeslagen dus moet er een titel gegeven worden. Deze keer
%is er ook een cell array met legenda items gegeven
analysePSDsignal(5*signal1+signal2,Mtime,Fac,timeinds,LPFF,1,'Voorbeeld van 3 analyses',1,0,'black',{'signaal 1','signaal 2','signaal 3'});




