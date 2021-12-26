function soundout = linramp(x,rampdur,sf)

t = 1/sf:1/sf:rampdur;
ramp = linspace(0,1,length(t));

soundout = x .* [ramp, ones(1,length(x) - length(ramp))];
soundout = soundout .* [ones(1,length(x) - length(ramp)), fliplr(ramp)];

end