clc
clear
close all;

%<----Importing Data from mat file---->
newData1 = load('rf_data','-mat');
vars = fieldnames(newData1);
for i = 1:length(vars)
    assignin('base', vars{i}, newData1.(vars{i}));
end

figure;
for i=1:5
    axis tight;
    subplot(5,1,i)
    stem(z,rf_data(:,i))
end

%<----Creating the transmitted chirp pulse---->
fs=20e6;%Sampling frequency
chir=chirp(0:(1/fs):10e-6,1.5e6,10e-6,4.5e6);
%chir(201:500)=0;
figure;
plot(chir)


%<----Correlation processing---->

%Finding Range from clean data
rangeCwithoutsnr=zeros(1,21);
velocityCwo=zeros(1,20);
for i=1:21
    [c,lags]=xcorr(rf_data(:,i),chir);%correlating transmitted signal with received one
    [m,pos]=max(c);%Finding the shift at maximum match
    rangeCwithoutsnr(i)=(pos-500)*(z(2)-z(1))+150;%Range calculation at match
    if i~=1
        %velocity calculation based on displacement and captured time
        velocityCwo(i-1)=(rangeCwithoutsnr(i)-rangeCwithoutsnr(i-1))/(timestamp(i)-timestamp(i-1));
    end
end
figure;
hold on
title('Range of the object from clean data')
xticks(timestamp)
plot(timestamp,rangeCwithoutsnr);

%Finding Range from noisy data
rangeCwithsnr=zeros(1,21);
velocityCw=zeros(1,20);
SNR=5:5:30;
for snr=SNR
    for i=1:21%Getting range graph at every SNR
        y = awgn(rf_data(:,i),snr,'measured');%adding white gaussian noise at specified snr
        [c,lags]=xcorr(y,chir);
        [m,pos]=max(c);
        rangeCwithsnr(i)=(pos-500)*(z(2)-z(1))+150;
        if i~=1
            velocityCw(i-1)=(rangeCwithsnr(i)-rangeCwithsnr(i-1))/(timestamp(i)-timestamp(i-1));
        end
    end
    plot(timestamp,rangeCwithsnr);
end
title('Range with and w/o noise')
legend('No noise','5dB','10dB','15dB','20dB','25dB','30dB');
hold off


%<----End point detection---->
rangeEndpt=zeros(1,21);
velocityEwo=zeros(1,20);

for j=1:21
    Energy=zeros(1,100);%short term magnitude
    %increasing window size may decrease precision of the start and end
    %points
    windowsize=5;%samples per window
    x=rf_data(:,j);
    for i=1:(500/windowsize)
        samplepts=(1+(i-1)*windowsize:(i-1)*windowsize+5);
        %Taking the average of the absolute in a window for threshold
        %comparision
        Energy(i)=mean(abs(x(samplepts)));
    end
    %Energy=Energy.^2;
    %Clearing the noise by taking the average of minimum 30 samples
    Energy=Energy-mean(mink(Energy,30));
    %let threshold be 20% of max received
    threshold=max(Energy)*0.20;
    data=find(Energy>threshold);
    %Finding the start and end points of information
    dstart=data(1);
    dend=data(length(data));%Since data is concentrated in only one frame
    rangeEndpt(j)=((dstart-1)*windowsize*(z(2)-z(1)))+150;
    samplepts=(dstart-1)*windowsize:windowsize:(dend-1)*windowsize;
    if j~=1
        velocityEwo(j-1)=(rangeEndpt(j)-rangeEndpt(j-1))/(timestamp(j)-timestamp(j-1));
    end
end
figure;
xticks(timestamp)
plot(timestamp,rangeEndpt);
title('Range from clean data')

figure;
xticks(timestamp(2:length(timestamp)))
plot(timestamp(2:length(timestamp)),velocityEwo);
title('Velocity from clean data')

rangeEndptwithNoise=zeros(1,21);
velocityEw=zeros(1,20);
SNR=5:5:30;
figure;
hold on
plot(timestamp(2:length(timestamp)),velocityEwo);
for snr=SNR
    for j=1:21
        y=rf_data(:,j);
        [x,var]=awgn(y,snr,'measured');%SNR in dB

        Energy=zeros(1,100);%short term magnitude
        %increasing window size may decrease precision
        windowsize=5;%samples per window
        for i=1:(500/windowsize)
            samplepts=(1+(i-1)*windowsize:(i-1)*windowsize+5);
            Energy(i)=mean(abs(x(samplepts)));
        end
        %Energy=Energy.^2;
        %Clearing the noise by taking the average of minimum 30 samples
        Energy=Energy-mean(mink(Energy,30));

        %let threshold be 20% of max received
        threshold=max(Energy)*0.20;
        data=find(Energy>threshold);

        %Finding frame having atleast 50 consecutive samples
        dend=data(length(data));%Since we know data is concentrated in only one frame
        N = 10;
        x = diff(data)<=3;%Termed as consecutive if the difference is atmost 3
        f = find([false,x]~=[x,false]);
        g = find(f(2:2:end)-f(1:2:end-1)>=N,1,'first');
        dstart = data(f(2*g-1));
        if dstart<1%safety condition
            dstart=1;
        end

        rangeEndptwithNoise(j)=((dstart-1)*windowsize*(z(2)-z(1)))+150;
        if j~=1
            velocityEw(j-1)=(rangeEndptwithNoise(j)-rangeEndptwithNoise(j-1))/(timestamp(j)-timestamp(j-1));
        end

    end
    plot(timestamp(2:length(timestamp)),velocityEw);
end
title('Velocity with and w/o noise')
legend('No noise','5dB','10dB','15dB','20dB','25dB','30dB');
hold off
