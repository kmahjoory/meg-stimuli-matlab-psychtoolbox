function [] = run_short_training(subj_ID)

addpath('utils/')
subj_dir = ['behavioral_data/subj_', subj_ID];

INFO.indx_running_block = 1;%randi(nblocks); % to loop over blocks
INFO.j_running_block = 1; 
INFO.running_pc = 'meglab';%'meglab';%'mac'; %
INFO.fs = 44100;

load(fullfile(subj_dir, 'threshold_intensity.mat'), 'Tm', 'Tdb');
[~, ~, ratio_loud] = db2ratio(Tdb+45);
INFO.m_threshold = ratio_loud;% 10.^(m_db/20);
disp(['Ratio Loud:' num2str(ratio_loud)])

run_one_block_auditory_stim_training(INFO)