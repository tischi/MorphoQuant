function imout = grayopenbyrecon(im,se)
    
    %imero = grayero(im,se);
    imero = imerode(im,se); % slower implemenation but part of Matlab
    imout = imreconstruct(imero, im);
   
end

