clc 
clear
close all

% Show figures on/off
set(0, 'DefaultFigureVisible', 'on'); 

% Load all data & add position and name
% FLAI 4-24/10
GNSS_data{1} = readtable('Data\FLAI_Height_2024278_298.dat'); 
GNSS_data{1}{:,17} = 'FLAI*';
GNSS_data{1}{:,18} = 27.449731;     % Latitude
GNSS_data{1}{:,19} = -82.690230;    % Longitude
% FLSN 4-24/10
GNSS_data{2} = readtable('Data\FLSN_Height_2024278_298.dat'); 
GNSS_data{2}{:,17} = 'FLSN';
GNSS_data{2}{:,18} = 27.333611;     % Latitude
GNSS_data{2}{:,19} = -82.438323;    % Longitude
% FLSC 4-24/10
GNSS_data{3} = readtable('Data\FLSC_Height_2024278_298.dat'); 
GNSS_data{3}{:,17} = 'FLSC';
GNSS_data{3}{:,18} = 27.217272;     % Latitude
GNSS_data{3}{:,19} = -82.404745;    % Longitude
% ORL1 4-24/10
GNSS_data{4} = readtable('Data\ORL1_Height_2024278_298.dat'); 
GNSS_data{4}{:,17} = 'ORL1';
GNSS_data{4}{:,18} = 28.434562;     % Latitude
GNSS_data{4}{:,19} = -81.382467;    % Longitude
% FLKS 4-24/10
GNSS_data{5} = readtable('Data\FLKS_Height_2024278_298.dat'); 
GNSS_data{5}{:,17} = 'FLKS';
GNSS_data{5}{:,18} = 28.295611;     % Latitude
GNSS_data{5}{:,19} = -81.436352;    % Longitude
% FLCC 4-24/10
GNSS_data{6} = readtable('Data\FLCC_Height_2024278_298.dat'); 
GNSS_data{6}{:,17} = 'FLCC';
GNSS_data{6}{:,18} = 28.094482;     % Latitude
GNSS_data{6}{:,19} = -81.274206;    % Longitude
% FLBN 4-24/10
GNSS_data{7} = readtable('Data\FLBN_Height_2024278_298.dat'); 
GNSS_data{7}{:,17} = 'FLBN*';
GNSS_data{7}{:,18} = 29.594142;     % Latitude
GNSS_data{7}{:,19} = -81.287096;    % Longitude
% ORMD 4-24/10
GNSS_data{8} = readtable('Data\ORMD_Height_2024278_298.dat'); 
GNSS_data{8}{:,17} = 'ORMD*';
GNSS_data{8}{:,18} = 29.298186;     % Latitude
GNSS_data{8}{:,19} = -81.108892;    % Longitude
% TTVL 4-24/10
GNSS_data{9} = readtable('Data\TTVL_Height_2024278_298.dat'); 
GNSS_data{9}{:,17} = 'TTVL';
GNSS_data{9}{:,18} = 28.505709;     % Latitude
GNSS_data{9}{:,19} = -80.803381;    % Longitude

% Tide Level StPetersburg 4-24/10
Tide_Level{1} = readtable('Data\Milton_Water_Level_StPetersburg.dat'); 
% Tide Level Clearwater Beach 4-24/10
Tide_Level{2} = readtable('Data\Milton_Water_Level_Clearwater.dat'); 
% Tide Level Port Manatee 4-24/10
Tide_Level{3} = readtable('Data\Milton_Water_Level_Port_Manatee.dat'); 

% For MJD time
start_date = datetime(1858, 11, 17);

% Initialize for faster compile
numTables = length(GNSS_data);
numTables2 = length(Tide_Level);
xData_date = cell(1, numTables);

yData_Height = cell(1, numTables);
mean_move = cell(1, numTables);

wt = cell(1, numTables);
time = cell(1, numTables);
anomaly_mask = cell(1, numTables);

yData_around_median = cell(1, numTables2);
timeVector = cell(1, numTables2);

% Sampling frequency (Hz), since 30s sampling
fs = 1/30; 

