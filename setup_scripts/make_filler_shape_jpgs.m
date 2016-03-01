%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% make_filler_shape_jpgs
%
% This will make the filler stimuli for the complang_shapes experiment.
%
% Created: bpritche, 2/10/2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Initialize
% opts
opts.img_per_sent = 20;
opts.SCREEN_W = 100;
opts.SCREEN_H = 80;
opts.EdgeColor = 'black';
opts.LineWidth = 5;
opts.saveDir = fullfile(pwd, '..', 'shape_imgs');

% important i's
adj1 = [1 5];
adj2 = [2 6];
n = [3 7];
prep = 4;
% important mappings
colors = {[1 0 0], [0.2 0.6 1]}; % red, blue
square = 1; circle = 2; triangle = 3;
big = 1; small = 2; red = 1; blue = 2;
% Possible sentences
poss_sents = {[big red triangle], [big red circle], [big blue circle], [big blue triangle], ...
    [small red triangle], [small red circle], [small blue triangle], [small blue circle]};

addpath(fullfile(pwd, '..','helpers'));
%% loop
for i = 1:length(poss_sents)
    % grab info on sentence
    sent = poss_sents{i};
    sent_saveName = getSaveName(sent);
    fprintf(1, '%d. %s...\n\t', i, sent_saveName);
    sent_saveDir = fullfile(opts.saveDir, sent_saveName);
    if ~exist(sent_saveDir, 'dir'), mkdir(sent_saveDir); end
    
    % grab shape info
    absVertStruct = absVerts(sent);
    vertStruct = jitterPlace_filler(absVertStruct, opts);
        
   %% Draw shapes
   % General settings
   clf; curr_fig = figure(1);
   axis([0 opts.SCREEN_W 0 opts.SCREEN_H]); axis off;
    switch vertStruct.shape
        case square, drawSquare(vertStruct, opts);
        case circle, drawCircle(vertStruct, opts);
        case triangle, drawTriangle(vertStruct, opts);
        otherwise, error('Invalid input for shape: %d\n', vertStruct(k).shape);
    end

    %% Save shape
    img_saveName = sprintf('%s_1.jpg', sent_saveName);
    %print(fullfile(sent_saveDir, img_saveName), '-djpeg');
    saveas(gcf, fullfile(sent_saveDir, img_saveName));
    fprintf(1, '\n');
end

%% Clean up
rmpath(fullfile(pwd,'..','helpers'));