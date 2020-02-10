try
                    try
                    FIG = figure('PaperOrientation', 'landscape');                    
                    
                    sgtitle({bname, ['Percentage of ', num2str(length(Deployment_roomcat_save.Activity)),' total time points by activity during 48hr deployment']},'Interpreter', 'none')
                    subplot(2,2,1)
                    pie(Deployment_roomcat_save.Activity)
                    title('Overall activity')
                    subplot(2,2,2)
                    pie(Deployment_roomcat_save.CookingCat)
                    title('Cooking status')
                    subplot(2,2,3)
                    pie(Deployment_roomcat_save.LocationCat)
                    title('Location status')
                    subplot(2,2,4)
                    pie(Deployment_roomcat_save.ProximityCat)
                    title('Proximity to nearest kitchen')
                            try
                            print(figure(FIG),'-fillpage','-dpsc2','-append',psname)
                            catch
                                print(figure(FIG),'-dpsc','-append',psname)
                            end
                    catch
                    end
                    %pause(1);
                    close
                    
                    
                    
                    
                    try
                    FIG = figure('PaperOrientation', 'landscape');                    
                    
                    sgtitle({bname, ['Percentage of ', num2str(length(Deployment_roomcat_save.Activity(Deployment_roomcat_save.Overall_Compliance>=0.5))),' compliant time points by activity during 48hr deployment']},'Interpreter', 'none')
                    subplot(2,2,1)
                    pie(Deployment_roomcat_save.Activity(Deployment_roomcat_save.Overall_Compliance>=0.5))
                    title('Overall activity')
                    subplot(2,2,2)
                    pie(Deployment_roomcat_save.CookingCat(Deployment_roomcat_save.Overall_Compliance>=0.5))
                    title('Cooking status')
                    subplot(2,2,3)
                    pie(Deployment_roomcat_save.LocationCat(Deployment_roomcat_save.Overall_Compliance>=0.5))
                    title('Location status')
                    subplot(2,2,4)
                    pie(Deployment_roomcat_save.ProximityCat(Deployment_roomcat_save.Overall_Compliance>=0.5))
                    title('Proximity to nearest kitchen')
                    
                            try
                            print(figure(FIG),'-fillpage','-dpsc2','-append',psname)
                            catch
                                print(figure(FIG),'-dpsc','-append',psname)
                            end
                    
                    catch
                    end
                    %pause(1);
                    close
                    
                    
                    
                    try
                    FIG = figure('PaperOrientation', 'landscape');     
                    boxplot(Deployment_roomcat_save.CO_exposure_ppm, Deployment_roomcat_save.Activity, 'LabelOrientation','inline')
                    title({'All CO exposure by Activity for: ', bname}, 'Interpreter', 'none')
                    ylabel('CO ppm')
                    set(gca, 'YScale', 'log')

                            try
                            print(figure(FIG),'-fillpage','-dpsc2','-append',psname)
                            catch
                                print(figure(FIG),'-dpsc','-append',psname)
                            end

                    catch
                    end
                    %pause(1);
                    close
                    
                    
                    
                    try
                    FIG = figure('PaperOrientation', 'landscape');     
                    boxplot(Deployment_roomcat_save.CO_exposure_ppm(Deployment_roomcat_save.Overall_Compliance>=0.5), Deployment_roomcat_save.Activity(Deployment_roomcat_save.Overall_Compliance>=0.5), 'LabelOrientation','inline')
                    title({'Compliant CO exposure by Activity for: ', bname}, 'Interpreter', 'none')
                    ylabel('CO ppm')
                    set(gca, 'YScale', 'log')

                            try
                            print(figure(FIG),'-fillpage','-dpsc2','-append',psname)
                            catch
                                print(figure(FIG),'-dpsc','-append',psname)
                            end
                    
                    catch
                    end
                    %pause(1);
                    close
                    
                    
                    % box = findobj(gca,'tag','Box')
                    % for i=1:numel(box)
                    % prctls(i,1:2) = unique(box(i).YData);
                    % end
                    % prct25 = prctls(:,1)
                    % prct75 = prctls(:,2)


                    % [y,x,g] = iosr.statistics.tab2box(Cylinders,MPG,when);
                    % 
                    % figure;
                    % [y,~,g] = iosr.statistics.tab2box([],Deployment_roomcat_save.CO_exposure_ppm,char(Deployment_roomcat_save.Activity));
                    % 
                    % iosr.statistics.boxPlot(Deployment_roomcat_save.Activity,Deployment_roomcat_save.CO_exposure_ppm,...
                    %   'medianColor','k',...
                    %   'symbolMarker',{'+','o','d'},...
                    %   'boxcolor','auto',...
                    %   'sampleSize',true,...
                    %   'scaleWidth',true);
                    % box on

                    try
                    FIG = figure('PaperOrientation', 'landscape');                    
                    boxplot(Deployment_roomcat_save.PM_exposure_ugpcm,Deployment_roomcat_save.Activity, 'LabelOrientation','inline')
                    title({'All PM exposure by Activity for: ', bname}, 'Interpreter', 'none')
                    ylabel('PM ug/m^3')
                    set(gca, 'YScale', 'log')

                            try
                            print(figure(FIG),'-fillpage','-dpsc2','-append',psname)
                            catch
                                print(figure(FIG),'-dpsc','-append',psname)
                            end
                    
                    catch
                    end
                    %pause(1);
                    close
                    
                    
                    try
                    FIG = figure('PaperOrientation', 'landscape');                    
                    boxplot(Deployment_roomcat_save.PM_exposure_ugpcm(Deployment_roomcat_save.Overall_Compliance>=0.5),Deployment_roomcat_save.Activity(Deployment_roomcat_save.Overall_Compliance>=0.5), 'LabelOrientation','inline')
                    title({'Compliant PM exposure by Activity for: ', bname}, 'Interpreter', 'none')
                    ylabel('PM ug/m^3')
                    set(gca, 'YScale', 'log')

                            try
                            print(figure(FIG),'-fillpage','-dpsc2','-append',psname)
                            catch
                                print(figure(FIG),'-dpsc','-append',psname)
                            end
                    
                    catch
                    end
                    %pause(1);
                    close
                    
                    
                    try
                    FIG = figure('PaperOrientation', 'landscape');                    
                    boxplot(Deployment_roomcat_save.Micro_CO_ppm, Deployment_roomcat_save.CookingCat, 'LabelOrientation','inline')
                    title({'CO ppm in kitchen area by Activity for: ', bname}, 'Interpreter', 'none')
                    ylabel('PM ug/m^3')
                    set(gca, 'YScale', 'log')
                    
                            try
                            print(figure(FIG),'-fillpage','-dpsc2','-append',psname)
                            catch
                                print(figure(FIG),'-dpsc','-append',psname)
                            end

                    catch
                    end
                    %pause(1);
                    close
                    
                    
                    
                    try
                    FIG = figure('PaperOrientation', 'landscape');                    
                    subplot(2,1,1)
                    boxplot(Deployment_roomcat_save.Micro_BC_HAPEX_1, Deployment_roomcat_save.CookingCat, 'LabelOrientation','inline')
                    title({'Kitchen PM sensor 1 by Activity for: ', bname}, 'Interpreter', 'none')
                    ylabel('PM ug/m^3 or raw signal')
                    set(gca, 'YScale', 'log')
                    
                    subplot(2,1,2)
                    boxplot(Deployment_roomcat_save.Micro_BC_HAPEX_2, Deployment_roomcat_save.CookingCat, 'LabelOrientation','inline')
                    title({'Kitchen PM sensor 2 by Activity for: ', bname}, 'Interpreter', 'none')
                    ylabel('PM ug/m^3 or raw signal')
                    set(gca, 'YScale', 'log')
                    
                            try
                            print(figure(FIG),'-fillpage','-dpsc2','-append',psname)
                            catch
                                print(figure(FIG),'-dpsc','-append',psname)
                            end
                    
                    catch
                    end
                    %pause(1);
                    close
                    
                    
                    disp('Images saved to pdf report...')
                    
catch
disp('Issue saving images for this deployment...')
end
