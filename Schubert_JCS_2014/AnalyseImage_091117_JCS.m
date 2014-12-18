function [imCellOutlines imStack imStackSeg info features] = AnalyseImage_091117_JCS(sExpMaskStack,param,imText)

    %% load image and masks
    iExp = param.numFile.val;
    iImage = param.numImage.val;
    
    sExp = sExpMaskStack{iExp,1};
    sMask = sExpMaskStack{iExp,2};
    sStack = sExpMaskStack{iExp,3};
    sMaskBG = sExpMaskStack{iExp,4};
    
    % load image
    im(:,:) = double(imread([param.sPath.val sStack],iImage));
    if(param.scale.val<1)
        im = imresize(im, param.scale.val, 'bilinear'); %% scale down
    end
    [sr sc] = size(im); 
   
    % load cell mask
    imMaskCells = double(imread([param.sPath.val sMask])); 
    if(param.scale.val<1)
        imMaskCells = imresize(imMaskCells, param.scale.val, 'bilinear'); %% scale down
    end
    vMax = max(imMaskCells(:));
    imMaskCells = (imMaskCells==vMax); %% remove blurred pixels
     
    %% load BG mask 
    imMaskBG = double(imread([param.sPath.val sMaskBG])); 
    if(param.scale.val<1)
        imMaskBG = imresize(imMaskBG, param.scale.val, 'bilinear'); %% scale down
    end
    vMax = max(imMaskBG(:));
    imMaskBG = (imMaskBG == vMax); %% remove blurred pixels
    intensitiesBG = double(im(imMaskBG));
    medBG = median(intensitiesBG);
    imMinusBG = im - medBG;
      
    [imLabelCells, nCells] = bwlabel(imMaskCells);
  
    iCellStart = 1; 
    iCellEnd = nCells; 
    
    
    for iCell = iCellStart : iCellEnd

        imMaskCell = (imLabelCells(:,:) == iCell);
        idsCell = find(imMaskCell);

        %% work on cropped images
        dPad = round(param.strucWidthTH.val(1));
        [r,c] = ind2sub([sr sc],idsCell);
        rmax = min(sr,max(r)+dPad);
        rmin = max(1,min(r)-dPad);
        cmax = min(sc,max(c)+dPad);
        cmin = max(1,min(c)-dPad); 
               
        imMaskCellCrop = imMaskCell(rmin:rmax,cmin:cmax);
        imMinusBGCrop = imMinusBG(rmin:rmax,cmin:cmax);
        
        [ imStackCell imStackSegCell info features(iCell) ] = MorphoPipe_091126_JCS(imMinusBGCrop, imMaskCellCrop, param);
      
        %%% add number of cell
        imMaskCell = zeros(size(im));
        imMaskCell(rmin:rmax,cmin:cmax) = imMaskCellCrop;
        L = bwlabel(imMaskCell);
        s = regionprops(L, 'PixelList');
        xs = s.PixelList(1,2);
        ys = s.PixelList(1,1);
        xe = min( xs+size(imText{1},1)-1 , size(imMaskCell,1) );
        ye = min( ys+size(imText{1},2)-1 , size(imMaskCell,2) );
        
       % if(iCell==1)
       %     % intialise 
       %     imStackDecomp = zeros(sr,sc,size(imStackSegCell,3));
       %     imStackSeg = zeros(sr,sc,size(imStackSegCell,3));
       %     imCellOutlines = zeros(sr,sc,size(imStackSegCell,3));
       % end
        
        imCellBoundary =  imMaskCellCrop - imerode(imMaskCellCrop,strel('disk',1));
        for i=1:size(imStackSegCell,3)
            if(iCell==1)
                % intialise 
                imStack(:,:,i) = zeros(sr,sc); %%imMinusBG(:,:);
                imStackSeg(:,:,i) = zeros(sr,sc);
                imCellOutlines(:,:,i) = zeros(sr,sc);
            end
            imStack(rmin:rmax,cmin:cmax,i) = imStack(rmin:rmax,cmin:cmax,i) + imStackCell(:,:,i).*imMaskCellCrop(:,:);
            imStackSeg(rmin:rmax,cmin:cmax,i) = imStackSeg(rmin:rmax,cmin:cmax,i) + imStackSegCell(:,:,i).*imMaskCellCrop(:,:);
            imCellOutlines(rmin:rmax,cmin:cmax,i) = imCellOutlines(rmin:rmax,cmin:cmax,i) + imCellBoundary(:,:);
            imCellOutlines(xs:xe,ys:ye,i) = imText{iCell}(1:xe-xs+1,1:ye-ys+1);
        end
        
        
    end % iCells
    
    imMaskBoundary = imMaskBG - imerode(imMaskBG,strel('disk',1));
    for i=1:size(imCellOutlines,3)
        imCellOutlines(:,:,i) = imCellOutlines(:,:,i) + imMaskBoundary(:,:);
    end
   
    % only the foreground
    for i=2:2
        meanNumSmall = mean([features(:).(['nSegSmall' info{i}])]);
        meanNumLarge = mean([features(:).(['nSegLarge' info{i}])]);
        info{i} = [info{i} sprintf('--#Small:%.1f--#Large:%.1f', meanNumSmall, meanNumLarge)];
    end    
         
end