% Extract data
for i = 1:numTables
    % Get date from MJD
    xData_date{i} = datetime(start_date + days(GNSS_data{i}{:,1}), 'InputFormat', 'dd-MMM-yyyy');
    
    % Sets the data around the median of each dataset
    yData_Height{i} = GNSS_data{i}{:,8} - median(GNSS_data{i}{:,8});  
    
    % Set all date columns into one (for x-axis plot)
    time{i} = xData_date{i} + seconds(GNSS_data{i}{:,2});
    
    % Makes a mean value from the closest 60 values, 30 before and 29 after
    mean_move{i} = movmean(yData_Height{i}, 60);
    
    % Wavelet-transform with Morlet ('amor')
    [wt{i}, f] = cwt(GNSS_data{i}{:,8}, 'amor', fs); 
    
    % Threshold based median
    threshold = 4.5 * median(abs(wt{i}(:))); 
    anomaly_mask{i} = abs(wt{i}) > threshold;
end



% Loop over all stations and plot
for i = 1:length(yData_Height)
    figure;
    set(gcf, 'Units', 'centimeters', 'Position', [15, 8, 16, 14])
    hold on;

    % Plot time series
    subplot(3,1,1)
    axis xy;
    plot(time{i}, yData_Height{i})
    xlabel('Date');
    ylabel('Height (m)');
    title(['Height around median for station ' GNSS_data{i}{1,17}]);
    xlim([time{i}(1), time{i}(length(time{i}))]);
    xline(datetime(2024,10,09,13,00,00), '--red', 'LineWidth', 2);
    xline(datetime(2024,10,10,13,10,00), '--red', 'LineWidth', 2);
    xline(datetime(2024,10,05,15,00,00), '-.black', 'LineWidth', 2);
    xline(datetime(2024,10,10,21,00,00), '-.black', 'LineWidth', 2);

    % Plot scalogram
    subplot(3,1,2)
    imagesc(time{i}, f, abs(wt{i})); 
    axis xy;
    xlabel('Date');
    ylabel('Frequency (Hz)');
    title(['Wavelet Scalogram for station ' GNSS_data{i}{1,17}]);
    xline(datetime(2024,10,09,13,00,00), '--red', 'LineWidth', 2);
    xline(datetime(2024,10,10,13,10,00), '--red', 'LineWidth', 2);
    xline(datetime(2024,10,05,15,00,00), '-.black', 'LineWidth', 2);
    xline(datetime(2024,10,10,21,00,00), '-.black', 'LineWidth', 2);

    % Plot anomalies in wavelet
    subplot(3,1,3)
    imagesc(time{i}, f, anomaly_mask{i}); 
    axis xy;
    xlabel('Date');
    ylabel('Frequency (Hz)');
    title(['Anomaly detection in Height for station ' GNSS_data{i}{1,17}]);
    xline(datetime(2024,10,09,13,00,00), '--red', 'LineWidth', 2);
    xline(datetime(2024,10,10,13,10,00), '--red', 'LineWidth', 2);
    xline(datetime(2024,10,05,15,00,00), '-.black', 'LineWidth', 2);
    xline(datetime(2024,10,10,21,00,00), '-.black', 'LineWidth', 2);

    hold off;
end


% Plot of the CWT
figure;
set(gcf, 'Units', 'centimeters', 'Position', [15, 8, 16, 10])
hold on;
imagesc(time{2}, f, abs(wt{2})); 
axis xy;
xlabel('Date');
ylabel('Frequency (Hz)');
title(['Wavelet Scalogram for station ' GNSS_data{2}{1,17}]);
xlim([time{2}(1), time{2}(length(time{2}))]);
ylim([0, 12*10^-3]);
xline(datetime(2024,10,09,13,00,00), '--red', 'LineWidth', 2);
xline(datetime(2024,10,10,13,10,00), '--red', 'LineWidth', 2);
xline(datetime(2024,10,05,15,00,00), '-.black', 'LineWidth', 2);
xline(datetime(2024,10,10,21,00,00), '-.black', 'LineWidth', 2);
hold off;

% Plot of threshold of the cwt
figure;
set(gcf, 'Units', 'centimeters', 'Position', [15, 8, 16, 10])
hold on;
imagesc(time{2}, f, anomaly_mask{2}); 
axis xy;
xlabel('Date');
ylabel('Frequency (Hz)');
title(['Anomaly detection in Height for station ' GNSS_data{2}{1,17}]);
xlim([time{2}(1), time{2}(length(time{2}))]);
ylim([0, 12*10^-3]);
xline(datetime(2024,10,09,13,00,00), '--red', 'LineWidth', 2);
xline(datetime(2024,10,10,13,10,00), '--red', 'LineWidth', 2);
xline(datetime(2024,10,05,15,00,00), '-.black', 'LineWidth', 2);
xline(datetime(2024,10,10,21,00,00), '-.black', 'LineWidth', 2);
hold off;

