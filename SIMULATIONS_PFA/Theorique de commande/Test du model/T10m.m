clear all
close all
clc
%% LIRE CE COMMENTAIRE ICI POUR COMPRENDRE DE QUOI S'AGIT LE SCRIPT 
%Test sur reseaux 10 NEURONES

%% ---------------Initialisation--------------------
mu = 0.1; % pas d’adaptation
pmax = 500;               % nombre maximal de passages
N =200;                  % nombre de mesures
W1=0.1*randn(10,2);     %Matrice poids entrante
b1=0.1*rand(10,1);       %vecteur biais à l'entrée
W2=0.1*randn(1,10);      %Matrice poids sortante
b2=0.1*randn;            %vecteur biais à la sortie
u=0.8*(rand(1,N)-0.5);             %Mesure ancienne de la commande u(k)
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
    Cr(p) = (y - y1) * (y - y1)'/N;  
end

%% ----------- AFFICHAGES -----------
%% Convergence de critere
figure(1)
plot(Cr, '*r')
title('Cr pour BGD de MLP-10', 'fontsize', 16)
grid on
xlabel('Nombre de passages')
ylabel('Critère Cr-MLP-10')
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
%%  commande
figure(3)
plot(u, 'r')
grid on
title({'Evolution de la commande'}, 'fontsize', 16)
xlabel('Itération k')
ylabel('Sortie système et sortie modèle')
legend('u(k)')

%% =============== Test =================
Ntest = 100;                 % nombre d'échantillons de test
u_test = 0.5*(rand(1,Ntest)-0.5);  % nouvelle commande (non vue en apprentissage)

y_test(1)=0;
y_test(2)=0;
y1_test(1)=0;
y1_test(2)=0;

%% Réponse réelle du système (validation)
for k = 3:Ntest
    a_test(k)=y_test(k-2);
    y_test(k) = -0.8 * a_test(k) * (u_test(k-1))^2 / (1 + (u_test(k-1))^2) ...
                + 0.033*y_test(k-1) + 0.5*u_test(k-1);
end

%% Réponse du réseau (sans apprentissage)
for k = 3:Ntest
    % vecteur d'entrée
    X_test = [y_test(k-1); u_test(k-1)];
    
    % propagation avant uniquement
    V1_test = W1*X_test - b1;
    S1_test = tanh(V1_test);
    V2_test = W2*S1_test - b2;
    y1_test(k) = tanh(V2_test);
end

%% Critère d'erreur de validation
Cr_test = (y_test - y1_test)*(y_test - y1_test)'/Ntest;
disp(['Erreur_Fin_Test = ', num2str(Cr_test)])
figure(4)
plot(y_test,'g--')
hold on
plot(y1_test,'b--')
grid on
title('sortie système vs sortie réseau','fontsize',14)
xlabel('Itération k')
ylabel('Sortie')
legend('y_{test}(k)','y1_{test}(k)')
