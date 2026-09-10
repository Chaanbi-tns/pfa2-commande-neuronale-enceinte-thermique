clear all
close all
clc
%% LIRE CE COMMENTAIRE ICI POUR COMPRENDRE DE QUOI S'AGIT LE SCRIPT 
%VISUALISATION DU CRITERE "Cr" EN FONCTION DU PAS D'ADAPTATION "mu" POUR 3 VALEURS
%DIFFERENTES(0.001,0.01 et 0.1)POUR RESEAUX DE 10 NEURONES SUR COUCHES
%CACHEE

%% ---------------- INITIALISATION ----------------
mu_v = [0.001 0.01 0.1];   % 3 valeur de pas d'adaptation
pmax = 50;                   % nombre maximal de passages
N = 100;                    % nombre de mesures
n = 10;                      % nombre de neurones sur la couche cachee

Cr = zeros(3,pmax); % stockage des critères

%% ---------------- SIGNAUX D'ENTREE ----------------
u = rand(1,N)-0.5;% sera 
%y(1) = zeros(1,N);
y(1) = 0;
y(2)=0;
y1 = zeros(1,N);
% REPONSE DU SYSTEME ----------------
for k = 3:N
    a = y(k-2);
    y(k) = -0.8*a*(u(k-1))^2/(1+(u(k-1))^2)+ 0.033*y(k-1) + 0.5*u(k-1);
end

%% ================== APPRENTISSAGE ==================
% pour chaque valeur de mu  courante on initialise les poids et on calcul l'apprentissage et Cr
for i = 1:3
    mu = mu_v(i);   % pas d'adaptation courant
    % --- Initialisation des poids ---
    W1 = 0.1*randn(n,2);
    b1 = 0.1*rand(n,1);
    W2 = 0.1*randn(1,n);
    b2 = 0.1*randn;
    
    for p = 1:pmax   % Boucle passages
        
        for k = 3:N  % Boucle mesures
            
            % Vecteur d'entrée
            X = [y(k-1); u(k-1)];
            
            % Propagation avant
            V1 = W1*X - b1;
            S1 = tanh(V1);
            V2 = W2*S1 - b2;
            y1(k) = tanh(V2);
            
            % Erreur
            e = y(k) - y1(k);
            
            %% Rétropropagation
            df2 = e*(1 - y1(k)^2);
            W2 = W2 + mu*df2*S1';
            b2 = b2 - mu*df2;
            
            df1 = (W2'*df2).*(1 - S1.^2);
            W1 = W1 + mu*df1*X';
            b1 = b1 - mu*df1;
        end
        
        % Critère quadratique moyen
        Cr(i,p) = (y - y1)*(y - y1)'/N;
    end
end
save('C:\Users\user\Desktop\2AGE2\PFA2_AGE2\SIMULATIONS_PFA\Travail pratique\Essai_Identification\MPoids_10.mat','W1','b1','W2','b2');
%% ================== AFFICHAGES ==================

%%  --- Convergence du critère ---
figure
plot(Cr(1,:),'*r'); hold on
plot(Cr(2,:),'*b')
plot(Cr(3,:),'*g')
grid on
title('Convergence du critère Cr mu differentes','FontSize',14)
xlabel('Nombre de passages')
ylabel('Critère Cr')
legend('\mu = 0.001','\mu = 0.01','\mu = 0.1')

%% --- Sortie système vs réseau (dernier mu) ---
figure
plot(y,'r','linewidth',1.5); hold on
plot(y1,'b')
grid on
title('Comparaison sortie système / sortie réseau')
xlabel('k')
ylabel('Amplitude')
legend('y(k)','y_1(k)')

%%  --- Commande ---
figure
plot(u,'r')
grid on
title('Evolution de la commande u(k)')
xlabel('k')
ylabel('u(k)')
