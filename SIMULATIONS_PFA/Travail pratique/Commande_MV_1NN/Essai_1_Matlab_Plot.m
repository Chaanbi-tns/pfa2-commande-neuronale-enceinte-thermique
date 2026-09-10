clc; clear; close all;
data = readtable('Data_4000.txt', 'Delimiter', ' ', 'HeaderLines', 1);
data.Properties.VariableNames = {'k', 't', 'Power'};
k = data.k;
T = data.k;
P = data.Power;
disp([k' T' P'])
figure;
yc = 35 * ones(size(k));   
yc(k > 2000) = 45;        
title('Température T(k)')
xlabel('k');
ylabel('T');
legend('T(k)','Consigne');
disp([k' T' P'])
subplot(2,1,1)
plot(data.k, data.t, 'b', 'LineWidth', 1.8);
hold on;
plot(k, yc,'r','LineWidth',2)
title('Température T(k)')
xlabel('k'); 
ylabel('T')
legend('T(k)','Consigne')


subplot(2,1,2)
plot(data.k, data.Power, 'g', 'LineWidth', 1.8)
grid on; xlabel('k'); ylabel('%'); title('Power');legend('P(k)');