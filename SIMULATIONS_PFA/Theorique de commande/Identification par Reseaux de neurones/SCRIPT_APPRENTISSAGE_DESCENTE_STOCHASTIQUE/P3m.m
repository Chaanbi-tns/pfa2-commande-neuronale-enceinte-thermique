clear all
close all
clc
%% LIRE CE COMMENTAIRE ICI POUR COMPRENDRE DE QUOI S'AGIT LE SCRIPT 
%VISUALISATION DU CRITERE "Cr" EN FONCTION DU PAS D'ADAPTATION "mu" POUR UN
%RESEAUX DE 3 NEURONES
%CACHEE


%% initialisation
N = 50; % nombre de mesures
mu_v=[0.001 0.01 0.1];
mu = 0.2; % pas d’adaptation
u = rand(1,N);
y(1)=0;
y(2)=0;
y1 = zeros(1,N);
N = 50; % nombre de mesures
pmax = 100; % nombre maximal de passages
Cr = zeros(3,pmax); % stockage des critères
for k = 3:N
    a= y(k-2);
    y(k) = -0.8*a*(u(k-1))^2/(1+(u(k-1))^2)+ 0.033*y(k-1) + 0.5*u(k-1);
end
%% APPRENTISSAGE
for i=1:3
    mu = mu_v(i);   % pas d'adaptation courant
  % paramètres du neurone artificiel
      w30 = 0.15;w31 = -1.57;w32 = 0.225; 
      w20 = -0.007;w21 = 0.259;w22 = 0.061;
      w10 = 0.074;w11 = -1.375;w12 = 0.764;
  for p = 1:pmax   % Boucle passages
      for k = 3:N  % Boucle mesures
        % Calcul des sorties des couches cachées
        v1 = -w10 + w11*u(k-1) + w12*y(k-2);
        s1 = tanh(v1);
        v2 = -w20 + w21*u(k-1) + w22*y(k-2);
        s2 = tanh(v2);
        
        % Calcul de la sortie du réseau
        v = -w30 + w31*s1 + w32*s2;
        y1(k) = tanh(v);
        
        % Rétropropagation
        % Erreur de la couche de sortie
        df = (y(k) - y1(k)) * (1 - tanh(v)^2);
        
        % Mise à jour des poids de la couche de sortie
        dw30 = mu * df * (-1);
        dw31 = mu * df * s1;
        dw32 = mu * df * s2;
        
        % Rétropropagation vers la couche cachée
        % Pour le premier neurone caché
        delta1 = df * w31 * (1 - tanh(v1)^2);
        dw10 = mu * delta1 * (-1);
        dw11 = mu * delta1 * u(k-1);
        dw12 = mu * delta1 * y(k-2);
        
        % Pour le deuxième neurone caché
        df2 = df * w32 * (1 - tanh(v2)^2);
        dw20 = mu * df2 * (-1);
        dw21 = mu * df2 * u(k-1);
        dw22 = mu * df2 * y(k-2);
        
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
    Cr(i,p) = (y - y1)*(y - y1)'/N ;
    %Cr(p) = (y - y1) * (y - y1)';  % produit scalaire
  end
end
%save('C:\Users\user\Desktop\2AGE2\PFA2_AGE2\COMMANDE\Commande_Min_Variance\NN_3.mat','w30','w31','w32','w20','w21','w22','w10','w11','w12');

%% ----------- AFFICHAGES -----------
figure(1)
plot(Cr(1,:),'*r'); hold on
plot(Cr(2,:),'*b')
plot(Cr(3,:),'*g')
grid on
title('Convergence du critère Cr mu differentes')
xlabel('Nombre de passages')
ylabel('Critère Cr')
legend('\mu = 0.001','\mu = 0.01','\mu = 0.1')

%figure(2)
%plot(Cr, '*r')
%title('Evolution de la somme des erreurs au carré', 'fontsize', 16)
%grid on
%xlabel('Nombre de passages')
%ylabel('Critère Cr')

figure(2)
plot(y1, 'b')
hold on
plot(y, 'g')
grid on
title({'Evolutions de y(k) et de y1(k)';'0 < k < 51'}, 'fontsize', 16)
xlabel('Itération k')
ylabel('Sortie système et sortie modèle')
legend('y1(k)', 'y(k)')

figure(3)
plot(u, '-r')
title('Evolution de la commande')
grid on
xlabel('k')
ylabel('Commande')
