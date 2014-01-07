function fs = rippleMatrix()

rats = burstsRats();
rName    = {'awakeLight','awakeDeep','SWSLight', 'SWSDeep'};
cName   =  {'rippleRate','arityPtc', 'rippleAmp','rippleFreq',...
            'burstFirstAmp','burstSndAmp','burstThirdAmp'};
nR = numel(rName);
nC = numel(cName);
fs = zeros(numel(cName),numel(rName));

for r = 1:nR
    for c = 1:nC
        fs(r,c) = lfun_fig(rName{r},cName{c},rats);
    end
end
end

function f = lfun_fig(rowName, colName, rats)
for today = ratsToDays(rats);
e = loadMwlEpoch(today)
f = 1;
%m = loadData(today);


end
end