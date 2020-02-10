function [Deployment_roomcat_save_temp,numbad,class_log, bad_beacon] = classify_activities(Deployment_roomcat_save,AA_Deployment_Time_Averaging,bname,numbad,psname,yyy,class_log, bad_beacon)
%By Evan Coffey
% This code categorizes the time-intervals by a set of criteria (see below)
% for modeling purposes

wantsomeplots=0; %disabled when this content was added to the main Beacon_Exposure_Matching_updated Code

%****************************************************************************

%   Place the criteria here - be very careful setting limits - as of March 4th 2019

%   Proximity catergories (user sets);
prox_very_near = 2;                     %       very near	m<=2
prox_near = 5;                          %       near	2<m<=5
prox_in_vicinity = 1000;                %       in vicinity	5<m<=1000m
                                        %       undefined, not-logging	NA

%   Location categories (user sets):
at_home_gps = 0.5; at_home_prox = 60;   %       At home	if(GPS_cat>=0.5 & m<=60)
                                        %       Away	if(GPS_cat<0.5 & m>60)
                                        %       undefined, NA

%   Stove use categories:
                                        %       No stoves on	allstoves (status?1)
                                        %       TSF on	anyTSF (status=1)
                                        %       Coalpot on	anyCoalpot (status=1)
                                        %       Jumbo on	anyJumbo (status=1)
                                        %       ACE on	anyACE (status=1)
                                        %       LPG on	anyLPG (status=1)
                                        %       TSF and Coalpot on	anyTSF (status=1) && anyCoalpot (status=1)
                                        %       TSF and Jumbo on	anyTSF (status=1) && anyJumbo (status=1)
                                        %       TSF and ACE on	anyTSF (status=1) && anyACE (status=1)
                                        %       Coalpot and Jumbo on	anyCoalpot (status=1) && anyJumbo (status=1)
                                        %       Coalpot and ACE on	anyCoalpot (status=1) && anyACE (status=1)
                                        %       TSF and LPG on	anyTSF (status=1) && anyLPG (status=1)
                                        %       Coalpot and LPG on	anyCoalpot (status=1) && anyLPG (status=1)
                                        %       Jumbo and ACE on	anyJumbo (status=1) && anyACE (status=1)
                                        %       other	NA
    
%   Compliance:
                                        %       At least 0.75 in time interval (0=noncompliant, 1=compliant)

%****************************************************************************




