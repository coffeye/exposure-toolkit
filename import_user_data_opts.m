%% Import data from spreadsheet
% Script for importing data from the following spreadsheet:
%
%    Workbook: F:\Google Drive\P3 Data Analysis\NIH Beacons\Matlab Analysis Code\Functions\User_data.xlsx
%    Worksheet: Unique_sample_list
%
% Auto-generated by MATLAB on 12-Nov-2019 09:48:31

%% Setup the Import Options
opts = spreadsheetImportOptions("NumVariables", 14);

% Specify sheet and range
opts.Sheet = "Unique_sample_list";
opts.DataRange = "A2:N304";

% Specify column names and types
opts.VariableNames = ["deployment_namePersonalID_beaconconstants_datedeploymentstarted", "CurrenttempID", "IsthisaduplicatesampleakacontainsPM", "deployment_num", "Female_0", "PrimaryCook_1", "Age_years", "Lessthan30_0", "IndividID", "DOB", "Tempage", "Tempage1", "Tempage2", "Tempage3"];
opts.VariableTypes = ["string", "string", "double", "double", "double", "double", "double", "double", "string", "datetime", "double", "string", "string", "datetime"];
opts = setvaropts(opts, [1, 2, 9, 12, 13], "WhitespaceRule", "preserve");
opts = setvaropts(opts, [1, 2, 9, 12, 13], "EmptyFieldRule", "auto");

