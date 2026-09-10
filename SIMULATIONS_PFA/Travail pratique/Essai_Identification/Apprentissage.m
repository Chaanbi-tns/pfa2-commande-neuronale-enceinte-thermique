clear all
close all
clc
data = load('fichier_2.txt');
g = data';
y=g/100;
N = length(y);
u = zeros(1, N);
%%Données de la commande
u(1:501)       = 1.5;
u(502:801)     = 1.75;
u(802:1301)    = 0.25;
u(1302:1601)   = 2;
u(1602:1801)   = 0.2;
u(1802:N)   = 1.8;
%% initialisation
mu = 0.01; % pas d’adaptation
pmax = 150; % nombre maximal de passages
%%  Initialisation des paramètres du neurone artificiel
%% APPRENTISSAGE
w0 = 0.5; 
w1 = 0.1; 
w2 = 0.1;
 y1 = zeros(1,N);
 for p = 1:pmax   
    for k = 3:N  
             v = -w0 + w1 * u(k-1) + w2 * y(k-1);
             y1(k) = tanh(v); % sortie du neurone
        
              %  Termes de correction et de retropropagation( Backpropagation )
             df =  1 - tanh(v)^2;
             dw0 = mu * (y(k) - y1(k)) * df * (-1);
             dw1 = mu * (y(k) - y1(k)) * df * u(k-1);
             dw2 = mu * (y(k) - y1(k)) * df * y(k-1);
             w0 = w0 + dw0;
             w1 = w1 + dw1;
             w2 = w2 + dw2;
    end
    
    % critère : somme des erreurs au carré
    Cr(p) = (y - y1) * (y - y1)'/N; 
 end
%% ----------- AFFICHAGES -----------
figure(1)
%plot(g,'r'); 
hold on
grid on
title('Données d''essai ')
hold on;
plot(u*20, 'g')
grid on
xlabel('k')
ylabel('Commande & Température')
legend( 'Temperature')
figure(2)
plot(Cr,'*r'); 
hold on
grid on
title('Convergence du critère Cr ','FontSize',14)
xlabel('Nombre de passages')
ylabel('Critère Cr')
figure(3)
plot(y1, 'b')
hold on
plot(y, 'g')
grid on
title({'Evolutions de sortie du réseaux et de y(k)';'0 < k < 51'}, 'fontsize', 16)
xlabel('Itération k')
ylabel('Sortie système et sortie modèle')
legend('y1(k)', 'y(k)')
%% =============== TEST  =================
data2 = load('fichier_1.txt');
Ntest = length(data2);      % ? corrigé : data ? data2
g = data2';
y_t = g/100;                % normalisation du prof : ok

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

%% Réponse du neurone (poids figés)
for k = 3:Ntest
    v_t      = -w0 + w1*u_t(k-1) + w2*y_t(k-1);
    y1_t(k)  = tanh(v_t);
end

%% Critère d'erreur de validation
Err_t = (y_t - y1_t) * (y_t - y1_t)' / Ntest;  % ? corrigé : y1_test ? y1_t
disp(['Erreur quadratique de validation = ', num2str(Err_t)])

%% Affichage
figure(4)
plot(g, 'g', 'LineWidth', 1.5)
hold on
plot(y1_t*100, 'b', 'LineWidth', 1.5)   % dénormalisation *100 : ok
grid on
title('Phase de validation : sortie système vs sortie réseau', 'FontSize', 14)
xlabel('Itération k')
ylabel('Sortie (°C)')
legend('y_{test}(k)', 'y1_{test}(k)')
