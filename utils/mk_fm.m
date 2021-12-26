
function sig =  mk_fm(carr_freq, mod_freq, mod_depth, mod_phase, fs, nsamples)
    
% This function makes frequency modulated signals.
    % Sine modulated is used here
    
    % INPUTS
    % carr_freq: carrier frequency e.g. 1000 Hz
    % mod_freq: modulating frequency e.g. 2 Hz
    % mod_depth: modulation depth. between [0, 1] (See Picton, page 193)
    % mod_phase: onset phase of the modulator e.g. pi or 0
    % fs: sampling frequency. e.g. 44100 Hz
    % nsamples: length in samples. e.g. 2*fs to make a 2 second sound
    
    % OUTPUTS
    % sig: frequency modulated signal!
    
    % EXAMPLE
    %{
    fs = 44100;
    carr_freq = 1000;
    mod_freq = 2;
    mod_depth = 0.63;
    mod_phase = 0;
    sig1 = mk_fm(carr_freq, mod_freq, mod_depth, mod_phase, fs, 5*fs);
    
    player = audioplayer(sig1, fs);
    play(player);
    %}
    
    mod_index = (mod_depth * carr_freq) / (2 * mod_freq);
    t = 1/fs : 1/fs: nsamples/fs;
    phi = - mod_index * cos(2*pi*mod_freq*t + mod_phase); % See Picton, page 193
    sig = cos(2*pi*carr_freq*t + phi);
    
    