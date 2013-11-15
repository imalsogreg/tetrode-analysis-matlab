function cdatOut = eegByArea(cdatIn, trode_groups, area)
% eegByArea(eeg, trode_groups, area)

areas = cmap(@(x) x.name, trode_groups);

match = strcmp(area, areas);

if(~any(match))
    error('eegByArea:noMatch',['eegByArea didn''t find ', area, ' among ', areas]);
end

hitTrodes = trode_groups{match}.trodes;

cdatOut = contchans(cdatIn,'chanlabels',hitTrodes);