clc; clear; close all;
% ============================================
% CE PROGRAMME ILLUSTRE L'APPLICATION DE LA COMMANDE pi SUR UN SYSTEME DE
 %DEUXIEME ORDRE DE PARAMETRES(Ks,xi,w0),Ks ETANT LE GAIN,xi LE COEFFICIENT
 %D'AMMORTISSEMENT ET w0 LA PULSATION PROPRE DE SYSTEME
% C(z) = c1 * (z + 1) / (z - 1)
% Système : G(z) = 2z^-1/ (1 - 0.9048 z^-1)
% ============================================


%% --- Paramètres du système ---
%a = -0.9048;      % pôle du système discret
Te = 0.4;        % période d'échantillonnage (s)
N = 100;         % nombre d'échantillons
Ks=5;
xi=0.5;
w0=4;
Den=[1 2*xi*w0 w0^2];
Num=[Ks*w0^2];
H=tf(Num,Den);
%% step(H);
Gz=c2d(H,Te,'zoh');
[b, a] = tfdata(Gz, 'v');
%% --- Correcteur PI ---
c1 =4;      % à modifier pour tester d'autres valeurs 
c0=1;
%Le systéme est stable pour les valeurs positifs de c1

% --- Entrée : échelon unitaire ---
y_ref=[];
for k=1:N/2
    y_ref(k)=1;
end
for k=N/2+1:N
    y_ref(k)=2;
end

y(1) =0 ;y(2)=0;
e(2)=0;e(1)=0;
u(2)=0;u(1)=0;
%% --- EQUATION RECCURENTE DU SYSTEME ---
for k = 3:N
    y(k) = -a(2)*y(k-1) - a(3)*y(k-2) + b(2)*u(k-1) + b(3)*u(k-2);
    e(k)=y_ref(k)-y(k);
    u(k)=u(k-1)+c0*e(k)+c1*e(k-1); 
    
    
end

%% --- Axe temporel ---
k = 0:N-1;
t = k * Te;

%%  --- Tracé de la réponse ---
figure(1);
plot(y);
grid on;
title(['Reponse 2 eme ordre avec  PI pour (c1 = ', num2str(c1), ') et c0 = ', num2str(c0), ')']);
xlabel('Temps (s)');
ylabel('Amplitude');
hold on;
plot(y_ref);
figure(2);
plot(u);

