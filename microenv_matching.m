function  [Deployment_roomcat_save_temp, yesmatched] = microenv_matching(Deployment_roomcat_save,Deployment,Gdata,GdataKintampo,yesmatched,bname,particle_coefficient,HAPEx_LOQ)

% By Evan Coffey

%Match any avialable calibrated Kitchen area data with deployments.
% GPod (temp, rh, COppm, CO2ppm, abshum) and HAPEx data



%% Start by preallocating columns for MicroEnv data (length of deployment)
load('PC_model')
%Flagging threshold for PM
hmean_thresh = 1.15*HAPEx_LOQ; %mean values equal to or under this threshold are flagged as bad
hmedian_thresh = 125; %median values equal to or over this threshold are flagged as bad
hstd_thresh = 10; %std values equal to or under this threshold are flagged as bad
PC = particle_coefficient; %This is the default PC value stipulated in the main code


%GPod
Deployment_roomcat_save.Micro_Temp_K = double(NaN(height(Deployment_roomcat_save),1));
Deployment_roomcat_save.Micro_RH = double(NaN(height(Deployment_roomcat_save),1));
Deployment_roomcat_save.Micro_Abshum_mol = double(NaN(height(Deployment_roomcat_save),1));
Deployment_roomcat_save.Micro_CO2_ppm = double(NaN(height(Deployment_roomcat_save),1));
Deployment_roomcat_save.Micro_CO_ppm = double(NaN(height(Deployment_roomcat_save),1));
%Deployment_roomcat_save.Micro_MCE =
%double(NaN(height(Deployment_roomcat_save),1)); %Background subtracted MCE

%add uncertainty??

%HAPEx 1
Deployment_roomcat_save.Micro_BC_HAPEX_1 = double(NaN(height(Deployment_roomcat_save),1));
Deployment_roomcat_save.Micro_Raw_HAPEX_1 = double(NaN(height(Deployment_roomcat_save),1));
Deployment_roomcat_save.Micro_BC_HAPEX_1_flag = double(NaN(height(Deployment_roomcat_save),1));
Deployment_roomcat_save.Micro_HAPEX_1_Name = num2cell(NaN(height(Deployment_roomcat_save),1));
Deployment_roomcat_save.Micro_HAPEX_1_Compliance = double(NaN(height(Deployment_roomcat_save),1));
Deployment_roomcat_save.Micro_HAPEX_1_weight = double(NaN(height(Deployment_roomcat_save),1));

%HAPEx 2
Deployment_roomcat_save.Micro_BC_HAPEX_2 = double(NaN(height(Deployment_roomcat_save),1));
Deployment_roomcat_save.Micro_Raw_HAPEX_2 = double(NaN(height(Deployment_roomcat_save),1));
Deployment_roomcat_save.Micro_BC_HAPEX_2_flag = double(NaN(height(Deployment_roomcat_save),1));
Deployment_roomcat_save.Micro_HAPEX_2_Name = num2cell(NaN(height(Deployment_roomcat_save),1));
Deployment_roomcat_save.Micro_HAPEX_2_Compliance = double(NaN(height(Deployment_roomcat_save),1));
Deployment_roomcat_save.Micro_HAPEX_2_weight = double(NaN(height(Deployment_roomcat_save),1));


%Overall
Deployment_roomcat_save.Micro_Overall_PM_ugpcm = double(NaN(height(Deployment_roomcat_save),1));
Deployment_roomcat_save.Micro_Overall_PM_flag = double(NaN(height(Deployment_roomcat_save),1));


%% Next

