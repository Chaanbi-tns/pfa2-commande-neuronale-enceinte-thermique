clear all
close all
clc

%% -------- Initialisation --------
imax   = 10;      % nombre max d'iterations (minimisation)
mu     = 0.2;     % pas de descente
lambda = 0.01;       % penalisation commande
alpha=1.0;
N  = 1000;            % longueur simulation
u  = zeros(1,N);      % commande
y  = zeros(1,N);      % sortie
y1 = zeros(1,N);      % sortie predite
yc = zeros(1,N);      % consigne

N1 = 300;
N2 = 600;

%% -------- Consigne --------
yc(1:N1)     = 0.3;
yc(N1+1:N2)  = 0.6;
yc(N2+1:N)   = 0.5;

%% -------- Conditions initiales --------
u(1) = 0; 
u(2) = 0;
y(1) = 0; 
y(2) = 0;

%% -------- Chargement des poids appris --------
load('NN_10.mat');   % doit contenir w10..w32

poids_10 = [W1(:)', b1', W2, b2];
writematrix(poids_10, 'poids_10.csv', 'Delimiter', ',');
fprintf('Fichier poids.csv généré : %d valeurs exportées.\n', length(poids_10));

%% -------- Boucle principale --------
for k = 3:N-1

    % --- Systeme reel ---
    y(k) = -0.8*(u(k-1)^2/(1+u(k-1)^2))*y(k-1)+ 0.033*y(k-1) + 0.5*u(k-1);

    % --- initialisation MV ---
        X = [y(k-1); u(k-1)];
        V1 = W1*X - b1;      % (10x1)
        S1 = tanh(V1);

        V2 = W2*S1 - b2;     
        y1(k) = tanh(V2);
        x = u(k-1);

   for i = 1:imax
        % ===== reseau neuronal =====
        X = [y(k); x];
        V1 = W1*X - b1;      % (10x1)
        S1 = tanh(V1);
        V2 = W2*S1 - b2;     % scalaire
        y1(k+1) = tanh(V2);
        y1(k+1)=y1(k+1)+alpha*(y(k)-y1(k));
        % ===== derivees =====
        df2 = 1 - tanh(V2)^2;      % sortie
        df1 = 1 - tanh(V1).^2;     % couche cachee (10x1)
        % dy/dx
        dy = df2 * ( W2 * (df1 .* W1(:,2)) );
        % ===== gradient MV =====
        dJ = -2*(yc(k+1) - y1(k+1))*dy + 2*lambda*(x-u(k-1));

        % ===== descente =====
        x = x - mu*dJ;

        % saturation (optionnel mais conseillé)
        x = max(min(x,2),-2);
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
