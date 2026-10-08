clc
clear
fprintf('\nPoints 1-2\n\n');

% 1. File cleaning
file = fileread('Anna_Karenina.txt');           %Read file
file = regexprep(lower(file), '[^a-z ]', '');   %Lowering
file = regexprep(file, '\s+', ' ');             %Cleaning
N = length(file);
alphabet = ['a':'z', ' '];

% 2. Single character entropy
char_prob = zeros(1, 27);
for i = 1:27
    char_prob(i) = sum(file == alphabet(i)) / N;
end
H1 = shannon(char_prob);

% Track max and min for single characters
max_contrib1 = -inf; 
min_contrib1 = inf;
char_max_contrib1 = ''; 
char_min_contrib1 = '';

max_info1 = -inf; 
min_info1 = inf;
char_max_info1 = ''; 
char_min_info1 = '';

% --- Char by cha entropy ---
fprintf('Entropy for each single character\n');
fprintf('Character | Probability | Information | Contribution to H1\n');
fprintf('--------------------------------------------------------\n');
for i = 1:27
    if char_prob(i) > 0
        info = -log2(char_prob(i));           % Amount of information of the single symbol
        contrib = char_prob(i) * info;        % Weighted contribution to total entropy H1
        
        % Formatting the output
        if alphabet(i) == ' '
            char_str = '[]';
        else
            char_str = sprintf('   %c     ', alphabet(i));
        end
        
        fprintf('%s |   %.5f    |      %.5f |    %.5f\n', char_str, char_prob(i), info, contrib);
        
        % Check max/min Contribution to H1
        if contrib > max_contrib1
            max_contrib1 = contrib;
            char_max_contrib1 = strtrim(char_str);
        end

        if contrib < min_contrib1
            min_contrib1 = contrib;
            char_min_contrib1 = strtrim(char_str);
        end
        
        % Check max/min Information
        if info > max_info1
            max_info1 = info;
            char_max_info1 = strtrim(char_str);
        end

        if info < min_info1
            min_info1 = info;
            char_min_info1 = strtrim(char_str);
        end
    end
end

fprintf('\nH1: %.4f\n', H1);

fprintf(['Max Contribution to H1: %s (%.4f bits) | ' ...
         'Min Information: %s (%.2f bits)\n'], ...
         char_max_contrib1, max_contrib1, ...
         char_min_info1, min_info1);

fprintf(['Min Contribution to H1: %s (%.4f bits) | ' ...
         'Max Information: %s (%.2f bits)\n'], ...
         char_min_contrib1, min_contrib1, ...
         char_max_info1, max_info1);

fprintf('--------------------------------------------------------\n');
fprintf('--------------------------------------------------------\n');


% --- BAR CHART ---

char_labels = string(alphabet(:));
char_labels(27) = "_"; 

% Entropy per character
contrib1 = zeros(1, 27);
idx = char_prob > 0;
contrib1(idx) = char_prob(idx) .* -log2(char_prob(idx));

[p1_sorted, sort_idx] = sort(char_prob, 'descend');
contrib1_sorted = contrib1(sort_idx);
char_labels_sorted = char_labels(sort_idx);

% Graph p(x_i)
fig_h1 = figure();

subplot(2, 1, 1);

bar(1:27, p1_sorted, ...
    'FaceColor', [0.2 0.5 0.8], ...
    'EdgeColor', 'k');

xticks(1:27);
xticklabels(char_labels_sorted);

ylabel('Probability p(x_i)', ...
       'FontWeight', 'bold');

title('Single-Symbol Probability Distribution', ...
      'FontSize', 14, ...
      'FontWeight', 'bold');

grid on;

set(gca, ...
    'FontSize', 11, ...
    'FontName', 'Consolas', ...
    'TickDir', 'out');


% Graph Entropy
subplot(2, 1, 2);

bar(1:27, contrib1_sorted, ...
    'FaceColor', [0.8 0.4 0.2], ...
    'EdgeColor', 'k');

xticks(1:27);
xticklabels(char_labels_sorted);

xlabel('Alphabet Symbols (x_i)', ...
       'FontWeight', 'bold', ...
       'FontSize', 12);

ylabel('Entropy Contrib. [bits]', ...
       'FontWeight', 'bold');

