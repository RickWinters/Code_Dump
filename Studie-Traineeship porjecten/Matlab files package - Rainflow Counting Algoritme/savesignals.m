for i = 8:8 %loop over file
    if i == 8
        Channel_02_x = linspace(-1,4,100000);
        Channel_02 = 1*sin(200*pi.*Channel_02_x);
        %Channel_02 = Channel_02 + 1*sin(800*pi.*Channel_02_x);
        %Channel_02 = Channel_02 + rand([1,length(Channel_02_x)])*6-3;
        %Channel_02 = Channel_02 + rand([1,length(Channel_02_x)])*2-1;
        dt = Channel_02_x(3) - Channel_02_x(2);
        signal = Channel_02;
        Toffset = 0;
        Tstart = 0;
        Tend = 5;
    elseif i == 9
        load all_data 
        signal = Y_BEARING_OUT';
        dt = Y_BEARING_OUT_x(3) - Y_BEARING_OUT_x(2);
        Toffset = 0;
        Tstart = 0;
        Tend = 120+2*dt;
    elseif i == 10
        load all_data
        signal = Z_BEARING_OUT';
        dt = Z_BEARING_OUT_x(3) - Z_BEARING_OUT_x(2); 
        Toffset = 0;
        Tstart = 0;
        Tend = 120+2*dt;
    else
        load(strcat('ImExport',num2str(i),'.mat'))%load file
        signal = Channel_02(1:100000)';
        dt = Channel_02_x(3) - Channel_02_x(2); %calculate time difference
        Toffset = -1;
        Tstart = 0;
        Tend = 5;
    end           
    time = Tstart+dt:dt:Tend;   
    save(strcat('C:\Stage\MATLAB\gui\data\signal',num2str(i)),'signal');
    save(strcat('C:\Stage\MATLAB\gui\data\time',num2str(i)),'time');
    
end

