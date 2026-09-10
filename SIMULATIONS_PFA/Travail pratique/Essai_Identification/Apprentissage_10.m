clear all
close all
clc
%% Données de la température
data = load('fichier_2.txt');
g = data';
y=g/100;
N = length(y);% nombre de mesures
u = zeros(1, N);
%% Données de la commande
u(1:501)       = 1.5;
u(502:801)     = 1.75;
u(802:1301)    = 0.25;
u(1302:1601)   = 2;
u(1602:1801)   = 0.2;
u(1802:N)   = 1.8;
%% initialisation
mu = 0.01; % pas d’adaptation
pmax = 500; % nombre maximal de passages
W1=0.1*randn(10,2);     %Matrice poids entrante
b1=0.1*rand(10,1);       %vecteur biais à l'entrée
W2=0.1*randn(1,10);      %Matrice poids sortante
b2=0.1*randn;            %vecteur biais à la sortie
%u=rand(1,N)-0.5;             %Mesure ancienne de la commande u(k)
n = 10;                       % nb de neurones sur la couche cachée
%% ALGORITHME D'APPRENTISSAGE
for p = 1:pmax   % Boucle passages
    
    for k = 3:N  % Boucle mesures
        %VECTEUR D'ENTREE
        X=[y(k-1);u(k-1)];
        % Calcul des sorties des couches cachées
        V1=W1*X-b1;
        S1=tanh(V1);
        V2=W2*S1-b2;
        y1(k)=tanh(V2);      
        % Rétropropagation
        e=y(k) - y1(k);
        %Actualisation de la matrice poids
        df2 = e* (1 - y1(k)^2);
        W2=W2+mu*df2*S1';
        b2=b2-mu*df2;
        df1=(W2'*df2).*(1-S1.^2);
        W1=W1+mu*df1*X';
        b1=b1-mu*df1;
    end
    
    % critère : somme des erreurs au carré
    Cr(p) = (y - y1) * (y - y1)'/N;  
end

%% ----------- AFFICHAGES -----------
%% Convergence de critere
figure(1)
plot(Cr, '*r')
title('Evolution de l''erreur quadratique', 'fontsize', 16)
grid on
xlabel('Nombre de passages')
ylabel('Critère Cr')

%% EVOLUTION DE LA SORTIE DE RESEAUX ET CELLE DE SYSTEME
figure(2)
plot(y1, 'b')
hold on
plot(y, 'g')

grid on
title({'Evolutions de la sortie du neurone y1(k) et y(k)';'0 < k < 51'}, 'fontsize', 16)
xlabel('Itération k')
ylabel('Sortie système et sortie modèle')
legend('y(k)', 'y1(k)')
%% Evolution de la commande
figure(3)
plot(u, 'r')
grid on
title({'Evolution de la commande'}, 'fontsize', 16)
xlabel('Itération k')
ylabel('Sortie système et sortie modèle')
legend('u(k)')
save('C:\Users\user\Desktop\2AGE2\PFA2_AGE2\SIMULATIONS_PFA\Travail pratique\Essai_Identification\Poids_10.csv','W1','b1','W2','b2');
%% =============== Test =================
data2 = load('fichier_1.txt');
Ntest = length(data2);      % ? corrigé : data ? data2
g = data2';
y_t = g/100;                % normalisation du prof : ok
%% Evolution de la commande de Test
u_test = zeros(1, Ntest);
u_test(1:501)       = 1.5;
u_test(502:801)     = 1.75;
u_test(802:1301)    = 0.25;
u_test(1302:1601)   = 2;
u_test(1602:1801)   = 0.2;
u_test(1802:Ntest)  = 1.8;
u_t = u_test/5;             % normalisation du prof : ok
%% Initialisation (manquait complètement)
y1_t = zeros(1, Ntest);     % ? ajouté : sinon crash si Ntest > N_app

%% Réponse du réseau (sans apprentissage)
for k = 3:Ntest
    % vecteur d'entrée
    X_test = [y_t(k-1); u_t(k-1)];
    
    % propagation avant uniquement
    V1_test = W1*X_test - b1;
    S1_test = tanh(V1_test);
    V2_test = W2*S1_test - b2;
    y1_t(k) = tanh(V2_test);
end

%% Critère d'erreur de validation
Cr_test = (y_t - y1_t)*(y_t - y1_t)'/Ntest;
disp(['Erreur Test = ', num2str(Cr_test)])
figure(4)
plot(y_t*100,'g--')
hold on
plot(y1_t*100,'b--')
grid on
title('sortie système vs sortie réseau  du test','fontsize',14)
xlabel('Itération k')
ylabel('Sortie')
legend('y_{test}(k)','y1_{test}(k)')
