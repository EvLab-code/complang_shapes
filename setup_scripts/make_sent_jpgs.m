%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% make_sent_jpgs
% Makes the sentence jpgs for the stimuli
%
% Created: bpritche, 02/04/2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialize
main_dir = fullfile(pwd, '..');
addpath(fullfile(main_dir, 'helpers'));

load(fullfile(main_dir, 'poss_sents.mat'));     % load poss_sents cell array

sent_filename = fullfile(pwd, 'sents.txt');
[sent_fid, sent_err] = fopen(sent_filename, 'w');
assert(sent_fid > 3, 'Couldn''t open sents.txt: %s', sent_err);

title_filename = fullfile(pwd, 'titles.txt');
[title_fid, title_err] = fopen(title_filename, 'w');
assert(title_fid > 3, 'Coudln''t open titles.txt: %s', title_err);

save_dir = fullfile(main_dir, 'sent_imgs');

%% Loop through sents
for i = 1:length(poss_sents)
    sent_nums = poss_sents{i};
    sent_str = getSentStr(sent_nums);
    fprintf(sent_fid, '%s\n', sent_str);
    save_str = getSaveName(sent_nums);
    fprintf(title_fid, '%s\n', save_str);
end

%% Make images
gen_sent_imgs(sent_filename, save_dir, title_filename);

%% Cleanup
rmpath(fullfile(main_dir, 'helpers'));
fclose(sent_fid);
fclose(title_fid);