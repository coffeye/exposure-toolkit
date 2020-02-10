function [noncomp,comptable] = final_plotting(Deployment_roomcat_save,bname,noncomp,comptable,psname)
%Final_plotting Summary of this function goes here
%   Detailed explanation goes here

%        %Merge complinace to form Overall_compliance
%         Deployment_roomcat_save.HAPEX_1_Compliance = round(Deployment_roomcat_save.HAPEX_1_Compliance);
%         Deployment_roomcat_save.HAPEX_2_Compliance = round(Deployment_roomcat_save.HAPEX_2_Compliance);
% 
%         %c=confusionmat(Deployment_roomcat_save.HAPEX_1_Compliance,Deployment_roomcat_save.HAPEX_2_Compliance); c = sum(c); matched = c(1,1)/(sum(c)); conflicted = c(1,2)/(sum(c));
% 
% 
%         totcomp1 = Deployment_roomcat_save.HAPEX_1_Compliance;
%         totcomp2 = Deployment_roomcat_save.HAPEX_2_Compliance;
% 
%         comptemp = cat(2,totcomp1,totcomp2);
%         comptemp = nansum(comptemp,2);
%         comptemp = comptemp>0;
% 
%         Deployment_roomcat_save.Overall_Compliance = comptemp;

% % Create the necessary categirical data
%      
%        Deployment_roomcat_save.DistanceFlag = categorical(Deployment_roomcat_save.DistanceFlag);
%        Deployment_roomcat_save.Overall_compliance = categorical(Deployment_roomcat_save.Overall_Compliance);
% 
%                
  
       
       FIG = figure('PaperOrientation', 'landscape'); %generate figure
       set(gcf,'units','normalized','outerposition',[0 0 1 1]); %Increase size

       % Timeseries plot of GPS, proximity (smoothed) to nearest area coded by compliance
        plot1 = subplot(5,1,1); hold on; title(['Timeseries of deployment: ', bname],'Interpreter', 'none');
        ar = area(Deployment_roomcat_save.gmttime,Deployment_roomcat_save.GPS_cat*(max(Deployment_roomcat_save.Distance_m_merged)));
        scatter(Deployment_roomcat_save.gmttime(Deployment_roomcat_save.Overall_Compliance==0),Deployment_roomcat_save.Distance_m_merged(Deployment_roomcat_save.Overall_Compliance==0),8,'r', 'filled');
        scatter(Deployment_roomcat_save.gmttime(Deployment_roomcat_save.Overall_Compliance==1),Deployment_roomcat_save.Distance_m_merged(Deployment_roomcat_save.Overall_Compliance==1),8,'g', 'filled');
        plot(Deployment_roomcat_save.gmttime,smooth(Deployment_roomcat_save.Distance_m_merged,10,'rloess'),'k-');
        ar.FaceColor = 'g';
        ar.FaceAlpha = 0.2;
        ar.EdgeColor = 'none';
        ylim([0,max(Deployment_roomcat_save.Distance_m_merged)])
        xlim([Deployment_roomcat_save.gmttime(1),Deployment_roomcat_save.gmttime(end)])
        ylabel({'Meters to nearest','cooking area'})
        datetick('x')
         
        % Zommed in timeseries plot of GPS, proximity (smoothed) to nearest area coded by compliance
        plot2 = subplot(5,1,2); hold on;
        ar = area(Deployment_roomcat_save.gmttime,Deployment_roomcat_save.GPS_cat*(max(Deployment_roomcat_save.Distance_m_merged)));
        scatter(Deployment_roomcat_save.gmttime(Deployment_roomcat_save.Overall_Compliance==0),Deployment_roomcat_save.Distance_m_merged(Deployment_roomcat_save.Overall_Compliance==0),8,'r', 'filled');
        scatter(Deployment_roomcat_save.gmttime(Deployment_roomcat_save.Overall_Compliance==1),Deployment_roomcat_save.Distance_m_merged(Deployment_roomcat_save.Overall_Compliance==1),8,'b', 'filled');
        plot(Deployment_roomcat_save.gmttime,smooth(Deployment_roomcat_save.Distance_m_merged,10,'rloess'),'k-');
        ar.FaceColor = 'g';
        ar.FaceAlpha = 0.2;
        ar.EdgeColor = 'none';
        ylim([0,5])
        xlim([Deployment_roomcat_save.gmttime(1),Deployment_roomcat_save.gmttime(end)])
        ylabel({'Meters to nearest','cooking area'})
        datetick('x')
        hold off
        
        % Exposure timeseries coded by compliance
        plot3 = subplot(5,1,3); hold on;
        ax2 = scatter(Deployment_roomcat_save.gmttime(Deployment_roomcat_save.Overall_Compliance==0),Deployment_roomcat_save.CO_exposure_ppm(Deployment_roomcat_save.Overall_Compliance==0),50,'r.');
        ax1 = scatter(Deployment_roomcat_save.gmttime(Deployment_roomcat_save.Overall_Compliance==1),Deployment_roomcat_save.CO_exposure_ppm(Deployment_roomcat_save.Overall_Compliance==1),50,'g.');
        ylabel('CO ppm')
