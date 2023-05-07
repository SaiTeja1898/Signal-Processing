detectspeech;
Mypitch=zeros(1,size(segments,2));
tic
for i=1:size(segments,2)
    %if(isInBetween(idx,i,windowsize))
    y=segments(:,i);%x(((windowsize*(i-1))+1):windowsize*(i));
    if(energies(i)<0.05*max(energies))
        continue;%A silence signal
    end
    %center compress and clip
    clip_threshold=0.3*max(abs(y));
    for j=1:length(y)
        if y(j)>=clip_threshold
            y(j)=y(j)-clip_threshold;%clip
        elseif y(j)<=-clip_threshold
            y(j)=y(j)+clip_threshold;%clip
        else
            y(j)=0;%compress
        end
    end
    [acf,lags] = xcorr(y);%Autocorrelation between two clc signals
    %The obtained autocorrelation is symmetric around center[-windowsize,windowsize]
    center_peak=windowsize+1;
    %to get a lag that is greater than the min expected lag of voice signal based on maximum frequency
    %Considering For male voice(20), For female voice(32)
    shift=20;
    acf=acf(center_peak+shift:end);
    %acf(acf<=0)=0;
    %Find peaks at a minimum distance of shift specified
    [pks,locs] = findpeaks(acf,'MinPeakDistance',shift);%,'MinPeakProminence',5
    [maxxm,loca]=max(pks);%Find the maximum in these peaks
%   [mini,peaks]=min(fs./diff(locs));
    if(~isempty(loca))%loca empty implies its a silence signal.
        Mypitch(i)=fs/(shift+locs(loca));%adding shift to the obtained lag value as we eliminated to remove outliers.
    end
    %end
end
Mypitch = medfilt1(Mypitch,5);%1D median filter of order 5 for smoothening
toc
hold on
plot(1:80:24000,p1);
plot(1:windowsize:24000,Mypitch);
xlabel('sample number');
ylabel('Pitch');
legend('Original','Pitch using autocorrelation method')
title('s1.wav')
hold off