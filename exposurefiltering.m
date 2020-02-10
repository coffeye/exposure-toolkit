function [Deployment_roomcat_save_temp] = CO_exposurefiltering(Deployment_roomcat_save, bname, flagmode, particle_coefficient, Lascar_LOQ, HAPEx_LOQ)

%Flagging and filtering of CO exposure data
% By Evan Coffey

%% Settings

%Flagging thresholds for CO and PM
lmean_thresh = 1.15*Lascar_LOQ ; %mean values equal to or under this threshold are flagged as bad
lmedian_thresh = 10; %median values equal to or over this threshold are flagged as bad
lstd_thresh = 0.66; %std values equal to or under this threshold are flagged as bad

hmean_thresh = 1.15*HAPEx_LOQ; %mean values equal to or under this threshold are flagged as bad
hmedian_thresh = 125; %median values equal to or over this threshold are flagged as bad
hstd_thresh = 10; %std values equal to or under this threshold are flagged as bad

%% LASCARS FIRST

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
    


%% HAPEx NEXT


% %First creat a timetable variable with both HAPEx signals
% tempHAPtable = Deployment_roomcat_save(:,[68,73,82,17]);
% tempHAPtable.TimeMinuteRounded = datetime(tempHAPtable.TimeMinuteRounded,'ConvertFrom','datenum');
% HAPtable = table2timetable(tempHAPtable,'RowTimes', 'TimeMinuteRounded');
% 
% %Add urban/rural and season classifications
% 
% %First update the default PC with a deployment-specific PC
% PC = particle_coefficient; %Particle coefficient constant passed on
% 
% hap1mean = nanmean(HAPtable.(1));
% hap2mean = nanmean(HAPtable.(2));
% 
% %Determine season and urban or rural
% try 
%     %urban/rural
%     if contains(Deployment_roomcat_save.HouseholdID(1),'CA') || contains(Deployment_roomcat_save.UserID(1),'BM')
%         hapex_location = 'Urban';
%     else
%         hapex_location = 'Rural';
%     end
%     %season
%     whatweek = week(datetime(Deployment_roomcat_save.TimeMinuteRounded(1), 'ConvertFrom', 'datenum'));
%     if whatweek>14 && whatweek<23
%         hapex_season = 'Light Rainy'; %April to June also known as light_rainy
%     else
%         if whatweek>=23 && whatweek<40
%             hapex_season = 'Heavy Rainy'; %June to october also known as heavy rainy
%         else
%             if whatweek>=44 || whatweek<7
%                 hapex_season = 'Harmattan_bushburning'; % November to mid Feb.
%             else
%                 if whatweek>=7 && whatweek<=14
%                     hapex_season = 'Dry'; %Mid Feb to April also known as hot and dry
%                 else
%                     hapex_season = 'Transition';
%                 end
%             end
%         end
%     end
%     
%     if strcmpi(hapex_location,'Rural') && strcmpi(hapex_season,'Dry') %reference case    
%     PC_1_temp = 0.11176 + hap1mean*0.00656;
%     PC_2_temp = 0.11176 + hap2mean*0.00656;
%     else
%         if strcmpi(hapex_location,'Rural') && strcmpi(hapex_season,'Dry') %reference case
%         PC_1_temp = 0.11176 + hap1mean*0.00656;
%         PC_2_temp = 0.11176 + hap2mean*0.00656;
%         end
%     end
% catch
%   
%     
%     disp('!!!Issue encountered classifying season!!!') 
% end
% 
% disp(['Using HAPEx particle coefficient of ', num2str(PC)])
% 



%%Create a two new variables called PM_exposure_ugpcm and PM_exposure_ugpcm_flag that will be single value for each user

Deployment_roomcat_save.PM_exposure_ugpcm = NaN(height(Deployment_roomcat_save),1);
Deployment_roomcat_save.PM_exposure_ugpcm_flag = NaN(height(Deployment_roomcat_save),1);

%First determine if two sensors were deployed during this deployment
if ~isnan(nanmean(Deployment_roomcat_save.BC_HAPEX_2)) && ~isnan(nanmean(Deployment_roomcat_save.BC_HAPEX_1)) %Both logged
    numhapex = 2; nummicropems = 0;
else
    if isnan(nanmean(Deployment_roomcat_save.BC_HAPEX_2)) && ~isnan(nanmean(Deployment_roomcat_save.BC_HAPEX_1)) %only HAP 1 logged
    numhapex = 1; nummicropems = 0;
    else
        if ~isnan(nanmean(Deployment_roomcat_save.BC_HAPEX_2)) && isnan(nanmean(Deployment_roomcat_save.BC_HAPEX_1))  %only HAP 2 logged
         numhapex=3; nummicropems = 0;
        else
            numhapex = 0; nummicropems = 0;
        end
    end
