function Gbest = OptimiseBySMPSO(Algorithm, Problem, inputPopulation, evaluations)
    %% Generate random population
    Population       = inputPopulation;
    Pbest            = Population;
    [Gbest,CrowdDis] = UpdateGbest(Population,Problem.N);
    
    maximum = Problem.FE + evaluations;

    %% Optimization
    while Problem.FE < maximum
        Particles        = [Population,Pbest,Gbest(TournamentSelection(2,Problem.N,-CrowdDis))];
        Population       = PSO(Particles, Problem);
        [Gbest,CrowdDis] = UpdateGbest([Gbest,Population],Problem.N);
        Pbest            = UpdatePbest(Pbest,Population);
    end

end

function Pbest = UpdatePbest(Pbest,Population)
    % Update the local best position of each particle
    replace        = ~all(Population.objs>=Pbest.objs,2);
    Pbest(replace) = Population(replace);
end

function [Gbest,CrowdDis] = UpdateGbest(Gbest,N)
    % Update the global best set
    Gbest    = Gbest(NDSort(Gbest.objs,1)==1);
    CrowdDis = CrowdingDistance(Gbest.objs);
    [~,rank] = sort(CrowdDis,'descend');
    Gbest    = Gbest(rank(1:min(N,length(Gbest))));
    CrowdDis = CrowdDis(rank(1:min(N,length(Gbest))));
end

function NewParticles = PSO(Particles, Problem)
    Particles      = Particles([1:end,1:ceil(end/3)*3-end]);
    ParticlesDec   = Particles.decs;
    [N,D]          = size(ParticlesDec);
    ParticlesSpeed = Particles.adds(zeros(N,D));

    %% PSO
    ParticleDec   = ParticlesDec(1:N/3,:);
    ParticleSpeed = ParticlesSpeed(1:N/3,:);
    PBestDec      = ParticlesDec(N/3+1:N/3*2,:);
    GBestDec      = ParticlesDec(N/3*2+1:end,:);
    W  = repmat(unifrnd(0.1,0.5,N/3,1),1,D);
    r1 = repmat(rand(N/3,1),1,D);
    r2 = repmat(rand(N/3,1),1,D);
    C1 = repmat(unifrnd(1.5,2.5,N/3,1),1,D);
    C2 = repmat(unifrnd(1.5,2.5,N/3,1),1,D);
    NewSpeed = W.*ParticleSpeed + C1.*r1.*(PBestDec-ParticleDec) + C2.*r2.*(GBestDec-ParticleDec);
    phi      = max(4,C1+C2);
    NewSpeed = NewSpeed.*2./abs(2-phi-sqrt(phi.^2-4*phi));
    delta    = repmat((Problem.upper-Problem.lower)/2,N/3,1);
    NewSpeed = max(min(NewSpeed,delta),-delta);
    NewDec   = ParticleDec + NewSpeed;
    
    %% Deterministic back
    Lower  = repmat(Problem.lower,N/3,1);
    Upper  = repmat(Problem.upper,N/3,1);
    repair = NewDec < Lower | NewDec > Upper;
    NewSpeed(repair) = 0.001*NewSpeed(repair);
    NewDec = max(min(NewDec,Upper),Lower);
    
    %% Polynomial mutation
    disM  = 20;
    Site1 = repmat(rand(N/3,1)<0.15,1,D);
    Site2 = rand(N/3,D) < 1/D;
    mu    = rand(N/3,D);
    temp  = Site1 & Site2 & mu<=0.5;
    NewDec(temp) = NewDec(temp)+(Upper(temp)-Lower(temp)).*((2.*mu(temp)+(1-2.*mu(temp)).*...
                   (1-(NewDec(temp)-Lower(temp))./(Upper(temp)-Lower(temp))).^(disM+1)).^(1/(disM+1))-1);
    temp  = Site1 & Site2 & mu>0.5; 
    NewDec(temp) = NewDec(temp)+(Upper(temp)-Lower(temp)).*(1-(2.*(1-mu(temp))+2.*(mu(temp)-0.5).*...
                   (1-(Upper(temp)-NewDec(temp))./(Upper(temp)-Lower(temp))).^(disM+1)).^(1/(disM+1)));

    NewParticles = SOLUTION(NewDec,NewSpeed);
end