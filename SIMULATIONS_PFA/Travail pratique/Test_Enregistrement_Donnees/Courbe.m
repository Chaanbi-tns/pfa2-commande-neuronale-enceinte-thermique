clc; clear; close all;

data = readtable('C:\Users\user\Desktop\2AGE2\PFA2_AGE2\SIMULATIONS_PFA\Travail pratique\Commande_MV_1NN\Data_1000.txt', 'Delimiter', ' ', 'HeaderLines', 1);
data.Properties.VariableNames = {'k', 't', 'Power'};

subplot(2,1,1);
plot(data.k, data.t, 'b', 'LineWidth', 1.8);
grid on; xlabel('k'); ylabel('°C'); title('Température');

subplot(2,1,2);
plot(data.k, data.Power, 'g', 'LineWidth', 1.8);
grid on; xlabel('k'); ylabel('%'); title('Power');