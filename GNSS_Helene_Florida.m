clc 
clear
close all

% Show figures on/off
set(0, 'DefaultFigureVisible', 'on'); 

% Load all data & add position and name
% -- Segment 1 --
% FLPY 19/9-1/10
GNSS_data{1} = readtable('Data\FLPY_2024263_275.dat'); 
GNSS_data{1}{:,10} = 'FLPY';
GNSS_data{1}{:,11} = 30.094282;     % Latitude
GNSS_data{1}{:,12} = -83.572900;    % Longitude
% FLMD 19/9-1/10
GNSS_data{2} = readtable('Data\FLMD_2024263_275.dat'); 
GNSS_data{2}{:,10} = 'FLMD';
GNSS_data{2}{:,11} = 30.374022;     % Latitude
GNSS_data{2}{:,12} = -83.275478;    % Longitude
% FL75 19/9-1/10
GNSS_data{3} = readtable('Data\FL75_2024263_275.dat'); 
GNSS_data{3}{:,10} = 'FL75*';
GNSS_data{3}{:,11} = 30.612525;     % Latitude
GNSS_data{3}{:,12} = -83.146681;    % Longitude

% -- Segment 2 --
% FLCB 19/9-1/10
GNSS_data{4} = readtable('Data\FLCB_2024263_275.dat'); 
GNSS_data{4}{:,10} = 'FLCB';
GNSS_data{4}{:,11} = 29.842600;     % Latitude
GNSS_data{4}{:,12} = -84.695148;    % Longitude
% TALH 19/9-1/10
GNSS_data{5} = readtable('Data\TALH_2024263_275.dat'); 
GNSS_data{5}{:,10} = 'TALH';
GNSS_data{5}{:,11} = 30.396523;     % Latitude
GNSS_data{5}{:,12} = -84.355843;    % Longitude
% FLJL 19/9-1/10
GNSS_data{6} = readtable('Data\FLJL_2024263_275.dat'); 
GNSS_data{6}{:,10} = 'FLJL';
GNSS_data{6}{:,11} = 30.579702;     % Latitude
GNSS_data{6}{:,12} = -84.266277;    % Longitude
% GATE 19/9-1/10
GNSS_data{7} = readtable('Data\GATE_2024263_275.dat'); 
GNSS_data{7}{:,10} = 'GATE';
GNSS_data{7}{:,11} = 30.833576;     % Latitude
GNSS_data{7}{:,12} = -83.982649;    % Longitude
% GAME 19/9-1/10
GNSS_data{8} = readtable('Data\GAME_2024263_275.dat'); 
GNSS_data{8}{:,10} = 'GAME';
GNSS_data{8}{:,11} = 31.182252;     % Latitude
GNSS_data{8}{:,12} = -83.786949;    % Longitude


% Initialize for faster compile
numTables = length(GNSS_data);
yData_ZWD_tot = cell(1, numTables);

mean_move = cell(1, numTables);

wt = cell(1, numTables);
time = cell(1, numTables);
anomaly_mask = cell(1, numTables);

lags = cell(numTables-1, numTables-1);
c = cell(numTables-1, numTables-1);
lagDiff_all = cell(numTables-1, numTables-1);
distance_stations_all = cell(numTables-1, numTables-1);

speed_kmh_all = cell(numTables-1, numTables-1);
speed_ms_all = cell(numTables-1, numTables-1);

% Sampling frequency (Hz), since 30s sampling
fs = 1/30; 

% Extract data
for i = 1:numTables
    % ZWD total is the ini + cor
    yData_ZWD_tot{i} = GNSS_data{i}{:,8} + GNSS_data{i}{:,9};

    % Set all date columns into one (for x-axis plot)
    time{i} = datetime(GNSS_data{i}{:,1}, GNSS_data{i}{:,2}, GNSS_data{i}{:,3}, GNSS_data{i}{:,4}, GNSS_data{i}{:,5}, GNSS_data{i}{:,6});
    
    % Makes a mean value from the closest 60 values, 30 before and 29 after
    mean_move{i} = movmean(yData_ZWD_tot{i}, 60);

    % Wavelet-transform with Morlet ('amor')
    [wt{i}, f] = cwt(mean_move{i}, 'amor', fs);

    % Threshold based median, where median is decided under "good" weather
    threshold = 12 * median(abs(wt{i}(:)));

    % Only saves the data above threshold
    anomaly_mask{i} = abs(wt{i}) > threshold;
