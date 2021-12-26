function [Tm, Tdb] = intensity_beat_threshold(Sound,Sf,dbRange,nRep,INFO)

% [Tm Tdb] = ptb_sensation_level(Sound,dbRange,nRep)
%
% Sound   - Sound vector; by default a 12 s, 1000 Hz sine tone is used
% Sf      - sampling frequency; default = 44100
% dbRange - the minimun and maximum decibel applied to the Sound; default = [-150 -70]
% nRep    - number of repetitions per descending and ascending Sound; default = 6
%
% Tm  - threshold in ratio/multiplier units; use this to multiply your Sound with
% Tdb - threshold in decibel units (Tdb + 55)
%
% Description: The script calculates a hearing threshold (sensation level)
% for a given Sound. It applies a method of limits whereby the Sound
% descends in intensity until inaudible, and then ascends until audible.
% -----------------------------------------------------------------------------------
% B. Herrmann, Email: bjoern.herrmann@outlook.com, 2015-02-17. Small
% modifications from Y. Cabral-Calderin July 2019 and Kristin Weineck
% February 2020

% get all the defaults going
if nargin < 4, nRep    = 6; end
if nargin < 3, dbRange = [-70 0]; end
if nargin < 2, Sf = 44100; end
% if isempty(Sound)
%     %     centerfreq = [1200 1200]; % try to match it to the main experiment
%     %     freqrange  = [500 500]; %match to the main experiment
%     %     ncomps = [30 30];
%     %     eventdur = [12 12];
%     %     rampdur  = .005;
%     %     lbs = centerfreq(1) - (freqrange(1) / 2); % lower bound
%     %     ubs = centerfreq(1) + (freqrange(1) / 2); % upper bound
%     %     compfreqs = (lbs + (ubs - lbs)*rand(1,ncomps(1)));
%     %     amps = 1 - (abs((compfreqs-centerfreq(1))/centerfreq(1)));
%     %     Sound = getstim(compfreqs,amps,eventdur(1),rampdur,Sf);
%     Sound=linramp(rand(1,12*44100),0.02,44100);
%     
% end

% get Sound duration
%Sound = -1 + (1-(-1)).*rand(1,length(Sound));
Sound = Sound(:);
Sound = Sound - mean(Sound);
Sound = Sound / max(abs(Sound));
durSound = length(Sound)/Sf;

% get db multipliers
dbLin  = linspace(dbRange(1),dbRange(2),length(Sound));  % linear spacing between decibels
m_asc  = 10.^(dbLin/20);                                 % ascending multipliers
m_des  = 10.^(fliplr(dbLin)/20);                         % descending multipliers
db_asc = dbLin;                                          % ascending decibel
db_des = fliplr(dbLin);                                  % descending decibel

% get ascending and descending Sound
asound = Sound .* m_asc';
dsound = Sound .* m_des';

% initial params
PsychDefaultSetup(2);

% InitializePsychSound;
InitializePsychSound(1); % need low latency; works only on WDM/KS & WASAPI windows

alldevices=PsychPortAudio('GetDevices',3);
disp(alldevices.DeviceName);
Fs=44100;
pahandle = PsychPortAudio('Open',[alldevices.DeviceIndex], [], 3, Fs, 3);

% sca;                                             % close all screens
screens      = Screen('Screens');                % get all screens available
screenNumber = max(screens);                     % present stuff on the last screen
Screen('Preference', 'SkipSyncTests', 2);   %2 will skip it
white        = WhiteIndex(screenNumber);         % get white given the screen used

% play once something to get the time stamps right later
PsychPortAudio('FillBuffer',pahandle,[0; 0; 0]);
initialTime = PsychPortAudio('Start',pahandle,1,0,1);

