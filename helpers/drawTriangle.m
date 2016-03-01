function drawTriangle(shapeInfo, opts)
% drawTriangle(shapeInfo, opts)
% draws a square on the current open figure
%
% Input:
%   shapeInfo: a 1x1 struct, with the (necessary) fields:
%       x: an array of x-coordinates
%       y: an array of corresponding y-coordinates
%       color: 'red' or 'blue'
%   opts: a struct with the (necessary) fields:
%       EdgeColor: Outline color for the shape
%       LineWidth: Width of border of shape

patch(shapeInfo.x, shapeInfo.y, ...
    shapeInfo.color, ...
    'EdgeColor', opts.EdgeColor, ...
    'LineWidth', opts.LineWidth);

end