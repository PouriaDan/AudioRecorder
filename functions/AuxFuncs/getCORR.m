function [CORR]=getCORR(singleFrame)
    len = length(singleFrame);
    Coefs = xcorr(singleFrame);
    CORR = Coefs(len:end)/len;
end