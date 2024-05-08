function Population = StepGeneratePopulation(stepPopulation, Problem, Population, Group, xPrime, stepDiversityPop)
    calc = size(stepDiversityPop,2)*size(Population,2);
    PopDec1 = ones(calc,Problem.D);
    count = 1;
    for stepi = 1:size(stepDiversityPop,2)
        stepIndividual = stepDiversityPop(stepi);
        stepVars = stepIndividual.dec;
        
        for i = 1:size(Population,2)
            individualVars = Population(i).dec;
            
            x = TransformationFunctionMatrixForm(individualVars,stepVars(Group),Problem.upper,Problem.lower);

            PopDec1(count,:) = x;
            count = count + 1;
        end
        
    end
    
    pop1 = SOLUTION(PopDec1);

    % Step 2
    PopDec2 = [];
    for stepi = 1:size(stepPopulation,2)
        stepIndividual = stepPopulation(stepi);
        stepVars = stepIndividual.dec;
        
            individualVars = xPrime.dec;
            x = 1:Problem.D;
            for j = 1:Problem.D
                x(j) = TransformationFunction(individualVars(j),stepVars(Group(j)),Problem.upper(j),Problem.lower(j));   
            end
            PopDec2 = [PopDec2;x]; 
    end
    pop2 = SOLUTION(PopDec2);
    
    Population = [pop1,pop2];
end

function value = TransformationFunction(xPrime,weight,maxVal,minVal)
    if weight > 1.0
        weight = weight - 1.0;
        interval = maxVal - xPrime;
        value = xPrime + weight * interval;
    else
        interval = xPrime - minVal;
        value = minVal + weight * interval;
    end 
    
    %do repair
    if value < minVal
       value = minVal;
    elseif value > maxVal
       value = maxVal;
    end 
end

function value = TransformationFunctionMatrixForm(xPrime,weight,maxVal,minVal)
    interval = xPrime - minVal;
    value = minVal + weight .* interval;
    interval = maxVal - xPrime;
    value(weight > 1.0) = xPrime(weight > 1.0) + (weight(weight > 1.0)-1.0) .* interval(weight > 1.0); 
    
    %do repair
    if value < minVal
       value = minVal;
    elseif value > maxVal
       value = maxVal;
    end
end