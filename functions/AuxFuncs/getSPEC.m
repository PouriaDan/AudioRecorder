function [DFTMagnitudes, f]=getSPEC(singleFrame, Fs)
    len_frame = length(singleFrame);
    len_limited = ceil((len_frame+1)/2);
    FourierFreqs = fft(singleFrame,len_frame);
    DFTMagnitudes = 20.*log10(abs(FourierFreqs));
    DFTMagnitudes = DFTMagnitudes(:,1:len_limited);
    f = linspace(0,Fs,len_frame+1);
    f = f(1:len_limited);
end