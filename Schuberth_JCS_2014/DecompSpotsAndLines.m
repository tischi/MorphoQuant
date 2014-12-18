function [ imSpots imLines ] = DecompSpotsAndLines( im, linelength, dAngle )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    %% imLine = supr_alpha(imopen(im,line_alpha)) -
    %% mean_alpha(imopen(im,line_alpha));
    
    nAngles = 180/dAngle;
    imLineStack = zeros(nAngles,size(im,1),size(im,2));
    
    % circular
    da = 1;
    indAngle(1:da) = 1:da;
    indAngle(da+1:da+nAngles) = 1:nAngles;
    indAngle(end+1:end+da) = 1:da;
    
    for iAngle = 1 : nAngles
        angle = dAngle * (iAngle-1);
        se{iAngle} = strel('line',linelength,angle);
        imLineStack(iAngle,:,:) = grayopen(im,se{iAngle});
        %imLineStack(iAngle,:,:) = grayopenbyrecon(im,se{iAngle}); 
    end

    %im = [];
    %im = imLineStack(:,1:5,1:5);
    [imMax(:,:) imIndMax(:,:)] =  max(imLineStack);
    
    %imIndMax = imIndMax + da; %% shift by one to match the circular angle indexing
    %for r = 1 : size(im,1)
    %    for c = 1 : size(im,2)
    %        imMax2(r,c) = imLineStack(indAngle(imIndMax(r,c)),r,c);
    %        imMaxP1(r,c) = imLineStack(indAngle(imIndMax(r,c)+da),r,c);
    %        imMaxM1(r,c) = imLineStack(indAngle(imIndMax(r,c)-da),r,c);
    %    end
    %end
    
    %imMax2
    %imMaxAround = (imMaxP1 + imMaxM1)/2;
    
    %imMean(:,:) = mean(imLineStack);
    %imSum(:,:) = sum(imLineStack);
    imMin(:,:) = min(imLineStack);
    %imLine(:,:) = imMax - imMaxAround;
    %imMeanRest(:,:) = (imSum - imMax)/(size(imLineStack,1)-1);
    imLines(:,:) = imMax - imMin;
    
    %% at this point i would need something to only subtract the lines if
    %% they are dimm.
    imSpots = im - imLines;
   
    %imLine = imLine ./ imNoiseAvg;
    
    %figure; imagesc(im); colormap(gray)
    %figure; imagesc(imLine); colormap(gray)
    %figure; imagesc(imOut); colormap(gray)
   
    
    %figure; imagesc(imLine);colormap(gray)
    %figure; imagesc(imLine2);colormap(gray)
    
    
end

