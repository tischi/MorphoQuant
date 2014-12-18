function h = myShowImOverlayText(imMaskBoundary, im, imSeg, info, sVis)
%UNTITLED14 Summary of this function goes here
%   Detailed explanation goes here

    intensities = sort(im(:),'descend');
    vMin = intensities(end-10);
    vMax = intensities(10);
    %vMin = min(im(:));
    %vMax = max(im(:));
    
    %imBoundary = imdilate(imSeg,strel('disk',1)) - imSeg;
    imRGB{1} = (im-vMin)/(vMax-vMin);
    imRGB{1}(imRGB{1}>1) = 1;
    imRGB{1}(imRGB{1}<0) = 0;
    imRGB{2} = imRGB{1};
    imRGB{3} = imRGB{1};
    
    %% segmentation
    idsBig = (imSeg==1)&(imSeg~=2);
    idsSmall = (imSeg==2)&(imSeg~=1);
   
    imRGB{1}(idsBig) = 1;
    imRGB{2}(idsBig) = 0;
    
    imRGB{1}(idsSmall) = 0;
    imRGB{2}(idsSmall) = 1;
    
    imRGB{3}(imSeg>0) = 0;
    
    
    %% cells
    imRGB{3}(imMaskBoundary>0) = 0.5;
    
    imComp = cat(3, imRGB{1}, imRGB{2}, imRGB{3});
   
    ri = size(imComp,1);
    ci = size(imComp,2);
  
    scrsz = get(0,'ScreenSize');             
    cs = scrsz(3);
    rs = scrsz(4);
    
    d = 80;
    l = d;
    b = d;
    c = cs - 2*d; %% probably an issue when using remote control :-)
    r = ri*(c/ci);
    if(r>0.8*rs) %% figure too high
        r = round(0.8*rs);
        c = round(c*0.8*rs/r);
    end
    h = figure('Position',[l b c r],'PaperPositionMode','auto','Visible',sVis);
    set(gca,'Position',[0 0 1 1]);
    imagesc(imComp);
    set(gca,'xtick',[],'ytick',[]); 
    colormap('default');
    
    if(length(info))
        text(info.c ,info.r , info.text , 'color', [0.8 0.8 0.8], 'BackgroundColor', [0 0 0], 'VerticalAlignment', 'bottom', 'HorizontalAlignment','center', ...
            'FontUnits', 'pixels', 'FontSize', 15);
    end
    
end

