clc;clear;close all;
%% Comment Utuliser ce script 
%CE PROGRAMME ILLUSTRE L'APPLICATION DE LA COMMANDE PID SUR UN SYSTEME DE
%DEUXIEME ORDRE DE PARAMETRES(Ks,xi,w0),Ks ETANT LE GAIN,xi LE COEFFICIENT
%D'AMMORTISSEMENT ET w0 LA PULSATION PROPRE DE SYSTEME
%% ==================%%
%% Les paramétres du correcteur
c0=15;
c1 =1; 
c2=1;
%% ----------------------Reponse en continue--------------------------
Ks=5;%Gain statique
w0=20;%pulsation propre
xi=0.5;%amortissement
Num_p=[Ks];
Den_p=[1 2*xi*w0 w0^2];%La fonction de transfert du systéme à commander
H=tf(Num_p,Den_p);%La réponse indicielle du systéme en boucle ouverte à simuler
step(H);
%% --------------------La TZ de H par C2d utilisant par défaut'zoh'
Te=0.36;%Période d'échantillonnage pour le bloqueur d'ordre 0
N = 100;         % nombre d'échantillons
Hz=c2d(H,Te,'zoh');
[b,a]=tfdata(Hz,'v');%Récupération des polynomé de la forme discréte de H
%% -----------------Initialisation------------------------
y_ref = [ones(1,N/2) 2*ones(1,N/2)];%Consigne 
y(1) = 0; y(2) = 0;
e(1) = y_ref(1) - y(1);
e(2) = y_ref(2) - y(2);
u(1) = 0; u(2) = 0;
%%  --- Simulation de la réponse par équation récurrente ---
for k = 3:N
    y(k) = -a(2)*y(k-1) - a(3)*y(k-2) + b(2)*u(k-1) + b(3)*u(k-2);
    e(k)=y_ref(k)-y(k);
    u(k)=u(k-1)+c0*e(k)+c1*e(k-1)+c2*e(k-2); 
end
%%  --- Axe temporel ---
k = 0:N-1;
t = k * Te;
%%  --- Tracé de la réponse ---
figure(1);
plot(y);
grid on;
title(['Reponse 2 ere ordre avec  PID pour (c1 = ', num2str(c1), ')']);
xlabel('Temps (s)');
ylabel('Amplitude');
hold on;
plot(y_ref);
legend("Reponse du systéme","Signal de référence");
figure(2);
plot(u,'g');
legend("Signal de commande");
grid on;
title(['Signal de commande u corrigé PID (c1 = ', num2str(c1), ')']);
xlabel('Temps (s)');
ylabel('Amplitude');


