%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% make_shapes_jpgs
%
% This will make the image stimuli for the complang_shapes experiment.
%
% Created: bpritche, 1/25/2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Initialize
% opts
opts.img_per_sent = 20;
opts.SCREEN_W = 100;
opts.SCREEN_H = 80;
opts.EdgeColor = 'black';
opts.LineWidth = 5;
opts.saveDir = fullfile(pwd, 'shape_imgs');

% Possible sentences
load poss_sents.mat % loads cell array poss_sents, see make_poss_sents.m for doc
% important i's
adj1 = [1 5];
adj2 = [2 6];
n = [3 7];
prep = 4;
% important mappings
colors = {[1 0 0], [0.2 0.6 1]}; % red, blue
square = 1; circle = 2; triangle = 3;
above = 1; below = 2; infront = 3; behind = 4;

addpath('helpers');
%% loop
for i = 1:length(poss_sents)
    % grab info on sentence
    sent = poss_sents{i};
    %if sent(prep) < 3, continue; end % already did above/below
    %if sent(n(1)) ~= square && sent(n(2) ~= square), continue; end
    sent_saveName = getSaveName(sent);
    fprintf(1, '%d. %s...\n\t', i, sent_saveName);
    sent_saveDir = fullfile(opts.saveDir, sent_saveName);
    if ~exist(sent_saveDir, 'dir'), mkdir(sent_saveDir); end
    
    % grab absolute shape info
    absVertStruct = absVerts(sent);
    
    % now for specifics
    for j = 1:opts.img_per_sent
        fprintf(1, '%d ', j);
        % determine where shapes will be on screen
        if sent(prep) < 3 
            vertStruct = jitterPlace_aboveBelow(sent(prep), absVertStruct, opts); 
        else
            vertStruct = jitterPlace_infrontBehind(sent(prep), absVertStruct, opts);
        end
        
        %% Draw shapes
        % General settings
        clf; curr_fig = figure(1);
        axis([0 opts.SCREEN_W 0 opts.SCREEN_H]); axis off;
%         set(gcf,'PaperPosition', [0 0 opts.SCREEN_W opts.SCREEN_H], ... %set dimensions for img
%            'Color', 'white'); 
        % Determine order for drawing shapes on screen
        if sent(prep) == above || sent(prep) == below
            % order or presentation irrelevant
            order = 1:2;
        elseif sent(prep) == infront, order = [2 1]; % behind shape must be drawn first
        elseif sent(prep) == behind, order = 1:2;
        else error('Invalid input for prep: %d\n', sent(prep));
        end
        for k = order
            switch vertStruct(k).shape
                case square, drawSquare(vertStruct(k), opts);
                case circle, drawCircle(vertStruct(k), opts);
                case triangle, drawTriangle(vertStruct(k), opts);
                otherwise, error('Invalid input for shape: %d\n', vertStruct(k).shape);
            end
        end
        
        %% Save shape
        img_saveName = sprintf('%s_%d.jpg', sent_saveName, j);
        %print(fullfile(sent_saveDir, img_saveName), '-djpeg');
        saveas(gcf, fullfile(sent_saveDir, img_saveName));
    end
    fprintf(1, '\n');
end

%% Clean up
rmpath('helpers');