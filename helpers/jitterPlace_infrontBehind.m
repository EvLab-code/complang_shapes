function vertStruct = jitterPlace_infrontBehind(prep, absVertStruct, opts)
% jitterPlace_overlap(prep, vertStruct)
% Places the shapes in the right place on the screen.
% Version 3, code in terms of 'anchor' and 'rel'.  When there's a size
%   difference, 'anchor' is the larger shape and the smaller shape moves in 
%   relation to its border.  When the shapes are the same size, 'anchor' is
%   the shape in front. This ensures that you can see the whole shape.
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
% Created: bpritche, 01-28-2016
% Edited: bpritche, 02-02-2016, use larger shape as anchor 

%% Initialize
SCREEN_W = opts.SCREEN_W;
SCREEN_H = opts.SCREEN_H;
infront = 3; behind = 4;
square = 1; circle = 2; triangle = 3;
% margins
screen_margin = 5;          % margin between shape and edge of screen
lineup_margin = 0.6;        % margin preventing borders of shapes from lining up

% Propagate non-place dependent info
for i = 1:2
    vertStruct(i).w = absVertStruct(i).w;
    vertStruct(i).h = absVertStruct(i).h;
    vertStruct(i).shape = absVertStruct(i).shape;
    vertStruct(i).color = absVertStruct(i).color;
end

assert(prep==3||prep==4,'Entered wrong function: prep = %d', prep);

%% Determine jitter for anchor shape
% Figure out which shape is bigger
if absVertStruct(1).size > absVertStruct(2).size % big = 1, small = 2
    anchorShape = 2; relShape = 1;
elseif absVertStruct(1).size < absVertStruct(2).size
    anchorShape = 1; relShape = 2; 
else
    % shapes same size, want border of back shape along border of front
    % so front shape is placed first and back shape is moved relative to it
    if prep == 3
        anchorShape = 1; relShape = 2;
    else anchorShape = 2; relShape = 1;
    end
end

% Place it - can basically go anywhere
% NOTE: on x and y vertices throughout.  The singular 'x' and 'y' values for a
%   single shape (ie anchor_x) represent the lower left corner of that shape.
% x-axis
anchorW = absVertStruct(anchorShape).w;
anchor_x_leftbound = screen_margin;
anchor_x_rightbound = SCREEN_W - screen_margin - anchorW;
assert(anchor_x_leftbound < anchor_x_rightbound, 'anchor shape too wide');
anchor_x = randInRange(anchor_x_leftbound, anchor_x_rightbound);
vertStruct(anchorShape).x = absVertStruct(anchorShape).x + anchor_x;
% y-axis
anchorH = absVertStruct(anchorShape).h;
anchor_y_lowbound = screen_margin;
anchor_y_highbound = SCREEN_H - screen_margin - anchorH;
assert(anchor_y_lowbound < anchor_y_highbound, 'anchor shape too tall');
anchor_y = randInRange(anchor_y_lowbound, anchor_y_highbound);
vertStruct(anchorShape).y = absVertStruct(anchorShape).y + anchor_y;

%% Determine jitter for smaller shape
% General algo note: places center of the smaller shape at some point along
%   the border of the bigger shape.  This ensures overlap.
abs_rel_xCenter = absVertStruct(relShape).center(1);
rel_xCenter_dist = abs_rel_xCenter; % dist from center to left edge
abs_rel_yCenter = absVertStruct(relShape).center(2);
rel_yCenter_dist = abs_rel_yCenter; % dist from center to bottom edge
relW = absVertStruct(relShape).w;
relH = absVertStruct(relShape).h;

