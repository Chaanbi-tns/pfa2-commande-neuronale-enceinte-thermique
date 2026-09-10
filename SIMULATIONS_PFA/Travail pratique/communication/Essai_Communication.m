fid = fopen('Data_communication.txt','r');

k = [];
T = [];
P = [];

line = fgetl(fid); % ignorer header

while ischar(line)
    
    line = fgetl(fid);
    
    if ischar(line)
        data = sscanf(line, '%d T=%f P=%f');
        
        if length(data) == 3
            k(end+1) = data(1);
            T(end+1) = data(2);
            P(end+1) = data(3);
        end
    end
end

fclose(fid);

% ? Consigne (même taille que k)
yc = 40 * ones(size(k));   % initialisation à 40

yc(k > 2000) = 50;         % après 2000 ? 50

% ? si tu veux changer à 50 après un certain point :
% yc(k > 1000) = 50;

disp([k' T' P'])

figure;

subplot(2,1,1)
plot(k, T,'LineWidth',2)
hold on
plot(k, yc,'r--','LineWidth',2)
title('Température T(k)')
xlabel('k'); ylabel('T')
legend('T(k)','Consigne')

subplot(2,1,2)
plot(k, P,'LineWidth',2)
title('Puissance P(k)')
xlabel('k'); ylabel('P')