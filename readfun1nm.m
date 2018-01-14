function [datacell,typecell,typemat,fs0]=readfun1nm(foldername)
%% Read 1-n-m data
%% Read the file inside the folder
path1 = mfilename('fullpath');%Obtain the path for current .mat file
index1= strfind(path1,'\');
path1=path1(1:index1(end));
%Result=D:\Program Files\MATLAB\MATLAB Production Server\R2012b\work\curve\ Note£ºinclude the last¡°\¡±

% foldername=char('data\');
path2=[path1,foldername(1,:)];
subdir=dir(path2); % First determine the sub-folder
% subdir=subdir(3:end);%Remove two hidden files

N1=5;% Starting seconds
N2=10;% Ending seconds
fs0=44100;

L=length(subdir)-2;
datacell={};
typemat=[];
gen=1;
typeID=0;
typecell={};
wait_hand = waitbar(0,'running...', 'tag', 'TMWWaitbar');
for i=1:length(subdir)
    if (isequal(subdir(i).name,'.') || isequal(subdir(i).name,'..') || ~subdir(i).isdir)%Skip if not a directory
        continue;
    end
    typeID=typeID+1;
    typecell{typeID,1}=subdir(i).name;
    subdirpath=fullfile(path2,subdir(i).name,'*.mp3');
    filestuct=dir(subdirpath);%find the file whose suffix is MP3 in the sub-folder
    %go through each file
    for j=1:length(filestuct)
        typemat=[typemat;
            typeID];
        filename=fullfile(path2,subdir(i).name,filestuct(j).name);
        [sampledata,fs] = audioread(filename);% Read MP3 data
        data1=sampledata(N1*fs:N2*fs,1);% Intercept data
        if fs~=fs0
            data1=resample(data1,fs0,fs);
        end
        datacell{gen,1}=data1;
        gen=gen+1;
    end
    waitbar(i/L,wait_hand);
end
delete(wait_hand);

