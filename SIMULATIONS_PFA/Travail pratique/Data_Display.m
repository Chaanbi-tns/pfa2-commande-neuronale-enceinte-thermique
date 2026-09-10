%% ============================================================
%  Lecture et tracé - Parsing direct du log Python
%  Format : "Reçu : Temp: XX.XX °C | Power: YY.YY"
% =============================================================

clc; clear; close all;

%% --- 1. Chemin du fichier ---
filepath = 'C:\Users\user\Desktop\2AGE2\PFA2_AGE2\SIMULATIONS_PFA\Travail pratique\Commande_MV_1NN\Donnees_Essai.txt';

%% --- 2. Lecture et parsing ---
fid = fopen(filepath, 'r', 'n', 'UTF-8');
if fid == -1
    error('Impossible d''ouvrir le fichier.');
end

temp_list   = [];
power_list  = [];

while ~feof(fid)
    line = fgetl(fid);
    if ~ischar(line), continue; end
    
    % Cherche les lignes "Reçu : Temp: XX.XX °C | Power: YY.YY"
    tok = regexp(line, 'Temp:\s*([\d.]+)\s*.*Power:\s*([\d.]+)', 'tokens');
    if ~isempty(tok)
        temp_list(end+1)  = str2double(tok{1}{1}); %#ok<SAGROW>
        power_list(end+1) = str2double(tok{1}{2}); %#ok<SAGROW>
    end
end
fclose(fid);

N  = length(temp_list);
k  = (1:N)';
Ts = 2;                        % Période d'échantillonnage [s]
t  = (k - 1) * Ts;

% Consigne dénormalisée : yc = 0.35 * 100 = 35 °C
yc = 35 * ones(N, 1);

%% --- 3. Détection du reset (k revient à 3) ---
% Repère l'instant où la commande chute brutalement à 0
reset_idx = find(diff(power_list) < -10, 1, 'first') + 1;

%% --- 4. Tracé ---
figure('Name', 'Commande MV - Réseau de Neurones', ...
       'NumberTitle', 'off', ...
       'Position', [100, 80, 950, 650]);

% --- Subplot 1 : Température ---
subplot(2,1,1);
plot(t, temp_list, 'b-', 'LineWidth', 1.8); hold on;
plot(t, yc,        'r--','LineWidth', 1.5);
if ~isempty(reset_idx)
    xline(t(reset_idx), 'k:', 'LineWidth', 1.2, 'Label', 'Reset k');
end
grid on; grid minor;
xlabel('Temps (s)');
ylabel('Température (°C)');
title('Évolution de la température');
legend('Sortie mesurée  y(k)', 'Consigne  y_c = 35°C', 'Location','southeast');
ylim([min(temp_list)-1, max(yc)+5]);

% --- Subplot 2 : Commande ---
subplot(2,1,2);
stairs(t, power_list, 'g-', 'LineWidth', 1.8);
if ~isempty(reset_idx)
    xline(t(reset_idx), 'k:', 'LineWidth', 1.2, 'Label', 'Reset k');
end
grid on; grid minor;
xlabel('Temps (s)');
ylabel('Puissance (%)');
title('Signal de commande u(k)  [Power %]');
legend('Commande u(k)', 'Location','northeast');
ylim([-2, 105]);

sgtitle('Commande par Minimum de Variance — Modèle NN (ESP32)', ...
        'FontSize', 13, 'FontWeight', 'bold');