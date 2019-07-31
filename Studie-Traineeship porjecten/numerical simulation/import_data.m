function[data] = import_data()
%% Import data from spreadsheet
% Script for importing data from the following spreadsheet:
%
%    Workbook: C:\Dropbox\Saxion\4e jaar\EPS finland Floating Solar Park\EPS Floating Solar Park\numerical simulation\SunEarthTools_AnnualSunPath_2018_1519894286943.xlsx
%    Worksheet: SunEarthTools_AnnualSunPath_201
%
% To extend the code for use with different selected data or a different
% spreadsheet, generate a function instead of a script.

% Auto-generated by MATLAB on 2018/03/01 12:02:56

%% Import the data, extracting spreadsheet dates in Excel serial date format
[~, ~, raw, dates] = xlsread('C:\Dropbox\Saxion\4e jaar\EPS finland Floating Solar Park\EPS Floating Solar Park\numerical simulation\SunEarthTools_AnnualSunPath_2018_1519894286943.xlsx','SunEarthTools_AnnualSunPath_201','A2:AW367','',@convertSpreadsheetExcelDates);
stringVectors = string(raw(:,[2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49]));
stringVectors(ismissing(stringVectors)) = '';
dates = dates(:,1);

%% Create table
SunEarthToolsAnnualSunPath20181519894286943 = table;

%% Allocate imported array to column variable names
SunEarthToolsAnnualSunPath20181519894286943.coo63095089_216164564 = datetime([dates{:,1}].', 'ConvertFrom', 'Excel');
SunEarthToolsAnnualSunPath20181519894286943.E000000 = categorical(stringVectors(:,1));
SunEarthToolsAnnualSunPath20181519894286943.A000000 = categorical(stringVectors(:,2));
SunEarthToolsAnnualSunPath20181519894286943.E010000 = categorical(stringVectors(:,3));
SunEarthToolsAnnualSunPath20181519894286943.rrrrrrrr = categorical(stringVectors(:,4));
SunEarthToolsAnnualSunPath20181519894286943.E020000 = categorical(stringVectors(:,5));
SunEarthToolsAnnualSunPath20181519894286943.A020000 = categorical(stringVectors(:,6));
SunEarthToolsAnnualSunPath20181519894286943.E030000 = categorical(stringVectors(:,7));
SunEarthToolsAnnualSunPath20181519894286943.A030000 = categorical(stringVectors(:,8));
SunEarthToolsAnnualSunPath20181519894286943.E040000 = categorical(stringVectors(:,9));
SunEarthToolsAnnualSunPath20181519894286943.A040000 = categorical(stringVectors(:,10));
SunEarthToolsAnnualSunPath20181519894286943.E050000 = categorical(stringVectors(:,11));
SunEarthToolsAnnualSunPath20181519894286943.A050000 = categorical(stringVectors(:,12));
SunEarthToolsAnnualSunPath20181519894286943.E060000 = categorical(stringVectors(:,13));
SunEarthToolsAnnualSunPath20181519894286943.A060000 = categorical(stringVectors(:,14));
SunEarthToolsAnnualSunPath20181519894286943.E070000 = categorical(stringVectors(:,15));
SunEarthToolsAnnualSunPath20181519894286943.A070000 = categorical(stringVectors(:,16));
SunEarthToolsAnnualSunPath20181519894286943.E080000 = categorical(stringVectors(:,17));
SunEarthToolsAnnualSunPath20181519894286943.A080000 = categorical(stringVectors(:,18));
SunEarthToolsAnnualSunPath20181519894286943.E090000 = categorical(stringVectors(:,19));
SunEarthToolsAnnualSunPath20181519894286943.A090000 = categorical(stringVectors(:,20));
SunEarthToolsAnnualSunPath20181519894286943.E100000 = stringVectors(:,21);
SunEarthToolsAnnualSunPath20181519894286943.A100000 = stringVectors(:,22);
SunEarthToolsAnnualSunPath20181519894286943.E110000 = stringVectors(:,23);
SunEarthToolsAnnualSunPath20181519894286943.A110000 = stringVectors(:,24);
SunEarthToolsAnnualSunPath20181519894286943.E120000 = stringVectors(:,25);
SunEarthToolsAnnualSunPath20181519894286943.A120000 = stringVectors(:,26);
SunEarthToolsAnnualSunPath20181519894286943.E130000 = stringVectors(:,27);
SunEarthToolsAnnualSunPath20181519894286943.A130000 = stringVectors(:,28);
SunEarthToolsAnnualSunPath20181519894286943.E140000 = stringVectors(:,29);
SunEarthToolsAnnualSunPath20181519894286943.A140000 = stringVectors(:,30);
SunEarthToolsAnnualSunPath20181519894286943.E150000 = categorical(stringVectors(:,31));
SunEarthToolsAnnualSunPath20181519894286943.A150000 = categorical(stringVectors(:,32));
SunEarthToolsAnnualSunPath20181519894286943.E160000 = categorical(stringVectors(:,33));
SunEarthToolsAnnualSunPath20181519894286943.A160000 = categorical(stringVectors(:,34));
SunEarthToolsAnnualSunPath20181519894286943.E170000 = categorical(stringVectors(:,35));
SunEarthToolsAnnualSunPath20181519894286943.A170000 = categorical(stringVectors(:,36));
SunEarthToolsAnnualSunPath20181519894286943.E180000 = categorical(stringVectors(:,37));
SunEarthToolsAnnualSunPath20181519894286943.A180000 = categorical(stringVectors(:,38));
SunEarthToolsAnnualSunPath20181519894286943.E190000 = categorical(stringVectors(:,39));
SunEarthToolsAnnualSunPath20181519894286943.A190000 = categorical(stringVectors(:,40));
SunEarthToolsAnnualSunPath20181519894286943.E200000 = categorical(stringVectors(:,41));
SunEarthToolsAnnualSunPath20181519894286943.A200000 = categorical(stringVectors(:,42));
SunEarthToolsAnnualSunPath20181519894286943.E210000 = categorical(stringVectors(:,43));
SunEarthToolsAnnualSunPath20181519894286943.A210000 = categorical(stringVectors(:,44));
SunEarthToolsAnnualSunPath20181519894286943.E220000 = categorical(stringVectors(:,45));
SunEarthToolsAnnualSunPath20181519894286943.A220000 = categorical(stringVectors(:,46));
SunEarthToolsAnnualSunPath20181519894286943.E230000 = categorical(stringVectors(:,47));
SunEarthToolsAnnualSunPath20181519894286943.A230000 = categorical(stringVectors(:,48));

% For code requiring serial dates (datenum) instead of datetime, uncomment
% the following line(s) below to return the imported dates as datenum(s).

% SunEarthToolsAnnualSunPath20181519894286943.coo63095089_216164564=datenum(SunEarthToolsAnnualSunPath20181519894286943.coo63095089_216164564);

%% Clear temporary variables
data = SunEarthToolsAnnualSunPath20181519894286943;
clearvars data raw dates stringVectors;