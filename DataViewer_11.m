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