title(sprintf( ...
    'Contribution to H_1 (Total H_1 = %.4f bits/char)', H1), ...
    'FontSize', 14, ...
    'FontWeight', 'bold');

grid on;

set(gca, ...
    'FontSize', 11, ...
    'FontName', 'Consolas', ...
    'TickDir', 'out');


% Save
exportgraphics(fig_h1, ...
    'H1_Distribution.png', ...
    'Resolution', 300);


%-------------------------------------------------------------------

fprintf('Point 3\n\n');

% 3. Pairs entropy
[~, fileIndex] = ismember(file, alphabet);

% ismember(A,B) function returns an array containing logical 1 (true) where the data in A is found in B.
% ~: used to indicate that the first value won't be used

pairMatrix = zeros(27, 27);

% How many times character(i) is followed by character(i+1)
for i = 1:(N-1)
    rows = fileIndex(i);
    col = fileIndex(i+1);

    pairMatrix(rows, col) = pairMatrix(rows, col) + 1;
end

% Convert to probability by dividing by the total number of pairs (N-1)
probMatrix = pairMatrix / (N-1);
p2 = probMatrix(:); 

H2 = shannon(p2);

% Variables to track max and min for character pairs
max_contrib2 = -inf; 
min_contrib2 = inf;

pair_max_contrib2 = ''; 
pair_min_contrib2 = '';

max_info2 = -inf; 
min_info2 = inf;

pair_max_info2 = ''; 
pair_min_info2 = '';

% --- Pair by pair entropy (ALL pairs) ---
fprintf('Entropy for each character pair\n');
fprintf('Pair          | Probability | Information | Contribution to H2\n');
fprintf('--------------------------------------------------------------\n');

for r = 1:27
    for c = 1:27
        prob = probMatrix(r, c);
        if prob > 0

            info = -log2(prob);        % Amount of information of the pair
            contrib = prob * info;     % Weighted contribution to total entropy H2
            
            % Formatting the first and second character of the pair
            if alphabet(r) == ' '
                char1 = '[]'; 
            else
                char1 = alphabet(r); 
            end
            
            if alphabet(c) == ' '
                char2 = '[]'; 
            else
                char2 = alphabet(c); 
            end
            
            pair_str = sprintf('%4s%-4s', char1, char2);
            
            fprintf('%s |   %.5f    |      %.5f   |    %.5f\n', pair_str, prob, info, contrib);
            
            % Check max/min Contribution to H2
            if contrib > max_contrib2
                max_contrib2 = contrib;
                pair_max_contrib2 = strtrim(pair_str);
            end

            if contrib < min_contrib2
                min_contrib2 = contrib;
                pair_min_contrib2 = strtrim(pair_str);
            end
            
            % Check max/min Information
            if info > max_info2
                max_info2 = info;
                pair_max_info2 = strtrim(pair_str);
            end

            if info < min_info2
                min_info2 = info;
                pair_min_info2 = strtrim(pair_str);
            end
        end
    end
end

fprintf('--------------------------------------------------------------\n');

fprintf('\nH2: %.4f\n', H2);

fprintf('Entropy per character:\n');
fprintf('H2/2: %.4f\n\n', H2 / 2);

fprintf(['Max Contribution to H2: [%s] (%.4f bits) | ' 'Min Information: [%s] (%.2f bits)\n'], ...
         pair_max_contrib2, max_contrib2, pair_min_info2, min_info2);

fprintf(['Min Contribution to H2: [%s] (%.4f bits) | ' 'Max Information: [%s] (%.2f bits)\n'], ...
         pair_min_contrib2, min_contrib2, pair_max_info2, max_info2);

fprintf('--------------------------------------------------------\n');
fprintf('--------------------------------------------------------\n');


% --- PAIR BAR CHART ---

% Probability of each character pair
pairProb = probMatrix(:);

% Entropy contribution of each character pair
pairContrib = zeros(729, 1);

idx = pairProb > 0;

pairContrib(idx) = pairProb(idx) .* -log2(pairProb(idx));


% ---------------------------------------------------------
% Create labels for the 729 possible character pairs
% ---------------------------------------------------------

pair_labels = strings(729, 1);

k = 1;