end %logging hapex count loop    

%Next determine if one of those sensors was a MicroPEms monitor
if nansum(Deployment_roomcat_save.BC_HAPEX_1_flag==-777)>0
numhapex = 0; nummicropems = 1;
disp('MicroPEMs deployed - not peforming any PM filtering')
end


%For deployments where only Hapex 1 logged
if numhapex==1
only_hapex_ok = 1; %default option is Hapex data is good (1 for good, 0 no good)

if flagmode==0 %manual flagging is activated
    try
        clear g
        figure()
        g(1,1) = gramm('x', Deployment_roomcat_save.BC_HAPEX_1);
        g(1,2) = copy(g(1));
        g(2,1) = copy(g(1));
        g(2,2) = copy(g(1));
        %g(3,2) = copy(g(1));
        g(3,1) = gramm('x', Deployment_roomcat_save.TimeMinuteRounded, 'y', Deployment_roomcat_save.BC_HAPEX_1);
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
    disp('!!!Issue with gramm plots - one hapex')
    end %try

  
    %USER INPUT REQUIRED HERE
    txt = 'y'; %default = data is good
    txt = input('Press "y" for good data and "n" for bad data: ', 's');
    
    if txt=='y'
       only_hapex_ok=1;
    else if txt=='n'
       only_hapex_ok=0;
        else
           txt = input('Input not registered: Press "y" for good data and "n" for bad data: ', 's');
            if txt=='y'
               only_hapex_ok=1;
            else
               only_hapex_ok=0;
            end
        end
    end
    close %close figure
    
else %conditional for automatic flagging

    %STATS NEED TO DETERMINE FLAG STATUS
    hmean = nanmean(Deployment_roomcat_save.BC_HAPEX_1);
    hmedian = nanmedian(Deployment_roomcat_save.BC_HAPEX_1);
    hstd = nanstd(Deployment_roomcat_save.BC_HAPEX_1);

    %Flagging criteria
    try
        if hmean<=hmean_thresh || hmedian>hmedian_thresh || hstd<hstd_thresh %mean is less than por equal to specified value OR median is larger than specified value OR the stdev is less than specified value there is a problem and the data is flagged
       only_hapex_ok=0;
    else
       only_hapex_ok=1;
        end
    catch; disp('Issue occured automatically setting one HAPEx flag')
    end
   
end %flagmode conditional

% Set the flag corresponding to user/automation
if only_hapex_ok ==0
    Deployment_roomcat_save.BC_HAPEX_1_flag(:)= -999;
   disp(strcat('Hapex ', {' '},Deployment_roomcat_save.HAPEX_1_Name(1),' flagged as bad'))
else
    if ~nummicropems==1
    Deployment_roomcat_save.BC_HAPEX_1_flag(:)=1;
   disp(strcat('Hapex ', {' '},Deployment_roomcat_save.HAPEX_1_Name(1),' data good'))
    else
        disp('MicroPEMs data used as overall PM exposure')
    end
end %Data flagging conditional
clear hmean hmedian hstd

% Determine overall PM exposure
if only_hapex_ok ==1 %hapex data from one unit is good
    for lll=1:length(Deployment_roomcat_save.PM_exposure_ugpcm)
        if ~nummicropems==1 %MicroPEMs was not used
            Deployment_roomcat_save.PM_exposure_ugpcm(lll) = (Deployment_roomcat_save.BC_HAPEX_1(lll)/PC); %we want to divide by the PC
        end
    end
end % overall PM exposure conditional

end %1 hapex conditional




%For deployments where only Hapex 2 logged
if numhapex==3
only_hapex_ok = 1; %default option is Hapex data is good (1 for good, 0 no good)

if flagmode==0 %manual flagging is activated
    try
        clear g
        figure()
        g(1,1) = gramm('x', Deployment_roomcat_save.BC_HAPEX_2);
        g(1,2) = copy(g(1));
        g(2,1) = copy(g(1));
        g(2,2) = copy(g(1));
        %g(3,2) = copy(g(1));
        g(3,1) = gramm('x', Deployment_roomcat_save.TimeMinuteRounded, 'y', Deployment_roomcat_save.BC_HAPEX_2);
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
    disp('!!!Issue with gramm plots - one hapex')
    end %try

  
    %USER INPUT REQUIRED HERE
    txt = 'y'; %default = data is good
    txt = input('Press "y" for good data and "n" for bad data: ', 's');
    
    if txt=='y'
       only_hapex_ok=1;
    else if txt=='n'
       only_hapex_ok=0;
        else
           txt = input('Input not registered: Press "y" for good data and "n" for bad data: ', 's');
            if txt=='y'
               only_hapex_ok=1;
            else
               only_hapex_ok=0;
            end
        end
    end
    close %close figure
    
