function [numbad] = plot_matching(Deployment_roomcat_save,bname,numbad,psname)
% by Evan Coffey

%   Ceates plots from the beacon deployments of proximity to stove and CO
%   exposure etc.


%Text spacer variable (between .1 and .2 ish)
s=.2;

%Determine if there were two Lascars used that have valid data
if isnan(nanmean(Deployment_roomcat_save.Calibrated_LascarCO_ppm_2))
    dupeL = 0;
else
    dupeL = 1;
end

    %% for SENSOR1
        
       %basic visualization of the CO/proximity data...
       Deployment_roomcat_save.DistanceFlag = categorical(Deployment_roomcat_save.DistanceFlag);
       [gname,meann,minn,maxx,dose,mediann,numel] = grpstats(Deployment_roomcat_save.Calibrated_LascarCO_ppm_1,Deployment_roomcat_save.DistanceFlag,{'gname','nanmean','min','max','sum','nanmedian','numel'});
       lascar1name = char(Deployment_roomcat_save.Lascar_1_Name(1));
       
       FIG = figure('PaperOrientation', 'landscape');
       %Time series plot of distance and COppm
       try
       %figure( 'Units', 'normalized','Position',[.1 .1 .7 .6])
       subplot(2,2,1)
       ax = plotyy(Deployment_roomcat_save.gmttime,Deployment_roomcat_save.Distance_m_merged,Deployment_roomcat_save.gmttime, Deployment_roomcat_save.Calibrated_LascarCO_ppm_1);
       datetick('x')
       title([lascar1name, ' time series'],'Interpreter', 'none')
       xlabel('Time')
       ylabel(ax(2),'CO (ppm)')
       ylabel(ax(1),'Distance (m)')
       grid  
       catch
        disp('Issue plotting CO/proximity timeseries 1')
       end
       
       %mdl = fitlm(Deployment_roomcat,'Calibrated_LascarCO_ppm_1~1+Distance_m_merged*DistanceFlag')

       %Group scatterplot of COppm vs distance meters
       try
       subplot(2,2,2)
       hold on
       gscatter(Deployment_roomcat_save.Distance_m_merged,Deployment_roomcat_save.Calibrated_LascarCO_ppm_1,Deployment_roomcat_save.DistanceFlag);
       %scatter(Deployment_roomcat_save.Distance_m_merged(Deployment_roomcat_save.DistanceFlag=='Over5m'),Deployment_roomcat_save.Calibrated_LascarCO_ppm_1(Deployment_roomcat_save.DistanceFlag=='Over5m'))
       %scatter(Deployment_roomcat_save.Distance_m_merged(Deployment_roomcat_save.DistanceFlag=='<5m'),Deployment_roomcat_save.Calibrated_LascarCO_ppm_1(Deployment_roomcat_save.DistanceFlag=='<5m'))
       ax = gca;
       ylim([-5,max(maxx)])
       xlim([-5,100])
       xlabel('Distance from receiver (m)')
       ylabel('CO (ppm)')
       ax.YAxisLocation = 'right';
       %legend('off')
       title([bname],'Interpreter', 'none');
       grid
       hold off
       catch
           disp('Issue plotting CO vs. proximity 1')
       end
       
       
       %Boxplot of category COppm with 2nd and 98th percentiles
       try
           subplot(2,2,3)
           boxplot(Deployment_roomcat_save.Calibrated_LascarCO_ppm_1,Deployment_roomcat_save.DistanceFlag);
           ylabel('CO (ppm)')
           title('CO 2nd and 98th prctls')
           set(gca,'XTickLabelRotation',45)           
           
            g = findobj(gca,'Tag','Box');
            for j=1:length(g)
                get(g(j),'XData'); get(g(j),'YData');
            end
            a = findall(gca,'type','line');
            for j=1:length(a)
            set(a(j), 'Linewidth',2)
            end

            for rr=1:length(gname)
             p([1:2],rr) = prctile(Deployment_roomcat_save.Calibrated_LascarCO_ppm_1(Deployment_roomcat_save.DistanceFlag==gname(rr)),[2,98]);
            end

             % Replace upper end y value of whisker
            h = flipud(findobj(gca,'Tag','Upper Whisker'));
            for j=1:length(h)
                ydata = get(h(j),'YData');
                ydata(2) = p(2,j);
                set(h(j),'YData',ydata);
            end

            % Replace all y values of adjacent value
            h = flipud(findobj(gca,'Tag','Upper Adjacent Value'));
            for j=1:length(h)
                ydata = get(h(j),'YData');
                ydata(:) = p(2,j);
                set(h(j),'YData',ydata);
            end

            % Replace lower end y value of whisker
            h = flipud(findobj(gca,'Tag','Lower Whisker'));
            for j=1:length(h)
                ydata = get(h(j),'YData');
                ydata(1) = p(1,j);
                set(h(j),'YData',ydata);
            end

            % Replace all y values of adjacent value
            h = flipud(findobj(gca,'Tag','Lower Adjacent Value'));
            for j=1:length(h)
                ydata = get(h(j),'YData');
                ydata(:) = p(1,j);
                set(h(j),'YData',ydata);
            end

            h = flipud(findobj(gca,'Tag','Outliers'));
            for j=1:length(h)
              ydata = get(h(j),'YData');
              xdata = get(h(j),'XData');
              remdata = (ydata >= p(1,j)) & (ydata <= p(2,j));
              ydata(remdata) = [];
              xdata(remdata) = [];
              set(h(j),'XData',xdata,'YData',ydata);
            end
            clear p
           grid
       
           try %Plots the number of observations from each dictance flag category (rr) on the boxplot
               for rr =1:length(gname)
                text(rr+.15,maxx(rr),{'n:' num2str(numel(rr),4)})
               end
           catch
               disp('Issue displaying sample numbers on boxplot 1')
           end
       
       catch
           disp('Issue plotting boxplot 1')
       end
       
       
       %Pie chart of CO dose by category
       try
       subplot(2,2,4)
       bar(categorical(gname), dose/sum(dose));
       title('Percentage of CO dose by category')
       grid
       catch
           disp('Issue plotting bar chart 1')
       end
             
