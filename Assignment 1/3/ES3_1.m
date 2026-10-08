clear;
clc;
close all;

% --- LOAD AND CLEAN TEXT ---
file = fileread('Anna_Karenina.txt');

% Convert to lowercase
file = lower(file);

% Keep only letters a-z and spaces
file = regexprep(file, '[^a-z ]', '');

% Replace multiple spaces with a single space
file = regexprep(file, '\s+', ' ');

N = length(file);

% Define alphabet: 26 letters + space
alphabet = ['a':'z', ' '];
alphabet_size = length(alphabet);


%% --- SINGLE CHARACTER ANALYSIS ---

% Count occurrences of each character
counts = zeros(1, alphabet_size);

for i = 1:alphabet_size
    counts(i) = sum(file == alphabet(i));
end

% Calculate probabilities
p1 = counts / N;

% Shannon entropy for single characters
H1 = shannon(p1);

fprintf('\n--- SINGLE CHARACTER ANALYSIS ---\n');
fprintf('Text length: %d characters\n', N);
fprintf('H1 = %.6f bits/character\n', H1);

% Information and entropy contribution
info1 = zeros(1, alphabet_size);
contrib1 = zeros(1, alphabet_size);

for i = 1:alphabet_size
    if p1(i) > 0
        info1(i) = -log2(p1(i));
        contrib1(i) = p1(i) * info1(i);
    end
end

% Maximum and minimum entropy contribution
[maxContrib, maxIdx] = max(contrib1);
[minContrib, minIdx] = min(contrib1(p1 > 0));

valid_idx = find(p1 > 0);
minIdx = valid_idx(find(contrib1(p1 > 0) == minContrib, 1));

fprintf('\nMaximum entropy contribution:\n');
fprintf('Character: "%s"\n', alphabet(maxIdx));
fprintf('Probability: %.6f\n', p1(maxIdx));
fprintf('Information: %.6f bits\n', info1(maxIdx));
fprintf('Contribution: %.6f bits\n', maxContrib);

fprintf('\nMinimum entropy contribution:\n');
fprintf('Character: "%s"\n', alphabet(minIdx));
fprintf('Probability: %.6f\n', p1(minIdx));
fprintf('Information: %.6f bits\n', info1(minIdx));
fprintf('Contribution: %.6f bits\n', minContrib);


% --- SINGLE CHARACTER BAR CHART ---

% Sort characters by probability
[p1_sorted, sort_idx] = sort(p1, 'descend');
contrib1_sorted = contrib1(sort_idx);
alphabet_sorted = alphabet(sort_idx);

% Replace space with underscore for the plot
alphabet_labels = strings(1, alphabet_size);

for i = 1:alphabet_size
    if alphabet_sorted(i) == ' '
        alphabet_labels(i) = '_';
    else
        alphabet_labels(i) = string(alphabet_sorted(i));
    end
end

fig_h1 = figure();

% Probability distribution
subplot(2,1,1);

bar(1:alphabet_size, p1_sorted, 'FaceColor', [0.2 0.4 0.7]);

ax1 = gca;
ax1.XTick = 1:alphabet_size;
ax1.XTickLabel = alphabet_labels;
ax1.XTickLabelRotation = 0;

xlabel('Character');
ylabel('Probability');
title('Single Character Probability Distribution');
grid on;

% Entropy contribution
subplot(2,1,2);

bar(1:alphabet_size, contrib1_sorted, 'FaceColor', [0.7 0.4 0.2]);

ax2 = gca;
ax2.XTick = 1:alphabet_size;
ax2.XTickLabel = alphabet_labels;
ax2.XTickLabelRotation = 0;

xlabel('Character');
ylabel('Entropy Contribution (bits)');
title('Single Character Entropy Contribution');
grid on;

exportgraphics(fig_h1, 'H1_Distribution.png', 'Resolution', 300);


%% --- PAIR ANALYSIS ---

% Create pair frequency matrix
pairMatrix = zeros(alphabet_size, alphabet_size);

for i = 1:(N-1)

    char1 = file(i);
    char2 = file(i+1);

    idx1 = find(alphabet == char1);
    idx2 = find(alphabet == char2);

    pairMatrix(idx1, idx2) = pairMatrix(idx1, idx2) + 1;

end

% Calculate pair probabilities
probMatrix = pairMatrix / (N-1);

% Flatten probability matrix
p2 = probMatrix(:);

% Calculate pair entropy
H2 = shannon(p2);

fprintf('\n--- PAIR ANALYSIS ---\n');
fprintf('H2 = %.6f bits/pair\n', H2);
fprintf('H2/2 = %.6f bits/character\n', H2/2);

% Conditional entropy
H_cond = H2 - H1;

fprintf('Conditional entropy H(X2|X1) = %.6f bits/character\n', H_cond);


% --- PAIR INFORMATION AND ENTROPY CONTRIBUTION ---

info2 = zeros(size(p2));
contrib2 = zeros(size(p2));

idx = p2 > 0;

info2(idx) = -log2(p2(idx));
contrib2(idx) = p2(idx) .* info2(idx);

% Maximum pair entropy contribution
[maxContrib2, maxIdx2] = max(contrib2);

% Minimum pair entropy contribution
valid_idx2 = find(p2 > 0);
[minContrib2, tempIdx2] = min(contrib2(valid_idx2));
minIdx2 = valid_idx2(tempIdx2);


% Create pair labels
pair_labels = strings(alphabet_size^2, 1);

k = 1;

