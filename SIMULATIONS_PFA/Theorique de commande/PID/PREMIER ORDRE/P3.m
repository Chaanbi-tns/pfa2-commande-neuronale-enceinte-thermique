clc;clear;close all;
%Les paramétres du correcteur
%c0=0.22;
%c1 =-0.20;%IL FAUT SAVOIR un tel c faire quoi 
%c2=0.00001;
%CE PROGRAMME ILLUSTRE L4APPLICATION DE LA COMMANDE PAR PID SUR LE SYSTEME
%DE PREMIER ORDRE DE PARAMETRES (Ks,T0)
%% ----------------------FONCTION DE TRANSFERT DU SYSTEME--------------------------
Ks=5;
T0=4;
Num_p=[Ks];
Den_p=[T0 1];
H=tf(Num_p,Den_p);
c0=0.22;
c1 =-0.20;%IL FAUT SAVOIR un tel c faire quoi 
c2=0.00001;<<
%% --------------------La TZ de H par C2d utilisant par défaut'zoh'
Te=T0/10;
N = 100;         % nombre d'échantillons
Hz=c2d(H,Te,'zoh');
[b,a]=tfdata(Hz,'v');
%% -----------------Initialisation------------------------
y_ref=[];
for k=1:N/2
   y_ref(k)=1;
end
for k=N/2+1:N
   y_ref(k)=2;
end
y(1) =0 ;y(2)=0
e(2)=0;e(1)=0;
u(2)=0;u(1)=0;
% --- Simulation de la réponse par équation récurrente ---
for k = 3:N
    %y(k) = -a1*y(k-1) - a2*y(k-2) + b0*y_ref(k) + b1*y_ref(k-1);
    y(k)=-a(2)*y(k-1)+b(2)*u(k-1);
    e(k)=y_ref(k)-y(k);
    u(k)=u(k-1)+c0*e(k)+c1*e(k-1)+c2*e(k-2);   
end
%%  --- Axe temporel ---
k = 0:N-1;
t = k * Te;
%% --- Tracé de la réponse ---
figure(1);
plot(y);
grid on;
title(['Reponse 1 ere ordre avec  PID pour (c1 = ', num2str(c1), ')']);
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


