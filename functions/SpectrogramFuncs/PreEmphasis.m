function [PreEmphSignal]=PreEmphasis(Signal, Coeff)
    shifted_signal = [0, Signal(1:end-1)];
    PreEmphSignal = Signal - Coeff.*shifted_signal;
end