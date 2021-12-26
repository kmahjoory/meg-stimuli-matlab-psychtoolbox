
function [sig] = mk_silence_stimulus(mod_freq, ncycles)
        
% Example
%{
mod_freq = 2; 
ncycles = 8;
[sig] = mk_silence_stimulus(mod_freq, ncycles);

%}

fs = 44100;
fsro2 = round(fs / (mod_freq*2));
fs_interp = round(fsro2*2 * mod_freq); % sampling frequency 
nsamples = round(fsro2*2 * ncycles);

sig = zeros(1, nsamples);
                         
