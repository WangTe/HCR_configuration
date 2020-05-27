% Ocean scan calibration for HCR data

clear all;
close all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Input variables %%%%%%%%%%%%%%%%%%%%%%%%%%

% If 1, plots for individual calibration events will be made, if 0, only
% total plots will be made

project='cset'; %socrates, aristo, cset, otrec
quality='qc2'; %field, qc1, or qc2
dataFreq='10hz';

b_drizz = 0.52; % Z<-17 dBZ
b_rain = 0.68; % Z>-17 dBZ
%alpha = 0.21;

ylimUpper=15;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath(genpath('~/git/HCR_configuration/projDir/qc/dataProcessing/'));

figdir=['/scr/sci/romatsch/liquidWaterHCR/'];

dataDir=HCRdir(project,quality,dataFreq);

startTime=datetime(2015,8,12,17,42,0);
endTime=datetime(2015,8,12,17,53,0);

%% Get data

fileList=makeFileList(dataDir,startTime,endTime,'xxxxxx20YYMMDDxhhmmss',1);

data=[];

data.DBZ = [];
data.TEMP=[];
data.TOPO=[];
data.FLAG=[];

dataVars=fieldnames(data);

% Load data
data=read_HCR(fileList,data,startTime,endTime);

% Check if all variables were found
for ii=1:length(dataVars)
    if ~isfield(data,dataVars{ii})
        dataVars{ii}=[];
    end
end

dataVars=dataVars(~cellfun('isempty',dataVars));

data.freq=ncread(fileList{1},'frequency');

%% Create ocean surface mask
% 0 extinct or not usable
% 1 cloud
% 2 clear air 

surfMask=nan(size(data.time));

%sort out non nadir pointing
surfMask(data.elevation>-85)=0;

%sort out land
surfMask(data.TOPO>0)=0;

% sort out data from below 2500m altitude
%surfMask(data.altitude<2500)=0;

% Find ocean surface gate
[linInd maxGate rangeToSurf] = hcrSurfInds(data);

% Calculate reflectivity sum inside and outside ocean surface to
% distinguish clear air and cloud
% Also, calculate warm and cold reflectivity
reflTemp=data.DBZ;
reflCW=data.DBZ;
reflCW(data.FLAG>1)=nan;

% Remove bang
reflTemp(data.FLAG==6)=nan;

reflLin=10.^(reflTemp./10);
reflOceanLin=nan(size(data.time));
reflNoOceanLin=nan(size(data.time));

reflCWLin=10.^(reflCW./10);
reflWarmLin=nan(size(data.time));
reflColdLin=nan(size(data.time));

for ii=1:length(data.time)
    if (~(maxGate(ii)<10 | maxGate(ii)>size(reflLin,1)-5)) & ~isnan(maxGate(ii))
        reflRay=reflLin(:,ii);
        reflOceanLin(ii)=sum(reflRay(maxGate(ii)-5:maxGate(ii)+5),'omitnan');
        reflNoOceanLin(ii)=sum(reflRay(1:maxGate(ii)-6),'omitnan');
        
        cwRay=reflCWLin(:,ii);
        tempRay=data.TEMP(:,ii);
        zeroGate=max(find(tempRay<=0))+10;
        reflColdLin(ii)=sum(cwRay(1:zeroGate),'omitnan');
        reflWarmLin(ii)=sum(cwRay(zeroGate+1:end),'omitnan');
    end
end

% Remove data where reflectivity outside of ocean swath is more than
% 0.8
clearAir=find(reflNoOceanLin<=0.8);
surfMask(clearAir)=2;
surfMask(isnan(reflOceanLin))=0;

% Remove data where warm rain is below threshold
warmFrac=reflWarmLin./(reflColdLin+reflWarmLin);
surfMask(warmFrac<0.95)=0;
surfMask(any(data.FLAG==3,1))=0;

% Remve 1 data that is not cloud
dbzMasked=data.DBZ;
dbzMasked(data.FLAG>1)=nan;
    
surfMask(find(any(~isnan(dbzMasked),1) & surfMask~=0 & surfMask~=2))=1;

% Remove noise source cal, ant trans, and missing
surfMask(find(any(data.FLAG>9,1) & surfMask~=0))=0;

