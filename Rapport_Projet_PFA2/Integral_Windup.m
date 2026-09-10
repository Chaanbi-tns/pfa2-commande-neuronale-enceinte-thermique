% ============================================================
%  Integral Windup - Démonstration simple
%  Système : G(s) = 1/(s+1)^2   |   PID avec saturation
% ============================================================

clear; clc; close all;

%% ?? Paramètres ??????????????????????????????????????????????
Kp = 5;   Ki = 3;   Kd = 0.5;
umax =  1.5;   % saturation actuateur
umin = -1.5;

dt = 0.01;
T  = 20;
t  = 0:dt:T;
N  = length(t);

r  = ones(1,N);   % échelon unitaire

%% ?? Simulation AVEC windup ???????????????????????????????????
y1 = zeros(1,N);  u1 = zeros(1,N);
e1 = zeros(1,N);  I1 = zeros(1,N);
x1 = [0;0];  % états système (2nd ordre)

for k = 2:N
    e1(k)   = r(k) - y1(k-1);
    de      = (e1(k) - e1(k-1)) / dt;
    I1(k)   = I1(k-1) + e1(k)*dt;          % intégrale NON limitée
    u_raw   = Kp*e1(k) + Ki*I1(k) + Kd*de;
    u1(k)   = max(umin, min(umax, u_raw));  % saturation commande seule

    % système G(s)=1/(s+1)^2  ?  espace d'état
    dx      = [x1(2) ; -2*x1(2) - x1(1) + u1(k)];
    x1      = x1 + dx*dt;
    y1(k)   = x1(1);
end

%% ?? Simulation SANS windup (anti-windup simple) ??????????????
y2 = zeros(1,N);  u2 = zeros(1,N);
e2 = zeros(1,N);  I2 = zeros(1,N);
x2 = [0;0];

for k = 2:N
    e2(k)   = r(k) - y2(k-1);
    de      = (e2(k) - e2(k-1)) / dt;
    u_raw   = Kp*e2(k) + Ki*I2(k) + Kd*de;
    u_sat   = max(umin, min(umax, u_raw));

    % intégrale gelée si saturée (anti-windup)
    if u_raw == u_sat
        I2(k) = I2(k-1) + e2(k)*dt;
    else
        I2(k) = I2(k-1);
    end

    u2(k)   = u_sat;
    dx      = [x2(2) ; -2*x2(2) - x2(1) + u2(k)];
    x2      = x2 + dx*dt;
    y2(k)   = x2(1);
end

%% ?? Figure ???????????????????????????????????????????????????
figure('Color','w', 'Position',[100 100 800 600]);

% ?? Subplot 1 : Sortie ???????????????????????????????????????
subplot(3,1,1);
plot(t, r,  'k--',       'LineWidth', 1.2); hold on;
plot(t, y1, 'k-',        'LineWidth', 1.5);
plot(t, y2, 'k-.',       'LineWidth', 1.5);
ylabel('$y(t)$','Interpreter','latex','FontSize',12);
legend('Consigne $r(t)$','Avec windup','Sans windup', ...
       'Interpreter','latex','Location','southeast');
title('Phénomène d''integral windup','FontSize',13);
grid on; ylim([-0.2 2.0]);

% ?? Subplot 2 : Intégrale accumulée ??????????????????????????
subplot(3,1,2);
plot(t, I1, 'k-',  'LineWidth', 1.5); hold on;
plot(t, I2, 'k-.', 'LineWidth', 1.5);
ylabel('$I(t)$','Interpreter','latex','FontSize',12);
legend('Intégrale avec windup','Intégrale sans windup', ...
       'Interpreter','latex','Location','northeast');
grid on;

% ?? Subplot 3 : Commande ?????????????????????????????????????
subplot(3,1,3);
plot(t, u1,           'k-',  'LineWidth', 1.5); hold on;
plot(t, u2,           'k-.', 'LineWidth', 1.5);
yline(umax, 'k:',  '$u_{\max}$', 'Interpreter','latex', ...
      'LabelHorizontalAlignment','left','FontSize',11);
yline(umin, 'k:',  '$u_{\min}$', 'Interpreter','latex', ...
      'LabelHorizontalAlignment','left','FontSize',11);
ylabel('$u(t)$','Interpreter','latex','FontSize',12);
xlabel('Temps (s)','FontSize',12);
legend('Commande avec windup','Commande sans windup', ...
       'Interpreter','latex','Location','northeast');
grid on; ylim([-2.5 2.5]);