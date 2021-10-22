function [FrameMat, t]=FrameBlocking(Signal, N, M, Fs)
    len_frames = N*Fs;
    stride = round(M*Fs);
    noverlap = len_frames-stride;
    len_signal = length(Signal);
    num_frames = floor((len_signal-noverlap)/(len_frames-noverlap));
    padded_signal = [Signal, zeros(1,len_frames)];
    FrameMat = zeros(num_frames,len_frames);
    t = zeros(1,num_frames);
    for i=1:num_frames
        t(i)=N/2+M*(i-1);
        FrameMat(i,:)=padded_signal(stride*(i-1)+1:stride*(i-1)+len_frames);
    end
end