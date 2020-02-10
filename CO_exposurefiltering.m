function [Deployment_roomcat_save_temp] = CO_exposurefiltering(Deployment_roomcat_save, bname, flagmode, Lascar_LOQ)

%Flagging and filtering of CO exposure data
% By Evan Coffey

%% Settings

%Flagging thresholds for CO
lmean_thresh = 1.25*Lascar_LOQ ; %mean values equal to or under this threshold are flagged as bad
lmedian_thresh = 10; %median values equal to or over this threshold are flagged as bad
lstd_thresh = 0.50; %std values equal to or under this threshold are flagged as bad

%% LASCARS

%% Create two new variables called CO_exposure_ppm and CO_exposure_ppm_flag that will be single value for each user

Deployment_roomcat_save.CO_exposure_ppm = NaN(height(Deployment_roomcat_save),1);
Deployment_roomcat_save.CO_exposure_ppm_flag = NaN(height(Deployment_roomcat_save),1);


%First determine if two sensors were deployed during this deployment
if ~isnan(nanmean(Deployment_roomcat_save.Calibrated_LascarCO_ppm_2)) && ~isnan(nanmean(Deployment_roomcat_save.Calibrated_LascarCO_ppm_1))
    numlascars = 2;
else if isnan(nanmean(Deployment_roomcat_save.Calibrated_LascarCO_ppm_2)) && ~isnan(nanmean(Deployment_roomcat_save.Calibrated_LascarCO_ppm_1))
    numlascars = 1;
    else numlascars = 0;
    end
    %disp('!!!No calibrated Lascar 1 data found - make sure data is up to date.')
end %lascar count loop    



%For deployments with 1 Lascar
if numlascars==1
only_lascar_ok = 1; %default option is Lascar data is good (1 for good, 0 no good)    
if flagmode==0 %manual flagging is activated
    try
        clear g
        figure()
        g(1,1) = gramm('x', Deployment_roomcat_save.Calibrated_LascarCO_ppm_1);
        g(1,2) = copy(g(1));
        g(2,1) = copy(g(1));
        g(2,2) = copy(g(1));
        %g(3,2) = copy(g(1));
        g(3,1) = gramm('x', Deployment_roomcat_save.TimeMinuteRounded, 'y', Deployment_roomcat_save.Calibrated_LascarCO_ppm_1);
        %Raw data as raster plot
        g(1,1).geom_raster();
        g(1,1).set_title('geom_raster()');
        %Histogram
        g(1,2).stat_bin('nbins',50,'geom','line','fill','all');
        g(1,2).set_title('stat_bin()');
        %Kernel smoothing density estimate
        g(2,1).stat_density();
        g(2,1).set_title('stat_density()');
        % Q-Q plot for normality
        g(2,2).stat_qq();
        g(2,2).set_title('stat_qq()');
        % Time series
        g(3,1).geom_line;
        g(3,1).set_datetick;
        g.set_title([bname],'Interpreter', 'none');
        g.draw();
        
    catch
    disp('!!!Issue with gramm plots - one lascar')
    end %try
  
    %USER INPUT REQUIRED HERE
    txt = 'y'; %default = data is good
    txt = input('Press "y" for good data and "n" for bad data: ', 's');
    
    if txt=='y'
       only_lascar_ok=1;
    else if txt=='n'
       only_lascar_ok=0;
        else
           txt = input('Input not registered: Press "y" for good data and "n" for bad data: ', 's');
            if txt=='y'
               only_lascar_ok=1;
            else
               only_lascar_ok=0;
            end
        end
    end
    close %close figure
    
else %conditional for automatic flagging

    %STATS NEED TO DETERMINE FLAG STATUS
    
    lmean = nanmean(Deployment_roomcat_save.Calibrated_LascarCO_ppm_1);
    lmedian = nanmedian(Deployment_roomcat_save.Calibrated_LascarCO_ppm_1);
    lstd = nanstd(Deployment_roomcat_save.Calibrated_LascarCO_ppm_1);
    
    %Flagging criteria
    try
        if lmean<=lmean_thresh || lmedian>lmedian_thresh || lstd<lstd_thresh %if mean is equal to LOQ OR median is larger than specified threshold OR the stdev is less than specified threshold there is most likely a problem and all Lascar data is flagged
       only_lascar_ok=0;
    else
       only_lascar_ok=1;
        end
    catch; disp('Issue occured automatically setting Lascar 1 flag')
    end
   
end %flagmode conditional

