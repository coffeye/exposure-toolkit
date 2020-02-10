function [TempD] = reorganize_deployment_table(Deployment_roomcat_save_temp)
% by Evan Coffey

%   This code reorganizes the deployment_roomcat_save_temp table so that
%   all the deployments have the same ordering

TempD = Deployment_roomcat_save_temp;

%the first 15 columns should be the same across all deployments
%Deployment_rommcat_save_temp.Properties.VariableNames(1:15)

    if strcmp(TempD.Properties.VariableNames(15),'GPS_lon')
        TempD = movevars(TempD,'Stove_1_sumid','After','GPS_lon');
        TempD = movevars(TempD,'Stove_1_ID','After','Stove_1_sumid');
        TempD = movevars(TempD,'Stove_1_temp','After','Stove_1_ID');
        TempD = movevars(TempD,'Stove_1_status','After','Stove_1_temp');

        TempD = movevars(TempD,'Stove_2_sumid','After','Stove_1_status');
        TempD = movevars(TempD,'Stove_2_ID','After','Stove_2_sumid');
        TempD = movevars(TempD,'Stove_2_temp','After','Stove_2_ID');
        TempD = movevars(TempD,'Stove_2_status','After','Stove_2_temp');

        TempD = movevars(TempD,'Stove_3_sumid','After','Stove_2_status');
        TempD = movevars(TempD,'Stove_3_ID','After','Stove_3_sumid');
        TempD = movevars(TempD,'Stove_3_temp','After','Stove_3_ID');
        TempD = movevars(TempD,'Stove_3_status','After','Stove_3_temp');

        TempD = movevars(TempD,'Stove_4_sumid','After','Stove_3_status');
        TempD = movevars(TempD,'Stove_4_ID','After','Stove_4_sumid');
        TempD = movevars(TempD,'Stove_4_temp','After','Stove_4_ID');
        TempD = movevars(TempD,'Stove_4_status','After','Stove_4_temp');    

        TempD = movevars(TempD,'Stove_5_sumid','After','Stove_4_status');
        TempD = movevars(TempD,'Stove_5_ID','After','Stove_5_sumid');
        TempD = movevars(TempD,'Stove_5_temp','After','Stove_5_ID');
        TempD = movevars(TempD,'Stove_5_status','After','Stove_5_temp');    

        TempD = movevars(TempD,'Stove_6_sumid','After','Stove_5_status');
        TempD = movevars(TempD,'Stove_6_ID','After','Stove_6_sumid');
        TempD = movevars(TempD,'Stove_6_temp','After','Stove_6_ID');
        TempD = movevars(TempD,'Stove_6_status','After','Stove_6_temp');

        TempD = movevars(TempD,'Stove_7_sumid','After','Stove_6_status');
        TempD = movevars(TempD,'Stove_7_ID','After','Stove_7_sumid');
        TempD = movevars(TempD,'Stove_7_temp','After','Stove_7_ID');
        TempD = movevars(TempD,'Stove_7_status','After','Stove_7_temp');    

        TempD = movevars(TempD,'Lascar_1_Name','After','Raw_LascarCO_ppm_1');
        TempD = movevars(TempD,'Lascar_2_Name','After','Raw_LascarCO_ppm_2');

        TempD = movevars(TempD,'HAPEX_1_Name','After','Raw_HAPEX_1');
        TempD = movevars(TempD,'HAPEX_2_Name','After','Raw_HAPEX_2');
        

        TempD = movevars(TempD,'Stove_7_temp','After','Stove_7_ID');
        TempD = movevars(TempD,'Stove_7_status','After','Stove_7_temp'); 

        TempD = movevars(TempD,'Groupname','After','Stovegroup');
        
        TempD = movevars(TempD,'UserID','After','gmttime');
        TempD = movevars(TempD,'HouseholdID','After','UserID');
        
        TempD = movevars(TempD,'DistanceFlag','After','Distance_m_merged');
        
        
        
        disp('averaging complete')

    else
        disp('There is an issue with the starting column. Check file!!')
    end
 
end