for r = 1:27
    for c = 1:27

        % First character
        if alphabet(r) == ' '
            char1 = '[]';
        else
            char1 = alphabet(r);
        end

        % Second character
        if alphabet(c) == ' '
            char2 = '[]';
        else
            char2 = alphabet(c);
        end

        % Pair label
        pair_labels(k) = string(char1) + string(char2);

        k = k + 1;

    end
end


% ---------------------------------------------------------
% Sort pairs according to probability
% ---------------------------------------------------------

[pairProb_sorted, sort_idx] = sort(pairProb, 'descend');

pairContrib_sorted = pairContrib(sort_idx);
pair_labels_sorted = pair_labels(sort_idx);


% ---------------------------------------------------------
% Remove pairs that never occur
% ---------------------------------------------------------

valid = pairProb_sorted > 0;

pairProb_sorted = pairProb_sorted(valid);
pairContrib_sorted = pairContrib_sorted(valid);
pair_labels_sorted = pair_labels_sorted(valid);


% ---------------------------------------------------------
% Keep only the first 20 pairs
% ---------------------------------------------------------

numPairs = min(20, length(pairProb_sorted));

pairProb_sorted = pairProb_sorted(1:numPairs);
pairContrib_sorted = pairContrib_sorted(1:numPairs);
pair_labels_sorted = pair_labels_sorted(1:numPairs);

% BAR CHART
fig_h2 = figure();
% 1. Pair Probability Distribution
subplot(2, 1, 1);

bar(1:numPairs, pairProb_sorted, 'FaceColor', [0.2 0.5 0.8], 'EdgeColor', 'k');

% Character pairs on x-axis
xticks(1:numPairs);
xticklabels(pair_labels_sorted);

xlabel('Character Pair (x_i,x_{i+1})', 'FontWeight', 'bold', 'FontSize', 12);
ylabel('Probability p(x_i,x_{i+1})', 'FontWeight', 'bold');
title('Character-Pair Probability Distribution', 'FontSize', 14, 'FontWeight', 'bold');
grid on;

set(gca, 'FontSize', 11, 'FontName', 'Consolas', 'TickDir', 'out');

% 2. Entropy Contribution

subplot(2, 1, 2);
bar(1:numPairs, pairContrib_sorted, 'FaceColor', [0.8 0.4 0.2], 'EdgeColor', 'k');

% Character pairs on x-axis
xticks(1:numPairs);
xticklabels(pair_labels_sorted);

xlabel('Character Pair (x_i,x_{i+1})', 'FontWeight', 'bold', 'FontSize', 12);
ylabel('Entropy Contrib. [bits]', 'FontWeight', 'bold');
title( ...
    sprintf('Contribution to H_2 (Total H_2 = %.4f bits/pair)', H2), ...
    'FontSize', 14, 'FontWeight', 'bold' ...
    );
grid on;
set(gca, 'FontSize', 11, 'FontName', 'Consolas', 'TickDir', 'out');

% Save figure
exportgraphics(fig_h2, 'H2_Distribution.png', 'Resolution', 300);

%-------------------------------------------------------------------

fprintf('Point 4\n\n');

% 4. Shuffle
% randperm(N) generates an array of indices from 1 to N randomly shuffled
fileShuffled = file(randperm(N));

% Recompute H1_shuffled
p1_shuff = zeros(1, 27);

for i = 1:27
    p1_shuff(i) = sum(fileShuffled == alphabet(i)) / N;
end

H1_shuff = shannon(p1_shuff);

% Recompute H2_shuffled
[~, shuffledIndices] = ismember(fileShuffled, alphabet);

shuffledPairMatrix = zeros(27, 27);

for i = 1:(N-1)
    %!!
    % change
    %!!
    shuffledPairMatrix( shuffledIndices(i), shuffledIndices(i+1))=shuffledPairMatrix(shuffledIndices(i), shuffledIndices(i+1))+1;

end

p2_shuff = shuffledPairMatrix(:) / (N-1);
H2_shuff = shannon(p2_shuff);
fprintf('H1_shuff: %.4f\n', H1_shuff);
fprintf('Variation between H1_shuff and H1: %.4f\n', H1_shuff - H1);
fprintf('H2_shuff/2: %.4f\n', H2_shuff / 2);

