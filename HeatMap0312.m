% Cargar datos desde el archivo Excel
data = readtable('HeatMap.xlsx'); % Reemplaza con tu archivo

% Definir las variables biomecánicas con sus nuevas etiquetas
variables = {'Area', 'Longitud', 'VelocidadNormalizada', 'LongitudDeOndaNormalizada', 'AmplitudDeOndaNormalizada', 'Coleteos'};
variableLabels = {'Área', 'Longitud', 'Velocidad normalizada', 'Longitud de onda normalizada', 'Amplitud de onda normalizada', 'Coleteos'}; % Nuevas etiquetas

cepas = {'N2', 'ATM1', 'CZ26389', 'ATM1xCZ26389'}; % Orden deseado

% Matriz para datos normalizados
normalizedData = zeros(numel(cepas), numel(variables));

% Normalizar todas las cepas respecto a N2
controlCepa = 'N2';
controlData = data(strcmp(data.Cepa, controlCepa), :);

for i = 1:numel(cepas)
    cepaData = data(strcmp(data.Cepa, cepas{i}), :);
    for v = 1:numel(variables)
        normalizedData(i, v) = log2(mean(cepaData{:, variables{v}}) / mean(controlData{:, variables{v}}));
    end
end

% Clustering jerárquico
distances = pdist(normalizedData, 'euclidean'); % Distancias euclidianas
linkages = linkage(distances, 'average'); % Agrupamiento promedio

% Reordenar el dendrograma y el mapa de calor al mismo orden
[~, dendrogramOrder] = ismember(cepas, cepas); % Asegurar orden fijo

% Crear un mapa de calor con un colormap que va de verde a rojo
nColors = 256; % Aumentar la cantidad de niveles para mayor gradualidad

% Colormap de verde a rojo
greenToRedColormap = [linspace(0, 1, nColors)', linspace(1, 0, nColors)', zeros(nColors, 1)];

% Etiquetas personalizadas para las cepas
cepaLabels = {'WT', ...
    '\it{-mctp-1}', ...     % En cursiva para ATM1
    '\it{-esyt-2}', ...     % En cursiva para CZ26389
    '-mctp-1/-esyt-2'};    % Para ATM1xCZ26389

% Representar dendrograma y heatmap en la misma figura
figure;

% Subplot 1: Dendrograma
subplot(1, 2, 1);
dendrogram(linkages, 'Labels', cepaLabels(dendrogramOrder), 'Orientation', 'left');
xlabel('Distancia Euclidiana');
ylabel('Cepa');

% Subplot 2: Heatmap
subplot(1, 2, 2);
heatmap(variableLabels, cepaLabels, normalizedData(dendrogramOrder, :), ...
    'Colormap', greenToRedColormap, 'ColorLimits', [0, 0.5], 'CellLabelColor', 'none');

% Eliminar el título en el mapa de calor
% title('Mapa de calor de parámetros normalizados'); % Esta línea ha sido eliminada
colorbar;