%% For time-averaged deployments, reassign non-numeric fields to categories
   
    if AA_Deployment_Time_Averaging==1
    disp('re-assigning non-numeric fields')

            try
                        %location
                        primary_ind = Deployment_roomcat_save.Location<=1.5;
                        secondary_ind = Deployment_roomcat_save.Location>1.5 & Deployment_roomcat_save.Location<=2.5;
                        unclassified_ind = Deployment_roomcat_save.Location>2.5 | isnan(Deployment_roomcat_save.Location);

                        Deployment_roomcat_save.Location = num2cell(Deployment_roomcat_save.Location);
                        Deployment_roomcat_save.Location(primary_ind) = {'Primary Kitchen'};
                        Deployment_roomcat_save.Location(secondary_ind) = {'Secondary Kitchen'};
                        Deployment_roomcat_save.Location(unclassified_ind) = {''};
                        clear unclassified_ind
            catch
                     disp(['Issue converting numerics back to LOCATION categories. Check file yyy=', num2str(yyy)])
            end
            %stove status
            %conditional if class is cell not numeric here
            
            
            try
                if ~isnan(nanmean(Deployment_roomcat_save.Stove_1_temp))    
                stove1_off_ind = Deployment_roomcat_save.Stove_1_status<0.5;
                stove1_on_ind = Deployment_roomcat_save.Stove_1_status>=0.5;
                unclassified_1_ind = Deployment_roomcat_save.Stove_1_status>1 | isnan(Deployment_roomcat_save.Stove_1_status);
                Deployment_roomcat_save.Stove_1_status = num2cell(Deployment_roomcat_save.Stove_1_status);
                Deployment_roomcat_save.Stove_1_status(stove1_off_ind) = {'No Cooking'};
                Deployment_roomcat_save.Stove_1_status(stove1_on_ind) = {'Cooking'};
                Deployment_roomcat_save.Stove_1_status(unclassified_1_ind) = {'Not Logging'};
                end
            catch
                disp(['Issue converting numerics back to stove_status 1 categories. Check file yyy=', num2str(yyy)])
            end

            try
                if ~isnan(nanmean(Deployment_roomcat_save.Stove_2_temp))
                stove2_off_ind = Deployment_roomcat_save.Stove_2_status<0.5;
                stove2_on_ind = Deployment_roomcat_save.Stove_2_status>=0.5;
                unclassified_2_ind = Deployment_roomcat_save.Stove_2_status>1 | isnan(Deployment_roomcat_save.Stove_2_status);
                Deployment_roomcat_save.Stove_2_status = num2cell(Deployment_roomcat_save.Stove_2_status);
                Deployment_roomcat_save.Stove_2_status(stove2_off_ind) = {'No Cooking'};
                Deployment_roomcat_save.Stove_2_status(stove2_on_ind) = {'Cooking'};
                Deployment_roomcat_save.Stove_2_status(unclassified_2_ind) =  {'Not Logging'};
                end
            catch
                disp(['Issue converting numerics back to stove_status 2 categories. Check file yyy=', num2str(yyy)])                
            end
            
            try
                if ~isnan(nanmean(Deployment_roomcat_save.Stove_3_temp))
                stove3_off_ind = Deployment_roomcat_save.Stove_3_status<0.5;
                stove3_on_ind = Deployment_roomcat_save.Stove_3_status>=0.5;
                unclassified_3_ind = Deployment_roomcat_save.Stove_3_status>1 | isnan(Deployment_roomcat_save.Stove_3_status);
                Deployment_roomcat_save.Stove_3_status = num2cell(Deployment_roomcat_save.Stove_3_status);
                Deployment_roomcat_save.Stove_3_status(stove3_off_ind) = {'No Cooking'};
                Deployment_roomcat_save.Stove_3_status(stove3_on_ind) = {'Cooking'};
                Deployment_roomcat_save.Stove_3_status(unclassified_3_ind) =  {'Not Logging'};
                end
            catch
                disp(['Issue converting numerics back to stove_status 3 categories. Check file yyy=', num2str(yyy)])
            end
           
            try
                if ~isnan(nanmean(Deployment_roomcat_save.Stove_4_temp))
                stove4_off_ind = Deployment_roomcat_save.Stove_4_status<0.5;
                stove4_on_ind = Deployment_roomcat_save.Stove_4_status>=0.5;
                unclassified_4_ind = Deployment_roomcat_save.Stove_4_status>1 | isnan(Deployment_roomcat_save.Stove_4_status);
                Deployment_roomcat_save.Stove_4_status = num2cell(Deployment_roomcat_save.Stove_4_status);
                Deployment_roomcat_save.Stove_4_status(stove4_off_ind) = {'No Cooking'};
                Deployment_roomcat_save.Stove_4_status(stove4_on_ind) = {'Cooking'};
                Deployment_roomcat_save.Stove_4_status(unclassified_4_ind) =  {'Not Logging'};
                end
            catch
                disp(['Issue converting numerics back to stove_status 4 categories. Check file yyy=', num2str(yyy)])
            end
            
            try
                if ~isnan(nanmean(Deployment_roomcat_save.Stove_5_temp))
                stove5_off_ind = Deployment_roomcat_save.Stove_5_status<0.5;
                stove5_on_ind = Deployment_roomcat_save.Stove_5_status>=0.5;
                unclassified_5_ind = Deployment_roomcat_save.Stove_5_status>1 | isnan(Deployment_roomcat_save.Stove_5_status);
                Deployment_roomcat_save.Stove_5_status = num2cell(Deployment_roomcat_save.Stove_5_status);
                Deployment_roomcat_save.Stove_5_status(stove5_off_ind) = {'No Cooking'};
                Deployment_roomcat_save.Stove_5_status(stove5_on_ind) = {'Cooking'};
                Deployment_roomcat_save.Stove_5_status(unclassified_5_ind) =  {'Not Logging'};
                end
            catch
                disp(['Issue converting numerics back to stove_status 5 categories. Check file yyy=', num2str(yyy)])
            end
           
            try
                if ~isnan(nanmean(Deployment_roomcat_save.Stove_6_temp))
                stove6_off_ind = Deployment_roomcat_save.Stove_6_status<0.5;
                stove6_on_ind = Deployment_roomcat_save.Stove_6_status>=0.5;
                unclassified_6_ind = Deployment_roomcat_save.Stove_6_status>1 | isnan(Deployment_roomcat_save.Stove_6_status);
                Deployment_roomcat_save.Stove_6_status = num2cell(Deployment_roomcat_save.Stove_6_status);
                Deployment_roomcat_save.Stove_6_status(stove6_off_ind) = {'No Cooking'};
                Deployment_roomcat_save.Stove_6_status(stove6_on_ind) = {'Cooking'};
                Deployment_roomcat_save.Stove_6_status(unclassified_6_ind) =  {'Not Logging'};
                end
            catch
                disp(['Issue converting numerics back to stove_status 6 categories. Check file yyy=', num2str(yyy)])
            end
            
            try
                if ~isnan(nanmean(Deployment_roomcat_save.Stove_7_temp))
                stove7_off_ind = Deployment_roomcat_save.Stove_7_status<0.5;
                stove7_on_ind = Deployment_roomcat_save.Stove_7_status>=0.5;
                unclassified_7_ind = Deployment_roomcat_save.Stove_7_status>1 | isnan(Deployment_roomcat_save.Stove_7_status);
                Deployment_roomcat_save.Stove_7_status = num2cell(Deployment_roomcat_save.Stove_7_status);
                Deployment_roomcat_save.Stove_7_status(stove7_off_ind) = {'No Cooking'};
                Deployment_roomcat_save.Stove_7_status(stove7_on_ind) = {'Cooking'};
                Deployment_roomcat_save.Stove_7_status(unclassified_7_ind) =  {'Not Logging'};
                end
            catch
                disp(['Issue converting numerics back to stove_status 7 categories. Check file yyy=', num2str(yyy)])
            end
            
            
            
            %Create location and stove_status categoricals
            
            Deployment_roomcat_save.Location = categorical(Deployment_roomcat_save.Location);
            
           
            Deployment_roomcat_save.Stove_1_status = categorical(Deployment_roomcat_save.Stove_1_status);
            Deployment_roomcat_save.Stove_2_status = categorical(Deployment_roomcat_save.Stove_2_status);
            Deployment_roomcat_save.Stove_3_status = categorical(Deployment_roomcat_save.Stove_3_status);
            Deployment_roomcat_save.Stove_4_status = categorical(Deployment_roomcat_save.Stove_4_status);
            Deployment_roomcat_save.Stove_5_status = categorical(Deployment_roomcat_save.Stove_5_status);
            Deployment_roomcat_save.Stove_6_status = categorical(Deployment_roomcat_save.Stove_6_status);
            Deployment_roomcat_save.Stove_7_status = categorical(Deployment_roomcat_save.Stove_7_status);
            
            disp('...done')


            clear stove7_off_ind stove6_off_ind stove5_off_ind stove4_off_ind stove3_off_ind stove2_off_ind stove1_off_ind primary_ind secondary_ind
            clear stove7_on_ind stove6_on_ind stove5_on_ind stove4_on_ind stove3_on_ind stove2_on_ind stove1_on_ind
            clear unclassified_1_ind unclassified_2_ind unclassified_3_ind unclassified_4_ind unclassified_5_ind unclassified_6_ind unclassified_7_ind
    
            
    else %add code here to reformat 1-min data
        disp('creating location and stove status categoricals')
        
                
            try
                if  sum(cellfun('isclass', Deployment_roomcat_save.Stove_1_ID, 'char'))>20 %If almost all (but a few) stove_ID values are text for a stove ID, then this stove was monitored
                    unclassified_1_ind = isnan(Deployment_roomcat_save.Stove_1_temp) | (Deployment_roomcat_save.Stove_1_temp==-270); %Indicate time points that are NaN or -270
                    Deployment_roomcat_save.Stove_1_status(unclassified_1_ind) =  {'Not Logging'};
                else
                    Deployment_roomcat_save.Stove_1_status(:) =  {''};
                end
            catch
               disp(['Issue converting stove_status 1 categories. Check file yyy=', num2str(yyy)])
            end

           
            try
                if sum(cellfun('isclass', Deployment_roomcat_save.Stove_2_ID, 'char'))>20 %If almost all (but a few) stove_ID values are text for a stove ID, then this stove was monitored
                    unclassified_2_ind = isnan(Deployment_roomcat_save.Stove_2_temp) | (Deployment_roomcat_save.Stove_2_temp==-270); %Indicate time points that are NaN or -270
                    Deployment_roomcat_save.Stove_2_status(unclassified_2_ind) =  {'Not Logging'};
                else
                    Deployment_roomcat_save.Stove_2_status(:) =  {''};
                end
            catch
               disp(['Issue converting stove_status 2 categories. Check file yyy=', num2str(yyy)])
            end
                
            
            try
                if sum(cellfun('isclass', Deployment_roomcat_save.Stove_3_ID, 'char'))>20 %If almost all (but a few) stove_ID values are text for a stove ID, then this stove was monitored
                    unclassified_3_ind = isnan(Deployment_roomcat_save.Stove_3_temp) | (Deployment_roomcat_save.Stove_3_temp==-270); %Indicate time points that are NaN or -270
                    Deployment_roomcat_save.Stove_3_status(unclassified_3_ind) =  {'Not Logging'};
                else
                    Deployment_roomcat_save.Stove_3_status(:) =  {''};
                end
            catch
               disp(['Issue converting stove_status 3 categories. Check file yyy=', num2str(yyy)])
            end
               
            
            try
                if sum(cellfun('isclass', Deployment_roomcat_save.Stove_4_ID, 'char'))>20 %If almost all (but a few) stove_ID values are text for a stove ID, then this stove was monitored
                    unclassified_4_ind = isnan(Deployment_roomcat_save.Stove_4_temp) | (Deployment_roomcat_save.Stove_4_temp==-270); %Indicate time points that are NaN or -270
                    Deployment_roomcat_save.Stove_4_status(unclassified_4_ind) =  {'Not Logging'};
                else
                    Deployment_roomcat_save.Stove_4_status(:) =  {''};
                end
            catch
               disp(['Issue converting stove_status 4 categories. Check file yyy=', num2str(yyy)])
            end  
                
            
            try
               if sum(cellfun('isclass', Deployment_roomcat_save.Stove_5_ID, 'char'))>20 %If almost all (but a few) stove_ID values are text for a stove ID, then this stove was monitored
                    unclassified_5_ind = isnan(Deployment_roomcat_save.Stove_5_temp) | (Deployment_roomcat_save.Stove_5_temp==-270); %Indicate time points that are NaN or -270
                    Deployment_roomcat_save.Stove_5_status(unclassified_5_ind) =  {'Not Logging'};
                else
                    Deployment_roomcat_save.Stove_5_status(:) =  {''};
                end
            catch
               disp(['Issue converting stove_status 5 categories. Check file yyy=', num2str(yyy)])
            end    
                
            
            try
                if sum(cellfun('isclass', Deployment_roomcat_save.Stove_6_ID, 'char'))>20 %If almost all (but a few) stove_ID values are text f0r a stove ID, then this stove was monitored
                    unclassified_6_ind = isnan(Deployment_roomcat_save.Stove_6_temp) | (Deployment_roomcat_save.Stove_6_temp==-270); %Indicate time points that are NaN or -270
                    Deployment_roomcat_save.Stove_6_status(unclassified_6_ind) =  {'Not Logging'};
                else
                    Deployment_roomcat_save.Stove_6_status(:) =  {''};
                end
            catch
               disp(['Issue converting stove_status 6 categories. Check file yyy=', num2str(yyy)])
            end
            
            
            try
                 if sum(cellfun('isclass', Deployment_roomcat_save.Stove_7_ID, 'char'))>20 %If almost all (but a few) stove_ID values are text for a stove ID, then this stove was monitored
                    unclassified_7_ind = isnan(Deployment_roomcat_save.Stove_7_temp) | (Deployment_roomcat_save.Stove_7_temp==-270); %Indicate time points that are NaN or -270
                    Deployment_roomcat_save.Stove_7_status(unclassified_7_ind) =  {'Not Logging'};
                else
                    Deployment_roomcat_save.Stove_7_status(:) =  {''};
                end
            catch
               disp(['Issue converting stove_status 7 categories. Check file yyy=', num2str(yyy)])
            end
            
            
            %Create location and stove-status categoricals
                
            Deployment_roomcat_save.Location = categorical(Deployment_roomcat_save.Location);
            
            Deployment_roomcat_save.Stove_1_status = categorical(Deployment_roomcat_save.Stove_1_status);
            Deployment_roomcat_save.Stove_2_status = categorical(Deployment_roomcat_save.Stove_2_status);
            Deployment_roomcat_save.Stove_3_status = categorical(Deployment_roomcat_save.Stove_3_status);
            Deployment_roomcat_save.Stove_4_status = categorical(Deployment_roomcat_save.Stove_4_status);
            Deployment_roomcat_save.Stove_5_status = categorical(Deployment_roomcat_save.Stove_5_status);
            Deployment_roomcat_save.Stove_6_status = categorical(Deployment_roomcat_save.Stove_6_status);
            Deployment_roomcat_save.Stove_7_status = categorical(Deployment_roomcat_save.Stove_7_status);
            
            disp('...done')
            
            
            clear stove7_off_ind stove6_off_ind stove5_off_ind stove4_off_ind stove3_off_ind stove2_off_ind stove1_off_ind primary_ind secondary_ind
            clear stove7_on_ind stove6_on_ind stove5_on_ind stove4_on_ind stove3_on_ind stove2_on_ind stove1_on_ind
            clear unclassified_1_ind unclassified_2_ind unclassified_3_ind unclassified_4_ind unclassified_5_ind unclassified_6_ind unclassified_7_ind
    
    end %time averaging conditional
       

