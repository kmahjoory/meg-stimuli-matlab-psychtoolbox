
function [sig, sig_trigger, sig_modulator, t] = mk_fm_stimulus(mod_freq, ncycles, mod_phase, carr_center_freq, on_ramp_samples, off_damp_samples, start_trigger, end_trigger)
        
% Example
%{
mod_freq = 2; 
ncycles = 8;
mod_phase = 0;
carr_center_freq = 1000;
on_ramp_samples = round(0.025 * 44100);
off_damp_samples = round(0.5/mod_freq * 44100);
start_trigger =  0.7;
end_trigger = 0.4;
[sig, sig_trigger, sig_modulator, t] = mk_fm_stimulus(mod_freq, ncycles, mod_phase,...
 carr_center_freq, on_ramp_samples, off_damp_samples, start_trigger,...
 end_trigger);

%}

fs = 44100;
carr_freq_range = 400;
ncomps = 30;
mod_depth = 0.63;

fsro2 = round(fs / (mod_freq*2));
fs_interp = round(fsro2*2 * mod_freq); % sampling frequency 
nsamples = round(fsro2*2 * ncycles);

                         
                         
sig_ramp = mk_linramp_nsamples(on_ramp_samples, fs, 0);
sig_damp = mk_lindamp_nsamples(off_damp_samples, fs, 0);

sig = mk_complex_carrier_fm(carr_center_freq, carr_freq_range, ncomps, mod_freq,...
                             mod_depth, mod_phase, fs_interp, nsamples);
sig(1, 1:on_ramp_samples) = sig(1, 1:on_ramp_samples) .* sig_ramp;
sig(1, end-off_damp_samples+1:end) = sig(1, end-off_damp_samples+1:end) .* sig_damp;
% % new
sig = sig - mean(sig);
sig = sig / max(abs(sig));

sig_trigger = zeros(1, length(sig));
sig_trigger(1, 1) = start_trigger;
sig_trigger(1, end) = end_trigger;

t = [0:length(sig)-1] / fs_interp;
sig_modulator = sin(2*pi*mod_freq*t + mod_phase);


