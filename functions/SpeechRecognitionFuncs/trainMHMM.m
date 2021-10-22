function [prior1, transmat1, mu1, Sigma1, mixmat1] = trainMHMM(data, Q, M, method)
    O=size(data,1);
    cov_type='spherical';

    prior0 = [[0.9;0.1]; zeros(Q-2,1)];
    if method=="Stochastic"
        transmat0 = mk_stochastic(rand(Q,Q));
    elseif method=="Left to Right"
        transmat0 = mk_leftright_transmat(Q,0.5);
    else
        transmat0 = mk_rightleft_transmat(Q,0.5);
    end

    [mu0, Sigma0] = mixgauss_init(Q*M, data, cov_type, 'kmeans');
    mu0 = reshape(mu0, [O Q M]);
    Sigma0 = reshape(Sigma0, [O O Q M]);
    mixmat0 = mk_stochastic(rand(Q,M));

    [LL, prior1, transmat1, mu1, Sigma1, mixmat1] = ...
        mhmm_em(data, prior0, transmat0, mu0, Sigma0, mixmat0, 'max_iter', 50);
end
