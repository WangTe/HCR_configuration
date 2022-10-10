% Call cloud puzzle script

clear all;
close all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Input variables %%%%%%%%%%%%%%%%%%%%%%%%%%

project={'cset','socrates','otrec','spicule'}; %socrates, aristo, cset, otrec
freqData='10hz';
whichModel='era5';

figdir='/scr/snow2/rsfdata/projects/cset/hcr/qc3/cfradial/v3.0_full/cloudPropsProjects/';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath(genpath('~/git/HCR_configuration/projDir/qc/dataProcessing/'));

for ii=1:length(project)
    if strcmp(project{ii},'spicule')
        qcVersion='v1.1';
        quality='qc1';
    elseif strcmp(project{ii},'cset')
        qcVersion='v3.0';
        quality='qc3';
    else
        qcVersion='v3.1';
        quality='qc3';
    end

    cfDir=HCRdir(project{ii},quality,qcVersion,freqData);

    indir=[cfDir(1:end-5),'cloudProps/'];

    in.(project{ii})=load([indir,project{ii},'_cloudProps.mat']);
end

plotVars=fields(in.cset);

for ii=1:length(plotVars)
    for jj=1:length(project)
        if ~(strcmp(project{jj},'spicule') & strcmp(plotVars{ii},'sstAll'))
            plotV.(plotVars{ii}).(project{jj})=in.(project{jj}).(plotVars{ii});
        end
    end
end

%% Plot

disp('Plotting ...')

classTypes={'CloudLow','CloudMid','CloudHigh',...
        'StratShallow','StratMid','StratDeep',...
        'ConvYoungShallow','ConvYoungMid','ConvYongDeep',...
        'ConvMatureShallow','ConvMatureMid','ConvMatureDeep'};

colmapCC=[204,255,204;
    153,204,0;
    0,128,0;
    0,204,255;
    51,102,255;
    0,0,180;
    255,204,0;
    255,102,0;
    220,0,0;
    255,153,220;
    204,153,255;
    128,0,128];

colmapCC=colmapCC./255;

close all

%% Max refl

close all

edges=-50:2:30;
xlab='Maximum reflectivity (dBZ)';
figname=[figdir,'maxRefl.png'];

plotStatsProjects(plotV.maxReflAll,edges,xlab,figname,classTypes,colmapCC);

%% Mean refl

close all

edges=-50:2:30;
xlab='Mean reflectivity (dBZ)';
figname=[figdir,'meanRefl.png'];

plotStatsProjects(plotV.meanReflAll,edges,xlab,figname,classTypes,colmapCC);

%% Max convectivity

close all

edges=0:0.05:1;
xlab='Max convectivity';
figname=[figdir,'maxConv.png'];

plotStatsProjects(plotV.maxConvAll,edges,xlab,figname,classTypes,colmapCC);

%% Mean convectivity

close all

edges=0:0.05:1;
xlab='Mean convectivity';
figname=[figdir,'meanConv.png'];

plotStatsProjects(plotV.meanConvAll,edges,xlab,figname,classTypes,colmapCC);

%% Cloud depth

close all

edges=0:0.5:15;
xlab='Cloud depth (km)';
figname=[figdir,'cloudDepth.png'];

plotStatsProjects(plotV.cloudDepthAll,edges,xlab,figname,classTypes,colmapCC);

%% Max temperature

close all

edges=-80:5:30;
xlab='Max temperature (C)';
figname=[figdir,'maxTemp.png'];

plotStatsProjects(plotV.maxTempAll,edges,xlab,figname,classTypes,colmapCC);

%% Min temperature

close all

edges=-80:5:30;
xlab='Min temperature (C)';
figname=[figdir,'minTemp.png'];

plotStatsProjects(plotV.minTempAll,edges,xlab,figname,classTypes,colmapCC);

%% Mean temperature

close all

edges=-80:5:30;
xlab='Mean temperature (C)';
figname=[figdir,'meanTemp.png'];

