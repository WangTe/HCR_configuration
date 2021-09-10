% De-alias velocity

clear all
close all

addpath(genpath('~/git/HCR_configuration/projDir/qc/dataProcessing/'));

project='spicule'; %socrates, aristo, cset
quality='qc1'; %field, qc1, or qc2
qcVersion='v1.0';
freqData='10hz'; % 10hz, 100hz, 2hz, or combined

figdir=['/scr/sleet2/rsfdata/projects/spicule/hcr/',quality,'/cfradial/',qcVersion,'/deAliasVEL/'];

ylimits=[0 13];

casefile=['~/git/HCR_configuration/projDir/qc/dataProcessing/HCRproducts/caseFiles/velDeAlias_',project,'.txt'];

indir=HCRdir(project,quality,qcVersion,freqData);

% Loop through cases

caseList=readtable(casefile);
caseStart=datetime(caseList.Var1,caseList.Var2,caseList.Var3, ...
    caseList.Var4,caseList.Var5,0);
caseEnd=datetime(caseList.Var6,caseList.Var7,caseList.Var8, ...
    caseList.Var9,caseList.Var10,0);

for aa=1:length(caseStart)
    
    disp(['Case ',num2str(aa),' of ',num2str(length(caseStart))]);
    
    startTime=caseStart(aa);
    endTime=caseEnd(aa);
    
    %% Load data
    
    disp('Loading data ...');
    
    data=[];
    
    % Make list of files within the specified time frame
    fileList=makeFileList(indir,startTime,endTime,'xxxxxx20YYMMDDxhhmmss',1);
    
    if length(fileList)==0
        disp('No data files found.');
        return
    end
    
    % Check if VEL_MASKED is available
    try
        velTest=ncread(fileList{1},'VEL_MASKED');
        data.VEL_MASKED=[];
    catch
        data.VEL_CORR=[];
    end
    
    % Load data
    data=read_HCR(fileList,data,startTime,endTime);
    
    if isfield(data,'VEL_CORR')
        data.VEL_MASKED=data.VEL_CORR;
        data=rmfield(data,'VEL_CORR');
    end
    
    %% Correct velocity folding
    
    %data.VEL_CORR=unfoldVel(data.VEL_CORR,data.FLAG,data.elevation);
    
    
    
    %% Plot
    
    disp('Plotting ...');
    
    close all
    
    f1=figure('DefaultAxesFontSize',12,'Position',[0 300 1000 1200],'visible','on');
    
    s1=subplot(2,1,1);
    surf(data.time,data.asl./1000,data.VEL_MASKED,'edgecolor','none');
    view(2);
    ylim(ylimits);
    xlim([data.time(1),data.time(end)]);
    caxis([-8 8]);
    colormap(s1,jet);
    colorbar;
    ylabel('Altitude (km)');
    title(['HCR radial velocity (m s^{-1})']);
    grid on
    
    %         s3=subplot(4,2,3);
    %         surf(data.time,data.asl./1000,data.VEL_CORR,'edgecolor','none');
    %         view(2);
    %         ylim(ylimits);
    %         xlim([data.time(1),data.time(end)]);
    %         caxis([-5 5]);
    %         colormap(s3,jet);
    %         colorbar;
    %         ylabel('Altitude (km)');
    %         title(['HCR radial velocity (m s^{-1})']);
    %         grid on
    %
    %         s5=subplot(4,2,5);
    %         surf(data.time,data.asl./1000,data.LDR,'edgecolor','none');
    %         view(2);
    %         ylim(ylimits);
    %         xlim([data.time(1),data.time(end)]);
    %         caxis([-30 -5]);
    %         colormap(s5,jet);
    %         colorbar;
    %         ylabel('Altitude (km)');
    %         title(['HCR linear depolarization ratio (dB)']);
    %         grid on
    %
    %         s7=subplot(4,2,7);
    %         surf(data.time,data.asl./1000,data.WIDTH,'edgecolor','none');
    %         view(2);
    %         ylim(ylimits);
    %         xlim([data.time(1),data.time(end)]);
    %         caxis([0 1]);
    %         colormap(s7,jet);
    %         colorbar;
    %         ylabel('Altitude (km)');
    %         title(['HCR spectrum width (m s^{-1})']);
    %         grid on
    %
    %         s2=subplot(4,2,2);
    %         plotMelt=data.MELTING_LAYER;
    %         plotMelt(~isnan(plotMelt) & plotMelt<20)=10;
    %         plotMelt(~isnan(plotMelt) & plotMelt>=20)=20;
    %         surf(data.time,data.asl./1000,plotMelt,'edgecolor','none');
    %         view(2);
    %         ylim(ylimits);
    %         xlim([data.time(1),data.time(end)]);
    %         %caxis([0 2]);
    %         colormap(s2,[1 0 1;1 1 0]);
    %         c=colorbar;
    %         c.Visible='off';
    %         ylabel('Altitude (km)');
    %         title(['Melting Layer']);
    %         grid on
    %
    %         s4=subplot(4,2,4);
    %         jetIn=jet;
    %         jetTemp=cat(1,jetIn(1:size(jetIn,1)/2,:),repmat([0 0 0],3,1),...
    %             jetIn(size(jetIn,1)/2+1:end,:));
    %         surf(data.time,data.asl./1000,data.TEMP,'edgecolor','none');
    %         view(2);
    %         ylim(ylimits);
    %         xlim([data.time(1),data.time(end)]);
    %         caxis([-15 15]);
    %         colormap(s4,jetTemp);
    %         colorbar;
    %         ylabel('Altitude (km)');
    %         title(['Temperature (C)']);
    %         grid on
    %
    %         s5=subplot(4,2,6);
    %         surf(data.time,data.asl./1000,pid_hcr,'edgecolor','none');
    %         view(2);
    %         ylim(ylimits);
    %         xlim([data.time(1),data.time(end)]);
    %         caxis([.5 9.5]);
    %         colormap(s5,cscale_hcr);
    %         cb=colorbar;
    %         cb.Ticks=1:9;
    %         cb.TickLabels=units_str_hcr;
    %         ylabel('Altitude (km)');
    %         title(['HCR particle ID']);
    %
    set(gcf,'PaperPositionMode','auto')
    print(f1,[figdir,project,'_velDeAlias_',...
        datestr(data.time(1),'yyyymmdd_HHMMSS'),'_to_',datestr(data.time(end),'yyyymmdd_HHMMSS')],'-dpng','-r0')
    
    
    
end