clear all
close all
clc
%% LIRE CE COMMENTAIRE ICI POUR COMPRENDRE DE QUOI S'AGIT LE SCRIPT 
%VISUALISATION DU CRITERE "Cr" EN FONCTION DU PAS D'ADAPTATION "mu" POUR UN
%RESEAUX DE "1 NEURONE" pour 3 valeurs differentes
%CACHEE


%% initialisation
N = 100; % nombre de mesures
mu_v=[0.001 0.01 0.1];% vecteurs de valeurs mu à tester 
%mu = 0.2; % pas d’adaptation
u = rand(1,N)-0.5;
y(1)=0;
y(2)=0;
pmax = 100; % nombre maximal de passages
Cr = zeros(3,pmax); % stockage des critères
for k = 3:N
    a= y(k-2);
    y(k) = -0.8*a*(u(k-1))^2/(1+(u(k-1))^2)+ 0.033*y(k-1) + 0.5*u(k-1);
end
%%  Initialisation des paramètres du neurone artificiel
pmax = 100; % nombre maximal de passages

%%  valeurs initiales de la sortie du neurone
y(1) =0;
y(2) = 0;
%% APPRENTISSAGE
for i=1:3
    mu = mu_v(i);   % pas d'adaptation courante
    w0 = 0.5; 
    w1 = -0.1; 
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
    Cr(i,p) = (y - y1) * (y - y1)'; 
end
end
%save('C:\Users\user\Desktop\2AGE2\PFA2_AGE2\COMMANDE\Commande_Min_Variance\NN_1.mat','w0','w1','w2');
%% ----------- AFFICHAGES -----------

figure(1)
plot(Cr(1,:),'*r'); hold on
plot(Cr(2,:),'*b')
plot(Cr(3,:),'*g')
grid on
title('Convergence du critère Cr mu differentes','FontSize',14)
xlabel('Nombre de passages')
ylabel('Critère Cr')
legend('\mu = 0.001','\mu = 0.01','\mu = 0.1')

figure(2)
plot(y1, 'b')
hold on
plot(y, 'g')
grid on
title({'Evolutions de y_1(k) et de y(k)';'0 < k < 51'}, 'fontsize', 16)
xlabel('Itération k')
ylabel('Sortie système et sortie modèle')
legend('y1(k)', 'y(k)')
figure(3)
plot(u, '-r')
title('Evolution de la commande')
grid on
xlabel('k')
ylabel('Commande')