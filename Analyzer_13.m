% Provide the file path of the Excel file
file_path = 'ARACAS Laboratory Measurements.xlsx';

% Read the Excel file
data = readtable(file_path);

% Extract data table
blank_C2H4 = data{:, 'Blank_C2H4'}; 

% Make rates per hour
blank_24 = blank_C2H4 ./ 24;

% Provide the file path of the Excel file
file_path = 'ARACAS Laboratory Measurements.xlsx';

% Read the Excel file
data = readtable(file_path);

% Extract data table
b_C2H4 = data{:, 'Background_C2H4'}; 
m_C2H4 = data{:, 'Measured_C2H4'}; 
Type = data{:, 'Type'}; 
Location = data{:, 'Location'};
dry_w = data{:, 'Dry_Weight'};
wet_w = data{:, 'Wet_Weight'};
T_uc = data{:, 'Temperature'};
s_name = data{:, 'Sample'};

% Subtract values in column A from column B to create variable C2H4
C2H4 = m_C2H4 - b_C2H4;

% Zero Correct Data
C2H4_zc = C2H4;
C2H4_zc(C2H4 < 0) = 0;

% Make rates per hour
C2H4_24 = C2H4_zc ./ 24;

% Calculate Volume of C2H4 in the chamber
C2H4_V = (C2H4_24 .* 0.6)./ 1000000000;

%Calculate Corrected Temp in Celcius
T = T_uc + 1.21707317;

%Calculate Temp in Kelvin
T_K = T + 273.15; 

% Calculate mols of C2H4 in the chamber
C2H4_m = (C2H4_V .* 1)./ (0.0821 .* T_K ); % 1 is the pressure in atmosphere

% Calculate nano mols of C2H4 in the chamber
N_nm = (C2H4_m .* 1000000000)./ 3.5;

% Standardize to Dry Weight
N_dw = N_nm ./ dry_w;

% Water Content
wc = ((wet_w - dry_w) ./ dry_w) * 100;

% Sort C2H4_dw data based on the groups in column Location
unique_locations = unique(Location); % Get unique location names
num_locations = numel(unique_locations);

% Create a structure to store subgroup data
subgroups = struct();

% Store C2H4_dw data in subgroup structure
for i = 1:num_locations
    location_name = unique_locations{i};
    location_indices = strcmp(Location, location_name);
    
    % Get unique Types within the current Location
    types_in_location = unique(Type(location_indices));
    num_types = numel(types_in_location);
    
    % Create sub-subgroups for each Type within the Location
    for j = 1:num_types
        type_name = types_in_location{j};
        indices = location_indices & strcmp(Type, type_name);
        
        % Extract C2H4_dw data for the current Location and Type
        subgroup_data = N_dw(indices);
        
        % Create a unique name for the subgroup
        subgroup_name = strcat('N_dw_', location_name, '_', type_name);
        
        % Store subgroup data in the subgroups structure
        subgroups.(subgroup_name) = subgroup_data;
        
        % Create variables for each subgroup (optional)
        var_name = genvarname(subgroup_name); % Generate valid variable name
        eval([var_name, ' = subgroup_data;']); % Create variable

        % Extract C2H4_dw data for the current Location and Type
        subgroup_data = dry_w(indices);
        
        % Create a unique name for the subgroup
        subgroup_name = strcat('dry_w_', location_name, '_', type_name);
        
        % Store subgroup data in the subgroups structure
        subgroups.(subgroup_name) = subgroup_data;
        
        % Create variables for each subgroup (optional)
        var_name = genvarname(subgroup_name); % Generate valid variable name
        eval([var_name, ' = subgroup_data;']); % Create variable

          % Extract C2H4_dw data for the current Location and Type
        subgroup_data = wet_w(indices);
        
        % Create a unique name for the subgroup
        subgroup_name = strcat('wet_w_', location_name, '_', type_name);
        
        % Store subgroup data in the subgroups structure
        subgroups.(subgroup_name) = subgroup_data;
        
        % Create variables for each subgroup (optional)
        var_name = genvarname(subgroup_name); % Generate valid variable name
        eval([var_name, ' = subgroup_data;']); % Create variable
    end
end
