clear; clc; close all;
%% Paramètres
dt = 0.01;  T = 10;
t  = 0:dt:T;  Ns = length(t);
r  = ones(1,Ns);   % échelon unitaire
%% Système : G(s) = 1/(s+1)^2
Kp_vals = [0.5, 2, 5, 15];
colors  = {'b', 'k', 'g', 'r'};
figure('Color','w','Position',[100 100 700 400]);
plot(t, r, 'k--', 'LineWidth', 1.2); hold on;
for i = 1:length(Kp_vals)
    Kp = Kp_vals(i);
    y  = zeros(1,Ns);
    x  = [0;0];
    for k = 2:Ns
        e = r(k) - y(k-1);
        u = Kp * e;
        x = x + dt*[x(2); -2*x(2)-x(1)+u];
        y(k) = x(1);
    end
    plot(t, y, colors{i}, 'LineWidth', 1.5, ...
         'DisplayName', ['$K_p = ' num2str(Kp) '$']);
end
ylabel('$y(t)$','Interpreter','latex','FontSize',12);
xlabel('Temps (s)','FontSize',12);
legend('Consigne','Interpreter','latex','Location','southeast');
legend('Consigne $r(t)$', ...
       '$K_p = 0.5$','$K_p = 2$','$K_p = 5$','$K_p = 10$', ...
       'Interpreter','latex','Location','southeast');
title('Action proportionnelle : effet de $K_p$', ...
      'Interpreter','latex','FontSize',13);
grid on;