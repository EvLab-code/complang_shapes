function complang_shapes( subjID, runNum, rand_seed )
% USAGE: complang_shapes(subjID, runNum, [rand_seed])
% version 1
% IPS: 249, runtime: 497 s
%
% INPUTS: 
%   subjID: subject ID
%   runNum: run number 
%   rand_seed: optional, random seed for this participant.  If not included
%       and this is the participant's first run, the program will query the
%       user for a randSeed to use.
%
% datafile (complang_shapes_subjID_runNum.mat) will have a struct data, with 
%   the following fields:
%   .opts - structure, options set by user
%   .T - int, run time in seconds  
%   .run_data_table - a table containing just the stim used in this run.
%       This contains all of the columns listed in the allstim_table, in
%       addition to the following:
%           sent_onset: sentence onset, s, relative to the beginning of the
%               run
%           img_onset: image (cue) onset, s, relative to the beginning of
%               the run
%           resp: response (1 or 2, 0 if no response in time)
%           rt: time that the button was pressed, relative to onset of
%               shape stimulus
%           sent_txtr: texture for sentence jpg, for Psychtoolbox use
%           img_txtr: texture for image jpg, for Psychtoolbox use
%   .run_stim_order - the order in which the rows of run_data_table were presented
%
% Created: bpritche, 01/11/2016
% goodbye
% Based on code by Sam Gershman (complang_experiment1)

%% %%%%%%%%%%%%%%%%%%  Initialization  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% OPTIONS %%%
% Timing
opts.txt_dur = 3;               % phrase duration (s)
opts.shape_dur = 2;             % shape duration (s)
opts.ISI = [5 6 7 8 9];         % possible interstimulus intervals
opts.ITI = 3;                   % intertrial interval
opts.fix = 10;                  % fixation period at beginning and end
% Directories
opts.data_dir = fullfile(pwd, 'data', subjID);
opts.sent_stim_dir = fullfile(pwd, 'sent_imgs');
opts.shape_stim_dir = fullfile(pwd, 'shape_imgs');
% Stim
opts.conds_per_set = 12;        % num of possible transformations of each base sent (size of target set)
opts.trials_per_cond = 10;      % num of trials per condition
opts.num_sets = 2;              % how many target sets per participant
opts.num_filler_trials = 80;    % how many filler trials

if strcmp(subjID, 'debug')
    % Change durations
    opts.txt_dur = opts.txt_dur/10;              
    opts.shape_dur = opts.shape_dur/10;            
    opts.ISI = opts.ISI/10;        
    opts.ITI = opts.ITI/10;                   
    opts.fix = opts.fix/10;  
end
if strcmp(subjID, 'debug') || strcmp(subjID, 'test')
    % Turn off SyncTests
    Screen('Preference', 'SkipSyncTests', 1);
end

% save options
save_filename = sprintf('complang_shapes_%s_run%d_data.mat', subjID, runNum);
if ~exist(opts.data_dir, 'dir'), mkdir(opts.data_dir); end
if exist(save_filename, 'file') && ~strcmp(subjID, 'debug')
    answer = input('Data already exists for this participant! Overwrite? (y/n)', s);
    if ~strcmpi(answer, 'y'), return; end
end
addpath(pwd, 'helpers');

% PICK STIMULI
if runNum == 1
    % get randSeed
    if nargin < 3
        rand_seed = input('Please enter a number to use as random seed     ');
    end
    opts.rand_seed = rand_seed;
    % set up order
    allstim_table = gen_subj_stim(rand_seed, opts);
    subj_stim_savename = sprintf('complang_shapes_%s_allstim.mat', ...
        subjID);
    save(fullfile(opts.data_dir,subj_stim_savename), 'allstim_table');
else
    subj_stim_savename = sprintf('complang_shapes_%s_allstim.mat', ...
        subjID);
    load(fullfile(opts.data_dir,subj_stim_savename), 'allstim_table');
end
% grab indices for the stim to be used this run
if runNum > opts.trials_per_cond
    % If they put in a run number > 10, let them do it but let them know
    %   that the participant will see the same stimuli as run mod(runNum,
    %   10)
    warning_msg = ['Experiment only configured for ' opts.trials_per_cond ...
        ' runs.  User will see the same stimuli that they saw in run ' ...
        mod(runNum, opts.trials_per_cond) '.'];
    warning(warning_msg);
end
run_rows = (allstim_table.rep == mod((runNum-1), opts.trials_per_cond)+1);
run_data_table = allstim_table(run_rows, :);
nTrials = height(run_data_table);
run_stim_order = randperm(nTrials);
data.run_stim_order = run_stim_order;
% Set up new columns
run_data_table.sent_onset = nan(nTrials, 1);
run_data_table.img_onset = nan(nTrials, 1);
run_data_table.resp = nan(nTrials, 1);
run_data_table.rt = nan(nTrials, 1);

% TIMING
% construct randomized ISIs
nTrialsPerISI = ceil(nTrials/length(opts.ISI));
ISI = repmat(opts.ISI, 1, nTrialsPerISI);
ISI = ISI(1:nTrials);
ISI = ISI(randperm(nTrials));
% Grab overall length of run, tell user
time = 2*opts.fix + nTrials*(opts.txt_dur+opts.shape_dur+opts.ITI) + sum(ISI);
data.T = time;

