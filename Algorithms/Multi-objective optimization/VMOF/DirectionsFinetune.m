function [Directions, Offspring] = DirectionsFinetune(Parent, Algorithm, Problem, Directions)
%ThompsonSamplingOffspring - Crossover and mutation operators of genetic algorithm.
    %% Parameter setting
    g_num = length(Directions);
    g_sample = 50;
    g_pop_size = 5;
    G2 = 5;
    Offspring = Parent;
    for s_i = 1:g_sample:g_num
        Reference = max(Offspring.objs,[],1);
        if s_i + g_sample > g_num
            g_sample = g_num - s_i;
        end
        directions = Directions(s_i:s_i + g_sample - 1);
        direction = directions.dirs();

        step_max = sum((Problem.upper-Problem.lower).^2)^(0.5)*0.5;
        
        %% Optimize the weight variables by DE
        step0 = rand(g_pop_size,g_sample).*step_max;
        [fitness,PopNew] = generate(step0,direction,Problem,Reference);
    
        Offspring = PopNew(NDSort(PopNew.objs,1)==1);
        pCR = 0.2;
        beta_min=0.2;   % Lower Bound of Scaling Factor
        beta_max=0.8;   % Upper Bound of Scaling Factor
        empty_individual.Position=[];
        empty_individual.Cost=[];
        pop=repmat(empty_individual,g_pop_size,1);
        for i = 1 : g_pop_size
            pop(i).Position = step0(i,:);
            pop(i).Cost = fitness(i);
        end
        temp = [];
        for it = 1 : G2
            for i = 1 : g_pop_size
                x = pop(i).Position;
                A = randperm(g_pop_size);
                A(A==i) = [];
                a = A(1); b = A(2); c = A(3);
                % Mutation  %beta=unifrnd(beta_min,beta_max);
                beta = unifrnd(beta_min,beta_max,[1 g_sample]);
                y = pop(a).Position + beta.*(pop(b).Position - pop(c).Position);
                y = min(max(y,0),step_max);
                % Crossover
                offspring_step = zeros(size(x));
                j0=randi([1 numel(x)]);
                for j=1:numel(x)
                    if j==j0 || rand<=pCR
                        offspring_step(j) = y(j);
                    else
                        offspring_step(j) = x(j);
                    end
                end
                NewSol.Position = offspring_step;
                [fit,PopNew] = generate(offspring_step,direction,Problem,Reference);
                temp = [temp,PopNew];
                betas = NDSort(PopNew.objs,1)==1;
                Directions(directions.indecies) = Directions(directions.indecies).update(betas);
                temp = temp(NDSort(temp.objs,1)==1);
                NewSol.Cost = fit;
                if NewSol.Cost < pop(i).Cost
                    pop(i)=NewSol;
                end
            end
        end
        %Update and store the non-dominated solutions
        Offspring = [Offspring,temp];
        Directions(directions.indecies) = Directions(directions.indecies).set_step(offspring_step);
    end
    Offspring = [Parent, Offspring];
    if length(Offspring) > Problem.N
        [frontNo,~] = NDSort(Offspring.objs,1);
        Offspring = Offspring(frontNo==1);
    end
end

function [Obj,OffSpring] = generate(step,direct,Problem,Reference)
    [step_pop,step_size] = size(step); 
    Obj   	  = zeros(step_pop,1);
    OffSpring = [];
    for i = 1 : step_pop
        PopDec  = [repmat(step(i,1:step_size)',1,Problem.D).*direct(1:step_size,:)];
        OffWPop   = SOLUTION(PopDec);
        OffSpring = [OffSpring,OffWPop];
        if nargin <= 2
            Obj(i) = -HV(OffWPop,Reference);
        else
            Obj(i) = 0;
        end
    end
end