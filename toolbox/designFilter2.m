function filt = designFilter2(gamma, filter, len, crop)

% this kernel design is based on pp74 of Kak & Slaney 's book. It works
% much better than the other filter (designFilter.m)

order = max(64,2^nextpow2(2*len-1));

index = -order/2+1:order/2-1;
%assign h value according to formular (61) on pp72
h = zeros(size(index));
h(find(index==0)) = 1/(4*gamma^2);

% note: abs(index)<len, instead of abs(index)<len/2, if needed in 'temp';

temp = find(mod(index,2)==1);
h(temp) = -1./(index(temp)*pi*gamma).^2; 

h(order) = 0; % zero-padding

filt = abs(fft(h));
filt = filt(1:order/2+1);

w = 2*pi*(0:size(filt,2)-1)/order;   % frequency axis up to Nyquist 

switch filter
case 'ram-lak'
    % Do nothing
case 'shepp-logan'
    % be careful not to divide by 0:
    filt(2:end) = filt(2:end) .* (sin(w(2:end)/(2*crop))./(w(2:end)/(2*crop)));
case 'cosine'
    filt(2:end) = filt(2:end) .* cos(w(2:end)/(2*crop));
case 'hamming'  
    filt(2:end) = filt(2:end) .* (.54 + .46 * cos(w(2:end)/crop));
case 'hann'
    filt(2:end) = filt(2:end) .*(1+cos(w(2:end)./crop)) / 2;
otherwise
    error('Invalid filter selected.');
end

filt(w>pi*crop) = 0;                      % Crop the frequency response
filt = [filt' ; filt(end-1:-1:2)'];    % Symmetry of the filter