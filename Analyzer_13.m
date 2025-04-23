% Load data from Lichens.xlsx
%data = readtable('Bryophytes.xlsx');
%data = readtable('Bryophytes_FR.xlsx');

data = readtable('Lichens.xlsx');
%data = readtable('Lichens_FR.xlsx');

% Extract required variables
T_C = data.Temperature;      % in Celsius
b = data.bC2H4;              % background C2H4
m = data.fC2H4;              % fixation C2H4 (equivalent to slope)
dry_w = data.Dry_Weight;     % dry weight in g

% Apply offsets to b and m
b = b + 0.1253;
m = m + 112.82;

% Constants
P = 1;                       % atm
Vc = 0.5674;                 % L
R = 0.0821;                  % L·atm·mol⁻¹·K⁻¹
Ratio = 3;                   % C2H4:N2 ratio
T_K = T_C + 273.15 + 1.21707317;          % convert to Kelvin

% Absolute uncertainties
rel_err_m = 0.03;            % 3%
rel_err_b = 0.03;            % 3%
delta_Vc = 0.01135;          % L
delta_T = 0.5;               % K
delta_dry_w = 0.001;         % g
rel_err_P = 0.007;           % 0.7% uncertainty in pressure

% Preallocate output
N_dw = zeros(size(m));
delta_N_dw = zeros(size(m));

% Loop through each row of data
for i = 1:length(m)
    m_i = m(i);
    b_i = b(i);
    dw_i = dry_w(i);
    T_i = T_K(i);

    % Set b to 0 if it's negative
    if b_i < 0
        b_i = 0;
    end

    % Set N_dw and uncertainty to 0 if invalid m
    if m_i < b_i || m_i < 0
        N_dw(i) = 0;
        delta_N_dw(i) = 0;
    else
        % Calculate N_dw
        num = (m_i - b_i) * Vc * P;
        denom = R * T_i * Ratio * dw_i;
        N_dw(i) = (1/12) * num / denom;

        % Relative uncertainty in (m - b)
        delta_m = rel_err_m * m_i;
        delta_b = rel_err_b * b_i;
        rel_err_mb = sqrt(delta_m^2 + delta_b^2) / abs(m_i - b_i);

        % Relative errors for other terms
        rel_err_Vc = delta_Vc / Vc;
        rel_err_T = delta_T / T_i;
        rel_err_dw = delta_dry_w / dw_i;

        % Total relative uncertainty in N_dw (includes P)
        rel_err_N_dw = sqrt(rel_err_mb^2 + rel_err_Vc^2 + ...
                            rel_err_T^2 + rel_err_dw^2 + rel_err_P^2);

        % Absolute uncertainty
        delta_N_dw(i) = N_dw(i) * rel_err_N_dw;
    end
end

% Store results in the table
data.N_dw = N_dw;
data.delta_N_dw = delta_N_dw;

% Optional: save to a new file
writetable(data, 'Lichens_with_N_dw.xlsx');
