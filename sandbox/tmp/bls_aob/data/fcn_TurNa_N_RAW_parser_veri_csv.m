function [struct_data] = fcn_TurNa_N_RAW_parser_veri_csv(veriyolu,analysis_result_folder)
    
    fid = fopen(veriyolu);
    data = fread(fid,'*uint8'); 
    fclose(fid); % Dosya Açma İşlemleri
    
    len=66;
    weight=len; %bir periyotta ortalama paket uzunluğu + 1
    header_position=zeros(floor(length(data)/weight),1); %memory allocation
    
    % Locate candidate packages
    jj=1;
    ii=1;
    while true
        if ii>=length(data)-(len-1)
            break;
        end
        if data(ii) == 90 && data(ii+1) == 0 && data(ii+2) == 165 && data(ii+3) == 0
            header_position(jj,1)=ii;
            jj=jj+1;
            ii=ii+len;
        else
            ii=ii+1;
        end
    end
    
    delete_zeros= header_position(:,1)==0;
    header_position = header_position(not(delete_zeros),:);

    veri=zeros(length(header_position),len,"uint8");

    jj=1;
    for ii=1:length(header_position)
        veri(jj,:)= data(header_position(ii):header_position(ii)+len-1);
        jj=jj+1;
    end
    clear data

    % CRC Check
    crc_calculated=CRC16CCIT(veri,len-2);
    crc_received=uint16(veri(:,len-1))+bitshift(uint16(veri(:,len)),8);
    veri = veri(crc_calculated==crc_received,:);
    
    if all(crc_calculated==crc_received)
        disp("CRC hatası yok");
    else
        disp("CRC hatası var");
    end
    
    %Extract data
%     veri = veri(1:fix(length(veri)/500)*500,:); %Make the length of the data divisible by the frequency.

    k=45;
    MUX_ID1= veri(:,k);
    k=46;
    MUX_ID2= veri(:,k);

    pattern = find(bitand(MUX_ID1== 4,MUX_ID2 == 19));
    startofpattern= pattern(1);
    endofpattern= pattern(end);

    veri = veri(startofpattern:endofpattern,:);

%     if isempty(veri)
%         errordlg("Veri içeriği boştur. Analiz durdurulacaktır.","HATA")
%         return
%     end

    %COUNTER ANALYSIS 
    CounterCheck= diff(double([uint16(veri(:,63))+bitshift(uint16(veri(:,64)),8);1]));
    CounterCheck= CounterCheck==1 | CounterCheck==-2^16+1;
    CounterMiss = sum(not(CounterCheck));
    CounterCheck= find(not(CounterCheck)); %Counter Hatası olan yerler 1

