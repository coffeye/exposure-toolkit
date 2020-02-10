function [Deployment_roomcat_save_temp, num_out_of_range] = PM_exposurefiltering(Deployment_roomcat_save, bname, flagmode, particle_coefficient, HAPEx_LOQ, num_out_of_range)

%Flagging and filtering of CO exposure data
% By Evan Coffey

%% Settings
defaultPC=1; %temporary setting to just use the default PC for all HAPEx data


load('PC_model')
%Flagging threshold for PM
hmean_thresh = 1.15*HAPEx_LOQ; %mean values equal to or under this threshold are flagged as bad
hmedian_thresh = 125; %median values equal to or over this threshold are flagged as bad
hstd_thresh = 10; %std values equal to or under this threshold are flagged as bad
PC = particle_coefficient; %This is the default PC value stipulated in the main code


%%Create a two new variables called PM_exposure_ugpcm and PM_exposure_ugpcm_flag that will be single value for each user
Deployment_roomcat_save.HAPEx_1_PC = NaN(height(Deployment_roomcat_save),1);
Deployment_roomcat_save.HAPEx_2_PC = NaN(height(Deployment_roomcat_save),1);
Deployment_roomcat_save.PM_exposure_ugpcm = NaN(height(Deployment_roomcat_save),1);
Deployment_roomcat_save.PM_exposure_ugpcm_flag = NaN(height(Deployment_roomcat_save),1);

if ~defaultPC
        try
        %First creat a timetable variable with both HAPEx signals
        tempHAP_1table = Deployment_roomcat_save(:,[61,75,76,17]);%for HAP1
        tempHAP_2table = Deployment_roomcat_save(:,[66,75,76,17]);%for HAP2

        tempHAP_1table.TimeMinuteRounded = datetime(tempHAP_1table.TimeMinuteRounded,'ConvertFrom','datenum');
        tempHAP_2table.TimeMinuteRounded = datetime(tempHAP_2table.TimeMinuteRounded,'ConvertFrom','datenum');

        HAP_1table = table2timetable(tempHAP_1table,'RowTimes', 'TimeMinuteRounded');
        HAP_2table = table2timetable(tempHAP_2table,'RowTimes', 'TimeMinuteRounded');

        HAP_1table.var_HAPEx(:) = nanvar(Deployment_roomcat_save.(61));
        HAP_1table.mean_CO(:) = nanvar(Deployment_roomcat_save.(77));

        HAP_2table.var_HAPEx(:) = nanvar(Deployment_roomcat_save.(66));
        HAP_2table.mean_CO(:) = nanvar(Deployment_roomcat_save.(77));

        HAP_1table = timetable2table(HAP_1table);
        HAP_2table = timetable2table(HAP_2table);

        HAP_1table.Properties.VariableNames{4} = 'season'; %rename the season variable to match the model parameters
        HAP_2table.Properties.VariableNames{4} = 'season'; %rename the season variable to match the model parameters

        %deploy the PC_model to estimate PC for each HAPEx monitor here
        [HAP_1PC, HAP1_CI95] = predict(PC_model,HAP_1table,'Alpha',0.05,'Prediction','curve'); %PC estimated for each HAPEx as well as a 95%CI for the estimate
        [HAP_2PC,HAP2_CI95]= predict(PC_model,HAP_2table,'Alpha',0.05,'Prediction','curve'); %PC estimated for each HAPEx as well as a 95%CI for the estimate

        disp(['Modeled PC for HAPEx 1 is: ', num2str(HAP_1PC(1))]);
        disp(['Modeled PC for HAPEx 2 is: ', num2str(HAP_2PC(1))]);

        catch
            disp(['Issue encountered applying the PC model to the PM data. Check file: ', bname])
        end


        %A few filtering conditionals for the individual PC estimates

        if HAP_1PC(1)<0.056 %minimum PC in microE sampling
            HAP_1PC(:)= 0.056; num_out_of_range = num_out_of_range +1;
        else
            if HAP_1PC(1)>0.93 %maximum PC in microE sampling
                HAP_1PC(:)= 0.93; num_out_of_range = num_out_of_range +1;
            else
                if isnan(HAP_1PC(1))
                    HAP_1PC(:)= particle_coefficient; %Use default PC when model inputs are missing (e.g., mean_CO)
                end
            end
        end


        if HAP_2PC(1)<0.056 %minimum PC in microE sampling
            HAP_2PC(:) = 0.056; num_out_of_range = num_out_of_range +1;
        else
            if HAP_2PC(1)>0.93 %maximum PC in microE sampling
                HAP_2PC(:)= 0.93; num_out_of_range = num_out_of_range +1;
            else
                if isnan(HAP_2PC(1))
                    HAP_2PC(:)= particle_coefficient; %Use default PC when model inputs are missing (e.g., mean_CO)
                end
            end
        end

else
    HAP_1PC(:)= ones(height(Deployment_roomcat_save),1)*particle_coefficient;
    HAP_2PC(:)= ones(height(Deployment_roomcat_save),1)*particle_coefficient;
    disp(['Using default PC of ', num2str(HAP_2PC(1)), ' for both HAPEx']);
end



%% HAPEx

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
disp(['Using a PC of: ', num2str(HAP_1PC(1),3),' for HAPEx 1']);
    for lll=1:length(Deployment_roomcat_save.PM_exposure_ugpcm)
        if ~nummicropems==1 %MicroPEMs was not used
            Deployment_roomcat_save.PM_exposure_ugpcm(lll) = (Deployment_roomcat_save.BC_HAPEX_1(lll)/HAP_1PC(lll)); %we want to divide by the PC
            
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
    disp(['Using a PC of: ', num2str(HAP_2PC(1),3),' for HAPEx 2']);
    for lll=1:length(Deployment_roomcat_save.PM_exposure_ugpcm)
    Deployment_roomcat_save.PM_exposure_ugpcm(lll) = (Deployment_roomcat_save.BC_HAPEX_2(lll)/HAP_2PC(lll)); %we want to divide by PC
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
    disp(['Using a PC of: ', num2str(HAP_1PC(1),3),' for HAPEx 1']);
    disp(['Using a PC of: ', num2str(HAP_2PC(1),3),' for HAPEx 2']);
    for lll=1:length(Deployment_roomcat_save.PM_exposure_ugpcm)
    Deployment_roomcat_save.PM_exposure_ugpcm(lll) = ((Deployment_roomcat_save.BC_HAPEX_1(lll)/HAP_1PC(lll)+Deployment_roomcat_save.BC_HAPEX_2(lll)/HAP_2PC(lll))/2); %we want to divide by PC first, then average
    end
else
    if hapex_1_ok==1 && hapex_2_ok==0 %only hapex 1 is good
     disp(['Using a PC of: ', num2str(HAP_1PC(1),3),' for HAPEx 1']);
     for lll=1:length(Deployment_roomcat_save.PM_exposure_ugpcm)
     Deployment_roomcat_save.PM_exposure_ugpcm(lll) = Deployment_roomcat_save.BC_HAPEX_1(lll)/HAP_1PC(lll); %we want to divide by PC
     end
     else %only hapex 2 is good
        disp(['Using a PC of: ', num2str(HAP_2PC(1),3),' for HAPEx 2']);
        for lll=1:length(Deployment_roomcat_save.PM_exposure_ugpcm)
        Deployment_roomcat_save.PM_exposure_ugpcm(lll) = Deployment_roomcat_save.BC_HAPEX_2(lll)/HAP_2PC(lll); %we want to divide by PC
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












