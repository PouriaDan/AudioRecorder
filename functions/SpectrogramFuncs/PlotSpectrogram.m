function PlotSpectrogram(Spec, t, f)
    surf(t, f, Spec, 'EdgeColor', 'none');
    axis xy; 
    axis tight; 
    colorbar()
    view(0,90);
end
