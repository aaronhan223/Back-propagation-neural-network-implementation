clc;close all; clear all;warning off;
addpath(genpath('audioAnalysisLibraryCode'));


% Read music files
% foldername='Project Music_Timbre';
% [datacell,typecell,typemat,fs0]=readfun1nm(foldername);
% save data.mat datacell typecell typemat fs0;
load data.mat;
% Feature extraction
%//Define sampling parameters
win  = 5;        % short-term window size (in seconds) 
step = 8;        % short-term step (in seconds)       
n=length(datacell);
Fmat=[];
for i=1:n
    signal=datacell{i,1};
    Features = musicfeatureExtraction(signal, fs0, win, step);
    % Combine features of frames in 6 ways: 'mean'    'median'    'std'    'stdbymean'    'max'    'min'
    mean_feature   = mean(Features, 2);
    median_feature = median(Features, 2);
    std_features   = std(Features, 0, 2);
    stdbymean_features = std(Features, 1, 2);
    max_features = max(Features, [], 2);
    min_features = min(Features, [], 2);
    %//Merge into a line
    sampleFeature = [mean_feature', median_feature', std_features', stdbymean_features', max_features', min_features'];
    Fmat=[Fmat;
        sampleFeature];
end
% Eliminate all-zero columns
n=size(Fmat,2);
m=size(Fmat,1);
indexdelet=zeros(1,n);
for i=1:n
    if sum(Fmat(:,i)==0)==m
        indexdelet(i)=1;
    end
end
Fmat(:,indexdelet==1)=[];



save dataforBP.mat Fmat typemat;

rmpath(genpath('audioAnalysisLibraryCode'));