else %conditional for automatic flagging

    %STATS NEED TO DETERMINE FLAG STATUS
    hmean = nanmean(Deployment_roomcat_save.BC_HAPEX_2);
    hmedian = nanmedian(Deployment_roomcat_save.BC_HAPEX_2);
    hstd = nanstd(Deployment_roomcat_save.BC_HAPEX_2);
    
    %Flagging criteria
    try
        if hmean<=hmean_thresh || hmedian>hmedian_thresh || hstd<hstd_thresh %mean is less than por equal to specified value OR median is larger than specified value OR the stdev is less than specified value there is a problem
       only_hapex_ok=0;
    else
       only_hapex_ok=1;
        end
    catch; disp('Issue occured automatically setting one HAPEx flag')
    end
   
end %flagmode conditional

% Set the flag corresponding to user/automation
if only_hapex_ok ==0
    Deployment_roomcat_save.BC_HAPEX_2_flag(:)= -999;
   disp(strcat('Hapex ', {' '},Deployment_roomcat_save.HAPEX_1_Name(1),' flagged as bad'))
else
    Deployment_roomcat_save.BC_HAPEX_2_flag(:)=1;
   disp(strcat('Hapex ', {' '},Deployment_roomcat_save.HAPEX_1_Name(1),' data good'))
end %Data flagging conditional
clear hmean hmedian hstd


 
% Determine overall PM exposure
if only_hapex_ok ==1 %hapex data from one unit is good  
    for lll=1:length(Deployment_roomcat_save.PM_exposure_ugpcm)
    Deployment_roomcat_save.PM_exposure_ugpcm(lll) = (Deployment_roomcat_save.BC_HAPEX_2(lll)/PC); %we want to divide by PC
    end
end % overall PM exposure conditional

end %hapex 2 only conditional


% if two hapex logged
if numhapex == 2 %Two Hapex deployed
    
hapex_1_ok = 1; %default option is hapex data is good (1 for good, 0 no good)    
hapex_2_ok = 1; %default option is hapex data is good (1 for good, 0 no good)    


if flagmode==0 %manual flagging is activated
    
        %Hapex 1
        try
            clear g
            figure()
            g(1,1) = gramm('x', Deployment_roomcat_save.BC_HAPEX_1);
            g(1,2) = copy(g(1));
            g(2,1) = copy(g(1));
            g(2,2) = copy(g(1));
            %g(3,2) = copy(g(1));
            g(3,1) = gramm('x', Deployment_roomcat_save.TimeMinuteRounded, 'y', Deployment_roomcat_save.BC_HAPEX_1);
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
            g.set_title(['Hapex_1: ' bname],'Interpreter', 'none');
            g.draw();

        catch
        disp('!!!Issue with gramm plots - hapex one')
        end %try

  
        %USER INPUT REQUIRED HERE
        txt = 'y'; %default = data is good
        txt = input('Press "y" for good data and "n" for bad data: ', 's');

        if txt=='y'
           hapex_1_ok=1;
        else if txt=='n'
           hapex_1_ok=0;
            else
               txt = input('Input not registered: Press "y" for good data and "n" for bad data: ', 's');
                if txt=='y'
                   hapex_1_ok=1;
                else
                   hapex_1_ok=0;
                end
            end
        end
            close %close figure
    
        %Hapex 2
        try
            clear g
            figure()
            g(1,1) = gramm('x', Deployment_roomcat_save.BC_HAPEX_2);
            g(1,2) = copy(g(1));
            g(2,1) = copy(g(1));
            g(2,2) = copy(g(1));
            %g(3,2) = copy(g(1));
            g(3,1) = gramm('x', Deployment_roomcat_save.TimeMinuteRounded, 'y', Deployment_roomcat_save.BC_HAPEX_2);
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
            g.set_title(['Hapex_2: ' bname],'Interpreter', 'none');
            g.draw();

        catch
        disp('!!!Issue with gramm plots - hapex two')
        end %try
  
        %USER INPUT REQUIRED HERE
        txt = 'y'; %default = data is good
        txt = input('Press "y" for good data and "n" for bad data: ', 's');

        if txt=='y'
           hapex_2_ok=1;
        else if txt=='n'
           hapex_2_ok=0;
            else
               txt = input('Input not registered: Press "y" for good data and "n" for bad data: ', 's');
                if txt=='y'
                   hapex_2_ok=1;
                else
                   hapex_2_ok=0;
                end
            end
        end
            close %close figure

    else %conditional for automatic flagging
    
    %STATS NEED TO DETERMINE FLAG STATUS
        try
        hmean1 = nanmean(Deployment_roomcat_save.BC_HAPEX_1);
        hmedian1 = nanmedian(Deployment_roomcat_save.BC_HAPEX_1);
        hstd1 = nanstd(Deployment_roomcat_save.BC_HAPEX_1);
        hmean2 = nanmean(Deployment_roomcat_save.BC_HAPEX_2);
        hmedian2 = nanmedian(Deployment_roomcat_save.BC_HAPEX_2);
        hstd2 = nanstd(Deployment_roomcat_save.BC_HAPEX_2);
        catch; disp('Issue calculating stats for automatic flagging')
        end

        %Flagging criteria hapex 1
        try
            if hmean1<=hmean_thresh || hmedian1>hmedian_thresh || hstd1<hstd_thresh %mean is less than por equal to specified value OR median is larger than specified value OR the stdev is less than specified value there is a problem
           hapex_1_ok=0;
        else
           hapex_1_ok=1;
            end
        catch; disp('Issue occured automatically setting HAPEx 1 flag')
        end

         %Flagging criteria hapex 2
        try
            if hmean2<=hmean_thresh || hmedian2>hmedian_thresh || hstd2<hstd_thresh %mean is less than por equal to specified value OR median is larger than specified value OR the stdev is less than specified value there is a problem
           hapex_2_ok=0;
        else
           hapex_2_ok=1;
            end
        catch; disp('Issue occured automatically setting HAPEx 2 flag')
        end