plotStatsProjects(plotV.meanTempAll,edges,xlab,figname,classTypes,colmapCC);

%% Max pressure

close all

edges=100:50:1100;
xlab='Max pressure (hPa)';
figname=[figdir,'maxPress.png'];

plotStatsProjects(plotV.maxPressAll,edges,xlab,figname,classTypes,colmapCC);

%% Min pressure

close all

edges=100:50:1100;
xlab='Min pressure (hPa)';
figname=[figdir,'minPress.png'];

plotStatsProjects(plotV.minPressAll,edges,xlab,figname,classTypes,colmapCC);

%% Mean pressure

close all

edges=100:50:1100;
xlab='Mean pressure (hPa)';
figname=[figdir,'meanPress.png'];

plotStatsProjects(plotV.meanPressAll,edges,xlab,figname,classTypes,colmapCC);

%% Icing level

close all

edges=0:0.2:8;
xlab='Icing level (km)';
figname=[figdir,'iceLev.png'];

plotStatsProjects(plotV.iceLevAll,edges,xlab,figname,classTypes,colmapCC);

%% SST

close all

edges=-35:2:35;
xlab='SST (C)';
figname=[figdir,'sst.png'];

plotStatsProjects(plotV.sstAll,edges,xlab,figname,classTypes,colmapCC);

% %% Longitude
% 
% close all
% 
% if strcmp(project,'cset')
%     edges=-160:0.5:-120;
% elseif strcmp(project,'socrates')
%     edges=130:0.5:180;
% elseif strcmp(project,'otrec')
%     edges=-95:0.5:-65;
% elseif strcmp(project,'spicule')
%     edges=-140:0.5:-60;
% end
% xlab='Longitude (deg)';
% figname=[figdir,project,'_lon.png'];
% 
% plotStats(lonAll,edges,xlab,figname,classTypes,colmapCC);
% 
% %% Latitude
% 
% close all
% 
% if strcmp(project,'cset')
%     edges=15:0.5:50;
% elseif strcmp(project,'socrates')
%     edges=-70:0.5:-30;
% elseif strcmp(project,'otrec')
%     edges=-5:0.5:15;
% elseif strcmp(project,'spicule')
%     edges=20:0.5:55;
% end
% xlab='Latitude (deg)';
% figname=[figdir,project,'_lat.png'];
% 
% plotStats(latAll,edges,xlab,figname,classTypes,colmapCC);

%% Updraft number

close all

edges=1:2:30;
xlab='Number of updrafts';
figname=[figdir,'upNum.png'];

plotStatsProjects(plotV.upNumAll,edges,xlab,figname,classTypes,colmapCC);

%% Updraft fraction

close all

edges=0:0.05:1;
xlab='Updraft fraction';
figname=[figdir,'upFrac.png'];

plotStatsProjects(plotV.upFracAll,edges,xlab,figname,classTypes,colmapCC);

%% Maximum width of updrafts

close all

edges=0:5:100;
xlab='Max width of updrafts (km)';
figname=[figdir,'upMaxWidth.png'];

plotStatsProjects(plotV.upMaxWidthAll,edges,xlab,figname,classTypes,colmapCC);

%% Maximum depth of updrafts

close all

edges=0:0.5:10;
xlab='Max depth of updrafts (km)';
figname=[figdir,'upMaxDepth.png'];

plotStatsProjects(plotV.upMaxDepthAll,edges,xlab,figname,classTypes,colmapCC);

%% Maximum strength of updraft

close all

edges=0:1:20;
xlab='Max up velocity (m s^{-1})';
figname=[figdir,'upMaxStrength.png'];

plotStatsProjects(plotV.upMaxStrengthAll,edges,xlab,figname,classTypes,colmapCC);

%% Maximum strength of downdraft

close all

edges=0:1:20;
xlab='Max down velocity (m s^{-1})';
figname=[figdir,'downMaxStrength.png'];

plotStatsProjects(plotV.downMaxStrengthAll,edges,xlab,figname,classTypes,colmapCC);
