function [wFrames]=Windowing(FrameMat,Type)
    len_frames = size(FrameMat,2);
    switch Type
        case 0
            wFrames = FrameMat;
        case 1
            hamming_window = reshape(hamming(len_frames), [1, len_frames]);
            wFrames = FrameMat.*hamming_window;
        case 2
            hanning_window = reshape(hanning(len_frames), [1, len_frames]);
            wFrames = FrameMat.*hanning_window;
        case 3
            triang_window = reshape(triang(len_frames), [1, len_frames]);
            wFrames = FrameMat.*triang_window;
    end
end