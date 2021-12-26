function [taps_time] = run_smt()


% ---------------keyboard--------------------------------------------------

KbName('UnifyKeyNames');

% Get the KbQueue up and running; scans also while is busy with other stuff
KbQueueCreate();
KbQueueStart();

% Set the keyboard buttons to detect
continueKey = 49; % left key of left response box in MEG: labelled as '1'
escapeKey = 52; % right key of left response box

%-------------configure trigger via parallel port--------------------------
%
ioObj = io64;                        %download two functions on MORLA
status = io64(ioObj);
address = hex2dec('FFF8');           %standard LPT1 output port address for the MEG*

leftbuttontrigger=200;          % gap detection


%----------screen----------------------------------------------------------

PsychDefaultSetup(2);

% Skip sync tests for demo purposes only
Screen('Preference', 'SkipSyncTests', 0);% set to 2 o skip; preference settings are global

%Prepare pipeline for configuration.
PsychImaging ('PrepareConfiguration');

screens=Screen('Screens');
screenNumber=max(screens);
white = WhiteIndex(screenNumber);
grey = white / 3;

% [CurrentMonitor, RectangleSize] = PsychImaging('OpenWindow', screenNumber, grey, [10 30 500 500]);
[CurrentMonitor, RectangleSize] = PsychImaging('OpenWindow', screenNumber, grey);

Text9 = sprintf('%s\n\n%s\n\n%s\n\n%s\n\n%s\n\n\n\n%s\n\n%s','Please press the "LEFT KEY" at a speed that is comfortable for you.',...
    'Please START as soon as the image of a hand appears on the screen.',...
    'And STOP when the hand disappears.',...
    'This process will repeat 3 times.',...
    'Now, Let''s begin. Please press the LEFT button.');

% Set up alpha-blending for smooth (anti-aliased) lines
Screen('BlendFunction', CurrentMonitor, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
color=WhiteIndex(screenNumber);

[screenXpixels, screenYpixels] = Screen('WindowSize', CurrentMonitor);

Screen('TextSize', CurrentMonitor, 25); %size for the text
DrawFormattedText(CurrentMonitor, Text9, 'center', 'center', color);
Screen(CurrentMonitor,'Flip');

% WAIT until the bush button to start with the experiment
while true
    [pressed,firstPress]= KbQueueCheck;
    if pressed
        kpressed = find(firstPress);
        if kpressed(1)==continueKey
            break;
        end
        if kpressed(1)==escapeKey
            return;   %returns from function
        end
    end
end

[xCenter, yCenter] = RectCenter(RectangleSize);            % get center of window
fixCrossDimPix = 40;            % set the size of the arms of fixation cross
xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];   % set the coordinates (these are all relative to zero)
yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
allCoords = [xCoords; yCoords];
lineWidthPix = 4;                   % Set the line width for fixation cross

%% ---------------------start experiment-----------------------------------


Screen('DrawLines', CurrentMonitor, allCoords, lineWidthPix, white, [xCenter yCenter], 2);
Screen('Flip', CurrentMonitor);

% load tapping image
theImage = imread('hand.jpg');
fs=44100;
tap_dur=30;             %in sec
sound_zero=zeros(1,fs*tap_dur);

% set path for saving data 
path='behavioral_data/'; 

HideCursor;

taps_time = nan(3, 150);
for hh=1:3          % loop through trials
          
        KbQueueStop()          % otherwise weird interference with sound
        onsets=[1/fs length(sound_zero)/fs];        % mark trial start and stop time
   
        realonsets=[];
        currtime = GetSecs;
        realonsets = onsets+ currtime + 0.5;     %add plus 0.5 sec to have buffer
        
        imageTexture = Screen('MakeTexture', CurrentMonitor, theImage);
        Screen('DrawTexture', CurrentMonitor, imageTexture, [], [], 0);
        Screen('Flip', CurrentMonitor);
        
        % simultaneously send trigger and check Keyboard
        num_trigger = 1;
        send_trigger = 0;
        trigger_val=40; % start_trigger: 40
        
        pressed=0; KbQueueStart()
        bb=1;
        while  send_trigger == 0
            currtime = GetSecs;
            [pressed,firstPress]= KbQueueCheck;
            
            if realonsets(num_trigger)<=currtime
                send_trigger = 1;
                if send_trigger == 1
                    io64(ioObj,address,trigger_val);  % on, this takes about 1.2ms
                    WaitSecs(0.005);                    % duration
                    io64(ioObj,address,0);              % off
                    send_trigger = 0;
                    
                    if num_trigger< numel(realonsets)
                        num_trigger=num_trigger+1;
                        trigger_val=80; % stop_trigger: 80 
                    end
                    
                end
            end 
            if pressed
                kpressed = find(firstPress);
                if kpressed(1)==continueKey
                    io64(ioObj,address,leftbuttontrigger);  % on. this takes about 1.2ms
                    WaitSecs(0.005);                    % duration
                    io64(ioObj,address,0);              % off
                    currtime_push = GetSecs;
                    taps_time(hh,bb)=currtime_push-realonsets(1);        % save button presses also manually
                    bb=bb+1;
                    send_trigger=0;
                    pressed=0;
                end
            end
            
            if currtime >= max(realonsets)+0.5          % add 0.5 sec at end 
                break
            end
        end
        
        %save([path num2str(subj_no) '_SMT_pre'],'taps_pre')     % save tap times 
        
        Screen('TextSize', CurrentMonitor, 70);
        text_disp = '';
        DrawFormattedText(CurrentMonitor, text_disp, 'center', 'center'); % clear the previous text from display
        Screen(CurrentMonitor, 'Flip');
        
        WaitSecs(3)

end %end block loop
Screen('TextSize', CurrentMonitor, 70);
Text2 = sprintf('This session is ended. Thank You.');
DrawFormattedText(CurrentMonitor, Text2, 'center', 'center', color);
Screen(CurrentMonitor,'Flip');

WaitSecs(1)

%----------------------------exit audio-----------------------------------

PsychPortAudio('Close'); %, pahandle);

%--------------------------- exit screen----------------------------------
sca;

ShowCursor;

end



