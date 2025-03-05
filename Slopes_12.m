opts1 = detectImportOptions('Jan 22.xlsx');
opts1.SelectedVariableNames = [2, 18, 21, 24, 25]; % Change 20, 23, and 24 for in situ Svalbard data
[Time, C2H4, H2O, startTimes, stopTimes] = readvars('Jan 22.xlsx', opts1);

% Initialize arrays to store the calculated slopes, R-squared values, p-values, data points count, and slope uncertainties
numIntervals = length(startTimes);
slopes = zeros(numIntervals, 1);
rSquaredValues = zeros(numIntervals, 1);
pValues = zeros(numIntervals, 1);
dataPointsCount = zeros(numIntervals, 1); % To store the count of data points used for each interval

lineWidth = 2; % Adjust this value to set the desired line thickness

figure;
hold on;
plot(Time, C2H4, 'o', 'DisplayName', 'Data');

for i = 1:numIntervals
    startIdx = find(Time >= startTimes(i), 1);
    stopIdx = find(Time <= stopTimes(i), 1, 'last');

    if isempty(startIdx) || isempty(stopIdx) || (stopIdx <= startIdx + 1)
        continue;
    end

    x_fit = Time(startIdx:stopIdx);
    y_fit = C2H4(startIdx:stopIdx);

    % Store the count of data points used for each interval
    dataPointsCount(i) = numel(x_fit);

    % Perform linear regression using regress function
    X = [ones(length(x_fit), 1) x_fit];
    [coefficients, ~, ~, ~, stats] = regress(y_fit, X);

    slopes(i) = coefficients(2); % Slope is the second coefficient in this case
    rSquaredValues(i) = stats(1); % R-squared value
    pValues(i) = stats(3); % p-value for the slope estimation

    % Plot the fitted line
    fittedLine = [min(x_fit), max(x_fit); coefficients(1) + coefficients(2) * [min(x_fit), max(x_fit)]];
    plot(fittedLine(1, :), fittedLine(2, :), '-', 'LineWidth', lineWidth, 'DisplayName', ['Best-Fit Line ' num2str(i)]);
end

hold off;

% Calculate slope uncertainties
slopes_unc = zeros(numIntervals, 1); % Initialize the slope uncertainty array
for i = 1:numIntervals
    if dataPointsCount(i) > 2 % Ensure valid intervals
        df = dataPointsCount(i) - 2; % Degrees of freedom
        tValue = tinv(1 - pValues(i) / 2, df); % Calculate the t-value
        slopes_unc(i) = slopes(i) / tValue; % Calculate the uncertainty
    else
        slopes_unc(i) = NaN; % Assign NaN for invalid intervals
    end
end

% Store the variable in the workspace
assignin('base', 'slopes_unc', slopes_unc);

% Add labels and other plot customization if necessary
datetick('x', 'HH:mm:ss');
xlabel('Time (EDT)', 'FontSize', 14, 'FontWeight', 'bold');
ylabel('C2H4 (ppb(v))', 'FontSize', 14, 'FontWeight', 'bold');
title('Picarro Run With Slopes and Uncertainties', 'FontSize', 16, 'FontWeight', 'bold');
ax = gca; % Get current axes
ax.FontSize = 12; % Set font size for tick mark labels
ax.FontWeight = 'bold'; % Set font weight for tick mark labels
grid on;

slopes_unc = abs(slopes_unc);