%% Define new categorical variables in the Deployment Log and make them as long as the existing deployment (yyy) - start out as 'undefined'

Deployment_roomcat_save.CookingCat = categorical(NaN(height(Deployment_roomcat_save),1));
Deployment_roomcat_save.LocationCat = categorical(NaN(height(Deployment_roomcat_save),1));
Deployment_roomcat_save.ProximityCat = categorical(NaN(height(Deployment_roomcat_save),1));
Deployment_roomcat_save.Activity = categorical(NaN(height(Deployment_roomcat_save),1));

%% Stove type categorize

try
    stove_type_categorize
    disp('all monitored stove types identified')
catch
    disp('Issue categorizing stove types')
end

%% Pre-allocate Class_log and predefine stats

% class_log.deployment(yyy) = {bname}; %this has been defined in the matchPMexposure code
% class_log.deployment_num(yyy) = yyy; %this has been defined in the matchPMexposure code


%for proximity
very_near_num = NaN;
very_near_perc = NaN;

near_num = NaN;
near_perc = NaN;

vicinity_num = NaN;
vicinity_perc = NaN;

out_of_range_num = NaN;
out_of_range_perc = NaN;

out_of_small_range_num = NaN;
out_of_small_range_perc = NaN;

out_of_home_range_num = NaN;
out_of_home_range_perc = NaN;

undefined_prox_num = NaN;
undefined_prox_perc = NaN;

%beacon issue value?
deployment_poor_beacon_flag = NaN;

%for location
at_home_loc_num = NaN;
at_home_loc_perc = NaN;

away_loc_num = NaN;
away_loc_perc = NaN;

not_logging_any_loc_num = NaN;
not_logging_any_loc_perc = NaN;

out_of_home_range_loc_num = NaN;
out_of_home_range_loc_perc = NaN;

out_of_range_loc_num = NaN;
out_of_range_loc_perc = NaN;

overlap_loc_num = NaN;
overlap_loc_perc = NaN;

undefined_loc_num = NaN;
undefined_loc_perc = NaN;


%For stoves
any_stove_not_logging_num = NaN;
any_stove_not_logging_perc = NaN;



%% Check to see if the Beacon was non-operational

try
beacon_issue_perc = nansum(isnan(Deployment_roomcat_save.Distance_m_merged))/length(Deployment_roomcat_save.Distance_m_merged);
clear dep_beacon_flag

if beacon_issue_perc>0.75
    disp(['Likely beacon issue detected. ' num2str(beacon_issue_perc*100,3), '% of proximity is NaN...'])
    disp('...classifying location and proximity accordingly')

    Deployment_roomcat_save.Beacons_flag(:) = 0; %Bad beacon flag is 0
    dep_beacon_flag = 1;%Flag overall beacon perfomance in classlog
    bad_beacon = bad_beacon +1;
