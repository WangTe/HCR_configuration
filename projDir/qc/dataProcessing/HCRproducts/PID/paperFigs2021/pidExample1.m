% Calculate PID from HCR HSRL combined data

clear all
close all

addpath(genpath('~/git/HCR_configuration/projDir/qc/dataProcessing/'));

ylimits=[0 2];

indir='/scr/snow2/rsfdata/projects/socrates/hcr/qc3/cfradial/hcr_hsrl_merge/v3.0_full/2hz/';

figdir=['/scr/snow2/rsfdata/projects/socrates/hcr/qc3/cfradial/hcr_hsrl_merge/v3.0_full/pidPlotsComb/paperFigs/'];

startTime=datetime(2018,1,19,4,25,0);
endTime=datetime(2018,1,19,4,30,0);

fileList=makeFileList(indir,startTime,endTime,'xxxxxx20YYMMDDxhhmmss',1);

%% Load data

disp('Loading data');

data=[];

%HCR data
data.HCR_DBZ=[];
data.HCR_VEL=[];
data.HCR_LDR=[];
data.TEMP=[];
data.HCR_ICING_LEVEL=[];
data.PID=[];
data.HCR_PID=[];
data.HSRL_Aerosol_Backscatter_Coefficient=[];
data.HSRL_Particle_Linear_Depolarization_Ratio=[];

dataVars=fieldnames(data);

% Load data
data=read_HCR(fileList,data,startTime,endTime);

% Check if all variables were found
for ii=1:length(dataVars)
    if ~isfield(data,dataVars{ii})
        dataVars{ii}=[];
    end
end

data.HSRL_Aerosol_Backscatter_Coefficient(isnan(data.HCR_DBZ))=nan;
data.HSRL_Particle_Linear_Depolarization_Ratio(isnan(data.HCR_DBZ))=nan;

data.HSRL_Aerosol_Backscatter_Coefficient(data.HSRL_Aerosol_Backscatter_Coefficient<9.9e-9)=nan;
data.HSRL_Particle_Linear_Depolarization_Ratio(data.HSRL_Aerosol_Backscatter_Coefficient<9.9e-9)=nan;

%% Scales and units
%cscale_hcr=[1,0,0; 1,0.6,0.47; 0,1,0; 0,0.7,0; 0,0,1; 1,0,1; 0.5,0,0; 1,1,0; 0,1,1; 0,0,0; 0.5,0.5,0.5];

%cscale_hcr=[1,0,0; 1,0,1; 0.98,0.64,0.1; 1,1,0; 0.1,0.6,0.1; 0,1,0; 0.6,0.4,0.1; 0,0,1; 0,1,1; 0,0,0; 0.4,0.5,0.5];

%cscale_hcr=[1,0,0; 1,0,1; 0.98,0.64,0.1; 1,1,0; 0.1,0.6,0.1; 0,1,0; 0.6,0.4,0.1; 0,0,1; 0,1,1; 0,0,0; 0.4,0.5,0.5];

%cscale_hcr=[255,0,0; 238,153,170; 249,163,25; 255,255,0; 153,119,0; 221,204,119; 17,119,51; 0,0,255; 0,255,255; 0,0,0; 150,150,150];

cscale_hcr=[255,0,0; 255,204,204; 249,163,25; 255,240,60; 136,34,185; 255,0,255; 17,170,51; 0,0,255; 0,255,255; 0,0,0; 150,150,150];

cscale_hcr=cscale_hcr./255;

units_str_hcr={'Rain','SC Rain','Drizzle','SC Drizzle','Cloud Liquid','SC Cloud Liq.',...
    'Melting','Large Frozen','Small Frozen','Precip','Cloud'};

%% Plot PIDs

timeMat=repmat(data.time,size(data.TEMP,1),1);

disp('Plotting PID');

close all

wi=10;
hi=10.5;

fig1=figure('DefaultAxesFontSize',11,'DefaultFigurePaperType','<custom>','units','inch','position',[3,100,wi,hi]);
fig1.PaperPositionMode = 'manual';
fig1.PaperUnits = 'inches';
fig1.Units = 'inches';
fig1.PaperPosition = [0, 0, wi, hi];
fig1.PaperSize = [wi, hi];
fig1.Resize = 'off';
fig1.InvertHardcopy = 'off';

set(fig1,'color','w');

s1=subplot(8,1,1);
surf(data.time,data.asl./1000,data.HCR_DBZ,'edgecolor','none');
view(2);
ylim(ylimits);
xlim([data.time(1),data.time(end)]);
caxis([-40 20]);
colormap(s1,jet);
cb1=colorbar;
cb1.Ticks=-30:10:10;
ylabel('Altitude (km)');
text(startTime+seconds(5),ylimits(2)-0.2,'(a) HCR DBZ (dBZ)',...
    'fontsize',11,'fontweight','bold','BackgroundColor','w','Margin',0.5);
grid on
box on
s1.XTickLabel=[];
s1.YTick=0:0.5:1.5;

s2=subplot(8,1,2);
surf(data.time,data.asl./1000,data.HCR_VEL,'edgecolor','none');
view(2);
ylim(ylimits);
xlim([data.time(1),data.time(end)]);
caxis([-5 5]);
colormap(s2,jet);
cb2=colorbar;
cb2.Ticks=-4:2:4;
ylabel('Altitude (km)');
text(startTime+seconds(5),ylimits(2)-0.25,'(b) HCR VEL (m s^{-1})',...
    'fontsize',11,'fontweight','bold','BackgroundColor','w','Margin',0.5);
s2.SortMethod = 'childorder';
grid on
box on
s2.XTickLabel=[];
s2.YTick=0:0.5:1.5;

