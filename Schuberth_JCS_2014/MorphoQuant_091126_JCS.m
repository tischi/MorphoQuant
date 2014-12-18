% 
% Author: Christian Tischer; tischitischer@gmail.com
%
    
function MorphoQuant_091126_JCS()

    set(0,'DefaultTextInterpreter','none');
    
    ip=0;
    ip=ip+1;param.strucWidthTH.val = [20 20]; param.strucWidthTH.txt = 'Find structures: Width TH';
    ip=ip+1;param.dotWidthTH.val = [1.5 3]; param.dotWidthTH.txt = 'Find dots: Width TH';
    ip=ip+1;param.lineLengthTH.val = [20 5]; param.lineLengthTH.txt = 'Line suppression: Length TH';
    ip=ip+1;param.areaSmallTH.val = ceil((2.5*param.dotWidthTH.val(1))^2*pi/4); param.areaSmallTH.txt = 'Distinguish small and large: maxAreaSmall';
    ip=ip+1;param.objectSizeMinMax.val = [5 1000000]; param.objectSizeMinMax.txt = 'Reject: MinArea MaxArea';
    ip=ip+1;param.scale.val = 1; param.scale.txt = 'Rescale the image by factor (e.g. 0.5): ';
    ip=ip+1;param.numImage.val = 1; param.numImage.txt = 'Select image for testing:';
    np=ip;
    ip=ip+1;param.numFile.val = 1; param.numFile.txt = 'TestFile';
        
    param.prgPath.val = [pwd '\'];
    
    ['programme folder: '  param.prgPath.val] 
    disp(['programme folder: '  param.prgPath.val]);
    try
       temp = load([param.prgPath.val 'imText.mat']); 
       imText = temp.imText;
    catch
       [ imText ] = genTextIm( 30 );
       save([param.prgPath.val 'imText.mat'], 'imText');
    end
    
    try
        temp = load([param.prgPath.val 'lastFolder.mat']);
        param.sPath.val = temp.lastDataFolder;
    catch
        param.sPath.val = '';
    end
    
    param.lineAngle.val = 15;
    
    while(1)
        %%
        [param sExpMaskStack sData nExp] = selectDataFolder(param);
        if(length(sExpMaskStack)==0) %% user pressed cancel
            return;
        end
        %%


        vButton = 'Try';
        while(strcmp(vButton,'Try') || strcmp(vButton,'ChDir'))

            [param vButton] = inputdlgMQ(param,np,'MorphoQuant091126 ALMF@EMBL.DE',1,sData);
   
            switch vButton
                case 'Cancel'
                    close all;return;
                case 'Run'
                    continue;
                case 'ChDir'
                    [param sExpMaskStack sData nExp] = selectDataFolder(param);   
                    if(length(sExpMaskStack)==0) %% user pressed cancel
                        close all; return;
                    end
                    param.numFile.val=1;
                    param.numImage.val=1;
                    
                case 'Try'

                     if( param.numImage.val>sExpMaskStack{param.numFile.val,5} )
                         h = msgbox('sorry, the selected image does not exist','','warn');
                         uiwait(h);
                         continue;
                     else
                          %% - compute segmentation and analyse the image
                         [imStackOutlines imStack imStackSeg info.text features] = AnalyseImage_091117_JCS(sExpMaskStack,param,imText);

                         %% DISPLAY
                         [ imMont info.r info.c ] = mymontage( imStack );
                         [ imMontSeg info.r info.c ] = mymontage( imStackSeg );
                         [ imMontOutlines info.r info.c ] = mymontage( imStackOutlines );
                         h = myShowImOverlayText(imMontOutlines, imMont, imMontSeg, info, 'on');

                         uiwait(h);
                         close all;
                     end


                otherwise
                     
                   close all; return;

            end



        end

        %% store paramater settings
        save([param.sPath.val 'parameters.mat'],'param');
        fid = fopen([param.sPath.val 'parameters.txt'], 'wt');
        fn = fieldnames(param);
        for i = 1 : length(fn)
            if(~isfield(param.(fn{i}),'txt'))
                param.(fn{i}).txt='';
            end
            fprintf(fid, '%s:\t%s\t%s\n', fn{i}, param.(fn{i}).txt,num2str(param.(fn{i}).val) );
        end
        fclose(fid);



        close all; 
        
        flagCancel = false;
        idsExps = 1 : nExp;
        for iExpMeta = 1 : length(idsExps)

            iExp = idsExps(iExpMeta);
            sExp = sExpMaskStack{iExp,1};  
            iImageStart = 1;
            iImageEnd = sExpMaskStack{iExp,5};

            hWaitbar = waitbar(0, [num2str(iExp) '/' num2str(nExp) ':' sExp],...
                'Name','MorphoQuant running...','CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
            setappdata(hWaitbar,'canceling',0)

            clear features;
            
            
            for iImage = iImageStart : iImageEnd

                 waitbar(iImage/iImageEnd);

                 if (getappdata(hWaitbar,'canceling'))
                    flagCancel = true;
                    break
                 end

                %% analyse image
                param.numFile.val = iExp;
                param.numImage.val = iImage;
                [imStackOutlines imStack imStackSeg info.text features{iImage}] = AnalyseImage_091117_JCS(sExpMaskStack,param,imText);

                % save results image
                if(iImage==1)
                    wr_mode = 'overwrite';
                else
                    wr_mode = 'append';
                end
                imOut = []; imOut(:,:) = 100*imStackSeg(:,:,2) + 50*imStackOutlines(:,:,2);
                imwrite(uint8(imOut), [param.sPath.val sExp '--MQ-seg.tif'], 'tif', 'Compression', 'none', 'WriteMode', wr_mode);
                
            end % for images

            delete(hWaitbar) 

            if(flagCancel)
                break;
            end
            
            %%%%%%%%%%%%%%%%%
            %% SAVE RESULTS
            %%%%%%%%%%%%%%%%%

            disp('saving results...');
            filename = [param.sPath.val sExp '--MQ-results.txt'];
            fid = fopen(filename, 'wt');

            % header
            string = sprintf('iImage\tiCell\t');
            sfeatures = fieldnames(features{1}(1));
            for iF = 1 : length(sfeatures)
               string = [string sprintf('%s\t', sfeatures{iF})];
            end
            disp(string);
            fprintf(fid, '%s\n', string );

            %% feature values
            for iImage = 1 : length(features)
       
                for iCell = 1 : length(features{1})
                    
                    string = sprintf('%.0f\t%.0f\t',iImage,iCell);
             
                    for iF = 1 : length(sfeatures)
                        string = [string sprintf('%.8f\t', features{iImage}(iCell).(sfeatures{iF}))];
                    end
                    
                    disp(string);
                    fprintf(fid, '%s\n', string );

                end
                
                % mean
                string = sprintf('%.0f\tmean\t',iImage);
                for iF = 1 : length(sfeatures)
                    string = [string sprintf('%.8f\t', nanmean([features{iImage}(:).(sfeatures{iF})]))];
                end
                disp(string); fprintf(fid, '%s\n', string );

                % median
                string = sprintf('%.0f\tmedian\t',iImage);
                for iF = 1 : length(sfeatures)
                    string = [string sprintf('%.8f\t', nanmedian([features{iImage}(:).(sfeatures{iF})]))];
                end
                disp(string); fprintf(fid, '%s\n', string );
                
                % std
                string = sprintf('%.0f\tstd\t',iImage);
                for iF = 1 : length(sfeatures)
                    string = [string sprintf('%.8f\t', nanstd([features{iImage}(:).(sfeatures{iF})]))];
                end
                disp(string); fprintf(fid, '%s\n', string );
               
              
            end

            fclose(fid);


        end  %% iExp
        
        if(~flagCancel)
            h = msgbox('Done! Output files are written into folder with input images.');
            uiwait(h);
        end

    end %% while(1) %% till user presses cancel at some point
    
end



