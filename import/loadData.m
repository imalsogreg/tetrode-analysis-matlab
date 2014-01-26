function d = loadData(m,varargin)

p = inputParser();
p.addParamValue('timewin',[]);
p.addParamValue('loadPos',true);
p.addParamValue('loadEEG',true);
p.addParamValue('samplerate',1000);
p.addParamValue('loadMUA',true);
p.addParamValue('loadSpikes',true);
p.parse(varargin{:});

if(isempty(p.Results.timewin))
    timewin = m.loadTimewin;
else
    timewin = p.Results.timewin;
end

dayOfWeek = m.today(3:4);

d.epochs = loadMwlEpoch('filename',[m.basePath, '/epoch.epoch']);

if(~m.checkedArteCorrectionFactor)
    warning('loadDataGeneric:noCorrectionFactor',...
        'Using an un-checked correction factor');
end

if(p.Results.loadEEG)
d.eeg = quick_eeg('timewin',timewin,...
 'file1', m.f1File, 'f1_ind', m.f1Inds, 'f1_chanlabels', m.f1TrodeLabels, ...
 'file2', m.f2File, 'f2_ind', m.f2Inds, 'f2_chanlabels', m.f2TrodeLabels, ...
 'file3', m.f3File, 'f3_ind', m.f3Inds, 'f3_chanlabels', m.f3TrodeLabels, ...
 'file4', m.f4File, 'f4_ind', m.f4Inds, 'f4_chanlabels', m.f4TrodeLabels, ...
 'system_list',m.systemList,'sort_areas',true,'arte_correction_factor',m.arteCorrectionFactor,'samplerate',p.Results.samplerate);
end

if(p.Results.loadMUA)
d.mua = mua_at_date(m.today, m.mua_filelist_fn, 'keep_groups', m.keepGroups,...
    'trode_groups', m.trode_groups_fn, 'timewin', m.loadTimewin, 'arte_correction_factor',m.arteCorrectionFactor,...
    'ad_trodes',m.ad_tts,'arte_trodes',m.arte_tts,'width_window',m.width_window,'threshold',m.threshold);
[~,d.mua_rate] = assign_rate_by_time(d.mua,'timewin',timewin,'samplerate',p.Results.samplerate);
end

if(p.Results.loadSpikes)
d.spikes = imspike('spikes','arte_correction_factor',m.arteCorrectionFactor,...
    'ad_dirs',cmap(@(x) [x,dayOfWeek], m.ad_tts),'arte_dirs',cmap(@(x) [x,dayOfWeek],m.arte_tts)  );
end

if(p.Results.loadPos)
    if isfield(m,'circular_track')
        circ = m.linearize_opts.circular_track;
    else
        circ = false;
    end
    [d.pos_info,d.track_info,d.linearize_opts] = linearize_track(['l',dayOfWeek,'.p'],'timewin',d.epochs('run'),...
        'circular_track',circ, 'calibrate_length',m.linearize_opts.calibrate_length,'calibrate_points',m.linearize_opts.calibrate_points,...
        'click_points',m.linearize_opts.click_points);
end

if(~m.checkedArteCorrectionFactor)
    warning('loadDataGeneric:uncheckedCorrectionFactor',...
        'This day''s correction factor hasn''t been checked');
end