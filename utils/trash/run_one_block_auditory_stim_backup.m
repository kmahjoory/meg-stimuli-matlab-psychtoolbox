
function run_one_block_auditory_stim(INFO)



jblock = INFO.indx_running_block;%randi(nblocks); % to loop over blocks

running_pc = INFO.running_pc; %'mac';%'mac'; %'meglab'; 



%% ------------------------------------------------------------------------
%% Screen settings

% Clear the screen. "sca" is short hand for "Screen CloseAll". This clears
% all features related to PTB. Note: we leave the variables in the
% workspace so you can have a look at them.

sca;
                    
% Call default settings for screen
PsychDefaultSetup(2); % the feature level 2 implies execution of AssertOpenGl command(to check the status of the Screen() mex), KbName('UnifyKeyNames'), switches default color range to the normalized floating point number range 0.0-1.0

% % Skip sync tests for demo purposes only
% Screen('Preference', 'SkipSyncTests', 1);% set to 2 or skip

% If in debugging mode uncomment this line
% PsychDebugWindowConfiguration(0, 0.5)

% Prepare pipeline for configuration.
PsychImaging ('PrepareConfiguration')
screens = Screen('Screens'); % Get the screen numbers
screenNumber = max(screens); % if two screens are attached, draw to the external one

%% ------------------------------------------------------------------------
%% Set Grey color for the Backgroaud