%     fig=figure("Visible","off");
%     scatter((CounterCheck-1)/500/60,ones(length(CounterCheck),1),'*')
%     xlim([0 CounterCheck(end)/500/60])
%     ylim([0 1.2])
%     xticks(0:60:10000)
%     yticks([0 1])
%     title(sprintf('Counter Error = %d',CounterMiss))
%     xlabel('Time [min]')
%     ylabel('Error')
%     grid on
%     box on
%     disp(['Sayac Hatasi= ', num2str(CounterMiss)])
%     
%     set(fig,'Visible','on')
%     saveas(fig,fullfile(analysis_result_folder,'Sayac_Hatasi.png'))
%     savefig(fig,fullfile(analysis_result_folder,'Sayac_Hatasi.fig'))

    k=5;
    struct_data(1).FOG=segmented_mean(typecast(uint32(veri(:,k))+bitshift(uint32(veri(:,k+1)),8)+bitshift(uint32(veri(:,k+2)),16)+bitshift(uint32(veri(:,k+3)),24),'int32'),500)/4;
    k=9;
    struct_data(2).FOG=segmented_mean(typecast(uint32(veri(:,k))+bitshift(uint32(veri(:,k+1)),8)+bitshift(uint32(veri(:,k+2)),16)+bitshift(uint32(veri(:,k+3)),24),'int32'),500)/4;
    k=13;
    struct_data(3).FOG=segmented_mean(typecast(uint32(veri(:,k))+bitshift(uint32(veri(:,k+1)),8)+bitshift(uint32(veri(:,k+2)),16)+bitshift(uint32(veri(:,k+3)),24),'int32'),500)/4;

    k=17;
    struct_data(1).ACC=segmented_mean(typecast(uint32(veri(:,k))+bitshift(uint32(veri(:,k+1)),8)+bitshift(uint32(veri(:,k+2)),16)+bitshift(uint32(veri(:,k+3)),24),'int32'),500)/4;
    k=21;
    struct_data(2).ACC=segmented_mean(typecast(uint32(veri(:,k))+bitshift(uint32(veri(:,k+1)),8)+bitshift(uint32(veri(:,k+2)),16)+bitshift(uint32(veri(:,k+3)),24),'int32'),500)/4;
    k=25;
    struct_data(3).ACC=segmented_mean(typecast(uint32(veri(:,k))+bitshift(uint32(veri(:,k+1)),8)+bitshift(uint32(veri(:,k+2)),16)+bitshift(uint32(veri(:,k+3)),24),'int32'),500)/4;
    
    k=29;
    struct_data(1).DELTATHETA=segmented_mean(typecast(uint32(veri(:,k))+bitshift(uint32(veri(:,k+1)),8)+bitshift(uint32(veri(:,k+2)),16)+bitshift(uint32(veri(:,k+3)),24),'int32'),500)/4;
    k=33;
    struct_data(2).DELTATHETA=segmented_mean(typecast(uint32(veri(:,k))+bitshift(uint32(veri(:,k+1)),8)+bitshift(uint32(veri(:,k+2)),16)+bitshift(uint32(veri(:,k+3)),24),'int32'),500)/4;
    k=37;
    struct_data(3).DELTATHETA=segmented_mean(typecast(uint32(veri(:,k))+bitshift(uint32(veri(:,k+1)),8)+bitshift(uint32(veri(:,k+2)),16)+bitshift(uint32(veri(:,k+3)),24),'int32'),500)/4;
    
    k=41;
    MASTER_BIT = uint32(veri(:,k))+bitshift(uint32(veri(:,k+1)),8)+bitshift(uint32(veri(:,k+2)),16)+bitshift(uint32(veri(:,k+3)),24);
    
    k=45;
    MUX_ID1= veri(:,k);
    k=46;
    MUX_ID2= veri(:,k);
    
    k=47;
    MUX_DATA_X = uint32(veri(:,k))+bitshift(uint32(veri(:,k+1)),8)+bitshift(uint32(veri(:,k+2)),16)+bitshift(uint32(veri(:,k+3)),24);
    k=51;
    MUX_DATA_Y = uint32(veri(:,k))+bitshift(uint32(veri(:,k+1)),8)+bitshift(uint32(veri(:,k+2)),16)+bitshift(uint32(veri(:,k+3)),24);
    k=55;
    MUX_DATA_Z = uint32(veri(:,k))+bitshift(uint32(veri(:,k+1)),8)+bitshift(uint32(veri(:,k+2)),16)+bitshift(uint32(veri(:,k+3)),24);

    k=59;
    MUX_DATA = uint32(veri(:,k))+bitshift(uint32(veri(:,k+1)),8)+bitshift(uint32(veri(:,k+2)),16)+bitshift(uint32(veri(:,k+3)),24);
    
%     struct_data(1).SN = MUX_DATA(find(MUX_ID2==11,1));
%     struct_data(1).DATA_RATE =2000/MUX_DATA(find(MUX_ID2==19,1));
%     struct_data(1).FW_version = dec2hex(MUX_DATA(find(MUX_ID2==10,1)));

%     struct_data(1).FLYTIME = bitand(MUX_DATA(find(MUX_ID2==12,1)),uint32(255));
%     struct_data(2).FLYTIME = bitand(MUX_DATA(find(MUX_ID2==13,1)),uint32(255));
%     struct_data(3).FLYTIME = bitand(MUX_DATA(find(MUX_ID2==14,1)),uint32(255));
% 
%     struct_data(1).RATIO = bitshift(bitand(MUX_DATA(find(MUX_ID2==12,1)),uint32(65280)),-8);
%     struct_data(2).RATIO = bitshift(bitand(MUX_DATA(find(MUX_ID2==13,1)),uint32(65280)),-8);
%     struct_data(3).RATIO = bitshift(bitand(MUX_DATA(find(MUX_ID2==14,1)),uint32(65280)),-8);
% 
%     struct_data(1).FLYTIME = bitand(MUX_DATA(find(MUX_ID2==12,1)),uint32(255));
%     struct_data(2).FLYTIME = bitand(MUX_DATA(find(MUX_ID2==13,1)),uint32(255));
%     struct_data(3).FLYTIME = bitand(MUX_DATA(find(MUX_ID2==14,1)),uint32(255));
% 
%     struct_data(1).RATIO = bitshift(bitand(MUX_DATA(find(MUX_ID2==12,1)),uint32(65280)),-8);
%     struct_data(2).RATIO = bitshift(bitand(MUX_DATA(find(MUX_ID2==13,1)),uint32(65280)),-8);
%     struct_data(3).RATIO = bitshift(bitand(MUX_DATA(find(MUX_ID2==14,1)),uint32(65280)),-8);

    struct_data(1).GYROtemps = Steinhart_hart(segmented_mean(double(typecast(MUX_DATA_X(MUX_ID1==0),'int32')),100));
    struct_data(2).GYROtemps = Steinhart_hart(segmented_mean(double(typecast(MUX_DATA_Y(MUX_ID1==0),'int32')),100));
    struct_data(3).GYROtemps = Steinhart_hart(segmented_mean(double(typecast(MUX_DATA_Z(MUX_ID1==0),'int32')),100));

    struct_data(1).ACCtemps = segmented_mean(double(typecast(MUX_DATA_X(MUX_ID1==1),'int32')),100)*2.5/2^31*100-23.15;
    struct_data(2).ACCtemps = segmented_mean(double(typecast(MUX_DATA_Y(MUX_ID1==1),'int32')),100)*2.5/2^31*100-23.15;
    struct_data(3).ACCtemps = segmented_mean(double(typecast(MUX_DATA_Z(MUX_ID1==1),'int32')),100)*2.5/2^31*100-23.15;

    struct_data(1).GYROtemps2 = Steinhart_hart(segmented_mean(double(typecast(MUX_DATA_X(MUX_ID1==4),'int32')),100));
    struct_data(2).GYROtemps2 = Steinhart_hart(segmented_mean(double(typecast(MUX_DATA_Y(MUX_ID1==4),'int32')),100));
    struct_data(3).GYROtemps2 = Steinhart_hart(segmented_mean(double(typecast(MUX_DATA_Z(MUX_ID1==4),'int32')),100));

    struct_data(1).GAIN = segmented_mean(double(typecast(MUX_DATA_X(MUX_ID1==2),'int32')),100)*2.5/2^16;
    struct_data(2).GAIN = segmented_mean(double(typecast(MUX_DATA_Y(MUX_ID1==2),'int32')),100)*2.5/2^16;
    struct_data(3).GAIN = segmented_mean(double(typecast(MUX_DATA_Z(MUX_ID1==2),'int32')),100)*2.5/2^16;
  
    struct_data(1).BOARDtemp = (segmented_mean(double(MUX_DATA(MUX_ID2==8)),25)*2.5/2^31*1000-122.4)/0.42+25; 

