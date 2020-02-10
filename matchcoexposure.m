function [Deployment_roomcat_save_temp, nomatch] = matchcoexposure(Deployment_roomcat_save, Pathnames2, allFiles2, Deployment, bname, nomatch, AA_COsmoothing, rollingtime, AA_Lascar_LOQ_replace, Lascar_LOQ)
%matchcoexposure by Evan Coffey

%   This function matches CO exposure to user beacon timeseries for
%   deployment matches

%inputs:
% a single user beacon deployment entry (table)
% filenames and pathnames for all calibrated Lascar data

%outputs:
% time-matched beacon deployment with CO exposure

%%
% Create a columns in the Deployment_roomcat_save for up to two Lascar timeseries (calibrated and raw) with flags to go
Deployment_roomcat_save.Calibrated_LascarCO_ppm_1 = NaN(height(Deployment_roomcat_save),1);
Deployment_roomcat_save.Calibrated_LascarCO_ppm_1_flag = NaN(height(Deployment_roomcat_save),1);
Deployment_roomcat_save.Raw_LascarCO_ppm_1 = NaN(height(Deployment_roomcat_save),1);
Deployment_roomcat_save.Lascar_1_Name = NaN(height(Deployment_roomcat_save),1);


Deployment_roomcat_save.Calibrated_LascarCO_ppm_2 = NaN(height(Deployment_roomcat_save),1);
Deployment_roomcat_save.Calibrated_LascarCO_ppm_2_flag = NaN(height(Deployment_roomcat_save),1);
Deployment_roomcat_save.Raw_LascarCO_ppm_2 = NaN(height(Deployment_roomcat_save),1);
Deployment_roomcat_save.Lascar_2_Name = NaN(height(Deployment_roomcat_save),1);


%Use the start and end times of the beacon deployment
ts = datetime(Deployment_roomcat_save.TimeMinuteRounded(1),'ConvertFrom', 'datenum');
te = datetime(Deployment_roomcat_save.TimeMinuteRounded(end),'ConvertFrom', 'datenum');

disp([' from ', datestr(ts), ' to ', datestr(te)])


%Grab the UserID from the Beacon deployment - this is the key variable for which we are searching
%for in the Deployment Log
User = Deployment_roomcat_save.UserID(1);

