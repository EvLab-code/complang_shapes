function vertStruct = absVerts(sent)
% absVerts(sent)
% Determine vertices of shapes in sentence, if positioned at [0,0]
%
% Input: sent, array formatted as the cells of poss_sents (see
%   make_poss_sents for doc)
% Output: vertStruct, a 2x1 struct with fields listed below.  Each element is
%   one shape. Fields:
%       x: list of x-coordinates
%       y: list of corresponding y-coordinates
%       center: [x,y] vertices of the center of the shape
%       w: width of the shape
%       h: height of the shape
%       shape: int, 1:3.  1: square, 2: circle, 3: triangle
%       color: 'red' or 'blue'
%       size: 'big' or 'small'
%
% Created: bpritche, 01-25-2016
% Edited: bpritche, 02-10-2016, account for filler sents

% initialize
square = 1; circle = 2; triangle = 3;
big = 1; small = 2;
colors = {[1 0 0], [0.2 0.6 1]}; % red, blue

adj1 = [1 5];
adj2 = [2 6];
n = [3 7];

big_size = 30;
small_size = 10;

if length(sent) == 7
    num_shapes = 2;
elseif length(sent) == 3
    num_shapes = 1;
else
    error('length sent = %d', length(sent))
end

%initialize in such a way that it's obvious if a variable isn't assigned
vertStruct(1:num_shapes) = struct('x',[],'y',[],'w',nan,'h',nan, ...
    'shape',nan,'color','green'); 

for i = 1:num_shapes
    shape = sent(n(i));
    vertStruct(i).shape = shape;
    size = sent(adj1(i));
    color = colors{sent(adj2(i))};
    vertStruct(i).color = color;
    switch shape
        case triangle % equilateral 
            if size == small
                x = [0 small_size/2 small_size];
                pointY = sqrt((small_size^2)-(small_size/2)^2); % geometry
                y = [0 pointY 0];
                center = [small_size/2 (1/3)*pointY];
                w = small_size;
                vertStruct(i).size = small;
            elseif size == big
                x = [0 big_size/2 big_size];
                pointY = sqrt((big_size^2)-(big_size/2)^2); % geometry
                y = [0 pointY 0];
                center = [big_size/2 (1/3)*pointY];
                w = big_size;
                vertStruct(i).size = big;
            else error('size = %d\n', size); 
            end
            vertStruct(i).x = x;
            vertStruct(i).y = y;
            vertStruct(i).center = center;
            vertStruct(i).h = pointY;
            vertStruct(i).w = w;
        case {square, circle}
            % circle drawn as rounded rectangle, same vertices
            if size == small
                vertStruct(i).x = [0 0 small_size small_size];
                vertStruct(i).y = [0 small_size 0 small_size];
                vertStruct(i).center = [small_size/2 small_size/2];
                vertStruct(i).h = small_size;
                vertStruct(i).w = small_size;
                vertStruct(i).size = small;
            elseif size == big
                vertStruct(i).x = [0 0 big_size big_size];
                vertStruct(i).y = [0 big_size 0 big_size];
                vertStruct(i).center = [big_size/2 big_size/2];
                vertStruct(i).h = big_size;
                vertStruct(i).w = big_size;
                vertStruct(i).size = big;
            else error('size = %d\n', size);
            end
        otherwise, error('shape = %d\n', shape);
    end
end

end