% Plot socrates locations

clear all;
close all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Input variables %%%%%%%%%%%%%%%%%%%%%%%%%%

project={'socrates'}; %socrates, aristo, cset, otrec
freqData='10hz';
whichModel='era5';

figdir='/scr/snow2/rsfdata/projects/cset/hcr/qc3/cfradial/v3.0_full/cloudPropsProjects/paperFigs/';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath(genpath('~/git/HCR_configuration/projDir/qc/dataProcessing/'));


qcVersion='v3.1';
quality='qc3';
ii=1;

cfDir=HCRdir(project{ii},quality,qcVersion,freqData);

indir=[cfDir(1:end-5),'cloudProps/'];

in.(project{ii})=load([indir,project{ii},'_cloudProps.mat']);

plotVars=fields(in.socrates);

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
    'ConvYoungShallow','ConvYoungMid','ConvYoungDeep',...
    'ConvMatureShallow','ConvMatureMid','ConvMatureDeep'};

classTypeNames={'(a) CloudLow','(b) CloudMid','(f) CloudHigh',...
    '(g) StratShallow','(h) StratMid','(l) StratDeep',...
    '(c) ConvShallow','(d) ConvMid','(f) ConvDeep',...
    '(e) ConvStratShallow','(h) ConvStratMid','(i) ConvStratDeep'};

close all

%% Plot locations

close all

lonLims=[-160,-120;
    130,165;
    -95,-75];

latLims=[15,45;
    -65,-40
    -0,15];


lons=plotV.lonAll;
lats=plotV.latAll;

load coastlines

%% Per flight hour
load('/scr/snow2/rsfdata/projects/cset/hcr/qc3/cfradial/v3.0_full/cloudPropsProjects/flightHourGrids.mat');

fig=figure('DefaultAxesFontSize',11,'position',[100,100,1200,1100],'renderer','painters','visible','on');
colmap=turbo(21);
colormap(colmap(3:end-1,:));

% Loop through projects
projects=fields(lons);
gridStep=1;

bb=2;

lonLength=(lonLims(bb,2)-lonLims(bb,1))/gridStep;
latLength=(latLims(bb,2)-latLims(bb,1))/gridStep;

lonSteps=lonLims(bb,1):gridStep:lonLims(bb,2);
latSteps=latLims(bb,1):gridStep:latLims(bb,2);

plotNum=num2str(1:12);

nums=[1,2,7,8,10,3,4,5];

for aa=1:length(nums)
    hourGrid=zeros(latLength,lonLength);
    s.plotNum{aa}=subplot(4,2,aa);

    hold on

    thisLons=lons.socrates.(classTypes{nums(aa)});
    thisLats=lats.socrates.(classTypes{nums(aa)});

    % Loop through output grid
    for ii=1:size(hourGrid,1)
        for jj=1:size(hourGrid,2)
            pixInds=find(thisLats>latSteps(ii) & thisLats<=latSteps(ii+1) & ...
                thisLons>lonSteps(jj) & thisLons<=lonSteps(jj+1));
            hzPix=length(pixInds);
            hourGrid(ii,jj)=hourGrid(ii,jj)+hzPix;
        end
    end

    perHour=hourGrid./flightHourGrids.socrates;
    perHour(perHour==0)=nan;
    perHour(flightHourGrids.socrates<0.167)=nan;

    h=imagesc(lonSteps(1:end-1)+gridStep/2,latSteps(1:end-1)+gridStep/2,perHour);
    set(h,'AlphaData',~isnan(perHour));

    caxis([0,18]);
    if aa==8
        cb=colorbar;
    end

    if aa==2 | aa==4 | aa==6 | aa==8
        s.plotNum{aa}.YTickLabel=[];
    else
        ylabel('Latitude (deg)');
        yticklabels({'-65','-60','-55','-50','-45',''});
    end
    if aa<7
        s.plotNum{aa}.XTickLabel=[];
    else
        xlabel('Longitude (deg)');
        xticks(135:5:165);
        %xticklabels({'-95','-90','-85','-80'});
    end

    xlim(lonLims(bb,:));
    ylim(latLims(bb,:));

    plot(coastlon,coastlat,'-k')
    text(131,-42,[classTypeNames{nums(aa)}],'fontsize',12,'FontWeight','bold','BackgroundColor','w');

    grid on
    box on
end

s.plotNum{1}.Position=[0.05,0.765,0.44,0.23];
s.plotNum{2}.Position=[0.5,0.765,0.44,0.23];
s.plotNum{3}.Position=[0.05,0.525,0.44,0.23];
s.plotNum{4}.Position=[0.5,0.525,0.44,0.23];
s.plotNum{5}.Position=[0.05,0.285,0.44,0.23];
s.plotNum{6}.Position=[0.5,0.285,0.44,0.23];
s.plotNum{7}.Position=[0.05,0.045,0.44,0.23];
s.plotNum{8}.Position=[0.5,0.045,0.44,0.23];

cb.Position=[0.955,0.045,0.02,0.23];

set(gcf,'PaperPositionMode','auto')
print([figdir,'socrates_locs.png'],'-dpng','-r0');
