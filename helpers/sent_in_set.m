function valid = sent_in_set(sent, test_set)
% figures out if a particular sentence is in the first target set.  This is
%   used for determining possible target sets.
%
% Input: 
%   sent: the sentence we're querying
%   test_set: the target set we want to avoid collision with (cell array
%   of 12 sentences)
% Output: valid, boolean indicating if sent is in test_set
%
% Created: bpritche, 02-08-2016

valid = false; % to save time, only set valid = true if we get to the end

one_poss = [1 2 3 4 5 7 8 9 11 12];
for i = one_poss
    if isequal(test_set{i}, sent), return; end
end

multi_poss = [5 10];
for i = multi_poss
    match_indices = cellfun(@(x)isequal(x,sent),test_set{i});
    if ~isempty(find(match_indices,1)), return; end
end

valid = true;

end