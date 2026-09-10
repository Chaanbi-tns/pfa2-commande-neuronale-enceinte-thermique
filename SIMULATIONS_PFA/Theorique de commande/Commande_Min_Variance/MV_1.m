clear all
close all
clc
%% -------- Initialisation --------
imax   = 10;      % nombre max d'iterations (minimisation)
mu     = 0.2;     % pas de descente
a      = 1;       % poids erreur
lambda = 0.001;       % penalisation commande
N1 = 300;
N2 = 600;
N  = 1000;            % longueur simulation
u  = zeros(1,N);      % commande
y  = zeros(1,N);      % sortie
y1 = zeros(1,N);      % sortie predite
yc = zeros(1,N);      % consigne
%% -------- Consigne --------
for k = 1:N1
    yc(k) = 0.3;
end
for k = N1+1:N2
    yc(k) = 0.6;
end
for k = N2+1:N
    yc(k) = 0.5;
end
%% -------- Conditions initiales --------
u(1) = 0; 
u(2) = 0;
y(1) = 0; 
y(2) = 0;
%% -------- Parametres du modele NN importtées comme résultats de l'algorithme d'apprentissage--------
w0 = -0.0442;w1 =0.0121;w2 = 0.9369;
% Récuppération des poids résultent de l'lgorithme d'identification du
% processus y
load('NN_1.mat');
fprintf('w0 = %.6f\n', w0);
fprintf('w1 = %.6f\n', w1);
fprintf('w2 = %.6f\n', w2);
alpha=1;
%% -------- Boucle principale de calcul de la commande par minimum de variance--------
for k = 3:N-1
    % --- Systeme reel ---
    y(k) = -0.8*(u(k-1)^2/(1+u(k-1)^2))*y(k-1)+ 0.033*y(k-1) + 0.5*u(k-1);
    % --- Optimisation de la commande ---
        v = -w0 + w1*u(k-1) + w2*y(k-1);
        y1(k) = tanh(v);%Sortie réseaux
    x = u(k-1);   % initialisation
    for i = 1:imax
        % modele neuronal (predicteur)
        v = -w0 + w1*x + w2*y(k);
        y1(k+1) = tanh(v);
        y1(k+1)=y1(k+1)+alpha*(y(k)-y1(k));
        % derivee tanh
        df = 1 - tanh(v)^2;
        % gradient du critere MV
        dJ = -2*(yc(k+1) - y1(k+1))*df*w1 + 2*lambda*(x-u(k-1));
        % descente de gradient
        x = x - mu*dJ;
    end
    % --- Mise a jour commande ---
    u(k) = x;
end
%% -------- AFFICHAGES --------

% Sortie et consigne
figure(1)
plot(y,'b','LineWidth',1.5)
hold on
plot(yc,'r--','LineWidth',1.5)
grid on
title('Commande Minimum de Variance','fontsize',16)
xlabel('Iteration k')
ylabel('Sortie y(k)')
legend('Sortie','Consigne')

% Evolution commande
figure(2)
plot(u,'g','LineWidth',1.5)
grid on
title('Evolution de la commande u(k)','fontsize',16)
xlabel('Iteration k')
ylabel('Commande u(k)')
