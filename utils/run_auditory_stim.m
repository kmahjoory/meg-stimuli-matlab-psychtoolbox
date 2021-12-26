

function run_auditory_stim(INFO)

% This function creates random order of blocks, makes direcotory for the
% participants and ...



disp('---------------------------------------------------------------------')
q_nblocks = input('During the experiment 9 blocks will be recorded. CONFIRM:[y]   Edit # of blocks:[n]: ', 's');
if strcmp(q_nblocks, 'y')
    n_blocks = 9;
else
    n_blocks = input('Type the number of Blocks for the experiment: ');
end
disp('---------------------------------------------------------------------')

blocks_order = 1:n_blocks;

subj_ID = INFO.subj_ID;
subj_dir = INFO.subj_dir;
INFO.start_datetime = datetime('now');
INFO.fs = 44100;


%mkdir([subj_dir, '/files_for_py']); TO DO; Add python friendly format for
%saveing data

if exist(fullfile(subj_dir, 'blocks_indx.mat'), 'file')
    load(fullfile(subj_dir, 'blocks_indx.mat'))
    load(fullfile(subj_dir, 'indx_running_block.mat'))
else
    blocks_indx = randperm(9, n_blocks); 
    indx_running_block = 1;
    save(fullfile(subj_dir, 'blocks_indx.mat'), 'blocks_indx')
    save(fullfile(subj_dir, 'indx_running_block.mat'), 'indx_running_block')
end

INFO.blocks_order = blocks_order;
INFO.blocks_indx = blocks_indx;


for jblock = blocks_order(indx_running_block:end)
    
    INFO.j_running_block = jblock;
    INFO.indx_running_block = blocks_indx(jblock);
    run_one_block_auditory_stim(INFO)
    indx_running_block = indx_running_block + 1;
    save(fullfile(subj_dir,'indx_running_block.mat'), 'indx_running_block')
    
    prompt = 'RUN NEXT BLOCK? y/n: ';
    str = input(prompt,'s');
    if strcmp(str, 'n')
        break;
    end
    
   
    
end



