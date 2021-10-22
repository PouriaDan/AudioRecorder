function [ZCR]=getZCR(FrameMat)
    len_frames = size(FrameMat, 2);
    shfitedFM1 = FrameMat(:,2:end);
    shfitedFM2 = FrameMat(:,1:end-1);
    zero_crossing_cout = abs(sign(shfitedFM1)-sign(shfitedFM2))/2;
    ZCR = sum(zero_crossing_cout,2)/len_frames;
end