color = WhiteIndex(screenNumber); % Similarly, black = BlackIndex(screenNumber);
grey = color / 2;
[CurrentMonitor] = PsychImaging('OpenWindow', screenNumber, grey); % Open an on screen CurrentMonitor and color it grey
%rec_width=RectangleSize(3);
%rec_height=RectangleSize(4);
% Return or set the current alpha-blending mode and the color buffer writemask for
% window ‘windowIndex’.
Screen('BlendFunction', CurrentMonitor, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

%sca;





%% ------------------------------------------------------------------------
%% Prepare Audio Device

%{
First, switch on the sournd card (Fireface UCX), otherwise no audio command will work. 
Note that pahandle = PsychPortAudio('Open') can be used once per session! To use again, reset Matlab. Maybe there is a better way. 
%}

InitializePsychSound(1);
all_devices = PsychPortAudio('GetDevices');
list_device_name = {all_devices.DeviceName};
list_HostAudioAPIName = {all_devices.HostAudioAPIName};
list_device_indx = [all_devices.DeviceIndex];
indx_asio = find(ismember(list_HostAudioAPIName, 'ASIO'));
asio_id = list_device_indx(indx_asio);

if isempty(asio_id), asio_id=1; end % To run on my macbook
device_ = PsychPortAudio('GetDevices', [], asio_id);

device_id = asio_id; % default sounddevice
device_mode = 1; % sound playback only
device_latency = 3; % (1: default level of latency), (2: Take full control over the audio device, even if this causes other sound
% applications to fail or shutdow) (3: As level 2, but request the most aggressive settings for the given device)
fs = 44100; % Requested frequency in samples per second
if strcmp(running_pc, 'meglab')
    nrchannels = 3; % (2: stereo output)(3: call for 3 channels: 1 and 2 are stim, 3 is trigger to electronix box.)
else
    nrchannels = 2; % To run on my laptop
end
pahandle = PsychPortAudio('Open', device_id, device_mode, device_latency, fs, nrchannels);
%{
PTB-INFO: New audio device 8 with handle 0 opened as PortAudio stream:
PTB-INFO: For 3 channels Playback: Audio subsystem is ASIO, Audio device name is ASIO Fireface USB
PTB-INFO: Real samplerate 44100.000000 Hz. Input latency 1.723356 msecs, Output latency 2.108844 msecs.
%}

PsychPortAudio('Stop', pahandle)



%% ------------------------------------------------------------------------
%% Load & Prepare Audio Files for the Block

T = readtable('meg_audio_stimuli_files/audio_files_info.csv');
T = T(:, 2:end);

nblocks = max(T.block)+1; % Zero indexing
nfiles_in_block = height(T(:, 1)) / nblocks;

audio_matrix = cell(nfiles_in_block, 2);
on_off_times = cell(nfiles_in_block, 1);
events_id = cell(nfiles_in_block, 1);

T_block = T(T.block==jblock, :);
%indx_shuffle = randperm(nfiles_in_block);
%T_block_shuff = T_block(indx_shuffle, :);


%% Shuffle between & within sub-blocks
[~, indx_mf_sort] = sort(T_block.freqmod);
T_sorted = T_block(indx_mf_sort, :);
indx_T = 1:height(T_sorted);
indx_ = reshape(indx_T, 16, []);
nc_indx_ = size(indx_, 2);
nr_indx_ = size(indx_, 1);
% Shuffle across elements in mod_freq class
for jc = 1:nc_indx_
    indx_(:, jc) = indx_(randperm(nr_indx_), jc);    
end
% Shuffle across mod_freqs
indx_ = reshape(indx_(:, randperm(nc_indx_)), [], 1); 
T_shuffled = T_sorted(indx_, :);

%tic
for jr = 1: nfiles_in_block
    load(['meg_audio_stimuli_files/', T_shuffled.filename{jr}, '.mat'], 'sig', 'trigger');
    audio_matrix{jr, 1}  = sig;
    audio_matrix{jr, 2}  = trigger;
    [~, t_] = ismember([1, 2, 3, 4, 5], trigger);
    on_off_times{jr, 1} = t_ / fs;
end
audio_matrix(:, 1) = cellfun(@(x) repmat(x, 2, 1), audio_matrix(:, 1), 'UniformOutput', false);
%t = toc

%audio_matrix{3,2}(audio_matrix{3,2}~=0)
% sca
% keyboard


%% ------------------------------------------------------------------------
%% Block Start Instructions

Screen('TextSize', CurrentMonitor, 70);
text_disp = 'Press Button Number "4" to Start the Block';
DrawFormattedText(CurrentMonitor, text_disp, 'center', 'center');
Screen(CurrentMonitor, 'Flip');

KbName('UnifyKeyNames');
HideCursor
k1_key_input_next; % Wait for the participant to press the key "4"

Screen('TextSize', CurrentMonitor, 70);
text_disp = '';
DrawFormattedText(CurrentMonitor, text_disp, 'center', 'center'); % clear the previous text from display
Screen(CurrentMonitor, 'Flip');


%% ------------------------------------------------------------------------
%% Prepare Parallel port for Trigger signals (start before iterating over trials)

if strcmp(running_pc, 'meglab')
    ioObj = io64;                        % These files are downloaded from MORLA
    status = io64(ioObj);
    address = hex2dec('FFF8');           % Standard LPT1 output port address to the MEG
end


%% ------------------------------------------------------------------------
%% Start looping over trials
jitter_inter_trial = [.5, 1, 1.5];
disp_text_left = cell(1, nfiles_in_block);
responded_key = cell(1, nfiles_in_block);
for jtrial = 1:nfiles_in_block
    
    
    
    WaitSecs(jitter_inter_trial(randi(3)));
    
    % continuous vs interrupted event id
    if on_off_times{jtrial, 1}(3) == 0
        events_id{jtrial} = [1, 2, 4, 5];
        on_off_times{jtrial, 1}(3) = [];
    elseif on_off_times{jtrial, 1}(4) == 0
        events_id{jtrial} = [1, 2, 3, 5];
        on_off_times{jtrial, 1}(4) = [];
    end
    
    
    Screen('TextSize', CurrentMonitor, 70);
    text_disp = '+';
    DrawFormattedText(CurrentMonitor, text_disp, 'center', 'center');
    Screen(CurrentMonitor, 'Flip');
    
    
    % Feed sound toolbox with a (3 x T) matrix. first two contain audio
    % signal, last row is for trigger signal
    audio_play = audio_matrix{jtrial, 1};
    %PsychPortAudio('FillBuffer', pahandle, audio_play);
    %PsychPortAudio('FillBuffer', pahandle, [audio_play; audio_matrix{jtrial, 2}]);
    if strcmp(running_pc, 'meglab')
        PsychPortAudio('FillBuffer', pahandle, [audio_play; audio_matrix{jtrial, 2}]);
    else
        PsychPortAudio('FillBuffer', pahandle, [audio_play]);
    end
    
    
    % Generate trigger signal for parallel port
    currtime = GetSecs;
    running_on_off = on_off_times{jtrial, 1} + currtime + 1;     %add plus 1 sec to have no delay (buffer)
    
    
    % Start audio playback
    % startTime = PsychPortAudio(‘Start’, pahandle [, repetitions=1] [, when=0] [, waitForStart=0] [, stopTime=inf] [, resume=0]);
    repetitions = 1;
    startCue = running_on_off(1);
    waitForDeviceStart = 0; 
    PsychPortAudio('Start', pahandle, repetitions, startCue, waitForDeviceStart);
    
    
    if strcmp(running_pc, 'meglab')
        jon_off = 1;
        while jon_off <= 4
            
            currtime = GetSecs;
            if running_on_off(jon_off)<=currtime
                trigger = events_id{jtrial}(jon_off) * 30; % Add continuous/interrupted info in trigger signal
                io64(ioObj, address, trigger);  % on, this takes about 1.2ms, sends signal to LPT1
                WaitSecs(0.005);                    % duration
                io64(ioObj, address, 0);              % off
                
                jon_off = jon_off + 1;
                
            end
        end
    end
    
    % Wait for stop of playback
    PsychPortAudio('Stop', pahandle, 1, 1);
    
    % Close the audio device
    %PsychPortAudio('Close', pahandle);
    
    % Display Response options
    Screen('TextSize', CurrentMonitor, 70);
    text_disp = {'L: Interrupted           R: Continuous';...
                 'L: Continuous           R: Interrupted'};
    indx_rand_text = randi(2);
    if indx_rand_text == 1
        txt_left = 'interrupted';
        txt_right = 'continuous';
    elseif indx_rand_text == 2
        txt_left = 'continuous';
        txt_right = 'interrupted';
    end
    
    disp_text_left{jtrial} = txt_left;  
        
    DrawFormattedText(CurrentMonitor, text_disp{indx_rand_text}, 'center', 'center');
    Screen(CurrentMonitor, 'Flip');

    
    % TO DO: save selected text_disp
    
    %  Response from Keyboard/Response box
    pressed_key_id_ = k1_key_input_question(pahandle);
    responded_key{jtrial} = pressed_key_id_;
    if pressed_key_id_ == KbName('ESCAPE')
        break
    end
    % Clear Display
    Screen('TextSize', CurrentMonitor, 50);
    text_disp = '';
    DrawFormattedText(CurrentMonitor, text_disp, 'center', 'center');
    Screen(CurrentMonitor, 'Flip');
    
end


%% End of block
% PsychHID('KbQueueStop',HIDindex) % stop the KbQueue
% PsychHID('KbQueueStop',HIDindexMain) % stop the KbQueue
%KbQueueStop

if pressed_key_id_ ~= KbName('ESCAPE')
    PsychPortAudio('Close', pahandle); % close audio port
    sca;
    ShowCursor
end


if strcmp(running_pc, 'meglab')
    write_path = 'E:\meg_training\mat_files\';
else
    write_path = '/Volumes/KEYVAN/meg_training/behaviour_data_from_mac_run/';
end
write_name = 'exp1.mat';
cc = 1;
while cc==1
    if exist([write_path, write_name], 'file')==2
        write_name = [write_name(1:4) , '_', write_name(5:end)];
    else
        cc=0;
    end
end
save([write_path, write_name], 'T_shuffled', 'disp_text_left', 'responded_key' )