end

% Calculate the time delay & print to console
% The numTables-1 comes from that the last one is the one used for STO test
for i = 1:numTables
    % Loop to only cover each station pair once
    for j = i+1:numTables
        % Detrend (which removes the best straight-fit line)
        [c{i, j}, lags{i, j}] = xcorr(detrend(mean_move{i}), detrend(mean_move{j}));
        [~, maxIndex] = max(c{i, j});
        lagDiff = lags{i, j}(maxIndex);
        lagDiff_all{i, j} = lagDiff;
        disp(['Time Delay between stations ', GNSS_data{i}{1,10}, ' and ', GNSS_data{j}{1,10}, ' : ', num2str(lagDiff/2), ' minutes']);
    
        % Distance between stations
        [dist, az] = distance(GNSS_data{i}{1,11}, GNSS_data{i}{1,12}, GNSS_data{j}{1,11}, GNSS_data{j}{1,12});
        distance_stations = deg2km(dist, 'earth');
        distance_stations_all{i ,j} = distance_stations;
        disp(['Distance between stations ', GNSS_data{i}{1,10}, ' and ', GNSS_data{j}{1,10}, ' : ', num2str(distance_stations), ' km']);
    
        % Speed 
        speed_kmh_all{i, j} = distance_stations / (lagDiff / 120);
        speed_ms_all{i, j} = (distance_stations * 1000) / (lagDiff * 30);
        disp(['Speed between stations ', GNSS_data{i}{1,10}, ' and ', GNSS_data{j}{1,10}, ' : ', num2str(speed_ms_all{i, j}), ' m/s or ', num2str(speed_kmh_all{i, j}), ' km/h']);
    
        disp(' ');
    end
end


% Loop over all stations and plot CWT, threshold and org. data
for i = 1:length(mean_move)
    figure;
    set(gcf, 'Units', 'centimeters', 'Position', [15, 8, 16, 14])
    hold on;

    % Plot time series mean
    subplot(3,1,1)
    axis xy;
    plot(time{i}, mean_move{i})
    xlabel('Date');
    ylabel('Mean 30min ZWD (m)');
    title(['Mean ZWD for station ' GNSS_data{i}{1,10}]);
    xlim([time{i}(1), time{i}(length(time{i}))]);
    xline(datetime(2024,09,27,00,00,00), '--red', 'LineWidth', 2);
    xline(datetime(2024,09,27,07,00,00), '--red', 'LineWidth', 2);
    xline(datetime(2024,09,24,15,00,00), '-.black', 'LineWidth', 2);
    xline(datetime(2024,09,27,21,00,00), '-.black', 'LineWidth', 2);


    % Plot scalogram
    subplot(3,1,2)
    imagesc(time{i}, f, abs(wt{i})); 
    axis xy;
    xlabel('Date');
    ylabel('Frequency (Hz)');
    title(['Wavelet Scalogram for station ' GNSS_data{i}{1,10}]);
    xline(datetime(2024,09,27,00,00,00), '--red', 'LineWidth', 2);
    xline(datetime(2024,09,27,07,00,00), '--red', 'LineWidth', 2);
    xline(datetime(2024,09,24,15,00,00), '-.black', 'LineWidth', 2);
    xline(datetime(2024,09,27,21,00,00), '-.black', 'LineWidth', 2);



    % Plot anomalies in wavelet
    subplot(3,1,3)
    imagesc(time{i}, f, anomaly_mask{i}); 
    axis xy;
    xlabel('Date');
    ylabel('Frequency (Hz)');
    title(['Anomaly detection in ZWD for station ' GNSS_data{i}{1,10}]);
    xline(datetime(2024,09,27,00,00,00), '--red', 'LineWidth', 2);
    xline(datetime(2024,09,27,07,00,00), '--red', 'LineWidth', 2);
    xline(datetime(2024,09,24,15,00,00), '-.black', 'LineWidth', 2);
    xline(datetime(2024,09,27,21,00,00), '-.black', 'LineWidth', 2);

    hold off;
end

% Plot for first segment
figure;
hold on
xlabel('Date')
ylabel('ZWD (m)')
title('ZWD Helene, Florida')

