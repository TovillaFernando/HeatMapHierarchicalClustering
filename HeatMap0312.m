data = readtable('HeatMap.xlsx'); % Load input table from Excel file

variables = {'Area', 'Longitud', 'VelocidadNormalizada', 'LongitudDeOndaNormalizada', 'AmplitudDeOndaNormalizada', 'Coleteos'};
variableLabels = {'Área', 'Longitud', 'Velocidad normalizada', 'Longitud de onda normalizada', 'Amplitud de onda normalizada', 'Coleteos'}; % Variable labels for the heatmap

% Strains
cepas = {'N2', 'ATM1', 'CZ26389', 'ATM1xCZ26389'}; % Desired strain order (edit this list to match your dataset)

normalizedData = zeros(numel(cepas), numel(variables)); % Matrix to store normalized values

controlCepa = 'N2'; % Reference strain for normalization (change this to your desired control)
controlData = data(strcmp(data.Cepa, controlCepa), :); % Extract control rows

for i = 1:numel(cepas)
    cepaData = data(strcmp(data.Cepa, cepas{i}), :); % Extract rows for each strain
    for v = 1:numel(variables)
        % Compute log2 fold change relative to control
        normalizedData(i, v) = log2(mean(cepaData{:, variables{v}}) / mean(controlData{:, variables{v}}));
    end
end

distances = pdist(normalizedData, 'euclidean'); % Pairwise Euclidean distances
linkages = linkage(distances, 'average'); % Hierarchical clustering using average linkage

[~, dendrogramOrder] = ismember(cepas, cepas); % Maintain original order for labeling

nColors = 256; % Number of colors in gradient colormap

greenToRedColormap = [linspace(0, 1, nColors)', linspace(1, 0, nColors)', zeros(nColors, 1)]; % Custom green-to-red colormap

% Label strains for the plot (edit these to match your strain names or formatting)
cepaLabels = {'WT', ...
    '\it{-mctp-1}', ...     % Italic text for ATM1
    '\it{-esyt-2}', ...     % Italic text for CZ26389
    '-mctp-1/-esyt-2'};    % Combined genotype for ATM1xCZ26389

figure;

% Subplot 1: Dendrogram
subplot(1, 2, 1);
dendrogram(linkages, 'Labels', cepaLabels(dendrogramOrder), 'Orientation', 'left'); % Draw dendrogram
xlabel('Distancia Euclidiana'); % X-axis label
ylabel('Cepa'); % Y-axis label

% Subplot 2: Heatmap
subplot(1, 2, 2);
heatmap(variableLabels, cepaLabels, normalizedData(dendrogramOrder, :), ...
    'Colormap', greenToRedColormap, 'ColorLimits', [0, 0.5], 'CellLabelColor', 'none'); % Heatmap settings

colorbar; % Add color scale

