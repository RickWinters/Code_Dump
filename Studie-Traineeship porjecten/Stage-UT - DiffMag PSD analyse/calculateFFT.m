function[Faxis,sigF] = calculateFFT(signal,X,Y,nFFTmult)
%Calculates the FFT of a signal, given the signal and the sampling
%frequency or the measurement time
%--------------------------------------------------------------------------
%SYNTAX
%   sigF = calculateFFT(signal,X,Y,nFFTmult)
%   [Faxis,sigF] = calculateFFT(signal,X,Y,nFFTmult)
%--------------------------------------------------------------------------
%OUTPUT
%   Faxis[array]
%                   - frequency axis of the fourier
%   sigF------------[array]
%                   - amplitudes of the frequencies
%--------------------------------------------------------------------------
%INPUT
%   signal----------[array]
%                   - amplitude of the signal
%   X---------------[float]
%                   - Sampling frequency OR measurement time
%   Y---------------['1' or '0']
%                   - 1 if X is measurement time, 0 if X is sampling
%                   frequency
%   nFFTmult--------[integer]
%                   - multiplier for 'zero-padding' of the fft, if n = 10.
%                   the array inputted to the fft function is multiplied in
%                   length by 10, filling in zeros. This reduces the
%                   frequency spacing of the resulting fourier transform.
%                   I.E. the resulting fourier transform is 10 times more
%                   data points on the frequency axis
%                   - optional, default = 1
%--------------------------------------------------------------------------
%DEPENDENCIES
% - none
%--------------------------------------------------------------------------
%Rick Winters, 2017-10-10 
if nargin < 4                                                               % set variables to default Value of not given
    nFFTmult = 1;
end

'creating Faxis'
if Y == 1
    Fsampling = length(signal)/X;                                           % Fsampling is the number of samples divided by the measurement time
else
    Fsampling = X;                                                          
end

nFFT = nFFTmult*length(signal);                                             % The number fft values, zero padding happens if this is bigger than number of samples
Fspacing = Fsampling/nFFT;                                                  % Spacing of the frequency axis
Fnyquist = Fsampling/2;                                                     % Nyquist Frequency,

Fstart = -Fnyquist;                                                         % Setup Frequency axis
Fend = Fnyquist-Fspacing;
Faxis = Fstart:Fspacing:Fend;
ind = find(Faxis >= 1);                                                     % Find the indices of the Faxis that are positive and save these indices
Faxis = Faxis(ind);                                                         % Select only the part that's positve

'calculating fft of signal'
sigF = fftshift(abs(fft(signal',nFFT)))/(length(signal')/2);                % Calculate fft and divide by 0.5*number of samples for correct amplitude 
sigF = sigF(ind,:);                                                         % only the indices that belong to F >= 0
if nargout == 1                                                             
    Faxis = sigF;
end
end