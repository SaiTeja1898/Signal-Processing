clc;clear;close all;
%% Importing Data from mat file
newData1 = load('p1','-mat');
vars = fieldnames(newData1);
for i = 1:length(vars)
    assignin('base', vars{i}, newData1.(vars{i}));
end

newData2 = load('p2','-mat');
vars = fieldnames(newData2);
for i = 1:length(vars)
    assignin('base', vars{i}, newData2.(vars{i}));
end

%% Speech Detection
[x, fs] = audioread('s1.wav');
x=lowpass(x,900,fs);%cutoff frequency specified in the referred paper
windowtime=10e-3;
windowsize=round(windowtime*fs);
%Detect speech based on the specified window and overlap length
%window=hann(windowsize,'periodic');
% window=rectwin(windowsize);
% percentOverlap=35;
% overlap = round(windowsize*percentOverlap/100);
% [idx,~]=detectSpeech(x,fs,'Window',window,"OverlapLength",overlap);
%segment the signal into 10ms segments
segments=buffer(x,windowsize);
%Calculate absolute means for each segment
energies = mean(abs(segments), 1);%row vector containing sum of all columns