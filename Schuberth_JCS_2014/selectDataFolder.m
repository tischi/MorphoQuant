function  [param sExpMaskStack sData nExp] = selectDataFolder(param)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    

    while(1) 

        string = sprintf('\nPlease select the folder containing your images and masks');
        param.sPath.val = uigetdir(param.sPath.val,string);
        if(param.sPath.val == 0); sExpMaskStack = []; sData = []; nExp=0; return; end %% user pressed cancel
        param.sPath.val  = [param.sPath.val  '\'];
        sPathTemp =  param.sPath.val ;

        disp(['data folder: ' param.sPath.val ]);
        %% replace by settings in data folder, if those exist
        try 
            settings = load([param.sPath.val  'parameters.mat']);
            param = settings.param;
            param.sPath.val  = sPathTemp; %% but set back the path 
            disp('-- loaded parameter settings from data folder.')
        catch
        end


        %sTemp = dir(fullfile(param.sPath,'*.tif'));
        sTemp = dir(fullfile(param.sPath.val ,'*-mask-bg.tif'));

        if(length(sTemp)>0)
            break;
        else
            h = msgbox('sorry,  this folder contains no valid data.','','warn');
            uiwait(h);     
        end
        
    end


    
    iDat = 0;
    for iFile = 1:length(sTemp)
        %if( ~length(strfind(sTemp(iFile).name,'mask')) && ~length(strfind(sTemp(iFile).name,'MQ')) )
        %    iDat = iDat +1 ; sFiles{iDat} = sTemp(iFile).name;
        %end
        iDat = iDat +1 ; sFiles{iDat} = sTemp(iFile).name(1:end-12);
    end
    
    nExp = length(sFiles);
      
    
    sExpMaskStack = cell(1,4);
    
    for iExp = 1 : nExp

        sExpMaskStack{iExp,1} = sFiles{iExp};  % sExp
        sExpMaskStack{iExp,2} = [sFiles{iExp} '-mask.tif']; % mask
        sExpMaskStack{iExp,3} = [sFiles{iExp} '.tif']; % Stack
        sExpMaskStack{iExp,4} = [sFiles{iExp} '-mask-bg.tif']; % bg-mask
        
        try
            info = imfinfo([param.sPath.val  sExpMaskStack{iExp,2}]);
        catch
            h = msgbox(['sorry, ' sExpMaskStack{iExp,2} ' could not be found.'],'','warn');
            uiwait(h);
            return;
        end
        
        
        try
            info = imfinfo([param.sPath.val  sExpMaskStack{iExp,3}]);
        catch
            h = msgbox(['sorry, ' sExpMaskStack{iExp,3} ' could not be found.'],'','warn');
            uiwait(h);
            return;
        end
        
        
        nImages = length(info); info = [];
        sExpMaskStack{iExp,5} = nImages; % 
        stringData{iExp} = sprintf('%.0f: %s (%.0f images)', iExp, sExpMaskStack{iExp,1}, nImages);
    
    end
    
    lastDataFolder = param.sPath.val ;
    param.prgPath.val
    save([param.prgPath.val  'lastFolder.mat'],'lastDataFolder');
    
    sData = stringData;
     

end

