% FCM.m Frequency cross correlation matrix 
%% Read wave file
clear; close all; clc
% [yy, fs] = audioread('6603_240605105635_128000_0_000231_F8.wav');
[yy, fs] = audioread('demo.wav'); 
ADCVOLT = 2.5;
y = yy(:, 1) * ADCVOLT;
sensitivity = -168;

%% Compute spectrogram (PSD) 
% set up parameters 
% time resolation, duration of each segment 
dt = 2;                             
N = floor(length(y) / fs / dt);        % number of segments 
tAxis = 0 : dt : N * dt - 1; 

% frequency resolution
freqRes = 10;                       
fAxis = freqRes : freqRes : fs / 2;       

Pxx = [];
win = [];       % using default window: hanning window 

for ii = 1 : N 
    [pxx, fAxis] = pwelch(y( ((ii - 1) * dt * fs + 1) : (ii * dt * fs) ), win, 0, fAxis, fs);
    Pxx = [Pxx pxx.'];
end
Pxx = pow2db(Pxx) - sensitivity; 

% display result 
figure(200);
pcolor(tAxis, fAxis/1000, Pxx); 
colorbar
xlabel('time (s)')
ylabel('frequency (kHz)')
shading interp

%% Compute FCM 
fcm = corrcoef(Pxx.'); 
figure(201);
pcolor(fAxis/1e3, fAxis/1e3, fcm); 
shading interp
xlabel('frequency (kHz)')
ylabel('frequency (kHz)')
colorbar;

