% Calculadora de Sólidos de Revolución 
clc; 
clear; 
close all;

disp('--- CÁLCULO DE VOLÚMENES DE REVOLUCIÓN ---');

% Solicitar datos para calcular las funciones
str_f1 = input('Ingresa la primera función en x (ej. x^2): ', 's');
str_f2 = input('Ingresa la segunda función en x (ej. 4): ', 's');
a = input('Límite inferior en x (ej. -2): ');
b = input('Límite superior en x (ej. 2): ');

% Pregunta el jee de rotacion para determinar el metodo de arandelas o
% cascarones 
disp(' ');
disp('¿Sobre qué tipo de eje va a girar el sólido?');
disp('  X -> Eje horizontal (ej. y = 0, y = 6)');
disp('  Y -> Eje vertical   (ej. x = 0, x = 3)');
tipo_eje = input('Elige X o Y: ', 's');
eje_val = input('Ingresa el valor de la constante del eje (ej. 0 para el eje principal): ');

%Preparar los textos para cálculo numérico y prevenir errores
str_f1 = lower(str_f1); % Convertir a minúsculas
str_f2 = lower(str_f2);
str_f1 = strrep(strrep(str_f1, 'y=', ''), 'y =', '');
str_f2 = strrep(strrep(str_f2, 'y=', ''), 'y =', '');

str_f1 = strrep(strrep(strrep(str_f1, '^', '.^'), '*', '.*'), '/', './');
str_f2 = strrep(strrep(strrep(str_f2, '^', '.^'), '*', '.*'), '/', './');

% Crea las funciones 
f1_temp = str2func(['@(x) ' str_f1]);
f2_temp = str2func(['@(x) ' str_f2]);

f1 = @(x) f1_temp(x) .* ones(size(x));
f2 = @(x) f2_temp(x) .* ones(size(x));

% Prepara la malla 3D para la construccion del solido
x_vals = linspace(a, b, 100);
theta = linspace(0, 2*pi, 60);
[X_malla, Theta] = meshgrid(x_vals, theta);

Y1_base = f1(x_vals);
Y2_base = f2(x_vals);
Y1_malla = repmat(Y1_base, length(theta), 1);
Y2_malla = repmat(Y2_base, length(theta), 1);

figure('Name', 'Sólido de Revolución', 'Color', 'w');
hold on; grid on;

% Elige el metodo dependiendo  del eje de rotacion
if strcmpi(tipo_eje, 'X')
    %% Giro horizontal arandelas
    disp('-> Calculando por Método de Arandelas...');
    integrando = @(x) abs((f1(x) - eje_val).^2 - (f2(x) - eje_val).^2);
    Volumen_Num = pi * integral(integrando, a, b);
    
    % Coordenadas 3D (Giro sobre Y y Z)
    Z1_3D = abs(Y1_malla - eje_val) .* sin(Theta);
    Y1_3D = eje_val + abs(Y1_malla - eje_val) .* cos(Theta);
    Z2_3D = abs(Y2_malla - eje_val) .* sin(Theta);
    Y2_3D = eje_val + abs(Y2_malla - eje_val) .* cos(Theta);
    
    % Graficar Superficies y Eje de Rotación
    surf(X_malla, Y1_3D, Z1_3D, 'FaceColor', 'b', 'EdgeColor', 'none', 'FaceAlpha', 0.5);
    surf(X_malla, Y2_3D, Z2_3D, 'FaceColor', 'r', 'EdgeColor', 'none', 'FaceAlpha', 0.8);
    plot3([a, b], [eje_val, eje_val], [0, 0], 'k--', 'LineWidth', 2);
    title(sprintf('Giro Horizontal en y = %g', eje_val));

elseif strcmpi(tipo_eje, 'Y')
    %% GIRO VERTICAL Método de Cascarones Cilíndricos
    disp('-> Calculando por Método de Cascarones...');
    integrando = @(x) 2 * pi * abs(x - eje_val) .* abs(f1(x) - f2(x));
    Volumen_Num = integral(integrando, a, b);
    
    %Coordenadas 3D (Giro sobre X y Z)
    % La altura en Y se mantiene igual a la función
    Z1_3D = abs(X_malla - eje_val) .* sin(Theta);
    X1_3D = eje_val + abs(X_malla - eje_val) .* cos(Theta);
    
    Z2_3D = abs(X_malla - eje_val) .* sin(Theta);
    X2_3D = eje_val + abs(X_malla - eje_val) .* cos(Theta);
    
    % Graficar Superficies y Eje de Rotación
    surf(X1_3D, Y1_malla, Z1_3D, 'FaceColor', 'b', 'EdgeColor', 'none', 'FaceAlpha', 0.5);
    surf(X2_3D, Y2_malla, Z2_3D, 'FaceColor', 'r', 'EdgeColor', 'none', 'FaceAlpha', 0.8);
    
    % Eje de rotación 
    max_y = max(max(max(Y1_malla)), max(max(Y2_malla)));
    min_y = min(min(min(Y1_malla)), min(min(Y2_malla)));
    plot3([eje_val, eje_val], [min_y, max_y], [0, 0], 'k--', 'LineWidth', 2);
    title(sprintf('Giro Vertical en x = %g', eje_val));
    
else
    disp('Error: Debes elegir X o Y.');
    Volumen_Num = 0;
end

% Grafica y resultados
if Volumen_Num > 0
    view(3);
    camlight; lighting gouraud;
    xlabel('Eje X'); ylabel('Eje Y'); zlabel('Eje Z');
    hold off;
    
    fprintf('\n--- RESULTADOS ---\n');
    fprintf('Volumen calculado: %.4f unidades cúbicas\n\n', Volumen_Num);
end