clear all
close all
clc
warning off

%Dit is een voorbeeld script waar 3 signalen worden gemaakt om te gebruiken
%bij Comparesignals functie. Eerst worden 3 signalen gesimuleerd om daarna
%de comparesignals functie aan te roepen. Bij elk voorbeeld worden de
%argumenten uitgelegd. 


%Tijd as opzetten, meet tijd is 5 seconden, sampling frequentie van 2e5;
Mtime = 5;
Fsample = 2e5;
dt = 1/Fsample;
time = dt:dt:Mtime;

%Alvast de arrays aanmaken voor de drie signalen
signal1 = zeros(1,length(time));
signal2 = zeros(1,length(time));
signal3 = zeros(1,length(time));

%Elk signaal bestaat uit een 'harmonische frequentie'. opgebouwd uit 10
%sinussen met dubbele frequentie en halve amplitude plus een phaseshift
%plus wat normaal verdeelde ruis. Signaal 1 heeft normaal verdeelde ruis
%met een std van 0.01 en is het 'zuivere signaal'. de andere 2 signalen
%hebben normaal verdeelde ruis met een std van 1

%Het eerste signaal heeft een basis frequentie van 1 kHz en basis amplitude
%van 1

A_base = 1;
F_base = 1000;
for i = 1:10
    signal1 = signal1 + (A_base/i).*sin( (F_base*i)*2*pi.*time+randn(1)*90);
end
signal1 = signal1 + 0.01*randn(size(signal1));

%Het tweede signaal heeft eet basisfrequentie van 267 Hz en een
%basisamplitude van 2
A_base = 2;
F_base = 267;
for i = 1:10
    signal2 = signal2 + (A_base/i).*sin( (F_base*i)*2*pi.*time+randn(1)*90);
end
signal2 = signal2 + randn(size(signal2));

%signaal 3 is een optelling van de eerste 2
signal3 = signal2 + 2*signal1;

%In het eerste voorbeeld vergelijken we signaal 2 en signaal 1.
%Deze twee arrays zijn dan ook meteen de eerste 2 argumenten van de
%functie, als derde word de meet tijd doorgegeven. Dit is een verplichte
%argument en moet gelijk zijn voor beide metingen.
%Het vierde argument is een cell array met 3 strings waarbij de eerste
%string de titel is van signaal 1, de tweede string is de titel van signaal
%2 en de laatste string is de setting die hoort bij de meting. De laatste
%twee argumenten zijn of je wilt dat het figuur wordt gesloten (0 voor
%niet, en 1 voor wel), en de laatste is de FontSize van de tekst. De figuur
%wordt automatisch opgeslagen onder de naam die opgebouwd is uit de drie
%strings. In het eerste voorbeeld is dit "signal1_signal2_at_example". Een
%map waarin dit staat opgeslagen is hard-coded in de functie en wordt
%aangeraden de veranderen zodat de png-files in de goede map komen.

%Hier vergelijken we signaal 1 en 2 bij setting 'example', word het figuur
%niet gesloten, en een FontSize van 22
comparesignals(signal2,signal1,Mtime,{'signal1','signal2','example'},0,22)

%Hier word signaal 3 en 1 vergeleken, en de figuur wel gesloten. Echter
%is dit figuur wel opgeslagen
comparesignals(signal3,signal1,Mtime,{'signal3','signal1','example2'},1,22)
%%
%Eeen laatste signaal is een vergelijking met signaal 2 en 3, maar dan een
%andere fontsize
comparesignals(signal3,signal2,Mtime,{'signal3','signal2','example3'},0,30)