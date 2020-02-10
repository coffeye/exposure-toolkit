function [Deployment_roomcat_save_temp,numbad] = deployment_time_average(Deployment_roomcat_save,avg_time,bname,numbad,psname);
%by Evan Coffey

%% Location: 1=Primary Kitchen, 2=Secondary Kitchen
temploc = categorical(Deployment_roomcat_save.Location);
cats = categories(temploc); %Could reorder the categories to ensure order

    if  length(cats)>2 | iscategorical(Deployment_roomcat_save.Location)
        disp('More than 2 categories for Location or classification has already been performed on this deployment...reclassifying')
                   Deployment_roomcat_save.Location = cellstr(Deployment_roomcat_save.Location);
                   Deployment_roomcat_save.Location(strcmp(Deployment_roomcat_save.Location, cats(1)))={'1'};
                   Deployment_roomcat_save.Location(strcmp(Deployment_roomcat_save.Location, cats(2)))={'2'};
                   Deployment_roomcat_save.Location = str2double(cellstr(Deployment_roomcat_save.Location));
                   disp('done');
    else
        if length(cats)==1 %Only primary kitchen used (e.g. i=55)
        disp('One kitchen location monitored')
        Deployment_roomcat_save.Location(strcmp(Deployment_roomcat_save.Location, cats(1)))={'1'};
        Deployment_roomcat_save.Location = str2double(cellstr(Deployment_roomcat_save.Location));
        disp('done')
        else %Primary and Secondary Kitchen locations
            disp('Two kitchen locations monitored')
                if strcmp(cats(1),'Primary Kitchen') %catnum(1)=1;
                   Deployment_roomcat_save.Location(strcmp(Deployment_roomcat_save.Location, cats(1)))={'1'};
                   Deployment_roomcat_save.Location(strcmp(Deployment_roomcat_save.Location, cats(2)))={'2'};
                   Deployment_roomcat_save.Location = str2double(cellstr(Deployment_roomcat_save.Location));
                   disp('done');
                else
                    if strcmp(cats(2),'Primary Kitchen') %catnum(2)=1;
                           Deployment_roomcat_save.Location(strcmp(Deployment_roomcat_save.Location, cats(2)))={'1'};
                           Deployment_roomcat_save.Location(strcmp(Deployment_roomcat_save.Location, cats(1)))={'2'};
                           Deployment_roomcat_save.Location = str2double(cellstr(Deployment_roomcat_save.Location));
                           disp('done');
                    end %order of cats (primary = second) end
                end %order of cats (primary = first) end
        end %only primary kitchen end
    end %more than 2 categories end
    clear temploc cats

