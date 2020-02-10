function[Deployment_roomcat_save_temp, nomatch] = adduserdata(Deployment_roomcat_save, bname,nomatch, HH_data, User_data)

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
Deployment_roomcat_save.Gender = string(NaN(height(Deployment_roomcat_save),1));
Deployment_roomcat_save.Age = NaN(height(Deployment_roomcat_save),1);
Deployment_roomcat_save.Age_cat = string(NaN(height(Deployment_roomcat_save),1));


%% Now identify the HH and User from Deployment
HHID = char(Deployment_roomcat_save.HouseholdID(1));
USERID = Deployment_roomcat_save.UserID(1);


%Find matching info in HH_data sheet
try
hhind = find(contains(HH_data.hhid,HHID));
    if isempty(hhind)
        hhind = find(strcmp(HH_data.hhid,string(HHID(1:5))));
    end
    if isempty(hhind)
        hhind = find(strcmp(HH_data.hhid,string(HHID)));
    end
catch
    disp(['!!!Problems encountered finding details for ' bname, ' in HH ', HHID ,'!!!'])
end

%Find matching info in User_data sheet

% try
% hhind = find(contains(HH_data.hhid,HHID));
%     if isempty(hhind)
%         hhind = find(strcmp(HH_data.hhid,string(HHID(1:5))));
%     end
%     if isempty(hhind)
%         hhind = find(strcmp(HH_data.hhid,string(HHID)));
%     end
% catch
%     disp(['!!!Problems encountered finding details for ' bname, ' in HH ', HHID ,'!!!'])
% end




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

        
        % Add User level data here
        
        
        
        

            
        % Save out the deployment
        Deployment_roomcat_save_temp = Deployment_roomcat_save;
        nomatch = nomatch; %no increment
       
else %HH match conditional
        disp(['!!!Household: ', HHID, ' was not found in HH data list - check HH_data.xlsx!!!'])
        nomatch = nomatch+1; %nomatch increments by 1
        Deployment_roomcat_save_temp = Deployment_roomcat_save;
end %HH match conditional


%% Regardless of whether or not a HHID match was made, determine season, hour of day and Urban/Rural


 % Season, hour of day and urban/rural calssification [NEED TO DISCUSS SEASON CLASSIFICATIONS FOR KINTAMPO AREA]
            try
                HHIDnan = find(cell2mat(cellfun(@(x)any(isnan(x)),Deployment_roomcat_save.HouseholdID,'UniformOutput',false)));
                Deployment_roomcat_save.HouseholdID(HHIDnan) = {'no match'};
                Deployment_roomcat_save.LocationType = cellstr(Deployment_roomcat_save.HouseholdID);
                Deployment_roomcat_save.LocationType(contains(Deployment_roomcat_save.HouseholdID,'CA') | contains(Deployment_roomcat_save.Groupname,'Kintampo')) = {'Urban'};
                Deployment_roomcat_save.LocationType(~contains(Deployment_roomcat_save.HouseholdID,'CA') & ~contains(Deployment_roomcat_save.Groupname,'Kintampo') & ~contains(Deployment_roomcat_save.HouseholdID,'no match')) = {'Rural'};
                Deployment_roomcat_save.LocationType = categorical(Deployment_roomcat_save.LocationType);
                Deployment_roomcat_save.Groupname = categorical(Deployment_roomcat_save.Groupname);

                %disp('LocationType successfully classified')
            catch
                disp(['!!!Issue encountered classifying location type (urban/rural) for: ' bname, '!!!'])
            end

            try
                whatweek = week(datetime(Deployment_roomcat_save.TimeMinuteRounded, 'ConvertFrom', 'datenum'));
                Deployment_roomcat_save.Season(:) = {'Transition'};
                Deployment_roomcat_save.Season(whatweek>14 & whatweek<23) = {'Light Rainy'}; %April to June also known as light_rainy
                Deployment_roomcat_save.Season(whatweek>=23 & whatweek<40) = {'Heavy Rainy'}; %June to october also known as heavy rainy
                Deployment_roomcat_save.Season(whatweek>=44 | whatweek<7) = {'Harmattan_bushburning'}; % November to mid Feb.
                Deployment_roomcat_save.Season(whatweek>=7 & whatweek<=14 ) = {'Dry'}; %Mid Feb to April also known as hot and dry
                Deployment_roomcat_save.Season = categorical(Deployment_roomcat_save.Season);
                %disp('Season successfully classified')
            catch
                disp(['!!!Issue encountered classifying season for: ' bname, '!!!']) 
            end
            
            try
               Deployment_roomcat_save.HourOfDay = hour(datetime(Deployment_roomcat_save.TimeMinuteRounded, 'ConvertFrom', 'datenum'));
            catch
               disp(['!!!Issue encountered classifying hour of day for: ' bname, '!!!']) 
            end
         
end %FUNCTION
    







































