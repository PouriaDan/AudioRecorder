function [val,loc]=findmainpeak(signal, rank)
    [peak_vals, peak_locs]=findpeaks(signal);
    [sorted_val, sorted_ind]=sort(peak_vals, 'descend');
    val = sorted_val(rank);
    sorted_locs = peak_locs(sorted_ind);
    loc = sorted_locs(rank);
end
