%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% find_poss_target_sets
%
% This will go through the cell array poss_sents (stored in poss_sents.mat)
%   and figure out which of these can work as base items.  It will return a
%   cell array poss_target_sets
%
% Created: bpritche, 02-08-2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialize
adj1 = [1 5]; adj2 = [2 6]; n = [3 7]; prep = 4;

load(fullfile(pwd, '..', 'poss_sents.mat'));
%assert(exist('poss_sents', 'var'), 'poss_sents load failed.');

addpath(fullfile(pwd, '..', 'helpers'));

num_sents = length(poss_sents);

%% Test sents
% Don't know size yet
poss_target_sets = {};
for i = 1:num_sents
    first_set = cell(12, 1);
    % Base for first sentence
    first_base = poss_sents{i};
    first_set{1} = first_base;
    
    % Adj1 swap, transformation 1
    first_t1 = first_base;
    new_adj1 = 3 - first_base(adj1(1));
    assert(new_adj1 == 1 || new_adj1 == 2, 'new_adj1 = %d', new_adj1)
    first_t1(adj1(1)) = new_adj1;    % 3-1=2, 3-2=1, swaps
    if ~validSent(first_t1), continue; end
    first_set{2} = first_t1;
    
    % Adj2 swap, transformation 2
    first_t2 = first_base;
    new_adj2 = 3 - first_base(adj2(1));
    assert(new_adj2 == 1 || new_adj2 == 2, 'new_adj2 = %d', new_adj2);
    first_t2(adj2(1)) = new_adj2;
    if ~validSent(first_t2), continue; end
    first_set{3} = first_t2;
    
    % Adj1 and Adj2 swap, transformation 3
    first_t3 = first_base;
    first_t3(adj1(1)) = 3 - first_base(adj1(1));
    first_t3(adj2(1)) = 3 - first_base(adj2(1));
    if ~validSent(first_t3), continue; end
    first_set{4} = first_t3;
    
    % N1 swap, transformation 4
    first_t4 = first_base;
    curr_n1 = first_base(n(1));
    poss_n1s = {};
    for j = 1:3
        if j == curr_n1, continue; end
        first_t4(n(1)) = j;
        if validSent(first_t4), poss_n1s{end+1} = first_t4; end
    end
    if isempty(poss_n1s), continue; end
    first_set{5} = poss_n1s;
    
    % Prep swap, transformation 5
    first_t5 = first_base;
    curr_prep = first_base(prep);
    if curr_prep == 1, first_t5(prep) = 2; 
    elseif curr_prep == 2, first_t5(prep) = 1;
    elseif curr_prep == 3, first_t5(prep) = 4;
    elseif curr_prep == 4, first_t5(prep) = 3;
    end
    if ~validSent(first_t5), continue; end
    first_set{6} = first_t5;
    
    % Adj3 swap, transformation 6
    first_t6 = first_base;
    first_t6(adj1(2)) = 3 - first_base(adj1(2));    % 3-1=2, 3-2=1, swaps
    if ~validSent(first_t6), continue; end
    first_set{7} = first_t6;
    
    % Adj4 swap, transformation 7
    first_t7 = first_base;
    first_t7(adj2(2)) = 3 - first_base(adj2(2));
    if ~validSent(first_t7), continue; end
    first_set{8} = first_t7;
    
    % Adj3 and Adj4 swap, transformation 8
    first_t8 = first_base;
    first_t8(adj1(2)) = 3 - first_base(adj1(2));
    first_t8(adj2(2)) = 3 - first_base(adj2(2));
    if ~validSent(first_t8), continue; end
    first_set{9} = first_t8;
    
    % N2 swap, transformation 9
    first_t9 = first_base;
    curr_n2 = first_base(n(2));
    poss_n2s = {};
    for j = 1:3
        if j == curr_n2, continue; end
        first_t9(n(2)) = j;
        if validSent(first_t9), poss_n2s{end+1} = first_t9; end
    end
    if isempty(poss_n2s), continue; end
    first_set{10} = poss_n2s;
    
    % Swap characters, transformation 10
    first_t10 = first_base;
    % swap adj1
    first_t10(adj1(1)) = first_base(adj1(2));
    first_t10(adj1(2)) = first_base(adj1(1));
    % swap adj2
    first_t10(adj2(1)) = first_base(adj2(2));
    first_t10(adj2(2)) = first_base(adj2(1));
    % swap n
    first_t10(n(1)) = first_base(n(2));
    first_t10(n(2)) = first_base(n(1));
    % save
    if ~validSent(first_t10), continue; end
    first_set{11} = first_t10;
    
    % Swap and keep meaning, transformation 11
    first_t11 = first_base;
    % swap adj1
    first_t11(adj1(1)) = first_base(adj1(2));
    first_t11(adj1(2)) = first_base(adj1(1));
    % swap adj2
    first_t11(adj2(1)) = first_base(adj2(2));
    first_t11(adj2(2)) = first_base(adj2(1));
    % swap n
    first_t11(n(1)) = first_base(n(2));
    first_t11(n(2)) = first_base(n(1));
    % swap prep
    if curr_prep == 1, first_t11(prep) = 2; 
    elseif curr_prep == 2, first_t11(prep) = 1;
    elseif curr_prep == 3, first_t11(prep) = 4;
    elseif curr_prep == 4, first_t11(prep) = 3;
    end
    if ~validSent(first_t11), continue; end
    first_set{12} = first_t11;
    
    %%% SECOND SET %%%
    for j = 1:num_sents
        second_set = cell(12, 1);
        % Base for first sentence
        second_base = poss_sents{j};
        if sent_in_set(second_base, first_set), continue; end
        second_set{1} = second_base;
    
        % Adj1 swap, transformation 1
        second_t1 = second_base;
        second_t1(adj1(1)) = 3 - second_base(adj1(1));    % 3-1=2, 3-2=1, swaps
        if ~validSent(second_t1) || sent_in_set(second_t1, first_set), continue; end
        second_set{2} = second_t1;
    
        % Adj2 swap, transformation 2
        second_t2 = second_base;
        second_t2(adj2(1)) = 3 - second_base(adj2(1));
        if ~validSent(second_t2) || sent_in_set(second_t2, first_set), continue; end
        second_set{3} = second_t2;
    
        % Adj1 and Adj2 swap, transformation 3
        second_t3 = second_base;
        second_t3(adj1(1)) = 3 - second_base(adj1(1));
        second_t3(adj2(1)) = 3 - second_base(adj2(1));
        if ~validSent(second_t3) || sent_in_set(second_t3, first_set), continue; end
        second_set{4} = second_t3;
    
        % N1 swap, transformation 4
        second_t4 = second_base;
        curr_n1 = second_base(n(1));
        poss_n1s = {};
        for k = 1:3
            if k == curr_n1, continue; end
            second_t4(n(1)) = k;
            if validSent(second_t4) && ~sent_in_set(second_t4, first_set) 
                poss_n1s{end+1} = second_t4; 
            end
        end
        if isempty(poss_n1s), continue; end
        second_set{5} = poss_n1s;
    
        % Prep swap, transformation 5
        second_t5 = second_base;
        curr_prep = second_base(prep);
        if curr_prep == 1, second_t5(prep) = 2; 
        elseif curr_prep == 2, second_t5(prep) = 1;
        elseif curr_prep == 3, second_t5(prep) = 4;
        elseif curr_prep == 4, second_t5(prep) = 3;
        end
        if ~validSent(second_t5), continue; end
        second_set{6} = second_t5;
    
        % Adj3 swap, transformation 6
        second_t6 = second_base;
        second_t6(adj1(2)) = 3 - second_base(adj1(2));    % 3-1=2, 3-2=1, swaps
        if ~validSent(second_t6) || sent_in_set(second_t6, first_set), continue; end
        second_set{7} = second_t6;
    
        % Adj4 swap, transformation 7
        second_t7 = second_base;
        second_t7(adj2(2)) = 3 - second_base(adj2(2));
        if ~validSent(second_t7) || sent_in_set(second_t7, first_set), continue; end
        second_set{8} = second_t7;
    
        % Adj3 and Adj4 swap, transformation 3
        second_t8 = second_base;
        second_t8(adj1(2)) = 3 - second_base(adj1(2));
        second_t8(adj2(2)) = 3 - second_base(adj2(2));
        if ~validSent(second_t8) || sent_in_set(second_t8, first_set), continue; end
        second_set{9} = second_t8;
    
        % N2 swap, transformation 9
        second_t9 = second_base;
        curr_n2 = second_base(n(2));
        poss_n2s = {};
        for k = 1:3
            if k == curr_n2, continue; end
            second_t9(n(2)) = k;
            if validSent(second_t9) && ~sent_in_set(second_t9, first_set)
                poss_n2s{end+1} = second_t9; 
            end
        end
        if isempty(poss_n2s), continue; end
        second_set{10} = poss_n2s;
    
        % Swap characters, transformation 10
        second_t10 = second_base;
        % swap adj1
        second_t10(adj1(1)) = second_base(adj1(2));
        second_t10(adj1(2)) = second_base(adj1(1));
        % swap adj2
        second_t10(adj2(1)) = second_base(adj2(2));
        second_t10(adj2(2)) = second_base(adj2(1));
        % swap n
        second_t10(n(1)) = second_base(n(2));
        second_t10(n(2)) = second_base(n(1));
        % save
        if ~validSent(second_t10) || sent_in_set(second_t10, first_set)
            continue; 
        end
        second_set{11} = second_t10;
    
        % Switch everything, transformation 11
        second_t11 = second_base;
        % adj1
        second_t11(adj1(1)) = second_base(adj1(2));
        second_t11(adj1(2)) = second_base(adj1(1));
        % adj2
        second_t11(adj2(1)) = second_base(adj2(2));
        second_t11(adj2(2)) = second_base(adj2(1));
        % n swap
        second_t11(n(1)) = second_base(n(2));
        second_t11(n(2)) = second_base(n(1));
        % prep swap
        if curr_prep == 1, second_t11(prep) = 2; 
        elseif curr_prep == 2, second_t11(prep) = 1;
        elseif curr_prep == 3, second_t11(prep) = 4;
        elseif curr_prep == 4, second_t11(prep) = 3;
        end
        if ~validSent(second_t11), continue; end
        second_set{12} = second_t11;
        
        % If we get here, this combo of sets is valid!!
        poss_target_sets{end+1} = {first_set, second_set};
    end
end

%% Clean up
rmpath(fullfile(pwd, '..', 'helpers'));
save('poss_target_sets.mat', 'poss_target_sets')