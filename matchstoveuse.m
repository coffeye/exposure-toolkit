function  [Deployment_roomcat_save_temp, nomatch] = matchstoveuse(Deployment_roomcat_save,master_sums_list,nomatch,allFiles_SUMS_Final,Pathnames_SUMS_Final)
%by Evan Coffey

% Matches stove usage monitoring infomation to individual deployment data

%% Start by preallocating columns for SUMs data (maximum of 7  stoves)

Deployment_roomcat_save.Stove_1_sumid = num2cell(NaN(height(Deployment_roomcat_save),1));
Deployment_roomcat_save.Stove_1_ID = num2cell(NaN(height(Deployment_roomcat_save),1));
Deployment_roomcat_save.Stove_1_temp = double(NaN(height(Deployment_roomcat_save),1));
Deployment_roomcat_save.Stove_1_status = num2cell(NaN(height(Deployment_roomcat_save),1));

Deployment_roomcat_save.Stove_2_sumid = num2cell(NaN(height(Deployment_roomcat_save),1));
Deployment_roomcat_save.Stove_2_ID = num2cell(NaN(height(Deployment_roomcat_save),1));
Deployment_roomcat_save.Stove_2_temp = NaN(height(Deployment_roomcat_save),1);
Deployment_roomcat_save.Stove_2_status = num2cell(NaN(height(Deployment_roomcat_save),1));

Deployment_roomcat_save.Stove_3_sumid = num2cell(NaN(height(Deployment_roomcat_save),1));
Deployment_roomcat_save.Stove_3_ID = num2cell(NaN(height(Deployment_roomcat_save),1));
Deployment_roomcat_save.Stove_3_temp = NaN(height(Deployment_roomcat_save),1);
Deployment_roomcat_save.Stove_3_status = num2cell(NaN(height(Deployment_roomcat_save),1));

Deployment_roomcat_save.Stove_4_sumid = num2cell(NaN(height(Deployment_roomcat_save),1));
Deployment_roomcat_save.Stove_4_ID = num2cell(NaN(height(Deployment_roomcat_save),1));
Deployment_roomcat_save.Stove_4_temp = NaN(height(Deployment_roomcat_save),1);
Deployment_roomcat_save.Stove_4_status = num2cell(NaN(height(Deployment_roomcat_save),1));

Deployment_roomcat_save.Stove_5_sumid = num2cell(NaN(height(Deployment_roomcat_save),1));
Deployment_roomcat_save.Stove_5_ID = num2cell(NaN(height(Deployment_roomcat_save),1));
Deployment_roomcat_save.Stove_5_temp = NaN(height(Deployment_roomcat_save),1);
Deployment_roomcat_save.Stove_5_status = num2cell(NaN(height(Deployment_roomcat_save),1));

Deployment_roomcat_save.Stove_6_sumid = num2cell(NaN(height(Deployment_roomcat_save),1));
Deployment_roomcat_save.Stove_6_ID = num2cell(NaN(height(Deployment_roomcat_save),1));
Deployment_roomcat_save.Stove_6_temp = NaN(height(Deployment_roomcat_save),1);
Deployment_roomcat_save.Stove_6_status = num2cell(NaN(height(Deployment_roomcat_save),1));

Deployment_roomcat_save.Stove_7_sumid = num2cell(NaN(height(Deployment_roomcat_save),1));
Deployment_roomcat_save.Stove_7_ID = num2cell(NaN(height(Deployment_roomcat_save),1));
Deployment_roomcat_save.Stove_7_temp = NaN(height(Deployment_roomcat_save),1);
Deployment_roomcat_save.Stove_7_status = num2cell(NaN(height(Deployment_roomcat_save),1));



%% Step through matching criteria

