%Categorize each stove type present

%by Evan Coffey

Deployment_roomcat_save.Stove_1_type = categorical(NaN(height(Deployment_roomcat_save),1));
Deployment_roomcat_save.Stove_2_type = categorical(NaN(height(Deployment_roomcat_save),1));
Deployment_roomcat_save.Stove_3_type = categorical(NaN(height(Deployment_roomcat_save),1));
Deployment_roomcat_save.Stove_4_type = categorical(NaN(height(Deployment_roomcat_save),1));
Deployment_roomcat_save.Stove_5_type = categorical(NaN(height(Deployment_roomcat_save),1));
Deployment_roomcat_save.Stove_6_type = categorical(NaN(height(Deployment_roomcat_save),1));
Deployment_roomcat_save.Stove_7_type = categorical(NaN(height(Deployment_roomcat_save),1));

try
Deployment_roomcat_save.Stove_1_type(contains(Deployment_roomcat_save.Stove_1_ID,'T'))= 'TSF';
Deployment_roomcat_save.Stove_2_type(contains(Deployment_roomcat_save.Stove_2_ID,'T'))= 'TSF';
Deployment_roomcat_save.Stove_3_type(contains(Deployment_roomcat_save.Stove_3_ID,'T'))= 'TSF';
Deployment_roomcat_save.Stove_4_type(contains(Deployment_roomcat_save.Stove_4_ID,'T'))= 'TSF';
Deployment_roomcat_save.Stove_5_type(contains(Deployment_roomcat_save.Stove_5_ID,'T'))= 'TSF';
Deployment_roomcat_save.Stove_6_type(contains(Deployment_roomcat_save.Stove_6_ID,'T'))= 'TSF';
Deployment_roomcat_save.Stove_7_type(contains(Deployment_roomcat_save.Stove_7_ID,'T'))= 'TSF';
catch
end

try
Deployment_roomcat_save.Stove_1_type(contains(Deployment_roomcat_save.Stove_1_ID,'J'))= 'Jumbo';
Deployment_roomcat_save.Stove_2_type(contains(Deployment_roomcat_save.Stove_2_ID,'J'))= 'Jumbo';
Deployment_roomcat_save.Stove_3_type(contains(Deployment_roomcat_save.Stove_3_ID,'J'))= 'Jumbo';
Deployment_roomcat_save.Stove_4_type(contains(Deployment_roomcat_save.Stove_4_ID,'J'))= 'Jumbo';
Deployment_roomcat_save.Stove_5_type(contains(Deployment_roomcat_save.Stove_5_ID,'J'))= 'Jumbo';
Deployment_roomcat_save.Stove_6_type(contains(Deployment_roomcat_save.Stove_6_ID,'J'))= 'Jumbo';
Deployment_roomcat_save.Stove_7_type(contains(Deployment_roomcat_save.Stove_7_ID,'J'))= 'Jumbo';
catch
end


try
Deployment_roomcat_save.Stove_1_type(contains(Deployment_roomcat_save.Stove_1_ID,'C'))= 'Coalpot';
Deployment_roomcat_save.Stove_2_type(contains(Deployment_roomcat_save.Stove_2_ID,'C'))= 'Coalpot';
Deployment_roomcat_save.Stove_3_type(contains(Deployment_roomcat_save.Stove_3_ID,'C'))= 'Coalpot';
Deployment_roomcat_save.Stove_4_type(contains(Deployment_roomcat_save.Stove_4_ID,'C'))= 'Coalpot';
Deployment_roomcat_save.Stove_5_type(contains(Deployment_roomcat_save.Stove_5_ID,'C'))= 'Coalpot';
Deployment_roomcat_save.Stove_6_type(contains(Deployment_roomcat_save.Stove_6_ID,'C'))= 'Coalpot';
Deployment_roomcat_save.Stove_7_type(contains(Deployment_roomcat_save.Stove_7_ID,'C'))= 'Coalpot';
catch
end


try
Deployment_roomcat_save.Stove_1_type(contains(Deployment_roomcat_save.Stove_1_ID,'A'))= 'ACE';
Deployment_roomcat_save.Stove_2_type(contains(Deployment_roomcat_save.Stove_2_ID,'A'))= 'ACE';
Deployment_roomcat_save.Stove_3_type(contains(Deployment_roomcat_save.Stove_3_ID,'A'))= 'ACE';
Deployment_roomcat_save.Stove_4_type(contains(Deployment_roomcat_save.Stove_4_ID,'A'))= 'ACE';
Deployment_roomcat_save.Stove_5_type(contains(Deployment_roomcat_save.Stove_5_ID,'A'))= 'ACE';
Deployment_roomcat_save.Stove_6_type(contains(Deployment_roomcat_save.Stove_6_ID,'A'))= 'ACE';
Deployment_roomcat_save.Stove_7_type(contains(Deployment_roomcat_save.Stove_7_ID,'A'))= 'ACE';
catch
end


try
Deployment_roomcat_save.Stove_1_type(contains(Deployment_roomcat_save.Stove_1_ID,'G'))= 'LPG';
Deployment_roomcat_save.Stove_2_type(contains(Deployment_roomcat_save.Stove_2_ID,'G'))= 'LPG';
Deployment_roomcat_save.Stove_3_type(contains(Deployment_roomcat_save.Stove_3_ID,'G'))= 'LPG';
Deployment_roomcat_save.Stove_4_type(contains(Deployment_roomcat_save.Stove_4_ID,'G'))= 'LPG';
Deployment_roomcat_save.Stove_5_type(contains(Deployment_roomcat_save.Stove_5_ID,'G'))= 'LPG';
Deployment_roomcat_save.Stove_6_type(contains(Deployment_roomcat_save.Stove_6_ID,'G'))= 'LPG';
Deployment_roomcat_save.Stove_7_type(contains(Deployment_roomcat_save.Stove_7_ID,'G'))= 'LPG';
catch
end

%reorganize the deployment file so the stove types categories are behind
%each stove status column
try
        TempD = Deployment_roomcat_save;
        TempD = movevars(TempD,'Stove_1_type','After','Stove_1_status');
        TempD = movevars(TempD,'Stove_2_type','After','Stove_2_status');
        TempD = movevars(TempD,'Stove_3_type','After','Stove_3_status');
        TempD = movevars(TempD,'Stove_4_type','After','Stove_4_status');
        TempD = movevars(TempD,'Stove_5_type','After','Stove_5_status');
        TempD = movevars(TempD,'Stove_6_type','After','Stove_6_status');
        TempD = movevars(TempD,'Stove_7_type','After','Stove_7_status');
catch
    disp('Issue reorganizing stove type categories')
end
                
Deployment_roomcat_save = TempD;
clear TempD
