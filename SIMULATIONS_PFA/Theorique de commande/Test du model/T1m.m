clear all
close all
clc

%% ================================================================
%  IDENTIFICATION NEURONALE - 1 NEURONE (BGD corrigé)
%  Système non linéaire :
%  y(k) = -0.8*y(k-2)*u(k-1)^2/(1+u(k-1)^2) + 0.033*y(k-1) + 0.5*u(k-1)
%% ================================================================

%% ---------- Paramètres ----------
pmax = 500;       % nombre de passages (époques)
N    = 200;       % nombre d'échantillons
mu   = 0.1;       % pas d'apprentissage

% Initialisation des poids
w0 =  0.5;
w1 = -0.1;
w2 =  0.1;

%% ---------- Commande aléatoire ----------
u = 0.8*(rand(1,N) - 0.5);

%% ---------- Réponse du système ----------
y = zeros(1,N);
for k = 3:N
    y(k) = -0.8*y(k-2)*(u(k-1))^2 / (1+(u(k-1))^2) ...
           + 0.033*y(k-1) ...
           + 0.5*u(k-1);
end

%% ---------- Initialisation sortie réseau ----------
y1 = zeros(1,N);
Cr = zeros(1,pmax);

%% ================================================================
%  ALGORITHME BGD (Batch Gradient Descent)
%% ================================================================
for p = 1:pmax

    %% -- Propagation avant (forward pass) sur toutes les données --
    for k = 3:N
        v     = -w0 + w1*u(k-1) + w2*y(k-1);
        y1(k) = tanh(v);
    end

    %% -- Critère global --
    Cr(p) = sum((y(3:N) - y1(3:N)).^2) / N;

    %% -- Calcul du gradient batch --
    grad_w0 = 0;
    grad_w1 = 0;
    grad_w2 = 0;

    for k = 3:N
        v   = -w0 + w1*u(k-1) + w2*y(k-1);
        df  = 1 - tanh(v)^2;          % dérivée de tanh
        err = y(k) - y1(k);           % erreur

        grad_w0 = grad_w0 + err * df * (-1);      % ?J/?w0
        grad_w1 = grad_w1 + err * df * u(k-1);    % ?J/?w1  (CORRIGÉ)
        grad_w2 = grad_w2 + err * df * y(k-1);    % ?J/?w2
    end

    %% -- Mise à jour des poids (une seule fois par époque) --
    w0 = w0 + (mu/N) * grad_w0;
    w1 = w1 + (mu/N) * grad_w1;
    w2 = w2 + (mu/N) * grad_w2;

end

%% ---------- Affichage des poids identifiés ----------
fprintf('\n=== Poids identifiés ===\n')
fprintf('w0 = %.4f\n', w0)
fprintf('w1 = %.4f\n', w1)
fprintf('w2 = %.4f\n', w2)
fprintf('Cr final (apprentissage) = %.6f\n', Cr(end))

%% ================================================================
%  AFFICHAGES - PHASE D'APPRENTISSAGE
%% ================================================================

%% Figure 1 : Convergence du critère
figure(1)
plot(Cr, '*r', 'MarkerSize', 4)
title('Convergence du critère C_r (BGD)', 'FontSize', 14)
xlabel('Nombre de passages')
ylabel('Critère C_r')
grid on

%% Figure 2 : Sortie système vs sortie modèle
figure(2)
plot(y,  'g', 'LineWidth', 1.5)
hold on
plot(y1, 'b', 'LineWidth', 1.5)
grid on
title({'Évolutions de y(k) et y1(k)'; 'Phase d''apprentissage'}, ...
      'FontSize', 14)
xlabel('Itération k')
ylabel('Sortie')
legend('y(k)','y1(k)')
%% Figure 3 : Commande appliquée
figure(3)
plot(u, 'r')
grid on
title('Commande aléatoire u(k)', 'FontSize', 14)
xlabel('Itération k')
ylabel('u(k)')
legend('u(k)')

%% ================================================================
%  PHASE DE TEST / VALIDATION
%% ================================================================

Ntest    = 100;
u_test   = 0.5*(rand(1,Ntest) - 0.5);   % commande non vue
y_test   = zeros(1,Ntest);
y1_test  = zeros(1,Ntest);

%% -- Réponse réelle du système (validation) --
for k = 3:Ntest
    y_test(k) = -0.8*y_test(k-2)*(u_test(k-1))^2 / (1+(u_test(k-1))^2) ...
                + 0.033*y_test(k-1) ...
                + 0.5*u_test(k-1);
end

%% -- Réponse du modèle (poids figés) --
for k = 3:Ntest
    v_test      = -w0 + w1*u_test(k-1) + w2*y_test(k-1);
    y1_test(k)  = tanh(v_test);
end

%% -- Critère de validation --
Cr_test = sum((y_test(3:end) - y1_test(3:end)).^2) / Ntest;
fprintf('\nErreur fin_test = %.6f\n', Cr_test)

%% Figure 4 : Validation
figure(4)
plot(y_test,  'g')
hold on
plot(y1_test, 'b')
grid on
title('Phase de validation : système vs modèle', 'FontSize', 14)
xlabel('Itération k')
ylabel('Sortie')
legend('y_t(k)')

%% ================================================================
%  COMPARAISON mu (optionnel - décommenter pour tester)
%% ================================================================
% mu_list = [0.001, 0.01, 0.1];
% colors  = {'r','b','g'};
% figure(5); hold on; grid on
% title('Convergence C_r pour différents \mu','FontSize',14)
% xlabel('Passages'); ylabel('C_r')
% 
% for idx = 1:length(mu_list)
%     mu_i = mu_list(idx);
%     w0_i= 0.5; w1_i=-0.1; w2_i=0.1;
%     Cr_i = zeros(1,pmax);
%     y1_i = zeros(1,N);
%     for p = 1:pmax
%         for k=3:N
%             v=?w0_i+w1_i*u(k-1)+w2_i*y(k-1);
%             y1_i(k)=tanh(v);
%         end
%         Cr_i(p)=sum((y(3:N)-y1_i(3:N)).^2)/N;
%         g0=0;g1=0;g2=0;
%         for k=3:N
%             v=?w0_i+w1_i*u(k-1)+w2_i*y(k-1);
%             df=1-tanh(v)^2; e=y(k)-y1_i(k);
%             g0=g0+e*df*(-1);
%             g1=g1+e*df*u(k-1);
%             g2=g2+e*df*y(k-1);
%         end
%         w0_i=w0_i+(mu_i/N)*g0;
%         w1_i=w1_i+(mu_i/N)*g1;
%         w2_i=w2_i+(mu_i/N)*g2;
%     end
%     plot(Cr_i,'*','Color',colors{idx},'MarkerSize',3,...
%          'DisplayName',['\mu = ',num2str(mu_i)])
% end
% legend show