for r = 1:alphabet_size
    for c = 1:alphabet_size

        if alphabet(r) == ' '
            char1 = '_';
        else
            char1 = alphabet(r);
        end

        if alphabet(c) == ' '
            char2 = '_';
        else
            char2 = alphabet(c);
        end

        pair_labels(k) = string(char1) + string(char2);

        k = k + 1;

    end
end


fprintf('\nMaximum pair entropy contribution:\n');
fprintf('Pair: "%s"\n', pair_labels(maxIdx2));
fprintf('Probability: %.6f\n', p2(maxIdx2));
fprintf('Information: %.6f bits\n', info2(maxIdx2));
fprintf('Contribution: %.6f bits\n', maxContrib2);

fprintf('\nMinimum pair entropy contribution:\n');
fprintf('Pair: "%s"\n', pair_labels(minIdx2));
fprintf('Probability: %.6f\n', p2(minIdx2));
fprintf('Information: %.6f bits\n', info2(minIdx2));
fprintf('Contribution: %.6f bits\n', minContrib2);


%% --- PAIR BAR CHART ---

% Sort pairs by probability
pairProb = probMatrix(:);
pairContrib = zeros(size(pairProb));

idx = pairProb > 0;

pairContrib(idx) = pairProb(idx) .* -log2(pairProb(idx));

% Create pair labels
pair_labels = strings(alphabet_size^2, 1);

k = 1;

for r = 1:alphabet_size
    for c = 1:alphabet_size

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

        pair_labels(k) = string(char1) + string(char2);

        k = k + 1;

    end
end

% Sort pairs by probability
[pairProb_sorted, sort_idx] = sort(pairProb, 'descend');

pairContrib_sorted = pairContrib(sort_idx);
pair_labels_sorted = pair_labels(sort_idx);

% Remove pairs that never occur
valid = pairProb_sorted > 0;

pairProb_sorted = pairProb_sorted(valid);
pairContrib_sorted = pairContrib_sorted(valid);
pair_labels_sorted = pair_labels_sorted(valid);

% Keep only the first 15 pairs
numPairs = min(15, length(pairProb_sorted));

pairProb_sorted = pairProb_sorted(1:numPairs);
pairContrib_sorted = pairContrib_sorted(1:numPairs);
pair_labels_sorted = pair_labels_sorted(1:numPairs);


% --- CREATE PAIR FIGURE ---

fig_h2 = figure();

% Pair probability distribution
subplot(2,1,1);

bar(1:numPairs, pairProb_sorted, ...
    'FaceColor', [0.2 0.4 0.7]);

ax1 = gca;

ax1.XTick = 1:numPairs;
ax1.XTickLabel = pair_labels_sorted;
ax1.XTickLabelRotation = 0;

xlabel('Character Pair');
ylabel('Probability');

title('Top 15 Character Pair Probability Distribution');

grid on;


% Pair entropy contribution
subplot(2,1,2);

bar(1:numPairs, pairContrib_sorted, ...
    'FaceColor', [0.7 0.4 0.2]);

ax2 = gca;

ax2.XTick = 1:numPairs;
ax2.XTickLabel = pair_labels_sorted;
ax2.XTickLabelRotation = 0;

xlabel('Character Pair');
ylabel('Entropy Contribution (bits)');

title('Top 10 Character Pair Entropy Contribution');

grid on;


% Export figure
exportgraphics(fig_h2, 'H2_Distribution.png', 'Resolution', 300);


%% --- SHUFFLED TEXT ANALYSIS ---

% Shuffle the text
rng(1);

shuffled_file = file(randperm(N));

% Calculate single-character probabilities for shuffled text
counts_shuffled = zeros(1, alphabet_size);

for i = 1:alphabet_size
    counts_shuffled(i) = sum(shuffled_file == alphabet(i));
end

p1_shuffled = counts_shuffled / N;

% Entropy of shuffled text
H1_shuffled = shannon(p1_shuffled);

fprintf('\n--- SHUFFLED TEXT ANALYSIS ---\n');
fprintf('H1 shuffled = %.6f bits/character\n', H1_shuffled);


% Calculate pair probabilities for shuffled text
pairMatrix_shuffled = zeros(alphabet_size, alphabet_size);

for i = 1:(N-1)

    char1 = shuffled_file(i);
    char2 = shuffled_file(i+1);

    idx1 = find(alphabet == char1);
    idx2 = find(alphabet == char2);

    pairMatrix_shuffled(idx1, idx2) = ...
        pairMatrix_shuffled(idx1, idx2) + 1;

end

probMatrix_shuffled = pairMatrix_shuffled / (N-1);

p2_shuffled = probMatrix_shuffled(:);

% Pair entropy of shuffled text
H2_shuffled = shannon(p2_shuffled);

fprintf('H2 shuffled = %.6f bits/pair\n', H2_shuffled);
fprintf('H2 shuffled / 2 = %.6f bits/character\n', H2_shuffled/2);


%% --- PAIR PROBABILITY HEATMAP ---

fig_heatmap = figure();

% Original text
subplot(1,2,1);

imagesc(probMatrix);

colorbar;

xlabel('Second Character');
ylabel('First Character');

title('Original Text Pair Probabilities');

axis square;

% Shuffled text
subplot(1,2,2);

imagesc(probMatrix_shuffled);

colorbar;

xlabel('Second Character');
ylabel('First Character');

title('Shuffled Text Pair Probabilities');

axis square;

exportgraphics(fig_heatmap, 'Pair_Probability_Comparison.png', ...
    'Resolution', 300);

%% --- SHANNON ENTROPY FUNCTION ---

function H = shannon(p)

    % Remove zero probabilities
    p = p(p > 0);

    % Calculate Shannon entropy
    H = -sum(p .* log2(p));

end