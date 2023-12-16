function plotVelocities(velDual,moments,figdir,project,showPlot)
velDual(:,moments.elevation>0,:)=-velDual(:,moments.elevation>0,:);
moments.vel(:,moments.elevation>0,:)=-moments.vel(:,moments.elevation>0,:);

velBase=velDual(:,:,1);
velHigh=nan(size(velBase));
velLow=nan(size(velBase));
velHighH=nan(size(velBase));
velLowH=nan(size(velBase));

velHigh(:,moments.elevation>0)=velDual(:,moments.elevation>0,3);
velLow(:,moments.elevation>0)=velDual(:,moments.elevation>0,2);
velHigh(:,moments.elevation<=0)=velDual(:,moments.elevation<=0,2);
velLow(:,moments.elevation<=0)=velDual(:,moments.elevation<=0,3);

velHighH(:,moments.elevation>0)=velDual(:,moments.elevation>0,5);
velLowH(:,moments.elevation>0)=velDual(:,moments.elevation>0,4);
velHighH(:,moments.elevation<=0)=velDual(:,moments.elevation<=0,4);
velLowH(:,moments.elevation<=0)=velDual(:,moments.elevation<=0,5);

aslGood=moments.asl(~isnan(velBase))./1000;
ylims=[0,max(aslGood)+0.5];

f1 = figure('Position',[200 500 1800 1250],'DefaultAxesFontSize',12,'visible',showPlot);

colormap(velCols);

s1=subplot(3,2,1);

moments.vel(isnan(moments.vel))=-99;

colTwo=cat(1,[0,0,0],velCols);

hold on
surf(moments.time,moments.asl./1000,moments.vel,'edgecolor','none');
view(2);
ylabel('Altitude (km)');
clim([-8 8]);
s1.Colormap=colTwo;
ylim(ylims);
xlim([moments.time(1),moments.time(end)]);
colorbar
grid on
box on
title('Velocity time domain (m s^{-1})')

s2=subplot(3,2,2);

velBase(isnan(velBase))=-99;

hold on
surf(moments.time,moments.asl./1000,velBase,'edgecolor','none');
view(2);
ylabel('Altitude (km)');
clim([-8 8]);
s2.Colormap=colTwo;
ylim(ylims);
xlim([moments.time(1),moments.time(end)]);
colorbar
grid on
box on
title('Velocity base (m s^{-1})')

s3=subplot(3,2,3);

velHighH(isnan(velHighH))=-99;

hold on
surf(moments.time,moments.asl./1000,velHighH,'edgecolor','none');
view(2);
ylabel('Altitude (km)');
clim([-8.001 8]);
s3.Colormap=colTwo;
ylim(ylims);
xlim([moments.time(1),moments.time(end)]);
colorbar
grid on
box on
title('Velocity high (m s^{-1})')

s4=subplot(3,2,4);

velLowH(isnan(velLowH))=-99;

hold on
surf(moments.time,moments.asl./1000,velLowH,'edgecolor','none');
view(2);
ylabel('Altitude (km)');
clim([-8.001 8]);
s4.Colormap=colTwo;
ylim(ylims);
xlim([moments.time(1),moments.time(end)]);
colorbar
grid on
box on
title('Velocity low (m s^{-1})')

s5=subplot(3,2,5);

velHigh(isnan(velHigh))=-99;

hold on
surf(moments.time,moments.asl./1000,velHigh,'edgecolor','none');
view(2);
ylabel('Altitude (km)');
clim([-8.001 8]);
s5.Colormap=colTwo;
ylim(ylims);
xlim([moments.time(1),moments.time(end)]);
colorbar
grid on
box on
title('Velocity high filled (m s^{-1})')

s6=subplot(3,2,6);

velLow(isnan(velLow))=-99;

hold on
surf(moments.time,moments.asl./1000,velLow,'edgecolor','none');
view(2);
ylabel('Altitude (km)');
clim([-8.001 8]);
s6.Colormap=colTwo;
ylim(ylims);
xlim([moments.time(1),moments.time(end)]);
colorbar
grid on
box on
title('Velocity low filled (m s^{-1})')

linkaxes([s1 s2 s3 s4 s5 s6],'xy')

set(gcf,'PaperPositionMode','auto')
print(f1,[figdir,project,'_vels50hz_2_',datestr(moments.time(1),'yyyymmdd_HHMMSS'),'_to_',datestr(moments.time(end),'yyyymmdd_HHMMSS')],'-dpng','-r0');
end