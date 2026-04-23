clc 
clear
close all

% Show figures on/off
set(0, 'DefaultFigureVisible', 'on'); 

% Load all data & add position and name
% -- Segment 1 --
% FLPY 19/9-1/10
GNSS_data{1} = readtable('Data\FLPY_Height_2024263_275.dat'); 
GNSS_data{1}{:,17} = 'FLPY';
GNSS_data{1}{:,18} = 30.094282;     % Latitude
GNSS_data{1}{:,19} = -83.572900;    % Longitude
% FLMD 19/9-1/10
GNSS_data{2} = readtable('Data\FLMD_Height_2024263_275.dat'); 
GNSS_data{2}{:,17} = 'FLMD';
GNSS_data{2}{:,18} = 30.374022;     % Latitude
GNSS_data{2}{:,19} = -83.275478;    % Longitude
% FL75 19/9-1/10
GNSS_data{3} = readtable('Data\FL75_Height_2024263_275.dat'); 
GNSS_data{3}{:,17} = 'FL75*';
GNSS_data{3}{:,18} = 30.612525;     % Latitude
GNSS_data{3}{:,19} = -83.146681;    % Longitude

% -- Segment 2 --
% FLCB 19/9-1/10
GNSS_data{4} = readtable('Data\FLCB_Height_2024263_275.dat'); 
GNSS_data{4}{:,17} = 'FLCB';
GNSS_data{4}{:,18} = 29.842600;     % Latitude
GNSS_data{4}{:,19} = -84.695148;    % Longitude
% TALH 19/9-1/10
GNSS_data{5} = readtable('Data\TALH_Height_2024263_275.dat'); 
GNSS_data{5}{:,17} = 'TALH';
GNSS_data{5}{:,18} = 30.396523;     % Latitude
GNSS_data{5}{:,19} = -84.355843;    % Longitude
% FLJL 19/9-1/10
GNSS_data{6} = readtable('Data\FLJL_Height_2024263_275.dat'); 
GNSS_data{6}{:,17} = 'FLJL';
GNSS_data{6}{:,18} = 30.579702;     % Latitude
GNSS_data{6}{:,19} = -84.266277;    % Longitude
% GATE 19/9-1/10
GNSS_data{7} = readtable('Data\GATE_Height_2024263_275.dat'); 
GNSS_data{7}{:,17} = 'GATE';
GNSS_data{7}{:,18} = 30.833576;     % Latitude
GNSS_data{7}{:,19} = -83.982649;    % Longitude
% GAME 19/9-1/10
GNSS_data{8} = readtable('Data\GAME_Height_2024263_275.dat'); 
GNSS_data{8}{:,17} = 'GAME';
GNSS_data{8}{:,18} = 31.182252;     % Latitude
GNSS_data{8}{:,19} = -83.786949;    % Longitude

% Tide Level 19/9-1/10
Tide_Level{1} = readtable('Data\Helene_Water_Level_Apalachicola.dat'); 

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

