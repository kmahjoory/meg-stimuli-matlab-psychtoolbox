
function [m] = mk_complex_carrier_fm(carr_center_freq, carr_freq_range, ncomps, mod_freq, mod_depth, mod_phase, fs, nsamples)
% This function makes complex carrier frequency modulated signals.
    % Sine modulated is used here
    
    % INPUTS
    % center_carr_freq: center carrier frequency e.g. 1000 Hz
    % carr_freq_range: carrier frequency range e.g. 200 Hz
    % mod_depth: modulation depth. between [0, 1] (See Picton, page 193)
    % mod_phase: onset phase of the modulator e.g. pi or 0
    % fs: sampling frequency. e.g. 44100 Hz
    % nsamples: length in samples. e.g. 2*fs to make a 2 second sound
    
    % OUTPUTS
    % sig: frequency modulated signal!
    
    % EXAMPLE
    %{
    fs = 44100;
    carr_center_freq = 1000;
    carr_freq_range = 600;
    ncomps = 30;
    mod_freq = 2;
    mod_depth = 0.63;
    mod_phase = 0;
    sig1 = mk_complex_carrier_fm(carr_center_freq, carr_freq_range, ncomps, mod_freq, mod_depth, mod_phase, fs, 6*fs);
    
    player = audioplayer(sig1, fs);
    play(player);
    %}
    

complex = zeros(1, nsamples);
lb = carr_center_freq - (carr_freq_range/2); % lower bound
ub = carr_center_freq + (carr_freq_range/2); % upper bound
comp_freqs = (lb + (ub - lb) * rand(1, ncomps));
amps = 1 - abs((comp_freqs - carr_center_freq)/carr_center_freq);
for icomp = 1:ncomps
    comp = amps(1, icomp) * mk_fm(comp_freqs(1, icomp), mod_freq, mod_depth, mod_phase, fs, nsamples);
    complex = complex + comp;
    m = 0.05 * complex;
end
