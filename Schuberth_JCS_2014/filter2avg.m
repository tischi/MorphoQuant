function [ out ] = filter2avg( im, R )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

    se = fspecial('disk', R);
    out = imfilter(im,se,'replicate') / sum(se(:));
    
end

