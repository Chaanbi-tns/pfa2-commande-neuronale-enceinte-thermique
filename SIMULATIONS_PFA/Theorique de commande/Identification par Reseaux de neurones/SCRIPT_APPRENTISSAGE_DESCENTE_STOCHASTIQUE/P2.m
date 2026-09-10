clear all
close all
clc
%% LIRE CE COMMENTAIRE ICI POUR COMPRENDRE DE QUOI S'AGIT LE SCRIPT 
%CE PROGRAMME ILLUSTRE L'APPRENTISSAGE D'UN RESEAUX DE NEURONE ARTIFICIELS
%(3 NEURONES)A UN SYSTEME  NON LINEAIRE g(k)
%POUR PREDIRE UN SIGNAL A PARTIR DE SES VALEURS PASSEES ICI g(k-1) ET
%g(k-2)
N = 50; % nombre de mesures

% Fonction non linéaire g(k)
%% Reponse systeme
for k = 1:N
    g(k) = 0.4 * sin(0.2 * k) + 0.6 * cos(0.4 * k);
end
%g=0.5*g;
% Initialisation
mu = 0.2; % pas d’adaptation

% paramètres du neurone artificiel
w30 = 0.15;w31 = -1.57;w32 = 0.225; 
w20 = -0.007;w21 = 0.259;w22 = 0.061;
w10 = 0.074;w11 = -1.375;w12 = 0.764;


pmax = 100; % nombre maximal de passages

% valeurs initiales de la sortie du neurone
%y = zeros(1, N);
y(1) = g(1);
y(2) = g(2);
%% APPRENTISSAGE
for p = 1:pmax   % Boucle passages
    
    
    for k = 3:N  % Boucle mesures
        % Calcul des sorties des couches cachées
        v1 = -w10 + w11*g(k-1) + w12*g(k-2);
        s1 = tanh(v1);
        v2 = -w20 + w21*g(k-1) + w22*g(k-2);
        s2 = tanh(v2);
        
        % Calcul de la sortie du réseau
        v = -w30 + w31*s1 + w32*s2;
        y(k) = tanh(v);
        
        % Rétropropagation
        % Erreur de la couche de sortie
        df = (g(k) - y(k)) * (1 - tanh(v)^2);
        
        % Mise à jour des poids de la couche de sortie
        dw30 = mu * df * (-1);
        dw31 = mu * df * s1;
        dw32 = mu * df * s2;
        
        % Rétropropagation vers la couche cachée
        % Pour le premier neurone caché
        delta1 = df * w31 * (1 - tanh(v1)^2);
        dw10 = mu * delta1 * (-1);
        dw11 = mu * delta1 * g(k-1);
        dw12 = mu * delta1 * g(k-2);
        
        % Pour le deuxième neurone caché
        df2 = df * w32 * (1 - tanh(v2)^2);
        dw20 = mu * df2 * (-1);
        dw21 = mu * df2 * g(k-1);
        dw22 = mu * df2 * g(k-2);
        
        % Adaptation des pondérations
        w30 = w30 + dw30;
        w31 = w31 + dw31;
        w32 = w32 + dw32;
        
        w10 = w10 + dw10;
        w11 = w11 + dw11;
        w12 = w12 + dw12;
        
        w20 = w20 + dw20;
        w21 = w21 + dw21;
        w22 = w22 + dw22;
    end
    
    % critère : somme des erreurs au carré
    Cr(p) = (g - y) * (g - y)';  % produit scalaire
end

%% ----------- AFFICHAGES -----------

figure(1)
plot(Cr, '*r')
title('Evolution de la somme des erreurs au carré', 'fontsize', 16)
grid on
xlabel('Nombre de passages')
ylabel('Critère Cr')

figure(2)
plot(y, 'b')
hold on
plot(g, 'g')
grid on
title({'Evolutions de g(k) et de y(k)';'0 < k < 51'}, 'fontsize', 16)
xlabel('Itération k')
ylabel('Sortie système et sortie modèle')
legend('y(k)', 'g(k)')
