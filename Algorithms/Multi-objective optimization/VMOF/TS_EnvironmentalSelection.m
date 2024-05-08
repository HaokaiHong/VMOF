function [Population,FrontNo,CrowdDis] = TS_EnvironmentalSelection(Population,N)
% The environmental selection used inside VMOF.
% This function is mostly identical to the original
% EnvironmentalSelection function from the NSGA-II algorithm.
    %% Non-dominated sorting
    [FrontNo,MaxFNo] = NDSort(Population.objs,N);
    Next = false(1,length(FrontNo));
    Next(FrontNo<MaxFNo) = true;
    
    %% Calculate the crowding distance of each solution
    CrowdDis = CrowdingDistance(Population.objs,FrontNo);
    
    %% Select the solutions in the last front based on their crowding distances
    Last     = find(FrontNo==MaxFNo);
    [~,Rank] = sort(CrowdDis(Last),'descend');
    Popsize = min(N,size(Population,2));
    Next(Last(Rank(1:Popsize-sum(Next)))) = true;
    
    %% Population for next generation
    Population = Population(Next);
    FrontNo    = FrontNo(Next);
    CrowdDis   = CrowdDis(Next);
end