if ~max(surfMask)==0
       
    reflSurf=data.DBZ(linInd);
    
    % Remove data with clouds    
    dbzClear=nan(size(data.time));
    dbzCloud=nan(size(data.time));
    
    dbzClear(surfMask==2)=reflSurf(surfMask==2);
    dbzCloud(surfMask==1)=reflSurf(surfMask==1);
    
    % Clear air ocean refl
    clearShort=dbzClear;
    clearShort(isnan(clearShort))=[];
    
    meanClearShort=movmedian(clearShort,100,'omitnan');
    meanClear=nan(size(data.time));
    meanClear(~isnan(dbzClear))=meanClearShort;
    
    meanClear(1)=meanClear(min(find(~isnan(meanClear))));
    
    for jj=2:length(meanClear)
        if isnan(meanClear(jj))
            meanClear(jj)=meanClear(jj-1);
        end
    end
    
    %% Calculate liquid attenuation   
    
    attLiq=nan(size(data.time));        
    specAtt=nan(size(data.DBZ));
    
    C1=4/(20*log10(exp(1)));
    
    b=nan(size(data.DBZ));
    b(dbzMasked<=-17)=b_drizz;
    b(dbzMasked>-17)=b_rain;
    
    meanB=median(b,1,'omitnan');
    
    cloudInds=find(surfMask==1);
    
    for ii=1:length(cloudInds)
        dbzRay=dbzMasked(:,cloudInds(ii));
        cloudIndsRay=find(~isnan(dbzRay));
        
        if length(cloudIndsRay)>2
            
            attDiff=meanClear(cloudInds(ii))-reflSurf(cloudInds(ii));
            if attDiff>=0
                attLiq(cloudInds(ii))=attDiff;
            else
                attLiq(cloudInds(ii))=0;
            end
            
            % Specific attenuation
            % Z phi method
            dbzLinB  = (10.^(0.1.*dbzRay)).^meanB(cloudInds(ii));
            I0 = C1*meanB(cloudInds(ii))*trapz(data.range(cloudIndsRay,cloudInds(ii))./1000,dbzLinB(cloudIndsRay));
            CC = 10.^(0.1*meanB(cloudInds(ii))*attLiq(cloudInds(ii)))-1;
            for mm = 1:length(cloudIndsRay)
                if mm < length(cloudIndsRay)
                    Ir = C1*meanB(cloudInds(ii))*trapz(data.range(cloudIndsRay(mm:end),cloudInds(ii))./1000,dbzLinB(cloudIndsRay(mm:end)));
                else
                    Ir = 0;
                end
                specAtt(cloudIndsRay(mm),cloudInds(ii)) = (dbzLinB(cloudIndsRay(mm))*CC)/(I0+CC*Ir);
            end
        end
    end
    
    alpha=1./(4.792-3.63e-2*data.TEMP-1.897e-4*data.TEMP.^2);
    LWC=specAtt.*alpha;
        
    LWC(data.TEMP<=0)=nan;

    %% Liquid attenuation
    close all
    
    f2 = figure('Position',[200 500 1500 900],'DefaultAxesFontSize',12);
    
    subplot(3,1,1)
    hold on
    l1=plot(data.time,dbzClear,'-b','linewidth',1);
    l2=plot(data.time,dbzCloud,'color',[0.5 0.5 0.5],'linewidth',0.5);
    l3=plot(data.time,meanClear,'-r','linewidth',2);
    l4=plot(data.time,attLiq,'-g','linewidth',1);
    ylabel('Refl. (dBZ), Atten. (dB)');
    ylim([0 50]);
    grid on
    
    xlim([data.time(1),data.time(end)]);
    
    legend([l1 l3 l4],{'Refl. measured','Refl. used','Liquid Attenuation'},'location','east');
    
    title([datestr(data.time(1)),' to ',datestr(data.time(end))])
    cb=colorbar;
    cb.Visible='off';
    
    subplot(3,1,2)
    
    colormap jet
    
    hold on
    surf(data.time,data.asl./1000,dbzMasked,'edgecolor','none');
    view(2);
    ylabel('Altitude (km)');
    caxis([-25 25]);
    ylim([0 ylimUpper]);
    xlim([data.time(1),data.time(end)]);
    colorbar
    grid on
    title('Reflectivity (dBZ)')
    
    subplot(3,1,3)
    
    colormap jet
    
    hold on
    surf(data.time,data.asl./1000,LWC,'edgecolor','none');
    view(2);
    ylabel('Altitude (km)');
    caxis([0 2]);
    ylim([0 5]);
    xlim([data.time(1),data.time(end)]);
    colorbar
    grid on
    title('Liquid water content (g m^{-3})')
    
    set(gcf,'PaperPositionMode','auto')
    print(f2,[figdir,project,'_lwc_',datestr(data.time(1),'yyyymmdd_HHMMSS'),'_to_',datestr(data.time(end),'yyyymmdd_HHMMSS')],'-dpng','-r0')
    
end
