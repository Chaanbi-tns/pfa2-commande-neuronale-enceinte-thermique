clear; clc; close all;

%% Paramètres
Kp = 2;  Kd = 0.8;  N = 20;
dt = 0.01;  T = 5;
t  = 0:dt:T;  Ns = length(t);

% Consigne + bruit
r      = ones(1,Ns);
bruit  = 0.05 * randn(1,Ns);
r_b    = r + bruit;

%% Système : G(s) = 1/(s+1)^2 ? espace d'état
% dx1 = x2
% dx2 = -2x2 - x1 + u

%% Sans filtre
y1 = zeros(1,Ns);  x1 = [0;0];
for k = 2:Ns
    e  = r_b(k)   - y1(k-1);
    ep = r_b(k-1) - y1(k-1);
    u  = Kp*e + Kd*(e-ep)/dt;
    u  = max(-10, min(10, u));
    x1 = x1 + dt*[x1(2); -2*x1(2)-x1(1)+u];
    y1(k) = x1(1);
end

%% Avec filtre dérivée : df = (1-N*dt)*df + N*(e-ep)
y2 = zeros(1,Ns);  x2 = [0;0];  df = 0;
for k = 2:Ns
    e  = r_b(k)   - y2(k-1);
    ep = r_b(k-1) - y2(k-1);
    df = (1-N*dt)*df + N*(e-ep);
    u  = Kp*e + Kd*df;
    u  = max(-10, min(10, u));
    x2 = x2 + dt*[x2(2); -2*x2(2)-x2(1)+u];
    y2(k) = x2(1);
end

%% Figure
figure('Color','w','Position',[100 100 700 500]);

subplot(2,1,1);
plot(t, r,  'k--', 'LineWidth',1.2); hold on;
plot(t, y1, 'k-',  'LineWidth',1.5);
plot(t, y2, 'b-',  'LineWidth',1.5);
ylabel('$y(t)$','Interpreter','latex','FontSize',12);
legend('Consigne','Sans filtre','Avec filtre',...
       'Interpreter','latex','Location','southeast');
title('Action dérivée : avec / sans filtre passe-bas','FontSize',12);
grid on;

subplot(2,1,2);
% recalculer u1 et u2 proprement
u1_log = zeros(1,Ns);
u2_log = zeros(1,Ns);
x1 = [0;0]; x2 = [0;0]; df = 0;
y1b = zeros(1,Ns); y2b = zeros(1,Ns);

for k = 2:Ns
    e  = r_b(k)   - y1b(k-1);
    ep = r_b(k-1) - y1b(k-1);
    u  = Kp*e + Kd*(e-ep)/dt;
    u1_log(k) = max(-10, min(10, u));
    x1 = x1 + dt*[x1(2); -2*x1(2)-x1(1)+u1_log(k)];
    y1b(k) = x1(1);

    e  = r_b(k)   - y2b(k-1);
    ep = r_b(k-1) - y2b(k-1);
    df = (1-N*dt)*df + N*(e-ep);
    u  = Kp*e + Kd*df;
    u2_log(k) = max(-10, min(10, u));
    x2 = x2 + dt*[x2(2); -2*x2(2)-x2(1)+u2_log(k)];
    y2b(k) = x2(1);
end

plot(t, u1_log, 'r-',  'LineWidth', 1.0); hold on;
plot(t, u2_log, 'k-.', 'LineWidth', 1.5);
ylabel('$u(t)$','Interpreter','latex','FontSize',12);
xlabel('Temps (s)','FontSize',12);
legend('Sans filtre (bruitée)','Avec filtre (lissée)',...
       'Interpreter','latex','Location','northeast');
title('Commande $u(t)$ : effet du bruit sur l''action dérivée','Interpreter','latex','FontSize',12);
grid on;