else
    Deployment_roomcat_save.Beacons_flag(:) = 1; %Good beacon data is 1
    dep_beacon_flag = 0; %No overall flag in classlog
end

catch
    disp('!!!Issue encountered checking for poor beacon data!!!')
end

%% Classify the Proximity-flag (match the closest logger_id to the corresponding beaconlogger_flag to discern operation between each beaconLogger)

%If Beacon_flag is not 0 (beacons are working), compare loggerID (receiver)
%with each BeaconLogger ID available and check to see what each BeaconLoggerID_flag says to determine if the beacon system was functional
Deployment_roomcat_save.Proximity_flag(strcmpi(Deployment_roomcat_save.logger_id,Deployment_roomcat_save.BeaconLogger_1_ID) & ismember(Deployment_roomcat_save.BeaconLogger_1_flag,'Logging') | strcmpi(Deployment_roomcat_save.logger_id,Deployment_roomcat_save.BeaconLogger_2_ID) & ismember(Deployment_roomcat_save.BeaconLogger_2_flag,'Logging') & (Deployment_roomcat_save.Beacons_flag>0)) = {'Logging'};
Deployment_roomcat_save.Proximity_flag(strcmpi(Deployment_roomcat_save.logger_id,Deployment_roomcat_save.BeaconLogger_1_ID) & ismember(Deployment_roomcat_save.BeaconLogger_1_flag,'NotLogging') | strcmpi(Deployment_roomcat_save.logger_id,Deployment_roomcat_save.BeaconLogger_2_ID) & ismember(Deployment_roomcat_save.BeaconLogger_2_flag,'NotLogging') | (Deployment_roomcat_save.Beacons_flag==0)) = {'Not Logging'};


%% Re-classify the HOD

try
   Deployment_roomcat_save.HourOfDay = hour(datetime(Deployment_roomcat_save.TimeMinuteRounded, 'ConvertFrom', 'datenum'));
catch
   disp(['!!!Issue encountered classifying hour of day for: ' bname, '!!!']) 
end

%% Reclassify the DistanceFlag category here

% Using the Proximity Flag and the maximum range of the Beacon logger system, at each home, this section detemrines if the tools where in range of one another
try
    %Calculate how far (1.5* dist of weakest signal logged during the deployment - using bname coefficients) out-of-range is to help determine 'away'
    namesplit = split(bname,'_');

    if contains(bname,'_PM')
        position = 3;
    else
        position = 2;
    end

    p1 = double(string(namesplit(position,1)));
    p2 = double(string(namesplit(position+1,1)));

    min_sig = nanmin(Deployment_roomcat_save.BeaconRSSI(Deployment_roomcat_save.BeaconRSSI>-120));
    
    if min_sig>(-100)
        min_sig=-100;
    end
    
    maxdist = 1.5*(p1*exp((p2*min_sig)));
catch
    disp('Issue calculating maximum proximity dist')
end


%Using maxdist

if maxdist<at_home_prox %if max dist is less than the GPS 'at home' buffer (90m)

Deployment_roomcat_save.DistanceFlag((Deployment_roomcat_save.BeaconRSSI<-120) & ~contains(Deployment_roomcat_save.Proximity_flag,'Not')) = {'Out of smaller-than-buffer range'}; %Beacon system working with an INvalid distance value (no reading), cannot assume instruments left home
Deployment_roomcat_save.DistanceFlag((Deployment_roomcat_save.BeaconRSSI>=-120) & ~contains(Deployment_roomcat_save.Proximity_flag,'Not')) = {'In range'}; %Beacon system working with valid distance value (positive reading)
Deployment_roomcat_save.DistanceFlag(contains(Deployment_roomcat_save.Proximity_flag,'Not')) = {'Not Logging'}; %Beacon system is not working
    
else
Deployment_roomcat_save.DistanceFlag((Deployment_roomcat_save.BeaconRSSI<-120) & ~contains(Deployment_roomcat_save.Proximity_flag,'Not')) = {'Out of buffer range'}; %Beacon system working with an INvalid distance value (no reading), assuming instruments left home
Deployment_roomcat_save.DistanceFlag((Deployment_roomcat_save.BeaconRSSI>=-120) & ~contains(Deployment_roomcat_save.Proximity_flag,'Not')) = {'In range'}; %Beacon system working with valid distance value (positive reading)
Deployment_roomcat_save.DistanceFlag(contains(Deployment_roomcat_save.Proximity_flag,'Not')) = {'Not Logging'}; %Beacon system is not working

end


%% Apply criteria to each sub-category

%% ProximityCat

try
disp('Categorizing proximity...')

%Very near
very_near_ind = Deployment_roomcat_save.Distance_m_merged<=prox_very_near; 
very_near_num=sum(very_near_ind); very_near_perc=(sum(very_near_ind)/length(very_near_ind)*100); disp([num2str(very_near_num), ' time intervals identified as "very near" or ', num2str(very_near_perc,3), '%']);

%Near
near_ind = Deployment_roomcat_save.Distance_m_merged>prox_very_near & Deployment_roomcat_save.Distance_m_merged<=prox_near;
near_num=sum(near_ind); near_perc=(sum(near_ind)/length(near_ind)*100); disp([num2str(near_num), ' time intervals identified as "near" or ', num2str(near_perc,3), '%']);

%In Vicinity
in_vicinity_ind = Deployment_roomcat_save.Distance_m_merged>=prox_near & Deployment_roomcat_save.Distance_m_merged<=prox_in_vicinity;
vicinity_num=sum(in_vicinity_ind); vicinity_perc=(sum(in_vicinity_ind)/length(in_vicinity_ind)*100); disp([num2str(vicinity_num), ' time intervals identified as "in vicinity" or ', num2str(vicinity_perc,3), '%']);

%Out of range (any type)
out_of_range_ind = contains(Deployment_roomcat_save.DistanceFlag, 'Out');
out_of_range_num=sum(out_of_range_ind); out_of_range_perc=(sum(out_of_range_ind)/length(out_of_range_ind)*100); disp([num2str(out_of_range_num), ' time intervals identified as "out of range" or ', num2str(out_of_range_perc,3), '%']); %these alone cannot be used to define 'at or away from home

%Out of smaller-than-buffer range
out_of_small_range_ind = contains(Deployment_roomcat_save.DistanceFlag, 'smaller');
out_of_small_range_num=sum(out_of_small_range_ind); out_of_small_range_perc=(sum(out_of_small_range_ind)/length(out_of_small_range_ind)*100); disp([num2str(out_of_small_range_num), ' time intervals identified as "out of smaller-than-buffer range" or ', num2str(out_of_small_range_perc,3), '%']); %these cannot be used to define 'at or away from home

%Out of buffer range
out_of_home_range_ind = contains(Deployment_roomcat_save.DistanceFlag, 'Out of buffer range');
out_of_home_range_num=sum(out_of_home_range_ind); out_of_home_range_perc=(sum(out_of_home_range_ind)/length(out_of_home_range_ind)*100); disp([num2str(out_of_home_range_num), ' time intervals identified as "out of home buffer range" or ', num2str(out_of_home_range_perc,3), '%']); %these CAN be used to define 'at or away from home

