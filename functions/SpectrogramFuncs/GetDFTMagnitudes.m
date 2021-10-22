function [DFTMagnitudes, f]=GetDFTMagnitudes(wFrames, Fs)
    len_frames = size(wFrames,2);
    len_limited = ceil((len_frames+1)/2);
    FourierFreqs = fft(wFrames,len_frames,2);
    DFTMagnitudes = 20.*log10(abs(FourierFreqs));
    DFTMagnitudes = transpose(DFTMagnitudes);
    DFTMagnitudes = DFTMagnitudes(1:len_limited,:);
    f = linspace(0,Fs,len_frames+1);
    f = f(1:len_limited);
end