function[Deployment_roomcat_save_temp, hh_nomatch, user_nomatch] = add_deployment_data(Deployment_roomcat_save, bname, hh_nomatch, user_nomatch, HH_data, User_data)

% adduserdata by Evan Coffey


%% Create the new column headers for HH (and User info)
clear hhind

Deployment_roomcat_save.Stovegroup = NaN(height(Deployment_roomcat_save),1);
Deployment_roomcat_save.Groupname = string(NaN(height(Deployment_roomcat_save),1));
Deployment_roomcat_save.Total_price = NaN(height(Deployment_roomcat_save),1);
Deployment_roomcat_save.LocationType = string(NaN(height(Deployment_roomcat_save),1));
Deployment_roomcat_save.Season = string(NaN(height(Deployment_roomcat_save),1));
Deployment_roomcat_save.HourOfDay = NaN(height(Deployment_roomcat_save),1);


%add more columns as seen fit (age, sex, etc.)
Deployment_roomcat_save.PermID = string(NaN(height(Deployment_roomcat_save),1));
Deployment_roomcat_save.Gender = string(NaN(height(Deployment_roomcat_save),1));
Deployment_roomcat_save.Age = NaN(height(Deployment_roomcat_save),1);
Deployment_roomcat_save.Age_cat = string(NaN(height(Deployment_roomcat_save),1));
Deployment_roomcat_save.PrimaryCook = string(NaN(height(Deployment_roomcat_save),1));


%% Now identify the HH and User from Deployment
HHID = char(Deployment_roomcat_save.HouseholdID(1));
USERID = Deployment_roomcat_save.UserID(1);
DATEDEP = datestr(Deployment_roomcat_save.TimeMinuteRounded(1),'dd-mmm-yyyy');



%Find matching info in HH_data sheet
try
hhind = find(contains(HH_data.hhid,HHID));
    if isempty(hhind)
        hhind = find(strcmpi(HH_data.hhid,string(HHID(1:5))));
    end
    if isempty(hhind)
        hhind = find(strcmpi(HH_data.hhid,string(HHID)));
    end
catch
    disp(['!!!Problems encountered finding details for ' char(bname), ' in HH ', char(HHID) ,'!!!'])
end

%Find matching info in User_data sheet
try
    
    if ~contains(USERID, '_PM')
userind = find(strcmpi(User_data.CurrenttempID,USERID));
dateind = find(strcmpi(string(datestr(User_data.Tempage3)),DATEDEP));
matchedind = userind(ismember(userind,dateind));
isdupind = User_data.IsthisaduplicatesampleakacontainsPM(matchedind)~=1;
matchedind = matchedind(isdupind);
    else
        
        USERID = string(USERID);
userind = find(strncmpi(User_data.CurrenttempID,USERID,9));
dateind = find(strcmpi(string(datestr(User_data.Tempage3)),DATEDEP));
matchedind = userind(ismember(userind,dateind));
isdupind = User_data.IsthisaduplicatesampleakacontainsPM(matchedind)==1;
matchedind = matchedind(isdupind);        
    end
   
%     if isempty(matchedind)
%         matchedind = find(strcmpi(User_data.CurrenttempID,string(USERID))) & find(DATEDEP==User_data.Tempage3);
%     end
    
catch
    disp(['!!!Problems encountered finding details for ' char(bname), ' with User ', char(USERID) ,'!!!'])
end


%% HH data matching
if ~isempty(hhind) % && ~isempty(usind)

        %Populate the Deployment columns
        try
        % Stovegroup number
        Deployment_roomcat_save.Stovegroup(1:end) = HH_data.stove_group(hhind);
        if isnan(Deployment_roomcat_save.Stovegroup(1))
            Deployment_roomcat_save.Stovegroup(1:end) = string(HH_data.stove_group(hhind));
        end
        % Stove group name
        Deployment_roomcat_save.Groupname(1:end) = HH_data.groupname{hhind};
        Deployment_roomcat_save.Groupname = cellstr(Deployment_roomcat_save.Groupname);
        %Total price
        Deployment_roomcat_save.Total_price(1:end) = HH_data.total_price(hhind);
        catch
            disp('An issue arose while assigning HH data to this deployment')
        end
            
        hh_nomatch = hh_nomatch; %no increment