%% Stove_n_status: 0=Not Cooking, 1=Cooking

    tempcook = table; cats = table;
    for cc = 1:7 %the number of potential stoves in a single deployment
    disp(['Processing data from stove ', num2str(cc)]);
    var_ind_match = find(contains(Deployment_roomcat_save.Properties.VariableNames,strcat('Stove_',num2str(cc)))); %Locate column number of each stove
    
    if length(var_ind_match)<5 %check to see if there are 4 or 5 colums matching "stove_1"
        cookstatcolumn = var_ind_match(end); %if there are 4, then classify_activites hasn't been run yet for this deployment file
    else %if there are 5, then stove type classification has been done and 
        cookstatcolumn = var_ind_match(end-1);
        TEMPstatus = cellstr(Deployment_roomcat_save.(cookstatcolumn));
        Deployment_roomcat_save.(cookstatcolumn)=TEMPstatus;
    end
    
    %Change 'not logging' or NaN (numeric) to empty cell ('undefined') for the purposes of classification
    try
        Deployment_roomcat_save.(cookstatcolumn)((strcmpi((Deployment_roomcat_save.(cookstatcolumn)),'Not Logging')))={''};
        Deployment_roomcat_save.(cookstatcolumn)(cellfun(@isnumeric,Deployment_roomcat_save.(cookstatcolumn))) = {''};
    catch
    end
    
    try
    tempcook = categorical(Deployment_roomcat_save.(cookstatcolumn));
    cats = categories(tempcook); %Could reorder the categories to ensure order
    catch
        if isequaln(NaN(length(Deployment_roomcat_save.(cookstatcolumn)),1),cell2mat(Deployment_roomcat_save.(cookstatcolumn)))
        disp('all cooking status values are NaN');
        else
        disp('!!!ISSUES detecting categories - check file[]')
        end
        tempcook = []; cookcase=0;
    end


        if isempty(tempcook)||isempty(cats) 
        disp('no cooking categories found'); cookcase=0;
        else
            if length(cats)>2
                disp('!!!MORE than 2 categories for cooking. Check file...')
                cookcase=0;
            else
                if length(cats)==1 %Only one cooking status detected
                disp('only 1 cooking category detected')
                cookcase=1;
                else %Both cooking and no cooking are categories
                cookcase=2;       
                end %only one cooking status end
            end %more than 2 categories end
        end

                if cookcase==1
                    if strcmp(cats,'No Cooking')
                        Deployment_roomcat_save.(cookstatcolumn)(strcmp(Deployment_roomcat_save.(cookstatcolumn), cats))={'0'};
                        Deployment_roomcat_save.(cookstatcolumn)= str2double(cellstr(Deployment_roomcat_save.(cookstatcolumn)));
                        disp('done processing')
                    else
                        if strcmp(cats,'Cooking')
                        Deployment_roomcat_save.(cookstatcolumn)(strcmp(Deployment_roomcat_save.(cookstatcolumn), cats))={'1'};
                        Deployment_roomcat_save.(cookstatcolumn)= str2double(cellstr(Deployment_roomcat_save.(cookstatcolumn)));
                        disp('done processing')
                        end   
                    end
                end %cookcase=1

                if cookcase==2
                    if strcmp(cats(1),'Cooking') %catnum(1)=1;
                       Deployment_roomcat_save.(cookstatcolumn)(strcmp(Deployment_roomcat_save.(cookstatcolumn), cats(1)))={'1'};
                       Deployment_roomcat_save.(cookstatcolumn)(strcmp(Deployment_roomcat_save.(cookstatcolumn), cats(2)))={'0'};
                       Deployment_roomcat_save.(cookstatcolumn)= str2double(cellstr(Deployment_roomcat_save.(cookstatcolumn)));
                       disp('done processing');
                    else
                        if strcmp(cats(1),'No Cooking') %catnum(2)=1;
                            Deployment_roomcat_save.(cookstatcolumn)(strcmp(Deployment_roomcat_save.(cookstatcolumn), cats(1)))={'0'};
                            Deployment_roomcat_save.(cookstatcolumn)(strcmp(Deployment_roomcat_save.(cookstatcolumn), cats(2)))={'1'};
                            Deployment_roomcat_save.(cookstatcolumn)= str2double(cellstr(Deployment_roomcat_save.(cookstatcolumn)));
                           disp('done processing');
                        end %order of cats (primary = second)
                    end %order of cats (primary = first)
                end %cookcase=2

            clear cookstatcolumn cookcase var_ind_match cats
    end


    
%% Numerically encode BeaconLogger 1 and 2 flags; 0=NotLogging, 1=Logging
  

try
   
   cats1 = categories(Deployment_roomcat_save.BeaconLogger_1_flag); num1cats = length(cats1);
   cats2 = categories(Deployment_roomcat_save.BeaconLogger_2_flag); num2cats = length(cats2);

   %Create temp array for each BeaconLogger
   BL1_codes = NaN(length(Deployment_roomcat_save.BeaconLogger_1_flag),1);
   BL2_codes = NaN(length(Deployment_roomcat_save.BeaconLogger_2_flag),1);

   %Assign 0 or 1 depending on category
   BL1_codes(ismember(Deployment_roomcat_save.BeaconLogger_1_flag,'NotLogging'))=0;
   BL1_codes(ismember(Deployment_roomcat_save.BeaconLogger_1_flag,'Logging'))=1;
   
   Deployment_roomcat_save.BeaconLogger_1_flag = BL1_codes;

   if ~isempty(cats2)
   BL2_codes(ismember(Deployment_roomcat_save.BeaconLogger_2_flag,'NotLogging'))=0;
   BL2_codes(ismember(Deployment_roomcat_save.BeaconLogger_2_flag,'Logging'))=1;
   Deployment_roomcat_save.BeaconLogger_2_flag = BL2_codes;  
   else
     Deployment_roomcat_save.BeaconLogger_2_flag = BL2_codes;
   end
   
    
catch
    disp('!!!Issue encountered numerically encoding BeaconLogger flags!!!')
    blerp
end

    
%% Now perform the averaging 

    try
    Deployment_roomcat_save.gmttime = datetime(Deployment_roomcat_save.TimeMinuteRounded, 'ConvertFrom', 'datenum');
    Deployment_roomcat_save.gmttime_text = cellstr(Deployment_roomcat_save.gmttime_text); %change gmttime_text to a cell string

    %NaN values that were set to -999 for flagging so they do not affect averaging
    Deployment_roomcat_save.BeaconRSSI(Deployment_roomcat_save.BeaconRSSI==-999)=NaN;
    Deployment_roomcat_save.Distance_m1(Deployment_roomcat_save.Distance_m1==-999)=NaN;
    Deployment_roomcat_save.Distance_m2(Deployment_roomcat_save.Distance_m2==-999)=NaN;

    %Create temporary timetable
    depTT = table2timetable(Deployment_roomcat_save);


    % Determine which variables (column) are numeric and will be able to be retimed