%Not logging
notlogging_prox_ind = contains(Deployment_roomcat_save.DistanceFlag, 'Not');
not_logging_prox_num=sum(notlogging_prox_ind); not_logging_prox_perc=(sum(notlogging_prox_ind)/length(notlogging_prox_ind)*100); disp([num2str(not_logging_prox_num), ' time intervals identified as "not logging" or ', num2str(not_logging_prox_perc,3), '%']);


%prox_undefined = out_of_range_ind;
proximityexcluded = ~very_near_ind & ~near_ind & ~in_vicinity_ind & ~out_of_home_range_ind | notlogging_prox_ind; undefined_prox_num=sum(proximityexcluded); undefined_prox_perc=(sum(proximityexcluded)/length(proximityexcluded)*100); disp([num2str(undefined_prox_num), ' time intervals have "undefined" proximity or ', num2str(undefined_prox_perc,3), '%'])

Deployment_roomcat_save.ProximityCat(isundefined(Deployment_roomcat_save.ProximityCat))= 'Undefined';

Deployment_roomcat_save.ProximityCat(very_near_ind)= 'Very Near';
Deployment_roomcat_save.ProximityCat(near_ind)= 'Near';
Deployment_roomcat_save.ProximityCat(in_vicinity_ind)= 'In Vicinity';
Deployment_roomcat_save.ProximityCat(out_of_home_range_ind)= 'Out of home range';
Deployment_roomcat_save.ProximityCat(out_of_small_range_ind)= 'Out of instrument range';


clear very_near_ind near_ind in_vicinity_ind out_of_range_ind out_of_home_range_ind
catch
        disp('issue with proximity cat')
end

%% LocationCat

try

disp('Categorizing location...')
%at_home_ind = (Deployment_roomcat_save.GPS_cat>=at_home_gps) & (Deployment_roomcat_save.Distance_m_merged<=at_home_prox) | ((Deployment_roomcat_save.Distance_m_merged<=at_home_prox) & (isnan(Deployment_roomcat_save.GPS_cat))) | ((Deployment_roomcat_save.GPS_cat>=at_home_gps) & (isnan(Deployment_roomcat_save.Distance_m_merged)));
%at_home_ind = (Deployment_roomcat_save.GPS_cat>=at_home_gps) | ((Deployment_roomcat_save.Distance_m_merged<=at_home_prox) & (isnan(Deployment_roomcat_save.GPS_cat))) | ((Deployment_roomcat_save.GPS_cat>=at_home_gps) & (isnan(Deployment_roomcat_save.Distance_m_merged) | strcmpi(Deployment_roomcat_save.DistanceFlag, 'Out of range')));
%away_ind = (Deployment_roomcat_save.GPS_cat<at_home_gps) & (Deployment_roomcat_save.Distance_m_merged>at_home_prox | isnan(Deployment_roomcat_save.Distance_m_merged)) | ((Deployment_roomcat_save.Distance_m_merged>at_home_prox) & (isnan(Deployment_roomcat_save.GPS_cat))) | ((Deployment_roomcat_save.GPS_cat<at_home_gps) & (isnan(Deployment_roomcat_save.Distance_m_merged)));

%at_home_ind = Deployment_roomcat_save.GPS_cat>=at_home_gps | (~isnan(Deployment_roomcat_save.Distance_m_merged) & isnan(Deployment_roomcat_save.GPS_cat)) | ((Deployment_roomcat_save.GPS_cat>=at_home_gps) & (isnan(Deployment_roomcat_save.Distance_m_merged) | strcmpi(Deployment_roomcat_save.DistanceFlag, 'Out of range'))); at_home_loc_num=sum(at_home_ind); at_home_loc_perc=sum(at_home_ind)/length(at_home_ind)*100; disp([num2str(at_home_loc_num), ' time intervals confidently identified as "at home" or ', num2str(at_home_loc_perc,3), '%']);
%away_ind = Deployment_roomcat_save.GPS_cat<at_home_gps | (strcmpi(Deployment_roomcat_save.DistanceFlag, 'Out of range') & isnan(Deployment_roomcat_save.GPS_cat)); away_loc_num=sum(away_ind); away_loc_perc=sum(away_ind)/length(away_ind)*100; disp([num2str(away_loc_num), ' time intervals identified as "away" or ', num2str(away_loc_perc,3), '%']);

at_home_ind = Deployment_roomcat_save.GPS_cat>=at_home_gps | strcmpi(Deployment_roomcat_save.DistanceFlag,'In range'); at_home_loc_num=sum(at_home_ind); at_home_loc_perc=(sum(at_home_ind)/length(at_home_ind)*100); disp([num2str(at_home_loc_num), ' time intervals confidently identified as "at home" or ', num2str(at_home_loc_perc,3), '%']);
away_ind = Deployment_roomcat_save.GPS_cat<at_home_gps | (strcmpi(Deployment_roomcat_save.DistanceFlag, 'Out of buffer range')); away_loc_num=sum(away_ind); away_loc_perc=(sum(away_ind)/length(away_ind)*100); disp([num2str(away_loc_num), ' time intervals identified as "away" or ', num2str(away_loc_perc,3), '%']);
loc_out_of_range_ind = contains(Deployment_roomcat_save.DistanceFlag, 'Out');
loc_out_of_small_range_ind = contains(Deployment_roomcat_save.DistanceFlag, 'smaller');
loc_not_logging_ind = (strcmpi(Deployment_roomcat_save.DistanceFlag, 'Not Logging'));

catch
    disp('!!!Issue with location!!!')
end


locationoverlap = at_home_ind & away_ind; 
if nansum(locationoverlap)>0 %If there is overlap between 'at home' and 'away' defer to the GPS data
    
    disp([num2str(nansum(locationoverlap)), ' time intervals overlap "At Home" and "Away"....resolving with GPS...'])
    gps_athome = Deployment_roomcat_save.GPS_cat>=at_home_gps; %which GPS data are home
    gps_away = Deployment_roomcat_save.GPS_cat<at_home_gps; %which gps data are away
    
    home_gps_overlap = and(gps_athome,locationoverlap); %find where gps home data and overlapped classification data overlap
    away_gps_overlap = and(gps_away,locationoverlap); %find where gps away data and overlapped classification data overlap
    
    if nansum(home_gps_overlap)>0 %if those overlap data are from gps saying home
        at_home_ind = or(at_home_ind,home_gps_overlap); %set home indicies to 1
        away_ind(home_gps_overlap) = 0; %set other indicies to 0
    else
        if nansum(away_gps_overlap)>0 %if those overlap data are from gps saying away
            away_ind = or(away_ind,away_gps_overlap); %set away indicies to 1
            at_home_ind(away_gps_overlap) = 0; %set other indicies to 0
        end
    end
    
    locationoverlap = at_home_ind & away_ind; %check again for overlap of away and at home
    if nansum(locationoverlap)>0 %check again for overlap of away and at home
        disp('!!!More attention needed for this deployment!!!'); bleeerrrrg %This is bad news if we hit here
    else
        disp('...resolved overlapping classification') %Define the overlap statistics below 
        overlap_loc_num=sum(locationoverlap); overlap_loc_perc=(sum(locationoverlap)/length(locationoverlap)*100); disp([num2str(overlap_loc_num), ' time intervals overlap "At Home" and "Away" or ', num2str(overlap_loc_perc,3), '%']);
    end
