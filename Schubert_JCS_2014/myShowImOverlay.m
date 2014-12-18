function h = myShowImOverlay(im,imSeg,scale)
%UNTITLED14 Summary of this function goes here
%   Detailed explanation goes here

    scrsz = get(0,'ScreenSize');             
    
    vMax = max(im(:));
    vMin = min(im(:));
    
    imBoundary = imdilate(imSeg,strel('disk',1)) - imSeg;
    imRGB{1} = (im-vMin)/(vMax-vMin);
    imRGB{2} = imRGB{1};
    imRGB{3} = imRGB{1};
    
    imRGB{2}(imBoundary>0) = 1;
    imRGB{3}(imBoundary>0) = 1;
    
    imComp = cat(3, imRGB{1}, imRGB{2}, imRGB{3});
    
    
    h = figure('Position',[100 100 size(imComp,2)*scale size(imComp,1)*scale]);
    set(gca,'Position',[0 0 1 1])
    imagesc(imComp);
    set(gca,'xtick',[],'ytick',[]); 
    colormap('default') 
  
end