%        clear g
%         %testing the gramm plotting
%       
%        % Create a gramm object, provide x (year of production) and y (fuel economy) data,
%         % color grouping data (number of cylinders) and select a subset of the data
%         g=gramm('x',Deployment_roomcat_save.DistanceFlag, 'y',Deployment_roomcat_save.Calibrated_LascarCO_ppm_1,'color',Deployment_roomcat_save.DistanceFlag);
%         % Plot linear fits of the data with associated confidence intervals
%         g.stat_glm('disp_fit', 'fullrange');
%         %%%
%         % Set appropriate names for legends
%         g.set_names('x','Distance from receiver (m)','y','CO (ppm)','color','Distance Category');
%         %%%
%         % Set figure title
%         g.set_title('CO exposure by distance');
%         %%%
%         % Do the actual drawing
%         %figure('Position',[100 100 800 400])
%         g.facet_grid(Deployment_roomcat_save.DistanceFlag,[]);
% 
%         g.geom_point();
%           g.stat_boxplot()
%           g.draw();
%         
%        
       
       
try
print(figure(FIG),'-fillpage','-dpsc2','-append',psname)
catch
    print(figure(FIG),'-dpsc','-append',psname)
end
       
       
       
     %% SENSOR2   
  if dupeL == 1
       
      lascar2name = char(Deployment_roomcat_save.Lascar_2_Name(1));
      
   
       % Create a gramm object, provide x (year of production) and y (fuel economy) data,
        % color grouping data (number of cylinders) and select a subset of the data
       
        try
        clear g
        g(1,1)=gramm('x',Deployment_roomcat_save.Calibrated_LascarCO_ppm_2,'y',Deployment_roomcat_save.Calibrated_LascarCO_ppm_1);
        g(1,1).stat_glm('disp_fit', 'fullrange');
        % Se2 appropriate names for legends
        g(1,1).set_names('x',lascar2name,'y',lascar1name);
        % Set figure title
        g(1,1).set_title('Overall Duplicate Lascar Comparison');
        % Plot as points
        g(1,1).geom_point();
        % Reference line
        g(1,1).geom_abline('intercept',0,'slope',1)
        
        
        g(2,1)=gramm('x',Deployment_roomcat_save.Calibrated_LascarCO_ppm_2,'y',Deployment_roomcat_save.Calibrated_LascarCO_ppm_1,'color',Deployment_roomcat_save.DistanceFlag);
        g(2,1).stat_glm('disp_fit', 'fullrange');
        % Se2 appropriate names for legends
        g(2,1).set_names('x',lascar2name,'y',lascar1name,'color','Distance Category');
        % Set figure title
        g(2,1).set_title('Categorized Duplicate Lascar Comparison');
        % Plot as points
        g(2,1).geom_point();
        % Reference line
        g(2,1).geom_abline('intercept',0,'slope',1)
        
        %g(2,1).results.stat_glm(1).model.Rsquared.Adjusted
        %g(2,1).results.stat_glm(4).model.Rsquared.Adjusted  
        
        % Draw fig
         FIG = figure('PaperOrientation', 'landscape');
         g.draw();
         clear g
        
        catch
            disp('Issue plotting Lascar Scatter')
        end
        
        try
        print(figure(FIG),'-fillpage','-dpsc2','-append',psname)
        catch
            print(figure(FIG),'-dpsc','-append',psname)
        end