% Plot the initial test of land subsidence
figure;
set(gcf, 'Units', 'centimeters', 'Position', [15, 8, 16, 10])
hold on
xlabel('Date')
ylabel('Height (m)')
title('Height around median for station FLSN')

plot(time{2},yData_Height{2})
xline(datetime(2024,10,09,13,00,00), '--red', 'LineWidth', 2);
xline(datetime(2024,10,10,13,10,00), '--red', 'LineWidth', 2);
xline(datetime(2024,10,05,15,00,00), '-.black', 'LineWidth', 2);
xline(datetime(2024,10,10,21,00,00), '-.black', 'LineWidth', 2);
hold off

% Tide Level
for i = 1:numTables2
    opts = detectImportOptions('Data\Milton_Water_Level_StPetersburg.dat', 'Delimiter', ',');
    opts.SelectedVariableNames = opts.VariableNames(1:2); 
    data = readtable('Data\Milton_Water_Level_StPetersburg.dat', opts);
    dateStrings = strcat(data.Var1, {' '}, data.Var2);
    timeVector{i} = datetime(dateStrings, 'InputFormat', 'yyyy/MM/dd HH:mm');
    yData = table2array(Tide_Level{i}(:,5));
    yData_around_median{i} = yData - median(yData);
     
end

% Plot the Tide Level
figure;
set(gcf, 'Units', 'centimeters', 'Position', [15, 8, 16, 11])
hold on

subplot(2,1,1)
plot(timeVector{2}, yData_around_median{2})
xlabel('Date')
ylabel('Height (m)')
title('Water Level around median for Clearwater')
xline(datetime(2024,10,09,13,00,00), '--red', 'LineWidth', 1);
xline(datetime(2024,10,10,13,10,00), '--red', 'LineWidth', 1);
xline(datetime(2024,10,05,15,00,00), '-.black', 'LineWidth', 2);
xline(datetime(2024,10,10,21,00,00), '-.black', 'LineWidth', 2);

subplot(2,1,2)
plot(time{2}, yData_Height{2})
xlabel('Date')
ylabel('Height (m)')
title('Height around median for FLSN')
xline(datetime(2024,10,09,13,00,00), '--red', 'LineWidth', 1);
xline(datetime(2024,10,10,13,10,00), '--red', 'LineWidth', 1);
xline(datetime(2024,10,05,15,00,00), '-.black', 'LineWidth', 2);
xline(datetime(2024,10,10,21,00,00), '-.black', 'LineWidth', 2);

hold off;

% -- Plots of initial observations (all 3 regions and one complete) --

% Plot the weastern height around median
figure;
hold on
xlabel('Date')
ylabel('Height around median (m)')
title('Land Subsidence, Milton, Western Florida')

plot(time{1},yData_Height{1})
plot(time{2},yData_Height{2})
plot(time{3},yData_Height{3})
legend('FLAI','FLSN','FLSC')
hold off

% Plot the central height around median
figure;
hold on
xlabel('Date')
ylabel('Height around median (m)')
title('Land Subsidence, Milton, Central Florida')

plot(time{4},yData_Height{4})
plot(time{5},yData_Height{5})
plot(time{6},yData_Height{6})
legend('ORL1', 'FLKS', 'FLCC')
hold off

% Plot the eastern height around median
figure;
hold on
xlabel('Date')
ylabel('Height around median (m)')
title('Land Subsidence, Milton, Eastern Florida')

plot(time{7},yData_Height{7})
plot(time{8},yData_Height{8})
plot(time{9},yData_Height{9})
legend('FLBN', 'ORMD', 'TTVL')
hold off

% Plot for all stations
figure;
hold on
xlabel('Date')
ylabel('Height around median (m)')
title('Land Subsidence, Milton, Florida')

plot(time{1},yData_Height{1}, 'red')
plot(time{2},yData_Height{2}, 'red')
plot(time{3},yData_Height{3}, 'red')
plot(time{4},yData_Height{4}, 'blue')
plot(time{5},yData_Height{5}, 'blue')
plot(time{6},yData_Height{6}, 'blue')
plot(time{7},yData_Height{7}, 'black')
plot(time{8},yData_Height{8}, 'black')
plot(time{9},yData_Height{9}, 'black')
legend('FLAI', 'FLSN', 'FLSC', 'ORL1', 'FLKS', 'FLCC', 'FLBN', 'ORMD', 'TTVL')
hold off


