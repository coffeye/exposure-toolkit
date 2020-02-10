%%  AIR POLLUTION EXPOSURE ASSESSMENT TOOLKIT

%LOCATION, PROXIMITY, SOURCE ACTIVITY AND EXPOSURE FUSION TOOL

%{
by Evan R. Coffey (2019), PRA
University of Colorado Boulder
Mechanical Engineering Department
coffeye@colorado.edu

Funding provided by the Implementation Science Network

Additonal Authors:
NHRC staff
KHRC staff
Columbia University faculty, staff and students


Prices, Peers and Perceptions Study; Ghana
Child Lung Function Study, Ghana

NOTE: Spelling was not checked or corrected - appologies
%}

%% OVERVIEW
%{ 
Main code to integrate all co-collected data streams for personal deployment data
Be sure all input data streams have been pre-processed and are up-to-date in corresponding "final" folders
 
1. Merges baseline corrected PM and calibrated CO exposure data with proximity, location and demographic information
2. Allows for averaging of Lascar data using a rolling-mean
3. Replaces CO and PM signal values below LOQ (level of quantification) with an instrument-specific value
4. Calculates compliance using combination of HAPEx values and beacon RSSI values
5. Categorizes atcivities using proximity, stove use and location information
6. Variable time-averaging
%}

%% INPUTS
%{
User settings below determine what inputs are needed and what processing and analysis is done
Some settings are dependent on others - look at comments for depenencies

The set of INPUTS include:
1)Deployment_roomcat .mat (proximity analysis smoothed output) files for each USER monitored during the 48 hour sampling period - format found in 'example data'
2)Calibrated Lascar CO files - format found in 'example data'
3)Baseline corrected HAPEx files (OR formatted MicroPEMs files) - format found in 'example data'
4)GPS master1 file (.mat) (optional GPS_master2) - format found in 'example data'
5)HH and User information (.csv) - format found in 'example data'
6)Final master SUM timeseries for each SUMID(.mat) - format found in 'example data'
%}

%% OUTPUTS
%{
The OUTPUT(s) consist of:
1) Matched user-deployment .mat timeseries files containing all finalized relevant information gathered from logsheets and available data
2) One aggregated .csv file containing the appended user-deployment timeseries files (above) acting as a single data structure for any subsequent analysis (e.g., in R)
3) A record of the command-window text (diary) including percentages of matched data, missing or skipped files etc.
4) A PDF file of the any saved plots
%}

%% SUB-FUNCTIONS REQUIRED IN MAIN DIRECTORY OR 'FUNCTIONS' SUBDIRECTORY
%{
import_roomcat_files

matchgps

matchstoveuse
stove_type_categorize

matchcoexposure
matchPMexposure

CO_exposurefiltering

PM_exposurefiltering

adduserdata
import_user_data_opts

microenv_matching
deployment_time_average
classify_activities
reorganize_deployment_table

generate_STEP_plots
check_compliance
prox_gps_check
plot_matching
movcorr
savePDF/ps2pdf
dscatter(optional)
@gramm (grammar of graphics)
%}


%% DATA FILES REQUIRED IN DIRECTORY OR 'FUNCTIONS' SUBDIRECTORY
%{
GPS_master1
GPS_master2
GPS_master4REX
GPS_master3REX
HH_data
User_data
PC_model
compliance_ensemble_BALogger
compliance_ensemble_PhoneLogger
%}

%% INITIALIZE
clear all
close all
diary off
clc


%% USER SETTINGS FOR OUTPUT NAMING
AA_beacon_cal_type = 'Unique'           %'Unique' is for deployment-specific beacon calibrations, 'Global' is for use of the global calibration function and 'iBeacon' signifies the old model. NOTE: when AA_Start_Fresh is active, the most recent beacon_analysis_sqlite_updated run outputs will be used

%% USER DEFINED OPTIONS and PARAMETERS - start with "AA" so they show up at top of variable list
AA_StartFresh = 1                       %When 1, imports brand new smoothed Deployment_Roomcat files from the most recent beacon_analysis_sqlite_updated run (i.e. the processed beacon data)
AA_Import_All_Files = 1                 %Allows user to select which files to process (enter 0 if you want to manually select files - HAS DEPENDENCIES including pathnames so consider removing)

AA_Combine_GPS = 1                      %Combines GPS data with proximity

AA_Combine_SUMs = 1                     %Match stove usage information for each deployment to other data streams

AA_Combine_CO_exposure = 1              %Combines CO Lascar data with proximity
AA_COsmoothing = 1                      %Smooths CO data at rolling X minute average (see below for dependency)
rollingtime = 5                         %Minutes for CO rolling averaging
AA_Lascar_LOQ_replace = 1               %Replaces values below Lascar_LOQ with Lascar_LOQ
Lascar_LOQ = 0.15                       %User setting for lascars level of quantification (in ppm)

AA_Combine_PM_exposure_compliance = 1   %Combines raw and baseline-corrected PM data from HAPEx with proximity
AA_HAPEx_LOQ_replace = 1                %Replaces values below HAPEx_LOQ with HAPEx_LOQ (below)
HAPEx_LOQ = 5.4                         %User setting for HAPEx level of quantification (raw signal)

particle_coefficient = 0.089            %Stipulate the default particle coefficient (PC = meanHAPEx/Grav) to be applied to raw HAPEx readings - 0.089 is overall slope

AA_HH_User_info = 1                     %Matches to intervention group, age, gender, SES, etc as well as seaosn and urban/rural
AA_flag_CO_exposure = 1                 %Flags and filters CO exposure data to ommit from analaysis
AA_flag_PM_exposure = 1                 %Flags and filters PM exposure data to ommit from analaysis and applies particle coefficient determined from 'Microenvironment Analysis' modeling results
flagmode = 1                            %Type of flagging; 1 is auto and 2 is manual flagging which requires user input during this stage

AA_MicroEnv = 1                         %Matches any kitchen-area measurements with deployments (e.g., CO, CO2, HAPEx PM, temperature, humidity etc.)

