function[noncomp,comptable] = check_compliance(Deployment_roomcat_save, bname,noncomp,comptable,psname)
% by Evan Coffey

%   Ceates plots from the beacon deployments of proximity to stove and CO
%   exposure by compliance type



%Compliance 1
compliance1 = Deployment_roomcat_save.HAPEX_1_Compliance;
totcomperc1 = sum(compliance1)/numel(compliance1)*100; %compliance percentage for HAPEx 1
compliance1 = string(Deployment_roomcat_save.HAPEX_1_Compliance);
compliance1(compliance1=='0')= {'Noncompliant'};
compliance1(compliance1=='1')= {'Compliant'};
compliance1 = categorical(compliance1);

%Compliance 2
compliance2 = Deployment_roomcat_save.HAPEX_2_Compliance;
totcomperc2 = sum(compliance2)/numel(compliance2)*100; %compliance percentage for HAPEx 2
compliance2 = string(Deployment_roomcat_save.HAPEX_2_Compliance);
compliance2(compliance2=='0')= {'Noncompliant'};
compliance2(compliance2=='1')= {'Compliant'};
compliance2 = categorical(compliance2);

%Overall Compliance
compliance_overall = Deployment_roomcat_save.Overall_Compliance;
totcomperc_overall = sum(compliance_overall)/numel(compliance_overall)*100; %Overall compliance percentage
compliance_overall = string(Deployment_roomcat_save.Overall_Compliance);
compliance_overall(compliance_overall=='0')= {'Noncompliant'};
compliance_overall(compliance_overall=='1')= {'Compliant'};
compliance_overall = categorical(compliance_overall);