try
    HHID = char(Deployment_roomcat_save.HouseholdID(1));
    ts = datetime(Deployment_roomcat_save.TimeMinuteRounded(1),'ConvertFrom', 'datenum');
    te = datetime(Deployment_roomcat_save.TimeMinuteRounded(end),'ConvertFrom', 'datenum');
    
    for lll = 1:length(Deployment.Location)
    
        try
        dep_ind_match(lll) = contains(HHID,Deployment.Location(lll)) && (contains(Deployment.(1)(lll), 'H2') || contains(Deployment.(1)(lll), 'G7') ); %For deployments with G7 OR H2
        catch
        disp('!!!Issue encountered. check deployment log!!!')
        end
        
        try
           dep_ind_match2(lll) = contains(HHID,Deployment.Location(lll)) && (contains(Deployment.(1)(lll), 'G6') || contains(Deployment.(1)(lll), 'G8') ); %For deployments with G6 OR G8
           if contains(HHID,Deployment.Location(lll)) && (contains(Deployment.(1)(lll), 'G6') || contains(Deployment.(1)(lll), 'G8') )
           disp('Kintampo household detected - matching gas phase GPod data')
           end
        catch
        disp('!!!Issue encountered. check deployment log!!!')
        end
    
    end
    
    dep_rows = Deployment(dep_ind_match,:); %NHRC
    dep_rows2 = Deployment(dep_ind_match2,:); %KHRC
    
catch
end %try for matching household ID


