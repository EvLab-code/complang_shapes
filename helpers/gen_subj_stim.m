function subj_stim = gen_subj_stim(rand_seed, opts)
% gen_subj_stim(randSeed, opts)
%
% Generates the stimuli table for this subject
%
% Input: 
%   rand_seed: random seed for this subject
%   opts: options structure.  Must have the following fields:
%       .conds_per_set = how many transformations per base sentence
%       .trials_per_cond = how many trials per transformation
%       .num_sets = number of sets per condition
%       .num_filler_trials = number of filler trials
%       .sent_stim_dir = where to find the sentence jpgs
%       .shape_stim_dir = where to find the shape jpgs
% Output:
%   subj_stim:  This is a table with the following columns
%       stim_num: int, 1:320, which sentence, of the total # sents this subject
%           will see
%       sent: 1x1 cell, each containing a sentence.  Contains 1x7 arrays for
%           critical sentences and 1x3 arrays for filler sentences
%       sent_jpg: string, full path to sentence jpg shown on this trial
%       img_jpg: string, full path to image jpg shown on this trial
%       match: boolean, does the image match the sentence?
%       set: int, 1:3.  which target set this stim belongs to.  3 = filler
%       transform: int, 1:12, in this set, which transformation of the base
%           sentence is this?  Note: 2 = Transform 1, all shifted by one since base
%           sent = 1.  For filler sents, this will be 1:8
%       transform_poss_sent: int, 1:n, where n represents how many possible
%           sentences this transformation allows for.  
%       rep: which repetition of this sentence is this?
%
% Created: bpritche, 02-08-2016
% Edited: bpritche, 02-11-2016; updated for new filler condition

%% Initialize
% seed random number generator
rng(rand_seed);
% grab num_trials
assert(isfield(opts,'conds_per_set') && isfield(opts,'trials_per_cond') && ...
    isfield(opts,'num_sets') && isfield(opts, 'num_filler_trials') && ...
    isfield(opts, 'sent_stim_dir') && isfield(opts, 'shape_stim_dir'), ...
    'opts structure missing necessary fields');
num_trials = opts.num_sets * opts.conds_per_set * opts.trials_per_cond + ...
    opts.num_filler_trials;

% grab which target sets to use
load(fullfile(pwd,'poss_target_sets.mat'), 'poss_target_sets');
target_set_i = randi([1 length(poss_target_sets)]);
target_sets = poss_target_sets{target_set_i};

% set up column arrays - one array per what will become a column in the final setup
sent_num = (1:num_trials)';
sent = cell(num_trials, 1);
sent_jpg = cell(num_trials, 1);
img_jpg = cell(num_trials, 1);
match = nan(num_trials, 1);
set = nan(num_trials, 1);
transform = nan(num_trials, 1);
transform_poss_sent = nan(num_trials, 1);
rep = nan(num_trials, 1);

%% Loop through trials
assert(opts.num_sets == length(target_sets), 'mismatch between opts struct and target_sets');
stim_num = 1;
for set_i = 1:opts.num_sets
    % Grab this target set
    curr_set = target_sets{set_i};
    assert(opts.conds_per_set == length(curr_set), 'mismatch between opts struct and set length');
    for cond_i = 1:opts.conds_per_set
        % Grab this condition, or transformation
        cond = curr_set{cond_i};
        if ~iscell(cond)
            % only one possibility for this sentence, just do 10
            % repetitions of this sentence
            reps = opts.trials_per_cond;
            stim_rep_inds = stim_num:stim_num+reps-1;
            % sent
            sent(stim_rep_inds, :) = repmat({cond},reps,1);
            % sent jpg
            curr_save_name = sprintf('%s.jpg', getSaveName(cond));
            curr_save_path = fullfile(opts.sent_stim_dir, curr_save_name);
            sent_jpg(stim_rep_inds, :) = repmat({curr_save_path},reps,1);
            % img jpg, match
            allocate_incorrect(stim_rep_inds, curr_set, cond_i);
            % set
            set(stim_rep_inds, :) = repmat(set_i,reps,1);
            % cond, or transform
            transform(stim_rep_inds, :) = repmat(cond_i,reps,1);
            % which possibility for this transform
            transform_poss_sent(stim_rep_inds, :) = ones(reps,1);
            % which rep?
            rep(stim_rep_inds, :) = (1:reps)';
            % increment stim counter
            stim_num = stim_num + reps;
        else
            % many possibilities for this sentence, evenly distribute them
            %   among reps
            num_poss_sents = length(cond);
            reps = opts.trials_per_cond;
            reps_per_sent = floor(reps/num_poss_sents);
            num_extra_reps = mod(reps, num_poss_sents);
            % present each sentence an equal number of times
            sent_inds = repmat(1:num_poss_sents, 1, reps_per_sent);
            % if there's any leftover sentences, randomly select some
            % sentences to be shown more than once
            extra_inds = randperm(num_poss_sents);
            sent_inds = cat(2, sent_inds, extra_inds(1:num_extra_reps));
            % randomize presentation
            sent_inds = sent_inds(randperm(length(sent_inds)));
            % allocate trials
            stim_rep_inds = stim_num:stim_num+reps-1;
            allocate_incorrect(stim_rep_inds, curr_set, cond_i, sent_inds);
            
            % Now, take each of these and insert them into the proper
            % column arrays
            for rep_i = 1:length(sent_inds)
                sent_i = sent_inds(rep_i);
                % sent
                sent(stim_num, :) = cond(sent_i);
                % sent jpg
                curr_save_name = sprintf('%s.jpg',getSaveName(cond{sent_i}));
                sent_jpg{stim_num, :} = fullfile(opts.sent_stim_dir, curr_save_name);
                % set
                set(stim_num, :) = set_i;
                % transform
                transform(stim_num, :) = cond_i;
                % transform_poss_sent
                transform_poss_sent(stim_num, :) = sent_i;
                % rep
                rep(stim_num, :) = rep_i;
                % increment stim counter
                stim_num = stim_num + 1;
            end
        end
        
    end
