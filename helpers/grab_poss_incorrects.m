function poss_incorrects = grab_poss_incorrects(sent_set, cond_i, opts)
% Usage: grab_poss_incorrects(sent_set, cond_i)
%
% This will take a sentence and give you a cell of jpgs corresponding
% to all of the images that could potentially serve as incorrect images (ie
% unmatched to the sentence)
%
% Input: 
%   sent_set: a cell of sentences, as found in poss_target_sets.mat
%   cond_i: an index into this set, represents a condition/transformation
%   opts: options structure, must have the field .shape_stim_dir
%
% Output:
%   poss_incorrects: a cell of strings, each string representing a path to
%       a jpg

poss_incorrects = {};
for i = 1:length(sent_set)
    if i == cond_i, continue; end
    sents = sent_set{i};
    
    % if it's a single sentence
    if ~iscell(sents)
        img_jpg = getImgJpg(sents);
        poss_incorrects = cat(2, poss_incorrects, img_jpg);
        continue;
    end
    
    % if there's multiple possibilities
    for j = 1:length(sents)
        img_jpg = getImgJpg(sents{j});
        poss_incorrects = cat(2, poss_incorrects, img_jpg);
    end
    
end

function jpg_path = getImgJpg(sent)
    % Take in the sentence, output a string of the full path to the
    % associated jpg
    jpg_base = getSaveName(sent);
    
    if strncmp(jpg_base, 'filler_', length('filler_'))
        filler = true;
    else filler = false;
    end

    jpg_num = mod(cond_i, 10) + 10;
    if ~filler, jpg_name = sprintf('%s_%d.jpg', jpg_base, jpg_num);
    else jpg_name = sprintf('%s_1.jpg', jpg_base);
    end
    jpg_path = fullfile(opts.shape_stim_dir, jpg_base, jpg_name);
end

end