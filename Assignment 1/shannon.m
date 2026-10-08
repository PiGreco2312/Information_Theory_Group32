function H = shannon(p)
    p = p(p > 0);
    H = - (p(:)') * log2(p(:));
end