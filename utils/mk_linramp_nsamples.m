function ramp =  mk_linramp_nsamples(dur_in_samples, fs, mk_plot)
    
% This function makes a ramp sigal.
    % % startpoint is included
    
    % INPUTS:
    % dur_in_samples: duration of damp in samples e.g. for a 2-second damp: fs*2
    % fs: sampling frequency. e.g. 44100 Hz
    % mk_plot: to make plots or not. Set it to either 0 or 1
    
    % OUTPUTS:
    % ramp: ramping signal!
    
    % EXAMPLE 1:
    %{
    fs = 44100;
    dur = round(0.025*fs); %  25 ms
    mk_plot = 1;
    ramp = mk_linramp_nsamples(dur, fs, mk_plot)
    %}
    
    
    t = 0 : 1/fs : dur_in_samples/fs - 1/fs;
    ramp = linspace(0, 1-1/fs, dur_in_samples);
    
    if mk_plot==1
        plot(t, ramp);
        xlabel('time (s)')
    end