switch vertStruct(anchorShape).shape
    case square
        %% SQUARE
        % Which side smaller shape will border
        validSide = false;      % can this shape fit on that side
        while ~validSide
            side = floor(randInRange(1,5)); % int bt 1 and 4
            if side == 5, side = 4; end
            assert(side >= 1 && side <= 4, 'Face = %d', side);
            if side == 1
                % left
                % See if it'll fit on screen
                x_peek = anchor_x - rel_xCenter_dist;
                if x_peek > screen_margin
                    validSide = true;
                else continue; 
                end
                % Fix x-axis
                vertStruct(relShape).x = absVertStruct(relShape).x + x_peek;
                % y-axis
                rel_yTop = anchor_y + anchorH;
                if rel_yTop+rel_yCenter_dist>SCREEN_W-screen_margin
                    rel_yTop = SCREEN_W-screen_margin-rel_yCenter_dist;
                end
                if anchor_y-rel_yCenter_dist<screen_margin, 
                    rel_yBottom = screen_margin + rel_yCenter_dist;
                else rel_yBottom = anchor_y; 
                end
                rel_yCenter = randInRange(rel_yBottom, rel_yTop);
                vertStruct(relShape).y = absVertStruct(relShape).y + ...
                    (rel_yCenter - rel_yCenter_dist);
            
           
            elseif side == 2
                % right
                % See if it fits on screen
                x_peek = anchor_x + anchorW + rel_xCenter_dist;
                if x_peek < SCREEN_W - screen_margin 
                    validSide = true;
                else continue; 
                end
                % Fix x-axis
                vertStruct(relShape).x = absVertStruct(relShape).x + ...
                    anchor_x + anchorW - rel_xCenter_dist;
                % y-axis
                rel_yTop = anchor_y + anchorH;
                if rel_yTop+rel_yCenter_dist>SCREEN_W-screen_margin
                    rel_yTop = SCREEN_W-screen_margin-rel_yCenter_dist;
                end
                if anchor_y-rel_yCenter_dist < screen_margin 
                    rel_yBottom = screen_margin + rel_yCenter_dist;
                else rel_yBottom = anchor_y; 
                end
                rel_yCenter = randInRange(rel_yBottom, rel_yTop);
                vertStruct(relShape).y = absVertStruct(relShape).y + ...
                    (rel_yCenter - rel_yCenter_dist);
            
            elseif side == 3
                % top
                % See if it'll fit
                y_peek = anchor_y + anchorH + (relH - rel_yCenter_dist);
                if y_peek < SCREEN_H - screen_margin
                    validSide = true;
                else continue; 
                end
                % Fix y-axis
                vertStruct(relShape).y = absVertStruct(relShape).y + ...
                    anchor_y + anchorH - rel_yCenter_dist;
                % x-axis
                if anchor_x-rel_xCenter_dist<screen_margin 
                    rel_xLeft = screen_margin + rel_xCenter_dist;
                else rel_xLeft = anchor_x; 
                end
                rel_xRight = anchor_x + anchorW;
                if rel_xRight+rel_xCenter_dist > SCREEN_W-screen_margin
                    rel_xRight = SCREEN_W-screen_margin-rel_xCenter_dist;
                end
                rel_xCenter = randInRange(rel_xLeft, rel_xRight);
                vertStruct(relShape).x = absVertStruct(relShape).x + ...
                    (rel_xCenter - rel_xCenter_dist);
                
            elseif side == 4
                % bottom
                % see if it'll fit on screen
                y_peek = anchor_y - rel_yCenter_dist;
                if y_peek > screen_margin 
                    validSide = true; 
                else continue; 
                end
                % Fix y-axis
                vertStruct(relShape).y = absVertStruct(relShape).y + ...
                    anchor_y - rel_yCenter_dist;
                % x-axis
                if anchor_x-rel_xCenter_dist < screen_margin 
                    rel_xLeft = screen_margin + rel_xCenter_dist;
                else rel_xLeft = anchor_x; 
                end
                rel_xRight = anchor_x + anchorW;
                if rel_xRight+rel_xCenter_dist > SCREEN_W-screen_margin
                    rel_xRight = SCREEN_W-screen_margin-rel_xCenter_dist;
                end
                rel_xCenter = randInRange(rel_xLeft, rel_xRight);
                vertStruct(relShape).x = absVertStruct(relShape).x + ...
                    (rel_xCenter - rel_xCenter_dist);
            else error('Noninteger side');
            end
        end
    case circle
        %% Circle
        anchor_center = ...
            [absVertStruct(anchorShape).center(1) + anchor_x ...
            absVertStruct(anchorShape).center(2) + anchor_y];
        anchor_radius = anchorW/2;
        validPlace = false;
        while ~validPlace
            % Randomly select theta
            theta = randInRange(0, 2*pi);
            % find this point along the circle
            rel_xCenter = anchor_center(1) + anchor_radius * cos(theta);
            rel_yCenter = anchor_center(2) + anchor_radius * sin(theta);
            % see if it'll fit
            fitsLeft = rel_xCenter-rel_xCenter_dist > screen_margin;
            fitsRight = rel_xCenter+rel_xCenter_dist < SCREEN_W-screen_margin;
            fitsTop = rel_yCenter+(relH-rel_yCenter_dist) < SCREEN_H-screen_margin;
            fitsBottom = rel_yCenter-rel_yCenter_dist > screen_margin;
            if fitsLeft && fitsRight && fitsTop && fitsBottom
                validPlace = true;
            end
        end
        
        rel_x = rel_xCenter - rel_xCenter_dist;
        vertStruct(relShape).x = absVertStruct(relShape).x + rel_x;
        rel_y = rel_yCenter - rel_yCenter_dist;
        vertStruct(relShape).y = absVertStruct(relShape).y + rel_y;
    
    case triangle
        %% Triangle
        anchor_topPoint = vertStruct(anchorShape).y(2);
        validPlace = false;
        while ~validPlace
            % Find x-value
            if anchor_x-rel_xCenter_dist < screen_margin
                rel_xLeft = screen_margin + rel_xCenter_dist;
            else rel_xLeft = anchor_x;
            end
            rel_xRight = anchor_x+anchorW;
            if rel_xRight+rel_xCenter_dist > SCREEN_W-screen_margin 
                rel_xRight = SCREEN_W-screen_margin-rel_xCenter_dist;
            end
            rel_xCenter = randInRange(rel_xLeft, rel_xRight);
            rel_x = rel_xCenter - rel_xCenter_dist;
            vertStruct(relShape).x = absVertStruct(relShape).x + rel_x;
            % Pick whether it'll be along top or bottom border
            tb_rand = rand;
            top = 1; bottom = 2;
            if tb_rand < 0.6, tb = top; else tb = bottom; end
            % Place it!
            if tb == bottom
                % Easy mode
                rel_y = anchor_y - rel_yCenter_dist;
                vertStruct(relShape).y = absVertStruct(relShape).y + rel_y;
            else
                triangle_xCenter = anchor_x + anchorW/2;
                if rel_xCenter == triangle_xCenter
                    % tippy top of the triangle
                    rel_yCenter = anchor_topPoint;
                elseif rel_xCenter < triangle_xCenter
                    % to the left of the tip
                    % Find point along line from bottom left to top of triangle
                    x1 = anchor_x; y1 = anchor_y;
                    x2 = anchor_x + anchorW/2;
                    y2 = anchor_topPoint;
                    slope = (y2-y1)/(x2-x1);
                    rel_yCenter = slope*(rel_xCenter-x1) + y1;
                else %rel_xCenter > triangle_xCenter
                    % to the right of the tip
                    % Find point along the line from top of triangle to bottom
                    %   right
                    x1 = anchor_x + anchorW/2; x2 = anchor_x + anchorW;
                    y1 = anchor_topPoint; y2 = anchor_y;
                    slope = (y2-y1)/(x2-x1);
                    rel_yCenter = slope*(rel_xCenter-x1) + y1;
                end
                
                % check to see if it fits
                fitsTop = rel_yCenter+(relH-rel_yCenter_dist) < SCREEN_H-screen_margin;
                fitsBottom = rel_yCenter-rel_yCenter_dist > screen_margin;
                if ~fitsTop || ~fitsBottom
                    continue; 
                else 
                    % save
                    rel_y = rel_yCenter - rel_yCenter_dist;
                    vertStruct(relShape).y = absVertStruct(relShape).y + rel_y;
                    validPlace = true;
                    break;
                end
            end
        end
end
