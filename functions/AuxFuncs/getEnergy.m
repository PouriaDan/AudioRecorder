function [Energy]=getEnergy(FrameMat)
    len_frames = size(FrameMat, 2);
    energy_arr = sum(FrameMat.*FrameMat, 2);
    Energy = energy_arr/len_frames;
end