timeVector = cell(1, numTables2);
yData_around_median = cell(1, numTables2);

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
    [wt{i}, f] = cwt(yData_Height{i}, 'amor', fs); 

    % Threshold based median
    threshold = 3 * median(abs(wt{i}(:))); 
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
    xline(datetime(2024,09,27,00,00,00), '--red', 'LineWidth', 2);
    xline(datetime(2024,09,27,06,00,00), '--red', 'LineWidth', 2);
    xline(datetime(2024,09,24,15,00,00), '-.black', 'LineWidth', 2);
    xline(datetime(2024,09,27,21,00,00), '-.black', 'LineWidth', 2);

    % Plot scalogram
    subplot(3,1,2)
    imagesc(time{i}, f, abs(wt{i})); 
    axis xy;
    xlabel('Date');
    ylabel('Frequency (Hz)');
    title(['Wavelet Scalogram for station ' GNSS_data{i}{1,17}]);
    xline(datetime(2024,09,27,00,00,00), '--red', 'LineWidth', 2);
    xline(datetime(2024,09,27,06,00,00), '--red', 'LineWidth', 2);
    xline(datetime(2024,09,24,15,00,00), '-.black', 'LineWidth', 2);
    xline(datetime(2024,09,27,21,00,00), '-.black', 'LineWidth', 2);

    % Plot anomalies in wavelet
    subplot(3,1,3)
    imagesc(time{i}, f, anomaly_mask{i}); 
    axis xy;
    xlabel('Date');
    ylabel('Frequency (Hz)');
    title(['Anomaly detection in Height for station ' GNSS_data{i}{1,17}]);
    xline(datetime(2024,09,27,00,00,00), '--red', 'LineWidth', 2);
    xline(datetime(2024,09,27,06,00,00), '--red', 'LineWidth', 2);
    xline(datetime(2024,09,24,15,00,00), '-.black', 'LineWidth', 2);
    xline(datetime(2024,09,27,21,00,00), '-.black', 'LineWidth', 2);
    
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
xline(datetime(2024,09,27,00,00,00), '--red', 'LineWidth', 2);
xline(datetime(2024,09,27,06,00,00), '--red', 'LineWidth', 2);
xline(datetime(2024,09,24,15,00,00), '-.black', 'LineWidth', 2);
xline(datetime(2024,09,27,21,00,00), '-.black', 'LineWidth', 2);
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
xline(datetime(2024,09,27,00,00,00), '--red', 'LineWidth', 2);
xline(datetime(2024,09,27,06,00,00), '--red', 'LineWidth', 2);
xline(datetime(2024,09,24,15,00,00), '-.black', 'LineWidth', 2);
xline(datetime(2024,09,27,21,00,00), '-.black', 'LineWidth', 2);
hold off;

% Plot the initial test of land subsidence
figure;
set(gcf, 'Units', 'centimeters', 'Position', [15, 8, 16, 10])
hold on
xlabel('Date')
ylabel('Height (m)')
title(['Height around median for station ' GNSS_data{2}{1,17}]);

plot(time{2},yData_Height{2})
xline(datetime(2024,09,27,00,00,00), '--red', 'LineWidth', 2);
xline(datetime(2024,09,27,06,00,00), '--red', 'LineWidth', 2);
xline(datetime(2024,09,24,15,00,00), '-.black', 'LineWidth', 2);
xline(datetime(2024,09,27,21,00,00), '-.black', 'LineWidth', 2);
hold off

% Tide Level
for i = 1:numTables2
    opts = detectImportOptions('Data\Helene_Water_Level_Apalachicola.dat', 'Delimiter', ',');
    opts.SelectedVariableNames = opts.VariableNames(1:2); 
    data = readtable('Data\Helene_Water_Level_Apalachicola.dat', opts);
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
plot(timeVector{1}, yData_around_median{1} / 2)
xlabel('Date')
ylabel('Height (m)')
title('Water Level around median for Apalachicola')
xline(datetime(2024,09,27,00,00,00), '--red', 'LineWidth', 1);
xline(datetime(2024,09,27,06,00,00), '--red', 'LineWidth', 1);
xline(datetime(2024,09,24,15,00,00), '-.black', 'LineWidth', 2);
xline(datetime(2024,09,27,21,00,00), '-.black', 'LineWidth', 2);

subplot(2,1,2)
plot(time{4}, yData_Height{4})
xlabel('Date')
ylabel('Height (m)')
title('Height around median for FLCB')
xline(datetime(2024,09,27,00,00,00), '--red', 'LineWidth', 1);
xline(datetime(2024,09,27,06,00,00), '--red', 'LineWidth', 1);
xline(datetime(2024,09,24,15,00,00), '-.black', 'LineWidth', 2);
xline(datetime(2024,09,27,21,00,00), '-.black', 'LineWidth', 2);

hold off