fprintf('--------------------------------------------------------\n');
fprintf('--------------------------------------------------------\n');


%-------------------------------------------------------------------
%-------------------------------------------------------------------

% --- HEATMAP  ---

probMatrix_shuff = shuffledPairMatrix / (N-1);
max_p = max([probMatrix(:); probMatrix_shuff(:)]);
% String Array
char_labels = string(alphabet(:));
char_labels(27) = "_"; 

% Large window 1800x850 pixel (impedisce a MATLAB di saltare le lettere)
fig = figure('Units', 'pixels', 'Position', [50, 50, 1800, 850], 'Color', 'w');
theme(fig, 'light');
t = tiledlayout(1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

%Titled cgart layout - usefull for subplots
% --- 1. Original text graph ---
ax1 = nexttile;
imagesc(probMatrix);    %Display image with scaled colors
axis square;

clim([0, max_p * 0.3]);       %Set colormap limits
colormap(parula);       %View and set current colormap
hold on;

for k = 0.5 : 1 : 27.5
    plot([0.5, 27.5], [k, k], 'Color', [1 1 1 0.25], 'LineWidth', 0.5);
    plot([k, k], [0.5, 27.5], 'Color', [1 1 1 0.25], 'LineWidth', 0.5);
end

hold off;

% All 27 symbols
set(ax1, ...
    'XTick', 1:27, ...
    'XTickLabel', char_labels, ...
    'XTickLabelRotation', 0, ...
    'YTick', 1:27, ...
    'YTickLabel', char_labels, ...
    'FontName', 'Consolas', ...
    'FontSize', 12, ...
    'FontWeight', 'bold', ...
    'XColor', [0 0 0], ...
    'YColor', [0 0 0], ...
    'TickDir', 'out', ...
    'Box', 'on');

xlabel('Second Character (X_{n+1})', 'FontSize', 14, 'FontWeight', 'bold', 'Color', [0 0 0]);

ylabel('First Character (X_n)', 'FontSize', 14, 'FontWeight', 'bold', 'Color', [0 0 0]);

title(sprintf( 'Original Text Pair Probabilities p(x_r, x_c)\nH_2/2 = %.4f bits/char', H2/2), ...
    'FontSize', 15, 'FontWeight', 'bold', 'Color', [0 0 0]);

% --- 2. SHUFFLED ---

ax2 = nexttile;
imagesc(probMatrix_shuff);
axis square;
clim([0, max_p * 0.3]);
hold on;

for k = 0.5 : 1 : 27.5
    plot([0.5, 27.5], [k, k], 'Color', [1 1 1 0.25], 'LineWidth', 0.5);
    plot([k, k], [0.5, 27.5], 'Color', [1 1 1 0.25], 'LineWidth', 0.5);
end
hold off;


set(ax2, ...
    'XTick', 1:27, ...
    'XTickLabel', char_labels, ...
    'XTickLabelRotation', 0, ...
    'YTick', 1:27, ...
    'YTickLabel', char_labels, ...
    'FontName', 'Consolas', ...
    'FontSize', 12, ...
    'FontWeight', 'bold', ...
    'XColor', [0 0 0], ...
    'YColor', [0 0 0], ...
    'TickDir', 'out', ...
    'Box', 'on');

xlabel('Second Character (X_{n+1})', 'FontSize', 14, 'FontWeight', 'bold', 'Color', [0 0 0]);
ylabel('First Character (X_n)', 'FontSize', 14, 'FontWeight', 'bold', 'Color', [0 0 0]);

title(sprintf('Shuffled Text Pair Probabilities p_{shuff}(x_r, x_c)\nH_{2,shuff}/2 = %.4f bits/char', H2_shuff/2), ...
    'FontSize', 15, 'FontWeight', 'bold', 'Color', [0 0 0]);

% --- Colors ---

cb = colorbar;
cb.Layout.Tile = 'east';
cb.Color = [0 0 0];
cb.FontSize = 12;
cb.FontWeight = 'bold';
cb.Label.String = 'Probability';
cb.Label.FontSize = 14;
cb.Label.FontWeight = 'bold';
cb.Label.Color = [0 0 0];

% Save graph
exportgraphics(fig, 'Heatmap.png', 'Resolution', 300, 'BackgroundColor', 'white');