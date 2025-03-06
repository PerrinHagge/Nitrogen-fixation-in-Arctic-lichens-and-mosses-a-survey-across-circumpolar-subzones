% Provide the file path of the Excel file
file_path = 'Lichens.xlsx';

% Read the Excel file
data = readtable(file_path);

% Extract data table
b_C2H4 = data{:, 'bC2H4'}; 
m_C2H4 = data{:, 'fC2H4'}; 
Type = data{:, 'Genus'}; 
Location = data{:, 'Location'};
dry_w = data{:, 'Dry_Weight'};
wet_w = data{:, 'Wet_Weight'};
T_uc = data{:, 'Temperature'};
s_name = data{:, 'Sample'};
Lat = data{:, 'Latitude'};
Long = data{:, 'Longitude'};
Collection = data{:, 'Collection'};
Subzone = data{:, 'Subzone'};
Nb = data{:, 'Nb'};
Nm = data{:, 'Nm'};
pv_bC2H4 = data{:, 'pv_bC2H4'};
pv_mC2H4 = data{:, 'pv_fC2H4'};

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