function [CEPSTRAL]=getCEPSTRAL(singleFrame)
    CEPSTRAL = ifft(log(abs(fft(singleFrame))));
end