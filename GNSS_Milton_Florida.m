clc 
clear
close all

% Show figures on/off
set(0, 'DefaultFigureVisible', 'on'); 

% Load all data & add position and name
% FLAI 4-24/10
GNSS_data{1} = readtable('Data\FLAI_2024278_298.dat');  
GNSS_data{1}{:,10} = 'FLAI*';
GNSS_data{1}{:,11} = 27.449731;     % Latitude
GNSS_data{1}{:,12} = -82.690230;    % Longitude   
% FLSN 4-24/10
GNSS_data{2} = readtable('Data\FLSN_2024278_298.dat');  
GNSS_data{2}{:,10} = 'FLSN';
GNSS_data{2}{:,11} = 27.333611;     % Latitude                  
GNSS_data{2}{:,12} = -82.438323;    % Longitude      
% FLSC 4-24/10
GNSS_data{3} = readtable('Data\FLSC_2024278_298.dat');  
GNSS_data{3}{:,10} = 'FLSC';
GNSS_data{3}{:,11} = 27.217272;     % Latitude                  
GNSS_data{3}{:,12} = -82.404745;    % Longitude      
% ORL1 4-24/10
GNSS_data{4} = readtable('Data\ORL1_2024278_298.dat');  
GNSS_data{4}{:,10} = 'ORL1';
GNSS_data{4}{:,11} = 28.434562;    % Latitude                   
GNSS_data{4}{:,12} = -81.382467;   % Longitude    
% FLKS 4-24/10
GNSS_data{5} = readtable('Data\FLKS_2024278_298.dat');  
GNSS_data{5}{:,10} = 'FLKS';
GNSS_data{5}{:,11} = 28.295611;    % Latitude                   
GNSS_data{5}{:,12} = -81.436352;   % Longitude         
% FLCC 4-24/10
GNSS_data{6} = readtable('Data\FLCC_2024278_298.dat');  
GNSS_data{6}{:,10} = 'FLCC';
GNSS_data{6}{:,11} = 28.094482;    % Latitude                   
GNSS_data{6}{:,12} = -81.274206;   % Longitude               
% FLBN 4-24/10
GNSS_data{7} = readtable('Data\FLBN_2024278_298.dat');  
GNSS_data{7}{:,10} = 'FLBN*';
GNSS_data{7}{:,11} = 29.594142;    % Latitude                   
GNSS_data{7}{:,12} = -81.287096;   % Longitude              
% ORMD 4-24/10
GNSS_data{8} = readtable('Data\ORMD_2024278_298.dat');  
GNSS_data{8}{:,10} = 'ORMD*';
GNSS_data{8}{:,11} = 29.298186;    % Latitude                   
GNSS_data{8}{:,12} = -81.108892;   % Longitude     
% TTVL 4-24/10
GNSS_data{9} = readtable('Data\TTVL_2024278_298.dat');  
GNSS_data{9}{:,10} = 'TTVL';
GNSS_data{9}{:,11} = 28.505709;    % Latitude                   
GNSS_data{9}{:,12} = -80.803381;   % Longitude                   

% FLSN STO 4-24/10
GNSS_data{10} = readtable('Data\FLSN_STO_2024278_298.dat'); 
GNSS_data{10}{:,10} = 'FLSN (STO)';

% FLSN HTC 4-24/10
GNSS_data_htc{1} = readtable('Data\FLSN_HTC_2024278_298.dat'); 


% Initialize for faster compile
numTables = length(GNSS_data);
yData_ZWD_tot = cell(1, numTables);

numTables_htc = length(GNSS_data_htc);

mean_move = cell(1, numTables);

wt = cell(1, numTables);
time = cell(1, numTables);
anomaly_mask = cell(1, numTables);

yData_htc_E_W = cell(1, numTables_htc);
yData_htc_N_S = cell(1, numTables_htc);
yData_htc_tot = cell(1, numTables_htc);
time_htc = cell(1, numTables_htc);

filtered1 = cell(numTables-1, numTables-1);
filtered2 = cell(numTables-1, numTables-1);

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

% Extract the data for HTC
for j = 1:numTables_htc
    % HTC E-W is the HTGS-ini + cor
    yData_htc_E_W{j} = GNSS_data_htc{j}{:,15} + GNSS_data_htc{j}{:,16};

    % HTC N-S is the HTGC-ini + cor
    yData_htc_N_S{j} = GNSS_data_htc{j}{:,13} + GNSS_data_htc{j}{:,14};
    
    % HTC squared tot. 
    yData_htc_tot{j} = sqrt(yData_htc_E_W{j}.^2 + yData_htc_N_S{j}.^2);

    % Set all date columns into one (for x-axis plot)
    time_htc{j} = datetime(GNSS_data_htc{j}{:,1}, GNSS_data_htc{j}{:,2}, GNSS_data_htc{j}{:,3}, GNSS_data_htc{j}{:,4}, GNSS_data_htc{j}{:,5}, GNSS_data_htc{j}{:,6});