try
    HHID = char(Deployment_roomcat_save.HouseholdID(1));
    DS = Deployment_roomcat_save.gmttime(1);
    DE = Deployment_roomcat_save.gmttime(end);

    %sums_ind_match = double(strcmp(HHID,master_sums_list.hhid)); %double of 1/0 for HH match - may need a more robust text comparison here

    %may need a loop
    for lll = 1:length(master_sums_list.hhid)
    try
        sums_ind_match(lll) = contains(HHID,master_sums_list.hhid(lll)); %test this out
    catch
        disp(['Issue finding ', HHID, ' in the master_SUMs_list CSV file. Check HH name'])
    end
    end
    
    if ~sum(sums_ind_match)==0 %If there is at least one entry with this HH in the SUMs survey list
    
        sums_ind_match = sums_ind_match'; sums_ind_match = double(sums_ind_match);


        date_match = datenum(master_sums_list.today-DE); %number of days separation from deployment end time. Important to use the end time!!!!!

        days_apart = sums_ind_match.*date_match;
        days_apart(abs(days_apart)<=0) = inf; %Change 0 values to inf
        minValue = min(days_apart(:));  % Find min.
        sums_list_match = find(days_apart == minValue);%index of the lowest value (this is our row match)

        
        if ~(length(sums_list_match)>1)
            
            clear days_apart sums_ind_match minValue date_match


            % Now the index row is located, strip relevant SUM IDs from row (from both entry types on survey form)

            SUMs_list1 = {master_sums_list.stove1_sum1(sums_list_match),master_sums_list.stove2_sum2(sums_list_match),master_sums_list.stove3_sum3(sums_list_match),master_sums_list.stove4_sum4(sums_list_match),master_sums_list.stove5_sum5(sums_list_match),master_sums_list.stove6_sum6(sums_list_match),master_sums_list.stove7_sum7(sums_list_match)};
            SUMs_list2 = {master_sums_list.stove1_sum1_other(sums_list_match),master_sums_list.stove2_sum2_other(sums_list_match),master_sums_list.stove3_sum3_other(sums_list_match),master_sums_list.stove4_sum4_other(sums_list_match),master_sums_list.stove5_sum5_other(sums_list_match),master_sums_list.stove6_sum6_other(sums_list_match),master_sums_list.stove7_sum7_other(sums_list_match)};
            SUMs_list = vertcat(SUMs_list1,SUMs_list2); %concatenate the two rows arrays above vertically

            % Locate any 'SUM b' devices in the case this HH has a two-burner LPG stove (whch would have two SUMs)
            SUMs_b_list1 = {master_sums_list.stove1_sum1_b(sums_list_match),master_sums_list.stove2_sum2_b(sums_list_match),master_sums_list.stove3_sum3_b(sums_list_match),master_sums_list.stove4_sum4_b(sums_list_match),master_sums_list.stove5_sum5_b(sums_list_match),master_sums_list.stove6_sum6_b(sums_list_match),master_sums_list.stove7_sum7_b(sums_list_match)};
            SUMs_b_list2 = {master_sums_list.stove1_sum1_other_b(sums_list_match),master_sums_list.stove2_sum2_other_b(sums_list_match),master_sums_list.stove3_sum3_other_b(sums_list_match),master_sums_list.stove4_sum4_other_b(sums_list_match),master_sums_list.stove5_sum5_other_b(sums_list_match),master_sums_list.stove6_sum6_other_b(sums_list_match),master_sums_list.stove7_sum7_other_b(sums_list_match)};
            SUMs_b_list = vertcat(SUMs_b_list1,SUMs_b_list2); %concatenate the two rows arrays above vertically


            for yy = 1:7 %Loop thru the seven columns of both the SUMs_list (and SUM_b_list) (first row are scanned SUMIDs, the second row is manually entered SUM IDs)
            new_list{yy} = horzcat(SUMs_list(1,yy),SUMs_list(2,yy));
            new_b_list{yy} = horzcat(SUMs_b_list(1,yy),SUMs_b_list(2,yy));

                for yyy=1:2 %For each column check the first and second rows to figure out which one is empty - only keep the value with text

                    if ~strcmp(string(new_list{1,yy}(1,yyy)),"")
                    final_list{1,yy}(1,1) = new_list{1,yy}(1,yyy); %only keep the value with text
                    end %end conditional

                    if ~strcmp(string(new_b_list{1,yy}(1,yyy)),"") && ~ismissing(string(new_b_list{1,yy}(1,yyy)))
                    final_b_list{1,yy}(1,1) = new_b_list{1,yy}(1,yyy); %only keep the value with text
                    end %end sum b conditional

                end %end yyy
            end %end yy


            for yy = 1:7 %Loop thru the possible seven columns of both the SUMs_list (and SUM_b_list) and turn to NaN each field that is blank or missing

                try
                    if isempty(string(final_list{1,yy}))
                    final_list{1,yy}=NaN;
                    end
                catch
                    try
                        if isnan(cell2mat(final_list{1,yy}))
                           final_list{1,yy}=NaN;
                        end
                    catch
                    end
                end


                try
                    if isempty(string(final_b_list{1,yy}))
                    final_b_list{1,yy}=['NaN'];
                    end
                catch
                    try
                        if isnan(cell2mat(final_b_list{1,yy}))
                           final_b_list{1,yy}='NaN';
                        end
                    catch

                    end
                end

            end % yy loop

            final_SUMs_list = string(final_list); %Here is the final list of SUMs at this HH


            if exist('final_b_list')
            final_SUMs_b_list = string(final_b_list); %Here is the final list of secondary SUMs (b) at this HH - aka the number of two-burner LPG stoves
            end

            clear new_list SUMs_list SUMs_list1 SUMs_list2 yy yyy final_list new_b_list SUMs_b_list SUMs_b_list1 SUMs_b_list2 final_b_list



            % Now the index row is located, strip relevant Stove IDs from row (from both entry types on survey form)

            SUMs_list1 = {master_sums_list.stove1_stove1_label(sums_list_match),master_sums_list.stove2_stove2_label(sums_list_match),master_sums_list.stove3_stove3_label(sums_list_match),master_sums_list.stove4_stove4_label(sums_list_match),master_sums_list.stove5_stove5_label(sums_list_match),master_sums_list.stove6_stove6_label(sums_list_match),master_sums_list.stove7_stove7_label(sums_list_match)};
            SUMs_list2 = {master_sums_list.stove1_stove1_label_other(sums_list_match),master_sums_list.stove2_stove2_label_other(sums_list_match),master_sums_list.stove3_stove3_label_other(sums_list_match),master_sums_list.stove4_stove4_label_other(sums_list_match),master_sums_list.stove5_stove5_label_other(sums_list_match),master_sums_list.stove6_stove6_label_other(sums_list_match),master_sums_list.stove7_stove7_label_other(sums_list_match)};
            SUMs_list = vertcat(SUMs_list1,SUMs_list2); %concatenate the two rows arrays above vertically



            for yy = 1:7 %Loop thru the seven columns of the SUMs_list
            new_list{yy} = horzcat(SUMs_list(1,yy),SUMs_list(2,yy));

            for yyy=1:2 %For each column check the first and second rows to figure out which one is empty - only keep the value with text
            if ~strcmp(string(new_list{1,yy}(1,yyy)),"")
                final_list{1,yy}(1,1) = new_list{1,yy}(1,yyy); %only keep the value with text
            end %end conditional
            end %end yyy
            end %end yy

            for yy = 1:7 %Loop thru the seven columns of the SUMs_list and NaN field that are blan or missing
            try
                if isempty(string(final_list{1,yy}))
                final_list{1,yy}=NaN;
                end
            catch
            end

            try 
                if isnan(cell2mat(final_list{1,yy}))
                final_list{1,yy}=NaN;
                end
            catch
            end

            end

            final_STOVE_list = string(final_list); %Here is the final list of SUMs at this HH
            
            
            
        else %If there wer emore than 2 matched entries in the SUMs survey list
            disp('More than 1 SUMs survey was completed for this HH on the deployment day. Check log.')
            blob
        end
        
  else %If there is no HH match in the whole SUMs survey list
        disp('This HH did not appear in the SUMs survey list at all - check log')
        blob
  end
    
    