plot(time{1},mean_move{1}, 'Color', '#EDB120')
plot(time{2},mean_move{2}, 'Color', '#D95319')
plot(time{3},mean_move{3}, 'Color', '#4DBEEE')
xline(datetime(2024,09,27,00,00,00), '--red', 'LineWidth', 2);
xline(datetime(2024,09,27,07,00,00), '--red', 'LineWidth', 2);
xline(datetime(2024,09,24,15,00,00), '-.black', 'LineWidth', 2);
xline(datetime(2024,09,27,21,00,00), '-.black', 'LineWidth', 2);
legend('FLPY', 'FLMD', 'FL75')
hold off

% Plot for second segment
figure;
hold on
xlabel('Date')
ylabel('ZWD (m)')
title('ZWD Helene, Florida')

plot(time{4},mean_move{4})
plot(time{5},mean_move{5})
plot(time{6},mean_move{6})
plot(time{7},mean_move{7})
plot(time{8},mean_move{8})
xline(datetime(2024,09,27,00,00,00), '--red', 'LineWidth', 2);
xline(datetime(2024,09,27,07,00,00), '--red', 'LineWidth', 2);
xline(datetime(2024,09,24,15,00,00), '-.black', 'LineWidth', 2);
xline(datetime(2024,09,27,21,00,00), '-.black', 'LineWidth', 2);
legend(GNSS_data{4}{1,10}, GNSS_data{5}{1,10}, GNSS_data{6}{1,10}, GNSS_data{7}{1,10}, GNSS_data{8}{1,10})
hold off

% Plot the initial test of ZWD (not mean)
figure;
hold on
xlabel('Date')
ylabel('ZWD (m)')
title('ZWD for station FLMD')

plot(time{2},yData_ZWD_tot{2})
xline(datetime(2024,09,27,00,00,00), '--red', 'LineWidth', 2);
xline(datetime(2024,09,27,07,00,00), '--red', 'LineWidth', 2);
xline(datetime(2024,09,24,15,00,00), '-.black', 'LineWidth', 2);
xline(datetime(2024,09,27,21,00,00), '-.black', 'LineWidth', 2);
hold off

% Plot the initial test of ZWD & Mean
figure;
hold on
xlabel('Date')
ylabel('ZWD (m)')
title('ZWD for station FLMD')

plot(time{2},yData_ZWD_tot{2})
plot(time{2},mean_move{2})
xline(datetime(2024,09,27,00,00,00), '--red', 'LineWidth', 2);
xline(datetime(2024,09,27,07,00,00), '--red', 'LineWidth', 2);
xline(datetime(2024,09,24,15,00,00), '-.black', 'LineWidth', 2);
xline(datetime(2024,09,27,21,00,00), '-.black', 'LineWidth', 2);
legend('Original Data', '30min Mean Data')
hold off

% Plot the CWT and Threshold
figure;
hold on;

subplot(2,1,1)
imagesc(time{2}, f, abs(wt{2})); % Amplitude of wavelet
axis xy;
xlabel('Date');
ylabel('Frequency (Hz)');
title(['Wavelet Scalogram for station ' GNSS_data{2}{1,10}]);
xlim([time{2}(1), time{2}(length(time{2}))]);
xline(datetime(2024,09,27,00,00,00), '--red', 'LineWidth', 2);
xline(datetime(2024,09,27,07,00,00), '--red', 'LineWidth', 2);
xline(datetime(2024,09,24,15,00,00), '-.black', 'LineWidth', 2);
xline(datetime(2024,09,27,21,00,00), '-.black', 'LineWidth', 2);

subplot(2,1,2)
imagesc(time{2}, f, anomaly_mask{2});
axis xy;
xlabel('Date');
ylabel('Frequency (Hz)');
title(['Anomaly detection in ZWD for station ' GNSS_data{2}{1,10}]);
xline(datetime(2024,09,27,00,00,00), '--red', 'LineWidth', 2);
xline(datetime(2024,09,27,07,00,00), '--red', 'LineWidth', 2);
xline(datetime(2024,09,24,15,00,00), '-.black', 'LineWidth', 2);
xline(datetime(2024,09,27,21,00,00), '-.black', 'LineWidth', 2);
hold off;