end

% Calculate the mean difference between PWC and STO (%)
diff_sto_perc = abs((mean_move{10} - mean_move{2}) ./ mean_move{2}) * 100;
mean_diff_sto_perc = mean(diff_sto_perc);
mean_diff_max_sto_perc =  max(diff_sto_perc);

diff = abs((mean_move{10}) - (mean_move{2}));
diff_mean = mean(diff);
diff_max = max(diff);

% Calculate student t for 99 % conf.interval

% Standard Error
SEM = std(mean_move{10})/sqrt(length(mean_move{10})); 
% T-Score
ts = tinv([0.005  0.995],length(mean_move{10})-1);    
% Confidence Intervals
CI = mean(mean_move{10}) + ts*SEM;                      
  
% Standard Error
SEM2 = std(mean_move{2})/sqrt(length(mean_move{2})); 
% T-Score
ts2 = tinv([0.005  0.995],length(mean_move{2})-1);   
% Confidence Intervals
CI2 = mean(mean_move{2}) + ts2*SEM2;                      

CI_strength = abs(diff_mean / abs(CI(1) - CI(2)));   % Check how small/big CI is compared to diff_mean

% Calculate the normal distribution (Z), 2.576 for 99 % conf.interval
z1 = mean(mean_move{2}) + (2.576 * std(mean_move{2} / sqrt(length(mean_move{2}))));
z2 = mean(mean_move{2}) - (2.576 * std(mean_move{2} / sqrt(length(mean_move{2}))));

z1_2 = mean(mean_move{10}) + (2.576 * std(mean_move{10} / sqrt(length(mean_move{10}))));
z2_2 = mean(mean_move{10}) - (2.576 * std(mean_move{10} / sqrt(length(mean_move{10}))));

% Calculate amount of data above CI
above_CI = diff(diff > (abs(z1 - z2))/2);

% Print results in console
disp(['Mean difference between ', GNSS_data{10}{1,10}, ' Mean and ', GNSS_data{2}{1,10}, ' Mean : ', num2str(diff_mean)]);
disp(['Mean difference between ', GNSS_data{10}{1,10}, ' Mean and ', GNSS_data{2}{1,10}, ' Mean : ', num2str(mean_diff_sto_perc), ' %']);
disp(' ');
disp(['Max difference between ', GNSS_data{10}{1,10}, ' Mean and ', GNSS_data{2}{1,10}, ' Mean : ', num2str(diff_max)]);
disp(['Max difference between ', GNSS_data{10}{1,10}, ' Mean and ', GNSS_data{2}{1,10}, ' Mean : ', num2str(mean_diff_max_sto_perc), ' %']);
disp(' ');
disp(['99 % Confidence Interval (student t) for ', GNSS_data{10}{1,10}, ' Mean : ', num2str(CI(1)), ' and ', num2str(CI(2)), ' = ', num2str(abs(CI(1)-CI(2))), ' or +- ', num2str(abs(CI(1)-CI(2))/2)]);
disp(['99 % Confidence Interval (student t) for ', GNSS_data{2}{1,10}, ' Mean : ', num2str(CI2(1)), ' and ', num2str(CI2(2)), ' = ', num2str(abs(CI2(1)-CI2(2))), ' or +- ', num2str(abs(CI2(1)-CI2(2))/2)]);
disp(' ');
disp(['99 % Confidence Interval (Z) for ', GNSS_data{10}{1,10}, ' Mean : ', num2str(z1_2), ' and ', num2str(z2_2), ' = ', num2str(abs(z1_2 - z2_2)), ' or +- ', num2str(abs(z1_2 - z2_2)/2)]);
disp(['99 % Confidence Interval (Z) for ', GNSS_data{2}{1,10}, ' Mean : ', num2str(z1), ' and ', num2str(z2), ' = ', num2str(abs(z1 - z2)), ' or +- ', num2str(abs(z1 - z2)/2)]);
disp(' ');
disp(['Amount of data above CI : ', num2str(length(above_CI)), ' or ', num2str(length(above_CI)/length(mean_move{2})*100), ' %']);
disp(' ');
disp(' ');

% Calculate the time delay & print to console
% The numTables-1 comes from that the last one is the one used for STO test
for i = 1:numTables-1
    % Loop to only cover each station pair once
    for j = i+1:numTables-1
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
    title(['Wavelet Scalogram for station ' GNSS_data{i}{1,10}]);
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
    title(['Anomaly detection in ZWD for station ' GNSS_data{i}{1,10}]);
    xline(datetime(2024,10,09,13,00,00), '--red', 'LineWidth', 2);
    xline(datetime(2024,10,10,13,10,00), '--red', 'LineWidth', 2);
    xline(datetime(2024,10,05,15,00,00), '-.black', 'LineWidth', 2);
    xline(datetime(2024,10,10,21,00,00), '-.black', 'LineWidth', 2);

    hold off;
