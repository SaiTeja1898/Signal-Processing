%BPM detection from QRS complex of an ECG signal
close all;clear;
ECG_data=load('ecg_1.txt');
ECG_org=ECG_data;
fs=360;%sampling frequency
plot(ECG_data)
%plotting fraction time period from each stage to see the improvement
hold on;
Stages=7;
StageCount=1;
figure;%subplot(Stages,1,1)
plot(ECG_data(1:1600))
xlabel('Sample Number')
ylabel('Amplitude')
title('Plot of first 1600 samples')

ECG_data = ECG_data - mean (ECG_data );%removing dc    
ECG_data = ECG_data/ max( abs(ECG_data )); % normalize to one
StageCount=StageCount+1;
figure;%subplot(Stages,1,StageCount)
plot(ECG_data(1:1600))
xlabel('Sample Number')
ylabel('Amplitude')
title('Normalised signal')

%% Preprocessing
%Linear filtering

%Low pass filter
% b=[1 zeros(1,5) -2 zeros(1,5) 1];
% a=[1 -2 1];
% ECG_data=filter(b,a,ECG_data);
ECG_data=lowpass(ECG_data,15,fs);
StageCount=StageCount+1;
figure;%subplot(Stages,1,StageCount)
plot(ECG_data(1:1600))
xlabel('Sample Number')
ylabel('Amplitude')
title('After Low pass filter')
%High pass filter
% b=[-1 zeros(1,15) 32 zeros(1,15) 1];
% a=[1 1];
% ECG_data=filter(b,a,ECG_data);
ECG_data=highpass(ECG_data,5,fs);
StageCount=StageCount+1;
figure;%subplot(Stages,1,StageCount)
plot(ECG_data(1:1600))
xlabel('Sample Number')
ylabel('Amplitude')
title('After High pass filter')

%Derivative filter
b=[1 2 0 -2 -1];
a=1;
ECG_data=(fs/8)*filter(b,a,ECG_data);
StageCount=StageCount+1;
figure;%subplot(Stages,1,StageCount)
plot(ECG_data(1:1600))
xlabel('Sample Number')
ylabel('Amplitude')
title('After Derivative filter')

%Non-linear filtering
%Squaring data
ECG_data=ECG_data.^2;
ECG_data=ECG_data(2+[1:length(ECG_data)-2]);%accounting for the delay due to differentiator
StageCount=StageCount+1;
figure;%subplot(Stages,1,StageCount)
plot(ECG_data(1:1600))
xlabel('Sample Number')
ylabel('Amplitude')
title('Point to Point squaring')

%Moving-Window integration
N=30;
b=[ones(1,N+1)];
a=N+1;
% ECG_data=[ECG_data; zeros((N/2),1)];
ECG_data=filter(b,a,ECG_data);
ECG_data=ECG_data((N/2)+[1:length(ECG_data)-(N/2)]);%accounting for the delay due to integrator
StageCount=StageCount+1;
figure;%subplot(Stages,1,StageCount)
plot(ECG_data(1:1600))
xlabel('Sample Number')
ylabel('Amplitude')
title('After Moving window integration')
%% Detection
% figure;
% [R_val,R_Locs]=findpeaks(ECG_data,'MinPeakHeight',0.2*max(ECG_data),'MinPeakDistance',100);
% findpeaks(ECG_data(10000:30000),'MinPeakHeight',0.2*max(ECG_data),'MinPeakDistance',100);
% hold on;
% plot(ECG_org(1:1600))
% plot(R_Locs(1:5)-24-7,ECG_org(R_Locs(1:5)-24-7),'^','MarkerSize',8,...
%     'MarkerEdgeColor','red', 'MarkerFaceColor',[1 .6 .6])

%detecting the end points of qrs complex
QRS_complex=ECG_data>0.2*max(ECG_data);%window of the complex
start_QRS=find(diff([0; QRS_complex; 0])==1);%gives start of QRS as here the data changes from 0 to 1
unique(start_QRS);
end_QRS=find(diff([0; QRS_complex; 0])==-1);%gives end of QRS as here the data changes from 1 to 0
start_QRS=start_QRS;
end_QRS=end_QRS;