if ~isempty(dep_rows) %this HH had the GPod at it at some point
    
    %Is this deployment within a certain time range of dep_rows?
    
        for jjj=1:length(dep_rows.(1)) %length here is the # of times this HH had the GPod deployed
            if isbetween(ts, datetime(dep_rows.Date_TimeStart(jjj))-hours(3),datetime(dep_rows.Date_TimeStart(jjj))+hours(3)) %looking within a 6 hour window centered on beacon deployment start time

                        try
                            matchind = isbetween(Gdata.TimeRounded_datetime,ts,te);
                            numatch = sum(matchind); % number of minute matches

                            if numatch>0
                                %disp([num2str(numatch), ' time matches found']);

                                [~,ia,ib] = innerjoin(Deployment_roomcat_save,Gdata,'LeftKeys',17,'RightKeys',87); %matching on time

                                if isempty(ia)
                                    disp('No overlapping data found. Doublecheck logs.')%No data overlapped
                                else
                                disp([num2str(length(ia)), ' time matches found']);

                                Deployment_roomcat_save.Micro_Temp_K(ia) = Gdata.Temp(ib);
                                Deployment_roomcat_save.Micro_RH(ia) = Gdata.RH(ib);
                                Deployment_roomcat_save.Micro_Abshum_mol(ia) = Gdata.abshum(ib);
                                Deployment_roomcat_save.Micro_CO2_ppm(ia) = Gdata.(9)(ib);
                                Deployment_roomcat_save.Micro_CO_ppm(ia) = Gdata.(13)(ib);
                                %Deployment_roomcat_save.Micro_MCE(ia) = Gdata.

                                Deployment_roomcat_save.Micro_BC_HAPEX_1(ia) = Gdata.BC_HAPEX_1(ib);
                                Deployment_roomcat_save.Micro_Raw_HAPEX_1(ia) = Gdata.Raw_HAPEX_1(ib);
                                Deployment_roomcat_save.Micro_BC_HAPEX_1_flag(ia) = Gdata.BC_HAPEX_1_flag(ib);
                                Deployment_roomcat_save.Micro_HAPEX_1_Name(ia) = Gdata.HAPEX_1_Name(ib);
                                Deployment_roomcat_save.Micro_HAPEX_1_Compliance(ia) = Gdata.HAPEX_1_Compliance(ib);
                                Deployment_roomcat_save.Micro_HAPEX_1_weight(ia) = Gdata.HAPEX_1_weight(ib);                            

                                Deployment_roomcat_save.Micro_BC_HAPEX_2(ia) = Gdata.BC_HAPEX_2(ib);
                                Deployment_roomcat_save.Micro_Raw_HAPEX_2(ia) = Gdata.Raw_HAPEX_2(ib);
                                Deployment_roomcat_save.Micro_BC_HAPEX_2_flag(ia) = Gdata.BC_HAPEX_2_flag(ib);
                                Deployment_roomcat_save.Micro_HAPEX_2_Name(ia) = Gdata.HAPEX_2_Name(ib);
                                Deployment_roomcat_save.Micro_HAPEX_2_Compliance(ia) = Gdata.HAPEX_2_Compliance(ib);
                                Deployment_roomcat_save.Micro_HAPEX_2_weight(ia) = Gdata.HAPEX_2_weight(ib);                            

                                yesmatched = yesmatched+1;
                                end %ia not empty

                            else %ia empty 
                                 disp('Missing Data - no NHRC GPod data exists within these times. Check Gdata.');

                            end %any time match conditional

                        catch % issues finding time matches after deployemnt was confirmed
                                disp('!!!Issues in code finding any NHRC time matches');
                                disp('........................................')
                        end


            end %HH did not have GPod during this deployment period
            disp('...')
        end
        
        
        %Apply PC here...flag data like personal filtering (automated only?)
        
        % LOQ replacement for HAPEx
        try 
            if~isnan(nanmean(Deployment_roomcat_save.Micro_BC_HAPEX_1))
            Deployment_roomcat_save.Micro_BC_HAPEX_1(Deployment_roomcat_save.Micro_BC_HAPEX_1<HAPEx_LOQ)=HAPEx_LOQ;
            disp(['Micro HAPEx 1 values below the LOQ: ',num2str(HAPEx_LOQ),' raw counts, have been replaced with the LOQ'])
            else
            disp('Micro HAPEx 1 values all NaN - no LOQ replacement')
            end
            
            if~isnan(nanmean(Deployment_roomcat_save.Micro_BC_HAPEX_2))
            Deployment_roomcat_save.Micro_BC_HAPEX_2(Deployment_roomcat_save.Micro_BC_HAPEX_2<HAPEx_LOQ)=HAPEx_LOQ;
            disp(['Micro HAPEx 2 values below the LOQ: ',num2str(HAPEx_LOQ),' raw counts, have been replaced with the LOQ'])
            else
            disp('Micro HAPEx 2 values all NaN - no LOQ replacement')
            end
        catch
             disp('!!!Issue LOQ replacement of Micro PM data!!!')
        end
        
        
        
        %temporary average of paired hapex when both available
        for jjj = 1:length(Deployment_roomcat_save.Micro_BC_HAPEX_1)
            
        if ~isnan(Deployment_roomcat_save.Micro_BC_HAPEX_1(jjj)) && ~isnan(Deployment_roomcat_save.Micro_BC_HAPEX_2(jjj)) %both HAPEx have valid data
        Deployment_roomcat_save.Micro_Overall_PM_ugpcm(jjj) = ((Deployment_roomcat_save.Micro_BC_HAPEX_1(jjj) + Deployment_roomcat_save.Micro_BC_HAPEX_2(jjj))/2)./PC;

        else
           if ~isnan(Deployment_roomcat_save.Micro_BC_HAPEX_1(jjj)) && isnan(Deployment_roomcat_save.Micro_BC_HAPEX_2(jjj))
              Deployment_roomcat_save.Micro_Overall_PM_ugpcm(jjj) = (Deployment_roomcat_save.Micro_BC_HAPEX_1(jjj))./PC;
           else
               if isnan(Deployment_roomcat_save.Micro_BC_HAPEX_1(jjj)) && ~isnan(Deployment_roomcat_save.Micro_BC_HAPEX_2(jjj))
                Deployment_roomcat_save.Micro_Overall_PM_ugpcm(jjj) = (Deployment_roomcat_save.Micro_BC_HAPEX_2(jjj))./PC;
               else %nothing - leave as NaN
               end
           end
        end
        
        end
        
        
        Deployment_roomcat_save_temp = Deployment_roomcat_save;