end

    
% Plot for all western stations
figure;
hold on
xlabel('Date')
ylabel('ZWD (m)')
title('Milton, Western Florida')

plot(time{1},mean_move{1})
plot(time{2},mean_move{2})
plot(time{3},mean_move{3})
xline(datetime(2024,10,09,13,00,00), '--red', 'LineWidth', 2);
xline(datetime(2024,10,10,13,10,00), '--red', 'LineWidth', 2);
xline(datetime(2024,10,05,15,00,00), '-.black', 'LineWidth', 2);
xline(datetime(2024,10,10,21,00,00), '-.black', 'LineWidth', 2);
legend('FLAI', 'FLSN', 'FLSC')
hold off

% Plot for all central stations
figure;
hold on
xlabel('Date')
ylabel('ZWD (m)')
title('Milton, Central Florida')

plot(time{4},mean_move{4})
plot(time{5},mean_move{5})
plot(time{6},mean_move{6})
xline(datetime(2024,10,09,13,00,00), '--red', 'LineWidth', 2);
xline(datetime(2024,10,10,13,10,00), '--red', 'LineWidth', 2);
xline(datetime(2024,10,05,15,00,00), '-.black', 'LineWidth', 2);
xline(datetime(2024,10,10,21,00,00), '-.black', 'LineWidth', 2);
legend('ORL1', 'FLKS', 'FLCC')
hold off

% Plot for all eastern stations
figure;
hold on
xlabel('Date')
ylabel('ZWD (m)')
title('Milton, Eastern Florida')

plot(time{7},mean_move{7})
plot(time{8},mean_move{8})
plot(time{9},mean_move{9})
xline(datetime(2024,10,09,13,00,00), '--red', 'LineWidth', 2);
xline(datetime(2024,10,10,13,10,00), '--red', 'LineWidth', 2);
xline(datetime(2024,10,05,15,00,00), '-.black', 'LineWidth', 2);
xline(datetime(2024,10,10,21,00,00), '-.black', 'LineWidth', 2);
legend('FLBN', 'ORMD', 'TTVL')
hold off

% Plot for all data
figure;
hold on
xlabel('Date')
ylabel('ZWD (m)')
title('ZWD Milton, Florida')

plot(time{1},mean_move{1}, 'Color', '#EDB120')
plot(time{2},mean_move{2}, 'Color', '#EDB120')
plot(time{3},mean_move{3}, 'Color', '#EDB120')
plot(time{4},mean_move{4}, 'Color', '#D95319')
plot(time{5},mean_move{5}, 'Color', '#D95319')
plot(time{6},mean_move{6}, 'Color', '#D95319')
plot(time{7},mean_move{7}, 'Color', '#4DBEEE')
plot(time{8},mean_move{8}, 'Color', '#4DBEEE')
plot(time{9},mean_move{9}, 'Color', '#4DBEEE')
xline(datetime(2024,10,09,13,00,00), '--red', 'LineWidth', 2);
xline(datetime(2024,10,10,13,10,00), '--red', 'LineWidth', 2);
xline(datetime(2024,10,05,15,00,00), '-.black', 'LineWidth', 2);
xline(datetime(2024,10,10,21,00,00), '-.black', 'LineWidth', 2);
legend('FLAI', 'FLSN', 'FLSC', 'ORL1', 'FLKS', 'FLCC', 'FLBN', 'ORMD', 'TTVL')
hold off

% Plot the initial test of ZWD (not mean)
figure;
hold on
xlabel('Date')
ylabel('ZWD (m)')
title('ZWD for station FLSN')

plot(time{2},yData_ZWD_tot{2})
xline(datetime(2024,10,09,13,00,00), '--red', 'LineWidth', 2);
xline(datetime(2024,10,10,13,10,00), '--red', 'LineWidth', 2);
xline(datetime(2024,10,05,15,00,00), '-.black', 'LineWidth', 2);
xline(datetime(2024,10,10,21,00,00), '-.black', 'LineWidth', 2);
hold off

 % Plot the initial test of ZWD & Mean
figure;
hold on
xlabel('Date')
ylabel('ZWD (m)')
title('ZWD for station FLSN')

plot(time{2},yData_ZWD_tot{2})
plot(time{2},mean_move{2})
xline(datetime(2024,10,09,13,00,00), '--red', 'LineWidth', 2);
xline(datetime(2024,10,10,13,10,00), '--red', 'LineWidth', 2);
xline(datetime(2024,10,05,15,00,00), '-.black', 'LineWidth', 2);
xline(datetime(2024,10,10,21,00,00), '-.black', 'LineWidth', 2);
legend('Original Data', '30min Mean Data')
hold off