else %Define the overlap statistics below 
    overlap_loc_num=sum(locationoverlap); overlap_loc_perc=(sum(locationoverlap)/length(locationoverlap)*100); disp([num2str(overlap_loc_num), ' time intervals overlap "At Home" and "Away" or ', num2str(overlap_loc_perc,3), '%']);
end

%Define not logging, out of home range (90meters), out of range and exluded (or undefined data) statistics below 
locationnotlogging = loc_not_logging_ind; not_logging_any_loc_num=sum(locationnotlogging); not_logging_any_loc_perc=(sum(locationnotlogging)/length(locationnotlogging)*100); disp([num2str(not_logging_any_loc_num), ' time intervals did not log proximity or GPS data or ', num2str(not_logging_any_loc_perc,3), '%']);
locationoutofhomerange = loc_out_of_range_ind ; out_of_home_range_loc_num=sum(locationoutofhomerange); out_of_home_range_loc_perc=(sum(locationoutofhomerange)/length(locationoutofhomerange)*100); disp([num2str(out_of_home_range_loc_num), ' time intervals were out of range of proximity logger or ', num2str(out_of_home_range_loc_perc,3), '%']);
locationoutofrange = loc_out_of_small_range_ind; out_of_range_loc_num=sum(locationoutofrange); out_of_range_loc_perc=(sum(locationoutofrange)/length(locationoutofrange)*100); disp([num2str(out_of_range_loc_num), ' time intervals were out of smaller-than-90m-range of proximity logger or ', num2str(out_of_range_loc_perc,3), '%']);
locationexcluded = ~at_home_ind & ~away_ind & ~loc_out_of_range_ind | loc_out_of_small_range_ind | loc_not_logging_ind; undefined_loc_num=sum(locationexcluded); undefined_loc_perc=(sum(locationexcluded)/length(locationexcluded)*100); disp([num2str(undefined_loc_num), ' time intervals have "undefined" locations or ', num2str(undefined_loc_perc,3), '%']);


Deployment_roomcat_save.LocationCat(at_home_ind)= 'At Home';
Deployment_roomcat_save.LocationCat(away_ind)= 'Away';
Deployment_roomcat_save.LocationCat(locationexcluded)= 'Undefined';

Deployment_roomcat_save.LocationCat(isundefined(Deployment_roomcat_save.LocationCat))= 'Undefined';


clear at_home_ind away_ind locationoverlap locationexcluded home_gps_overlap away_gps_overlap gps_athome gps_ayway



% % find where stove
% stove_ind = find(contains(Deployment_roomcat_save.Properties.VariableNames,strcat('Stove_',num2str(1)))); %Locate column number of each stove
% stove_stat_ind = [stove_ind(end),stove_ind(end)+4, stove_ind(end)+8,stove_ind(end)+12,stove_ind(end)+16,stove_ind(end)+20,stove_ind(end)+24]; %status columns of each of the 7 possible stoves
% stove_id_ind = [stove_ind(end)-2,stove_ind(end)+2, stove_ind(end)+6,stove_ind(end)+10,stove_ind(end)+14,stove_ind(end)+18,stove_ind(end)+22]; %status columns of each of the 7 possible stoves
% stove_ids = table2array(table(Deployment_roomcat_save.(stove_id_ind(1))(1),Deployment_roomcat_save.(stove_id_ind(2))(1),Deployment_roomcat_save.(stove_id_ind(3))(1),Deployment_roomcat_save.(stove_id_ind(4))(1),Deployment_roomcat_save.(stove_id_ind(5))(1),Deployment_roomcat_save.(stove_id_ind(6))(1),Deployment_roomcat_save.(stove_id_ind(7))(1))); %stove Ids from all possible 7 stoves
% stove_ids(cellfun(@(stove_ids) any(isnan(stove_ids)),stove_ids)) = [];

%%  CookingCat

