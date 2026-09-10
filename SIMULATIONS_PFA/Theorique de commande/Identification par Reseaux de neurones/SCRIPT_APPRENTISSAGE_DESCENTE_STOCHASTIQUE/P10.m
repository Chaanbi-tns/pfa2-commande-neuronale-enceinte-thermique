clear all
close all
clc
%% LIRE CE COMMENTAIRE ICI POUR COMPRENDRE DE QUOI S'AGIT LE SCRIPT 
%Apprentissage 10 Neurones

%% ---------------Initialisation--------------------
mu = 0.1; % pas d’adaptation
pmax = 150;               % nombre maximal de passages
N =100;                  % nombre de mesures
W1=0.1*randn(10,2);     %Matrice poids entrante
b1=0.1*rand(10,1);       %vecteur biais à l'entrée
W2=0.1*randn(1,10);      %Matrice poids sortante
b2=0.1*randn;            %vecteur biais à la sortie
u=rand(1,N)-0.5;             %Mesure ancienne de la commande u(k)
n = 10;                       % nb de neurones cachés
y(1)=0;
y(2)=0;
%% ------------------Réponse du systéme---------------------
for k = 3:N
    a(k)=y(k-2);
    y(k) = -0.8 *a(k)*(u(k-1))^2/(1+(u(k-1))^2)+0.033*y(k-1)+0.5*u(k-1);
end
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
title({'Evolutions de la sortie du neurone y(k) et y(k)';'0 < k < 51'}, 'fontsize', 16)
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

