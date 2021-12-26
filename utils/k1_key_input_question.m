function [responded_key] = k1_key_input_question(pahandle)


left_key = 49;% 1 Left
right_key = 50; % 2 Right




KbQueueCreate
KbQueueStart

while true

    [pressed, firstPress] = KbQueueCheck;

    if pressed
        disp(find(firstPress))
        kpressed = find(firstPress);

        if kpressed(1) == left_key % ismember(kpressed(1), KbName('RightArrow'))
            responded_key = 'left';
            break;
        elseif kpressed(1) == right_key
            responded_key = 'right';
            break;
        elseif kpressed(1) == KbName('ESCAPE')
            responded_key = 'escape';
            PsychPortAudio('Close', pahandle); % close audio port
            sca;
            ShowCursor
            break
            %error('Escape key press!')
        end
    end
end