try
%Using categorical variables for stove_status columns and stove type columns
any_tsf_on = (ismember(Deployment_roomcat_save.Stove_1_type,'TSF') & ismember(Deployment_roomcat_save.Stove_1_status,'Cooking')) | (ismember(Deployment_roomcat_save.Stove_2_type,'TSF') & ismember(Deployment_roomcat_save.Stove_2_status,'Cooking')) | (ismember(Deployment_roomcat_save.Stove_3_type,'TSF') & ismember(Deployment_roomcat_save.Stove_3_status,'Cooking')) | (ismember(Deployment_roomcat_save.Stove_4_type,'TSF') & ismember(Deployment_roomcat_save.Stove_4_status,'Cooking')) | (ismember(Deployment_roomcat_save.Stove_5_type,'TSF') & ismember(Deployment_roomcat_save.Stove_5_status,'Cooking')) | (ismember(Deployment_roomcat_save.Stove_6_type,'TSF') & ismember(Deployment_roomcat_save.Stove_6_status,'Cooking')) |(ismember(Deployment_roomcat_save.Stove_7_type,'TSF') & ismember(Deployment_roomcat_save.Stove_7_status,'Cooking'));
any_clpt_on = (ismember(Deployment_roomcat_save.Stove_1_type,'Coalpot') & ismember(Deployment_roomcat_save.Stove_1_status,'Cooking')) | (ismember(Deployment_roomcat_save.Stove_2_type,'Coalpot') & ismember(Deployment_roomcat_save.Stove_2_status,'Cooking')) | (ismember(Deployment_roomcat_save.Stove_3_type,'Coalpot') & ismember(Deployment_roomcat_save.Stove_3_status,'Cooking')) | (ismember(Deployment_roomcat_save.Stove_4_type,'Coalpot') & ismember(Deployment_roomcat_save.Stove_4_status,'Cooking')) | (ismember(Deployment_roomcat_save.Stove_5_type,'Coalpot') & ismember(Deployment_roomcat_save.Stove_5_status,'Cooking')) | (ismember(Deployment_roomcat_save.Stove_6_type,'Coalpot') & ismember(Deployment_roomcat_save.Stove_6_status,'Cooking')) |(ismember(Deployment_roomcat_save.Stove_7_type,'Coalpot') & ismember(Deployment_roomcat_save.Stove_7_status,'Cooking'));
any_ace_on = (ismember(Deployment_roomcat_save.Stove_1_type,'ACE') & ismember(Deployment_roomcat_save.Stove_1_status,'Cooking')) | (ismember(Deployment_roomcat_save.Stove_2_type,'ACE') & ismember(Deployment_roomcat_save.Stove_2_status,'Cooking')) | (ismember(Deployment_roomcat_save.Stove_3_type,'ACE') & ismember(Deployment_roomcat_save.Stove_3_status,'Cooking')) | (ismember(Deployment_roomcat_save.Stove_4_type,'ACE') & ismember(Deployment_roomcat_save.Stove_4_status,'Cooking')) | (ismember(Deployment_roomcat_save.Stove_5_type,'ACE') & ismember(Deployment_roomcat_save.Stove_5_status,'Cooking')) | (ismember(Deployment_roomcat_save.Stove_6_type,'ACE') & ismember(Deployment_roomcat_save.Stove_6_status,'Cooking')) |(ismember(Deployment_roomcat_save.Stove_7_type,'ACE') & ismember(Deployment_roomcat_save.Stove_7_status,'Cooking'));
any_lpg_on = (ismember(Deployment_roomcat_save.Stove_1_type,'LPG') & ismember(Deployment_roomcat_save.Stove_1_status,'Cooking')) | (ismember(Deployment_roomcat_save.Stove_2_type,'LPG') & ismember(Deployment_roomcat_save.Stove_2_status,'Cooking')) | (ismember(Deployment_roomcat_save.Stove_3_type,'LPG') & ismember(Deployment_roomcat_save.Stove_3_status,'Cooking')) | (ismember(Deployment_roomcat_save.Stove_4_type,'LPG') & ismember(Deployment_roomcat_save.Stove_4_status,'Cooking')) | (ismember(Deployment_roomcat_save.Stove_5_type,'LPG') & ismember(Deployment_roomcat_save.Stove_5_status,'Cooking')) | (ismember(Deployment_roomcat_save.Stove_6_type,'LPG') & ismember(Deployment_roomcat_save.Stove_6_status,'Cooking')) |(ismember(Deployment_roomcat_save.Stove_7_type,'LPG') & ismember(Deployment_roomcat_save.Stove_7_status,'Cooking'));
any_jmbo_on = (ismember(Deployment_roomcat_save.Stove_1_type,'Jumbo') & ismember(Deployment_roomcat_save.Stove_1_status,'Cooking')) | (ismember(Deployment_roomcat_save.Stove_2_type,'Jumbo') & ismember(Deployment_roomcat_save.Stove_2_status,'Cooking')) | (ismember(Deployment_roomcat_save.Stove_3_type,'Jumbo') & ismember(Deployment_roomcat_save.Stove_3_status,'Cooking')) | (ismember(Deployment_roomcat_save.Stove_4_type,'Jumbo') & ismember(Deployment_roomcat_save.Stove_4_status,'Cooking')) | (ismember(Deployment_roomcat_save.Stove_5_type,'Jumbo') & ismember(Deployment_roomcat_save.Stove_5_status,'Cooking')) | (ismember(Deployment_roomcat_save.Stove_6_type,'Jumbo') & ismember(Deployment_roomcat_save.Stove_6_status,'Cooking')) |(ismember(Deployment_roomcat_save.Stove_7_type,'Jumbo') & ismember(Deployment_roomcat_save.Stove_7_status,'Cooking'));
any_not_logging = ismember(Deployment_roomcat_save.Stove_1_status,'Not Logging') | ismember(Deployment_roomcat_save.Stove_2_status,'Not Logging') | ismember(Deployment_roomcat_save.Stove_3_status,'Not Logging') | ismember(Deployment_roomcat_save.Stove_4_status,'Not Logging') | ismember(Deployment_roomcat_save.Stove_5_status,'Not Logging') | ismember(Deployment_roomcat_save.Stove_6_status,'Not Logging') | ismember(Deployment_roomcat_save.Stove_7_status,'Not Logging');

any_stove_not_logging_num = sum(any_not_logging);
any_stove_not_logging_perc = (any_stove_not_logging_num/length(any_not_logging))*100;

disp([num2str(any_stove_not_logging_num), ' time points defined as having one or more monitored stoves "not logging" or ', num2str(any_stove_not_logging_perc), '%'])

catch
end


try
%NO STOVES ON
no_stoves_on_ind = ~any_tsf_on & ~any_clpt_on & ~any_ace_on & ~any_lpg_on & ~any_jmbo_on;

%SINGLE STOVE ON
%Only TSF on
tsf_on_ind = any_tsf_on & ~any_clpt_on & ~any_ace_on & ~any_lpg_on & ~any_jmbo_on;
%Only Coalpot on
clpt_on_ind = ~any_tsf_on & any_clpt_on & ~any_ace_on & ~any_lpg_on & ~any_jmbo_on;
%Only ACE one
ace_on_ind = ~any_tsf_on & ~any_clpt_on & any_ace_on & ~any_lpg_on & ~any_jmbo_on;
%Only LPG on
lpg_on_ind = ~any_tsf_on & ~any_clpt_on & ~any_ace_on & any_lpg_on & ~any_jmbo_on;
%Only Jumbo on
jmbo_on_ind = ~any_tsf_on & ~any_clpt_on & ~any_ace_on & ~any_lpg_on & any_jmbo_on;

%COMBO STOVES ON
%Only TSF and Coalpot on
tsf_and_clpt_on_ind = any_tsf_on & any_clpt_on & ~any_ace_on & ~any_lpg_on & ~any_jmbo_on;
%Only TSF and ACE on
tsf_and_ace_on_ind = any_tsf_on & ~any_clpt_on & any_ace_on & ~any_lpg_on & ~any_jmbo_on;
%Only TSF and Jumbo on
tsf_and_jmbo_on_ind = any_tsf_on & ~any_clpt_on & ~any_ace_on & ~any_lpg_on & any_jmbo_on;
%Only TSF and LPG on
tsf_and_lpg_on_ind = any_tsf_on & ~any_clpt_on & ~any_ace_on & any_lpg_on & ~any_jmbo_on;
%Only Coalpot and ACE on
clpt_and_ace_on_ind = ~any_tsf_on & any_clpt_on & any_ace_on & ~any_lpg_on & ~any_jmbo_on;
%Only Coalpot and Jumbo on
clpt_and_jmbo_on_ind = ~any_tsf_on & any_clpt_on & ~any_ace_on & ~any_lpg_on & any_jmbo_on;
%Only Coalpot and LPG on
clpt_and_lpg_on_ind = ~any_tsf_on & any_clpt_on & ~any_ace_on & any_lpg_on & ~any_jmbo_on;
%Only Ace and Jumbo on
ace_and_jmbo_on_ind = ~any_tsf_on & ~any_clpt_on & any_ace_on & ~any_lpg_on & any_jmbo_on;
%Only ACE and LPG on
ace_and_lpg_on_ind = ~any_tsf_on & ~any_clpt_on & any_ace_on & any_lpg_on & ~any_jmbo_on;
%Ony Jumbo and LPG on
jmbo_and_lpg_on_ind = ~any_tsf_on & ~any_clpt_on & ~any_ace_on & any_lpg_on & any_jmbo_on;