% hold on;
% plot(ECG_org(1:1600))
% plot(start_QRS(1:5)-24,ECG_org(start_QRS(1:5)-24),'^','MarkerSize',8,...
%     'MarkerEdgeColor','red', 'MarkerFaceColor',[1 .6 .6])
% plot(end_QRS(1:5)-24,ECG_org(end_QRS(1:5)-24),'s','MarkerSize',8,...
%     'MarkerEdgeColor','red', 'MarkerFaceColor',[1 .6 .6])
% QRS_interval=((end_QRS-start_QRS));%Subtracting integrator length as it represents the length of straight line
% QRS_interval=QRS_interval./360;%to continuous time
% figure;

for i=1:length(start_QRS)
    [R_val(i),R_loc(i)]=max(ECG_org(start_QRS(i):end_QRS(i)));
    R_loc(i)=R_loc(i)-1+start_QRS(i);
    [Q_val(i),Q_loc(i)]=min(ECG_org(start_QRS(i):R_loc(i)));
    Q_loc(i)=Q_loc(i)-1+start_QRS(i);
    [S_val(i),S_loc(i)]=min(ECG_org(R_loc(i):end_QRS(i)));
    S_loc(i)=S_loc(i)-1+R_loc(i);
end
figure;
hold on;
plot(ECG_org(1:1600))
plot(start_QRS(1:6),ECG_org(start_QRS(1:6)),'>','MarkerSize',8,...
    'MarkerEdgeColor','red', 'MarkerFaceColor',[1 .6 .6])
plot(Q_loc(1:6),ECG_org(Q_loc(1:6)),'^','MarkerSize',8,...
    'MarkerEdgeColor','red', 'MarkerFaceColor',[1 .6 .6])
plot(R_loc(1:6),ECG_org(R_loc(1:6)),'<','MarkerSize',8,...
    'MarkerEdgeColor','red', 'MarkerFaceColor',[1 .6 .6])
plot(S_loc(1:6),ECG_org(S_loc(1:6)),'s','MarkerSize',8,...
    'MarkerEdgeColor','red', 'MarkerFaceColor',[1 .6 .6])
plot(end_QRS(1:6),ECG_org(end_QRS(1:6)),'*','MarkerSize',8,...
    'MarkerEdgeColor','red', 'MarkerFaceColor',[1 .6 .6])
legend('ECG data','QRS complex start','Q','R','S','QRS complex end')
title('Detection of QRS locations')
xlabel('Sample Number')
ylabel('Amplitude')
figure;
RR_diff=diff(R_loc)./fs;
BPM=60./RR_diff;%Beats per minute
histogram(RR_diff,10);
ylabel('count');
xlabel('difference in seconds')
title('RR peak difference')
N=8;
b=[ones(1,N+1)];
a=N+1;
BPMa=filter(b,a,BPM);
figure;
plot([1:length(BPMa)]./fs,BPMa);
ylabel('BPM');
xlabel('time(seconds)')
title('BPM with an average over last 8 samples')
xlim tight
Num=RR_diff(1:length(RR_diff)-1);
Den=RR_diff(2:length(RR_diff));
RR_change=Num./Den;
figure;
histogram(RR_change,30)
title('RR change')
ylabel('Count');
xlabel('Fractional change in successive RR interval')
figure;
QRS_interval=((end_QRS-start_QRS));
QRS_interval=QRS_interval./fs;%to continuous time

histogram(QRS_interval,13);
title('QRS interval')
ylabel('Count');
xlabel('QRS interval (secs)')
figure
hold on
plot(ECG_org)
plot(start_QRS,ECG_org(start_QRS),'>','MarkerSize',8,...
    'MarkerEdgeColor','red', 'MarkerFaceColor',[1 .6 .6])
plot(Q_loc,ECG_org(Q_loc),'^','MarkerSize',8,...
    'MarkerEdgeColor','red', 'MarkerFaceColor',[1 .6 .6])
plot(R_loc,ECG_org(R_loc),'<','MarkerSize',8,...
    'MarkerEdgeColor','red', 'MarkerFaceColor',[1 .6 .6])
plot(S_loc,ECG_org(S_loc),'s','MarkerSize',8,...
    'MarkerEdgeColor','red', 'MarkerFaceColor',[1 .6 .6])
plot(end_QRS,ECG_org(end_QRS),'*','MarkerSize',8,...
    'MarkerEdgeColor','red', 'MarkerFaceColor',[1 .6 .6])
legend('ECG data','QRS complex start','Q','R','S','QRS complex end')
title('QRS locations')
