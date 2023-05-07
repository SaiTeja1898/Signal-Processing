detectspeech;
Mypitch=zeros(1,size(segments,2));
tic
for i=1:size(segments,2)
    %if(isInBetween(idx,i,windowsize))
        y=segments(:,i);%A 10ms segment
        if(energies(i)<0.05*max(energies))
            continue;%A silence signal
        end
        [z,zm] = rceps(y);%cepstrum signal
%     z = ifft(log(abs(fft(y))));
 %       plot(z);
        %Finding the pitch of the signal
        shift=20;%20 for female and 32 for male voice
        %Find peaks at a minimum distance of shift specified
        [pks,locs] = findpeaks(z,'MinPeakDistance',shift);%,'MinPeakProminence',5
        [Mypitch(i),~]=min(fs./diff(locs));%Find the fundamental period based on diff of quefrency 
    %end
end
Mypitch = medfilt1(Mypitch, 5);%1D median filter of order 5
toc
hold on
plot(1:80:24000,p1);
plot(1:windowsize:24000,Mypitch);
xlabel('sample number');
ylabel('Pitch');
title('s1.wav')
legend('Original','Pitch with cepstral method')
hold off
