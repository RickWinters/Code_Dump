function[dataout] = PhaseSD(time,signal,Fsample,Fac,LPFF)
% This function uses phase sensitive detection on an input signal and
% calculates the amplitude of a certain frequency within that signal by
% multiplying the input signal with a perfect sine wave and phase shifted
% sine wave. Multiple measurements can be put through this function at the
% same time. In that case, 'time' must have the same size as 'signal'.
% every output variable will be a matrix where each row represents the one
% measurement. 
%--------------------------------------------------------------------------
%SYNTAX
% dataout = PhaseSD(time,signal,Fsample,Fac)
%--------------------------------------------------------------------------
%OUTPUT
% dataout--[structure]
%          - dataout.X------------> [array], 
%                                   - Input signal multiplied by perfect 
%                                     sine wave of Fac.
%          - dataout.Y------------> [array], 
%                                   - Input signal multiplied by perfect, 
%                                     90 degree phase shifted, sine wave 
%                                     of Fac.
%          - dataout.Z------------> [array], 
%                                   - X + i.*Y passed through a lowpass 
%                                     filter.
%          - dataout.Z_unfiltered-> [array], 
%                                   - X + i.*Y
%          - dataout.Fac_amp------> [array], 
%                                   - Estimated amplitude of the Fac sine 
%                                     wave over time.
%          - dataout.R------------> [float], 
%                                   - Mean amplitude accros whole signal
%          - dataout.phi----------> [float], 
%                                   - Phase of Fac frequency in input 
%                                     signal.
%          - dataout.amp----------> [array], 
%                                   - Unfiltered amplitude over time,
%                                     calculated as sqrt(X^2 + Y^2).                             
%          - dataout.phase--------> [array], 
%                                   - Phase shift over time.
%          - dataout.signal_ref---> [array], 
%                                   - Perfect sine wave of Fac.
%          - dataout.signal_ref90-> [array], 
%                                   - Phase shifted sine wave of Fac.
%--------------------------------------------------------------------------
%INPUT
% time------------------------------[float or array]
%                                   - Either the time array or the
%                                     measurement time as 1 value. When    
%                                     the measurement time is given the
%                                     time array is created automatically.
% signal----------------------------[array]
%                                   - Input signal to be put through the
%                                     algorithm.
% Fsample---------------------------[float]
%                                   - Sampling frequency of input signal,
%                                     needed to create the reference 
%                                     signals.
% Fac-------------------------------[float]
%                                   - Frequency of wich the amplitude in
%                                     the input signal has to be known.
% LPFF------------------------------[float]
%                                   - Low Pass Filter Frequency
%                                   - Optional, default = 20
%--------------------------------------------------------------------------
%DEPENDENCIES
% none
%--------------------------------------------------------------------------
%Rick Winters, 2017-11-21


'starting phase sensitive detection'                                        % updating the user through the command window
if nargin < 5                                                               % set default values if needed
    LPFF = 20;
end
PSD_filt_N = 3;

if length(time) == 1                                                        % if the measurement time is given, create the time array
    dt = 1/Fsample;
    tend = time;
    time = [dt:dt:tend];
end

if size(signal,2) > size(signal,1)                                          % if multiple signals are given, transpose the matrices so that every column is a measurement
    time = time';
    signal = signal';
end

'Creating reference signals'
signal_ref = sin(2*pi*Fac.*time);                                           % create reference signal with an amplitude of 1
lag = floor((Fsample / Fac)/4);                                             % calculate 90 degree lag
signal_ref90 = circshift(signal_ref,[lag 0]);                               % create phase shifted reference signal

'Calculating PSD components'
X = signal.*signal_ref;                                                     % PSD components
Y = signal.*signal_ref90;
Z_unfiltered = X + 1i.*Y;                                                   % Z = X +i*Y

'Performing lowpass filter'
Fnorm = LPFF./(Fsample(1)./2);                                              % Normalized frequency
[b,a] = butter(PSD_filt_N,Fnorm,'low');                                     % Butterworth filter components
Z = filtfilt(b,a,Z_unfiltered);                                             % apply filter

'Calculating variables'
R = mean(2.*abs(Z(length(Z)/2:end)));                                       % mean of amplitude, assuming the Fac has the same amplitude over time
phi = mean(angle(Z(length(Z)/2:end)));                                      % phase shift of Fac component in the input signal
amp = sqrt(X.^2 + Y.^2);                                                    % unfiltered amplitude over time
phase = atand(Y./X);                                                        % phase shift in degrees over time

dataout.X = X';                                                             % create dataout structure, such that for every variable each row represents a measurment
dataout.Y = Y';
dataout.Z = Z';
dataout.Z_unfiltered = Z_unfiltered';
dataout.Fac_amp = (abs(Z).*2)';
dataout.R = R;
dataout.phi = phi';
dataout.amp = amp';
dataout.phase = phase';
dataout.signal_ref = signal_ref';
dataout.signal_ref90 = signal_ref90';
dataout.LPFF = LPFF;
'done'