function drawCircle(shapeInfo, opts)
% drawCircle(shapeInfo, opts)
% draws a square on the current open figure
%
% Input:
%   shapeInfo: a 1x1 struct, with the (necessary) fields:
%       x: an array of x-coordinates
%       y: an array of corresponding y-coordinates
%       w: width of the shape
%       h: height of the shape
%       color: 'red' or 'blue'
%   opts: a struct with the (necessary) fields:
%       EdgeColor: Outline color for the shape
%       LineWidth: Width of border of shape

position = [shapeInfo.x(1), shapeInfo.y(1) ... lower left corner
    shapeInfo.w, shapeInfo.h];

rectangle('Position', position, ...
    'Curvature', [1 1], ...
    'FaceColor', shapeInfo.color, ...
    'EdgeColor', opts.EdgeColor, ...
    'LineWidth', opts.LineWidth);

end