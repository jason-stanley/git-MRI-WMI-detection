function dis = dis_logical(log1, log2, debug)

% Assume that log1 is the foreground, log2 is the background, both of which
% have to be logical.

if(nargin == 2)
    debug = 0;
end

if(debug)
    figure, subplot(121), imshow(log1, []);
    subplot(122), imshow(log2, []);
end

if(max(log1 & log2) > 0)
    dis = 0;
else
    for i = 1:1:size(log2, 1)
        log1 = logic_dilate(log1, i);
        if(max(log1 & log2) > 0)
            dis = i;
            break
        end
    end
end