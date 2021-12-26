function [] = k1_key_input_next


next_key = 52;   % Go to the next page

KbQueueCreate
KbQueueStart

while true
    
    [pressed, firstPress] = KbQueueCheck;
    
    if pressed
        disp(find(firstPress))
        kpressed = find(firstPress);
        
        if ismember(kpressed(1), next_key) %ismember(kpressed(1), KbName('SPACE'))
            break;
        elseif kpressed(1) == KbName('ESCAPE')
            PsychPortAudio('Close', pahandle); % close audio port
            sca;
            ShowCursor
            error('Escape key press!')
        end
    end
    
end
end

