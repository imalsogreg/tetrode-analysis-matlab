function [dips, frames] = find_dips_frames(mua_rate,varargin)

p = inputParser();
p.addParamValue('mean_rate_threshold', 65);
p.addParamValue('frame_length_range', [0.01 3]);
p.addParamValue('draw',false);
p.parse(varargin{:});
opt = p.Results;

dip_crit = seg_criterion('cutoff_value', opt.mean_rate_threshold,...
    'thresh_is_positive',false,...
    'bridge_max_gap',0,'min_width_pre_bridge',0.05);

mua_mean = mua_rate;
mua_mean.data = mean(double(mua_mean.data),2); % Somehow input data was single
mua_mean.chanlabels = {'meanRate'};

dips = gh_signal_to_segs(mua_mean,dip_crit);

frames = gh_invert_segs(dips);

%c1 = 

frames = ...
    frames(cellfun(@(x) (diff(x) >= min(opt.frame_length_range) && ...
    diff(x) <= max(opt.frame_length_range)), frames, 'UniformOutput',true));

if(opt.draw)
    gh_plot_cont(mua_mean);
    hold on;
    gh_draw_segs({frames, dips}, 'names',{'frames','dips'},'ys',{[-100 0],[-200 -100]});
end