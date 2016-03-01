function saveName = getSaveName(sent)
% getSaveName(sent)
% Quite simple, takes an a sent array (from poss_sents) and turns it into
%   a string for this sentence (no spaces, can be used as dir or filename)
%
% Form: prep_char1_char2
%   Ex: above_bigRedCircle_smallBlueSquare
%
% Created: bpritche, 01/28/2016
% Edited: bpritche, 02/10/2016, account for filler sents
saveName = '';
if length(sent) == 7
    full_sent = true;
elseif length(sent) == 3
    full_sent = false;
else
    error('length sent = %d', length(sent));
end

% Prep
if full_sent
    switch sent(4)
        case 1, saveName = cat(2, saveName, 'above_');
        case 2, saveName = cat(2, saveName, 'below_');
        case 3, saveName = cat(2, saveName, 'infront_');
        case 4, saveName = cat(2, saveName, 'behind_');
        otherwise, error('PREP = %d', sent(4));
    end
else
    saveName = cat(2, saveName, 'filler_');
end

% 1Adj1
switch sent(1)
    case 1, saveName = cat(2, saveName, 'big');
    case 2, saveName = cat(2, saveName, 'small');
    otherwise, error('1ADJ1 = %d', sent(1));
end

% 1Adj2
switch sent(2)
    case 1, saveName = cat(2, saveName, 'Red');
    case 2, saveName = cat(2, saveName, 'Blue');
    otherwise, error('1ADJ2 = %d', sent(2));
end

% N1
switch sent(3)
    case 1, saveName = cat(2, saveName, 'Square');
    case 2, saveName = cat(2, saveName, 'Circle');
    case 3, saveName = cat(2, saveName, 'Triangle');
    otherwise, error('N1 = %d', sent(3));
end

if full_sent
    saveName = cat(2, saveName, '_');
    % 2Adj1
    switch sent(5)
        case 1, saveName = cat(2, saveName, 'big');
        case 2, saveName = cat(2, saveName, 'small');
        otherwise, error('2ADJ1 = %d', sent(5));
    end

    % 2Adj2
    switch sent(6)
        case 1, saveName = cat(2, saveName, 'Red');
        case 2, saveName = cat(2, saveName, 'Blue');
        otherwise, error('2ADJ2 = %d', sent(6));
    end

    % N1
    switch sent(7)
        case 1, saveName = cat(2, saveName, 'Square');
        case 2, saveName = cat(2, saveName, 'Circle');
        case 3, saveName = cat(2, saveName, 'Triangle');
        otherwise, error('N2 = %d', sent(7));
    end
end


end