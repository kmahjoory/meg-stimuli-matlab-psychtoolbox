function [] = calc_dfm_from_training(subj_ID)

%run_one_block_auditory_stim_training_sigmoid(subj_ID)



subj_dir = ['behavioral_data/subj_', subj_ID];
if ~isdir(subj_dir)
    mkdir(subj_dir)
end

load(fullfile(subj_dir, 'block_training_for_sigmoid_fit.mat'), 'T_shuffled');
%T_shuffled = run_one_block_auditory_stim_training_sigmoid(subj_ID);

dfm_all_ = [-10.5:3:-4.5 4.5:3:10.5]/100;%[-abs(dfm), abs(dfm)];
dfm_all = [-10.5:3:10.5]/100;
acc_ = nan(1, length(dfm_all_));
acc = nan(1, length(dfm_all_)+2);
cnt = 1;
for jfm = dfm_all_
    
    T_ = T_shuffled(T_shuffled.dmodFreq==jfm, :);
    resp = T_.subj_response_b;
    acc_(cnt) = sum(resp)/length(resp);
    cnt = cnt + 1;
end

addpath(genpath('utils'))


disp('--------------------------------------------------------------')
acc(1:3) = acc_(1:3);
acc(6:8) = acc_(4:6);
acc(4) = 0.5;
acc(5) = 0.5;
disp(acc);
acc(1:4) = 1 - acc(1:4);


[gamma, theta] = sigmoid_fit(dfm_all, acc);
dfm_hr = linspace(dfm_all(1), dfm_all(end), 1000);
sig_fitted = sigmoid(gamma, theta, dfm_hr);

indx_all_p70 = find(round(sig_fitted, 2) == 0.7);
indx_all_n70 = find(round(sig_fitted, 2) == 0.3);

if ~isempty(indx_all_p70)&& ~isempty(indx_all_n70)
    
    if mod(length(indx_all_p70), 2)==0
        indx_p70 = indx_all_p70(end/2);
    else
        indx_p70 = indx_all_p70((end-1)/2);
    end
    
    
    if mod(length(indx_all_n70), 2)==0
        indx_n70 = indx_all_n70(end/2);
    else
        indx_n70 = indx_all_n70((end-1)/2);
    end
    
    
    dfm_ = ( dfm_hr(indx_p70) + abs(dfm_hr(indx_n70)) )/2 ;
    dmod_freq = round(dfm_, 3);
    
    
    figure('color', 'w', 'Position', [100, 100, 600, 400])
    plot(dfm_hr, sig_fitted, 'k', 'linewidth', 2), hold on
    plot(dfm_hr(indx_p70), sig_fitted(indx_p70), '.r', 'markersize', 30)
    plot(dfm_hr(indx_n70), sig_fitted(indx_n70), '.r', 'markersize', 30)
    hold off
    grid on
    xticks(dfm_all)
    xticklabels(dfm_all*100)
    yticks([0, .1, .2, .3, .4, .5, .6, .7, .8, .9, 1])
    xlabel('fm_{target} - fm_{ref} (%)')
    ylabel('Performance score')
    set(gca,'FontSize',18)
    line([0, 0], [0, 1], 'color', [.4 .4 .4])
    title(['Estimated dfm: ', num2str(100*dmod_freq), '%'], 'fontsize', 13)
    saveas(gcf, fullfile(subj_dir, 'sigmoid_fit.jpg'))
    
    disp('---------------------------------------------------------------------')
    disp(['Estimated dfm value is: ', num2str(100*dmod_freq), '%'])
    disp('---------------------------------------------------------------------')
    answr = input('Do you want to change the estimated dfm value [y/n]?', 's');
    
    if strcmp(answr, 'n')
        save(fullfile(subj_dir, 'dmod_freq.mat'), 'dmod_freq');
    elseif strcmp(answr, 'y')
        dmod_freq = input('Input the new dfm value in %?')/100;
        save(fullfile(subj_dir, 'dmod_freq.mat'), 'dmod_freq');
    end
    
    disp('=====================================================================')
    
else
    disp(acc)
    dmod_freq = input('Couldn"t estimate the dfm. Input the new dfm value in %.')/100;
    save(fullfile(subj_dir, 'dmod_freq.mat'), 'dmod_freq');
end