%         yyaxis('right')
%         ax3 = scatter(Deployment_roomcat_save.gmttime(Deployment_roomcat_save.Overall_Compliance==1),Deployment_roomcat_save.PM_exposure_ugpcm(Deployment_roomcat_save.Overall_Compliance==1),20,'cs');
%         ax4 = scatter(Deployment_roomcat_save.gmttime(Deployment_roomcat_save.Overall_Compliance==0),Deployment_roomcat_save.PM_exposure_ugpcm(Deployment_roomcat_save.Overall_Compliance==0),20,'rs');
%         ylabel('PM ugpcm')
%         xlim([Deployment_roomcat_save.gmttime(1),Deployment_roomcat_save.gmttime(end)])
%         %ax2.Font
        datetick('x')
        hold off

        % Exposure timeseries coded by compliance
        plot4 = subplot(5,1,4); hold on;
        ax4 = scatter(Deployment_roomcat_save.gmttime(Deployment_roomcat_save.Overall_Compliance==0),Deployment_roomcat_save.PM_exposure_ugpcm(Deployment_roomcat_save.Overall_Compliance==0),20,'rs');
        ax3 = scatter(Deployment_roomcat_save.gmttime(Deployment_roomcat_save.Overall_Compliance==1),Deployment_roomcat_save.PM_exposure_ugpcm(Deployment_roomcat_save.Overall_Compliance==1),20,'gs');
        ylabel('PM ugpcm')
        xlim([Deployment_roomcat_save.gmttime(1),Deployment_roomcat_save.gmttime(end)])
        %ax2.Font
        datetick('x')
        hold off
        

        % Stove usage 
        plot5 = subplot(5,1,5); hold on;
        s1 = scatter(Deployment_roomcat_save.gmttime,Deployment_roomcat_save.Stove_1_temp./max(Deployment_roomcat_save.Stove_1_temp),8, 'filled');
        ar1 = area(Deployment_roomcat_save.gmttime,double(string(Deployment_roomcat_save.Stove_1_status)=={'Cooking'})); ar1.FaceColor = 'b'; ar1.FaceAlpha = 0.3; ar1.EdgeColor = 'k';
       
        s2 = scatter(Deployment_roomcat_save.gmttime,Deployment_roomcat_save.Stove_2_temp./max(Deployment_roomcat_save.Stove_2_temp),8, 'filled');
        ar2 = area(Deployment_roomcat_save.gmttime,double(string(Deployment_roomcat_save.Stove_2_status)=={'Cooking'})); ar2.FaceColor = 'y'; ar2.FaceAlpha = 0.3; ar2.EdgeColor = 'k';

        s3 = scatter(Deployment_roomcat_save.gmttime,Deployment_roomcat_save.Stove_3_temp./max(Deployment_roomcat_save.Stove_3_temp),8, 'filled');
        ar3 = area(Deployment_roomcat_save.gmttime,double(string(Deployment_roomcat_save.Stove_3_status)=={'Cooking'})); ar3.FaceColor = 'g'; ar3.FaceAlpha = 0.3; ar3.EdgeColor = 'k';

        s4 = scatter(Deployment_roomcat_save.gmttime,Deployment_roomcat_save.Stove_4_temp./max(Deployment_roomcat_save.Stove_4_temp),8, 'filled');
        ar4 = area(Deployment_roomcat_save.gmttime,double(string(Deployment_roomcat_save.Stove_4_status)=={'Cooking'})); ar4.FaceColor = [0.64,0.08,0.18]; ar4.FaceAlpha = 0.3; ar4.EdgeColor = 'k';

        s5 = scatter(Deployment_roomcat_save.gmttime,Deployment_roomcat_save.Stove_5_temp./max(Deployment_roomcat_save.Stove_5_temp),8, 'filled');
        ar5 = area(Deployment_roomcat_save.gmttime,double(string(Deployment_roomcat_save.Stove_5_status)=={'Cooking'})); ar5.FaceColor = [0.85,0.33,0.1]; ar5.FaceAlpha = 0.3; ar5.EdgeColor = 'k';

        s6 = scatter(Deployment_roomcat_save.gmttime,Deployment_roomcat_save.Stove_6_temp./max(Deployment_roomcat_save.Stove_6_temp),8, 'filled');
        ar6 = area(Deployment_roomcat_save.gmttime,double(string(Deployment_roomcat_save.Stove_6_status)=={'Cooking'})); ar6.FaceColor = [0.494,0.184,0.556]; ar6.FaceAlpha = 0.3; ar6.EdgeColor = 'k';

        s7 = scatter(Deployment_roomcat_save.gmttime,Deployment_roomcat_save.Stove_7_temp./max(Deployment_roomcat_save.Stove_7_temp),8, 'filled');
        ar7 = area(Deployment_roomcat_save.gmttime,double(string(Deployment_roomcat_save.Stove_7_status)=={'Cooking'})); ar7.FaceColor = [0.301,0.745,0.933]; ar7.FaceAlpha = 0.3; ar7.EdgeColor = 'k';
        
        ylabel({'Normalized stove temp:', 'T_i / T_m_a_x'})
        xlim([Deployment_roomcat_save.gmttime(1),Deployment_roomcat_save.gmttime(end)])
        ylim([0,1]);
        %Creat a lengend for the stove usage plot
        try
            
            try
            stove1 = char(Deployment_roomcat_save.Stove_1_ID(1)); stove1U = strcat(stove1,' in use');
            legend(stove1,stove1U,'Location','SouthEast');
            catch
            end
            
                try
                stove2 = char(Deployment_roomcat_save.Stove_2_ID(1)); stove2U = strcat(stove2,' in use');
                legend(stove1,stove1U,stove2,stove2U,'Location','SouthEast');
                catch
                end
                    
                    try
                    stove3 = char(Deployment_roomcat_save.Stove_3_ID(1)); stove3U = strcat(stove3,' in use');
                    legend(stove1,stove1U,stove2,stove2U,stove3,stove3U,'Location','SouthEast')
                    catch
                    end
                    
                        try
                        stove4 = char(Deployment_roomcat_save.Stove_4_ID(1)); stove4U = strcat(stove4,' in use');
                        legend(stove1,stove1U,stove2,stove2U,stove3,stove3U,stove4,stove4U,'Location','SouthEast')
                        catch
                        end
                    
                            try
                            stove5 = char(Deployment_roomcat_save.Stove_5_ID(1)); stove5U = strcat(stove5,' in use');
                            legend(stove1,stove1U,stove2,stove2U,stove3,stove3U,stove4,stove4U,stove5,stove5U,'Location','SouthEast')  
                            catch
                            end
            
                                try
                                stove6 = char(Deployment_roomcat_save.Stove_6_ID(1)); stove6U = strcat(stove6,' in use');
                                legend(stove1,stove1U,stove2,stove2U,stove3,stove3U,stove4,stove4U,stove5,stove5U,stove6,stove6U,'Location','SouthEast')
                                catch
                                end
                                    
                                    try
                                    stove7 = char(Deployment_roomcat_save.Stove_7_ID(1)); stove7U = strcat(stove7,' in use');
                                    legend(stove1,stove1U,stove2,stove2U,stove3,stove3U,stove4,stove4U,stove5,stove5U,stove6,stove6U,stove7,stove7U,'Location','SouthEast')
                                    catch
                                    end
                                        

        catch
            disp('Issue generating legend')
        end
        
       
        %legend(stove1,'Stove 1 in use',stove2,'Stove 2 in use',stove3,'Stove 3 in use', stove4,'Stove 4 in use','Location','SouthEast')
        datetick('x')
        hold off
        
        %make sure all x axes are synchronized
        linkaxes([plot1, plot2, plot3, plot4, plot5], 'x');
        plot1.XLim = [Deployment_roomcat_save.gmttime(1) Deployment_roomcat_save.gmttime(end)];

        
        
    %Save figure to postscript
    try
    print(figure(FIG),'-fillpage','-dpsc2','-append',psname)
    catch
        print(figure(FIG),'-dpsc','-append',psname)
    end

    close
       
end