else % A KHRC household

        if ~isempty(dep_rows2) %this HH had the GPod at it at some point

            %Is this deployment within a certain time range of dep_rows?

            for jjj=1:length(dep_rows2.(1)) %length here is the # of times this HH had the GPod deployed
                if isbetween(ts, datetime(dep_rows2.Date_TimeStart(jjj))-hours(3),datetime(dep_rows2.Date_TimeStart(jjj))+hours(3)) %looking within a 6 hour window centered on beacon deployment start time

                            try
                                matchind = isbetween(GdataKintampo.TimeRounded_datetime,ts,te);
                                numatch = sum(matchind); % number of minute matches

                                if numatch>0
                                    %disp([num2str(numatch), ' time matches found']);

                                    [~,ia,ib] = innerjoin(Deployment_roomcat_save,GdataKintampo,'LeftKeys',17,'RightKeys',87); %matching on time

                                    if isempty(ia)
                                        disp('No overlapping data found. Doublecheck logs.')%No data overlapped
                                    else
                                    disp([num2str(length(ia)), ' time matches found']);

                                    Deployment_roomcat_save.Micro_Temp_K(ia) = GdataKintampo.Temp(ib);
                                    Deployment_roomcat_save.Micro_RH(ia) = GdataKintampo.RH(ib);
                                    Deployment_roomcat_save.Micro_Abshum_mol(ia) = GdataKintampo.abshum(ib);
                                    Deployment_roomcat_save.Micro_CO2_ppm(ia) = GdataKintampo.(9)(ib);
                                    Deployment_roomcat_save.Micro_CO_ppm(ia) = GdataKintampo.(15)(ib);
                                    %Deployment_roomcat_save.Micro_MCE(ia) = Gdata.

                                    Deployment_roomcat_save.Micro_BC_HAPEX_1(ia) = GdataKintampo.BC_HAPEX_1(ib);
                                    Deployment_roomcat_save.Micro_Raw_HAPEX_1(ia) = GdataKintampo.Raw_HAPEX_1(ib);
                                    Deployment_roomcat_save.Micro_BC_HAPEX_1_flag(ia) = GdataKintampo.BC_HAPEX_1_flag(ib);
                                    Deployment_roomcat_save.Micro_HAPEX_1_Name(ia) = GdataKintampo.HAPEX_1_Name(ib);
                                    Deployment_roomcat_save.Micro_HAPEX_1_Compliance(ia) = GdataKintampo.HAPEX_1_Compliance(ib);
                                    Deployment_roomcat_save.Micro_HAPEX_1_weight(ia) = GdataKintampo.HAPEX_1_weight(ib);                            

                                    Deployment_roomcat_save.Micro_BC_HAPEX_2(ia) = GdataKintampo.BC_HAPEX_2(ib);
                                    Deployment_roomcat_save.Micro_Raw_HAPEX_2(ia) = GdataKintampo.Raw_HAPEX_2(ib);
                                    Deployment_roomcat_save.Micro_BC_HAPEX_2_flag(ia) = GdataKintampo.BC_HAPEX_2_flag(ib);
                                    Deployment_roomcat_save.Micro_HAPEX_2_Name(ia) = GdataKintampo.HAPEX_2_Name(ib);
                                    Deployment_roomcat_save.Micro_HAPEX_2_Compliance(ia) = GdataKintampo.HAPEX_2_Compliance(ib);
                                    Deployment_roomcat_save.Micro_HAPEX_2_weight(ia) = GdataKintampo.HAPEX_2_weight(ib);                            

                                    yesmatched = yesmatched+1;
                                    end %ia not empty

                                else %ia empty 
                                     disp('Missing Data - no KHRC GPod data exists within these times. Check Gdata.');

                                end %any time match conditional

                            catch % issues finding time matches after deployemnt was confirmed
                                    disp('!!!Issues in code finding any KHRC time matches');
                                    disp('........................................')
                            end


                end %HH did not have GPod during this deployment period
                disp('...')
            end
            
            
        %Apply PC here...flag data like personal filtering (automated only?)

            
            %No Micro_HAPEx data for KHRC HHs
            
            
            
            
            
            
            
            Deployment_roomcat_save_temp = Deployment_roomcat_save;

        else %The Gpod was not deployed at this HH
            disp(['No GPod deployments found in log matching HH: ', HHID])
            Deployment_roomcat_save_temp = Deployment_roomcat_save;

        end %HH ever had GPod (in either KHRC or NHRC)

    disp('........................................')
    clear deprows deprows2 ia ib ts te HHID PC
end


