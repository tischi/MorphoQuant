function [  imSmall imBig ] = DecompSmallAndBig( im, r )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    se = strel('disk', r);
    %imBig = grayopen(im, se);
    imBig = grayopenbyrecon(im, se); 
    % issues with reconstruction:
    % - whether the ER rim reappears depends on whether there is a seed in
    % the Golgi area, from which it can be reconstructed, this is different
    % dependening on the intensity in the Golgi area in the respective
    % cell; thus the content of the BG image can depend on the forground
    % image, which can be irritating....
    % 
    imSmall = im - imBig;
    
end
