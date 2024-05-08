%	'algorithm'     <function handle>	an algorithm
%	'problem'       <function handle>	a problem
%   'N'             <positive integer>  population size
%   'M'             <positive integer>  number of objectives
%   'D'             <positive integer>  number of variables
%	'maxFE'         <positive integer>  maximum number of function evaluations
%   'run'           <positive integer>  run number
%   'save'       	<integer>           number of saved populations
%   'outputFcn'     <function handle>   function called after each iteration
%   'encoding'      <string>            encoding scheme of variables
%   'lower'         <vector>            lower bounds of variables
%   'upper'         <vector>            upper bounds of variables
%   'decFcn'        <function handle>   function of variable repair
%   'objFcn'        <function handle>   function of objective calculation
%   'conFcn'        <function handle>   function of constraint calculation

% algorithms = {@LMOTS, @WOF, @LSMOF, @LMOCSO, @NSGAIII, @RMMEDA, @KnEA};
algorithms = {@VMOF};
problems = {@LSMOP1};
Ns = {100};
Ms = {2};
FE = 100000;
Ds = {100000, 500000, 1000000};

for m_index = 1:length(Ms)
    M = Ms{m_index};
    N = Ns{m_index};
    maxFE = FE;
    for d_index = 1:length(Ds)
        D = Ds{d_index};
        for a_index = 1:length(algorithms)
            algorithm = algorithms{a_index};
            for p_index = 1:length(problems)
                problem = problems{p_index};
                platemo('algorithm',{algorithm},'problem',{problem},'D',D,'M',M,'N',N,'T',2000,'maxFE',maxFE,'save',20);
            end
        end
    end
end