end %flagmode conditional

        % Set the flag corresponding to user/automation
        if hapex_1_ok ==0
            Deployment_roomcat_save.BC_HAPEX_1_flag(:)= -999;
            disp(strcat('Hapex ', {' '},Deployment_roomcat_save.HAPEX_1_Name(1),' flagged as bad'))
        else
            Deployment_roomcat_save.BC_HAPEX_1_flag(:)=1;
             disp(strcat('Hapex ', {' '},Deployment_roomcat_save.HAPEX_1_Name(1),' data good'))
        end %Data flagging conditional

        if hapex_2_ok ==0
            Deployment_roomcat_save.BC_HAPEX_2_flag(:)= -999;
            disp(strcat('Hapex ', {' '},Deployment_roomcat_save.HAPEX_2_Name(1),' flagged as bad'))
        else
            Deployment_roomcat_save.BC_HAPEX_2_flag(:)=1;
            disp(strcat('Hapex ', {' '},Deployment_roomcat_save.HAPEX_2_Name(1),' data good'))
        end %Data flagging conditional

clear hmean1 hmedian1 hstd1 hmean2 hmedian2 hstd2




% Determine overall PM exposure
if hapex_1_ok==1 && hapex_2_ok==1 %both hapex data are good
    for lll=1:length(Deployment_roomcat_save.PM_exposure_ugpcm)
    Deployment_roomcat_save.PM_exposure_ugpcm(lll) = ((Deployment_roomcat_save.BC_HAPEX_1(lll)/PC+Deployment_roomcat_save.BC_HAPEX_2(lll)/PC)/2); %we want to divide by PC first then average
    end
else if hapex_1_ok==1 && hapex_2_ok==0 %only hapex 1 is good
    for lll=1:length(Deployment_roomcat_save.PM_exposure_ugpcm)
    Deployment_roomcat_save.PM_exposure_ugpcm(lll) = Deployment_roomcat_save.BC_HAPEX_1(lll)/PC; %we want to divide by PC
    end
    else %only hapex 2 is good
        for lll=1:length(Deployment_roomcat_save.PM_exposure_ugpcm)
        Deployment_roomcat_save.PM_exposure_ugpcm(lll) = Deployment_roomcat_save.BC_HAPEX_2(lll)/PC; %we want to divide by PC
        end
    end
end % overall PM exposure conditonal
end % two hapex conditional
    

%% If MicroPEMs was deployed

if numhapex==0 && nummicropems==1 
   %MicroPEMs was used
    try
        for lll=1:length(Deployment_roomcat_save.PM_exposure_ugpcm)
            Deployment_roomcat_save.PM_exposure_ugpcm(lll) = (Deployment_roomcat_save.BC_HAPEX_1(lll)); %Can add some sort of (scaling)correction to the MicroPEM/ECM from gravimetric filter weighing
        end
        disp('using MicroPEMs data as overall PM exposure')
    catch
        disp('!!!Issue encountered saving MicroPEMs data as overal PM exposure - Check file!!!')
    end
else
    if numhapex==1 || numhapex==2 ||numhapex==3
    else
        disp('No HAPEx or MicroPEMS data to flag')
    end
end
    

%Save the new temp file with flagging
Deployment_roomcat_save_temp = Deployment_roomcat_save;


disp('........................................')
end %function end












