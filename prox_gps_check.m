function [Deployment_roomcat_save_temp,numpaired] = prox_gps_check(Deployment_roomcat_save,bname,numpaired,psname)
%Prox_gps_check by Evan Coffey

% Creates plots to visualize the proximity timeseries(in meters)and GPS classification (1 = in and 0 = away)
% Also shows a breakdown of the percentage of time monitored classified as spent at home and away


%Check to see if there is GPS data available
if ~isnan(nanmean(Deployment_roomcat_save.GPS_cat))
    disp(['GPS and Proximity found for: ', bname])
   
    
%Make an "at home" category variable with height of deployment cat
Deployment_roomcat_save.At_Home=nominal(NaN(height(Deployment_roomcat_save),1));
Deployment_roomcat_save.At_Home(Deployment_roomcat_save.GPS_cat ==1) = ('Home');
Deployment_roomcat_save.At_Home(Deployment_roomcat_save.GPS_cat ==0) = ('Away');
%What about undefined?




%If it does, plot proximity with in/out
FIG = figure('PaperOrientation', 'landscape');
try
subplot(2,2,1)
ax = plotyy(Deployment_roomcat_save.gmttime,Deployment_roomcat_save.Distance_m_merged,Deployment_roomcat_save.gmttime, Deployment_roomcat_save.GPS_cat);
datetick('x')
title('Location/proximity Timeseries');
ylabel(ax(1),'Distance (m)');
ylabel(ax(2),'Inside = 1');
catch
end

try
subplot(2,2,2)
title(bname,'Interpreter', 'none');
histogram(Deployment_roomcat_save.At_Home)
ylabel('# of minutes')
title(bname,'Interpreter', 'none');
catch
end

try
subplot(2,2,3)
hold on
gscatter(Deployment_roomcat_save.gmttime,Deployment_roomcat_save.Distance_m_merged,Deployment_roomcat_save.At_Home);
ar = area(Deployment_roomcat_save.gmttime,Deployment_roomcat_save.GPS_cat*(max(Deployment_roomcat_save.Distance_m_merged)));
ar.FaceColor = 'r';
ar.FaceAlpha = 0.3;
ylabel('Distance (m)');
datetick('x');
title(bname,'Interpreter', 'none');
hold off
catch
end

try
subplot(2,2,4)
title(bname,'Interpreter', 'none');
pie(Deployment_roomcat_save.At_Home)
catch
end

try
print(figure(FIG),'-fillpage','-dpsc2','-append',psname)
catch
    print(figure(FIG),'-dpsc','-append',psname)
end

%%Compliance estimates......
%
%
%



numpaired = numpaired+1; %Add 1 for a paired deployment
Deployment_roomcat_save_temp = Deployment_roomcat_save;


else %File has no overlapping GPS and Proximity data
    
    disp(['!!!No GPS/Proximity overlap found for: ', bname])
    Deployment_roomcat_save_temp = Deployment_roomcat_save;
    numpaired = numpaired; %No change for paired deployments
    
end %Does file have GPS info conditional

disp('........................................')

end %Function end

