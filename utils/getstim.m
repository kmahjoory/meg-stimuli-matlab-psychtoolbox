function S = getstim(compfreqs,amps,eventdur,rampdur,Sf)

S = zeros(1,eventdur(1)*Sf);

% build the sounds
for jj = 1:length(compfreqs)
    S = S + cosramp(amps(jj)*sin(2*pi*compfreqs(jj)*(1/Sf:1/Sf:eventdur(1))),rampdur,Sf);
end
S = S * (1/length(compfreqs));
