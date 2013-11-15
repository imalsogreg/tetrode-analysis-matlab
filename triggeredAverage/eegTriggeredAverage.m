function trigCdat = eegTriggeredAverage(inCdat, trigTimes, timeWin)

trigCdat = inCdat;

trigOkWindow = [inCdat.tstart - timeWin(1), inCdat.tend - timeWin(2)];
trigTimes = trigTimes( trigTimes >= trigOkWindow(1) & trigTimes <= trigOkWindow(2) );

inCdat.data( isnan(inCdat.data) ) = 0;

nChan = size(inCdat.data,2);
nSamp = size(inCdat.data,1);

inTS = conttimestamp(inCdat);
dt = 1/inCdat.samplerate;

trigTS = (timeWin(1):dt:timeWin(2))';
nNewSamp = numel(trigTS);

trigTimes = reshape(trigTimes,1,[]);

trigInterpTimes = bsxfun(@plus, trigTS, trigTimes);

trigCdat.data = zeros(nNewSamp,nChan); % right-sized placeholder

for c = 1:nChan

    alignedData = interp1(inTS, inCdat.data(:,c), trigInterpTimes,'linear','extrap');
    avgData = mean(alignedData,2);
    trigCdat.data(:,c) = avgData;

end

trigCdat.tstart = trigTS(1);
trigCdat.tend   = trigTS(end);