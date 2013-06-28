function state = behavioralState(pos_info,pfilename,eeg,varargin)
% behavioralState takes eeg, mua, emg, behavior data -> a map from
%  state name to a set of epochs where the rat is in that state
% Criteria:
%  - movement (with velocity_state, velocity_cdat)
%  - 
% Optional params: 

p = inputParser();
% General data
p.addParamValue('epoch_file','./epoch.epoch');
p.addParamValue('eeg',[]);
p.addParamValue('mua',[]);
% Run speed options
p.addParamValue('stillThresh',[]);
p.addParamValue('velocity_state_optional_args',cell(0));
% Theta-delta ratio
p.addParamValue('tdrSWSThresh',0.5);
p.addParamValue('tdrDeepSWSThresh',0.4);
p.addParamValue('tdrREMThresh',1.0);
p.addParamValue('tdrMaxBridge',1);
p.addParamValue('tdrMinLength',10);
p.addParamValue('tdr_optional_args',cell(0));

p.parse(varargin{:});
opt = p.Results;

% setup
state = containers.Map();
epochMap = loadMwlEpoch('filename',opt.epoch_file);

% Label the velocity-based states, like running, still, absolutely still
% inbound, outbound.
velCdat = velocity_cdat(pfilename,opt.epoch_file);
velStates = velocity_state(velCdat,pos_info,epochMap,...
    opt.velocity_state_optional_args{:});

% Fold the output fields from struct into the state map
state = foldl(@(x,y) fromVelocityState(x, velStates, y), state, ...
    {'running','absolutelyStill','still','outbound','inbound','test'});

sleepEpochs = gh_union_segs(epochMap('sleep1'),epochMap('sleep2'));

% Theta/Delta ratio
tdr = theta_delta_ratio(eeg,opt.tdr_optional_args{:});

SWSCand = gh_signal_to_segs(tdr, seg_criterion('cutoff_value',opt.tdrSWSThresh,...
    'bridge_max_gap',opt.tdrMaxBridge,...
    'min_width_post_bridge',opt.tdrMinLength,'thresh_is_positive',false));
state('sws') = gh_intersection_segs(SWSCand, sleepEpochs);

DeepSWSCand = gh_signal_to_segs( tdr, ...
    seg_criterion('cutoff_value', opt.tdrDeepSWSThresh,...
    'bridge_max_gap',opt.tdrMaxBridge, 'min_width_post_bridge',opt.tdrMinLength,...
    'thresh_is_positive',false));
state('deepsws') = gh_intersection_segs(DeepSWSCand, sleepEpochs);

REMCand = gh_signal_to_segs( tdr, ...
    seg_criterion('cutoff_value', opt.tdrREMThresh, ...
    'bridge_max_gap', opt.tdrMaxBridge,'min_width_post_bridge',opt.tdrREMThresh));
state('rem') = gh_intersection_segs(REMCand, sleepEpochs);

end

function newSt = fromVelocityState(oldSt, stateStruct, fieldName)
newSt = oldSt;
if(isfield(stateStruct, fieldName))
    newSt(fieldName) = stateStruct.(fieldName);
else
    warning('fromVelocityState:unsetField',['Input struct doesn''t have field', ...
        ' named: ', fieldName,' ... Skipping this field.']);
end
end