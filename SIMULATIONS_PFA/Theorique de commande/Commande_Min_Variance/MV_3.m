clear all
close all
clc

%% -------- Initialisation --------
imax   = 10;      % nombre max d'iterations (minimisation)
mu     = 0.2;     % pas de descente
lambda = 1.0;       % penalisation commande
alpha=1;
N  = 1000;            % longueur simulation
u  = zeros(1,N);      % commande
y  = zeros(1,N);      % sortie
y1 = zeros(1,N);      % sortie predite
yc = zeros(1,N);      % consigne

N1 = 300;
N2 = 600;

%% -------- Consigne --------
yc(1:N1)     = 0.5;
yc(N1+1:N2)  = 0.8;
yc(N2+1:N)   = 0.5;

%% -------- Conditions initiales --------
u(1) = 0; 
u(2) = 0;
y(1) = 0; 
y(2) = 0;

%% -------- Chargement des poids depuis le modéle identifiée du systéme --------
load('NN_3.mat');
poids = [w10, w11, w12, w20, w21, w22, w30, w31, w32];
writematrix(poids, 'poids.csv');

%% -------- Boucle principale --------
for k = 3:N-1

    % --- Systeme reel ---
    y(k) = -0.8*(u(k-1)^2/(1+u(k-1)^2))*y(k-1)+ 0.033*y(k-1) + 0.5*u(k-1);

    % --- initialisation MV ---
    v1 = -w10 + w11*u(k-1) + w12*y(k-1);
    s1 = tanh(v1);
    v2 = -w20 + w21*u(k-1) + w22*y(k-1);
    s2 = tanh(v2);
    v  = -w30 + w31*s1 + w32*s2;
    y1(k) = tanh(v);
    x = u(k-1);

    for i = 1:imax

        % ===== reseau neuronal =====
        v1 = -w10 + w11*x + w12*y(k);
        s1 = tanh(v1);
        v2 = -w20 + w21*x + w22*y(k);

        
        s2 = tanh(v2);

        v  = -w30 + w31*s1 + w32*s2;
        y1(k+1) = tanh(v);
        y1(k+1)=y1(k+1)+alpha*(y(k)-y1(k));
        % ===== derivees =====
        df_out = 1 - tanh(v)^2;
        df1 = 1 - tanh(v1)^2;
        df2 = 1 - tanh(v2)^2;

        % ===== dy1/dx =====
        dy = df_out * ( w31*df1*w11 + w32*df2*w21 );

        % ===== gradient MV =====
        dJ = -2*(yc(k+1) - y1(k+1))*dy + 2*lambda*(x-u(k-1));

        % ===== descente =====
        x = x - mu*dJ;

        % (optionnel) saturation commande pour stabilité
        % x = max(min(x,1),-1);
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
