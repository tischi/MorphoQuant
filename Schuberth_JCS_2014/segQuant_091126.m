function [ imSeg op ] = segQuant091126( im, imSeg, param )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
       
     
    [imL, nObjects] = bwlabel(imSeg); 
    s = regionprops(imL,'PixelIdxList');
    for iObject =  1 : nObjects
        op(iObject).ids = s(iObject).PixelIdxList;
        op(iObject).area = length(op(iObject).ids);
    end
    
    imObjects = zeros(size(im));
     
    if(exist('op'))
        iObject = 1;
        while (iObject<=length(op)) % for loop does not reevaluate length(op)
            ids = op(iObject).ids;
            area = op(iObject).area;
            if( (area<param.objectSizeMinMax.val(1)) || (area>param.objectSizeMinMax.val(2)))
                op(iObject) = []; % delete too small or too big objects            
            else
                if( area < param.areaSmallTH.val )
                    imObjects(ids) = imObjects(ids) + 2;  %% give different label to small objects
                else
                    imObjects(ids) = imObjects(ids) + 1;
                end
                iObject = iObject + 1;    
            end
        end    
     else
         op = [];
     end
   
     %% output
     imSeg = imObjects;
     op;
     
     
end

