classdef DIRECTION
%DIRECTION - The class of a direction.
%
%   This is the class of a direction. 
%
% SOLUTION properties:
%   dec         <read-only>     decision variables of the solution
%   obj         <read-only>     objective values of the solution
%   con         <read-only>     constraint violations of the solution
%   add         <read-only>     additional properties of the solution
%
% SOLUTION methods:
%   SOLUTION	<public>        the constructor, which sets all the
%                               properties of the solution
%   decs        <public>      	get the matrix of decision variables of
%                               multiple solutions
%   objs        <public>        get the matrix of objective values of
%                               multiple solutions
%   cons        <public>        get the matrix of constraint violations of
%                               multiple solutions
%   adds        <public>        get the matrix of additional properties of
%                               multiple solutions
%   best        <public>        get the feasible and nondominated solutions
%                               among multiple solutions

%------------------------------- Copyright --------------------------------

%--------------------------------------------------------------------------

    properties(SetAccess = private)
        index;      % Index of direction
        dir;        % Director of direction
        sampled;    % Number of direction was sampled
        pro;        % Promotion to solution by this direction
        con;        % Degeneration to solution by this direction
    end
    properties(SetAccess = public)
        step;       % Step calculated for this direction
    end
    methods
        function obj = DIRECTION(d, g, dp)
        %DIRECTION - The constructor of DIRECTION.
        %
        %   P = SOLUTION(Dec) creates an array of SOLUTION objects with
        %   decision variables of Dec, where the objective values and
        %   constraint violations are calculated automatically.
        %
        %   P = SOLUTION(Dec,AddPro) also sets the additional properties
        %   (e.g., velocity) of solutions to the values of AddPro.
        %
        %   Dec and AddPro are matrices, where each row denotes a solution
        %   and each column denotes a dimension of the decision variables
        %   or additional properties.
        %
        %   Example:
        %       Population = SOLUTION(PopDec)
        
            if nargin > 0
                if nargin == 2
                    S = randn(g, d);
                    dp = bsxfun(@rdivide, S, sqrt(sum(S.*S, 2)));
                end
                obj(1,g) = DIRECTION;
                for i = 1 : length(obj)
                    obj(i).index = i;
                    obj(i).dir = dp(i,:);
                    obj(i).sampled = 0;
                    obj(i).pro = 1;
                    obj(i).con = 1;
                    obj(i).step = 1;
                end
            end
        end
        function value = dirs(obj)
        %decs - Get the matrix of decision variables of a population.
        %
        %   Dec = obj.decs returns the matrix of decision variables of
        %   multiple solutions obj.
        
            value = cat(1,obj.dir);
        end
        function value = steps(obj)
        %decs - Get the matrix of decision variables of a population.
        %
        %   Dec = obj.decs returns the matrix of decision variables of
        %   multiple solutions obj.
        
            value = cat(1,obj.step);
        end
        function directions = sample_directions(obj, p)
        %objs - Get the matrix of objective values of a population.
        %
        %   Obj = obj.objs returns the matrix of objective values of
        %   multiple solutions obj.
            pros = repmat(obj.pros(), 1, p);
            cons = repmat(obj.cons(), 1, p);
            r = betarnd(pros,cons);
            [~, directions_index] = max(r, [], 1);
            directions = cat(1, obj(directions_index));
        end
        function value = indecies(obj)
        %cons - Get the matrix of constraint violations of a population.
        %
        %   Con = obj.cons returns the matrix of constraint violations of
        %   multiple solutions obj.
        
            value = cat(1,obj.index);
        end
        function value = pros(obj)
        %cons - Get the matrix of constraint violations of a population.
        %
        %   Con = obj.cons returns the matrix of constraint violations of
        %   multiple solutions obj.
        
            value = cat(1,obj.pro);
        end
        function value = cons(obj)
        %cons - Get the matrix of constraint violations of a population.
        %
        %   Con = obj.cons returns the matrix of constraint violations of
        %   multiple solutions obj.
        
            value = cat(1,obj.con);
        end
        function value = samples(obj)
        %adds - Get the matrix of additional properties of a population.
        %
        %   Add = obj.adds(AddPro) returns the matrix of additional
        %   properties of multiple solutions obj. If any solution in obj
        %   does not contain an additional property, it will be set to the
        %   default value specified in AddPro.

            value = cat(1,obj.sampled);
        end
        function obj = update(obj, fitness)
            for i = 1 : length(obj)
                if fitness(i) > 0
                    obj(i).pro = obj(i).pro + 1;
                elseif fitness(i) <= 0
                    obj(i).con = obj(i).con + 1;
                end
                obj(i).sampled = obj(i).sampled + 1;
            end
        end
        function obj = set_step(obj, step)
            for i = 1 : length(obj)
                obj(i).step = step(i);
            end
        end
    end
end