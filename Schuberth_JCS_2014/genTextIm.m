
function [ imText ] = genTextIm( N )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    imText = [];
    for i = 1 : N
        
        close all;
    
        nx=30;ny=30;

        %hf = figure('color','white','units','normalized','position',[.1 .1 .8 .8]);
        figure; imagesc(ones(nx,ny)); 
        set(gca,'units','pixels','position',[1 1 nx ny],'visible','off')
        text(1,15,num2str(i),'fontsize',20);
        colormap('gray');

        % Capture the text image
        % Note that the size will have changed by about 1 pixel
        tim = getframe(gca);
        %close(hf)

        %figure; imagesc(tim.cdata);

        % Extract the cdata
        %tim2 = (255-tim.cdata)/255;

        tim2 = (rgb2ind(tim.cdata,2)==0);
        tim2 = medfilt2(tim2, [2 2], 'symmetric');
        imText{i} = tim2(:,:);
    end

    close all;
   
    
end
