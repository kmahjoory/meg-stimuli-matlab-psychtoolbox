function damp =  mk_lindamp_nsamples(dur_in_samples, fs, mk_plot)

% This function makes a damping signal.
    % % endpoint is included
    
    % INPUTS:
    % dur_in_samples: duration of damp in samples e.g. for a 2-second damp: fs*2
    % fs: sampling frequency. e.g. 44100 Hz
    % mk_plot: to make plots or not. Set it to either 0 or 1
    
    % OUTPUTS:
    % damp: damping signal!
    
    % EXAMPLE 1:
    %{
    fs = 44100;
    dur = round(0.025*fs) %  25 ms
    mk_plot = 1
    damp = mk_lindamp_nsamples(dur, fs, mk_plot)
    %}
    



t = 1/fs : 1/fs : dur_in_samples/fs;
ramp = linspace(1/fs, 1, dur_in_samples);
damp = fliplr(ramp);
if mk_plot==1
    plot(t, damp);
    xlabel('time (s)')
end