%Locate the number of rows (# of uique Deployments) where this user comes up
Userind = find(strcmp(Deployment.User,User));

%If no matching rows arize, display a message and skip ahead else continue
if ~any(Userind)
    disp('!!!No users matching this Beacon file were found in the exposure Deployment!!!')
    nomatch = nomatch+1;
else

    
%Loop through the deployments that match that user and find time intervals
for j=1:length(Userind)
    try
    d_ts = datetime(Deployment.Date_TimeStart(Userind(j)));
    d_te = datetime(Deployment.Date_TimeEnd(Userind(j)));
    catch
    d_ts = datetime(Deployment.Date_TimeStart(Userind(j)),'ConvertFrom' ,'datenum');
    d_te = datetime(Deployment.Date_TimeEnd(Userind(j)),'ConvertFrom' ,'datenum');
    end
    
    %Add a time buffer in case the deployment time is slightly different
    
    d_ts_buffup = d_ts+minutes(300); %Is 5 hour buffer enough??? too much??
    d_ts_buffdown = d_ts-minutes(300);
    
    if isbetween(ts,d_ts_buffdown,d_ts_buffup)
        Userind_match(j)=Userind(j);
        fprintf('Match found for user %s \n', char(User));
    else
        Userind_match(j)=NaN;
    end
end
    

% Clear Userind_match that were not in the timeframe above that were set to NaN
Userind_match = Userind_match(~isnan(Userind_match));

%Now that we know which Lascars correspond to this deployment, load only
%these monitor(s) lascar files
lname = Deployment.(1)(Userind_match);

%if there are two Lascars deployed on this individual check to make sure they aren't duplicate entries
if length(lname)> 1 
    
if strcmp(lname(1),lname(2))
    disp(lname(1))
    disp(['!!!Duplicate error Lascar entry on Deployment row: ' num2str(Userind_match(2)),'!!!']);
    lname{2} = 'none'; %mark the second lascar name as 'none'
end
else
    lname{2,1} = 'none'; %mark the second lascar name as 'none'
end

%Display the names of the Lascars worn by this person
disp('Lascars worn by this individual: ');
disp(char(lname));


%WORK ON LASCAR 1 FIRST

 % Locate the position of the Lascar calibrated files that share the name of the matched lascars
 try
lnamematch = find(contains({allFiles2.name}.',lname(1)));
 catch
     lnamematch = find(~cellfun(@isempty,regexpi({allFiles2.name}.',lname(1))));
 end
     
    
for j=1:length(lnamematch)
    %Loop through calibrated Lascar files for lnamematch(1) and match CO exposure to the room_cat
    
    if ~ismac
    try load(fullfile(allFiles2(lnamematch(j)).folder, allFiles2(lnamematch(j)).name))
    catch
        disp('!!!(PC) Error loading one or more matched Lascar file(s)!!!');
    end
    else
    try load(fullfile(Pathnames2, allFiles2(lnamematch(j)).name))
    catch
        disp('!!!(Mac) Error loading one or more matched Lascar file(s)!!!');
    end
    end
   
    saveset = dataset2table(saveset);
    saveset.TimeRounded = dateshift(datetime(saveset.Time,'ConvertFrom', 'datenum'), 'start', 'minute');

        try
            matchind = isbetween(saveset.TimeRounded,ts,te);
            numatch = sum(matchind); % number of minute matches
            
            if numatch>0
            disp([num2str(numatch), ' possible Beacon time matches found in: ']); disp(allFiles2(lnamematch(j)).name);
            
            %Change the rounded time back to datenum for matching
            saveset.TimeRounded = datenum(dateshift(datetime(saveset.Time,'ConvertFrom', 'datenum'), 'start', 'minute'));
            
            [C,ia,ib] = innerjoin(Deployment_roomcat_save,saveset,'LeftKeys',17, 'RightKeys',6);%The key from Deployment_roomcat_save is column 1 and the key from saveset is 6
            disp([num2str(length(ia)), ' Lascar CO time matches found with proximity data']);
            Deployment_roomcat_save.Calibrated_LascarCO_ppm_1(ia)=saveset.Calibrated(ib);
            Deployment_roomcat_save.Raw_LascarCO_ppm_1(ia)=saveset.Raw(ib);
            Deployment_roomcat_save.Lascar_1_Name = num2cell(Deployment_roomcat_save.Lascar_1_Name);
            Deployment_roomcat_save.Lascar_1_Name(:)=lname(1);
            Deployment_roomcat_save_temp = Deployment_roomcat_save;
            
            %else disp('No overlapping time found in:'); disp(allFiles2(lnamematch(j)).name);
            end 
        catch
            disp('!!!Some issue occurred finding matches with: ');
            disp(allFiles2(lnamematch(j)).name);
               
        end %try for joining data to deployment
 
end %lascar 1 filename loop
clear C saveset
     

%Were any matched data found?
if isnan(nanmean(Deployment_roomcat_save.Calibrated_LascarCO_ppm_1))
    disp('!!!No calibrated Lascar 1 data found - make sure data is up to date.')
end        




%WORK ON LASCAR 2 NOW
if length(lname)>1 && ~strcmp(lname(2),'none')
   
try
lnamematch = find(contains({allFiles2.name}.',lname(2)));
 catch
     lnamematch = find(~cellfun(@isempty,regexpi({allFiles2.name}.',lname(2))));
end

for jj=1:length(lnamematch)
    %Loop through calibrated Lascar files for lname(2) and match CO exposure to the room_cat
    
    
    if ~ismac
    try load(fullfile(allFiles2(lnamematch(jj)).folder, allFiles2(lnamematch(jj)).name))
    catch
        disp('!!!(PC) Error loading one or more matched Lascar file(s)!!!');
    end
    else
    try load(fullfile(Pathnames2, allFiles2(lnamematch(jj)).name))
    catch
        disp('!!!(Mac) Error loading one or more matched Lascar file(s)!!!');
    end
    end
    
    saveset = dataset2table(saveset);
    saveset.TimeRounded = dateshift(datetime(saveset.Time,'ConvertFrom', 'datenum'), 'start', 'minute');

        try
            matchind = isbetween(saveset.TimeRounded,ts,te);
            numatch = sum(matchind); % number of minute matches
            
            if numatch>0
            disp([num2str(numatch), ' possible Beacon time matches found in: ']); disp(allFiles2(lnamematch(jj)).name);
            saveset.TimeRounded = datenum(dateshift(datetime(saveset.Time,'ConvertFrom', 'datenum'), 'start', 'minute'));
            [C,ia,ib] = innerjoin(Deployment_roomcat_save,saveset,'LeftKeys',17, 'RightKeys',6); %The key from Deployment_roomcat_save is column 1 and the key from saveset is 6
            disp([num2str(length(ia)), ' Lascar CO time matches found with proximity data']);
            Deployment_roomcat_save.Calibrated_LascarCO_ppm_2(ia)=saveset.Calibrated(ib);
            Deployment_roomcat_save.Raw_LascarCO_ppm_2(ia)=saveset.Raw(ib);
            Deployment_roomcat_save.Lascar_2_Name = num2cell(Deployment_roomcat_save.Lascar_2_Name);
            Deployment_roomcat_save.Lascar_2_Name(:)=lname(2);
            Deployment_roomcat_save_temp = Deployment_roomcat_save;
        
            
            %else disp('No overlapping time found in:'); disp(allFiles2(lnamematch(jj)).name);
            end 
        catch
            disp('!!!Some issue occurred finding matches with: ');
            disp(allFiles2(lnamematch(jj)).name);
        end

end %lascar 2 filename loop
clear C saveset


%Were any matched data found?
if isnan(nanmean(Deployment_roomcat_save.Calibrated_LascarCO_ppm_2))
    disp('!!!No calibrated Lascar 2 data found - make sure data is up to date.')
end   



end % one or two lascars conditional
%disp('........................................')

end
Deployment_roomcat_save_temp = Deployment_roomcat_save;

  
   if AA_COsmoothing==1
       try
       if ~isnan(nanmean(Deployment_roomcat_save_temp.Calibrated_LascarCO_ppm_1))
       Deployment_roomcat_save_temp.Calibrated_LascarCO_ppm_1 = movmean(Deployment_roomcat_save_temp.Calibrated_LascarCO_ppm_1,rollingtime);
       disp(['Lascar 1 data smoothed using ',num2str(rollingtime),' minute rolling average'])
       else
           disp('Lascar 1 values all NaN')
       end
       if ~isnan(nanmean(Deployment_roomcat_save_temp.Calibrated_LascarCO_ppm_2))
       Deployment_roomcat_save_temp.Calibrated_LascarCO_ppm_2 = movmean(Deployment_roomcat_save_temp.Calibrated_LascarCO_ppm_2,rollingtime);
       disp(['Lascar 2 data smoothed using ',num2str(rollingtime),' minute rolling average'])
       else
           disp('Lascar 2 values all NaN')
       end
       catch
           disp('!!!Issue smoothing CO data!!!')
       end
   end
   
   
if AA_Lascar_LOQ_replace==1
        try 
            if~isnan(nanmean(Deployment_roomcat_save_temp.Calibrated_LascarCO_ppm_1))
            Deployment_roomcat_save_temp.Calibrated_LascarCO_ppm_1(Deployment_roomcat_save_temp.Calibrated_LascarCO_ppm_1<Lascar_LOQ)=Lascar_LOQ;
            disp(['Lascar 1 values below the LOQ: ',num2str(Lascar_LOQ),' ppm, have been replaced with the LOQ'])
            else
            disp('Lascar 1 values all NaN - no LOQ replacement')
            end
            
            if~isnan(nanmean(Deployment_roomcat_save_temp.Calibrated_LascarCO_ppm_2))
            Deployment_roomcat_save_temp.Calibrated_LascarCO_ppm_2(Deployment_roomcat_save_temp.Calibrated_LascarCO_ppm_2<Lascar_LOQ)=Lascar_LOQ;
            disp(['Lascar 2 values below the LOQ: ',num2str(Lascar_LOQ),' ppm, have been replaced with the LOQ'])
            else
            disp('Lascar 2 values all NaN - no LOQ replacement')
            end
        catch
             disp('!!!Issue LOQ replacemnt of CO data!!!')
        end
end
    

disp('........................................')

end




















