clc
clear
close all

% Computational costs (in seconds) ordered increasingly:
x = [0.1,   % Basic pixel-difference check
    0.5,    % Feature extraction
    1.5,    % Object detection
    5.0]';  % Heavy image segmentation pipeline (transposed to row/column match)
x = x(:)';  % Ensure x is a row vector [0.1, 0.5, 1.5, 5.0]
labels = {'0.1s', '0.5s', '1.5s', '5.0s'};

mean = sum(x)/length(x);    %1.7750

mu_values = [0.5,   % Fast 
    1.4,            % Balanced 
    4.0]';          % High-Accuracy 
mu_values = mu_values(:)';
mode_names = {'Fast', 'Balanced', 'High-Accuracy'};

figure('Position', [100, 100, 1100, 380]);
for k = 1:length(mu_values)
    mu = mu_values(k);
    b_min = 0.0001; 
    b_max = 100;
    for iter = 1:100
        beta = (b_min + b_max) / 2;
        if sum((x - mu) .* (beta .^ x)) > 0
            b_max = beta; % Decrease beta to lower the mean
        else
            b_min = beta; % Increase beta to raise the mean
        end
    end
    
    % Compute the MaxEnt pmf for the found beta
    Z = sum(beta .^ x);
    p = (beta .^ x) / Z;
    
    % Compute Shannon entropy
    H = shannon(p); 
    
    % Print results
    fprintf('Case %d (%s): Mean constraint mu = %.2f s\n', k, mode_names{k}, mu);
    fprintf('  Solved beta : %.6f\n', beta);
    fprintf('  MaxEnt pmf  : [%.4f, %.4f, %.4f, %.4f]\n', p(1), p(2), p(3), p(4));
    fprintf('  Entropy H   : %.4f bits\n', H);
    fprintf('----------------------------------------------------------\n');
    
    % Plot the pmf
    subplot(1, 3, k);
    bar(1:4, p, 0.6, 'FaceColor', [0.2 0.5 0.8]);
    xticks(1:4);
    xticklabels(labels);
    ylim([0 1]);
    grid on;
    title(sprintf('%s: \\mu = %.1f s\n\\beta = %.4f | H = %.4f bits', mode_names{k}, mu, beta, H));
    xlabel('Computational Cost x_i [s]');
    ylabel('Probability p(x_i)');
end