s3=subplot(8,1,3);
surf(data.time,data.asl./1000,data.HCR_LDR,'edgecolor','none');
view(2);
ylim(ylimits);
xlim([data.time(1),data.time(end)]);
caxis([-30 -5]);
colormap(s3,jet);
cb3=colorbar;
cb3.Ticks=-25:5:-10;
ylabel('Altitude (km)');
text(startTime+seconds(5),ylimits(2)-0.2,'(c) HCR LDR (dB)',...
    'fontsize',11,'fontweight','bold','BackgroundColor','w','Margin',0.5);
grid on
box on
s3.XTickLabel=[];
s3.YTick=0:0.5:1.5;

s4=subplot(8,1,4);
surf(data.time,data.asl./1000,data.HSRL_Particle_Linear_Depolarization_Ratio,'edgecolor','none');
view(2);
ylim(ylimits);
xlim([data.time(1),data.time(end)]);
caxis([0 0.5]);
colormap(s4,jet);
cb4=colorbar;
%cb4.Ticks=0.25:0.25:1.75;
ylabel('Altitude (km)');
text(startTime+seconds(5),ylimits(2)-0.25,'(d) HSRL LLDR',...
    'fontsize',11,'fontweight','bold','BackgroundColor','w','Margin',0.5);
s4.SortMethod = 'childorder';
grid on
box on
s4.XTickLabel=[];
s4.YTick=0:0.5:1.5;

s5=subplot(8,1,5);
surf(data.time,data.asl./1000,log10(data.HSRL_Aerosol_Backscatter_Coefficient),'edgecolor','none');
view(2);
ylim(ylimits);
xlim([data.time(1),data.time(end)]);
caxis([-9 0]);
colormap(s5,'jet');
cb5=colorbar;
ylabel('Altitude (km)');
text(startTime+seconds(5),ylimits(2)-0.2,'(e) log10(HSRL BACKSCAT) (m^{-1} sr^{-1})',...
    'fontsize',11,'fontweight','bold','BackgroundColor','w','Margin',0.5);
s5.SortMethod = 'childorder';
grid on
box on
s5.XTickLabel=[];
s5.YTick=0:0.5:1.5;

s6=subplot(8,1,6);
hold on
surf(data.time,data.asl./1000,data.TEMP,'edgecolor','none');
view(2);
ylim(ylimits);
xlim([data.time(1),data.time(end)]);
caxis([-10 10]);
plot(data.time,data.HCR_ICING_LEVEL./1000,'-k','linewidth',2);
colormap(s6,'jet');
cb6=colorbar;
cb6.Ticks=-8:2:8;
ylabel('Altitude (km)');
text(startTime+seconds(5),ylimits(2)-0.2,['(f) TEMP (',char(176),'C) and melting layer'],...
    'fontsize',11,'fontweight','bold','BackgroundColor','w','Margin',0.5);
s6.SortMethod = 'childorder';
grid on
box on
s6.XTickLabel=[];
s6.YTick=0:0.5:1.5;

s7=subplot(8,1,7);
surf(data.time,data.asl./1000,data.PID,'edgecolor','none');
view(2);
ylim(ylimits);
xlim([data.time(1),data.time(end)]);
caxis([.5 11.5]);
colormap(s7,cscale_hcr);
cb7=colorbar;
cb7.Ticks=1:11;
cb7.TickLabels=units_str_hcr;
ylabel('Altitude (km)');
s7.XTickLabel=[];
text(startTime+seconds(5),ylimits(2)-0.2,'(g) PID combined',...
    'fontsize',11,'fontweight','bold','BackgroundColor','w','Margin',0.5);
grid on
box on
s7.YTick=0:0.5:1.5;

s8=subplot(8,1,8);
surf(data.time,data.asl./1000,data.HCR_PID,'edgecolor','none');
view(2);
ylim(ylimits);
xlim([data.time(1),data.time(end)]);
caxis([.5 11.5]);
colormap(s8,cscale_hcr);
cb8=colorbar;
cb8.Ticks=1:11;
cb8.TickLabels=units_str_hcr;
ylabel('Altitude (km)');
text(startTime+seconds(5),ylimits(2)-0.2,'(h) PID HCR stand-alone',...
    'fontsize',11,'fontweight','bold','BackgroundColor','w','Margin',0.5);
grid on
box on
s8.YTick=0:0.5:1.5;

s1.Position=[0.059 0.88 0.79 0.11];
cb1.Position=[0.856 0.88 0.023 0.11];
cb1.FontSize=9;

s2.Position=[0.059 0.76 0.79 0.11];
cb2.Position=[0.856 0.76 0.023 0.11];
cb2.FontSize=9;

s3.Position=[0.059 0.64 0.79 0.11];
cb3.Position=[0.856 0.64 0.023 0.11];
cb3.FontSize=9;

s4.Position=[0.059 0.52 0.79 0.11];
cb4.Position=[0.856 0.52 0.023 0.11];
cb4.FontSize=9;

s5.Position=[0.059 0.4 0.79 0.11];
cb5.Position=[0.856 0.4 0.023 0.11];
cb5.FontSize=9;

s6.Position=[0.059 0.28 0.79 0.11];
cb6.Position=[0.856 0.28 0.023 0.11];
cb6.FontSize=9;

s7.Position=[0.059 0.16 0.79 0.11];
cb7.Position=[0.856 0.16 0.023 0.11];
cb7.FontSize=9;

s8.Position=[0.059 0.04 0.79 0.11];
cb8.Position=[0.856 0.04 0.023 0.11];
cb8.FontSize=9;

set(gcf,'PaperPositionMode','auto')
%print(fig1,[figdir,'pidExample1.png'],'-dpng','-r0')
print(fig1,[figdir,'pidExample1.tif'],'-dtiffn','-r0')