% Plot the CWT and Threshold
figure;
hold on;
subplot(2,1,1)
imagesc(time{2}, f, abs(wt{2}));
axis xy;
xlabel('Date');
ylabel('Frequency (Hz)');
title(['Wavelet Scalogram for station ' GNSS_data{2}{1,10}]);
xlim([time{2}(1), time{2}(length(time{2}))]);
xline(datetime(2024,10,09,13,00,00), '--red', 'LineWidth', 2);
xline(datetime(2024,10,10,13,10,00), '--red', 'LineWidth', 2);
xline(datetime(2024,10,05,15,00,00), '-.black', 'LineWidth', 2);
xline(datetime(2024,10,10,21,00,00), '-.black', 'LineWidth', 2);
subplot(2,1,2)
imagesc(time{2}, f, anomaly_mask{2});
axis xy;
xlabel('Date');
ylabel('Frequency (Hz)');
title(['Anomaly detection in ZWD for station ' GNSS_data{2}{1,10}]);
xline(datetime(2024,10,09,13,00,00), '--red', 'LineWidth', 2);
xline(datetime(2024,10,10,13,10,00), '--red', 'LineWidth', 2);
xline(datetime(2024,10,05,15,00,00), '-.black', 'LineWidth', 2);
xline(datetime(2024,10,10,21,00,00), '-.black', 'LineWidth', 2);
hold off;


% Plot the lags for FLSC-TTVL, FLSC-FLKS, FLKS-TTVL
% Plot the visual lags for station
figure;
stem(lags{3, 9}, c{3, 9})
[~, linearIndex] = max(c{3,9}(:));
xMax = lags{3,9}(linearIndex);
xline(0, '--red', 'LineWidth', 2);
xline(xMax, '--black', 'LineWidth', 2);
text(xMax, 0, [num2str(xMax)]);
title(['ZWD for station ' GNSS_data{3}{1,10} ' and ' GNSS_data{9}{1,10}]);

% Plot the visual lags for station
figure;
stem(lags{3, 5}, c{3, 5})
[~, linearIndex] = max(c{3,5}(:));
xMax = lags{3,5}(linearIndex);
xline(0, '--red', 'LineWidth', 2);
xline(xMax, '--black', 'LineWidth', 2);
text(xMax, 0, [num2str(xMax)]);
title(['ZWD for station ' GNSS_data{3}{1,10} ' and ' GNSS_data{5}{1,10}]);

% Plot the visual lags for station
figure;
stem(lags{5, 9}, c{5, 9})
[maxValue, linearIndex] = max(c{5,9}(:));
xMax = lags{5,9}(linearIndex);
xline(0, '--red', 'LineWidth', 2);
xline(xMax, '--black', 'LineWidth', 2);
text(xMax, 0, [num2str(xMax)]);
title(['ZWD for station ' GNSS_data{5}{1,10} ' and ' GNSS_data{9}{1,10}]);


% Plot the detrend'ed data
figure;
hold on;
plot(filtered1{2, 9})
plot(filtered2{2, 9})
plot(mean_move{2})
plot(mean_move{9})
plot(detrend(mean_move{2}));
plot(detrend(mean_move{9}));
title(['ZWD for station ' GNSS_data{2}{1,10} ' and ' GNSS_data{9}{1,10}]);
hold off;


% Plot the difference between the different datasets, for representation if
% STO is worth over PWC 5min, to do on all data
figure;
hold on
xlabel('Date')
ylabel('ZWD (m)')
title('ZWD for station FLSN')

plot(time{2},yData_ZWD_tot{2})
plot(time{2},mean_move{2})
plot(time{10},yData_ZWD_tot{10})
plot(time{10},mean_move{10})
legend('FLSN PWC 5min', 'FLSN PWC 5min Mean', 'FLSN STO', 'FLSN STO Mean')
hold off;

% Plot HTC
figure;
hold on
xlabel('Date')
ylabel('HTC (m)')
title('HTC for station FLSN, 120 min interval')
plot(time_htc{1},yData_htc_E_W{1})
plot(time_htc{1},yData_htc_N_S{1})
plot(time_htc{1},yData_htc_tot{1})

xline(datetime(2024,10,09,13,00,00), '--red', 'LineWidth', 2);
xline(datetime(2024,10,10,13,10,00), '--red', 'LineWidth', 2);
xline(datetime(2024,10,05,15,00,00), '-.black', 'LineWidth', 2);
xline(datetime(2024,10,10,21,00,00), '-.black', 'LineWidth', 2);
yline(0, '-.black', 'LineWidth', 2);
legend('E-W HTC', 'N-S HTC', 'TOT HTC')
hold off;

