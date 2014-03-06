function d = loadData(m,varargin)

p = inputParser();
p.addParamValue('timewin',[]);
p.addParamValue('loadPos',true);
p.addParamValue('loadEEG',true);
p.addParamValue('samplerate',1000);
p.addParamValue('loadMUA',true);
p.addParamValue('loadSpikes',true);
p.addParamValue('computeFields',true);
p.parse(varargin{:});

if(isempty(p.Results.timewin))
    timewin = m.loadTimewin;
else
    timewin = p.Results.timewin;
end

dayOfWeek = m.today(3:4);

d.epochs = loadMwlEpoch('filename',[m.basePath, '/epoch.epoch']);

if(~m.checkedArteCorrectionFactor)
    warning('loadData:noCorrectionFactor',...
        'Using an un-checked correction factor');
end

if(p.Results.loadEEG)
  eegArgs = lfun_args(m);
  eegArgs = [eegArgs, 'timewin',timewin,...
       'system_list',{m.systemList},'sort_areas',true,...
      'arte_correction_factor',m.arteCorrectionFactor,...
      'samplerate',p.Results.samplerate];
  
  d.eeg = quick_eeg(eegArgs{:});
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

if(opt.computeFields)
    [spikes,pos_info2,track_info2] = assign_field(d.spikes, d.pos_info, 'n_track_seg',100,'track_info',d.track_info);
    d.spikes = spikes;
    d.pos_info = pos_info2;
    d.track_info = track_info2;
end

if(~m.checkedArteCorrectionFactor)
    warning('loadDataGeneric:uncheckedCorrectionFactor',...
        'This day''s correction factor hasn''t been checked');
end

end

function a = lfun_args(m)
  a = cell(0);
  for i = 1:100 % TODO : Magic number is the upper bound 
                % of eeg files we'll ever possibly encounter
    a = [a,lfun_args_from_file_ind(m,i)];
  end
end

function a = lfun_args_from_file_ind(m,i)
  thisFilenameParam = ['f', num2str(i),'File'];
  thisFileIndParam  = ['f', num2str(i),'Inds'];
  thisFileChanlabelsParam = ['f', num2str(i),'TrodeLabels'];
  if isfield(m,thisFilenameParam)
    if isfield(m,thisFileIndParam) && isfield(m,thisFileChanlabelsParam)
      thisFilenameName = ['file',num2str(i)];
      thisFileIndName  = ['f',num2str(i),'_ind'];
      thisFileChanlabelsName = ['f',num2str(i),'_chanlabels'];
      a = {thisFilenameName, m.(thisFilenameParam), ...
           thisFileIndName, m.(thisFileIndParam), ...
           thisFileChanlabelsName, m.(thisFileChanlabelsParam)};
    else
      error('loadData:eegFieldInconsistencies',...
            'metadata had eeg file filename but not ind or chanlabel info');
    end
  else
    a = cell(0);
  end
end
