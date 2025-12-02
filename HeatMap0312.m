data = readtable('HeatMap.xlsx'); %Table name

variables = {'Area', 'Longitud', 'VelocidadNormalizada', 'LongitudDeOndaNormalizada', 'AmplitudDeOndaNormalizada', 'Coleteos'};
variableLabels = {'Área', 'Longitud', 'Velocidad normalizada', 'Longitud de onda normalizada', 'Amplitud de onda normalizada', 'Coleteos'}; % Nuevas etiquetas

% Strains
cepas = {'N2', 'ATM1', 'CZ26389', 'ATM1xCZ26389'}; % Orden deseado

normalizedData = zeros(numel(cepas), numel(variables));

controlCepa = 'N2';
controlData = data(strcmp(data.Cepa, controlCepa), :);

for i = 1:numel(cepas)
    cepaData = data(strcmp(data.Cepa, cepas{i}), :);
    for v = 1:numel(variables)
        normalizedData(i, v) = log2(mean(cepaData{:, variables{v}}) / mean(controlData{:, variables{v}}));
    end
end

distances = pdist(normalizedData, 'euclidean');
linkages = linkage(distances, 'average');

[~, dendrogramOrder] = ismember(cepas, cepas);

nColors = 256;

greenToRedColormap = [linspace(0, 1, nColors)', linspace(1, 0, nColors)', zeros(nColors, 1)];

% Label strains
cepaLabels = {'WT', ...
    '\it{-mctp-1}', ...     % En cursiva para ATM1
    '\it{-esyt-2}', ...     % En cursiva para CZ26389
    '-mctp-1/-esyt-2'};    % Para ATM1xCZ26389

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

colorbar;