end

%% Pull in filler sentences
load(fullfile(pwd,'poss_fillers.mat'), 'poss_fillers');
for filler_i = 1:length(poss_fillers)
    filler_sent = poss_fillers{filler_i};
    reps = opts.trials_per_cond;
    stim_rep_inds = stim_num:stim_num+reps-1;
    % sent
    sent(stim_rep_inds, :) = repmat({filler_sent},reps,1);
    % sent jpg
    curr_save_name = sprintf('%s.jpg', getSaveName(filler_sent));
    curr_save_path = fullfile(opts.sent_stim_dir, curr_save_name);
    sent_jpg(stim_rep_inds, :) = repmat({curr_save_path},reps,1);
    % incorrect, match
    allocate_incorrect(stim_rep_inds, poss_fillers, filler_i);
    % set
    set(stim_rep_inds, :) = repmat(3,reps,1);
    % cond, or transform
    transform(stim_rep_inds, :) = repmat(filler_i,reps,1);
    % which possibility for this transform
    transform_poss_sent(stim_rep_inds, :) = ones(reps,1);
    % which rep?
    rep(stim_rep_inds, :) = (1:reps)';
    % increment stim counter
    stim_num = stim_num + reps;
end

%% Save table
subj_stim = table(sent_num, sent, sent_jpg, img_jpg, match, set, transform, ...
    transform_poss_sent, rep);

function allocate_incorrect(stim_rep_inds, set, cond_i, varargin)
% Usage: allocate_incorrect(stim_rep_inds, set, cond_i, sent_inds)
% 
% Allocate which of the trials will be correct and incorrect, then modify
%   img_jpg and match cells
%
% Input: 
%   stim_rep_inds: array representing which indices correspond to the
%       trials for this sentence
%   set: the full set of sentences being used here
%   cond_i: the transformation being used
%   sent_inds (optional): an array with indices representing which
%       sentences will be shown in which trials.  Only necessary for
%       transformations where multiple sentences are possible
    % initialize
    reps_ai = length(stim_rep_inds); % _ai so no variable sharing bt this and main function
    act_num_incorrect = floor(reps_ai/2);
    cond_ai = set{cond_i};
    if iscell(cond_ai)
        assert(~isempty(varargin), 'Need sent_inds array'); 
        sent_inds_ai = varargin{1};
        multi_poss = true;
        filler = false;
    else
        multi_poss = false;
        if strncmp(getSaveName(cond_ai), 'filler_', length('filler_'))
            filler = true;
        else filler = false;
        end
    end
    
    % determine what the incorrect images themselves will be
    all_poss_incorrects = grab_poss_incorrects(set, cond_i, opts);
    all_incorr_idx = randperm(length(all_poss_incorrects));
    incorr_idx = all_incorr_idx(1:act_num_incorrect);
    incorrects = all_poss_incorrects(incorr_idx);
    
    % place in the array
    all_incorr_spread_idx = randperm(opts.trials_per_cond);
    incorr_spread_idx = all_incorr_spread_idx(1:act_num_incorrect);
    corr_spread_idx = all_incorr_spread_idx(act_num_incorrect+1:end);
    ic = 1;
    c = 1;
    for ic_all = 1:length(stim_rep_inds)
        if any(ic_all == incorr_spread_idx)
            % make this one incorrect
            img_path = incorrects{ic};
            ic = ic+1;
            match(stim_rep_inds(ic_all)) = 0;
        else 
            if multi_poss, rel_sent = cond_ai{sent_inds_ai(ic_all)};
            else rel_sent = cond_ai;
            end
            if ~filler, c_i = corr_spread_idx(c); c = c + 1;
            else c_i = 1;
            end
            img_name = sprintf('%s_%d.jpg', getSaveName(rel_sent), c_i); 
            img_path = fullfile(opts.shape_stim_dir, getSaveName(rel_sent), img_name);
            match(stim_rep_inds(ic_all)) = 1;
        end
        
        img_jpg{stim_rep_inds(ic_all)} = img_path;
    end
    
end

end

