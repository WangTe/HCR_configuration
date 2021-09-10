% Analyze HCR clouds

clear all;
close all;

project='spicule'; %socrates, otrec, cset
quality='qc1'; %field, qc1, or qc2
qcVersion='v1.0';
freqData='10hz'; % 10hz, 100hz
whichModel='era5';

addpath(genpath('~/git/HCR_configuration/projDir/qc/dataProcessing/'));

figdir=['/scr/sleet2/rsfdata/projects/spicule/hcr/',quality,'/cfradial/',qcVersion,'/meltLayerPlots/process/'];
%figdir=['/home/romatsch/plots/HCR/meltingLayer/flights/',project,'/10hz/'];

saveTime=0;
saveOffset=0;

offsetIn=-300;
% If no data is found within one flight, take mean of previous flight (0)
% or mean over all flights (1) which is given as offsetIn above.
prevOrTotOffset=0;
adjustOffset=0; % Set to zero if constant offset should be used (e.g. when running flight by flight)

% Adjust thresholds
thresholds.LDRlimits=[-16,-7]; % SOCRATES, OTREC, CSET default: [-16,-7]
thresholds.LDRspeclePix=50; % SOCRATES, OTREC, CSET default: [] (not used)
thresholds.LDRsolidity=0.5; % SOCRATES, OTREC, CSET default: [] (not used)
thresholds.LDRsearchPix=25; % SOCRATES, OTREC, CSET default: 18
thresholds.LDRstd=150; % SOCRATES, OTREC, CSET default: 100
thresholds.LDRaltDiff=100; % SOCRATES, OTREC, CSET default: 50

thresholds.VELsearchPix=80; % SOCRATES, OTREC, CSET default: 50
thresholds.VELstd=70; % SOCRATES, OTREC, CSET default: 35
thresholds.VELaltDiff=100; % SOCRATES, OTREC, CSET default: 100
thresholds.VELudDiff=-0.7; % SOCRATES, OTREC, CSET default: -0.7
thresholds.VEL_LDRdiff=600; % SOCRATES, OTREC, CSET default: 200

thresholds.outlier=350; % SOCRATES, OTREC, CSET default: 50
thresholds.length=10; % SOCRATES, OTREC, CSET default: 20

if ~exist(figdir, 'dir')
    mkdir(figdir)
end

ylimits=[-0.2 13];

indir=HCRdir(project,quality,qcVersion,freqData);
%indir=HCRdirWFH(project,quality,freqData);

[~,directories.modeldir]=modelDir(project,whichModel,freqData);
outdir=directories.modeldir;
%outdir=['/run/media/romatsch/RSF0006/rsf/meltingLayer/',project,'Mat/'];

infile=['~/git/HCR_configuration/projDir/qc/dataProcessing/scriptsFiles/flights_',project,'_data.txt'];

caseList = table2array(readtable(infile));

zeroAdjust=offsetIn;

