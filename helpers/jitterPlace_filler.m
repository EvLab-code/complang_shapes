function vertStruct = jitterPlace_filler(absVertStruct, opts)
% jitterPlace_filler(absVertStruct, opts)
% Places the shape in the right place on the screen.
%
% Input: 
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
% Created: bpritche, 02-10-2016

%% Initialize
SCREEN_W = opts.SCREEN_W;
SCREEN_H = opts.SCREEN_H;
% margins
screen_margin = 5;          % margin between shape and edge of screen
% overlaps, all relative to the bottom shape (above/below) or behind shape
%   (infront/behind)
bottom_min_overlap = 0.3;  % minimum overlap between bottom and top shape

% Propagate non-place dependent info
vertStruct.w = absVertStruct.w;
vertStruct.h = absVertStruct.h;
vertStruct.shape = absVertStruct.shape;
vertStruct.color = absVertStruct.color;


%% Determine jitter
w = absVertStruct.w;
h = absVertStruct.h;
% x-axis
% center
center_x = SCREEN_W/2;
new_x = center_x - (w/2);
vertStruct.x = absVertStruct.x + new_x;
% y-axis
center_y = SCREEN_H/2;
new_y = center_y - (h/2);
vertStruct.y = absVertStruct.y + new_y;

end