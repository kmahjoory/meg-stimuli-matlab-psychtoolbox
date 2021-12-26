
function [T_shuffled] = mk_one_block(dfm)

%{
dfm = 0.1
[T_shuffled] = mk_one_block(dfm);
sigs = T_shuffled.sigs;
sigs_trigger = T_shuffled.sigs_trigger;
fs = 44100;
player = audioplayer(sigs{10, 1}, fs);
play(player);
%}



%write_path = '';
fs = 44100;
mod_freq_all = [1, 1.5,  2,  2.5, 3, 3.5, 4];
dfm_all = [-abs(dfm), abs(dfm)];
phase_ref_all = [0, pi];
phase_targ_all = [0, pi];
%freq_match_all = ['increase', 'decrease'];
carr_freq_all = [800, 900, 1000, 1100, 1200];

ntrials_in_block = length(mod_freq_all)* length(dfm_all)* length(phase_ref_all)* length(phase_targ_all);
sigs = cell(ntrials_in_block, 1);
sigs_trigger = cell(ntrials_in_block, 1);
dmodFreq = nan(ntrials_in_block, 1);
modFreq = nan(ntrials_in_block, 1);
phaseRef = nan(ntrials_in_block, 1);
phaseTarg = nan(ntrials_in_block, 1);
centerFreq = nan(ntrials_in_block, 1);
freqMatch = cell(ntrials_in_block, 1);
onoffTimes = nan(ntrials_in_block, 4);
onoffSamples = nan(ntrials_in_block, 4);
eventsID = nan(ntrials_in_block, 4);

%sig_modulator = {56, 1};
digits(6)
cnt = 1;
for jmod_freq = mod_freq_all
   for jphi_ref = phase_ref_all
       for jphi_targ = phase_targ_all
           for jdfm = dfm_all
               
               if jdfm>0
                   jfreq_match = 'increase';
               elseif jdfm<0
                   jfreq_match = 'decrease';
               end
           
           jcarr_freq = carr_freq_all(randi(5));
           
          %[sigs{cnt, 1}, sigs_trigger{cnt, 1}, ~] = mk_one_trial(jmod_freq, jdfm,...
          %    jphi_ref, jphi_targ, jcarr_freq);
          [sigs{cnt, 1}, sigs_trigger{cnt, 1}, ~] = mk_one_trial(jmod_freq, jdfm,...
              jphi_ref, jphi_targ, jcarr_freq);
          
          dmodFreq(cnt, 1) = dfm;
          modFreq(cnt, 1) = jmod_freq;
          phaseRef(cnt, 1) = jphi_ref;
          phaseTarg(cnt, 1) = jphi_targ;
          centerFreq(cnt, 1) = jcarr_freq;
          freqMatch{cnt, 1} = jfreq_match;
          
          [~, t_] = ismember(sigs_trigger{cnt, 1}(sigs_trigger{cnt, 1}~=0), sigs_trigger{cnt, 1});
          onoffTimes(cnt, :) = vpa(t_ / fs);
          onoffSamples(cnt, :) = t_;
          eventsID(cnt, :) = sigs_trigger{cnt, 1}(sigs_trigger{cnt, 1}~=0);
                
          cnt = cnt + 1;
           end
          
       end          
   end   
end

indxTrials = [1:ntrials_in_block]';
T = table(indxTrials, modFreq, dmodFreq, phaseRef, phaseTarg, centerFreq, freqMatch, onoffTimes, onoffSamples, eventsID, sigs, sigs_trigger);




%% Shuffle between & within sub-blocks
[~, indx_fm_sorted] = sort(T.modFreq);
T_sorted = T(indx_fm_sorted, :);

ntrials_per_frqmod = ntrials_in_block / length(unique(T_sorted.modFreq));
indx_ = reshape(indxTrials, ntrials_per_frqmod, []);
nc_indx_ = size(indx_, 2);
nr_indx_ = size(indx_, 1);
% Shuffle across elements in mod_freq class
for jc = 1:nc_indx_
    indx_(:, jc) = indx_(randperm(nr_indx_), jc);    
end
% Shuffle across mod_freqs
indx_ = reshape(indx_(:, randperm(nc_indx_)), [], 1); 
T_shuffled = T_sorted(indx_, :);