% Set the flag corresponding to user/automation
if only_lascar_ok ==0
    Deployment_roomcat_save.Calibrated_LascarCO_ppm_1_flag(:)= -999;
    disp([char(Deployment_roomcat_save.Lascar_1_Name(1)),' flagged as bad'])
else
    Deployment_roomcat_save.Calibrated_LascarCO_ppm_1_flag(:)=1;
    disp([char(Deployment_roomcat_save.Lascar_1_Name(1)),' data good'])
end %Data flagging conditional
clear lmean lmedian lstd

% Determine overall CO exposure
if only_lascar_ok==1 %lascar data one is good
   for lll=1:length(Deployment_roomcat_save.CO_exposure_ppm)
   Deployment_roomcat_save.CO_exposure_ppm(lll) = Deployment_roomcat_save.Calibrated_LascarCO_ppm_1(lll);
   end
end % overall CO exposure conditional
end %1 lascar conditional






% if two lascars
if numlascars == 2 %Two lascars deployed
    
lascar_1_ok = 1; %default option is Lascar 1 data is good (1 for good, 0 no good)    
lascar_2_ok = 1; %default option is Lascar 2 data is good (1 for good, 0 no good)    

if flagmode==0 %manual flagging is activated
    
        %Lascar 1
        try
            clear g
            figure()
            g(1,1) = gramm('x', Deployment_roomcat_save.Calibrated_LascarCO_ppm_1);
            g(1,2) = copy(g(1));
            g(2,1) = copy(g(1));
            g(2,2) = copy(g(1));
            %g(3,2) = copy(g(1));
            g(3,1) = gramm('x', Deployment_roomcat_save.TimeMinuteRounded, 'y', Deployment_roomcat_save.Calibrated_LascarCO_ppm_1);
            %Raw data as raster plot
            g(1,1).geom_raster();
            g(1,1).set_title('geom_raster()');
            %Histogram
            g(1,2).stat_bin('nbins',50,'geom','line','fill','all');
            g(1,2).set_title('stat_bin()');
            %Kernel smoothing density estimate
            g(2,1).stat_density();
            g(2,1).set_title('stat_density()');
            % Q-Q plot for normality
            g(2,2).stat_qq();
            g(2,2).set_title('stat_qq()');
            % Time series
            g(3,1).geom_line;
            g(3,1).set_datetick;
            g.set_title(['Lascar_1: ' bname],'Interpreter', 'none');
            g.draw();

        catch
        disp('!!!Issue with gramm plots - lascar one')
        end %try

        %USER INPUT REQUIRED HERE
        txt = 'y'; %default = data is good
        txt = input('Press "y" for good data and "n" for bad data: ', 's');

        if txt=='y'
           lascar_1_ok=1;
        else if txt=='n'
           lascar_1_ok=0;
            else
               txt = input('Input not registered: Press "y" for good data and "n" for bad data: ', 's');
                if txt=='y'
                   lascar_1_ok=1;
                else
                   lascar_1_ok=0;
                end
            end
        end
            close %close figure
    
        %Lascar 2
        try
            clear g
            figure()
            g(1,1) = gramm('x', Deployment_roomcat_save.Calibrated_LascarCO_ppm_2);
            g(1,2) = copy(g(1));
            g(2,1) = copy(g(1));
            g(2,2) = copy(g(1));
            %g(3,2) = copy(g(1));
            g(3,1) = gramm('x', Deployment_roomcat_save.TimeMinuteRounded, 'y', Deployment_roomcat_save.Calibrated_LascarCO_ppm_2);
            %Raw data as raster plot
            g(1,1).geom_raster();
            g(1,1).set_title('geom_raster()');
            %Histogram
            g(1,2).stat_bin('nbins',50,'geom','line','fill','all');
            g(1,2).set_title('stat_bin()');
            %Kernel smoothing density estimate
            g(2,1).stat_density();
            g(2,1).set_title('stat_density()');
            % Q-Q plot for normality
            g(2,2).stat_qq();
            g(2,2).set_title('stat_qq()');
            % Time series
            g(3,1).geom_line;
            g(3,1).set_datetick;
            g.set_title(['Lascar_2: ' bname],'Interpreter', 'none');
            g.draw();

        catch
        disp('!!!Issue with gramm plots - lascar two')
        end %try
  
        %USER INPUT REQUIRED HERE
        txt = 'y'; %default = data is good
        txt = input('Press "y" for good data and "n" for bad data: ', 's');

        if txt=='y'
           lascar_2_ok=1;
        else if txt=='n'
           lascar_2_ok=0;
            else
               txt = input('Input not registered: Press "y" for good data and "n" for bad data: ', 's');
                if txt=='y'
                   lascar_2_ok=1;
                else
                   lascar_2_ok=0;
                end
            end
        end
            close %close figure

    else %conditional for automatic flagging
    
    %STATS NEED TO DETERMINE FLAG STATUS
        try
        lmean1 = nanmean(Deployment_roomcat_save.Calibrated_LascarCO_ppm_1);
        lmedian1 = nanmedian(Deployment_roomcat_save.Calibrated_LascarCO_ppm_1);
        lstd1 = nanstd(Deployment_roomcat_save.Calibrated_LascarCO_ppm_1);
        lmean2 = nanmean(Deployment_roomcat_save.Calibrated_LascarCO_ppm_2);
        lmedian2 = nanmedian(Deployment_roomcat_save.Calibrated_LascarCO_ppm_2);
        lstd2 = nanstd(Deployment_roomcat_save.Calibrated_LascarCO_ppm_2);
        catch; disp('Issue calculating stats for automatic flagging')
        end

        %Flagging criteria lascar 1
        try
            if lmean1<=lmean_thresh || lmedian1>lmedian_thresh || lstd1<lstd_thresh %mean is less than or equal to Lascar_LOQ OR median is larger than 10 OR the stdev is less than 1 there is a problem and the data is flagged
           lascar_1_ok=0;
        else
           lascar_1_ok=1;
            end
        catch; disp('Issue occured automatically setting Lascar 1 flag')
        end

         %Flagging criteria lascar 2
        try
            if lmean2<=lmean_thresh || lmedian2>lmedian_thresh || lstd2<lstd_thresh %mean is less than or equal to Lascar_LOQ OR median is larger than 10 OR the stdev is less than 1 there is a problem and the data is flagged
           lascar_2_ok=0;
        else
           lascar_2_ok=1;
            end
        catch; disp('Issue occured automatically setting Lascar 2 flag')
        end

