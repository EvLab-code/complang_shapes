function valid = validSent(sent)
% validSent(sent)
% Checks if this is a valid sentence (i.e. if it doesn't have two
%   characters interacting with each other)
% Input: sent
% Output: valid, logical
% bpritche 02-08-2016
sameAdj1 = (sent(1) == sent(5));
sameAdj2 = (sent(2) == sent(6));
sameN = (sent(3) == sent(7));

valid = ~(sameAdj1 && sameAdj2 && sameN);

end