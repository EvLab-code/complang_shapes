%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% make_sent_jpgs
% Makes the sentence jpgs for the stimuli
%
% Created: bpritche, 02/10/2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialize
main_dir = fullfile(pwd, '..');
addpath(fullfile(main_dir, 'helpers'));

square = 1; circle = 2; triangle = 3;
big = 1; small = 2; red = 1; blue = 2;
% Possible sentences
poss_sents = {[big red triangle], [big red circle], [big blue circle], [big blue triangle], ...
    [small red triangle], [small red circle], [small blue triangle], [small blue circle]};

sent_filename = fullfile(pwd, 'filler_sents.txt');
[sent_fid, sent_err] = fopen(sent_filename, 'w');
assert(sent_fid >= 3, 'Couldn''t open filler_sents.txt: %s', sent_err);

title_filename = fullfile(pwd, 'filler_titles.txt');
[title_fid, title_err] = fopen(title_filename, 'w');
assert(title_fid >= 3, 'Coudln''t open filler_titles.txt: %s', title_err);

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