AA_Deployment_Time_Averaging = 0        %Averages deployment metrics at the number of minutes below
deploymnent_min_avg = 5                 %Number of minutes to average deployment metrics - creates a new directory (if doesn't exist) or overwrites existing ones matching this time

AA_Classifications = 1                  %Performs the classification of time-activites with user-defined measurement criteria (criteria inside subfunction)
AA_Generate_STEP_plots = 1              %Creates pie charts and boxplots of exposure and time categories by compliant/all times, across component measrue categories and overall activities etc.

AA_Diary = 1                            %Runs the Diary program - meaning all displayed text in command window are stored in a file
AA_CHECKCOMPLIANCE = 0                  %Visualizes compliance/noncompliance of user
AA_PLOTS = 0                            %Creates plots of exposure, location categories etc.
AA_CHECKLOCATION = 0                    %Categorizes and plots location-time information
AA_CLOSEPLOTS = 1                       %Closes plots after they are made to prevent matlab from crashing due to graphics failure
AA_Make_master_csv = 1                  %Create one giant csv file of all user deployments data by appending deployment files one by one (using set averaging time)
AA_Save_master_csv_MAT = 0              %Save a .MAT file of mastercsv dataset (TAKES ADDITIONAL 1-2 HOURS FOR ~800,000 MINUTE DATA POINTS!!)

AA_email_user = 1                       %email the user when the code is done running - requires additional setup
w = warning ('on','all');               %Warning set to on
id = w.identifier;                      %Keep track of the warnings
disp('--------------------------------------------------------------------------------')
disp('--------------------------------------------------------------------------------')

%%





%COMMENCE
disp('..............................................................................')
disp('..............................................................................')
disp(['.........Beacon_Exposure_Matching Run started at ' datestr(now), '.........'])
disp('..............................................................................')
disp('..............................................................................')







%% IMPORT MOST RECENT BATCH OF PROXIMITY DEPLOYMENT FILES
% Import new Beacon_RoomCat files to overwrite any in "Final" folder

if AA_StartFresh==1
    d = import_roomcat_files; d; clear d %Script to import most recently made Beacon deployment files
    disp('USING NEWEST FILES IN THIS RUN')
    disp('........................................')
else
    disp('USING EXISTING FILES')
    disp('........................................')
end

%% SELECT PROXIMITY DEPLOYMENT FILES
% Locate final, individual, beacon deployment data full roomcat smoothed time series files inside "FINAL" folder

% GUI for data selection
if ~isdeployed; addpath('Functions'); end
computername = char(java.lang.System.getProperty('user.name'));

%For Mac
Pathnames_Beacons_Final = fullfile('/Users',computername,'Google Drive','P3 Data Analysis','NIH Beacons','Beacon Logger Data P1','Smoothed Deployments','Final');
allFiles_Beacons_Final = dir(Pathnames_Beacons_Final);
filenames_Beacons_Final = {allFiles_Beacons_Final.name};
filenames_Beacons_Final(strncmp(filenames_Beacons_Final,'.',1)) = [];

%For windows
if isempty(filenames_Beacons_Final)
    Pathnames_Beacons_Final = fullfile('F:','Google Drive','P3 Data Analysis','NIH Beacons','Beacon Logger Data P1', 'Smoothed Deployments','Final');
    allFiles_Beacons_Final = dir(Pathnames_Beacons_Final);
    filenames_Beacons_Final = { allFiles_Beacons_Final.name };
    filenames_Beacons_Final(strncmp(filenames_Beacons_Final,'.',1)) = [];
end

if isempty(filenames_Beacons_Final)
    Pathnames_Beacons_Final = fullfile('D:','GDrive','P3 Data Analysis','NIH Beacons','Beacon Logger Data P1', 'Smoothed Deployments','Final');
    allFiles_Beacons_Final = dir(Pathnames_Beacons_Final);
    filenames_Beacons_Final = { allFiles_Beacons_Final.name };
    filenames_Beacons_Final(strncmp(filenames_Beacons_Final,'.',1)) = [];
end


if isempty(filenames_Beacons_Final) || AA_Import_All_Files == 0
    disp('Select smoothed beacon deployment ROOMCAT data files');
    [filenames_Beacons_Final, Pathnames_Beacons_Final] = uigetfile('*','Select smoothed beacon deployment ROOMCAT data data files','MultiSelect','on');
    if isequal(filenames_Beacons_Final,0); disp('!!!No Beacon files selected, run ended!!!'); errorize; end
end

%% CREATE FILE FOR PRINTING FIGURES
if ~ismac
    psname = [Pathnames_Beacons_Final,'\Reports\myReportReg.ps'];
    pdfsavename = [Pathnames_Beacons_Final,'\Reports\Plots_', AA_beacon_cal_type,'_',datestr(now, 'mmm_dd_YYYY_HH_MM'),'.pdf'];
else
    psname = [Pathnames_Beacons_Final,'/Reports/myReportReg.ps'];
    pdfsavename = [Pathnames_Beacons_Final,'/Reports/Plots_', AA_beacon_cal_type,'_',datestr(now, 'mmm_dd_YYYY_HH_MM'),'.pdf'];
end

%% DIARY
if AA_Diary ==1
    if ~ismac
    diary (fullfile(Pathnames_Beacons_Final,'\Reports\', [strcat('my_diary_',datestr(now,'mmm_dd_YYYY_HH_MM')),'.txt']))  % Diary is written to the output folder where the matched beacon deployment files will be stored
    else
    diary ([Pathnames_Beacons_Final, '/Reports/',strcat('my_diary_',datestr(now,'mmm_dd_YYYY_HH_MM')),'.txt'])
    end
end

%% DEFINE FILENAMES/PATHNAMES OF PROXMITY FILES USED FOR LOOPS

% Determine which indicies in allFiles.name are beacon (Roomcat) files and use those as the looping variable
try
tempfiles = {allFiles_Beacons_Final.name};
legitind = contains(tempfiles,'Roomcat'); %Check for 
loopfiles = allFiles_Beacons_Final(contains({allFiles_Beacons_Final.name},'Roomcat'));
numbeaconfiles = sum(legitind);% Only choose files over 150 bytes to prevent bugging out
disp([num2str(numbeaconfiles), ' beacon deployments found...']);
catch
    disp('Trying another beacon identification technique...')
    try
       bytes = [allFiles_Beacons_Final.bytes].';
       beaconfile_ind = bytes>150;
       loopfiles = allFiles_Beacons_Final(beaconfile_ind);
       numbeaconfiles = sum(beaconfile_ind);% Only choose files over 150 bytes to prevent bugging out
       disp('Successful finding beacon files')
       disp([num2str(numbeaconfiles), ' beacon deployments found...']);
    catch
        disp('!!!Issues identifying beacon files - try running Matlab2016 or later!!!')
    end
end
clear allFiles legitind tempfiles beaconfile_ind bytes
    

%% UPLOAD DEPLOYMENT LOG(S)
% these contain the deployment metadata

Pathnames_Logsheets = strrep(Pathnames_Beacons_Final,'Beacon Logger Data P0','Log Sheets');
Pathnames_Logsheets = strrep(Pathnames_Logsheets,'Beacon Logger Data P1','Log Sheets');
Pathnames_Logsheets = strrep(Pathnames_Logsheets,'Smoothed Deployments\','');
Pathnames_Logsheets = strrep(Pathnames_Logsheets,'Smoothed Deployments/','');
path_Deployment = strrep(Pathnames_Logsheets,'Final','');
deploymentfilename = fullfile(path_Deployment, 'LogsheetEntry.xlsm');
beacondeploymentfilename = fullfile(path_Deployment, 'Deployment Log.xlsm');

if ~ismac
try
Deployment = readtable(deploymentfilename,'sheet','Deployment');
HAPDeployment = readtable(deploymentfilename,'sheet','HAPDep');
Beacon_Deployment = readtable(beacondeploymentfilename);
catch
    disp(['!!!(PC) issue loading the Deployment logsheet...check: ' deploymentfilename, '!!!'])
end

else %If it is a Mac then add the time difference between Excel and Matlab 
try
Deployment = readtable(deploymentfilename,'sheet','Deployment');
Deployment.Date_TimeStart = Deployment.Date_TimeStart+693960;
Deployment.Date_TimeEnd = Deployment.Date_TimeEnd+693960;

HAPDeployment = readtable(deploymentfilename,'sheet','HAPDep');
HAPDeployment.Date_TimeStart = HAPDeployment.Date_TimeStart+693960;
HAPDeployment.Date_TimeEnd = HAPDeployment.Date_TimeEnd+693960;
catch
    disp(['!!!(Mac) issue loading the Deployment logsheet...check: ' deploymentfilename,'!!!'])
end
end 
clear deploymentfilename  beacondeploymentfilename


%% SUMMARIZE DEPLOYMENT LOG NUMBERS
% How many field deployments were reported as conducted between study dates
try
disp(['Analyzing all recorded deployments from: ', datestr(Beacon_Deployment{end,1}, 'mmmm-dd-yyyy'), ' to: ', datestr(Beacon_Deployment{1,2}, 'mmm-dd-yyyy')])
disp(['Unique proximtiy deployments recorded: ',num2str(height(Beacon_Deployment))])
catch
end


%% DEFINE CLASS-LOG VARIABLE
% class_log is the varibale that keeps track of deployment-specific measures, frequency etc.
class_log = table();

%% COMBINE GPS DATA 

if AA_Combine_GPS == 1
disp('INTEGRATING GPS DATA...')
%this may be a big memory hog but not sure how else to do it - select individual deployent gps logs?

%Import the master GPS timeseries (GPS_master2 is from watch placed in sample pack)
try
gpsmain = load('GPS_master1'); %This file is large but stored as .mat file (Oct'18: Using GPS_master1 as this is the file associated with the participant (on wrist))
gpsmain1 = gpsmain.masterSeries;
clear gpsmain
gpsmain = load('GPS_master2'); % This file data is associated with watch 2 worn in the waist pack
gpsmain2 = gpsmain.masterSeries;
clear gpsmain

disp('GPS master file(s) imported successfully')
disp('........................................')
catch
    disp('!!!Issues importing GPS master file(s) - check the file location/naming!!!')
    disp('........................................')
end

try
khrcwatch1 = load('GPS_master4REX.mat');
khrcwatch2 = load('GPS_master3REX.mat');

%NaN lats and lons that are 0 where no GPS data was found and NaN all the dataInside values for Kintampo data
khrcwatch1 = khrcwatch1.masterSeries; khrcwatch1.dataInside(:)=NaN; khrcwatch1.latSeries(khrcwatch1.latSeries==0)=NaN; khrcwatch1.lonSeries(khrcwatch1.lonSeries==0)=NaN;
khrcwatch2 = khrcwatch2.masterSeries; khrcwatch2.dataInside(:)=NaN; khrcwatch2.latSeries(khrcwatch2.latSeries==0)=NaN; khrcwatch2.lonSeries(khrcwatch2.lonSeries==0)=NaN;

disp('KHRC GPS master files imported successfully')
disp('........................................')

catch
    disp('Issue importing the KHRC watch GPS files - check them')
    disp('........................................')
end


%Define the number of no matches to start as 0
nomatch = 0;

% Import the final beacon data full roomcat smoothed time series files one
% at a time and serach for matches @ user/time levels
for i=1:numbeaconfiles %Loops through beacon files
       
    if ~ismac
    try load(fullfile(loopfiles(i).folder, loopfiles(i).name))%load deployment file
    catch
        disp('!!!(PC) Error loading one or more beacon Deployment_roomcat file(s)!!!');%print warning if file was not loaded
    end
    
    else
    try load(fullfile(Pathnames_Beacons_Final, loopfiles(i).name))%load deployment file
    catch err; disp('!!!(Mac) Error loading one or more beacon Deployment_roomcat file(s)!!!');%print warning if file was not loaded
    end
    end
                try
                    disp(['Adding gps category to deployment: ', loopfiles(i).name]); %continue;
                
                    %macth GPS function call
                    [Deployment_roomcat_save_temp, nomatch] = matchgps(Deployment_roomcat_save, gpsmain1, gpsmain2, nomatch, khrcwatch1, khrcwatch2);

                    %save the new(gps added) Deployment_roomcat to allFiles.folder
                    Deployment_roomcat_save = Deployment_roomcat_save_temp; 
               
                        if ~ismac
                        save(fullfile(loopfiles(i).folder, loopfiles(i).name),'Deployment_roomcat_save'); %Saves updated deployment file
                        else
                        save(Pathnames_Beacons_Final, loopfiles(i).name,'Deployment_roomcat_save'); %Saves updated deployment file
                        end %save new deployment file operating system conditional
                catch
                    disp(['!!!',loopfiles(i).name, 'not a deployment file','!!!']);
                end
                clear Deployment_roomcat_save_temp Deployment_roomcat_save
end %beacon files loop

        unmatchperc = nomatch/(numbeaconfiles)*100;
        disp([num2str(nomatch) ' beacon file(s) had no GPS watch match or ' num2str(unmatchperc,2) '%']);
        disp('FINISHED INTEGRATING GPS DATA')
        disp('--------------------------------------------------------------------------------')
        disp('--------------------------------------------------------------------------------')
        clear gpsmain gpsmain2 khrcwatch1 khrcwatch2 nomatch unmatchperc numatch
else
    disp('INTEGRATING GPS DATA SKIPPED BY USER')
    disp('--------------------------------------------------------------------------------')
    disp('--------------------------------------------------------------------------------')
end


%% COMBINE STOVE USAGE DATA

if AA_Combine_SUMs == 1
disp('INTEGRATING STOVE USAGE DATA...')


% First, locate all SUMs master timeseries
%For Mac
Pathnames_SUMS_Final = fullfile('/Users',computername,'Google Drive','P3 Data Analysis','SUMs','SUMs Data','Final Combined SUMS Master Files');
allFiles_SUMS_Final = dir(Pathnames_SUMS_Final);
filenames_SUMS_Final = {allFiles_SUMS_Final.name};
filenames_SUMS_Final(strncmp(filenames_SUMS_Final,'.',1)) = [];
%For windows
if isempty(filenames_SUMS_Final)
    Pathnames_SUMS_Final = fullfile('F:','Google Drive','P3 Data Analysis','SUMs','SUMs Data','Final Combined SUMS Master Files');
    allFiles_SUMS_Final = dir(Pathnames_SUMS_Final);
    filenames_SUMS_Final = {allFiles_SUMS_Final.name};
    filenames_SUMS_Final(strncmp(filenames_SUMS_Final,'.',1)) = []; %If a file name only has a decimal remove it
end

if isempty(filenames_SUMS_Final)
    Pathnames_SUMS_Final = fullfile('D:','GDrive','P3 Data Analysis','SUMs','SUMs Data','Final Combined SUMS Master Files');
    allFiles_SUMS_Final = dir(Pathnames_SUMS_Final);
    filenames_SUMS_Final = {allFiles_SUMS_Final.name};
    filenames_SUMS_Final(strncmp(filenames_SUMS_Final,'.',1)) = []; %If a file name only has a decimal remove it
end

if isempty(filenames_SUMS_Final)
    disp('Select all SUMs .mat data files');
    [filenames_SUMS_Final, Pathnames_SUMS_Final] = uigetfile('*','Select SUMS .mat data files','MultiSelect','on');
    if isequal(filenames_SUMS_Final,0); disp('No SUMS files selected, run ended'); errorize; end
end

%Determine how many individual SUMs files there are
bytes2 = [allFiles_SUMS_Final.bytes].';
numsumsfiles = sum(bytes2>150); % Only choose files over 150 bytes to prevent bugging out
disp([num2str(numsumsfiles), ' SUMs master timeseries files found...']);
disp('........................................')

%Second, load Household Stove Record
try
master_sums_list_filename = fullfile(strrep(Pathnames_SUMS_Final,'Final Combined SUMS Master Files','Metadata'),'Combined Master SUMs Survey_edited.xlsm');
master_sums_list = readtable(master_sums_list_filename);
catch
    try
        master_sums_list = xlsread(master_sums_list_filename);
    catch
        try
            master_sums_list_filename = fullfile(strrep(Pathnames_SUMS_Final,'Final Combined SUMS Master Files','Metadata'),'Combined Master SUMs Survey_edited.csv');
            master_sums_list = csvread(master_sums_list_filename);
        catch
            disp(['Issues loading ', master_sums_list_filename])
        end
    end
end


% Third, loop through deployments and find matching SUM data using
% household stove record as matching criteria
nomatch = 0;

for iii=1:numbeaconfiles %Loops through beacon files
       
    if ~ismac
    try load(fullfile(loopfiles(iii).folder, loopfiles(iii).name))%load deployment file
    catch
        disp('!!!(PC) Error loading one or more beacon Deployment_roomcat file(s)!!!');%print warning if file was not loaded
    end
    
    else
    try load(fullfile(Pathnames_Beacons_Final, loopfiles(iii).name))%load deployment file
    catch err; disp('!!!(Mac) Error loading one or more beacon Deployment_roomcat file(s)!!!');%print warning if file was not loaded
    end
    end
                try
                    disp(['Adding stove use information to deployment: ', loopfiles(iii).name]); %continue;
                
                    %match stove usage function call
                    [Deployment_roomcat_save_temp, nomatch] = matchstoveuse(Deployment_roomcat_save,master_sums_list,nomatch,allFiles_SUMS_Final,Pathnames_SUMS_Final);

                    %save the new(stove data added) Deployment_roomcat to allFiles.folder
                    Deployment_roomcat_save = Deployment_roomcat_save_temp; 
               
                        if ~ismac
                        save(fullfile(loopfiles(iii).folder, loopfiles(iii).name),'Deployment_roomcat_save'); %Saves updated deployment file
                        else
                        save(Pathnames_Beacons_Final, loopfiles(iii).name,'Deployment_roomcat_save'); %Saves updated deployment file
                        end %save new deployment file operating system conditional
                catch
                    disp(['!!!',loopfiles(iii).name, ' failed when matching stove data; ','iii = ', num2str(iii)]);
                    disp('........................................')
                end
                    disp('........................................')

                clear Deployment_roomcat_save_temp Deployment_roomcat_save DS DE
                
end %beacon files loop

 unmatchperc = nomatch/(numbeaconfiles)*100;
 disp([num2str(nomatch) ' beacon file(s) had no SUMs data match or ' num2str(unmatchperc) ' %']);
    
 clear unmatchperc nomatch numsumfiles bytes2 
 
 
 
 disp('FINISHED INTEGRATING SUMS DATA');
    disp('--------------------------------------------------------------------------------')
    disp('--------------------------------------------------------------------------------')
else
    disp('USER CHOSE TO SKIP INTEGRATING SUMS DATA')
   disp('--------------------------------------------------------------------------------')
    disp('--------------------------------------------------------------------------------')
end




%% COMBINE CO EXPOSURE DATA

if AA_Combine_CO_exposure == 1
disp('INTEGRATING CO EXPOSURE AND BEACON DATA...')
% First, locate all calibrated CO lascar timeseries

%For Mac
Pathnames_CO_Final = fullfile('/Users',computername,'Google Drive','P3 Data Analysis','CO Real-Time','P1 Lascar CO Inspected','Calibrated with Lascar Format','Final');
allFiles_CO_Final = dir(Pathnames_CO_Final);
filenames_CO_Final = {allFiles_CO_Final.name};
filenames_CO_Final(strncmp(filenames_CO_Final,'.',1)) = [];
%For windows
if isempty(filenames_CO_Final)
    Pathnames_CO_Final = fullfile('F:','Google Drive','P3 Data Analysis','CO Real-Time','P1 Lascar CO Inspected','Calibrated with Lascar Format','Final');
    allFiles_CO_Final = dir(Pathnames_CO_Final);
    filenames_CO_Final = {allFiles_CO_Final.name};
    filenames_CO_Final(strncmp(filenames_CO_Final,'.',1)) = []; %If a file name only has a decimal remove it
end

if isempty(filenames_CO_Final)
    Pathnames_CO_Final = fullfile('D:','GDrive','P3 Data Analysis','CO Real-Time','P1 Lascar CO Inspected','Calibrated with Lascar Format','Final');
    allFiles_CO_Final = dir(Pathnames_CO_Final);
    filenames_CO_Final = {allFiles_CO_Final.name};
    filenames_CO_Final(strncmp(filenames_CO_Final,'.',1)) = []; %If a file name only has a decimal remove it
end


if isempty(filenames_CO_Final)
    disp('Select calibrated Lascar CO .mat data files');
    [filenames_CO_Final, Pathnames_CO_Final] = uigetfile('*','Select calibrated Lascar CO .mat data files','MultiSelect','on');
    if isequal(filenames_CO_Final,0); disp('No files selected, run ended'); errorize; end
end

%Determine how many individual lascar deployments there are
bytes2 = [allFiles_CO_Final.bytes].';
lascarCOfile_ind = bytes2>150;
numlascarfiles = sum(bytes2>150); % Only choose files over 150 bytes to prevent bugging out
disp([num2str(numlascarfiles), ' calibrated Lascar files found...']);
disp('........................................')

% Define how many users are not matched (start at zero)
nomatch = 0;

for i=1:numbeaconfiles %Loops through beacon files
    if ~ismac
    try  bfullname = fullfile(loopfiles(i).folder, loopfiles(i).name);
        bname = loopfiles(i).name;
         load(bfullname);%load deployment file
    catch err; disp('!!!(PC) Error loading one or more beacon Deployment_roomcat file(s)!!!');%print warning if file was not loaded
    end
    else
    try bfullname = fullfile(Pathnames_Beacons_Final, loopfiles(i).name);
        bname = loopfiles(i).name;
         load(bfullname);%load deployment file
    catch err; disp('!!!(Mac) Error loading one or more beacon Deployment_roomcat file(s)!!!');%print warning if file was not loaded
    end
    end   
                disp(['Adding CO exposure to deployment: ', loopfiles(i).name]); %continue;
                
                %MATCHCOEXPOSURE function
                [Deployment_roomcat_save_temp, nomatch] = matchcoexposure(Deployment_roomcat_save,Pathnames_Beacons_Final,allFiles_CO_Final,Deployment,bname, nomatch, AA_COsmoothing, rollingtime, AA_Lascar_LOQ_replace, Lascar_LOQ);
               
                %Save the new(Co matched) Deployment_roomcat to allFiles.folder
                Deployment_roomcat_save = Deployment_roomcat_save_temp; 
                
               if ~ismac
               save(fullfile(loopfiles(i).folder, loopfiles(i).name),'Deployment_roomcat_save');%Saves updated deployment file
               else
               save(fullfile(Pathnames_Beacons_Final, loopfiles(i).name),'Deployment_roomcat_save');%Saves updated deployment file
               end
               
    clear matchind  nummatch name ia ib ind lnamematch numlascarfiles Deployment_roomcat_save_temp Deployment_roomcat_save te ts User Userind Userind_match lname lnamematch order dte d_ts d_te d_ts_buffdown d_ts_buffup
end

    unmatchperc = nomatch/(numbeaconfiles)*100;
    disp([num2str(nomatch) ' beacon file(s) had no CO exposure match or ' num2str(unmatchperc) ' %']);
    disp('FINISHED INTEGRATING CO EXPOSURE');
    disp('--------------------------------------------------------------------------------')
    disp('--------------------------------------------------------------------------------')

else
    disp('USER CHOSE TO SKIP INTEGRATING CO EXPOSURE')
    disp('--------------------------------------------------------------------------------')
    disp('--------------------------------------------------------------------------------')
end


%% COMBINE PM AND COMPLIANCE DATA

%Include similar matching mechanisms for the raw HAPEx data and
%filter-corrected data

if AA_Combine_PM_exposure_compliance == 1
    disp('INTEGRATING PM EXPOSURE AND COMPLIANCE DATA...')

    %First, turn the warning off due to the amount of warnings that
    %accompany the readtable function
    warning('off',id)
    
    % First, locate all baseline-corrected PM hapex timeseries
try
 %For Mac
Pathnames_bcor_Hapex = fullfile('/Users',computername,'Google Drive','P3 Data Analysis','HAPEX Data','Final');
allFiles_bcor_Hapex = dir(Pathnames_bcor_Hapex);
filenames_bcor_Hapex = {allFiles_bcor_Hapex.name};
filenames_bcor_Hapex(strncmp(filenames_bcor_Hapex,'.',1)) = [];


%For windows
if isempty(filenames_bcor_Hapex)
    Pathnames_bcor_Hapex = fullfile('F:','Google Drive','P3 Data Analysis','HAPEX Data','Final');
    allFiles_bcor_Hapex = dir(Pathnames_bcor_Hapex);
    filenames_bcor_Hapex = {allFiles_bcor_Hapex.name};
    filenames_bcor_Hapex(strncmp(filenames_bcor_Hapex,'.',1)) = [];
end

if isempty(filenames_bcor_Hapex)
    Pathnames_bcor_Hapex = fullfile('D:','GDrive','P3 Data Analysis','HAPEX Data','Final');
    allFiles_bcor_Hapex = dir(Pathnames_bcor_Hapex);
    filenames_bcor_Hapex = {allFiles_bcor_Hapex.name};
    filenames_bcor_Hapex(strncmp(filenames_bcor_Hapex,'.',1)) = [];
end

%If no files were found in the Final folder
if isempty(filenames_bcor_Hapex)
    disp('No PM files automatically detected')
    disp('Select baseline-corrected HAPEx or MicroPEMs data files');
    [filenames_bcor_Hapex, Pathnames_bcor_Hapex] = uigetfile('*','Select baseline-corrected HAPEx or MicroPEMs data files','MultiSelect','on');
    if isequal(filenames_bcor_Hapex,0); disp('!!!No PM files selected, run ended!!!'); errorize; end
end    
catch
    disp('!!!Issue locating HAPEX or MicroPEMs files!!!')
end

try
allFiles_bcor_Hapex = allFiles_bcor_Hapex(contains({allFiles_bcor_Hapex.name},'csv')); %Check for csv in name (will be important to match for MicroPEM data)
numrawhapexfiles = length(allFiles_bcor_Hapex);% Only choose files over 150 bytes to prevent bugging out
disp([num2str(numrawhapexfiles), ' HAPEx bcor or MicroPEMs csv files found...']);

hapexfiles = allFiles_bcor_Hapex(contains({allFiles_bcor_Hapex.name},'HAPEX'));
numhapexfiles = length(hapexfiles);% Only choose files over 150 bytes to prevent bugging out
if any(numhapexfiles)
disp([num2str(numhapexfiles), ' HAPEx bcor csv files found...']);
end

micropemsfiles = allFiles_bcor_Hapex(contains({allFiles_bcor_Hapex.name},'BM'));
numrawmicropemsfiles = length(micropemsfiles);% Only choose files over 150 bytes to prevent bugging out
if any(numrawmicropemsfiles)
disp([num2str(numrawmicropemsfiles), ' MicroPEMs csv files found...']);
end

catch
disp('!!!Issues identifying HAPEx or MicroPEMs files - try running Matlab2016 or later!!!')
end

disp('........................................')

% Define how many users are not matched (start at zero)
nomatch = 0;

for i=1:numbeaconfiles %Loops through beacon files
    
    if ~ismac
    try  bfullname = fullfile(loopfiles(i).folder, loopfiles(i).name);
        bname = loopfiles(i).name;
         load(bfullname);%load deployment file
    catch err; disp('!!!(PC) Error loading one or more beacon Deployment_roomcat file(s)!!!');%print warning if file was not loaded
    end
    else
    try bfullname = fullfile(Pathnames_Beacons_Final, loopfiles(i).name);
        bname = loopfiles(i).name;
         load(bfullname);%load deployment file
    catch err; disp('!!!(Mac) Error loading one or more beacon Deployment_roomcat file(s)!!!');%print warning if file was not loaded
    end
    end
                %Start by displaying HAPEx PM is being added to file(i)
                disp(['Adding PM exposure and compliance to deployment: ', loopfiles(i).name]); %continue;
 
                %FUNCTION for adding raw PM exposure here
                [Deployment_roomcat_save_temp, nomatch, class_log] = matchPMexposure(Deployment_roomcat_save,Pathnames_Beacons_Final,allFiles_bcor_Hapex,HAPDeployment,bname, nomatch, AA_HAPEx_LOQ_replace, HAPEx_LOQ, class_log,i);
               
                
                %save the new( (PM-matched) Deployment_roomcat to allFiles.folder                
                Deployment_roomcat_save = Deployment_roomcat_save_temp; 
                
               if ~ismac
               save(fullfile(loopfiles(i).folder, loopfiles(i).name),'Deployment_roomcat_save'); %Saves updated deployment file
               else
               save(fullfile(Pathnames_Beacons_Final, loopfiles(i).name),'Deployment_roomcat_save'); %Saves updated deployment file
               end
       
       clear matchind  nummatch name ia ib ind hnamematch numlascarfiles Deployment_roomcat_save_temp Deployment_roomcat_save te ts User Userind Userind_match hname hnamematch order dte d_ts d_te d_ts_buffdown d_ts_buffup
       %end
end

    unmatchperc = nomatch/(numbeaconfiles)*100;
    disp([num2str(nomatch) ' beacon file(s) had no PM exposure match or ' num2str(unmatchperc) ' %']);
    disp('FINISHED INTEGRATING PM EXPOSURE AND COMPLIANCE');
    disp('--------------------------------------------------------------------------------')
    disp('--------------------------------------------------------------------------------')
else
    disp('USER CHOSE TO SKIP INTEGRATING PM EXPOSURE AND COMPLIANCE')
    disp('--------------------------------------------------------------------------------')
    disp('--------------------------------------------------------------------------------')
end %Combine_PM_compliance conditional
    warning('on',id)
    
    
%% COMBINE USER, HOUSEHOLD AND INTERVENTION DATA

if AA_HH_User_info==1
% Define how many users are not matched (start at zero)
    disp('INTEGRATING HOUSEHOLD AND USER DATA...')

HH_data = table();
User_data = table();

%Script to set up some import options for User_data.xlsx file
import_user_data_opts

%Load HH data
try
HH_data = readtable('HH_data.xlsx'); disp('HH data loaded'); catch; disp('!!!Issue loading HH_data.xlsx. Check File!!!'); end

%Load User data
try
User_data = readtable('User_data.xlsx', opts, "UseExcel", false); disp('User data loaded'); User_data.Tempage3 = datetime(User_data.Tempage3, 'Format', 'dd-MMM-yyyy'); 
clear opts; 
catch; disp('!!!Issue loading User_data.xlsx. Check File!!!');
end


hh_nomatch = 0;
user_nomatch = 0;

for jk=1:numbeaconfiles %Loops through beacon files
    if ~ismac
    try  bfullname = fullfile(loopfiles(jk).folder, loopfiles(jk).name);
        bname = loopfiles(jk).name;
         load(bfullname);%load deployment file
    catch err; disp('!!!(PC) Error loading one or more beacon Deployment_roomcat file(s)!!!');%print warning if file was not loaded
    end
    else
    try bfullname = fullfile(Pathnames_Beacons_Final, loopfiles(jk).name);
        bname = loopfiles(jk).name;
         load(bfullname);%load deployment file
    catch err; disp('!!!(Mac) Error loading one or more beacon Deployment_roomcat file(s)!!!');%print warning if file was not loaded
    end
    end
                %Start by displaying which deployment file(i) will have user data added
                %disp(['Adding HH and User data to deployment: ', loopfiles(jk).name]); %continue;
 
              try  %FUNCTION for adding HH and User data
                [Deployment_roomcat_save_temp, hh_nomatch, user_nomatch] = add_deployment_data(Deployment_roomcat_save, bname, hh_nomatch, user_nomatch, HH_data, User_data);
                
                %save the new Deployment_roomcat to allFiles.folder with HH/User data
                Deployment_roomcat_save = Deployment_roomcat_save_temp;
                
                if ~ismac
                save(fullfile(loopfiles(jk).folder, loopfiles(jk).name),'Deployment_roomcat_save'); %Saves updated deployment file
                else
                save(fullfile(Pathnames_Beacons_Final, loopfiles(jk).name),'Deployment_roomcat_save'); %Saves updated deployment file
                end
                
              catch
                disp('Issue adding user data to deployment:'); disp([loopfiles(jk).name, ';  jk = ', num2str(jk)]);
              end
              
       
       clear hhind HHID USERID userind matchedind Deployment_roomcat_save_temp
end

    hh_unmatchperc = hh_nomatch/(numbeaconfiles)*100;
    disp([num2str(hh_nomatch) ' beacon file(s) had no HH data match or ' num2str(hh_unmatchperc) ' %']);
    
    user_unmatchperc = user_nomatch/(numbeaconfiles)*100;
    disp([num2str(user_nomatch) ' beacon file(s) had no USER data match or ' num2str(user_unmatchperc) ' %']);
   
    clear hh_nomatch user_nomatch user_unmatchperc hh_unmatchperc
    
    disp('FINISHED INTEGRATING USER INFORMATION TO DEPLOYMENTS');
    disp('--------------------------------------------------------------------------------')
    disp('--------------------------------------------------------------------------------')
    
else
    disp('USER CHOSE TO SKIP INTEGRATING USER INFO')
    disp('--------------------------------------------------------------------------------')
    disp('--------------------------------------------------------------------------------')
end %User_info conditional
    warning('on',id)
    

%% FILTER AND FLAG CO DATA

if AA_flag_CO_exposure==1
disp('FILTERING AND FLAGGING CO EXPOSURE DATA...')

    %Display what flagging mode was selected
    if flagmode==1
        disp('Data is being automatically flagged')
    else
        disp('Data is being manually flagged')
    end
    
for lm=1:numbeaconfiles %Loops through beacon files
    if ~ismac
    try  bfullname = fullfile(loopfiles(lm).folder, loopfiles(lm).name);
        bname = loopfiles(lm).name;
         load(bfullname);%load deployment file
    catch err; disp('!!!(PC) Error loading one or more beacon Deployment_roomcat file(s)!!!');%print warning if file was not loaded
    end
    else
    try bfullname = fullfile(Pathnames_Beacons_Final, loopfiles(lm).name);
        bname = loopfiles(lm).name;
         load(bfullname);%load deployment file
    catch err; disp('!!!(Mac) Error loading one or more beacon Deployment_roomcat file(s)!!!');%print warning if file was not loaded
    end
    end
                %Start by displaying which deployment file(i) will be flagged/filtered
                disp(['Flagging CO exposure data for: ', loopfiles(lm).name]); %continue;

                %FUNCTION for filtering/flagging
                [Deployment_roomcat_save_temp,] = CO_exposurefiltering(Deployment_roomcat_save, bname, flagmode, Lascar_LOQ);
                
                %save the new Deployment_roomcat to allFiles.folder with flagging
                Deployment_roomcat_save = Deployment_roomcat_save_temp;
                
                if ~ismac
                save(fullfile(loopfiles(lm).folder, loopfiles(lm).name),'Deployment_roomcat_save'); %Saves updated deployment file
                else
                save(fullfile(Pathnames_Beacons_Final, loopfiles(lm).name),'Deployment_roomcat_save'); %Saves updated deployment file
                end
       
       clear Deployment_roomcat_save_temp numlascars lascar_1_ok only_lascar_ok lascar_2_ok hapex_1_ok only_hapex_ok hapex_2_ok numhapex
end

    disp('FINISHED FLAGGING AND FILTERING CO');
    disp('--------------------------------------------------------------------------------')
    disp('--------------------------------------------------------------------------------')
    

else
    disp('USER CHOSE TO SKIP FLAGGING AND FILTERING CO')
    disp('--------------------------------------------------------------------------------')
    disp('--------------------------------------------------------------------------------')

end %Flagging filter conditional


%% FILTER AND FLAG PM DATA and APPLY CORRECTIONS AND PARTICLE COEFFICIENTS
if AA_flag_PM_exposure==1
disp('FILTERING, FLAGGING AND APPLYING CORRECTIONS TO PM EXPOSURE DATA...')

%Display what flagging mode was selected
    if flagmode==1
        disp('Data is being automatically flagged')
    else
        disp('Data is being manually flagged')
    end

num_out_of_range=0;
numbad=0;
                for yyy=1:numbeaconfiles %Loops through beacon files

                    if ~ismac
                    try  bfullname = fullfile(loopfiles(yyy).folder, loopfiles(yyy).name);
                        bname = loopfiles(yyy).name;
                         load(bfullname);%load deployment file
                    catch err; disp('(PC) Error loading one or more beacon Deployment_roomcat file(s)');%print warning if file was not loaded
                    end
                    else
                    try bfullname = fullfile(Pathnames_Beacons_Final, loopfiles(yyy).name);
                        bname = loopfiles(yyy).name;
                         load(bfullname);%load deployment file
                    catch err; disp('(Mac) Error loading one or more beacon Deployment_roomcat file(s)');%print warning if file was not loaded
                    end
                    end

                    
                        try 
                                %Start by displaying which deployment file(yyy) will be matched
                                disp(['Filtering, flagging and applying PM corrections to deployment: ', loopfiles(yyy).name]); %continue;
                                
                                 %FUNCTION for filtering/flagging
                                [Deployment_roomcat_save_temp,num_out_of_range] = PM_exposurefiltering(Deployment_roomcat_save, bname, flagmode, particle_coefficient, HAPEx_LOQ,num_out_of_range);

                                %save the new Deployment_roomcat to allFiles.folder with flagging
                                Deployment_roomcat_save = Deployment_roomcat_save_temp;

                                if ~ismac
                                save(fullfile(loopfiles(yyy).folder, loopfiles(yyy).name),'Deployment_roomcat_save'); %Saves updated deployment file
                                else
                                save(fullfile(Pathnames_Beacons_Final, loopfiles(yyy).name),'Deployment_roomcat_save'); %Saves updated deployment file
                                end
                        catch
                            disp('Issue filtering deployment:'); disp([loopfiles(yyy).name, ';  i = ', num2str(yyy)]);
                            numbad = numbad+1;        
                        end
                            disp('........................................')
                end %beaconfiles loop


    disp('FINISHED FLAGGING AND FILTERING PM');
    disp('--------------------------------------------------------------------------------')
    disp('--------------------------------------------------------------------------------')
    
else
    disp('USER CHOSE TO SKIP FLAGGING AND FILTERING PM')
    disp('--------------------------------------------------------------------------------')
    disp('--------------------------------------------------------------------------------')
end



%% COMBINE MICROENVIRONMENT DATA

if AA_MicroEnv==1
    
disp('INTEGRATING KITCHEN AREA MEASUREMENTS...')

    %Load in MicroEnv data
    try
    master_gpod_Pathnames = strrep(Pathnames_Logsheets,'NIH Beacons','GPod'); %chages existing directory path to navigate to where GPOd data is stored
    master_gpod_Pathnames = strrep(master_gpod_Pathnames,'Log Sheets','Field Data'); %chages existing directory path to navigate to where GPOd data is stored
    master_gpod_Pathnames = strrep(master_gpod_Pathnames,'Final','Calibrated Final');  %chages existing directory path to navigate to where GPOd data is stored

    load(fullfile(master_gpod_Pathnames,'Master_GPOD')) %load in the Master GPod data file (which requires seperate code to generate)
    f = dir(fullfile(master_gpod_Pathnames,'Master_GPOD.mat')); %create file object so we can return date this file was last modified...this needs to be current
    disp(['Master GPod data last modified on ', f.date, ' was succesfully loaded']); clear f; %print when Gdata was last modified
    disp('........................................')
    catch
        disp('!!!Issue loading Master_GPOD.mat file!!!')
    end
    
    %Load in MicroEnv data
    try
    Kintampo_master_gpod_Pathnames = ('F:\Google Drive\P3 Data Analysis\KHRC\Analysis\GPod Data\Raw Field Data\Calibrated Final');
    load(fullfile(Kintampo_master_gpod_Pathnames,'Master_KHRC_GPOD.mat')) %load in the Master GPod data file (which requires seperate code to generate)
    f = dir(fullfile(Kintampo_master_gpod_Pathnames,'Master_KHRC_GPOD.mat')); %create file object so we can return date this file was last modified...this needs to be current
    disp(['KHRC Master GPod data last modified on ', f.date, ' was succesfully loaded']); clear f; %print when Gdata was last modified
    disp('........................................')
    catch
        disp('!!!Issue loading Master_KHRC_GPOD.mat file!!!')
    end
    
yesmatched = 0;

    
for kl=1:numbeaconfiles %Loops through beacon files for subsequent matching with kithen level data
    
    if ~ismac
    try  bfullname = fullfile(loopfiles(kl).folder, loopfiles(kl).name);
        bname = loopfiles(lm).name;
         load(bfullname); %load deployment file
    catch err; disp('!!!(PC) Error loading one or more beacon Deployment_roomcat file(s)!!!'); %print warning if file was not loaded
    end
    else
    try bfullname = fullfile(Pathnames_Beacons_Final, loopfiles(kl).name);
        bname = loopfiles(kl).name;
         load(bfullname); %load deployment file
    catch err; disp('!!!(Mac) Error loading one or more beacon Deployment_roomcat file(s)!!!');%print warning if file was not loaded
    end
    end
                %Start by displaying which deployment file(i) will be matched
                disp(['Matching kitchen area data for: ', loopfiles(kl).name]); %continue;

                %FUNCTION for matching kitchen area data
                [Deployment_roomcat_save_temp, yesmatched] = microenv_matching(Deployment_roomcat_save, Deployment, Gdata, GdataKintampo, yesmatched, bname, particle_coefficient,HAPEx_LOQ);
                
                %save the new Deployment_roomcat to allFiles.folder with matched kitchen area data
                Deployment_roomcat_save = Deployment_roomcat_save_temp;
                
                if ~ismac
                save(fullfile(loopfiles(kl).folder, loopfiles(kl).name),'Deployment_roomcat_save'); %Saves updated deployment file
                else
                save(fullfile(Pathnames_Beacons_Final, loopfiles(kl).name),'Deployment_roomcat_save'); %Saves updated deployment file
                end
       
       clear Deployment_roomcat_save_temp
end
    
yesmatchedperc = yesmatched/(numbeaconfiles)*100; %percentage of deployments that had a match
disp([num2str(yesmatched) ' beacon file(s) had kitchen area data matches or ' num2str(yesmatchedperc,3) ' %']); %display overall matching results
%clear yesmatchedperc yesmatched
disp('FINISHED INTEGRATING KITCHEN AREA MEASUREMENTS');
disp('--------------------------------------------------------------------------------')
disp('--------------------------------------------------------------------------------')

else

disp('USER CHOSE TO SKIP INTEGRATING KITCHEN AREA MEASUREMENTS')
disp('--------------------------------------------------------------------------------')
disp('--------------------------------------------------------------------------------')

end



%% APPLY USER DEFINED AVERAGING TIME

%Turns binary categoricals to 1/0 for averaging (e.g. closest area for proximity, 'flag', 'cooking status' etc.) - only works if there are two options (and NaN)

if AA_Deployment_Time_Averaging==1

disp('PERFORMING TIME AVERAGING...')
avg_time = minutes(deploymnent_min_avg);
disp('Averaging time: '); disp(avg_time)
disp('........................................') 


% create sub folder named with time-averaging duration
 mkdir(fullfile(loopfiles(1).folder, char(avg_time))) %will throw warning if it already exists
                

%define the variable that keeps track of the number of "unplottable" beacon files
numbad = 0;

for i=1:numbeaconfiles %Loops through beacon files (first two are directory placeholders and last is not included in # of beacon files)
    
    if ~ismac
    try  bfullname = fullfile(loopfiles(i).folder, loopfiles(i).name);
        bname = loopfiles(i).name;
         load(bfullname);%load deployment file
    catch err; disp('(PC) Error loading one or more beacon Deployment_roomcat file(s)');%print warning if file was not loaded
    end
    else
    try bfullname = fullfile(Pathnames_Beacons_Final, loopfiles(i).name);
        bname = loopfiles(i).name;
         load(bfullname);%load deployment file
    catch err; disp('(Mac) Error loading one or more beacon Deployment_roomcat file(s)');%print warning if file was not loaded
    end
    end

        try    
                disp(['Time-averaging deployment: ', loopfiles(i).name]); %continue;
                [Deployment_roomcat_save_temp,numbad] = deployment_time_average(Deployment_roomcat_save,avg_time,bname,numbad,psname);
        
                %save the new Deployment_roomcat to allFiles.folder with flagging
                Deployment_roomcat_save = Deployment_roomcat_save_temp;
              
                if ~ismac
                save(fullfile(loopfiles(i).folder, char(avg_time), loopfiles(i).name),'Deployment_roomcat_save'); %Saves updated deployment file
                else
                save(fullfile(Pathnames_Beacons_Final, char(avg_time), loopfiles(i).name),'Deployment_roomcat_save'); %Saves updated deployment file
                end
        catch
            disp('Issue averaging deployment:'); disp([loopfiles(i).name, ';  i = ', num2str(i)]);
            numbad = numbad+1;        
            disp('........................................')
        end
            disp('........................................')

end

    %Need to change which deployment files are going to be used in the
    %make-Master_csv code - this could happen here or in the
    %Make_master_csv section

    badperc = numbad/(numbeaconfiles)*100;
    disp([num2str(numbad) ' deployment files had issue time-averaging or ' num2str(badperc) ' %']);
    disp('FINISHED AVERAGING DEPLOYMENT DATA');
    disp('--------------------------------------------------------------------------------')
    disp('--------------------------------------------------------------------------------')
else
    disp('TIME AVERAGING SKIPPED BY USER - using 1-min data!')
    disp('--------------------------------------------------------------------------------')
    disp('--------------------------------------------------------------------------------')
end


%% DETERMINE TIME-ACTIVITY CATEGORIES

if AA_Classifications == 1
    
disp('PERFORMING TIME/ACTIVITY CLASSIFICATION')

        if AA_Deployment_Time_Averaging==1

            try
                if exist('temploopfiles', 'var') %has this loop been run before and therefore the directory already been changed
                    
                    disp('Detected the user is re-running the activity-classification section again')
                    disp('...ignore "Issue converting numerics" messages')
                    pause(2)
                    
                    if isempty(filenames_Beacons_Final)
                    Pathnames_Beacons_Final = fullfile('F:','Google Drive','P3 Data Analysis','NIH Beacons','Beacon Logger Data P1', 'Smoothed Deployments','Final');
                    allFiles_Beacons_Final = dir(Pathnames_Beacons_Final);
                    filenames_Beacons_Final = { allFiles_Beacons_Final.name };
                    filenames_Beacons_Final(strncmp(filenames_Beacons_Final,'.',1)) = [];
                    end

                    try
                    tempfiles = {allFiles_Beacons_Final.name};
                    legitind = contains(tempfiles,'Roomcat'); %Check for 
                    loopfiles = allFiles_Beacons_Final(contains({allFiles_Beacons_Final.name},'Roomcat'));
                    numbeaconfiles = sum(legitind);% Only choose files over 150 bytes to prevent bugging out
                    catch
                        disp('Trying another beacon identification technique...')
                        try
                           bytes = [allFiles_Beacons_Final.bytes].';
                           beaconfile_ind = bytes>150;
                           loopfiles = allFiles_Beacons_Final(beaconfile_ind);
                           numbeaconfiles = sum(beaconfile_ind);% Only choose files over 150 bytes to prevent bugging out
                           disp([num2str(numbeaconfiles), ' beacon deployments found...']);
                        catch
                            disp('!!!Issues identifying beacon files - try running Matlab2016 or later!!!')
                        end
                    end
                    clear allFiles legitind tempfiles beaconfile_ind bytes


                    avgFiles_Beacons_Final = dir(fullfile(loopfiles(1).folder,char(avg_time)));
                    temploopfiles = avgFiles_Beacons_Final(contains({avgFiles_Beacons_Final.name},'Roomcat'));
                    loopfiles = temploopfiles;
                    numbeaconfiles = length(struct2cell(loopfiles));

                else %the time-averaged directory hasn't been created and thus is created now
                    avgFiles_Beacons_Final = dir(fullfile(loopfiles(1).folder,char(avg_time)));
                    temploopfiles = avgFiles_Beacons_Final(contains({avgFiles_Beacons_Final.name},'Roomcat'));
                    loopfiles = temploopfiles;
                    numbeaconfiles = length(struct2cell(loopfiles));
                
                end
            catch
                disp('Issue changing deployment directory to time-averaged directory. Check folders.'); line928
            end

            % classification for time averaging code
            disp('Classifying time-averaged deployments')
            numbad=0; bad_beacon=0;
            
                for yyy=1:numbeaconfiles %Loops through beacon files

                    if ~ismac
                    try  bfullname = fullfile(loopfiles(yyy).folder, loopfiles(yyy).name);
                        bname = loopfiles(yyy).name;
                         load(bfullname);%load deployment file
                    catch err; disp('(PC) Error loading one or more beacon Deployment_roomcat file(s)');%print warning if file was not loaded
                    end
                    else
                    try bfullname = fullfile(Pathnames_Beacons_Final, loopfiles(yyy).name);
                        bname = loopfiles(yyy).name;
                         load(bfullname);%load deployment file
                    catch err; disp('(Mac) Error loading one or more beacon Deployment_roomcat file(s)');%print warning if file was not loaded
                    end
                    end
                    
                            try 
                                %Start by displaying which deployment file(i) will be matched
                                disp(['Classifying activities for: ', loopfiles(yyy).name]); %continue;

                                    [Deployment_roomcat_save_temp,numbad,class_log,bad_beacon] = classify_activities(Deployment_roomcat_save,AA_Deployment_Time_Averaging,bname,numbad,psname,yyy,class_log,bad_beacon);

                                    %save the new Deployment_roomcat to allFiles.folder with flagging
                                    Deployment_roomcat_save = Deployment_roomcat_save_temp;

                                    if ~ismac
                                    save(fullfile(loopfiles(yyy).folder, loopfiles(yyy).name),'Deployment_roomcat_save'); %Saves updated deployment file
                                    else
                                    save(fullfile(Pathnames_Beacons_Final, loopfiles(yyy).name),'Deployment_roomcat_save'); %Saves updated deployment file
                                    end
                            catch
                                disp('Issue classifying deployment:'); disp([loopfiles(yyy).name, ';  i = ', num2str(yyy)]);
                                numbad = numbad+1;        
                                disp('........................................')
                            end
                                disp('........................................')
                                
                end %beaconfiles loop

        else %No time averaging
            disp('Classifying 1-min deployments')
            numbad=0; bad_beacon=0;

                for yyy=1:numbeaconfiles %Loops through beacon files

                    if ~ismac
                    try  bfullname = fullfile(loopfiles(yyy).folder, loopfiles(yyy).name);
                        bname = loopfiles(yyy).name;
                         load(bfullname);%load deployment file
                    catch err; disp('(PC) Error loading one or more beacon Deployment_roomcat file(s)');%print warning if file was not loaded
                    end
                    else
                    try bfullname = fullfile(Pathnames_Beacons_Final, loopfiles(yyy).name);
                        bname = loopfiles(yyy).name;
                         load(bfullname);%load deployment file
                    catch err; disp('(Mac) Error loading one or more beacon Deployment_roomcat file(s)');%print warning if file was not loaded
                    end
                    end

                        try 
                                %Start by displaying which deployment file(i) will be matched
                                disp(['Classifying activities for: ', loopfiles(yyy).name]); %continue;
                                
                                [Deployment_roomcat_save_temp,numbad,class_log,bad_beacon] = classify_activities(Deployment_roomcat_save,AA_Deployment_Time_Averaging,bname,numbad,psname,yyy,class_log,bad_beacon);

                                %save the new Deployment_roomcat to allFiles.folder with flagging
                                Deployment_roomcat_save = Deployment_roomcat_save_temp;

                                if ~ismac
                                save(fullfile(loopfiles(yyy).folder, loopfiles(yyy).name),'Deployment_roomcat_save'); %Saves updated deployment file
                                else
                                save(fullfile(Pathnames_Beacons_Final, loopfiles(yyy).name),'Deployment_roomcat_save'); %Saves updated deployment file
                                end
                        catch
                            disp('Issue classifying deployment:'); disp([loopfiles(yyy).name, ';  i = ', num2str(yyy)]);
                            numbad = numbad+1;        
                            disp('........................................')
                        end
                            disp('........................................')
                end %beaconfiles loop

        end %time-avergaing conditional
        
    badperc = numbad/(numbeaconfiles)*100;
    disp([num2str(numbad) ' deployment files had issue classifying or ' num2str(badperc) ' %']);
    
    
    bad_beacon_percentage = bad_beacon/(numbeaconfiles)*100;
    disp([num2str(bad_beacon) ' deployment files had poor Beacon data or ' num2str(bad_beacon_percentage) ' %']);
    
    
    clear bad_beacon_percentage bad_beacon badperc numbad
    
    disp('FINISHED CLASSIFYING DEPLOYMENT DATA');
    disp('--------------------------------------------------------------------------------')
    disp('--------------------------------------------------------------------------------')   
         
else %skip classification
    disp('CLASSIFICATION SKIPPED BY USER')
    disp('--------------------------------------------------------------------------------')
    disp('--------------------------------------------------------------------------------')
end


%% GENERATE DEPLOYMENT PLOTS OF TIME SPENT AND EXPOSURE (BOXPLOTS) INCURRED BY ACTIVITY

if AA_Generate_STEP_plots ==1
    
disp('USER CHOSE TO GENERATE S.T.E.P. PLOTS')

w = warning ('off','all'); %Warning set to off
noncomp = 0; %Define noncomp as the number of 
notplotted = 0; %Deployments that do not plot
comptable = table();

 for yyy=1:numbeaconfiles %Loops through beacon files

                    if ~ismac
                    try  bfullname = fullfile(loopfiles(yyy).folder, loopfiles(yyy).name);
                        bname = loopfiles(yyy).name;
                         load(bfullname);%load deployment file
                    catch err; disp('(PC) Error loading one or more beacon Deployment_roomcat file(s)');%print warning if file was not loaded
                    end
                    else
                    try bfullname = fullfile(Pathnames_Beacons_Final, loopfiles(yyy).name);
                        bname = loopfiles(yyy).name;
                         load(bfullname);%load deployment file
                    catch err; disp('(Mac) Error loading one or more beacon Deployment_roomcat file(s)');%print warning if file was not loaded
                    end
                    end
                    
                            try 
                                %Start by displaying which deployment file(i) will be matched
                                disp(['Generating report plots for: ', loopfiles(yyy).name]); %continue;

                                    generate_STEP_plots
                                
                                    try [noncomp, comptable] = final_plotting(Deployment_roomcat_save,bname,noncomp,comptable,psname);
                                    catch
                                        disp('!!!Issue plotting 48hr timeseries for deployment #:'); disp(loopfiles(i).name);
                                        notplotted = notplotted+1; %If there's an issue add one to the notplotted counter
                                        comptable = [comptable;comptable];
                                    end

                                clear stove1 stove2 stove3 stove4 stove5 stove6 stove7 s1 s2 s3 s4 s5 s6 s7 stove1U stove2U stove3U stove4U stove5U stove6U stove7U
                                disp('...')
                                
                            catch
                                disp('Check this error out'); disp([loopfiles(yyy).name, ';  i = ', num2str(yyy)]);
                                numbad = numbad+1;        
                                disp('........................................')
                            end
                                disp('........................................')
                                
 end %beaconfiles loop
    w = warning ('on','all');%Warning set back to on

    noncompdep = noncomp/(numbeaconfiles)*100;
    disp([num2str(noncomp) ' beacon file(s) had compliance under 10% or ' num2str(noncompdep) ' %']);
    
    clear noncompdep noncomp notplotted 
    
    disp('FINISHED GENERATING PLOTS');
    disp('........................................')
    disp('........................................')

else
    disp('USER CHOSE TO SKIP GENERATING S.T.E.P. PLOTS')
end


%% GENERATE MASTER CSV FILE

if AA_Make_master_csv==1
       
        mastercsv = table(); %Define new master table
        numadded = 0;
        disp('Merging all deployments into one file...this may take several minutes')
        
        for ik=1:numbeaconfiles %Loops through beacon files (first two are directory placeholders and last is not included in # of beacon files)

            if ~ismac
            try  bfullname = fullfile(loopfiles(ik).folder, loopfiles(ik).name);
                bname = loopfiles(ik).name;
                 load(bfullname);%load deployment file
            catch err; disp('!!!(PC) Error loading one or more beacon Deployment_roomcat file(s)!!!');%print warning if file was not loaded
            end
            else
            try bfullname = fullfile(Pathnames_Beacons_Final, loopfiles(ik).name);
                bname = loopfiles(ik).name;
                 load(bfullname);%load deployment file
            catch err; disp('!!!(Mac) Error loading one or more beacon Deployment_roomcat file(s)!!!');%print warning if file was not loaded
            end
            end
                       try
                        %Append loopfile ik to master csv
                        if ~iscell(Deployment_roomcat_save.Lascar_1_Name(1))
                       Deployment_roomcat_save.Lascar_1_Name = num2cell(Deployment_roomcat_save.Lascar_1_Name);
                        end

                        if ~iscell(Deployment_roomcat_save.Lascar_2_Name(1))
                       Deployment_roomcat_save.Lascar_2_Name = num2cell(Deployment_roomcat_save.Lascar_2_Name);
                        end
                        
                        Deployment_roomcat_save.BeaconMAC1 = string(Deployment_roomcat_save.BeaconMAC1);
                        Deployment_roomcat_save.BeaconMAC2 = string(Deployment_roomcat_save.BeaconMAC2);
 
                        
                        %Add a deployment number identifier variable to each Deployment_roomcat_save
                        Deployment_roomcat_save.DeploymentNum(:) = ik;
                        
                       %Append 
                       mastercsv = [mastercsv; Deployment_roomcat_save];
                       numadded=numadded+1;
                       catch; disp(['Issue appending deployments together. Check file: ',bname, '; ik = ', num2str(ik)])
                       end

               clear matchind  nummatch name ia ib ind lnamematch numlascarfiles Deployment_roomcat_save_temp Deployment_roomcat_save te ts User Userind Userind_match lname lnamematch order dte d_ts d_te d_ts_buffdown d_ts_buffup
        end 

            disp([num2str(numadded), ' files appended into master'])
           
            %Change the pathname for mastercsv file saving
            if ~ismac
            master_Pathnames = strrep(Pathnames_Logsheets,'Log Sheets','R code\data');
            master_Pathnames = strrep(master_Pathnames,'\Final','');  
            else
            master_Pathnames = strrep(Pathnames_Logsheets,'Log Sheets','R code/data');
            master_Pathnames = strrep(master_Pathnames,'/Final','');      
            end
            
            
             if AA_Save_master_csv_MAT==1
                %save mastercsv to current directory
                try
                    disp('Saving mastercsv .MAT file - this may take several minutes to hours...')
                    save([strcat(AA_beacon_cal_type,'_','mastercsv','_',datestr(now,'mm_dd_yyyy_HH_MM'))],'mastercsv','-v7.3');
                    disp('...mastercsv .MAT file successfully saved')

                catch
                    disp('!!!mastercsv not saved as .MAT file!!!')
                end
             end
            
            
            % Save the master csv and class_log
            if ~ismac
            disp('Saving the mastercsv .CSV file and class log...this may take several minutes')
            
                if AA_Deployment_Time_Averaging==1 %if averaging was done save to the time averaging folder
                    
                mkdir(fullfile(master_Pathnames, char(avg_time))) % create folder - will throw warning if it already exists
                writetable(mastercsv, fullfile(master_Pathnames, char(avg_time),strcat(AA_beacon_cal_type,'_mastercsv','_',datestr(now,'mm_dd_yyyy_HH_MM'),'.csv')));
                writetable(class_log, fullfile(master_Pathnames, char(avg_time),strcat(AA_beacon_cal_type,'_classlog','_',datestr(now,'mm_dd_yyyy_HH_MM'),'.csv')));
                disp('Time-averaged mastercsv file and classlog file saved successfully')
                disp('--------------------------------------------------------------------------------')
                disp('--------------------------------------------------------------------------------')
                
                else
                writetable(mastercsv, fullfile(master_Pathnames, strcat(AA_beacon_cal_type,'_mastercsv','_',datestr(now,'mm_dd_yyyy_HH_MM'),'.csv')));
                writetable(class_log, fullfile(master_Pathnames, strcat(AA_beacon_cal_type,'_classlog','_',datestr(now,'mm_dd_yyyy_HH_MM'),'.csv')));                            
                disp('Mastercsv file and classlog file saved successfully')
                disp('--------------------------------------------------------------------------------')
                disp('--------------------------------------------------------------------------------') 
                end
                
            else
            disp('Saving the mastercsv .CSV file and class log...this may take several minutes')
            
                if AA_Deployment_Time_Averaging==1
                    
                mkdir(fullfile(master_Pathnames, char(avg_time))) % create folder - will throw warning if it already exists
                writetable(mastercsv, fullfile(master_Pathnames, char(avg_time),strcat(AA_beacon_cal_type,'_mastercsv','_',datestr(now,'mm_dd_yyyy_HH_MM'),'.csv')));
                writetable(class_log, fullfile(master_Pathnames, char(avg_time),strcat(AA_beacon_cal_type,'_classlog','_',datestr(now,'mm_dd_yyyy_HH_MM'),'.csv')));
                disp('Time-averaged mastercsv file and classlog file saved successfully')
                disp('--------------------------------------------------------------------------------')
                disp('--------------------------------------------------------------------------------')
                else
                writetable(mastercsv, fullfile(master_Pathnames,strcat(AA_beacon_cal_type,'_mastercsv','_',datestr(now,'mm_dd_yyyy_HH_MM'),'.csv')));
                writetable(class_log, fullfile(master_Pathnames,strcat(AA_beacon_cal_type,'_classlog','_',datestr(now,'mm_dd_yyyy_HH_MM'),'.csv')));
                disp('Mastercsv file and classlog file saved successfully')
                disp('--------------------------------------------------------------------------------')
                disp('--------------------------------------------------------------------------------') 
                end %saving file operating system conditional
            end

            
else
disp('MAKE AND SAVE MASTER CSV FILE SKIPPED BY USER')
disp('--------------------------------------------------------------------------------')
disp('--------------------------------------------------------------------------------')

end % AA_Make_master_csv conditional


%% CHECK COMPLIANCE

if AA_CHECKCOMPLIANCE==1
    
noncomp = 0;
notplotted = 0;
comptable = table();
    
for i=1:numbeaconfiles %Loops through beacon files (first two are directory placeholders and last is not included in # of beacon files)
    if ~ismac
    try  bfullname = fullfile(loopfiles(i).folder, loopfiles(i).name);
        bname = loopfiles(i).name;
         load(bfullname);%load deployment file
    catch err; disp('(PC) Error loading one or more beacon Deployment_roomcat file(s)');%print warning if file was not loaded
    end
    else
    try bfullname = fullfile(Pathnames_Beacons_Final, loopfiles(i).name);
        bname = loopfiles(i).name;
         load(bfullname);%load deployment file
    catch err; disp('(Mac) Error loading one or more beacon Deployment_roomcat file(s)');%print warning if file was not loaded
    end
    end

        try [noncomp, comptable] = check_compliance(Deployment_roomcat_save,bname,noncomp,comptable,psname);
        catch
            disp('!!!Issue visualizing compliance for beacon series:'); disp(loopfiles(i).name);
        notplotted = notplotted+1;
        comptable = [comptable;comptable];
        end
        
end
    noncompdep = noncomp/(numbeaconfiles)*100;
    disp([num2str(noncomp) ' beacon file(s) had compliance under 10% or ' num2str(noncompdep) ' %']);
    disp('FINISHED CHECKING COMPLIANCE!');
    disp('--------------------------------------------------------------------------------')
    disp('--------------------------------------------------------------------------------')
else
    disp('CHECKING COMPLIANCE SKIPPED BY USER!')
    disp('--------------------------------------------------------------------------------')
    disp('--------------------------------------------------------------------------------')
end
    

%% CHECK GPS AND LOCATION

if AA_CHECKLOCATION ==1
 
%define the variable that keeps track of the number of files with no GPS and "unplottable" GPS/Proximity beacon files
numpaired = 0;
notplotted = 0;

for i=1:numbeaconfiles %Loops through beacon files (first two are directory placeholders and last is not included in # of beacon files)
    if ~ismac
    try  bfullname = fullfile(loopfiles(i).folder, loopfiles(i).name);
        bname = loopfiles(i).name;
         load(bfullname);%load deployment file
    catch err; disp('(PC) Error loading one or more beacon Deployment_roomcat file(s)');%print warning if file was not loaded
    end
    else
    try bfullname = fullfile(Pathnames_Beacons_Final, loopfiles(i).name);
        bname = loopfiles(i).name;
         load(bfullname);%load deployment file
    catch err; disp('(Mac) Error loading one or more beacon Deployment_roomcat file(s)');%print warning if file was not loaded
    end
    end

        try [Deployment_roomcat_save_temp,numpaired] = prox_gps_check(Deployment_roomcat_save,bname,numpaired,psname);
            if ~ismac
               save(fullfile(loopfiles(i).folder, loopfiles(i).name),'Deployment_roomcat_save'); %Resave the Deployment with classifications now
            else
               save(fullfile(Pathnames_Beacons_Final, loopfiles(i).name),'Deployment_roomcat_save'); %Resave the Deployment with classifications now
            end
        catch
            disp('!!!Issue plotting one or more graphs for beacon series:'); disp(loopfiles(i).name);
        notplotted = notplotted+1;  
        end
        
end
    pairedperc = numpaired/(numbeaconfiles)*100;
    disp([num2str(numpaired) ' beacon file(s) had matches with GPS or ' num2str(pairedperc) ' %']);
    disp('FINISHED PLOTTING GPS vs. PROXIMITY!');
    disp('--------------------------------------------------------------------------------')
    disp('--------------------------------------------------------------------------------')
else
    disp('PLOTTING GPS vs. PROXIMITY SKIPPED BY USER!')
    disp('--------------------------------------------------------------------------------')
    disp('--------------------------------------------------------------------------------')
end
   

%% CO AND PM EXPOSURE PLOTS BY DEPLOYMENT

if AA_PLOTS==1

%define the variable that keeps track of the number of "unplottable" beacon files
numbad = 0;

for i=1:numbeaconfiles %Loops through beacon files (first two are directory placeholders and last is not included in # of beacon files)
    
    if ~ismac
    try  bfullname = fullfile(loopfiles(i).folder, loopfiles(i).name);
        bname = loopfiles(i).name;
         load(bfullname);%load deployment file
    catch err; disp('(PC) Error loading one or more beacon Deployment_roomcat file(s)');%print warning if file was not loaded
    end
    else
    try bfullname = fullfile(Pathnames_Beacons_Final, loopfiles(i).name);
        bname = loopfiles(i).name;
         load(bfullname);%load deployment file
    catch err; disp('(Mac) Error loading one or more beacon Deployment_roomcat file(s)');%print warning if file was not loaded
    end
    end

        try 
            numbad = plot_matching(Deployment_roomcat_save,bname,numbad,psname);
        catch
            disp('Issue plotting one or more graphs for beacon series:'); disp(loopfiles(i).name);
        numbad = numbad+1;
        end
end
    badperc = numbad/(numbeaconfiles)*100;
    disp([num2str(numbad) ' beacon files had issue plotting and were skipped or ' num2str(badperc) ' %']);
    disp('... FINISHED PLOTTING CO EXPOSURE AND BEACON DATA!');
    disp('--------------------------------------------------------------------------------')
    disp('--------------------------------------------------------------------------------')
else
        disp('PLOTTING CO EXPOSURE AND BEACON DATA SKIPPED BY USER!')
        disp('--------------------------------------------------------------------------------')
        disp('--------------------------------------------------------------------------------')
end

%% CLOSE ALL OPEN PLOTS
if AA_CLOSEPLOTS ==1
close all
clear FIG unmatchperc props nomatch
end

%% SAVE PDF OF GENERATED PLOTS
   try
       savePDF(psname,pdfsavename);
       disp('Saved PDF successfully')
   catch
       disp('Issues using savePDF')
       disp('Make sure Plots.pdf is not open in Adobe Acrobat or Preview') 
   end
  
    try
        if exist(psname, 'file')==2
        delete(psname);
            if exist (psname, 'file')==2
               disp('Issue deleting psname') 
            else
                disp('post script deleted')
            end
        else
            disp('post script does not exist')
        end
    catch
        disp('myReportReg.ps not deleted or already deleted')
    end
                                                 
     disp('--------------------------------------------------------------------------------')
     disp('--------------------------------------------------------------------------------')

     

%% SEND AN EMAIL TO THE USER THAT CODE IS DONE RUNNING

if AA_email_user==1    
     
try
    sender = 'enter here'; % example: '****@gmail.com';
    receiver = 'enter here'; %example: '****@gmail.com';
    mailserver = 'enter here'; %example: 'smtp.gmail.com';
    username = 'enter here'; % sender username
    password = 'enter here'; % sender password

    setpref('Internet','E_mail',sender);
    setpref('Internet','SMTP_Server',mailserver);
    setpref('Internet','SMTP_Username',username);
    setpref('Internet','SMTP_Password',password);
    props = java.lang.System.getProperties;
    props.setProperty('mail.smtp.auth','true');
    props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
    props.setProperty('mail.smtp.socketFactory.port','465');
    sendmail(receiver,'Fusion code is done running!');
    disp(['email confirmation sent to: ', receiver])
catch
    disp('email confirmation failed to send - check settings and permissions')
end

end

     
%% TURN DIARY OFF AND DISPLAY END TIME
disp('................................................................................')
disp('................................................................................')
disp(['.........Beacon_Exposure_Matching Run completed at ' datestr(now), '.........'])
disp('................................................................................')
disp('................................................................................')

    
if AA_Diary ==1
    diary off
end

%% CODE END - FINAL STOP



