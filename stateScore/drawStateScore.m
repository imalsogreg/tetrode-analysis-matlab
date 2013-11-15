function f = drawStateScore(pos_info, pfilename, eeg, states, varargin)

p = inputParser();
p.addParamValue('efilename','./epoch.epoch');
p.parse(varargin{:});
opt = p.Results;

ax(1) = subplot(3,1,1);
f = gh_plot_cont(eeg);
hold on;

vCdat = velocity_cdat(pfilename,opt.efilename);

ax(2) = subplot(3,1,2);
gh_plot_cont(vCdat);

ax(3) = subplot(3,1,3);
gh_draw_segs(states.values(),'names',states.keys());

linkaxes(ax,'x');