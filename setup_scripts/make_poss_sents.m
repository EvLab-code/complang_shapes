%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% make_poss_sents
%
% This will output a matfile with a cell, where each element is an array.
%   This will be a 1x7 integer array, of the form
%   [1ADJ1, 1ADJ2, 1N, PREP, 2ADJ1, 2ADJ2, 2N] and the integers will represent
%   possible values.  They can then be used to index into the cell arrays
%   ADJ1 = {'big','small'}, ADJ2 = {'red', 'blue'}, N = {'square',
%   'circle', 'triangle'}, and PREP = {'above', 'below', 'in front of',
%   'behind'}.  A sentence can then be made from these options.
%
% Created: bpritche, 1/25/2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% We know there are 528 options: 12 possible characters, can be paired with
%   11 other possible characters, so 66 unique pairs and 2 possible orders =
%   132 pairs, multiplied by 4 unique orders = 528 phrases.
poss_sents = cell(1,528);

% possible indices for each element of the phrase
poss_adj1 = 2;
poss_adj2 = 2;
poss_n = 3;
poss_prep = 4;

% loop
% sorry, not efficient in the slightest but I only have to do it once 
% possible TODO: make this not suck so much.
overall_i = 1;
for a = 1:poss_adj1
    for b = 1:poss_adj2
        for c = 1:poss_n
            for d = 1:poss_prep
                for e = 1:poss_adj1
                    for f = 1:poss_adj2
                        for g = 1:poss_n
                            if (a == e) && (b == f) && (c == g), continue; end
                            poss_sents{overall_i} = [a b c d e f g];
                            overall_i = overall_i + 1;
                            if overall_i > 529, error('Something''s gone wrong'); end
                        end
                    end
                end
            end
        end
    end
end

save('poss_sents.mat', 'poss_sents');
