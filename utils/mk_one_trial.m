

function [sig, sig_trigger, sig_modulator] = mk_one_trial(mod_freq, df, mod_phase_ref, mod_phase_targ, carr_center_freq)


% Example
%{
mod_freq = 2;
df = 0.1*mod_freq;
mod_phase_ref = 0;
mod_phase_targ = 0;
carr_center_freq = 1000;
[sig, sig_trigger, sig_modulator] = mk_one_trial(mod_freq, df, mod_phase_ref,...
 mod_phase_targ, carr_center_freq);
fs = 44100
player = audioplayer(sig, fs);
play(player);
%}

fs = 44100;
ncycles_ref = 8;
on_ramp_samples = round(0.025 * fs);
off_damp_samples = round(0.5/mod_freq * fs);
ref_start_trigger =  1;
ref_end_trigger = 0.6;
[sig_ref, sig_trigger_ref, sig_modulator_ref] = mk_fm_stimulus(mod_freq,...
    ncycles_ref, mod_phase_ref, carr_center_freq, on_ramp_samples, off_damp_samples,...
    ref_start_trigger, ref_end_trigger);

ncycles_silence = 8;
[sig_silence] = mk_silence_stimulus(mod_freq, ncycles_silence);


mod_freq_targ = mod_freq + df*mod_freq;
ncycles_targ = 4;
on_ramp_samples_targ = round(0.5/mod_freq_targ * fs); 
off_damp_samples_targ = round(0.025 * fs);
targ_end_trigger = 0.4;
if df > 0
    targ_start_trigger =  0.8;
elseif df < 0
    targ_start_trigger =  0.7;
end

[sig_targ, sig_trigger_targ, sig_modulator_targ] = mk_fm_stimulus(mod_freq_targ,...
    ncycles_targ, mod_phase_targ, carr_center_freq, on_ramp_samples_targ, off_damp_samples_targ,...
    targ_start_trigger, targ_end_trigger);


sig = [sig_ref, sig_silence, sig_targ];
sig_trigger = [sig_trigger_ref, zeros(1, length(sig_silence)), sig_trigger_targ];
sig_modulator = [sig_modulator_ref, zeros(1, length(sig_silence)), sig_modulator_targ];