%     struct_data(1).DACCtemps = Derivative1st(movmean(struct_data(1).ACCtemps,[4 0]),5); %1/min
%     struct_data(2).DACCtemps = Derivative1st(movmean(struct_data(2).ACCtemps,[4 0]),5); %1/min
%     struct_data(3).DACCtemps = Derivative1st(movmean(struct_data(3).ACCtemps,[4 0]),5); %1/min
%     
%     struct_data(1).DGYROtemps = Derivative1st(movmean(struct_data(1).GYROtemps,[4 0]),5); %1/min
%     struct_data(2).DGYROtemps = Derivative1st(movmean(struct_data(2).GYROtemps,[4 0]),5); %1/min
%     struct_data(3).DGYROtemps = Derivative1st(movmean(struct_data(3).GYROtemps,[4 0]),5); %1/min
% 
%     struct_data(1).DGYROtemps2 = Derivative1st(movmean(struct_data(1).GYROtemps2,[4 0]),5); %1/min
%     struct_data(2).DGYROtemps2 = Derivative1st(movmean(struct_data(2).GYROtemps2,[4 0]),5); %1/min
%     struct_data(3).DGYROtemps2 = Derivative1st(movmean(struct_data(3).GYROtemps2,[4 0]),5); %1/min
% 
%     struct_data(1).DDGYROtemps = Derivative2nd(movmean(struct_data(1).GYROtemps,[4 0]),5); %1/min2
%     struct_data(2).DDGYROtemps = Derivative2nd(movmean(struct_data(2).GYROtemps,[4 0]),5); %1/min2
%     struct_data(3).DDGYROtemps = Derivative2nd(movmean(struct_data(3).GYROtemps,[4 0]),5); %1/min2
% 
%     struct_data(1).DDGYROtemps2 = Derivative2nd(movmean(struct_data(1).GYROtemps2,[4 0]),5); %1/min2
%     struct_data(2).DDGYROtemps2 = Derivative2nd(movmean(struct_data(2).GYROtemps2,[4 0]),5); %1/min2
%     struct_data(3).DDGYROtemps2 = Derivative2nd(movmean(struct_data(3).GYROtemps2,[4 0]),5); %1/min2
%     
%     struct_data(1).DBOARDtemp = Derivative1st(movmean(struct_data(1).BOARDtemp,[4 0]),5); %1/min
% 
%     IMU_PLOT(1).PINFET_POWER = segmented_mean(double(typecast(MUX_DATA_X(MUX_ID1==3),'int32')),100)*2.5/2^31+2.5;
%     IMU_PLOT(2).PINFET_POWER = segmented_mean(double(typecast(MUX_DATA_Y(MUX_ID1==3),'int32')),100)*2.5/2^31+2.5;
%     IMU_PLOT(3).PINFET_POWER = segmented_mean(double(typecast(MUX_DATA_Z(MUX_ID1==3),'int32')),100)*2.5/2^31+2.5;

    struct_data(1).PINFET_POWER = segmented_mean(double(typecast(MUX_DATA_X(MUX_ID1==3),'int32')),100)*2.5/2^31+2.5;
    struct_data(2).PINFET_POWER = segmented_mean(double(typecast(MUX_DATA_Y(MUX_ID1==3),'int32')),100)*2.5/2^31+2.5;
    struct_data(3).PINFET_POWER = segmented_mean(double(typecast(MUX_DATA_Z(MUX_ID1==3),'int32')),100)*2.5/2^31+2.5;
        
    struct_data(1).ILASER = segmented_mean(double(typecast(MUX_DATA(MUX_ID2==0),'uint32')),25)*5/2^32*1e3/15;
    struct_data(1).TLASER = Steinhart_hart_laser(segmented_mean(double(typecast(MUX_DATA(MUX_ID2==1),'uint32')),25));
    struct_data(1).PBFM = (segmented_mean(double(typecast(MUX_DATA(MUX_ID2==2),'uint32')),25)*5/2^32/(1+2.2))*1000*0.2973;
    struct_data(1).TEC_CURRENT = (segmented_mean(double(typecast(MUX_DATA(MUX_ID2==3),'uint32')),25)*5/2^32-1.5)/8/0.05*1000;
    struct_data(1).ASE_POWER = segmented_mean(double(typecast(MUX_DATA(MUX_ID2==4),'uint32')),25)*5/2^32;
    struct_data(1).SET_ILASER = segmented_mean(double(typecast(MUX_DATA(MUX_ID2==5),'uint32')),25)*5/2^32;
    struct_data(1).SET_TLASER = segmented_mean(double(typecast(MUX_DATA(MUX_ID2==6),'uint32')),25)*5/2^32;
    struct_data(1).VMON = (segmented_mean(double(typecast(MUX_DATA(MUX_ID2==9),'uint32')),25)*5/2^32-2.5)*4;
    struct_data(1).VREFMON = (segmented_mean(double(typecast(MUX_DATA(MUX_ID2==15),'uint32')),25)*5/2^32-2.5)*2;