try
    %% SET UP DISPLAY
    % psychtoolbox preliminaries
    KbName('UnifyKeyNames'); % switch to Mac OS X naming scheme
    HideCursor;    
    % devices
    if IsWin || IsLinux
        opts.D = 0; % may not have support for PsychHID
    else % mac
        devices = PsychHID('devices');
        opts.D = [];
        for i = 1:length(devices)
            % grab the devices that are keyboards
            if strcmp(devices(i).usageName, 'Keyboard')
                opts.D = cat(2, opts.D, i);
            end
        end
    end
    
    % response buttons
    opts.keycodes = [KbName('1!'), KbName('2@')];
    trigger = [KbName('=+'), KbName('+'), KbName('space')];

    
    % display parameters
    opts.whichscreen = max(Screen('Screens'));
    [opts.window, opts.rect] = Screen('OpenWindow', opts.whichscreen,[0 0 0]); % open black window
    Screen('BlendFunction', opts.window,GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
    opts.textsize = 25;
    Screen(opts.window, 'TextSize', opts.textsize);
    opts.white = WhiteIndex(opts.window);
    opts.black = BlackIndex(opts.window);
    [screensize(1),screensize(2)] = Screen('WindowSize', opts.window);
    opts.xcenter = screensize(1)/2;
    opts.ycenter = screensize(2)/2;
    opts.wrapat = 60;
    
    % load images
    run_data_table.sent_txtr = cell(nTrials, 1);
    run_data_table.img_txtr = cell(nTrials, 1); % Create new column
    for t = 1:nTrials
        stim_sent = imread(run_data_table.sent_jpg{t});
        run_data_table.sent_txtr{t} = Screen(opts.window, 'MakeTexture', stim_sent);

        
        stim_img = imread(run_data_table.img_jpg{t});
        run_data_table.img_txtr{t} = Screen(opts.window, 'MakeTexture', stim_img);
    end

%% %%%%%%%%%%%%%%%%%%%% RUN EXPERIMENT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % wait for trigger
    if ~strcmp(subjID, 'debug')
        Screen('FillRect', opts.window, opts.white);
        DrawFormattedText(opts.window, 'Waiting for scanner','center','center',opts.black);
        Screen('Flip', opts.window);
        getchoice(opts,inf,trigger);
    end
    run_start = GetSecs;

    % beginning fixation
    Screen('FillRect', opts.window, opts.white);
    DrawFormattedText(opts.window,'+','center','center',opts.black,opts.wrapat);
    Screen('Flip', opts.window);
    getchoice(opts,opts.fix,[]);
        
    
    % TRIAL
    for t = 1:nTrials
        % stim i
        stimi = run_stim_order(t);
        
        % display sentence
%         Screen('FillRect', opts.window, opts.white);
%         sentString = getSentStr(run_data_table.sent{stimi});
%         DrawFormattedText(opts.window,sentString,'center','center', ...
%             opts.white, opts.wrapat);
        sent_texture = run_data_table.sent_txtr{stimi};
        Screen('DrawTexture', opts.window, sent_texture);
        Screen('Flip', opts.window);
        run_data_table.sent_onset(stimi) = GetSecs - run_start;
        getchoice(opts, opts.txt_dur, []);
        Screen('Flip', opts.window);
        
        % ISI
        Screen('FillRect', opts.window, opts.white);
        getchoice(opts, ISI(t), []);
        
        % display target
        img_texture = run_data_table.img_txtr{stimi};
        Screen('DrawTexture', opts.window, img_texture);
        Screen('Flip', opts.window);
        run_data_table.img_onset(stimi) = GetSecs - run_start;
        [resp, rt] = getchoice(opts, opts.shape_dur);
        getchoice(opts, opts.shape_dur-rt); 
        Screen('Flip', opts.window);
        run_data_table.resp(stimi) = resp;
        run_data_table.rt(stimi) = rt;
        
        % ITI fixation
        Screen('FillRect', opts.window, opts.white);
        DrawFormattedText(opts.window,'+','center','center',opts.black,opts.wrapat);
        Screen('Flip', opts.window);
        getchoice(opts,opts.ITI,[]);
        
        
    end

    % end fixation
    Screen('FillRect', opts.window, opts.white);
    DrawFormattedText(opts.window,'+','center','center',opts.black,opts.wrapat);
    Screen('Flip', opts.window);
    getchoice(opts,opts.fix,[]);
    

catch err
    % catch errors
    disp(err.message)
    for i = 1:length(err.stack)
        err.stack(i)
    end
    Screen('CloseAll');
    sca;
    Priority(0);
    ShowCursor;
    error('Something went wrong!');
end

% Close Psychtoolbox stuff
Screen('FillRect', opts.window, opts.white);
DrawFormattedText(opts.window, 'The run is over.', 'center', 'center', ...
    opts.black, opts.wrapat);
Screen('Flip', opts.window);
WaitSecs(0.5);
KbWait;
Screen('Flip', opts.window);

Screen('CloseAll');
Priority(0);
ShowCursor;

% SAVE
data.opts = opts;
data.run_data_table = run_data_table;
save(fullfile(opts.data_dir , save_filename), 'data');

%% Cleanup
rmpath(pwd,'helpers');

end


%% %%%%%%%%%%%%%%%%%%%%% SUBFUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [resp, rt] = getchoice(opts, timeout, k)
% resp = response; rt = response time
% opts = options structure, timeout = how long to wait, k = key to wait for

if nargin > 2, opts.keycodes = k; end

D = opts.D;
while KbCheck(D); WaitSecs(0.002); end % make sure no keys are depressed

start_time = GetSecs;
timeout = timeout + start_time;
escape = KbName('escape');

success = false; resp = 0;
while ~success && GetSecs < timeout
    pressed = false;
    while ~pressed && GetSecs < timeout
        [pressed, ~, kbData] = KbCheck(D);
    end
    if kbData(escape) == 1
        % they want out
        Screen('CloseAll'); ShowCursor; warning('user escaped!');
    else
        for i = 1:length(opts.keycodes)
            if kbData(opts.keycodes(i)) == 1
                success = 1;
                resp = i;
                rt = GetSecs - start_time;
                return;
            end
        end
    end
end

rt = nan;

end

