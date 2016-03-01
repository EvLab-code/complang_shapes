function vertStruct = jitterPlace_overlap(prep, absVertStruct, opts)
% jitterPlace_overlap(prep, vertStruct)
% Places the shapes in the right place on the screen.
% NOTE: Uses algorithm that looks at % overlap between front and back
%   shape.  Was buggy and unnecessarily complicated wrt circles and
%   triangles - see jitterPlace for current algorithm.
%
% Input: 
%   prep: int, index for the preposition of the sentence
%   absVertStruct: structure from absVerts, 2x1 struct with fields x and y.
%       Each is an array representing the vertices when the bottom right
%       corner is at [0,0]
%   opts: structure with options defined in main file. Required fields:
%       SCREEN_W: width of figure on which we'll be drawing the shapes
%       SCREEN_H: height of figure on which we'll be drawing the shapes
%
% Output: 
%   vertStruct: structure of same format as vertStruct, but with x
%       and y representing where each shape will actually be on the screen
%
% Created: bpritche, 01-26-2016

%% Initialize
SCREEN_W = opts.SCREEN_W;
SCREEN_H = opts.SCREEN_H;

above = 1;
below = 2;
infront = 3;
behind = 4;
% margins
screen_margin = 5;          % margin between shape and edge of screen
shape_margin = 5;           % margin between shapes
% overlaps, all relative to the bottom shape (above/below) or behind shape
%   (infront/behind)
bottom_min_overlap = 0.3;  % minimum overlap between bottom and top shape
behind_min_overlap_prop = 0.3;   % minimum overlap between back and front shape
behind_max_overlap_prop = 0.7;   % maximum overlap between back and front shape

% Propagate non-place dependent info
for i = 1:2
    vertStruct(i).w = absVertStruct(i).w;
    vertStruct(i).h = absVertStruct(i).h;
    vertStruct(i).shape = absVertStruct(i).shape;
    vertStruct(i).color = absVertStruct(i).color;
end

