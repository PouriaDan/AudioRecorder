function [f_vals, f_locs, smoothed_signal]=getFORMANTS(signal, FS)
    [s, f] = getSPEC(Windowing(signal, 1), FS);
    ss = sgolayfilt(s, 3,31);
    smoothed_signal = filter(ones(1,10)/10, 1,ss);
    f_vals = zeros(1,3);
    f_locs = zeros(1,3);
    [peaks_vals, peaks_locs]=findpeaks(smoothed_signal);
    for i=1:3
        f_vals(i) = peaks_vals(i);
        f_locs(i) = f(peaks_locs(i));
    end
end