%         
%       try
%       scatter(Deployment_roomcat_save.Calibrated_LascarCO_ppm_1,Deployment_roomcat_save.Calibrated_LascarCO_ppm_2)
%       ylabel([lascar2name, ' ppm'],'Interpreter', 'none')
%       xlabel([lascar1name, ' ppm'],'Interpreter', 'none')
%       refline(1,0)
%       lsline()
%       grid
%       hold off
%       catch
%       end
      
       %basic visualization of the CO/proximity data...
       [gname2,meann2,minn2,maxx2,dose2,mediann2,numel2] = grpstats(Deployment_roomcat_save.Calibrated_LascarCO_ppm_2,Deployment_roomcat_save.DistanceFlag,{'gname','nanmean','min','max','sum','nanmedian','numel'});
       
       
       FIG = figure('PaperOrientation', 'landscape');
       %Time series plot of distance and COppm
       try
       subplot(2,2,1)
       ax = plotyy(Deployment_roomcat_save.gmttime,Deployment_roomcat_save.Distance_m_merged,Deployment_roomcat_save.gmttime, Deployment_roomcat_save.Calibrated_LascarCO_ppm_2);
       datetick('x')
       title([lascar2name, ' time series'],'Interpreter', 'none')
       xlabel('Time')
       ylabel(ax(2),'CO (ppm)')
       ylabel(ax(1),'Distance (m)')
       grid  
       %mdl = fitlm(Deployment_roomcat,'Calibrated_LascarCO_ppm_1~1+Distance_m_merged*DistanceFlag')
       catch
           disp('Issue plotting CO/proximity timeseries 2')
       end
       
       %Group scatterplot of COppm vs distance meters
       try
       subplot(2,2,2)
       hold on
       gscatter(Deployment_roomcat_save.Distance_m_merged,Deployment_roomcat_save.Calibrated_LascarCO_ppm_2,Deployment_roomcat_save.DistanceFlag);
       %scatter(Deployment_roomcat_save.Distance_m_merged(Deployment_roomcat_save.DistanceFlag=='Over5m'),Deployment_roomcat_save.Calibrated_LascarCO_ppm_2(Deployment_roomcat_save.DistanceFlag=='Over5m'))
       %scatter(Deployment_roomcat_save.Distance_m_merged(Deployment_roomcat_save.DistanceFlag=='<5m'),Deployment_roomcat_save.Calibrated_LascarCO_ppm_2(Deployment_roomcat_save.DistanceFlag=='<5m'))
       ax = gca;
       ylim([-5,max(maxx)])
       xlim([-5,100])
       xlabel('Distance from receiver (m)')
       ylabel('CO (ppm)')
       ax.YAxisLocation = 'right';
       %legend('off')
       title([bname],'Interpreter', 'none');
       grid
       hold off
       catch
           disp('Issue plotting CO vs. proximity 2')
       end
       
       
       %Boxplot of category COppm with 2nd and 98th percentiles
       try
           subplot(2,2,3)
           boxplot(Deployment_roomcat_save.Calibrated_LascarCO_ppm_2,Deployment_roomcat_save.DistanceFlag);
           ylabel('CO (ppm)')
           title('CO 2nd and 98th prctls')
           set(gca,'XTickLabelRotation',45)  

            g = findobj(gca,'Tag','Box');
            for j=1:length(g)
                get(g(j),'XData'); get(g(j),'YData');
            end
            a = findall(gca,'type','line');
            for j=1:length(a)
            set(a(j), 'Linewidth',2)
            end

              for rr=1:length(gname2)
                 p([1:2],rr) = prctile(Deployment_roomcat_save.Calibrated_LascarCO_ppm_2(Deployment_roomcat_save.DistanceFlag==gname(rr)),[2,98]);
              end

             % Replace upper end y value of whisker
            h = flipud(findobj(gca,'Tag','Upper Whisker'));
            for j=1:length(h)
                ydata = get(h(j),'YData');
                ydata(2) = p(2,j);
                set(h(j),'YData',ydata);
            end

            % Replace all y values of adjacent value
            h = flipud(findobj(gca,'Tag','Upper Adjacent Value'));
            for j=1:length(h)
                ydata = get(h(j),'YData');
                ydata(:) = p(2,j);
                set(h(j),'YData',ydata);
            end

            % Replace lower end y value of whisker
            h = flipud(findobj(gca,'Tag','Lower Whisker'));
            for j=1:length(h)
                ydata = get(h(j),'YData');
                ydata(1) = p(1,j);
                set(h(j),'YData',ydata);
            end

            % Replace all y values of adjacent value
            h = flipud(findobj(gca,'Tag','Lower Adjacent Value'));
            for j=1:length(h)
                ydata = get(h(j),'YData');
                ydata(:) = p(1,j);
                set(h(j),'YData',ydata);
            end

            h = flipud(findobj(gca,'Tag','Outliers'));
            for j=1:length(h)
              ydata = get(h(j),'YData');
              xdata = get(h(j),'XData');
              remdata = (ydata >= p(1,j)) & (ydata <= p(2,j));
              ydata(remdata) = [];
              xdata(remdata) = [];
              set(h(j),'XData',xdata,'YData',ydata);
            end
           grid
           

           try %Plots the number of observations from each dictance flag category (rr) on the boxplot
               for rr =1:length(gname2)
                text(rr+.15,maxx2(rr),{'n:' num2str(numel2(rr),4)})
               end
           catch
               disp('Issue displaying sample numbers on boxplot 2')
           end
           
       catch
           disp('Issue plotting boxplot 2')
       end
       
       %Pie chart of CO dose by category
       try
       subplot(2,2,4)
       bar(categorical(gname2), dose/sum(dose2));
       title('Percentage of CO dose by category')
       grid
       catch
           disp('Issue plotting bar chart 1')
       end
    try
    print(figure(FIG),'-fillpage','-dpsc2','-append',psname)
    catch
    print(figure(FIG),'-dpsc','-append',psname)
    end

       % Summary stats
           FIG = figure('PaperOrientation', 'landscape');
        try
           title(['Summary stats for ', bname],'Interpreter', 'none')
           text(.05,.9,Deployment_roomcat_save.Lascar_1_Name(1),'Interpreter', 'none')
           text(.1,0.8,{'category:' gname{1}})
           text(.1,0.7,{'mean:' num2str(meann(1),3)})
           text(.1,0.6,{'median:' num2str(mediann(1),3)})
           text(.1,0.5,{'dose:' num2str(dose(1),5)})
           text(.1,0.4,{'# points:' num2str(numel(1),5)})

           text(.45,.9,Deployment_roomcat_save.Lascar_1_Name(1),'Interpreter', 'none')
           text(0.5,0.8,{'category:' gname{2}})
           text(0.5,0.7,{'mean:' num2str(meann(2),3)})
           text(0.5,0.6,{'median:' num2str(mediann(2),3)})
           text(0.5,0.5,{'dose:' num2str(dose(2),5)})
           text(0.5,0.4,{'# points:' num2str(numel(2),5)})
           
           text(.05+s,.9,Deployment_roomcat_save.Lascar_2_Name(1),'Interpreter', 'none')
           text(.1+s,0.8,{'category:' gname2{1}})
           text(.1+s,0.7,{'mean:' num2str(meann2(1),3)})
           text(.1+s,0.6,{'median:' num2str(mediann2(1),3)})
           text(.1+s,0.5,{'dose:' num2str(dose2(1),5)})
           text(.1+s,0.4,{'# points:' num2str(numel2(1),5)})   
           
           text(.45+s,.9,Deployment_roomcat_save.Lascar_2_Name(1),'Interpreter', 'none')
           text(0.5+s,0.8,{'category:' gname2{2}})
           text(0.5+s,0.7,{'mean:' num2str(meann2(2),3)})
           text(0.5+s,0.6,{'median:' num2str(mediann2(2),3)})
           text(0.5+s,0.5,{'dose:' num2str(dose2(2),5)})
           text(0.5+s,0.4,{'# points:' num2str(numel2(2),5)})

            try
            print(figure(FIG),'-fillpage','-dpsc2','-append',psname)
            catch
                print(figure(FIG),'-dpsc','-append',psname)
            end
       
        catch
            disp('Summary stats problems');
        end
              
  else %only one Lascar has data in Deployment_roomcat
      
     disp('Only one Lascar used in depoyment: '); disp(bname)    

     FIG = figure('PaperOrientation', 'landscape');
      try       
       title(['Summary stats for ', bname],'Interpreter', 'none')
       text(.05,.8,Deployment_roomcat_save.Lascar_1_Name(1),'Interpreter', 'none')
       text(.1,0.7,{'category:' gname{1}})
       text(.1,0.6,{'mean:' num2str(meann(1),3)})
       text(.1,0.5,{'median:' num2str(mediann(1),3)})
       text(.1,0.4,{'dose:' num2str(dose(1),3)})
       text(.1,0.3,{'# points:' num2str(numel(1),5)})

       text(.45+s,.8,Deployment_roomcat_save.Lascar_1_Name(1),'Interpreter', 'none')
       text(0.65,0.7,{'category:' gname{2}})
       text(0.65,0.6,{'mean:' num2str(meann(2),3)})
       text(0.65,0.5,{'median:' num2str(mediann(2),3)})
       text(0.65,0.4,{'dose:' num2str(dose(2),3)})
       text(0.65,0.3,{'# points:' num2str(numel(2),5)})
        try
        print(figure(FIG),'-fillpage','-dpsc2','-append',psname)
        catch
            print(figure(FIG),'-dpsc','-append',psname)
        end
       
      catch
            disp('Summary stats problems');
      end
     
  end 
       numbad=numbad;
       
       clear gname meann minn maxx dose mediann numel gname2 meann2 minn2 maxx2 dose2 mediann2 numel2 g
       
end

