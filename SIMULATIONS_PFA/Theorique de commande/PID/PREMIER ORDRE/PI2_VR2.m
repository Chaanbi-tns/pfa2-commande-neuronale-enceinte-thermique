% ============================================
% DANS CE PROGRAMME ON IMPLEMENTE DIRECTEMENT L'EQUATION RECCURRENTE DE
% Y(k),ALORS QU'ON PASSE DANS P2 PAR LA METHODE "tf" PUIS "C2d"
% ============================================

clc; clear; close all;

%%  --- Paramètres du système ---
a = -0.9048;      % pôle du système discret
b0=2;
Te = 0.5;        % période d'échantillonnage (s)
N = 100;         % nombre d'échantillons
% --- Correcteur PI ---
c1 =-0.04;      % à modifier pour tester d'autres valeurs 
c0=0.08;
%Le systéme est stable pour les valeurs positifs de c1
%% --- Coefficients du polynôme caractéristique ---
% --- Entrée : échelon unitaire ---
y_ref=[];
for k=1:N/2
    y_ref(k)=1;
end
for k=N/2+1:N
    y_ref(k)=2;
end
y(1) =0 ;
e(2)=0;e(1)=0;
u(2)=0;u(1)=0;
%%  --- Simulation de la réponse par équation récurrente ---
for k = 2:N
    %y(k) = -a1*y(k-1) - a2*y(k-2) + b0*y_ref(k) + b1*y_ref(k-1);
    y(k)=-a*y(k-1)+b0*u(k-1);
    e(k)=y_ref(k)-y(k);
    u(k)=u(k-1)+c0*e(k)+c1*e(k-1); 
    
    
end
% --- Axe temporel ---
k = 0:N-1;
t = k * Te;

% --- Tracé de la réponse ---
figure(1);
plot(y);
grid on;
title(['Reponse 1 ere ordre avec  PI pour (c1 = ', num2str(c1), ')']);
xlabel('Temps (s)');
ylabel('Amplitude');
hold on;
plot(y_ref);
legend("Reponse du systéme","Signal de référence");
figure(2);
plot(u);
grid on;
title(['Signal de commande u corrigé PI (c1 = ', num2str(c1), ')']);
xlabel('Temps (s)');
ylabel('Amplitude');