%     S = vartype('numeric');
%     O = vartype('cell');%All cell columns - should be all other columns
%     C = vartype('categorical');
%     D = vartype('string');

    % Determine which variables (column) are numeric and will be able to be retimed
    numericVars = varfun(@isnumeric,depTT,'output','uniform');
    nonnumericVars = ~(numericVars);
    
    depTT1 = depTT(:,numericVars);%sub timetable of numerical data
    depTT2 = depTT(:,nonnumericVars);%sub timetable of non-numerical data
    
    % Creates a new timesteps series that uses the user defined avergaing time (avg_time)
    newTimes = (datetime(depTT1.gmttime(1), 'ConvertFrom', 'datenum')):avg_time:datetime(depTT1.gmttime(end), 'ConvertFrom', 'datenum');
    newdepTT1 = retime(depTT1,newTimes,'mean');%for the numerical class
    newdepTT2 = retime(depTT2,newTimes,'firstvalue');%for the cell class - using the value from the first bin element - need a better 'mean' metric for non-numeric data like ' BeaconLogger Flag' and 'Beacon Flag'

    catch
        disp('Issue using retime and/or confirguring timetables')
    end

%     %depTT = retime(depTT,'hourly','mean');
%     figure
%     stackedplot(depTT, {'Distance_m_merged','CO_exposure_ppm','PM_exposure_ugpcm'}, 'Title', '1-min');
%     figure
%     stackedplot(newdepTT1, {'Distance_m_merged','CO_exposure_ppm','PM_exposure_ugpcm'}, 'Title', char(avg_time));

    

%% Combine the two timetables
    try
    finaldepTT = join(newdepTT1,newdepTT2);
    Deployment_roomcat_save_temp = timetable2table(finaldepTT);
    catch
        disp('Issue joining numeric and non-numeric timetables')
    end

    %%Reorganize the final deployment table temp
    try
    Deployment_roomcat_save_temp_temp = reorganize_deployment_table(Deployment_roomcat_save_temp); %custom function
    catch
        disp('Issue reorganizing table variables')
    end
    clear S O depTT depTT1 depTT2 newdepTT1 newdepTT2 numericVars nonnumericVars newTimes
    
%% Reclassify BeaconLogger flags
  Deployment_roomcat_save_temp_temp.BeaconLogger_1_flag(Deployment_roomcat_save_temp_temp.BeaconLogger_1_flag>=0.5)=1;
  Deployment_roomcat_save_temp_temp.BeaconLogger_1_flag(Deployment_roomcat_save_temp_temp.BeaconLogger_1_flag<0.5)=0;
  
  Deployment_roomcat_save_temp_temp.BeaconLogger_1_flag = string(num2cell(Deployment_roomcat_save_temp_temp.BeaconLogger_1_flag));
  Deployment_roomcat_save_temp_temp.BeaconLogger_1_flag(strcmpi(Deployment_roomcat_save_temp_temp.BeaconLogger_1_flag,'1'))='Logging';
  Deployment_roomcat_save_temp_temp.BeaconLogger_1_flag(strcmpi(Deployment_roomcat_save_temp_temp.BeaconLogger_1_flag,'0'))='Not Logging';

  
  if ~isempty(cats2)
  Deployment_roomcat_save_temp_temp.BeaconLogger_2_flag(Deployment_roomcat_save_temp_temp.BeaconLogger_2_flag>=0.5)=1;
  Deployment_roomcat_save_temp_temp.BeaconLogger_2_flag(Deployment_roomcat_save_temp_temp.BeaconLogger_2_flag<0.5)=0;
 
  Deployment_roomcat_save_temp_temp.BeaconLogger_2_flag = string(num2cell(Deployment_roomcat_save_temp_temp.BeaconLogger_2_flag));
  Deployment_roomcat_save_temp_temp.BeaconLogger_2_flag(strcmpi(Deployment_roomcat_save_temp_temp.BeaconLogger_2_flag,'1'))='Logging';
  Deployment_roomcat_save_temp_temp.BeaconLogger_2_flag(strcmpi(Deployment_roomcat_save_temp_temp.BeaconLogger_2_flag,'0'))='Not Logging';
  end 
    
%% Reclassify compliance
  Deployment_roomcat_save_temp_temp.Overall_Compliance(Deployment_roomcat_save_temp_temp.Overall_Compliance>=0.5)=1; %recompute binary
  Deployment_roomcat_save_temp_temp.Overall_Compliance(Deployment_roomcat_save_temp_temp.Overall_Compliance<0.5)=0; %recompute binary

   

  
  clear cats1 cats2 BL1_codes BL2_codes num1cats num2cats
%return the temp file    
    
Deployment_roomcat_save_temp = Deployment_roomcat_save_temp_temp;


end

