function sentStr = getSentStr(sent)
% getSentStr(sent)
% Quite simple, takes an a sent array (from poss_sents) and turns it into
%   a string for this sentence (the full sentence as shown on screen)
%
% Created: bpritche, 02/04/2016
sentStr = 'A ';

% 1Adj1
switch sent(1)
    case 1, sentStr = cat(2, sentStr, 'big ');
    case 2, sentStr = cat(2, sentStr, 'small ');
    otherwise, error('1ADJ1 = %d', sent(1));
end

% 1Adj2
switch sent(2)
    case 1, sentStr = cat(2, sentStr, 'red ');
    case 2, sentStr = cat(2, sentStr, 'blue ');
    otherwise, error('1ADJ2 = %d', sent(2));
end

% N1
switch sent(3)
    case 1, sentStr = cat(2, sentStr, 'square');
    case 2, sentStr = cat(2, sentStr, 'circle');
    case 3, sentStr = cat(2, sentStr, 'triangle');
    otherwise, error('N1 = %d', sent(3));
end

if length(sent) == 3
    sentStr = cat(2, sentStr, '.');
    return;
end

sentStr = cat(2, sentStr, ' is ');

% Prep
switch sent(4)
    case 1, sentStr = cat(2, sentStr, 'above ');
    case 2, sentStr = cat(2, sentStr, 'below ');
    case 3, sentStr = cat(2, sentStr, 'in front of ');
    case 4, sentStr = cat(2, sentStr, 'behind ');
    otherwise, error('Prep = %d', sent(4));
end

sentStr = cat(2, sentStr, 'a ');

% 2Adj1
switch sent(5)
    case 1, sentStr = cat(2, sentStr, 'big ');
    case 2, sentStr = cat(2, sentStr, 'small ');
    otherwise, error('2ADJ1 = %d', sent(5));
end

% 2Adj2
switch sent(6)
    case 1, sentStr = cat(2, sentStr, 'red ');
    case 2, sentStr = cat(2, sentStr, 'blue ');
    otherwise, error('2ADJ2 = %d', sent(6));
end

% N1
switch sent(7)
    case 1, sentStr = cat(2, sentStr, 'square.');
    case 2, sentStr = cat(2, sentStr, 'circle.');
    case 3, sentStr = cat(2, sentStr, 'triangle.');
    otherwise, error('N2 = %d', sent(7));
end

end