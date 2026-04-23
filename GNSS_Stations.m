clc 
clear
close all

% --- Milton ---
% Locations for the GPS data
locations_milton = [
    27.449731, -82.690230; % FLAI
    27.333611, -82.438323; % FLSN
    27.217272, -82.404745; % FLSC
    28.434562, -81.382467; % ORL1
    28.295611, -81.436352; % FLKS
    28.094482, -81.274206; % FLCC 
    29.594142, -81.287096; % FLBN
    29.298186, -81.108892; % ORMD
    28.505709, -80.803381; % TTVL

    27 + 58.7/60, -(82 + 49.9/60) % Water Level Clearwater Beach
];

% Labels for the locations
labels_milton = {
    'FLAI'
    'FLSN'
    'FLSC'
    'ORL1'
    'FLKS'
    'FLCC'
    'FLBN'
    'ORMD'
    'TTVL'

    'WL Clearwater'
};

% --- Helene ---
% Locations for the GPS data
locations_helene = [
    30.094282, -83.572900; % FLPY
    30.374022, -83.275478; % FLMD
    30.612525, -83.146681; % FL75

    29.842600, -84.695148; % FLCB
    30.396523, -84.355843; % TALH
    30.579702, -84.266277; % FLJL
    30.833576, -83.982649; % GATE
    31.182252, -83.786949; % GAME

    29 + 43.5/60, -(84 + 58.8/60) % Water Level Apalachicola
];

% Labels for the locations
labels_helene = {
    'FLPY'
    'FLMD'
    'FL75'

    'FLCB'
    'TALH'
    'FLJL'
    'GATE'
    'GAME'

    'WL Apalachicola'
};

% Positioning of the background satellite images from NOAA / NESDIS
A_milton = flipud(imread('Milton_2024284_0330_2kX2k_cropped.jpg'));
latlim_milton = [25.00, 30.84];
lonlim_milton = [-85.00, -80.00];
R_milton = georefcells(latlim_milton, lonlim_milton, size(A_milton));

A_helene = flipud(imread('Helene_2024271_0450_2kX2k_cropped.jpg'));
latlim_helene = [26.31, 33.49];
lonlim_helene = [-86.51, -80.00];
R_helene = georefcells(latlim_helene, lonlim_helene, size(A_helene));

% Milton Figure
figure
set(gcf, 'Units', 'centimeters', 'Position', [15, 8, 17, 16])

hold on;
axesm('mercator','MapLatLimit',latlim_milton,'MapLonLimit',lonlim_milton)
setm(gca, 'MLabelLocation', 5, 'PLabelLocation', 5, 'MLabelParallel', 'south', 'PLabelMeridian', 'west')
geoshow(A_milton, R_milton)

% Plot all locations and labels
for i = 1:size(locations_milton, 1)
    geoshow(locations_milton(i,1), locations_milton(i,2), 'DisplayType', 'point', 'Marker', 'o', 'MarkerSize', 8, 'MarkerEdgeColor', 'black', 'MarkerFaceColor', 'white');
    textm(locations_milton(i,1) - 0.01, locations_milton(i,2) + 0.09, labels_milton(i), 'Color', 'k', 'FontSize', 12);
end

% Fixes grids for lat/lon & better positioning of image
gridm on
mlabel on
plabel on
framem on
tightmap

hold off;

% Helene Figure
figure
set(gcf, 'Units', 'centimeters', 'Position', [15, 8, 17, 16])

hold on;
axesm('mercator','MapLatLimit',latlim_helene,'MapLonLimit',lonlim_helene)
setm(gca, 'MLabelLocation', 5, 'PLabelLocation', 5, 'MLabelParallel', 'south', 'PLabelMeridian', 'west')
geoshow(A_helene, R_helene)

% Plot all locations and labels
for i = 1:size(locations_helene, 1)
    geoshow(locations_helene(i,1), locations_helene(i,2), 'DisplayType', 'point', 'Marker', 'o', 'MarkerSize', 8, 'MarkerEdgeColor', 'black', 'MarkerFaceColor', 'white');
    textm(locations_helene(i,1) - 0.01, locations_helene(i,2) + 0.09, labels_helene(i), 'Color', 'k', 'FontSize', 12);
end

% Fixes grids for lat/lon & better positioning of image
gridm on
mlabel on
plabel on
framem on
tightmap

hold off;

% -- Image used for front page --
% Positioning of the background satellite images from NOAA / NESDIS
A_front = flipud(imread('test_picture_M_H_cropped_2.jpg'));
latlim_front = [23.5897, 32.3700];
lonlim_front = [-87.3932, -79.1453];
R_front = georefcells(latlim_front, lonlim_front, size(A_front));

% Front Figure
figure
set(gcf, 'Units', 'centimeters', 'Position', [15, 8, 17, 16])

hold on;
axesm('mercator', 'MapLatLimit', latlim_front, 'MapLonLimit', lonlim_front)
setm(gca, 'MLabelLocation', 5, 'PLabelLocation', 5, 'MLabelParallel', 'south', 'PLabelMeridian', 'west')
geoshow(A_front, R_front)

% Plot locations for Helene & Milton
for i = 1:size(locations_helene, 1)
    geoshow(locations_helene(i,1), locations_helene(i,2), 'DisplayType', 'point', 'Marker', 'o', 'MarkerSize', 8, 'MarkerEdgeColor', 'black', 'MarkerFaceColor', 'white');
end
for i = 1:size(locations_milton, 1)
    geoshow(locations_milton(i,1), locations_milton(i,2), 'DisplayType', 'point', 'Marker', 'o', 'MarkerSize', 8, 'MarkerEdgeColor', 'black', 'MarkerFaceColor', 'white');
end

% Fixes grids for lat/lon & better positioning of image
gridm on
mlabel on
plabel on
framem on
tightmap

hold off;