catch
    disp('!!Issue finding SUMs information from master_sums_list')
    final_SUMs_list = []; final_STOVE_list = []; final_SUMs_b_list=[];
end
    clear new_list SUMs_list SUMs_list1 SUMs_list2 yyy yy final_list


%% Now we have our list of SUMs and Stoves, loop thru SUMs IDs and find/load in master SUM ID data

    if ~isempty(final_SUMs_list) && ~isempty(final_STOVE_list) %Check to see that the SUM ID and Stove ID are available for all loops

        
        %LOOP through each SUM deployed
        for yy = 1:length(final_SUMs_list)
            
                try
                    disp(['Matching ',char(final_SUMs_list(yy)),' on stove ',char(final_STOVE_list(yy)),'...'])
                catch
                    if ismissing(final_STOVE_list(yy))
                    disp(['Missing stove name for ', char(final_SUMs_list(yy)),'. Check the MasterSUMsSurvey sheet...skipping'])
                    else
                        if ismissing(final_SUMs_list(yy))
                    disp(['Missing SUM name for ', char(final_STOVE_list(yy)),'. Check the MasterSUMsSurvey sheet...skipping'])
                        end
                    end
                end


                try
                summatch = find(contains({allFiles_SUMS_Final.name}.',final_SUMs_list(yy)));
                    if isempty(summatch)
                        summatch = find(~cellfun(@isempty,regexpi({allFiles_SUMS_Final.name}.',final_SUMs_list(yy))));
                         if isempty(summatch)
                            disp(['Master SUM file for ', char(final_SUMs_list(yy)) , ' NOT found. Check folder for this SUM file.'])
                         end
                    end
                catch
                     disp(['Master SUM file for ', char(final_SUMs_list(yy)) , ' NOT found. Check folder for this SUM file.'])
                end

        
                    %Check that SUMs file was loaded in and conditional if it didn't
                    if ~isempty(summatch)

                    %Load in the corresponding  master SUMs file
                            if ~ismac
                            try load(fullfile(allFiles_SUMS_Final(summatch).folder, allFiles_SUMS_Final(summatch).name))
                            catch
                                disp('!!!(PC) Error loading one or more matched SUMs master file(s)!!!');
                            end
                            else
                            try load(fullfile(Pathnames_SUMS_Final, allFiles_SUMS_Final(summatch).name))
                            catch
                                disp('!!!(Mac) Error loading one or more matched SUMs master file(s)!!!');
                            end
                            end


                            %Convert start and stop times to datetime for isbetween function
                            DS = datetime(DS,'ConvertFrom', 'datenum');
                            DE = datetime(DE,'ConvertFrom', 'datenum');
                            %Round SUMs data to nearest minute
                            Final_output.TimeRounded = dateshift(datetime(Final_output.Datetime,'ConvertFrom', 'datenum'), 'start', 'minute');

                                    try
                                        matchind = isbetween(Final_output.TimeRounded,DS,DE);
                                        numatch = sum(matchind); % number of minute matches

                                        if numatch>0
                                            %disp([num2str(numatch), ' SUM time matches found in: ']); disp(allFiles_SUMS_Final(summatch).name);

                                            %Change the rounded time back to datenum for matching
                                            Final_output.TimeRounded = datenum(dateshift(datetime(Final_output.Datetime,'ConvertFrom', 'datenum'), 'start', 'minute'));

                                            [C,ia,ib] = innerjoin(Deployment_roomcat_save,Final_output,'LeftKeys',17, 'RightKeys',8);%The key from Deployment_roomcat_save is column 1 and the key from saveset is 8
                                            disp([num2str(length(ia)), ' SUM time matches found with proximity data']);

                                            var_ind_match = find(contains(Deployment_roomcat_save.Properties.VariableNames,strcat('Stove_',num2str(yy)))); %Locate column number of each stove

                                            ppp=1;
                                            Deployment_roomcat_save(:,var_ind_match(ppp))= Final_output.SUMID(1); %save SUM name for every row
                                            Deployment_roomcat_save(:,var_ind_match(ppp+1))= {char(final_STOVE_list(yy))}; %save stove name for every row
                                            Deployment_roomcat_save(ia,var_ind_match(ppp+2))= num2cell(Final_output.Temperature(ib));
                                            try
                                            Deployment_roomcat_save(ia,var_ind_match(ppp+3))= Final_output.Status_string(ib);
                                            catch
                                            Deployment_roomcat_save(ia,var_ind_match(ppp+3))= cellstr(Final_output.Status_string(ib));
                                            end

                                            else
                                            %Still record the stove id and SUM id even if time matches and temperatures were not found...
                                            var_ind_match = find(contains(Deployment_roomcat_save.Properties.VariableNames,strcat('Stove_',num2str(yy)))); %Locate column number of each stove
                                            ppp=1;
                                            Deployment_roomcat_save(:,var_ind_match(ppp))= Final_output.SUMID(1);
                                            Deployment_roomcat_save(:,var_ind_match(ppp+1))= {char(final_STOVE_list(yy))};

                                            disp('No valid overlapping SUMs times found in:'); disp(allFiles_SUMS_Final(summatch).name);

                                        end 
                                    catch
                                        disp('!!!Some issue occurred finding matches with: ');
                                        disp(allFiles_SUMS_Final(summatch).name);

                                        Deployment_roomcat_save_temp = Deployment_roomcat_save; %Save the deployment

                                    end %try for joining data to deployment

                                        clear ppp ia ib var_ind_match C sumatch

                    end %Was there a Master SUM file match
        
                    
             %If this stove has two SUMs on it...!!!!!!!!!!!!!
             if exist('final_SUMs_b_list') %first does the b_list exist
                 if length(final_SUMs_b_list)>=yy %second are there as many bsums as the stove number yy
                 if ~ismissing(final_SUMs_b_list(yy)) && ~contains('NaN',final_SUMs_b_list(yy)); disp([char(final_SUMs_b_list(yy)), ' was also deployed on this stove']);

                        try
                            summatch = find(contains({allFiles_SUMS_Final.name}.',final_SUMs_b_list(yy)));
                                if isempty(summatch)
                                    summatch = find(~cellfun(@isempty,regexpi({allFiles_SUMS_Final.name}.',final_SUMs_b_list(yy))));
                                        if isempty(summatch)
                                            disp(['Master SUM file for ', char(final_SUMs_b_list(yy)) , ' NOT found. Check folder for this SUM file.'])
                                        end
                                end
                        catch
                        disp(['Master SUM file for ', char(final_SUMs_b_list(yy)) , ' NOT found. Check folder for this SUM file.'])
                        end


                        %Check that SUMs file was loaded in and conditional if it didn't
                        if ~isempty(summatch)

                        %Load in the corresponding  master SUMs file
                                if ~ismac
                                try load(fullfile(allFiles_SUMS_Final(summatch).folder, allFiles_SUMS_Final(summatch).name))
                                catch
                                    disp('!!!(PC) Error loading one or more matched SUMs master file(s)!!!');
                                end
                                else
                                try load(fullfile(Pathnames_SUMS_Final, allFiles_SUMS_Final(summatch).name))
                                catch
                                    disp('!!!(Mac) Error loading one or more matched SUMs master file(s)!!!');
                                end
                                end


                                %Convert start and stop times to datetime for isbetween function
                                DS = datetime(DS,'ConvertFrom', 'datenum');
                                DE = datetime(DE,'ConvertFrom', 'datenum');
                                %Round SUMs data to nearest minute
                                Final_output.TimeRounded = dateshift(datetime(Final_output.Datetime,'ConvertFrom', 'datenum'), 'start', 'minute');

                                        try
                                            matchind = isbetween(Final_output.TimeRounded,DS,DE);
                                            numatch = sum(matchind); % number of minute matches
    
                                            if numatch>0
                                                %disp([num2str(numatch), ' SUM time matches found in: ']); disp(allFiles_SUMS_Final(summatch).name);

                                                %Change the rounded time back to datenum for matching
                                                Final_output.TimeRounded = datenum(dateshift(datetime(Final_output.Datetime,'ConvertFrom', 'datenum'), 'start', 'minute'));
                                                [C,ia,ib] = innerjoin(Deployment_roomcat_save,Final_output,'LeftKeys',17, 'RightKeys',8);%The key from Deployment_roomcat_save is column 1 and the key from saveset is 8
                                                disp([num2str(length(ia)), ' b-SUM time matches found with proximity data']);
                                                var_ind_match = find(contains(Deployment_roomcat_save.Properties.VariableNames,strcat('Stove_',num2str(yy)))); %Locate column number of each stove

                                                
                                                %Combine the SUMIDs first now that we know both SUMs are on this stove
                                                ppp=1;
                                                Deployment_roomcat_save.(var_ind_match(ppp))(ia)= strcat(Deployment_roomcat_save.(var_ind_match(ppp))(ia),',',Final_output.SUMID(ib));
                                                
                                                %Conditionals for how to merge a pair of SUM data

                                                    for ii=1:length(ia); check=0;
                                                    try
                                                        %SUM 1 says no cooking,SUM 2 says cooking - use temperature and status from SUM 2
                                                        if strcmp(Deployment_roomcat_save.(var_ind_match(ppp+3))(ia(ii)),'No Cooking') && strcmp(Final_output.Status_string(ib(ii)),'Cooking')
                                                            Deployment_roomcat_save.(var_ind_match(ppp+3))(ia(ii))={'Cooking'};Deployment_roomcat_save.(var_ind_match(ppp+2))(ia(ii))=Final_output.Temperature(ib(ii));
                                                            check = check+1;
                                                        end
                                                    catch; disp('!!!Issue encountered comparing the two SUMs values');
                                                    end
                                                    end

                                            else %if there are no b-SUM time matches with the deployment data
                                                    
                                                    %Still record the b-SUM id even if time matches and temperatures were not found...
                                                    var_ind_match = find(contains(Deployment_roomcat_save.Properties.VariableNames,strcat('Stove_',num2str(yy)))); %Locate column number of each stove
                                                    ppp=1;
                                                    Deployment_roomcat_save.(var_ind_match(ppp))(:)=strcat(Deployment_roomcat_save.(var_ind_match(ppp))(1),',',Final_output.SUMID(1));
                                                    disp('No valid overlapping b-SUMs times found in:'); disp(allFiles_SUMS_Final(summatch).name);
                                            end%no matches
                                            
                                        catch
                                            disp('!!!Some issue occurred finding matches with: ');
                                            disp(allFiles_SUMS_Final(summatch).name);
    
                                            Deployment_roomcat_save_temp = Deployment_roomcat_save; %Save the deployment
    
                                        end %try for joining data to deployment

                                            clear ppp ia ib var_ind_match C sumatch

                        end %SUM match
                    end %Is there a second SUM for this stove
                end %Is yy >= to number of b_list_sums
             end  %Does the second SUM b_list exist        
                    
                    
                    
        end %loop for each SUM detected
        
        Deployment_roomcat_save_temp = Deployment_roomcat_save; %Save the deployment
        nomatch = nomatch; %Mark no change in nomatch

    
    
    else %No HH match
     
    Deployment_roomcat_save_temp = Deployment_roomcat_save; %Save the deployment
    %disp('........................................')
    nomatch = nomatch +1; %Add one to nomatch

    end


end

