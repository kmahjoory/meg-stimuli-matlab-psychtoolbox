function [] = run_intensity_thresholding(subj_ID)

subj_dir = ['behavioral_data/subj_', subj_ID];
INFO.subj_dir = subj_dir;

INFO.running_pc = 'meglab';%'meglab';%'mac'; %
INFO.subj_ID = subj_ID;
if ~isdir(subj_dir)
    mkdir(subj_dir)   
end

addpath utils/


%% Intensity thresholding
is_run_thresholding = input('RUN Intensity Thresholding? [y/n] (without quotation mark): ','s');
if strcmp(is_run_thresholding, 'y')
    load('intensity_thresholding.mat', 'sig')
    INFO.intensity_threshold_sound = sig;
    Sf=44100;
    dbRange=[-70 0];%[-90 -20];
    nRep=6;%6 
    [Tm, Tdb] = intensity_beat_threshold(sig,Sf,dbRange,nRep,INFO);
    [~, ~, m_threshold] = db2ratio(Tdb+55);
    
    disp('-----------------------------------------------------------------')
    disp(['The estimated Threshold value is: ' num2str(m_threshold)])
    is_m_acceptable = input('Do you want to change it? [y/n] (without quotation mark): ','s');
    if strcmp(is_m_acceptable, 'y')
        m_threshold = input('Input the new threshold value: ');      
    end
    
     
    INFO.m_threshold = m_threshold;% 10.^(m_db/20);
    save(fullfile(INFO.subj_dir, 'm_threshold.mat'), 'm_threshold');
    
elseif strcmp(is_run_thresholding, 'n')

end