%Make CookingCat classifications
Deployment_roomcat_save.CookingCat(no_stoves_on_ind)= 'no stove on';
Deployment_roomcat_save.CookingCat(tsf_on_ind)= 'only TSF on';
Deployment_roomcat_save.CookingCat(clpt_on_ind)= 'only coalpot on';
Deployment_roomcat_save.CookingCat(ace_on_ind)= 'only ACE on';
Deployment_roomcat_save.CookingCat(lpg_on_ind)= 'only LPG on';
Deployment_roomcat_save.CookingCat(jmbo_on_ind)= 'only Jumbo on';
Deployment_roomcat_save.CookingCat(tsf_and_clpt_on_ind)= 'TSF and coalpot on';
Deployment_roomcat_save.CookingCat(tsf_and_ace_on_ind)= 'TSF and ACE on';
Deployment_roomcat_save.CookingCat(tsf_and_jmbo_on_ind)= 'TSF and Jumbo on';
Deployment_roomcat_save.CookingCat(tsf_and_lpg_on_ind)= 'TSF and LPG on';
Deployment_roomcat_save.CookingCat(clpt_and_ace_on_ind)= 'coalpot and ACE on';
Deployment_roomcat_save.CookingCat(clpt_and_jmbo_on_ind)= 'coalpot and Jumbo on';
Deployment_roomcat_save.CookingCat(clpt_and_lpg_on_ind)= 'coalpot and LPG on';
Deployment_roomcat_save.CookingCat(ace_and_jmbo_on_ind)= 'ACE and Jumbo on';
Deployment_roomcat_save.CookingCat(ace_and_lpg_on_ind)= 'ACE and LPG on';
Deployment_roomcat_save.CookingCat(jmbo_and_lpg_on_ind)= 'Jumbo and LPG on';

disp([num2str(sum(isundefined(Deployment_roomcat_save.CookingCat))), ' cooking category time intervals are "undefined", or ' num2str(sum(isundefined(Deployment_roomcat_save.CookingCat))/length(Deployment_roomcat_save.CookingCat)*100),'%'])

Deployment_roomcat_save.CookingCat(isundefined(Deployment_roomcat_save.CookingCat))= 'Undefined';

catch
    disp('Issue encountered classifying cooking activity')
end


% Final Activity categorization
try
cookingcat_temp = cellstr(Deployment_roomcat_save.CookingCat);
locationcat_temp = cellstr(Deployment_roomcat_save.LocationCat);
proximity_temp = cellstr(Deployment_roomcat_save.ProximityCat);
activity_temp = strcat(locationcat_temp,{' with '},cookingcat_temp, {' '}, proximity_temp);

%activity_temp(contains(activity_temp,'Undefined') & contains(activity_temp,'Out of Range'))={'Out of Range'};
%activity_temp(contains(activity_temp,'Undefined') & ~contains(activity_temp,'Out of Range'))={'Undefined'};
activity_temp(contains(activity_temp,'Undefined'))={'Undefined'};


Deployment_roomcat_save.Activity = categorical(activity_temp);

catch
    disp('!!!Issue encountered classifying overall activity!!!')
end


%Season and urban/rural classification moved to add_HH_User_data function


%% Save percentages of locations and proximity categories to a master log

%Proximity

class_log.deployment_poor_beacon_flag(yyy)=dep_beacon_flag;

class_log.Proximity_very_near_number(yyy) = very_near_num;
class_log.Proximity_very_near_percentage(yyy)= very_near_perc;

class_log.Proximity_near_number(yyy) = near_num;
class_log.Proximity_near_percentage(yyy)= near_perc;

class_log.Proximity_in_vicinity_number(yyy) = vicinity_num;
class_log.Proximity_in_vicinity_percentage(yyy)= vicinity_perc;

class_log.Proximity_out_of_range_number(yyy) = out_of_range_num;
class_log.Proximity_out_of_range_percentage(yyy)= out_of_range_perc;

class_log.Proximity_out_of_smaller_than_buffer_range_number(yyy) = out_of_small_range_num;
class_log.Proximity_out_of_smaller_than_buffer_range_percentage(yyy) = out_of_small_range_perc;

class_log.Proximity_out_of_buffer_range_number(yyy) = out_of_home_range_num;
class_log.Proximity_out_of_buffer_range_percentage(yyy) = out_of_home_range_perc;

class_log.Proximity_undefined_number(yyy) = undefined_prox_num;
class_log.Proximity_undefined_percentage(yyy)= undefined_prox_perc;

%Location
class_log.AtHome_number(yyy) = at_home_loc_num;
class_log.AtHome_percentage(yyy) = at_home_loc_perc;

class_log.Away_number(yyy) = away_loc_num;
class_log.Away_percentage(yyy) = away_loc_perc;

class_log.NotLoggingGPSorProx_number(yyy) = not_logging_any_loc_num;
class_log.NotLoggingGPSorProx_percentage(yyy) = not_logging_any_loc_perc;

class_log.Location_out_of_range_number(yyy) = out_of_range_loc_num;
class_log.Location_out_of_range_percentage(yyy) = out_of_range_loc_perc;

class_log.Location_out_of_home_range_number(yyy) = out_of_home_range_loc_num;
class_log.Location_out_of_home_range_percentage(yyy) = out_of_home_range_loc_perc;

class_log.Location_overlap_number(yyy) = overlap_loc_num;
class_log.Location_overlap_percentage(yyy) = overlap_loc_perc;

class_log.Location_undefined_number(yyy) = undefined_loc_num;
class_log.Location_undefined_percentage(yyy) = undefined_loc_perc;

%Stoves
class_log.Cooking_not_logging_stove(yyy) = any_stove_not_logging_num;
class_log.Cooking_not_logging_stove_percentage(yyy) = any_stove_not_logging_perc;



%% Does some basic plotting if 'wantsomeplots' set to 1 (at the top of this code)

if wantsomeplots==1;

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
                    %pause(1);
                    close
                    
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
                    %pause(1);
                    close
                    
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
                    %pause(1);
                    close
                    
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
                    %pause(1);
                    close
                    
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
                    %pause(1);
                    close
                    
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
                    %pause(1);
                    close
                    
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
                    %pause(1); 
                    close
                    
                    disp('Images saved to pdf report...')
                    catch
                        disp('Issue saving images for this deployment...')
                    end

end


% Reassign overall comliance
try
Deployment_roomcat_save.Overall_Compliance(Deployment_roomcat_save.Overall_Compliance<0.5)=0; %recompute binary
Deployment_roomcat_save.Overall_Compliance(Deployment_roomcat_save.Overall_Compliance>=0.5)=1; %recompute binary
catch
    disp('didnt round Overall_Compliance')
end

try
Deployment_roomcat_save.PM_compliance(Deployment_roomcat_save.PM_compliance<0.5)=0; %recompute binary
Deployment_roomcat_save.PM_compliance(Deployment_roomcat_save.PM_compliance>=0.5)=1; %recompute binary
catch
    disp('didnt round PM_compliance')
end

try
Deployment_roomcat_save.Beacon_compliance(Deployment_roomcat_save.Beacon_compliance<0.5)=0; %recompute binary
Deployment_roomcat_save.Beacon_compliance(Deployment_roomcat_save.Beacon_compliance>=0.5)=1; %recompute binary
catch
    disp('didnt round Beacon_compliance')
end




Deployment_roomcat_save_temp = Deployment_roomcat_save;


end