for aa=10:size(caseList,1)
    disp(['Flight ',num2str(aa)]);
    disp('Loading HCR data.')
    disp(['Starting at ',datestr(datetime('now'),'yyyy-mm-dd HH:MM')]);
    
    clearvars -except project quality freqData whichModel figdir ...
        ylimits indir outdir caseList zeroAdjust zeroAdjustIn aa ...
        saveOffset prevOrTotOffset saveTime adjustOffset thresholds
    
    if adjustOffset
        if aa==1
            OffsetM=nan(size(caseList,1),1);
            FlightNames=table('Size',[size(caseList,1) 1],'VariableTypes',"string");
            for ii=1:size(caseList,1)
                FlightNames.Var1(ii)=['Flight ',num2str(ii)];
            end
            offsetIn=array2table(OffsetM);
            offset=cat(2,FlightNames,offsetIn);
            offset.Properties.VariableNames{'Var1'}='Flight';
        else
            offset=readtable([outdir,whichModel,'.offset.',project,'.txt']);
            if ~isnan(offset.OffsetM(aa-1)) & prevOrTotOffset==0
                zeroAdjust=offset.OffsetM(aa-1);
            end
        end
    end
    
    startTime=datetime(caseList(aa,1:6));
    endTime=datetime(caseList(aa,7:12));
    
    fileList=makeFileList(indir,startTime,endTime,'xxxxxx20YYMMDDxhhmmss',1);
    
    disp([datestr(startTime,'yyyy-mm-dd HH:MM'),' to ',datestr(endTime,'yyyy-mm-dd HH:MM')]);
    
    %% Load data
        
    data.DBZ=[];
    data.TEMP=[];
    data.WIDTH=[];
    data.FLAG=[];
    data.TOPO=[];
    
    dataVars=fieldnames(data);
    
    % Make list of files within the specified time frame
    fileList=makeFileList(indir,startTime,endTime,'xxxxxx20YYMMDDxhhmmss',1);
    
    % Check if VEL_MASKED is available
    try
        velTest=ncread(fileList{1},'VEL_MASKED');
        data.VEL_MASKED=[];
    catch
        data.VEL_CORR=[];
    end
    
    % Check if LDR_MASKED is available
    try
        velTest=ncread(fileList{1},'LDR_MASKED');
        data.LDR_MASKED=[];
    catch
        data.LDR=[];
    end
    
    if length(fileList)==0
        disp('No data files found.');
        continue
    end
    
    % Load data
    data=read_HCR(fileList,data,startTime,endTime);
    
    % Check if all variables were found and convert to single
    for ii=1:length(dataVars)
        if ~isfield(data,dataVars{ii})
            dataVars{ii}=[];
        end
    end
    
    dataVars=dataVars(~cellfun('isempty',dataVars));
    
    if isempty(data.DBZ)
        continue
    end
    
    if isfield(data,'VEL_MASKED')
        data.VEL_CORR=data.VEL_MASKED;
        data=rmfield(data,'VEL_MASKED');
    end
    
    if isfield(data,'LDR_MASKED')
        data.LDR=data.LDR_MASKED;
        data=rmfield(data,'LDR_MASKED');
    end
    
    %% Find melting layer
    
    [meltLayer iceLayer offset.OffsetM(aa)]=f_meltLayer(data,zeroAdjust,thresholds);
    
    if ~isnan(offset.OffsetM(aa)) & prevOrTotOffset==0 & adjustOffset==1
        zeroAdjust=offset.OffsetM(aa);
    end        
    
    elevenInds=find(meltLayer==11);
    twelveInds=find(meltLayer==12);
    thirteenInds=find(meltLayer==13);
    fourteenInds=find(meltLayer==14);
    
    twentyoneInds=find(meltLayer==21);
    twentytwoInds=find(meltLayer==22);
    twentythreeInds=find(meltLayer==23);
    twentyfourInds=find(meltLayer==24);
    
    %% Plot
    
    timeMat=repmat(data.time,size(data.TEMP,1),1);
    ldrMasked=data.LDR;
    ldrMasked(data.FLAG>1)=nan;
    velMasked=data.VEL_CORR;
    velMasked(data.FLAG>1)=nan;
    
    close all
    
    if etime(datevec(endTime),datevec(startTime))<=900
        newInds=1:1:length(data.time);
    elseif etime(datevec(endTime),datevec(startTime))<=3600
        newInds=1:10:length(data.time);
    else
        newInds=1:100:length(data.time);
    end
    
    % Resample for plotting
    newDBZ=data.DBZ(:,newInds);
    newLDR=data.LDR(:,newInds);
    newVEL=data.VEL_CORR(:,newInds);
    newASL=data.asl(:,newInds);
    newTEMP=data.TEMP(:,newInds);
    newFindMelt=meltLayer(:,newInds);
    newTime=data.time(newInds);
    
    fig1=figure('DefaultAxesFontSize',11,'position',[100,1300,1200,920]);
    
    ax1=subplot(4,1,1);
    hold on;
    sub1=surf(newTime,newASL./1000,newDBZ,'edgecolor','none');
    view(2);
    sub1=colMapDBZ(sub1);
    scatter(timeMat(twentyoneInds),data.asl(twentyoneInds)./1000,10,...
        'MarkerEdgeColor',[0.7 0.7 0.7],'MarkerFaceColor',[0.7 0.7 0.7]);    
    scatter(timeMat(elevenInds),data.asl(elevenInds)./1000,10,'k','filled');
           
    scatter(timeMat(twentyfourInds),data.asl(twentyfourInds)./1000,10,...
        'MarkerEdgeColor',[0.45 0.76 0.42],'MarkerFaceColor',[0.45 0.76 0.42]);
    scatter(timeMat(twentythreeInds),data.asl(twentythreeInds)./1000,10,...
        'MarkerEdgeColor',[0.7 0.8 0.87],'MarkerFaceColor',[0.7 0.8 0.87]);
    scatter(timeMat(twentytwoInds),data.asl(twentytwoInds)./1000,10,...
        'MarkerEdgeColor',[0.17 0.45 0.7],'MarkerFaceColor',[0.17 0.45 0.7]);
        
    scatter(timeMat(fourteenInds),data.asl(fourteenInds)./1000,10,'g','filled');
    scatter(timeMat(thirteenInds),data.asl(thirteenInds)./1000,10,'c','filled');
    scatter(timeMat(twelveInds),data.asl(twelveInds)./1000,10,'b','filled');
    
    ax = gca;
    ax.SortMethod = 'childorder';
    ylim(ylimits);
    ylabel('Altitude (km)');
    xlim([data.time(1),data.time(end)]);
    title(['Flight ',num2str(aa),': Reflectivity and melting layer'])
    grid on
    set(gca,'xticklabel',[])
    ax1.Position=[0.06 0.765 0.87 0.21];
    
    ax2=subplot(4,1,2);
    hold on;
    sub1=surf(newTime,newASL./1000,newFindMelt,'edgecolor','none');
    ax2.Colormap=([1 0 1;1 1 0]);
    view(2);
    scatter(timeMat(twentyoneInds),data.asl(twentyoneInds)./1000,10,...
        'MarkerEdgeColor',[0.7 0.7 0.7],'MarkerFaceColor',[0.7 0.7 0.7]);    
    scatter(timeMat(elevenInds),data.asl(elevenInds)./1000,10,'k','filled');
           
    scatter(timeMat(twentyfourInds),data.asl(twentyfourInds)./1000,10,...
        'MarkerEdgeColor',[0.45 0.76 0.42],'MarkerFaceColor',[0.45 0.76 0.42]);
    scatter(timeMat(twentythreeInds),data.asl(twentythreeInds)./1000,10,...
        'MarkerEdgeColor',[0.7 0.8 0.87],'MarkerFaceColor',[0.7 0.8 0.87]);
    scatter(timeMat(twentytwoInds),data.asl(twentytwoInds)./1000,10,...
        'MarkerEdgeColor',[0.17 0.45 0.7],'MarkerFaceColor',[0.17 0.45 0.7]);
        
    scatter(timeMat(fourteenInds),data.asl(fourteenInds)./1000,10,'g','filled');
    scatter(timeMat(thirteenInds),data.asl(thirteenInds)./1000,10,'c','filled');
    scatter(timeMat(twelveInds),data.asl(twelveInds)./1000,10,'b','filled');
    
    plot(data.time,iceLayer./1000,'linewidth',1,'color',[0.6 0.6 0.6]);
    ax = gca;
    ax.SortMethod = 'childorder';
    ylim(ylimits);
    ylabel('Altitude (km)');
    xlim([data.time(1),data.time(end)]);
    title('Reflectivity and melting layer')
    grid on
    set(gca,'xticklabel',[])
    ax2.Position=[0.06 0.525 0.87 0.21];
    
    %%%%%%%%%%%%%%%%%%%%%%%% LDR%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ax3=subplot(4,1,3);
    hold on;
    sub3=surf(newTime,newASL./1000,newLDR,'edgecolor','none');
    view(2);
    caxis([-25 5]);
    colorbar
    ylim(ylimits);
    ylabel('Altitude (km)');
    xlim([data.time(1),data.time(end)]);
    title('LDR')
    grid on
    set(gca,'xticklabel',[])
    ax3.Position=[0.06 0.287 0.87 0.21];
    
    ax4=subplot(4,1,4);
    ax4.Colormap=jet;
    hold on;
    sub3=surf(newTime,newASL./1000,newVEL,'edgecolor','none');
    view(2);
    caxis([-5 5]);
    colorbar
    ylim(ylimits);
    ylabel('Altitude (km)');
    xlim([data.time(1),data.time(end)]);
    title('VEL')
    grid on
    ax4.Position=[0.06 0.05 0.87 0.21];
    
    linkaxes([ax1 ax2 ax3 ax4],'xy');
    
    set(gcf,'PaperPositionMode','auto')
    print([figdir,'meltRefl_Flight',num2str(aa)],'-dpng','-r0');
    
    disp(['Melting layer is on average ',num2str(offset.OffsetM(aa)),' m from the zero degree isotherm.'])
    
    %% Save
    disp('Saving meltLayer field ...')
    
    save([outdir,whichModel,'.meltLayer.',datestr(data.time(1),'YYYYmmDD_HHMMSS'),'_to_',...
        datestr(data.time(end),'YYYYmmDD_HHMMSS'),'.Flight',num2str(aa),'.mat'],'meltLayer');
    
    if saveTime
        timeHCR=data.time;
        save([outdir,whichModel,'.time.',datestr(data.time(1),'YYYYmmDD_HHMMSS'),'_to_',...
            datestr(data.time(end),'YYYYmmDD_HHMMSS'),'.Flight',num2str(aa),'.mat'],'timeHCR');
    end
    
    save([outdir,whichModel,'.iceLevel.',datestr(data.time(1),'YYYYmmDD_HHMMSS'),'_to_',...
        datestr(data.time(end),'YYYYmmDD_HHMMSS'),'.Flight',num2str(aa),'.mat'],'iceLayer');
    
    if saveOffset
        writetable(offset,[outdir,whichModel,'.offset.',project,'.txt'],'delimiter',' ');
    end
end

%% Calculate and save mean offset

meanOffset=mean(offset.OffsetM,'omitnan');
stdOffset=std(offset.OffsetM,'omitnan');
disp(['Offset over all flights: ',num2str(meanOffset),' +/- ',num2str(stdOffset),' m']);

offset=cat(1,offset,offset(1,:));
offset(end,1)={'Mean'};
offset.OffsetM(end)=meanOffset;

offset=cat(1,offset,offset(1,:));
offset(end,1)={'StDev'};
offset.OffsetM(end)=stdOffset;

if saveOffset
    writetable(offset,[outdir,whichModel,'.offset.',project,'.txt'],'delimiter',' ');
end