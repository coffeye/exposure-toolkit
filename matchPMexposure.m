function [Deployment_roomcat_save_temp, nomatch, class_log] = matchPMexposure(Deployment_roomcat_save,Pathnames3,allFiles3,HAPDeployment,bname,nomatch,AA_HAPEx_LOQ_replace,HAPEx_LOQ, class_log,i)
% matchPMexposure by Evan Coffey

%  This function matches PM exposure and compliance to user beacon timeseries for
%   deployment matches




%inputs:
% a single user beacon deployment entry (table)
% filenames and pathnames for all baseline corrected HAPEx data

n_min = 45; %number of minutes to smooth compliance data (OR what is reasonable interval in which one would not be changing into or out of the wearable instruments)
include_beacon_comp=0;


%outputs:
% time-matched beacon deployment with PM exposure and compliance

%% Create a columns in the Deployment_roomcat_save for up to two HAPEx timeseries (baseline corrected (BC) and raw) with flags to go
Deployment_roomcat_save.BC_HAPEX_1 = NaN(height(Deployment_roomcat_save),1);
Deployment_roomcat_save.BC_HAPEX_1_flag = NaN(height(Deployment_roomcat_save),1);
Deployment_roomcat_save.Raw_HAPEX_1 = NaN(height(Deployment_roomcat_save),1);
Deployment_roomcat_save.HAPEX_1_Name = num2cell(NaN(height(Deployment_roomcat_save),1));
Deployment_roomcat_save.HAPEX_1_Compliance = NaN(height(Deployment_roomcat_save),1);

Deployment_roomcat_save.BC_HAPEX_2 = NaN(height(Deployment_roomcat_save),1);
Deployment_roomcat_save.BC_HAPEX_2_flag = NaN(height(Deployment_roomcat_save),1);
Deployment_roomcat_save.Raw_HAPEX_2 = NaN(height(Deployment_roomcat_save),1);
Deployment_roomcat_save.HAPEX_2_Name = num2cell(NaN(height(Deployment_roomcat_save),1));
Deployment_roomcat_save.HAPEX_2_Compliance = NaN(height(Deployment_roomcat_save),1);

Deployment_roomcat_save.Beacon_compliance = NaN(height(Deployment_roomcat_save),1);
Deployment_roomcat_save.PM_compliance = NaN(height(Deployment_roomcat_save),1); 
Deployment_roomcat_save.Overall_Compliance = NaN(height(Deployment_roomcat_save),1);


%% Populate ClassLog table with variables

class_log.deployment(i) = {bname};
class_log.deployment_num(i) = i;

class_log.PM_compliances_agree_number(i) = NaN;
class_log.PM_compliances_agree_percentage(i) = NaN;
class_log.PM_compliances_disagree_number(i) = NaN;
class_log.PM_compliances_disagree_percentage(i) = NaN;

class_log.Beacon_compliance_0_PM_compliance_1_number(i) = NaN;
class_log.Beacon_compliance_0_PM_compliance_1_percentage(i) = NaN;
class_log.Beacon_compliance_0_PM_compliance_0_number(i) = NaN;
class_log.Beacon_compliance_0_PM_compliance_0_percentage(i) = NaN;
class_log.Beacon_compliance_1_PM_compliance_1_number(i) = NaN;
class_log.Beacon_compliance_1_PM_compliance_1_percentage(i) = NaN;
class_log.Beacon_compliance_1_PM_compliance_0_number(i) = NaN;
class_log.Beacon_compliance_1_PM_compliance_0_percentage(i) = NaN;

%% Begin

%Use the start and end times of the beacon deployment
ts = datetime(Deployment_roomcat_save.TimeMinuteRounded(1),'ConvertFrom', 'datenum');
te = datetime(Deployment_roomcat_save.TimeMinuteRounded(end),'ConvertFrom', 'datenum');

disp([' from ', datestr(ts), ' to ', datestr(te)])

%Grab the UserID from the Beacon deployment - this is the key variable with which we are searching
%for in the Deployment Log
User = Deployment_roomcat_save.UserID(1);