%     struct_data(1).ASE_POWER = segmented_mean(double(typecast(MUX_DATA(MUX_ID2==4),'uint32')),25)*5/2^32;

%     mkdir(analysis_result_folder,'DATA')
%     save(fullfile(analysis_result_folder,'DATA','struct_data.mat'),'struct_data')
%     save(fullfile(analysis_result_folder,'DATA','IMU_PLOT.mat'),'IMU_PLOT')
%     
%     mkdir(analysis_result_folder,'PLOT')

%     %PLOT
%     timeaxis=(0:fix(length(veri)/500)-1)/60; %minute
%     
%     %01
%     fig=figure("Visible","off");
%     fig.Name='01Temperatures';
%     
%     subplot(3,1,1);
%     legend
%     hold on
%     grid on
%     box on
%     plot(timeaxis,struct_data(1).GYROtemps,'DisplayName','TFOG1_1')
%     plot(timeaxis,struct_data(1).GYROtemps2,'DisplayName','TFOG1_2')
%     plot(timeaxis,struct_data(1).BOARDtemp,'DisplayName','TBOARD')
%     plot(timeaxis,struct_data(1).ACCtemps,'DisplayName','TACC1')
%     title('Unit Temperatures')
%     xlabel('Time [min]')
%     ylabel('Temperature [^oC]')
%     xticks(0:60:10000)
%     yticks(-20:20:100)
%     ylim([-30 90])
% 
%     subplot(3,1,2);
%     legend
%     hold on
%     grid on
%     box on
%     plot(timeaxis,struct_data(2).GYROtemps,'DisplayName','TFOG2_1')
%     plot(timeaxis,struct_data(2).GYROtemps2,'DisplayName','TFOG2_2')
%     plot(timeaxis,struct_data(1).BOARDtemp,'DisplayName','TBOARD')
%     plot(timeaxis,struct_data(2).ACCtemps,'DisplayName','TACC2')
%     title('Unit Temperatures')
%     xlabel('Time [min]')
%     ylabel('Temperature [^oC]')
%     xticks(0:60:10000)
%     yticks(-20:20:100)
%     ylim([-30 90])
% 
%     subplot(3,1,3);
%     legend
%     hold on
%     grid on
%     box on
%     plot(timeaxis,struct_data(3).GYROtemps,'DisplayName','TFOG3_1')
%     plot(timeaxis,struct_data(3).GYROtemps2,'DisplayName','TFOG3_2')
%     plot(timeaxis,struct_data(1).BOARDtemp,'DisplayName','TBOARD')
%     plot(timeaxis,struct_data(3).ACCtemps,'DisplayName','TACC3')
%     title('Unit Temperatures')
%     xlabel('Time [min]')
%     ylabel('Temperature [^oC]')
%     xticks(0:60:10000)
%     yticks(-20:20:100)
%     ylim([-30 90])
% 
%     linkaxes
%     
%     set(fig,'Visible','on')
%     savefig(fig,fullfile(analysis_result_folder,'PLOT','01Temperatures.fig'))
%     
%     %02
%     fig=figure("Visible","off");
%     fig.Name='02AD5061outputandPINFETpower';
% 
%     subplot(3,2,1);
%     hold on
%     grid on
%     box on
%     plot(timeaxis,struct_data(1).GAIN,'Color',[0 0.4470 0.7410])
%     title('DAC AD5061 - 1')
%     xlabel('Time [min]')
%     ylabel('Gain DAC Output [V]')
%     xticks(0:120:10000)
%     yticks(0:0.05:5)
% 
%     subplot(3,2,2);
%     hold on
%     grid on
%     box on
%     plot(timeaxis,IMU_PLOT(1).PINFET_POWER,'Color',[0 0.4470 0.7410])
%     title('Peak Detector Output - 1')
%     xlabel('Time [min]')
%     ylabel('Output Voltage [V]')
%     xticks(0:120:10000)
%     yticks(0:0.1:5)
% 
%     subplot(3,2,3);
%     hold on
%     grid on
%     box on
%     plot(timeaxis,struct_data(2).GAIN,'Color',[0.8500 0.3250 0.0980])
%     title('DAC AD5061 - 2')
%     xlabel('Time [min]')
%     ylabel('Gain DAC Output [V]')
%     xticks(0:120:10000)
%     yticks(0:0.05:5)
% 
%     subplot(3,2,4);
%     hold on
%     grid on
%     box on
%     plot(timeaxis,IMU_PLOT(2).PINFET_POWER,'Color',[0.8500 0.3250 0.0980])
%     title('Peak Detector Output - 2')
%     xlabel('Time [min]')
%     ylabel('Output Voltage [V]')
%     xticks(0:120:10000)
%     yticks(0:0.1:5)
% 
%     subplot(3,2,5);
%     hold on
%     grid on
%     box on
%     plot(timeaxis,struct_data(3).GAIN,'Color',[0.9290 0.6940 0.1250])
%     title('DAC AD5061 - 3')
%     xlabel('Time [min]')
%     ylabel('Gain DAC Output [V]')
%     xticks(0:120:10000)
%     yticks(0:0.05:5)
% 
%     subplot(3,2,6);
%     hold on
%     grid on
%     box on
%     plot(timeaxis,IMU_PLOT(3).PINFET_POWER,'Color',[0.9290 0.6940 0.1250])
%     title('Peak Detector Output - 3')
%     xlabel('Time [min]')
%     ylabel('Output Voltage [V]')
%     xticks(0:120:10000)
%     yticks(0:0.1:5)
% 
%     set(fig,'Visible','on')
%     savefig(fig,fullfile(analysis_result_folder,'PLOT','02AD5061outputandPINFETpower.fig'))
% 
%     %03
%     fig=figure("Visible","off");
%     fig.Name='03Temperaturederivatives';
% 
%     subplot(3,1,1);
%     legend
%     hold on
%     grid on
%     box on
%     plot(timeaxis,struct_data(1).DGYROtemps,'DisplayName','DTFOG1_1')
%     plot(timeaxis,struct_data(1).DGYROtemps2,'DisplayName','DTFOG1_2')
%     plot(timeaxis,struct_data(1).DBOARDtemp,'DisplayName','DTBOARD')
%     plot(timeaxis,struct_data(1).DACCtemps,'DisplayName','DTACC')
%     title('Temperature Derivatives')
%     xlabel('Time [min]')
%     ylabel('dT/dt [^oC/min]')
%     xticks(0:60:10000)
%     yticks(-10:2:10)
%     ylim([-2 2])
% 
%     subplot(3,1,2);
%     legend
%     hold on
%     grid on
%     box on
%     plot(timeaxis,struct_data(2).DGYROtemps,'DisplayName','DTFOG2_1')
%     plot(timeaxis,struct_data(2).DGYROtemps2,'DisplayName','DTFOG2_2')
%     plot(timeaxis,struct_data(1).DBOARDtemp,'DisplayName','DTBOARD')
%     plot(timeaxis,struct_data(2).DACCtemps,'DisplayName','DTACC2')
%     title('Temperature Derivatives')
%     xlabel('Time [min]')
%     ylabel('dT/dt [^oC/min]')
%     xticks(0:60:10000)
%     yticks(-10:2:10)
%     ylim([-3 3])
% 
%     subplot(3,1,3);
%     legend
%     hold on
%     grid on
%     box on
%     plot(timeaxis,struct_data(3).DGYROtemps,'DisplayName','DTFOG3_1')
%     plot(timeaxis,struct_data(3).DGYROtemps2,'DisplayName','DTFOG3_2')
%     plot(timeaxis,struct_data(1).DBOARDtemp,'DisplayName','DTBOARD')
%     plot(timeaxis,struct_data(3).DACCtemps,'DisplayName','DTACC3')
%     title('Temperature Derivatives')
%     xlabel('Time [min]')
%     ylabel('dT/dt [^oC/min]')
%     xticks(0:60:10000)
%     yticks(-10:2:10)
%     ylim([-3 3])
%     
%     set(fig,'Visible','on')
%     savefig(fig,fullfile(analysis_result_folder,'PLOT','03Temperaturederivatives.fig'))
% 
%     %04
% 
%     fig=figure("Visible","off");
%     fig.Name='04Rawgyros';
%     
%     subplot(3,1,1);
%     legend
%     hold on
%     grid on
%     box on
%     plot(timeaxis,struct_data(1).FOG,'DisplayName','FOG1','Color',[0 0.4470 0.7410])
%     title('RAW Gyro')
%     xlabel('Time [min]')
%     ylabel('RAW [LSB]')
%     xticks(0:60:10000)
%     ylim([-15e8 15e8]/4)
% 
%     subplot(3,1,2);
%     legend
%     hold on
%     grid on
%     box on
%     plot(timeaxis,struct_data(2).FOG,'DisplayName','FOG2','Color',[0.8500 0.3250 0.0980])
%     title('RAW Gyro')
%     xlabel('Time [min]')
%     ylabel('RAW [LSB]')
%     xticks(0:60:10000)
%     ylim([-15e8 15e8]/4)
% 
%     subplot(3,1,3);
%     legend
%     hold on
%     grid on
%     box on
%     plot(timeaxis,struct_data(3).FOG,'DisplayName','FOG3','Color',[0.9290 0.6940 0.1250])
%     title('RAW Gyro')
%     xlabel('Time [min]')
%     ylabel('RAW [LSB]')
%     xticks(0:60:10000)
%     ylim([-15e8 15e8]/4)
% 
%     linkaxes
% 
%     set(fig,'Visible','on')
%     savefig(fig,fullfile(analysis_result_folder,'PLOT','04Rawgyros.fig'))
% 
%     %05
% 
%     fig=figure("Visible","off");
%     fig.Name='05Rawaccs';
%     
%     subplot(3,1,1);
%     legend
%     hold on
%     grid on
%     box on
%     plot(timeaxis,struct_data(1).ACC,'DisplayName','ACC1','Color',[0 0.4470 0.7410])
%     title('RAW Acc')
%     xlabel('Time [min]')
%     ylabel('RAW [LSB]')
%     xticks(0:60:10000)
%     ylim([-2e7 2e7]/4)
% 
%     subplot(3,1,2);
%     legend
%     hold on
%     grid on
%     box on
%     plot(timeaxis,struct_data(2).ACC,'DisplayName','ACC2','Color',[0.8500 0.3250 0.0980])
%     title('RAW Acc')
%     xlabel('Time [min]')
%     ylabel('RAW [LSB]')
%     xticks(0:60:10000)
%     ylim([-2e7 2e7]/4)
% 
%     subplot(3,1,3);
%     legend
%     hold on
%     grid on
%     box on
%     plot(timeaxis,struct_data(3).ACC,'DisplayName','ACC3','Color',[0.9290 0.6940 0.1250])
%     title('RAW Acc')
%     xlabel('Time [min]')
%     ylabel('RAW [LSB]')
%     xticks(0:60:10000)
%     ylim([-2e7 2e7]/4)
% 
%     linkaxes
%     
%     set(fig,'Visible','on')
%     savefig(fig,fullfile(analysis_result_folder,'PLOT','05Rawaccs.fig'))
% 
%     %06
% 
%     fig=figure("Visible","off");
%     fig.Name='06ILASER';
%     
%     legend
%     hold on
%     grid on
%     box on
%     plot(timeaxis,IMU_PLOT(1).ILASER,'DisplayName','I LASER')
%     title('I Laser')
%     xlabel('Time [min]')
%     ylabel('I [mA]')
%     xticks(0:60:10000)
% 
%     set(fig,'Visible','on')
%     savefig(fig,fullfile(analysis_result_folder,'PLOT','06ILASER.fig'))
% 
%     %07
% 
%     fig=figure("Visible","off");
%     fig.Name='07TLASER';
%     
%     legend
%     hold on
%     grid on
%     box on
%     plot(timeaxis,IMU_PLOT(1).TLASER,'DisplayName','T LASER')
%     title('T Laser')
%     xlabel('Time [min]')
%     ylabel('[^oC]')
%     xticks(0:60:10000)
% 
%     set(fig,'Visible','on')
%     savefig(fig,fullfile(analysis_result_folder,'PLOT','07TLASER.fig'))
% 
%     %08
% 
%     fig=figure("Visible","off");
%     fig.Name='08PBFM';
%     
%     legend
%     hold on
%     grid on
%     box on
%     plot(timeaxis,IMU_PLOT(1).PBFM,'DisplayName','P BFM')
%     title('PBFM')
%     xlabel('Time [min]')
%     ylabel('Power [mW]')
%     xticks(0:60:10000)
% 
%     set(fig,'Visible','on')
%     savefig(fig,fullfile(analysis_result_folder,'PLOT','08PBFM.fig'))
% 
%     %09
% 
%     fig=figure("Visible","off");
%     fig.Name='09ITEC';
%     
%     legend
%     hold on
%     grid on
%     box on
%     plot(timeaxis,IMU_PLOT(1).TEC_CURRENT,'DisplayName','I TEC')
%     title('I TEC')
%     xlabel('Time [min]')
%     ylabel('I [mA]')
%     xticks(0:60:10000)
%     yticks(-2000:200:2000)
%     set(fig,'Visible','on')
%     savefig(fig,fullfile(analysis_result_folder,'PLOT','09ITEC.fig'))
% 
%     %10
% 
%     fig=figure("Visible","off");
%     fig.Name='10PASE';
%     
%     legend
%     hold on
%     grid on
%     box on
%     plot(timeaxis,IMU_PLOT(1).ASE_POWER,'DisplayName','P ASE')
%     title('P ASE')
%     xlabel('Time [min]')
%     ylabel('Voltage [V]')
%     xticks(0:60:10000)
%     set(fig,'Visible','on')
%     savefig(fig,fullfile(analysis_result_folder,'PLOT','10PASE.fig'))
% 
%     %11
% 
%     fig=figure("Visible","off");
%     fig.Name='11ILASERSET';
%     
%     legend
%     hold on
%     grid on
%     box on
%     plot(timeaxis,IMU_PLOT(1).SET_ILASER,'DisplayName','I LASER SET')
%     title('I LASER SET')
%     xlabel('Time [min]')
%     ylabel('Voltage [V]')
%     xticks(0:60:10000)
%     set(fig,'Visible','on')
%     savefig(fig,fullfile(analysis_result_folder,'PLOT','11ILASERSET.fig'))
% 
%     %12
% 
%     fig=figure("Visible","off");
%     fig.Name='12TLASERSET';
%     
%     legend
%     hold on
%     grid on
%     box on
%     plot(timeaxis,IMU_PLOT(1).SET_TLASER,'DisplayName','T LASER SET')
%     title('T LASER SET')
%     xlabel('Time [min]')
%     ylabel('Voltage [V]')
%     xticks(0:60:10000)
%     set(fig,'Visible','on')
%     savefig(fig,fullfile(analysis_result_folder,'PLOT','11TLASERSET.fig'))
% 
% 
%     %13
% 
%     fig=figure("Visible","off");
%     fig.Name='13VMON';
%     
%     legend
%     hold on
%     grid on
%     box on
%     plot(timeaxis,IMU_PLOT(1).VMON,'DisplayName','V MON')
%     title('V MON')
%     xlabel('Time [min]')
%     ylabel('Voltage [V]')
%     xticks(0:60:10000)
% 
%     set(fig,'Visible','on')
%     savefig(fig,fullfile(analysis_result_folder,'PLOT','13VMON.fig'))
% 
%     %14
% 
%     fig=figure("Visible","off");
%     fig.Name='14VREFMON';
%     
%     legend
%     hold on
%     grid on
%     box on
%     plot(timeaxis,IMU_PLOT(1).VREFMON,'DisplayName','V REF MON')
%     title('V REF MON')
%     xlabel('Time [min]')
%     ylabel('Voltage [V]')
%     xticks(0:60:10000)
% 
%     set(fig,'Visible','on')
%     savefig(fig,fullfile(analysis_result_folder,'PLOT','14VREFMON.fig'))
% 
%     %%MASTER BIT ANALYSIS
% 
%     Alarm_types = ["Laser Temperature OTR",
%                     "ASE Failure",
%                     "GYRO Initialized",
%                     "GYRO X Failure",
%                     "GYRO Y Failure",
%                     "GYRO Z Failure",
%                     "GYRO X OTR",
%                     "GYRO Y OTR",
%                     "GYRO Z OTR",
%                     "GYRO X Saturation",
%                     "GYRO Y Saturation",
%                     "GYRO Z Saturation",
%                     "ACC Failure",
%                     "DRDY FAIL ACC X",
%                     "DRDY FAIL ACC Y",
%                     "DRDY FAIL ACC Z",
%                     "ACCX Saturation",
%                     "ACCY Saturation",
%                     "ACCZ Saturation",
%                     "ADC Data Valid",
%                     "Reset Command"];
% 
%     Alarm_numbers = [1,2,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,23,30];
%     
%     fileID = fopen(fullfile(analysis_result_folder,'MBIT_ANALYSIS_REPORT.txt'),'w');
%     fprintf(fileID,'Master BIT WORD analysis\n');
%     jj=1;
%     for ii=Alarm_numbers
%         if sum(bitget(MASTER_BIT,ii))
%             fprintf(fileID,'\nMBIT %d - Alarm type: %s - Occurence: %d',ii,Alarm_types(jj),sum(bitget(MASTER_BIT,ii)));
%         end
%         jj=jj+1;
%     end
%     fclose(fileID);

    
    function s_mean = segmented_mean(data,size)
        % data length must be divisible by the size
        data=data(1:floor(length(data)/size)*size);

        s_mean = mean(reshape(data,size,[]));
        
    end

    function T = GyroRefTemp(LSB)
    
        LSB = LSB*5/2^32;
        
        p =       [0.361473371781292
                  -1.566846738695409
                   0.187675198800565
                   6.287065866742099
                  -3.938228866110220
                  -8.952629447534866
                   7.726066395243683
                   2.518785023789855
                  19.683074808820070
                  28.417616914623050];
        
        T = polyval(p,LSB);
    
    end

    function T = Steinhart_hart(LSB)

            V=LSB*5/2^32+2.5;
            R=10000*V./(4.096-V);

            A=0.001127081630318;
            B=0.000234449008267;
            C=0.000000086494566;

            T = 1./(A+B*log(R)+C*(log(R).^3))-273.15;

    end

    function T = Steinhart_hart_laser(LSB)

            V=LSB*5/2^32/(1+6.8/10);
            R=10000*V./(1.5-V);

            A=0.001127081630318;
            B=0.000234449008267;
            C=0.000000086494566;

            T = 1./(A+B*log(R)+C*(log(R).^3))-273.15;

    end
    
    
    function T = AccRefTemp(LSB,type)
    
        
        if type == "QUARTZ"
    
            LSB=LSB/2^8;
    
        p=    [2.454778446536727e-12
               6.963563717099972e-06
              -1.255435724692732e+02]; 
    
            T = polyval(p,LSB);
        
        elseif type == "MEMS"
    
            p(1)= 0;                     %k=2;
            p(2)= -2.91038304567337e-07; %k=1;
            p(3)= -297.5;                %k=0;   
        
            T = polyval(p,LSB);
    
        elseif type == "TR"
            
            LSB=LSB/2^8;
    
            LSB = (LSB*1000 + 1000*2^23)./(2^23 * 2.4 - LSB);
             
            T = 28.54*(LSB./1000).*(LSB./1000).*(LSB./1000) - 158.5*(LSB./1000).*(LSB./1000) + 474.8*(LSB./1000) - 319.85;
      
        else
        
            T=NaN;
        
        end
    
    end

    function D1st = Derivative1st(in_vec,order)
            
        D1st=(in_vec-circshift(in_vec,order))/(order/60); % 1/min
        
        C = (D1st(:,2*order+round(order/2))-D1st(:,2*order+1))/round(order/2);
        D1st(1:2*order+1) = linspace(D1st(2*order+1)-C*2*order,D1st(2*order+1),2*order+1);

    end

    function D2nd = Derivative2nd(in_vec,order)

        D2nd= (in_vec-2*circshift(in_vec,5)+circshift(in_vec,10))/(order/60)^2;
        
        C= (D2nd(:,3*order+round(order/2))-D2nd(:,3*order+1))/round(order/2);
        D2nd(1:3*order+1) = linspace(D2nd(3*order+1)-0.5*C*3*order,D2nd(3*order+1),3*order+1);
    
    end


    function crc=CRC16CCIT(data,len)
    
    Crc_ui16LookupTable=uint16([0,4129,8258,12387,16516,20645,24774,28903,33032,37161,41290,45419,49548,...
        53677,57806,61935,4657,528,12915,8786,21173,17044,29431,25302,37689,33560,45947,41818,54205,...
        50076,62463,58334,9314,13379,1056,5121,25830,29895,17572,21637,42346,46411,34088,38153,58862,...
        62927,50604,54669,13907,9842,5649,1584,30423,26358,22165,18100,46939,42874,38681,34616,63455,...
        59390,55197,51132,18628,22757,26758,30887,2112,6241,10242,14371,51660,55789,59790,63919,35144,...
        39273,43274,47403,23285,19156,31415,27286,6769,2640,14899,10770,56317,52188,64447,60318,39801,...
        35672,47931,43802,27814,31879,19684,23749,11298,15363,3168,7233,60846,64911,52716,56781,44330,...
        48395,36200,40265,32407,28342,24277,20212,15891,11826,7761,3696,65439,61374,57309,53244,48923,...
        44858,40793,36728,37256,33193,45514,41451,53516,49453,61774,57711,4224,161,12482,8419,20484,...
        16421,28742,24679,33721,37784,41979,46042,49981,54044,58239,62302,689,4752,8947,13010,16949,...
        21012,25207,29270,46570,42443,38312,34185,62830,58703,54572,50445,13538,9411,5280,1153,29798,...
        25671,21540,17413,42971,47098,34713,38840,59231,63358,50973,55100,9939,14066,1681,5808,26199,...
        30326,17941,22068,55628,51565,63758,59695,39368,35305,47498,43435,22596,18533,30726,26663,6336,...
        2273,14466,10403,52093,56156,60223,64286,35833,39896,43963,48026,19061,23124,27191,31254,2801,6864,...
        10931,14994,64814,60687,56684,52557,48554,44427,40424,36297,31782,27655,23652,19525,15522,11395,...
        7392,3265,61215,65342,53085,57212,44955,49082,36825,40952,28183,32310,20053,24180,11923,16050,3793,7920]);
    
        ui16RetCRC16 = 65535*ones(size(data,1),1,'uint16');
        for I=1:len
            ui8LookupTableIndex = bitxor(data(:,I),uint8(bitshift(ui16RetCRC16,-8)));
            ui16RetCRC16 = bitxor(Crc_ui16LookupTable(double(ui8LookupTableIndex)+1)',bitshift(ui16RetCRC16,8));
        end
        
        crc=uint16(ui16RetCRC16);

end

end





