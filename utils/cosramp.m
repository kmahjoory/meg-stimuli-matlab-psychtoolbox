function soundout = cosramp(x,rampdur,sf)

t = 1/sf:1/sf:rampdur;
ramp = cos(2*pi*ms2Hz(rampdur*2*1000)*t+pi);
ramp = (ramp - min(ramp)) ./ (max(ramp) - min(ramp));

soundout = x .* [ramp, ones(1,length(x) - length(ramp))];
soundout = soundout .* [ones(1,length(x) - length(ramp)), fliplr(ramp)];

end