%Locate the number of rows (# of Deployments) where this user comes up
Userind = find(strcmp(HAPDeployment.User,User));


if ~any(Userind) || contains(User,'BM') %No matched User in deployment log OR if the user is from KHRC (users start with BM...)
    
    if ~contains(User,'BM')
    disp('!!!No users matching this Beacon file were found in the PM exposure Deployment')
    nomatch = nomatch+1;
    else
        %% Find and Match the MicroPEMs data
        
        % this is where we integrate the MicroPEMs data but cannot have both MicroPEM and HAPEx data from single user at this time....
        try
         micropemsmatch = find(contains({allFiles3.name}.',User));%Locate micropems files with matching user ID 
        catch
         micropemsmatch = find(~cellfun(@isempty,regexpi({allFiles3.name}.',User)));%Locate micropems files with matching user ID 
        end
        
        
        
        if ~isempty(micropemsmatch) && length(micropemsmatch)==1
            %Read MicroPEMs file
            if ~ismac
            try Hdata = readtable(fullfile(allFiles3(micropemsmatch).folder, allFiles3(micropemsmatch).name));
            catch
                disp('!!!(PC) Error loading a matched MicroPEMs file!!!');
            end
            else
            try Hdata = readtable(fullfile(Pathnames3, allFiles3(micropemsmatch).name));
            catch
                disp('!!!(Mac) Error loading a matched MicroPEMs file!!!');
            end
            end
            
            %Convert the time
            Hdata.datenum_TimeRounded = datenum(Hdata.datetime); %may need to add some date format information
            
            %Convert pm_hepa or corrected_pm variable
            try
                %Hdata.pm_hepa = str2double(Hdata.pm_hepa); %uncorrected MicroPEM data
                Hdata.corrected_pm = str2double(Hdata.corrected_pm); %corrected data
            catch
                %Hdata.pm_hepa = Hdata.pm_hepa; %uncorrected MicroPEM data
                Hdata.corrected_pm = Hdata.corrected_pm; %corrected data
            end
            
            %Compute 1-min compliance
            x = movstd(Hdata.(4),10);  y = movstd(Hdata.(5),10);  z = movstd(Hdata.(6),10);
            xcomp=x>0.01; ycomp=y>0.01; zcomp=z>0.01;
            Hdata.compliance = xcomp | ycomp | zcomp; %If either dimension shows compliance then minute is compliant
            
                try
                    matchind = isbetween(Hdata.datetime,ts,te);
                    numatch = sum(matchind); % number of minute matches

                    if numatch>0
                    disp([num2str(numatch), ' possible Beacon time matches found in: ']); disp(allFiles3(micropemsmatch).name);

                    %[C,ia,ib] = innerjoin(Deployment_roomcat_save,Hdata,'LeftKeys',17, 'RightKeys',8);%The time key from Deployment_roomcat_save is column 17 and the time key from Hdata is 8
                    [C,ia,ib] = innerjoin(Deployment_roomcat_save,Hdata,'LeftKeys',17, 'RightKeys',12);%the time key from Deployment_roomcat_save is column 17 and the time key from Hdata is now row 12 for corrected MicroPEM data
                    disp([num2str(length(ia)), ' MicroPEMs time matches found with proximity data']);
                    %Deployment_roomcat_save.BC_HAPEX_1(ia)= Hdata.(7)(ib); %uncorrected data
                    Deployment_roomcat_save.BC_HAPEX_1(ia)= Hdata.(11)(ib); %corrected data
                    Deployment_roomcat_save.Raw_HAPEX_1(ia)= Hdata.(3)(ib);
                    Deployment_roomcat_save.HAPEX_1_Compliance(ia) = Hdata.compliance(ib);
                    Deployment_roomcat_save.HAPEX_1_Name(:)=extractBetween(allFiles3(micropemsmatch).name,1,10);
                    Deployment_roomcat_save.BC_HAPEX_1_flag(ia) = -777; %-777 indicates that a MicroPEMs monitor was used
                    Deployment_roomcat_save_temp = Deployment_roomcat_save;

        %             else disp('No overlapping time found in:');  
        %                  disp(allFiles3(hnamematch(j)).name);
                    end 
                catch
                    disp('!!!Some issue occurred finding matches with: ');
                    disp(allFiles3(micropemsmatch).name);
                end
                
        else
           disp('No micropems data files found matching this user') 

        end %hapex names loop
        clear C Hdata  
    end %KHRC user conditional
    
    
else %there is a user from NHRC then continue

    %% Match the HAPEx data

    %Loop through the deployments that match that user and find time intervals
    for j=1:length(Userind)

        try
        d_ts = datetime(HAPDeployment.Date_TimeStart(Userind(j)));
        d_te = datetime(HAPDeployment.Date_TimeEnd(Userind(j)));
        catch
        d_ts = datetime(HAPDeployment.Date_TimeStart(Userind(j)),'ConvertFrom' ,'datenum');
        d_te = datetime(HAPDeployment.Date_TimeEnd(Userind(j)),'ConvertFrom' ,'datenum');
        end

        %Add a time buffer in case the deployment time is slightly different

        d_ts_buffup = d_ts+minutes(30);
        d_ts_buffdown = d_ts-minutes(30);

        if isbetween(ts,d_ts_buffdown,d_ts_buffup)
            Userind_match(j)=Userind(j);
            fprintf('Match found for user %s \n', char(User));
        else
            Userind_match(j)=NaN;
        end
    end

    % Clear Userind_match that were not in the timeframe above that were set to NaN
    Userind_match = Userind_match(~isnan(Userind_match));

    %Now that we know which HAPEx correspond to this deployment, load only
    %these monitor(s) HAPEx files

    hname = HAPDeployment.(1)(Userind_match);

    %if there are two HAPEx deployed on this individual check to make sure they aren't duplicate entries
    if length(hname)> 1 
        if isequal(hname(1),hname(2))
            disp(hname(1))
            disp(['Duplicate error HAPEx entry on Deployment row: ' num2str(Userind_match(2))]);
            hname(2) = []; %mark the second lascar name as 'none'
        end
    end

    %Display the names of the HAPEx worn by this person
    disp('HAPEX worn by this individual: ');
    disp(hname);

    % If no userind match is found then set hname to 999
    if isempty(Userind_match)
        hname = 999; %999 means there is no matching HAPEx
        disp('!!!This user was not wearing a HAPEx!!!')
    end


    % WORK ON HAPEx 1 FIRST

     % Locate the position of the HAPEX b-cor files that share the name of the matched lascars
     try
        hnamematch = find(contains({allFiles3.name}.',strcat('_',hname(1))));%Locate bcor files with matching HAPEx ID 
     catch
           try
              hnamematch = find(contains({allFiles3.name}.',strcat('_',num2str(hname(1)))));%Locate bcor files with matching HAPEx ID 
           catch
               try
                 hnamematch = find(~cellfun(@isempty,regexpi({allFiles3.name}.',strcat('_',num2str(hname(1))))));%Locate bcor files with matching HAPEx ID 
               catch
               end
           end
     end
               
               
               

    for j=1:length(hnamematch)
        %Loop through b-cor HAPEx files for hnamematch(1) and match PM exposure and compliance to the room_cat

        if ~ismac
        try Hdata = readtable(fullfile(allFiles3(hnamematch(j)).folder, allFiles3(hnamematch(j)).name));
        catch
            disp('!!!(PC) Error loading one or more matched HAPEx file(s)!!!');
        end
        else
        try Hdata = readtable(fullfile(Pathnames3, allFiles3(hnamematch(j)).name));
        catch
            disp('!!!(Mac) Error loading one or more matched HAPEx file(s)!!!');
        end
        end

        Hdata.datenum_TimeRounded = datenum(Hdata.datetime);

            try
                matchind = isbetween(Hdata.datetime,ts,te);
                numatch = sum(matchind); % number of minute matches

                if numatch>0
                disp([num2str(numatch), ' possible Beacon time matches found in: ']); disp(allFiles3(hnamematch(j)).name);

                [C,ia,ib] = innerjoin(Deployment_roomcat_save,Hdata,'LeftKeys',17, 'RightKeys',7);%The key from Deployment_roomcat_save is column 1 and the key from Hdata is 7
                disp([num2str(length(ia)), ' HAPEX PM time matches found with proximity data']);
                Deployment_roomcat_save.BC_HAPEX_1(ia)= Hdata.(6)(ib);
                Deployment_roomcat_save.Raw_HAPEX_1(ia)= Hdata.(2)(ib);
                Deployment_roomcat_save.HAPEX_1_Compliance(ia) = Hdata.compliance(ib);
                Deployment_roomcat_save.HAPEX_1_Name(:)=hname(1);
                Deployment_roomcat_save.BC_HAPEX_1_flag = Hdata.(5)(ib);
                Deployment_roomcat_save_temp = Deployment_roomcat_save;
    %             else disp('No overlapping time found in:');  
    %                  disp(allFiles3(hnamematch(j)).name);
                end 
            catch
                disp('!!!Some issue occurred finding matches with: ');
                disp(allFiles3(hnamematch(j)).name);
            end

    end %hapex names loop
    clear C hdata


    %Were any matched data found?
    if isnan(nanmean(Deployment_roomcat_save.BC_HAPEX_1))
        disp('!!!No matched HAPEX 1 data found - make sure data is up to date.')
    end          

    % WORK ON HAPEx 2 NOW
    if length(hname)>1 %Is there a second HAPEx??

    
     % Locate the position of the HAPEX b-cor files that share the name of the matched lascars
     try
        hnamematch = find(contains({allFiles3.name}.',strcat('_',hname(2))));%Locate bcor files with matching HAPEx ID 
     catch
           try
              hnamematch = find(contains({allFiles3.name}.',strcat('_',num2str(hname(2)))));%Locate bcor files with matching HAPEx ID 
           catch
               try
                 hnamematch = find(~cellfun(@isempty,regexpi({allFiles3.name}.',strcat('_',num2str(hname(2))))));%Locate bcor files with matching HAPEx ID 
               catch
               end
           end
     end
               

    for jj=1:length(hnamematch)%Loop through b-cor HAPEx files for hname(2) and match PM exposure to the room_cat

        if ~ismac
        try Hdata = readtable(fullfile(allFiles3(hnamematch(jj)).folder, allFiles3(hnamematch(jj)).name));
        catch
            disp('!!!(PC) Error loading one or more matched Lascar file(s)!!!');
        end
        else
        try Hdata = readtable(fullfile(Pathnames3, allFiles3(hnamematch(jj)).name));
        catch
            disp('!!!(Mac) Error loading one or more matched Lascar file(s)!!!');
        end
        end

        Hdata.datenum_TimeRounded = datenum(Hdata.datetime);

            try
                matchind = isbetween(Hdata.datetime,ts,te);
                numatch = sum(matchind); % number of minute matches

                if numatch>0
                disp([num2str(numatch), ' possible Beacon time matches found in: ']); disp(allFiles3(hnamematch(jj)).name);

                [C,ia,ib] = innerjoin(Deployment_roomcat_save,Hdata,'LeftKeys',17, 'RightKeys',7);%The key from Deployment_roomcat_save is column 1 and the key from Hdata is 7
                disp([num2str(length(ia)), ' HAPEX PM time matches found with proximity data']);
                Deployment_roomcat_save.BC_HAPEX_2(ia)=Hdata.(6)(ib);
                Deployment_roomcat_save.Raw_HAPEX_2(ia)=Hdata.(2)(ib);
                Deployment_roomcat_save.HAPEX_2_Compliance(ia) = Hdata.compliance(ib);
                Deployment_roomcat_save.HAPEX_2_Name(:)=hname(2);
                Deployment_roomcat_save.BC_HAPEX_2_flag = Hdata.(5)(ib);
                Deployment_roomcat_save_temp = Deployment_roomcat_save;
    %             else disp('!!!No overlapping time found in:'); 
    %                  disp(allFiles3(hnamematch(jj)).name);
                end 
            catch
                disp('!!!Some issue occurred finding matches with: ');
                disp(allFiles3(hnamematch(jj)).name);
            end


    end %Hapex name match loop 
    clear C hdata

    %Were any matched data found?
    if isnan(nanmean(Deployment_roomcat_save.BC_HAPEX_2))
        disp('!!!No matched HAPEX 2 data found - make sure data is up to date.')
    end   

    end %HAPEx #2 conditional

    
end %If User has matched HAPEx/is from NHRC conditional


%% Merge compliance to form Overall_compliance metric

%% HAPEx Compliance

%Start by rounding the individual hapex compliance to nearest integer
Deployment_roomcat_save.HAPEX_1_Compliance = round(Deployment_roomcat_save.HAPEX_1_Compliance);
Deployment_roomcat_save.HAPEX_2_Compliance = round(Deployment_roomcat_save.HAPEX_2_Compliance);

%Smooth HAPEx compliance using n_min rolling mean
totcomp1 = movmean(Deployment_roomcat_save.HAPEX_1_Compliance,n_min);
totcomp1(totcomp1<0.5)=0; %recompute binary
totcomp1(totcomp1>=0.5)=1; %recompute binary

totcomp2 = movmean(Deployment_roomcat_save.HAPEX_2_Compliance,n_min);
totcomp2(totcomp2<0.5)=0; %recompute binary
totcomp2(totcomp2>=0.5)=1; %recompute binary


% Determine which HAPEx or MicroPEM, if any, has an issue with the accelerometer and therefore compliance reading
compstd1 = nanstd(totcomp1); compstd2 = nanstd(totcomp2);

if ~isnan(compstd1) && ~isnan(compstd2) %both PM monitors have compliance data
    try
    c1=confusionmat((totcomp1),(totcomp2)); %ceate confusion matrix for both PM logger compliance measures 
    tot = sum(c1, 'all'); matched = (c1(1,1)+c1(2,2))/(tot)*100; conflicted = (c1(1,2)+c1(2,1))/(tot)*100;

    try
    ch1=confusionchart(logical(totcomp1),logical(totcomp2));  %graph the confusion matrix
    ch1.YLabel = 'PM 1 compliance'; ch1.XLabel = 'PM 2 compliance';
    catch
    end
    
    disp(['Paired PM monitor compliance agree ' num2str(matched,3), '% of time'])
    % pause(2)
    close

    % Populate the class_log table
    class_log.PM_compliances_agree_number(i) = c1(1,1)+c1(2,2);
    class_log.PM_compliances_agree_percentage(i) = matched;
    class_log.PM_compliances_disagree_number(i) = (c1(1,2)+c1(2,1));
    class_log.PM_compliances_disagree_percentage(i) = conflicted;

    catch
        matched = 100; disp('No compliance detected from either PM monitor')
    end

        if matched<75 && compstd1<compstd2 %If paired PM complance match less than 75% of the time and compliance 1 has less noise
        comptemp = totcomp1; disp('Using PM monitor 1 compliance')
        else
            if matched<75 && compstd1>compstd2 %If paired PM complance match less than 75% of the time and compliance 2 has less noise
            comptemp = totcomp2;  disp('Using PM monitor 2 compliance')
            else
            comptemp = cat(2,totcomp1,totcomp2); %combine compliance
            comptemp = nansum(comptemp,2); %sum them
            comptemp(comptemp>=1)=1; %any compliant=1 is 1
            comptemp = movmean(comptemp,n_min);%smooth the merged data using rolling n_min mean
            disp('Using merged PM monitor compliance')
            end
        end
    clear c1 ch1 matched conflicted tot

else %only one of the two PM monitors has compliance data

    if ~isnan(compstd1) && isnan(compstd2)
        comptemp = totcomp1; disp('Using PM monitor 1 compliance') %use PM sensor 1 compliance, already smoothed
    else
        if isnan(compstd1) && ~isnan(compstd2)
        comptemp = totcomp2; disp('Using PM monitor 2 compliance') %use PM sensor 2 compliance, already smoothed
        else % neither has compliance data
        comptemp = NaN(height(Deployment_roomcat_save),1); %use neither...   
        end
        
    end
    clear c1 ch1 matched conflicted tot

end

Deployment_roomcat_save.PM_compliance = comptemp; %save the operational particle monitor compliance measure to the overall PM_compliance variable
Deployment_roomcat_save.PM_compliance = round(Deployment_roomcat_save.PM_compliance); %round


%% Perform the Beacon rssi compliance algorithm to merge with HAPEx data compliance stream


% Beacon compliance classification learner model

try
%load the classification ensemble

if contains(Deployment_roomcat_save.UserID(1), 'BM')
    %load compliance_ensemble_BALogger
    load compliance_ensemble_BALogger_v2
else
    %load compliance_ensemble_PhoneLogger
    load compliance_ensemble_PhoneLogger_v2
end

rssi_temp = Deployment_roomcat_save.BeaconRSSI;
rssi_temp(rssi_temp==-999)=NaN;


%first set up the inputs for the model MAY NEED TO REMOVE 'omitnan'
roll10std = abs(movstd(rssi_temp,10));
roll5std = abs(movstd(rssi_temp,5));
roll3std = abs(movstd(rssi_temp,3));

roll10mean = abs(movmean(rssi_temp,10));
roll5mean = abs(movmean(rssi_temp,5));
roll3mean = abs(movmean(rssi_temp,3));

roll10COV = roll10std./roll10mean;
roll5COV = roll5std./roll5mean;
roll3COV = roll3std./roll3mean;

roll10var = abs(movvar(rssi_temp,10));
roll5var = abs(movvar(rssi_temp,5));
roll3var = abs(movvar(rssi_temp,3));


%input_table = table(roll10std,roll10mean,roll10COV,roll5std,roll5mean,roll5COV,roll3std,roll3mean,roll3COV); %input variable table for v1 compliance_ensembles
input_table = table(roll10std,roll10mean,roll10COV,roll10var,roll5std,roll5mean,roll5COV,roll5var,roll3std,roll3mean,roll3COV,roll3var); %input variable table for v2 compliance_ensembles

model_output = compliance_ensemble.predictFcn(input_table); disp('...using ensemble...');

%Determine which rows of prediction do not have enough input data
[~,TF] = rmmissing(input_table,1,'MinNumMissing',5);


beaconcompliance = [];
beaconcompliance(strcmpi(model_output,'Noncompliant'))=0;
beaconcompliance(strcmpi(model_output,'compliant'))=1;
beaconcompliance = transpose(beaconcompliance);
beaconcompliance(TF)=NaN; %NaN those points where there wasn't enough info to make prediction
disp('...successfully predicted beacon compliance')


% % Additonal filtering of clearly non-compliant data can go here
% beaconcompliance(roll3var<3)=0;
% beaconcompliance(roll3var>6)=1;

%Smooth the beacon compliance metric using a n_min rolling mean
beaconcompliance = movmean(beaconcompliance,n_min);
beaconcompliance(beaconcompliance<0.5)=0; %recompute binary
beaconcompliance(beaconcompliance>=0.5)=1; %recompute binary
disp('...successfully smoothed beacon compliance')



Deployment_roomcat_save.Beacon_compliance = beaconcompliance;

clear compliance_ensemble
catch
    disp('!!!Issue loading or deploying the beacon compliance classification ensemble!!!')
end






 %% Alternative beacon_compliance algorithm
% 
% try
%     sm_temp = Deployment_roomcat_save.BeaconRSSI; sm_temp(sm_temp==-999)=NaN; %create temporary RSSI variable and change all -999 to NaN
%     sm = abs(movstd(sm_temp,5, 'omitnan')); %5-min rolling standard deviation above threshold determined via validation testing
%     beaconcompliance = double(sm>3); %which points have SD above threshold - these are compliant points
%     beaconcompliance = movmean(beaconcompliance,n_min);
%     beaconcompliance(beaconcompliance<0.5)=0; %recompute binary
%     beaconcompliance(beaconcompliance>=0.5)=1; %recompute binary
%     clear sm sm_temp
% catch
%     disp('!!!Issue classifying beacon compliance with movstd algorithm!!!')
% end

%% old beacon method

% try
%     sm = abs(movstd(Deployment_roomcat_save.BeaconRSSI,60, 'omitnan')./movmean(Deployment_roomcat_save.BeaconRSSI,60,'omitnan')); %This is the 1-hr rolling std dev divided by the rolling mean (or COV)
%     beaconcompliance = double(sm>0.045); %which points have COV above threshold - these are compliant
% catch
% end

%% Quick comparison of the PM monitor compliance and beacon compliance

try
c2=confusionmat(beaconcompliance,comptemp); %create confusion matrix of beacon and PM monitor compliance
tot = sum(c2, 'all'); matched = (c2(1,1)+(c2(2,2)))/(tot)*100; conflicted = (c2(1,2)+c2(2,1))/(tot)*100;

try
ch2 = confusionchart(logical(beaconcompliance),logical(comptemp));
ch2.YLabel = 'Beacon compliance'; ch2.XLabel = 'PM monitor compliance';
catch
end

disp([num2str(matched,3), '% MATCHES between PM compliance and beacon compliance'])
disp([num2str(conflicted,3), '% CONFLICTS between PM compliance and beacon compliance'])

%Could add this confusion plot to the post script report output
%pause(2)
close

class_log.Beacon_compliance_0_PM_compliance_1_number(i) = c2(1,2);
class_log.Beacon_compliance_0_PM_compliance_1_percentage(i) = c2(1,2)/tot;
class_log.Beacon_compliance_0_PM_compliance_0_number(i) = c2(1,1);
class_log.Beacon_compliance_0_PM_compliance_0_percentage(i) = c2(1,1)/tot;
class_log.Beacon_compliance_1_PM_compliance_1_number(i) = c2(2,2);
class_log.Beacon_compliance_1_PM_compliance_1_percentage(i) = c2(2,2)/tot;
class_log.Beacon_compliance_1_PM_compliance_0_number(i) = c2(2,1);
class_log.Beacon_compliance_1_PM_compliance_0_percentage(i) = c2(2,1)/tot;

clear c2 ch2 matched conflicted tot

catch
    disp('No comparison or comparison failed between PM compliance and beacon compliance')
end

%% Merge the beacon and HAPEx compliance

try
    if ~isempty(beaconcompliance) && include_beacon_comp==1
        comptemp = comptemp + beaconcompliance; % 2 or 0 will mean HAPEx and Beacon agreed on compliance metric, and 1 will mean they did not agree
        comp = double(comptemp>0); % if either metric predicts compliance (1,0 OR 0,1 OR 1,1) then the overall compliance is 1
    else
        comp = comptemp; %if beacon compliance has issue then just use PM compliance
        disp('Beacon compliance is empty or user chose to not include it; using only PM compliance')
    end
    
catch
    disp('Issue calculating compliance from beacon RSSI- using PM compliance only - check deployment_roomcat file')
    comp = comptemp;
end


%% Add overall compliance

Deployment_roomcat_save.Overall_Compliance = comp; % define overall compliance here from above measures
Deployment_roomcat_save_temp = Deployment_roomcat_save;


% HAPEx LOQ Replacement
if AA_HAPEx_LOQ_replace==1  && ~contains(User,'BM') %perform LOQ replacement if user selects it AND user is not from KHRC
        try 
            if~isnan(nanmean(Deployment_roomcat_save_temp.BC_HAPEX_1))
            Deployment_roomcat_save_temp.BC_HAPEX_1(Deployment_roomcat_save_temp.BC_HAPEX_1<HAPEx_LOQ)=HAPEx_LOQ;
            disp(['HAPEx 1 values below the LOQ: ',num2str(HAPEx_LOQ),' raw counts, have been replaced with the LOQ'])
            else
            disp('HAPEx 1 values all NaN - no LOQ replacement')
            end
            
            if~isnan(nanmean(Deployment_roomcat_save_temp.BC_HAPEX_2))
            Deployment_roomcat_save_temp.BC_HAPEX_2(Deployment_roomcat_save_temp.BC_HAPEX_2<HAPEx_LOQ)=HAPEx_LOQ;
            disp(['HAPEx 2 values below the LOQ: ',num2str(HAPEx_LOQ),' raw counts, have been replaced with the LOQ'])
            else
            disp('HAPEx 2 values all NaN - no LOQ replacement')
            end
        catch
             disp('!!!Issue LOQ replacemnt of PM data!!!')
        end
else
    disp('Skipping HAPEx LOQ replacement. MicroPEMs used or user selected to skip.')
end


disp('........................................')


clear totcomp1 totcomp2 comp sm beaconcompliance comptemp User
end %Function end

