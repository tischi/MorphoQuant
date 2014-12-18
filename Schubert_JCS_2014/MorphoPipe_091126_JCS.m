function [imStack imStackSeg info features] = MorphoPipe_091126_JCS(im, imMask, param)
    
    imZero = zeros(size(im));
  
    strucWidth = param.strucWidthTH.val(1);
    strucTH = param.strucWidthTH.val(2);
    lineLength = param.lineLengthTH.val(1);
    lineTH = param.lineLengthTH.val(2);
    lineAngle = param.lineAngle.val;
    dotWidth = param.dotWidthTH.val(1);
    dotTH = param.dotWidthTH.val(2);
   
    
    %% compute noise BG
    imNoise = abs(im - filter2avg(im, 1));
    imNoiseAvg = filter2avg(imNoise, round(strucWidth/2));
  
    %% select normalisation image
    imNorm = imNoiseAvg;
      
    %% decompose BG and FG
    [ imFG imBG ] = DecompSmallAndBig( im, round(strucWidth/2) );    
    imFGnorm = imFG ./ imNorm;
  
    %% segmentation foreground
    imFGseg = (imFGnorm>strucTH);
 
    %% enhance small spots in FG image using Laplacian of Gaussian Filter
    if(prod(param.dotWidthTH.val))
        fsize = ceil(dotWidth/2 * 3) * 2 + 1;  % choose an odd fsize >
        kernel = - fspecial('log',fsize,dotWidth/2); 
        kernel = kernel - sum(kernel(:))/prod(size(kernel));
        imFGLoG = imfilter(imFG,kernel,'replicate');
        imFGLoGnorm = imFGLoG ./ imNorm;    
    end
    
    %% enhance lines in image im
    if(prod(param.lineLengthTH.val))
        [ imTemp, imLines ] = DecompSpotsAndLines( im, lineLength, lineAngle);
        imLinesNorm = imLines ./ imNorm;
    end
   
    
    %% segment spots, rejecting lines
    if(prod(param.dotWidthTH.val))
        if(prod(param.lineLengthTH.val))
            imSpotSeg = (imFGLoGnorm>dotTH) & (imLinesNorm<lineTH);
        else
            imSpotSeg = (imFGLoGnorm>dotTH);
        end
    else
        imSpotSeg = imZero;
    end
    
    %% combine the segmentations
    imSeg = (imFGseg | imSpotSeg) & imMask;
     
    %% quantification & output
    idsCell = imMask>0;
    
    %% output
    features.areaCell = sum(idsCell(:));
    features.intensTotCell = sum(im(idsCell));
    
    
    i=0;
    %% orig ***************************
    i=i+1; info{i} = 'Original';
    imStack(:,:,i) = im; 
    imStackSeg(:,:,i) = imZero;
    imTemp(:,:) = imStack(:,:,i);
    
    %% clean up segmentation and divide in large and small objects
    %param.areaSmall.val = ceil((2.5*dotWidth)^2*pi/4);
    [ imSeg op ] = segQuant_091126( im, imSeg, param );
    
    %% foreground **********************
    i=i+1; info{i} = 'Foreground';
    imStack(:,:,i) = imFG; 
    imTemp(:,:) = imStack(:,:,i);   % added the imTemp line, 5.March.2013
    
    % quantify the segmented objects in the foreground(!) image
    % split up in small and large
    if(length(op))
       
        idsSmall = [op.area]<=param.areaSmallTH.val;
        idsLarge = [op.area]>param.areaSmallTH.val;
        features.(['nSegSmall' info{i}]) = sum(idsSmall);
        features.(['areaFracSmall' info{i}]) = sum([op(idsSmall).area])/features.areaCell;
        features.(['intensFracSmall' info{i}]) = sum(imTemp(imSeg==2))/features.intensTotCell; % changed from im to imTemp, 5.March.2013
        
        features.(['nSegLarge' info{i}]) = sum(idsLarge);
        features.(['areaFracLarge' info{i}]) = sum([op(idsLarge).area])/features.areaCell;
        features.(['intensFracLarge' info{i}]) = sum(imTemp(imSeg==1))/features.intensTotCell;  % changed from im to imTemp, 5.March.2013 
        
        features.(['areaMaxFrac' info{i}]) = max([op.area])/features.areaCell;
        
        [v, iMaxArea] = max([op.area]);
        features.(['maxIntensOfLargestObject' info{i}]) = max(imTemp(op(iMaxArea).ids));
            
    else
        
        features.(['nSegSmall' info{i}]) = 0;
        features.(['areaFracSmall' info{i}]) = 0;
        features.(['intensFracSmall' info{i}]) = 0;

        features.(['nSegLarge' info{i}]) = 0;
        features.(['areaFracLarge' info{i}]) = 0;
        features.(['intensFracLarge' info{i}]) = 0;
    
        features.(['areaMaxFrac' info{i}]) = 0;
        features.(['maxIntensOfLargestObject' info{i}]) = 0;
        
    end
        
    imStackSeg(:,:,i) = imSeg;
    
    
    %% background ********************
    i=i+1; info{i} = 'Background';
    imStack(:,:,i) = imBG; 
    imStackSeg(:,:,i) = imZero;
   
    imTemp(:,:) = imStack(:,:,i);
    features.(['intensFrac' info{i}]) = sum(imTemp(idsCell)) / features.intensTotCell;
    
 
end