else %HH match conditional
        disp(['!!!Household: ', char(HHID), ' was not found in HH data list - check HH_data.xlsx!!!'])
        hh_nomatch = hh_nomatch+1; %nomatch increments by 1
end %HH match conditional




%% User data matching
if ~isempty(matchedind) % && ~isempty(usind)

    try
        %Populate the Deployment columns
        Deployment_roomcat_save.PermID(:) = User_data.IndividID(matchedind);
        Deployment_roomcat_save.Gender(:) = User_data.Female_0(matchedind);
        Deployment_roomcat_save.Age(:) = User_data.Age_years(matchedind);
        Deployment_roomcat_save.Age_cat(:) = User_data.Lessthan30_0(matchedind);
        Deployment_roomcat_save.PrimaryCook(:) = User_data.PrimaryCook_1(matchedind);
        
        Deployment_roomcat_save.Gender(strcmpi(Deployment_roomcat_save.Gender,'0'))='Female';
        Deployment_roomcat_save.Gender(strcmpi(Deployment_roomcat_save.Gender,'1'))='Male';
        Deployment_roomcat_save.Gender = categorical(Deployment_roomcat_save.Gender);
        
        Deployment_roomcat_save.Age_cat(strcmpi(Deployment_roomcat_save.Age_cat,'1'))='30orOver';
        Deployment_roomcat_save.Age_cat(strcmpi(Deployment_roomcat_save.Age_cat,'0'))='Under30';
        Deployment_roomcat_save.Age_cat = categorical(Deployment_roomcat_save.Age_cat);
        
        Deployment_roomcat_save.PrimaryCook(strcmpi(Deployment_roomcat_save.PrimaryCook,'0'))='No';
        Deployment_roomcat_save.PrimaryCook(strcmpi(Deployment_roomcat_save.PrimaryCook,'1'))='Yes';
        Deployment_roomcat_save.PrimaryCook = categorical(Deployment_roomcat_save.PrimaryCook);
        
        Deployment_roomcat_save.PermID(ismissing(Deployment_roomcat_save.PermID))='';

        user_nomatch = user_nomatch; %no increment
    catch
        disp(['An issue arose while assigning User data to deployment:' char(bname)])
    end
    
    
else %HH match conditional
        disp(['!!!User: ', char(USERID), ' from ', char(DATEDEP), ' was not found in User data list - check User_data.xlsx!!!'])
        user_nomatch = user_nomatch+1; %nomatch increments by 1
        Deployment_roomcat_save.Gender = categorical(Deployment_roomcat_save.Gender);
        Deployment_roomcat_save.Age_cat = categorical(Deployment_roomcat_save.Age_cat);
        Deployment_roomcat_save.PrimaryCook = categorical(Deployment_roomcat_save.PrimaryCook);
        Deployment_roomcat_save.PermID(ismissing(Deployment_roomcat_save.PermID))='';


end %HH match conditional



