classdef VMOF < ALGORITHM
% <multi> <real/binary/permutation> <constrained/none>
% Efficiently Tackling Million-Dimensional Multiobjective Problems: A Direction Sampling and Fine-Tuning Approach


%------------------------------- Reference --------------------------------
% H. Hong, M. Jiang, Q. Lin and K. C. Tan, "Efficiently Tackling Million-
% Dimensional Multiobjective Problems: A Direction Sampling and Fine-Tuning
% Approach," in IEEE Transactions on Emerging Topics in Computational 
% Intelligence, doi: 10.1109/TETCI.2024.3386866. 
%--------------------------------------------------------------------------
    
    methods
        function main(Algorithm,Problem)
            %% Generate random population
            g_num = Problem.N;
            Population    = Problem.Initialization();
            Directions = DIRECTION(Problem.D, g_num);
            %% Optimization
            while Algorithm.NotTerminated(Population)
                [Population, Directions] = ThompsonSamplingDirections(Population, Directions, Algorithm, Problem);
                Algorithm.NotTerminated(Population);
                [Directions, Population] = DirectionsFinetune(Population, Algorithm, Problem, Directions);
                [Population,~,~]    = TS_EnvironmentalSelection(Population,Problem.N);
            end
        end
    end
end
