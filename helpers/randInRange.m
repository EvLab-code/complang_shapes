function randNum = randInRange(min, max)
% Usage: randInRange(min, max)
% Gives you a random floating point number between min and max
% 
% Created: bpritche, 01/27/2016
    randNum = (max-min)*rand + min;
end