switch prep
    %% Above/below
    case {above, below}
        if prep == above 
            topShape = 1;
            bottomShape = 2;
        else
            topShape = 2; 
            bottomShape = 1;
        end
        
        %% Determine jitter for top shape.
        topW = absVertStruct(topShape).w;
        topH = absVertStruct(topShape).h;
        bottomW = absVertStruct(bottomShape).w;
        bottomH = absVertStruct(bottomShape).h;
        % x-axis
        top_x_left = screen_margin;
        top_x_right = SCREEN_W - screen_margin - topW;
        if top_x_left>top_x_right, error('Both shapes can''t fit (left-right) without overlap!'); end
        top_x = randInRange(top_x_left, top_x_right);
        vertStruct(topShape).x = absVertStruct(topShape).x + top_x;
        % y-axis
        top_y_bottom = screen_margin + bottomH + shape_margin;
        top_y_top = SCREEN_H - screen_margin - topH;
        if top_y_bottom>top_y_top, error('Both shapes can''t fit (up-down) without overlap!'); end
        top_y = randInRange(top_y_bottom, top_y_top);
        vertStruct(topShape).y = absVertStruct(topShape).y + top_y;
        
        %% Determine jitter for bottom shape
        % x-axis
        bottom_x_left = top_x - ((1-bottom_min_overlap)*bottomW);
        if bottom_x_left < screen_margin, bottom_x_left = screen_margin; end
        bottom_x_right = top_x + topW - bottom_min_overlap*bottomW;
        if bottom_x_right+bottomW > (SCREEN_W-screen_margin), bottom_x_right = SCREEN_W - screen_margin - bottomW; end
        bottom_x = randInRange(bottom_x_left, bottom_x_right);
        vertStruct(bottomShape).x = absVertStruct(bottomShape).x + bottom_x; 
        % y-axis
        bottom_y_bottom = screen_margin;
        bottom_y_top = top_y - shape_margin - bottomH;
        if bottom_y_top < screen_margin, bottom_y_top = screen_margin; end
        bottom_y = randInRange(bottom_y_bottom, bottom_y_top);
        vertStruct(bottomShape).y = absVertStruct(bottomShape).y + bottom_y;
    

    %% In front of/behind
    case {infront, behind}
        if prep == infront
            frontShape = 1;
            behindShape = 2;
        else
            frontShape = 2;
            behindShape = 1;
        end
        
        %% Determine jitter for behind shape 
        % x-axis
        behindW = absVertStruct(behindShape).w;
        behind_x_left = screen_margin;
        behind_x_right = SCREEN_W - screen_margin - behindW;
        behind_x = randInRange(behind_x_left, behind_x_right);
        vertStruct(behindShape).x = absVertStruct(behindShape).x + behind_x;
        % y-axis
        behindH = absVertStruct(behindShape).h;
        behind_y_bottom = screen_margin;
        behind_y_top = SCREEN_H - screen_margin - behindH;
        behind_y = randInRange(behind_y_bottom, behind_y_top);
        vertStruct(behindShape).y = absVertStruct(behindShape).y + behind_y;
        
        %% Determine jitter for front shape 
        % (a bit harder)
        
        %%% x-axis: can be to left or right of back shape
        frontW = absVertStruct(frontShape).w;
        behind_x_max_overlap = behind_max_overlap_prop*behindW;
        behind_x_min_overlap = behind_min_overlap_prop*behindW;
        % default vals
        front_left_poss = true;
        front_right_poss = true;
        % if to the left
        front_left_rightlimit = behind_x - (frontW-behind_x_max_overlap);
        if front_left_rightlimit < screen_margin, front_left_poss = false; end
        front_left_leftlimit = behind_x - (frontW-behind_x_min_overlap);
        if front_left_leftlimit < screen_margin, front_left_leftlimit = screen_margin; end
        % if to the right
        front_right_leftlimit = behind_x + (behindW - behind_x_max_overlap);
        if (front_right_leftlimit + frontW) > (SCREEN_W-screen_margin)
            front_right_poss = false;
        end
        front_right_rightlimit = behind_x + (behindW - behind_x_min_overlap);
        if (front_right_rightlimit + frontW) > (SCREEN_W-screen_margin)
            front_right_rightlimit = SCREEN_W - screen_margin - frontW;
        end
        % now pick if it'll be left or right
        side = 0; % 1 = left, 2 = right
        if ~front_left_poss && ~front_right_poss
            error('Front can''t be to left or right of back, some calculation done wrong.\n');
        elseif ~front_left_poss, side = 2;
        elseif ~front_right_poss, side = 1;
        else
            side_01 = rand;
            if side_01 < 0.6, side = 1; else side = 2; end
        end
        if side == 1
            front_x = randInRange(front_left_leftlimit, front_left_rightlimit);
        elseif side == 2
            front_x = randInRange(front_right_leftlimit, front_right_rightlimit);
        else error('Side = %d (right/left), what even\n', side);
        end
        vertStruct(frontShape).x = absVertStruct(frontShape).x + front_x;
        
        %%% y-axis: can be above or below
        frontH = absVertStruct(frontShape).h;
        behind_y_min_overlap = behind_min_overlap_prop*behindH;
        behind_y_max_overlap = behind_max_overlap_prop*behindH;
        % default values
        front_above_poss = true;
        front_below_poss = true;
        % if above
        front_above_bottomlimit = behind_y + behindH-behind_y_max_overlap;
        if front_above_bottomlimit + frontH > SCREEN_H - screen_margin
            front_above_poss = false;
        end
        front_above_toplimit = behind_y + behindH-behind_y_min_overlap;
        if front_above_toplimit + frontH > SCREEN_H - screen_margin
            front_above_toplimit = SCREEN_H - screen_margin - frontH;
        end
        % if below
        front_below_toplimit = behind_y - (frontH-behind_y_max_overlap);
        if front_below_toplimit < screen_margin, front_below_poss = false; end
        front_below_bottomlimit = behind_y - (frontH-behind_y_max_overlap);
        if front_below_bottomlimit < screen_margin, front_below_bottomlimit = screen_margin; end
        % now pick if above or below
        side = 0; % 1 = above, 2 = below
        if ~front_below_poss && ~front_above_poss
            error('Front can''t be above or below back, some calculation went wrong!\n');
        elseif ~front_below_poss, side = 1;
        elseif ~front_above_poss, side = 2;
        else
            side_01 = rand;
            if side_01 < 0.6, side = 1; else side = 2; end
        end
        if side == 1
            front_y = randInRange(front_above_bottomlimit, front_above_toplimit);
        elseif side == 2
            front_y = randInRange(front_below_bottomlimit, front_below_toplimit);
        else 
            error('side = %d (above/below), what even.\n', side);
        end
        vertStruct(frontShape).y = absVertStruct(frontShape).y + front_y;
        
    otherwise 
        error('How did you get here, prep = %d\n', prep);
end