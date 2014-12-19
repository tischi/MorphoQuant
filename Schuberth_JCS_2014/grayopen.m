function out = grayopen(im,se)
    
    %out = graydil(grayero(im,se),se);
    out = imdilate(imerode(im,se),se); %slower

end

