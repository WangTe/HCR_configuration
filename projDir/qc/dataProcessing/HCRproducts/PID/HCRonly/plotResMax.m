function plotResMax(data,result,maxAll)
%Plot m and result for PID
close all
disp('Plotting maximum');

maxAll(isnan(data.DBZ))=nan;

timeMat=repmat(data.time,size(data.TEMP,1),1);

f1=figure('DefaultAxesFontSize',12,'Position',[0 300 2300 1200],'visible','off');

titles={'Rain','Drizzle','Cloud Liquid','Mixed Phase','Snow','Ice'};
ylimits=[0 3];

colormap jet

for ii=1:6
    subplot(4,2,ii);
    resPlot=squeeze(result(ii,:,:));
    resPlot(isnan(data.DBZ))=nan;
    surf(data.time,data.asl./1000,resPlot,'edgecolor','none');
    view(2);
    ylim(ylimits);
    xlim([data.time(1),data.time(end)]);
    caxis([0 100]);
    colorbar;
    ylabel('Altitude (km)');
    title(titles{ii});
    grid on
end

subplot(4,2,8);
surf(data.time,data.asl./1000,squeeze(maxAll),'edgecolor','none');
view(2);
ylim(ylimits);
xlim([data.time(1),data.time(end)]);
caxis([0 100]);
colorbar;
ylabel('Altitude (km)');
title(['Maximum']);

set(gcf,'PaperPositionMode','auto')
print(f1,['/scr/snow2/rsfdata/projects/socrates/hcr/qc2/cfradial/v2.1/pidPlots/debugPlots/socrates_pid_',...
datestr(data.time(1),'yyyymmdd_HHMMSS'),'_to_',datestr(data.time(end),'yyyymmdd_HHMMSS'),'_max'],'-dpng','-r0')

end