try
    %bgcolor  = 0;                                    % background color 0-255
    bgcolor  = [.5, .5, .5];
    txtcolor = round(white*0.3);                     % text color 0-255
    [shandle, windowRect] = PsychImaging('OpenWindow', screenNumber, bgcolor); % open window
    
    % Get the center and size of the on screen window
    [xCenter, yCenter] = RectCenter(windowRect);
    [screenXpixels, screenYpixels] = Screen('WindowSize', shandle);
    a_up     = arrow_matrix(100);
    a_down   = flipud(arrow_matrix(100));

    tmp      = [min([screenXpixels screenYpixels]) min([screenXpixels screenYpixels])] * 0.2;
    DestRect = CenterRectOnPointd([0 0 tmp],xCenter, yCenter);
    
    % Select specific text font, style and size:
    %Screen('TextFont', shandle, 'courier new');
    Screen('TextSize', shandle, 30);
    Screen('TextStyle', shandle, 1);
    HideCursor;
    KbName('UnifyKeyNames');
    
    % Get the KbQueue up and running; scans also while is busy with other stuff
    KbQueueCreate();
    KbQueueStart();
    continueKey = 49;
    escapeKey = 50;
    %.......................INITIALIZING RESPONSE..............................
    %HIDindex = 1; % check the index for the response box
    %     HIDindexMain =11;
    %     PsychHID('KbQueueCreate',HIDindex);
    %     PsychHID('KbQueueStart',HIDindex);
    %     PsychHID('KbQueueCreate',HIDindexMain);
    %     PsychHID('KbQueueStart',HIDindexMain);
    KbQueueCreate
    KbQueueStart
    % Instruction screen
    arrows = [a_down 1+zeros(size(a_up)) a_up];
    arrows = [1+zeros([size(a_down,1) size(arrows,2)]); arrows; 1+zeros([size(a_down,1) size(arrows,2)])];
    tmp    = [min([screenXpixels screenYpixels]) min([screenXpixels screenYpixels])] * 1;
    DRect  = CenterRectOnPointd([0 0 tmp],xCenter, yCenter+1);
    tex = Screen('MakeTexture', shandle, arrows);
    %Screen('DrawTextures', shandle, tex, [], DRect, [], [], [], [0 1 0]);
    Screen('DrawTextures', shandle, tex, [], DRect, [], [], [], [.3 .3 0.3]);
    DrawFormattedText(shandle, ['Arrow down: The sound starts loud,\n press a key as soon as you can''t hear it anymore!\n\n' ...
        'Arrow up: The sound starts softly,\n press a key as soon as you can hear it!'], 'center', yCenter*0.4+yCenter, txtcolor);
    DrawFormattedText(shandle, 'To start, please press the left button.', 'center', yCenter*0.75+yCenter, txtcolor);
    
    Screen('Flip', shandle);
    
    while true
        %  [pressed, firstPress] = PsychHID('KbQueueCheck', HIDindex);
        [pressed, firstPress] = KbQueueCheck;
        if pressed
            disp(find(firstPress))
            kpressed = find(firstPress);
            if kpressed(1)==continueKey
                break;
            end
        end
    end
    
    DrawFormattedText(shandle, '', 'center', 'center', txtcolor);
    Screen('Flip', shandle);
    WaitSecs(2);
    
    [Tm Tdb] = deal([]);
    for rr = 1 : nRep
        for pp = 1 : 2  % pp = 1 --> descending; pp = 2 --> ascending
            if pp == 1
                stim  = dsound;
                arrow = a_down;
            else
                stim  = asound;
                arrow = a_up;
            end
            
            % draw arrow
            tex = Screen('MakeTexture', shandle, arrow);
            Screen('DrawTextures', shandle, tex, [], DestRect, [], [], [], [0.3 0.3 0.3]);
            Screen('Flip', shandle);
            
            % play Sound
            PsychPortAudio('FillBuffer',pahandle,[stim'; stim'; zeros(1,length(stim'))]);
            starttime = PsychPortAudio('Start',pahandle,1,0,1);
            [keyIsDown, endtime, keyCode] = KbCheck;
            while ~keyIsDown && GetSecs-starttime < durSound
                [keyIsDown, endtime, keyCode] = KbCheck;
            end
            PsychPortAudio('Stop', pahandle,[],1);
            DrawFormattedText(shandle, '', 'center', 'center', txtcolor);
            Screen('Flip', shandle);
            
            % get reaction time
            RT = endtime - starttime;
            RTsamp = round(RT * Sf);
            if RTsamp > length(m_asc) || RT < 1        % exclude responses made too fast or late
                [Tm(rr,pp) Tdb(rr,pp)] = deal(NaN);
            else
                if pp == 1
                    Tm(rr,pp)  = m_des(RTsamp);
                    Tdb(rr,pp) = db_des(RTsamp);
                else
                    Tm(rr,pp)  = m_asc(RTsamp);
                    Tdb(rr,pp) = db_asc(RTsamp);
                end
            end
            
            % wait befor next tria;
            WaitSecs(1.5);
        end
        %if the escape key is pressed anytime the progrma will stop
        % [pressed, firstPress] = PsychHID('KbQueueCheck', HIDindexMain);
        [pressed, firstPress] = KbQueueCheck;
        if pressed
            if find(firstPress)==escapeKey
                %   PsychPortAudio('Stop'); % stop playing the sound
                break;
            end
        end
    end
    %     PsychHID('KbQueueStop',HIDindex) % stop the KbQueue
    %     PsychHID('KbQueueStop',HIDindexMain) % stop the KbQueue
    KbQueueStop
    sca;
catch
    sca;
    rethrow(lasterror);
end

if nnz(isnan(Tm(:))) == length(Tm)
    error('Error: No valid responses were made! Responses were either too early or too late.')
    [Tm Tdb] = deal([]);
elseif nnz(isnan(Tm(:)))/length(Tm) > 0.5
    disp('Info: More than half of the responses were invalid! Responses were either too early or too late.')
    Tm  = nanmean(Tm(:));
    Tdb = nanmean(Tdb(:));
else
    Tm  = nanmean(Tm(:));
    Tdb = nanmean(Tdb(:));
end

save(fullfile(INFO.subj_dir, 'threshold_intensity.mat'),'Tm','Tdb')

PsychPortAudio('Close', pahandle);


end


% get sine tone
function [y] = sine_tone(dur,Cf,Sf)
t = 0:1/Sf:(dur-1/Sf);
y = sin(2*pi*Cf*t);
end

% get rise and fall ramps
function [y] = wav_risefall(x,rf,Sf)
% get samples for rise and fall times
nsamp_rise = round(rf(1)*Sf);
nsamp_fall = round(rf(2)*Sf);

% get rise and fall vectors
rise = linspace(0,1,nsamp_rise)';
fall = linspace(1,0,nsamp_fall)';

% applied rise and fall vectors to x
x = x(:);
x(1:nsamp_rise) = x(1:nsamp_rise).*rise;
x(end-nsamp_fall+1:end) = x(end-nsamp_fall+1:end).*fall;
y = x;

end
% get the arrow image
function a = arrow_matrix(n)
a = [fliplr(tril(ones([n n]))) tril(ones([n n]))];
a = a(1:n/2,n/2:(n*2-n/2)-1);
a = [a; [zeros([n n/4]) ones([n n/2]) zeros([n n/4])]];
a = [zeros([n+n/2 n/4]) a zeros([n+n/2 n/4])];
indx_zeros = a==0;
a(indx_zeros) = 1;
a(~indx_zeros) = .3;

end

