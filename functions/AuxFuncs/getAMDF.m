function [AMDF]=getAMDF(singleFrame)
    len_frame = length(singleFrame);
    num_coeffs = min(len_frame, 1000);
    AMDF = zeros(1,num_coeffs);
    for m =1:num_coeffs
            shiftedF = [zeros(1,m-1), singleFrame(1:end-(m-1))];
            AMDF(m) = sum(abs(singleFrame-shiftedF))/len_frame;
    end
end