function [ imComp r c ] = mymontage( imStack )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    sr = size(imStack,1);
    sc = size(imStack,2);
    
    nim = size(imStack,3);
    if( nim < 4)
        imComp = zeros(sr,nim*sc);
    else
        imComp = zeros(2*sr,3*sc);
    end  
        
    rcim{1} = [0,0]; 
    rcim{2} = [0,1]; 
    rcim{3} = [0,2]; 
    rcim{4} = [1,0]; 
    rcim{5} = [1,1]; 
    rcim{6} = [1,2]; 
    
    
    for i = 1 : size(imStack,3)
        imComp(sr*rcim{i}(1)+1:sr*(rcim{i}(1)+1),sc*rcim{i}(2)+1:sc*(rcim{i}(2)+1)) = imStack(:,:,i);
        r(i) = sr*(rcim{i}(1)+1);
        c(i) = sc*rcim{i}(2)+0.5*sc;
    end                 

end

