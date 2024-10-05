% SPD.m Plot the spectral density probability of given audio.

% Ref: N. D. Merchant, T. R. Barton, P. M. Thompson, E. Pirotta, D. T. Dakin, 
% and J. Dorocicz, “Spectral probability density as a tool for ambient noise 
% analysis,” The Journal of the Acoustical Society of America, vol. 133, no. 4, 
% pp. EL262–EL267, Apr. 2013, doi: 10.1121/1.4794934.
%% Read wav file
clear; close all; clc
datapath = './data/';
files = dir(fullfile(datapath, '*.wav'));
ADCVOLT = 2.5;
sensitivity = -168;

sig = [];
for ii = 1 : length(files)
    [yy, fs] = audioread(fullfile(datapath, files(ii).name));
    sig = [sig; yy(:, 1) * ADCVOLT];
end

%% Compute spectrogram 
% set up parameters 
% nfft = 1024;              % number of FFT points
% freqRes = 50;            % frequency resolution
% noverlap = nfft/2;      % FFT window overlap
% 
% window = hann(nfft); 
% fAxis = 0 : freqRes : fs / 2;
% 
% [spec, fAxis, tAxis] = spectrogram(sig, window, noverlap, fAxis, fs);
% spec_dB = mag2db(abs(spec)) - sensitivity;

% figure(100) 
% pcolor(tAxis, fAxis, spec_dB);
% shading interp
% colorbar 

%% Compute spectrogram (PSD) 
% set up parameters 
% time resolation, duration of each segment 
dt = 1;                             
N = floor(length(sig) / fs / dt);        % number of segments 
tAxis = 0 : dt : N * dt - 1; 

% frequency resolution
freqRes = 100;                       
fAxis = freqRes : freqRes : fs / 2;       

Pxx = [];
win = [];       % using default window: hanning window 

for ii = 1 : N 
    [pxx, fAxis] = pwelch(sig( ((ii - 1) * dt * fs + 1) : (ii * dt * fs) ), win, 0, fAxis, fs);
    Pxx = [Pxx pxx.'];
end
PxxdB = pow2db(Pxx) - sensitivity; 

% display result 
figure(100);
pcolor(tAxis, fAxis/1000, PxxdB); 
colorbar
xlabel('time (s)')
ylabel('frequency (kHz)')
shading interp


%% Compute spectral probability density 
percentiles = [5, 50, 95];
nFreqBin = length(fAxis); 
splBinEdges = 0 : 200; 
spd.hist = zeros(length(splBinEdges) - 1, nFreqBin);
spd.pdf = zeros(length(splBinEdges) - 1, nFreqBin);
spd.percentiles = percentiles;
spd.percentilesLines = zeros(length(spd.percentiles), nFreqBin); 

for iFreq = 1 : nFreqBin
    freqBinData = PxxdB(iFreq, :); 
    emppdf = histcounts(freqBinData, splBinEdges, 'Normalization', 'probability'); 
    spd.pdf(:, iFreq) = emppdf(:);
    for iP = 1 : length(spd.percentiles) 
        p = spd.percentiles(iP); 
        spd.percentilesLines(iP, iFreq) = prctile(freqBinData, p); 
    end
end

spd.pdf(spd.pdf == 0) = NaN;

%% Display SPD
fH = figure(101);
fH.Position = [100 100 1000 600];
tH = tiledlayout(1, 1, "TileSpacing", "tight", "Padding", "tight");
tH.Units = 'inches'; 
tH.OuterPosition = [0 0 16 9] * 0.5;
aH = nexttile;
pcolor(fAxis/1e3, splBinEdges(2:end), spd.pdf);
shading interp

hold on 
lineStyle = {'--', ':', '-'};
legends = {''};
for iP = 1 : length(spd.percentiles) 
    plot(fAxis/1e3, spd.percentilesLines(iP, :), 'k', 'lineStyle', lineStyle{iP}, 'LineWidth', 1);
    legends{end + 1} = [num2str(spd.percentiles(iP)), '^{th} percentile'];
end

xlabel('frequency (kHz)')
ylabel('SPL (dB re 1 \muPa/Hz)')
ylim([20 90])
grid on
h = colorbar;
h.Label.String = 'empirical probability density';
legend(legends)
%% Save SPD
% exportgraphics(fH, "SPD.png", 'Resolution', 600)