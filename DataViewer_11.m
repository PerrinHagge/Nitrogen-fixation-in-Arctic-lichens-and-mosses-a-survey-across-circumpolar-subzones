opts1 = detectImportOptions('Jan 22.xlsx');
opts1.SelectedVariableNames = [2, 18, 21]; % Change to 20 for in situ data, 21 for others
[Time, C2H4, H2O] = readvars('Jan 22.xlsx', opts1);

% Plot individual data points
figure(1)         
scatter(Time, C2H4);
datetick('x', 'HH:mm:ss');
xlabel('Time (EDT)');
ylabel('C2H4 (ppb(v))');
title('Picarro Run');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Provide the file path of the Excel file
file_path = 'RWC.xlsx';

% Read the Excel file
data = readtable(file_path);

% Extract data table
b_C2H4 = data{:, 'bC2H4'}; 
m_C2H4 = data{:, 'fC2H4'}; 
dry_w = data{:, 'Dry_Weight'};
wet_w = data{:, 'Wet_Weight'};
turg_w = data{:, 'Turgid_Weight'};
T_uc = data{:, 'Temperature'};
s_name = data{:, 'Sample'};
% Light = data{:, 'Light'};
% CO2 = data{:, 'CO2'};
bC2H4_unc = data{:, 'bC2H4_unc'};
mC2H4_unc = data{:, 'mC2H4_unc'};


% Subtract values in column A from column B to create variable C2H4
b_C2H4(b_C2H4 < 0) = 0;
C2H4 = m_C2H4 - b_C2H4;

% Zero Correct Data
C2H4_zc = C2H4;
C2H4_zc(C2H4 < 0) = 0;

% Make rates per hour
C2H4_24 = C2H4_zc ./ 24;

% Calculate Volume of C2H4 in the chamber
C2H4_V = (C2H4_24 .* 0.5674)./ 1000000000;

% Calculate Corrected Temp in Celsius
T = T_uc + 1.21707317;

% Calculate Temp in Kelvin
T_K = T + 273.15; 

% Calculate mols of C2H4 in the chamber
C2H4_m = (C2H4_V .* 1)./ (0.0821 .* T_K ); % 1 is the pressure in atmosphere

% Calculate nano mols of N2 in the chamber
N2_nm = (C2H4_m .* 1000000000)./ 3;

% Calculate nano mols of N in the chamber
N_nm = N2_nm.* 2;

% Standardize to Dry Weight
N_dw = N_nm ./ dry_w;

% Water Content
wc = ((wet_w - dry_w) ./ dry_w) * 100;

% Relative Water Content
rwc = ((wet_w - dry_w) ./ (turg_w - dry_w)) * 100;