% c=confusionmat(Deployment_roomcat_save.HAPEX_1_Compliance,Deployment_roomcat_save.HAPEX_2_Compliance); c = sum(c); matched = c(1,1)/(sum(c)); conflicted = c(1,2)/(sum(c));
% disp('Matched

if ~isnan(totcomperc2) %if the second HAPEx has compliance data

try
    FIG = figure('PaperOrientation', 'landscape');
    subplot(3,1,1)
    histogram(compliance1)
    str1 = strcat('HAPEx 1 Compliance by minute = ', num2str(totcomperc1,3), ' percent');
    title({bname,str1},'Interpreter', 'none')
    
    subplot(3,1,2)
    hold on
    scatter(Deployment_roomcat_save.gmttime(Deployment_roomcat_save.HAPEX_1_Compliance==1),Deployment_roomcat_save.CO_exposure_ppm((Deployment_roomcat_save.HAPEX_1_Compliance==1)))
    scatter(Deployment_roomcat_save.gmttime(Deployment_roomcat_save.HAPEX_1_Compliance==0),Deployment_roomcat_save.CO_exposure_ppm((Deployment_roomcat_save.HAPEX_1_Compliance==0)))
    ar = area(Deployment_roomcat_save.gmttime,Deployment_roomcat_save.HAPEX_1_Compliance*(max(Deployment_roomcat_save.CO_exposure_ppm)));
    ar.FaceColor = 'g';
    ar.FaceAlpha = 0.2;
    ar.EdgeColor = 'none';
    datetick('x')
    xlabel('Time')
    ylabel('CO ppm')
    title('Compliant = blue with green highlight')
    hold off
    
    subplot(3,1,3)
    hold on
    scatter(Deployment_roomcat_save.gmttime(Deployment_roomcat_save.HAPEX_1_Compliance==1),Deployment_roomcat_save.PM_exposure_ugpcm((Deployment_roomcat_save.HAPEX_1_Compliance==1)))
    scatter(Deployment_roomcat_save.gmttime(Deployment_roomcat_save.HAPEX_1_Compliance==0),Deployment_roomcat_save.PM_exposure_ugpcm((Deployment_roomcat_save.HAPEX_1_Compliance==0)))
    ar = area(Deployment_roomcat_save.gmttime,Deployment_roomcat_save.HAPEX_1_Compliance*(max(Deployment_roomcat_save.PM_exposure_ugpcm)));
    ar.FaceColor = 'g';
    ar.FaceAlpha = 0.2;
    ar.EdgeColor = 'none';
    datetick('x')
    xlabel('Time')
    ylabel('PM count')
    title('Compliant = blue with green highlight')
    hold off
    

    try
    print(figure(FIG),'-fillpage','-dpsc2','-append',psname)
    catch
        print(figure(FIG),'-dpsc','-append',psname)
    end

    
    
  %Second hapex compliance
    FIG = figure('PaperOrientation', 'landscape');
    subplot(3,1,1)
    histogram(compliance2)
    str1 = strcat('HAPEx 2 Compliance by minute = ', num2str(totcomperc2,3), ' percent');
    title({bname,str1},'Interpreter', 'none')
    
    subplot(3,1,2)
    hold on
    scatter(Deployment_roomcat_save.gmttime(Deployment_roomcat_save.HAPEX_2_Compliance==1),Deployment_roomcat_save.CO_exposure_ppm((Deployment_roomcat_save.HAPEX_2_Compliance==1)))
    scatter(Deployment_roomcat_save.gmttime(Deployment_roomcat_save.HAPEX_2_Compliance==0),Deployment_roomcat_save.CO_exposure_ppm((Deployment_roomcat_save.HAPEX_2_Compliance==0)))
    ar = area(Deployment_roomcat_save.gmttime,Deployment_roomcat_save.HAPEX_2_Compliance*(max(Deployment_roomcat_save.CO_exposure_ppm)));
    ar.FaceColor = 'g';
    ar.FaceAlpha = 0.2;
    ar.EdgeColor = 'none';
    datetick('x')
    xlabel('Time')
    ylabel('CO ppm')
    title('Compliant = blue with green highlight')
    hold off
    
    subplot(3,1,3)
    hold on
    scatter(Deployment_roomcat_save.gmttime(Deployment_roomcat_save.HAPEX_2_Compliance==1),Deployment_roomcat_save.PM_exposure_ugpcm((Deployment_roomcat_save.HAPEX_2_Compliance==1)))
    scatter(Deployment_roomcat_save.gmttime(Deployment_roomcat_save.HAPEX_2_Compliance==0),Deployment_roomcat_save.PM_exposure_ugpcm((Deployment_roomcat_save.HAPEX_2_Compliance==0)))
    ar = area(Deployment_roomcat_save.gmttime,Deployment_roomcat_save.HAPEX_2_Compliance*(max(Deployment_roomcat_save.PM_exposure_ugpcm)));
    ar.FaceColor = 'g';
    ar.FaceAlpha = 0.2;
    ar.EdgeColor = 'none';
    datetick('x')
    xlabel('Time')
    ylabel('PM count')
    title('Compliant = blue with green highlight')
    hold off
    
    
    try
    print(figure(FIG),'-fillpage','-dpsc2','-append',psname)
    catch
        print(figure(FIG),'-dpsc','-append',psname)
    end

    
    
    %Overall compliance
    FIG = figure('PaperOrientation', 'landscape');
    subplot(3,1,1)
    histogram(compliance_overall)
    str1 = strcat('Overall Compliance by minute = ', num2str(totcomperc_overall,3), ' percent');
    title({bname,str1},'Interpreter', 'none')
    
    subplot(3,1,2)
    hold on
    scatter(Deployment_roomcat_save.gmttime(Deployment_roomcat_save.Overall_Compliance==1),Deployment_roomcat_save.CO_exposure_ppm((Deployment_roomcat_save.Overall_Compliance==1)))
    scatter(Deployment_roomcat_save.gmttime(Deployment_roomcat_save.Overall_Compliance==0),Deployment_roomcat_save.CO_exposure_ppm((Deployment_roomcat_save.Overall_Compliance==0)))
    ar = area(Deployment_roomcat_save.gmttime,Deployment_roomcat_save.Overall_Compliance*(max(Deployment_roomcat_save.CO_exposure_ppm)));
    ar.FaceColor = 'g';
    ar.FaceAlpha = 0.2;
    ar.EdgeColor = 'none';
    datetick('x')
    xlabel('Time')
    ylabel('CO ppm')
    title('Compliant = blue with green highlight')
    hold off
    
    subplot(3,1,3)
    hold on
    scatter(Deployment_roomcat_save.gmttime(Deployment_roomcat_save.Overall_Compliance==1),Deployment_roomcat_save.PM_exposure_ugpcm((Deployment_roomcat_save.Overall_Compliance==1)))
    scatter(Deployment_roomcat_save.gmttime(Deployment_roomcat_save.Overall_Compliance==0),Deployment_roomcat_save.PM_exposure_ugpcm((Deployment_roomcat_save.Overall_Compliance==0)))
    ar = area(Deployment_roomcat_save.gmttime,Deployment_roomcat_save.Overall_Compliance*(max(Deployment_roomcat_save.PM_exposure_ugpcm)));
    ar.FaceColor = 'g';
    ar.FaceAlpha = 0.2;
    ar.EdgeColor = 'none';
    datetick('x')
    xlabel('Time')
    ylabel('PM count')
    title('Compliant = blue with green highlight')
    hold off
    
    
    try
    print(figure(FIG),'-fillpage','-dpsc2','-append',psname)
    catch
        print(figure(FIG),'-dpsc','-append',psname)
    end
    
    
        
catch
    disp(['Issue plotting and calculating compliance for: ' char(bname)])
    disp('Check file')
end



else %there's only one compliance
     
try
     FIG = figure('PaperOrientation', 'landscape');
    subplot(3,1,1)
    histogram(compliance1)
    str1 = strcat('HAPEx 1 Compliance by minute = ', num2str(totcomperc1,3), ' percent');
    title({bname,str1},'Interpreter', 'none')
    
    subplot(3,1,2)
    hold on
    scatter(Deployment_roomcat_save.gmttime(Deployment_roomcat_save.HAPEX_1_Compliance==1),Deployment_roomcat_save.CO_exposure_ppm((Deployment_roomcat_save.HAPEX_1_Compliance==1)))
    scatter(Deployment_roomcat_save.gmttime(Deployment_roomcat_save.HAPEX_1_Compliance==0),Deployment_roomcat_save.CO_exposure_ppm((Deployment_roomcat_save.HAPEX_1_Compliance==0)))
    ar = area(Deployment_roomcat_save.gmttime,Deployment_roomcat_save.HAPEX_1_Compliance*(max(Deployment_roomcat_save.CO_exposure_ppm)));
    ar.FaceColor = 'g';
    ar.FaceAlpha = 0.2;
    ar.EdgeColor = 'none';
    datetick('x')
    xlabel('Time')
    ylabel('CO ppm')
    title('Compliant = blue with green highlight')
    hold off
    
    subplot(3,1,3)
    hold on
    scatter(Deployment_roomcat_save.gmttime(Deployment_roomcat_save.HAPEX_1_Compliance==1),Deployment_roomcat_save.PM_exposure_ugpcm((Deployment_roomcat_save.HAPEX_1_Compliance==1)))
    scatter(Deployment_roomcat_save.gmttime(Deployment_roomcat_save.HAPEX_1_Compliance==0),Deployment_roomcat_save.PM_exposure_ugpcm((Deployment_roomcat_save.HAPEX_1_Compliance==0)))
    ar = area(Deployment_roomcat_save.gmttime,Deployment_roomcat_save.HAPEX_1_Compliance*(max(Deployment_roomcat_save.PM_exposure_ugpcm)));
    ar.FaceColor = 'g';
    ar.FaceAlpha = 0.2;
    ar.EdgeColor = 'none';
    datetick('x')
    xlabel('Time')
    ylabel('PM count')
    title('Compliant = blue with green highlight')
    hold off
    
    
    try
    print(figure(FIG),'-fillpage','-dpsc2','-append',psname)
    catch
        print(figure(FIG),'-dpsc','-append',psname)
    end

     %Overall compliance
    FIG = figure('PaperOrientation', 'landscape');
    subplot(3,1,1)
    histogram(compliance_overall)
    str1 = strcat('Overall Compliance by minute = ', num2str(totcomperc_overall,3), ' percent');
    title({bname,str1},'Interpreter', 'none')
    
    subplot(3,1,2)
    hold on
    scatter(Deployment_roomcat_save.gmttime(Deployment_roomcat_save.Overall_Compliance==0),Deployment_roomcat_save.CO_exposure_ppm((Deployment_roomcat_save.Overall_Compliance==0)))
    scatter(Deployment_roomcat_save.gmttime(Deployment_roomcat_save.Overall_Compliance==1),Deployment_roomcat_save.CO_exposure_ppm((Deployment_roomcat_save.Overall_Compliance==1)))
    ar = area(Deployment_roomcat_save.gmttime,Deployment_roomcat_save.Overall_Compliance*(max(Deployment_roomcat_save.CO_exposure_ppm)));
    ar.FaceColor = 'g';
    ar.FaceAlpha = 0.2;
    ar.EdgeColor = 'none';
    datetick('x')
    xlabel('Time')
    ylabel('CO ppm')
    title('Compliant = blue with green highlight')
    hold off
    
    subplot(3,1,3)
    hold on
    scatter(Deployment_roomcat_save.gmttime(Deployment_roomcat_save.Overall_Compliance==0),Deployment_roomcat_save.PM_exposure_ugpcm((Deployment_roomcat_save.Overall_Compliance==0)))
    scatter(Deployment_roomcat_save.gmttime(Deployment_roomcat_save.Overall_Compliance==1),Deployment_roomcat_save.PM_exposure_ugpcm((Deployment_roomcat_save.Overall_Compliance==1)))
    ar = area(Deployment_roomcat_save.gmttime,Deployment_roomcat_save.Overall_Compliance*(max(Deployment_roomcat_save.PM_exposure_ugpcm)));
    ar.FaceColor = 'g';
    ar.FaceAlpha = 0.2;
    ar.EdgeColor = 'none';
    datetick('x')
    xlabel('Time')
    ylabel('PM count')
    title('Compliant = blue with green highlight')
    hold off
    
    
    try
    print(figure(FIG),'-fillpage','-dpsc2','-append',psname)
    catch
        print(figure(FIG),'-dpsc','-append',psname)
    end
    
    
catch
    disp(['Issue plotting and calculating compliance for: ' char(bname)])
    disp('Check file')
    disp('........................................')

end

end



if totcomperc1>totcomperc2
    
    if totcomperc1<10
        noncomp = 1+noncomp;
    else
        noncomp = noncomp;
    end
    
else
    
    if totcomperc2<10
    noncomp = 1+noncomp;
    else
    noncomp = noncomp;
    end
end



comptable = [comptable;comptable];


