clc; clear; close all;

% Nom du fichier
filename = 'Data_2000.txt'; % <-- change si nécessaire

% Lecture du fichier (ignore lignes vides automatiquement)
data = readmatrix(filename);

% Supprimer les lignes NaN (causées par lignes vides)
data = data(~any(isnan(data),2), :);

% Extraction des colonnes
k = data(:,1);
t = data(:,2);
power = data(:,3);

% --- AFFICHAGE ---
figure;

% Température
subplot(2,1,1);
plot(k, t, 'k', 'LineWidth', 1.5);
grid on;
xlabel('k');
ylabel('Température (°C)');
title('Température en fonction de k');

% Puissance
subplot(2,1,2);
plot(k, power, 'k', 'LineWidth', 1.5);
grid on;
xlabel('k');
ylabel('Puissance');
title('Puissance en fonction de k');