end %flagmode conditional

        % Set the flag corresponding to user/automation
        if lascar_1_ok ==0
            Deployment_roomcat_save.Calibrated_LascarCO_ppm_1_flag(:)= -999;
            disp([char(Deployment_roomcat_save.Lascar_1_Name(1)),' flagged as bad'])
        else
            Deployment_roomcat_save.Calibrated_LascarCO_ppm_1_flag(:)=1;
            disp([char(Deployment_roomcat_save.Lascar_1_Name(1)),' data good'])
        end %Data flagging conditional

        if lascar_2_ok ==0
            Deployment_roomcat_save.Calibrated_LascarCO_ppm_2_flag(:)= -999;
            disp([char(Deployment_roomcat_save.Lascar_2_Name(1)),' flagged as bad'])
        else
            Deployment_roomcat_save.Calibrated_LascarCO_ppm_2_flag(:)=1;
            disp([char(Deployment_roomcat_save.Lascar_2_Name(1)),' data good'])
        end %Data flagging conditional

        
% Determine overall CO exposure
if lascar_1_ok==1 && lascar_2_ok==1 %both lascar data are good
    for lll=1:length(Deployment_roomcat_save.CO_exposure_ppm)
    Deployment_roomcat_save.CO_exposure_ppm(lll) = ((Deployment_roomcat_save.Calibrated_LascarCO_ppm_1(lll)+Deployment_roomcat_save.Calibrated_LascarCO_ppm_2(lll))/2);
    end
else if lascar_1_ok==1 && lascar_2_ok==0 %only lascar 1 is good
        for lll=1:length(Deployment_roomcat_save.CO_exposure_ppm)
        Deployment_roomcat_save.CO_exposure_ppm(lll) = Deployment_roomcat_save.Calibrated_LascarCO_ppm_1(lll);
        end
    else %only lascar 2 is good
        for lll=1:length(Deployment_roomcat_save.CO_exposure_ppm)
        Deployment_roomcat_save.CO_exposure_ppm(lll) = Deployment_roomcat_save.Calibrated_LascarCO_ppm_2(lll);
        end
    end
end % overall CO exposure conditonal
     
clear lmean1 lmedian1 lstd1 lmean2 lmedian2 lstd2
end % two lascars conditional
    

if numlascars==0
    disp('No lascar data to flag')
end
    
%Save the new temp file with flagging
Deployment_roomcat_save_temp = Deployment_roomcat_save;


disp('........................................')
end %function end












