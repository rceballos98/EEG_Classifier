function [fb] = freqBands(eeg_data, Fs, bands)
%make frequency bands structure save inputs;
fb.t.data = eeg_data;
fb.param.fs = Fs;
fb.bands = bands;

%get data dimensions
fb.param.ch_num = size(eeg_data,1);
fb.param.N = size(eeg_data,2);

%compute frequencies for plotting
fb.f.freq = 0:fb.param.fs/fb.param.N:Fs/2;

%compute raw power sprectral density (psd)
xdft = fft(fb.t.data, fb.param.N, 2);
xdft = xdft(:,1:fb.param.N/2+1);
psdx = (1/(fb.param.fs*fb.param.N)) * abs(xdft).^2;

%take away mirrored data and save
psdx(:,2:end-1) = 2*psdx(:,2:end-1);
fb.f.psd = psdx;


%Get indexes for frequency band cutoffs
fb.bands.i = fb.bands.freq.*(size(fb.f.psd,2)-1)/(fb.param.fs/2);
fb.f.pbc = zeros(fb.param.ch_num,size(fb.bands.names,2));

for band = 1:size(fb.bands.i,1)
    %Get indexes of interest
    name = char(fb.bands.names(band));
    i1 = fb.bands.i(band,1);
    i2 = fb.bands.i(band,2);
    %number of points used in calculation
    point_num = abs(i2 - i1);
    
    %compute mid freq for each band (plotting)
    fb.bands.med(band) = i1 + (i2-i1)/2;
    
    
    %index PSD matrix for right band
    band_data = fb.f.psd(:,i1:i2);
    
    %Calculate average power over band for each channel
    fb.f.pbc(:,band) = sum(band_data,2)./point_num;
    
    %Calculate average power over all channels
    fb.f.pb_tot(band) = sum(fb.f.pbc(:,band))/fb.param.ch_num;

end

end