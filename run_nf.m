
function run_nf()

%{ 
 To Do 

4- short report after every epoch
%}

disp('=====================================================================')
disp('=====================================================================')
subj_ID = input('Please Enter Subject ID (without quotation mark): ','s');
if isempty(subj_ID)
    error('Subject ID is not specified!')
end

subj_dir = ['behavioral_data/subj_', subj_ID];
if ~isdir(subj_dir)
    mkdir(subj_dir);
end
INFO.subj_dir = subj_dir;

INFO.running_pc = 'meglab';%'meglab';%'mac'; %
INFO.subj_ID = subj_ID;


addpath utils/






%% PRE-STIMULI SMT
is_post_smt = input('RUN PRE-Stimulus SMT? [y/n] (without quotation mark): ','s');
if strcmp(is_post_smt, 'y')
    if ~exist(fullfile(subj_dir, 'smt_pre.mat'), 'file')
        disp(' --- RUN Pre-stimulus SMT -------------------------------------------')
        smt_pre = run_smt();
        save(fullfile(subj_dir, 'smt_pre.mat'), 'smt_pre');
        disp([' --- Pre-stimulus SMT Completed and Saved in: ' subj_dir])
    end
    % RUN increading decressing 1
    
end





%% RUN Main Auditory Stimuli
is_auditory_stim = input('RUN Main Auditory Stimuli? [y/n] (without quotation mark): ','s');
if strcmp(is_auditory_stim, 'y')
    
    
    %% Load Intensity thresholding
    if exist(fullfile(INFO.subj_dir, 'threshold_intensity.mat'), 'file')
        load(fullfile(INFO.subj_dir, 'm_threshold.mat'), 'm_threshold');
        INFO.m_threshold = m_threshold;% 10.^(m_db/20);
    else
        error('Intensity thresholding file not found!')
    end
    
    %% Load estimated dmod_freq
    load(fullfile(INFO.subj_dir, 'dmod_freq.mat'), 'dmod_freq');
    INFO.dmod_freq = dmod_freq;
    
    disp(' --- RUN Auditory Stimuli -------------------------------------------')
    run_auditory_stim(INFO)
end


% % RUN increading decressing 1
% 
% 
% 
%% POST-STIMULI SMT
is_post_smt = input('RUN Post-Stimulus SMT? [y/n] (without quotation mark): ','s');
if strcmp(is_post_smt, 'y')
    
    if ~exist(fullfile(subj_dir, 'smt_post.mat'), 'file')
        disp(' --- RUN Post-stimulus SMT -------------------------------------------')
        smt_post = run_smt();
        save(fullfile(subj_dir, 'smt_post.mat'), 'smt_post');
        disp(['---------------------------------------------------------------------'])
        disp([' --- Post-stimulus SMT Completed and Saved in: ' subj_dir])
    end
end

