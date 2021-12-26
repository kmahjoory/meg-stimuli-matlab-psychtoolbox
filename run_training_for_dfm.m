
function [] = run_training_for_dfm(subj_ID)

addpath('utils/')
running_pc = 'meglab';
subj_dir = ['behavioral_data/subj_', subj_ID];


load(fullfile(subj_dir, 'm_threshold.mat'), 'm_threshold');


[T_shuffled] = mk_one_block_training_sigmoid();
sigs = T_shuffled.sigs;
sigs_trigger = T_shuffled.sigs_trigger;
ntrials_in_block = length(sigs);


%tic
events_id = T_shuffled.eventsID;
on_off_samples  = T_shuffled.onoffSamples;
on_off_times = T_shuffled.onoffTimes;



%t = toc

%audio_matrix{3,2}(audio_matrix{3,2}~=0)
% sca
% keyboard




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
responded_key = cell(1, ntrials_in_block);
correct_response = cell(1, ntrials_in_block);
subj_response = cell(1, ntrials_in_block);
subj_response_b = nan(1, ntrials_in_block);

for jtrial = 1:ntrials_in_block
    
    
    
    WaitSecs(jitter_inter_trial(randi(3)));
  
    Screen('TextSize', CurrentMonitor, 70);
    text_disp = '+';
    DrawFormattedText(CurrentMonitor, text_disp, 'center', 'center');
    Screen(CurrentMonitor, 'Flip');
    
    
    % Feed sound toolbox with a (3 x T) matrix. first two contain audio
    % signal, last row is for trigger signal
    audio_play = repmat(sigs{jtrial, 1}, 2, 1);
    %PsychPortAudio('FillBuffer', pahandle, audio_play);
    %PsychPortAudio('FillBuffer', pahandle, [audio_play; audio_matrix{jtrial, 2}]);
    if strcmp(running_pc, 'meglab')
        PsychPortAudio('FillBuffer', pahandle, [m_threshold*audio_play; sigs_trigger{jtrial, 1}]);
    else
        PsychPortAudio('FillBuffer', pahandle, [audio_play]);
    end
    
    
    % Generate trigger signal for parallel port
    currtime = GetSecs;
    running_on_off = double(on_off_times(jtrial, :) + currtime + 1);     %add plus 1 sec to have no delay (buffer)
    

    % Start audio playback
    % startTime = PsychPortAudio(‘Start’, pahandle [, repetitions=1] [, when=0] [, waitForStart=0] [, stopTime=inf] [, resume=0]);
    repetitions = 1;
    startCue = running_on_off(1);
    waitForDeviceStart = 0; 
    PsychPortAudio('Start', pahandle, repetitions, startCue, waitForDeviceStart);
    
    n_events_in_trial = length(events_id(jtrial, :)); 
    if strcmp(running_pc, 'meglab')
        jon_off = 1;
        while jon_off <= n_events_in_trial
            
            currtime = GetSecs;
            if running_on_off(jon_off)<=currtime
                trigger_ = events_id(jtrial, :); % Add continuous/interrupted info in trigger signal
                trigger = trigger_(jon_off) * 30;
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
    text_disp = {'L: Slower           R: Faster';...
                 'L: Faster           R: Slower'};
    indx_rand_text = randi(2);
    if indx_rand_text == 1
        txt_left = 'decrease';
        txt_right = 'increase';
    elseif indx_rand_text == 2
        txt_left = 'increase';
        txt_right = 'decrease';
    end
    
        
    DrawFormattedText(CurrentMonitor, text_disp{indx_rand_text}, 'center', 'center');
    Screen(CurrentMonitor, 'Flip');


    correct_response{jtrial} = T_shuffled.freqMatch{jtrial, 1};
%     if strcmp(T_shuffled.iscontinuous{jtrial}, 'True')
%         correct_response{jtrial} = 'continuous';
%     elseif strcmp(T_shuffled.iscontinuous{jtrial}, 'False')
%         correct_response{jtrial} = 'interrupted';
%     end
        

    %  Response from Keyboard/Response box
    pressed_key = k1_key_input_question(pahandle);
    %%
%     ShowCursor
%     sca
%     keyboard
    %%
    
    if strcmp(pressed_key, 'left') && strcmp(txt_left, 'decrease')
        subj_response{jtrial} = 'decrease';
    elseif strcmp(pressed_key, 'left') && strcmp(txt_left, 'increase')
        subj_response{jtrial} = 'increase';
    elseif strcmp(pressed_key, 'right') && strcmp(txt_right, 'decrease')
        subj_response{jtrial} = 'decrease';
    elseif strcmp(pressed_key, 'right') && strcmp(txt_right, 'increase')
        subj_response{jtrial} = 'increase';
    end    
    
    
%     if strcmp(pressed_key, 'left') && strcmp(txt_left, 'interrupted')
%         subj_response{jtrial} = 'interrupted';
%     elseif strcmp(pressed_key, 'left') && strcmp(txt_left, 'continuous')
%         subj_response{jtrial} = 'continuous';
%     elseif strcmp(pressed_key, 'right') && strcmp(txt_right, 'interrupted')
%         subj_response{jtrial} = 'interrupted';
%     elseif strcmp(pressed_key, 'right') && strcmp(txt_right, 'continuous')
%         subj_response{jtrial} = 'continuous';
%     end
        
    subj_response_b(jtrial) = strcmp(subj_response{jtrial}, correct_response{jtrial});


    responded_key{jtrial} = pressed_key;
    if strcmp(pressed_key, 'escape')
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

T_shuffled.subj_response = subj_response';
T_shuffled.correct_response = correct_response';
T_shuffled.subj_response_b = subj_response_b';


%% Save all data
write_path = subj_dir;
write_name = ['block_training_for_sigmoid_fit.mat'];
if strcmp(pressed_key, 'escape')
    write_name = ['block_training_for_sigmoid_fit_ended_early_by_participant.mat'];
end
T_shuffled.sigs=[];
T_shuffled.sigs_trigger=[];
save(fullfile(write_path, write_name), 'T_shuffled')




if ~ strcmp(pressed_key, 'escape')
    PsychPortAudio('Close', pahandle); % close audio port
    sca;
    ShowCursor
    disp('---------------------------------------------------------------------')
    disp(['Training Block ended!'])
    disp('---------------------------------------------------------------------')
elseif strcmp(pressed_key, 'escape')
    disp('=====================================================================')
    disp('=== The participant pressed "ESCAPE" key and ended the block. ===')
    disp('=====================================================================')
end



