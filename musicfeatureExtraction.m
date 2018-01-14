function Features = musicfeaturExtraction(signal, fs, win, step)
%The following functions are used for extract music features
% Features include: 
%         chroma_vector 
%         energy
%         energy entropy
%         harmonic
%         Mel Frequency Cepstrum Coefficient£¬MFCC
%         spectral centroid
%         spectral entropy
%         spectral flux
%         spectral rolloff
%         zero crossing rate
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read music files: signal is music signal, fs is sampling frequency in Hz:
% which is hoe many times it viberate per second
% hfile = 'Andy Grammer - Honey,I''m Good..wav';

% [signal, fs] = wavread(hfile);

% win  = 10;        % short-term window size (in seconds) 
% step = 10;        % short-term step (in seconds)         

if (size(signal,2)>1)
    signal = (sum(signal,2)/2); % convert dual channel sugnal to MONO
    
end

% convert window length and step from seconds to samples
windowLength = round(win * fs);
step = round(step * fs);

curPos = 1;
L = length(signal);

% compute the total number of frames:
numOfFrames = floor((L - windowLength)/step) + 1;   
% number of features to be computed:
numOfFeatures = 35;
Features = zeros(numOfFeatures, numOfFrames); 
Ham = window(@hamming, windowLength);                 % Using hamming function to get Hamming Window
mfccParams = feature_mfccs_init(windowLength, fs);

for i = 1:numOfFrames % for each frame
    % get current frame:
    frame  = signal(curPos:curPos + windowLength - 1); % get frame signal
    frame  = frame .* Ham;
    frameFFT = getDFT(frame, fs);
    
    if (sum(abs(frame))> eps)
        % compute time-domain features: 
        Features(1,i) = feature_zcr(frame);                 % zero crossing rate
        Features(2,i) = feature_energy(frame);              % energy
        Features(3,i) = feature_energy_entropy(frame, 10);  % energy entropy

        % compute freq-domain features: 
        if (i == 1) 
            frameFFTPrev = frameFFT;
        end
        [Features(4,i) Features(5,i)] = ...
            feature_spectral_centroid(frameFFT, fs);                    % spectral centroid
        Features(6,i) = feature_spectral_entropy(frameFFT, 10);         % spectral entropy
        Features(7,i) = feature_spectral_flux(frameFFT, frameFFTPrev);  % spectral flux
        Features(8,i) = feature_spectral_rolloff(frameFFT, 0.90);       % spectral rolloff
        MFCCs = feature_mfccs(frameFFT, mfccParams);                     
        Features(9:21,i)  = MFCCs;                                      % MFCC (13)
        
        [HR, F0] = feature_harmonic(frame, fs);                         % harmonic
        Features(22, i) = HR;
        Features(23, i) = F0;        
        Features(23 + 1:23 + 12, i) = feature_chroma_vector(frame, fs); % chroma_vector (12)
    else
        Features(:,i) = zeros(numOfFeatures, 1);
    end    
    curPos = curPos + step;
    frameFFTPrev = frameFFT;
end
Features(35, :) = medfilt1(Features(35, :), 3);