%% Regardless of whether or not a HHID match was made, determine season, hour of day and Urban/Rural


 % Season, hour of day and urban/rural calssification [NEED TO DISCUSS SEASON CLASSIFICATIONS FOR KINTAMPO AREA]
            try
                HHIDnan = find(cell2mat(cellfun(@(x)any(isnan(x)),Deployment_roomcat_save.HouseholdID,'UniformOutput',false)));
                Deployment_roomcat_save.HouseholdID(HHIDnan) = {'no match'};
                Deployment_roomcat_save.LocationType = cellstr(Deployment_roomcat_save.HouseholdID);
                Deployment_roomcat_save.LocationType(strncmpi(Deployment_roomcat_save.HouseholdID,'CA',2) | contains(Deployment_roomcat_save.Groupname,'Kintampo')) = {'Urban'};
                Deployment_roomcat_save.LocationType(~strncmpi(Deployment_roomcat_save.HouseholdID,'CA',2) & ~contains(Deployment_roomcat_save.Groupname,'Kintampo') & ~contains(Deployment_roomcat_save.HouseholdID,'no match')) = {'Rural'};
                %disp('LocationType successfully classified')
            catch
                disp(['!!!Issue encountered classifying location type (urban/rural) for: ' bname, '!!!'])
            end
                Deployment_roomcat_save.LocationType = categorical(Deployment_roomcat_save.LocationType);
                Deployment_roomcat_save.Groupname = categorical(Deployment_roomcat_save.Groupname);

               
            try
                whatweek = week(datetime(Deployment_roomcat_save.TimeMinuteRounded, 'ConvertFrom', 'datenum'));
                Deployment_roomcat_save.Season(:) = {'Transition'};
                Deployment_roomcat_save.Season(whatweek>14 & whatweek<23) = {'Light Rainy'}; %April to June also known as light_rainy
                Deployment_roomcat_save.Season(whatweek>=23 & whatweek<40) = {'Heavy Rainy'}; %June to october also known as heavy rainy
                Deployment_roomcat_save.Season(whatweek>=44 | whatweek<7) = {'Harmattan_bushburning'}; % November to mid Feb.
                Deployment_roomcat_save.Season(whatweek>=7 & whatweek<=14 ) = {'Dry'}; %Mid Feb to April also known as hot and dry
                %disp('Season successfully classified')
            catch
                disp(['!!!Issue encountered classifying season for: ' bname, '!!!']) 
            end
               Deployment_roomcat_save.Season = categorical(Deployment_roomcat_save.Season);

               
            try
               Deployment_roomcat_save.HourOfDay = hour(datetime(Deployment_roomcat_save.TimeMinuteRounded, 'ConvertFrom', 'datenum'));
            catch
               disp(['!!!Issue encountered classifying hour of day for: ' bname, '!!!']) 
            end
         
          
%% BeaconLogger 1 and 2 Flag and create Merged Beacons_flag
    
 try  
    %Determine how many beaconloggers were recorded logging
    
    flagstring = string(Deployment_roomcat_save.Flag);
    
    
    splitflag = split(flagstring,',');
    splitsize = size(splitflag);
    numbeaconsloggers = splitsize(1,2)/2;
    
    
    if numbeaconsloggers>1
    BeaconLoggertable = array2table(splitflag, 'VariableNames',{'BeaconLogger_1_flag', 'BeaconLogger_2_flag', 'BeaconLogger_1_ID', 'BeaconLogger_2_ID'});
    BeaconLoggertable.BeaconLogger_1_flag = categorical(BeaconLoggertable.BeaconLogger_1_flag);
    BeaconLoggertable.BeaconLogger_2_flag = categorical(BeaconLoggertable.BeaconLogger_2_flag);
%     cats1 = categories(BL1_temp); num1cats = length(cats1);
%     cats2 = categories(BL2_temp); num2cats = length(cats2);

    else
    BeaconLoggertable = array2table(splitflag, 'VariableNames',{'BeaconLogger_1_flag', 'BeaconLogger_1_ID'}); 
    BeaconLoggertable.BeaconLogger_1_flag = categorical(BeaconLoggertable.BeaconLogger_1_flag);
%     cats1 = categories(BL1_temp); num1cats = length(cats1);
    BeaconLoggertable.BeaconLogger_2_flag = categorical(NaN(height(Deployment_roomcat_save),1));
    BeaconLoggertable.BeaconLogger_2_ID(:) = {"None"};
    BeaconLoggertable = movevars(BeaconLoggertable,'BeaconLogger_1_ID','After','BeaconLogger_2_flag');

    end  
       
 %Insert these table values into the Deployment_roomcat_save table
 Deployment_roomcat_save = [Deployment_roomcat_save, BeaconLoggertable];
 
 %Define the Beacons_flag
 Deployment_roomcat_save.Beacons_flag = NaN(height(Deployment_roomcat_save),1);  
 
 %Rename the Flag variable to Proximity_flag
 %Deployment_roomcat_save.Properties.VariableNames{'Flag'} = 'Proximity_flag';

 %Create new proximity flag variable
 Deployment_roomcat_save.Proximity_flag = Deployment_roomcat_save.Flag;
 
 catch
    disp('!!!Issue encountered making proximity (BeaconLogger) flags!!!') 
     
 end
 clear splitflag splitsize flagstring numbeaconsloggers BeaconLoggertable
            
            
% Save out the deployment
Deployment_roomcat_save_temp = Deployment_roomcat_save;            
            
            

disp('........................................')
            
            
end %FUNCTION
    







































