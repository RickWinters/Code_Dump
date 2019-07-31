function[rfdata,Sut] = stresscorrection(rfdata,Sut);
means = rfdata(2,:); %putting the mean stresses in an array
amps = rfdata(1,:); %putting the alternating stresses in an array
newamps = zeros(1,length(amps)); %create an array with corrected stresses
%Sut = 818.8e6; %ultimate stress for material, just a random number now
rfdata(6,:) = zeros(1,length(rfdata(1,:))); %add a new row to the rfdata, here the newapms are saved later


for i = 1:length(means)
    newamp = amps(i) / (1 - abs((means(i)) / Sut)); %calculated damage equivalent alternating stress from alternating stress amplitude, mean stress and material ultimate stress
    newamps(i) = newamp;
end

rfdata(6,:) = newamps;   %save newamps in the rfdata variable to be used later
rfdata(7,:) = zeros(1,length(amps));

end