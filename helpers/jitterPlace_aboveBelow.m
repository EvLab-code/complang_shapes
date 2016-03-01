function vertStruct = jitterPlace_aboveBelow(prep, absVertStruct, opts)
% jitterPlace_overlap(prep, vertStruct)
% Places the shapes in the right place on the screen.
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

%% Initialize
SCREEN_W = opts.SCREEN_W;
SCREEN_H = opts.SCREEN_H;

above = 1;
below = 2;
% margins
screen_margin = 5;          % margin between shape and edge of screen
shape_margin = 5;           % margin between shapes
% overlaps, all relative to the bottom shape (above/below) or behind shape
%   (infront/behind)
bottom_min_overlap = 0.3;  % minimum overlap between bottom and top shape

% Propagate non-place dependent info
for i = 1:2
    vertStruct(i).w = absVertStruct(i).w;
    vertStruct(i).h = absVertStruct(i).h;
    vertStruct(i).shape = absVertStruct(i).shape;
    vertStruct(i).color = absVertStruct(i).color;
end

assert(prep==1||prep==2,'Entered wrong function: prep = %d', prep);

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

end