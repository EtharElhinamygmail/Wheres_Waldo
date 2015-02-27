function [order,fval,output] = shortestPathAToB(pts,start,stop)
%% Adapted from the TSP Example from Optimization Toolbox
% Given a matrix of points "pts", where the first column of pts is the
% x-coordinates of the nodes, and the second column is the y-coordinates of
% the nodes, find the shortest path through all of the nodes.  "Start" and
% "stop" are scalars that specify the nodes that should be the start and
% end of the path.

%% Travelling Salesman Problem
% This example shows how to use binary integer programming to solve the
% classic travelling salesman problem. This problem involves finding the
% shortest closed tour (path) through a set of stops (cities). In this case
% there are 200 stops, but you can easily change the |nStops| variable to get
% a different problem size.  You'll solve the initial problem and see that
% the solution has subtours. This means the optimal solution found doesn't
% give one continuous path through all the points, but instead has several
% disconnected loops. You'll then use an iterative process of determining
% the subtours, adding constraints, and rerunning the optimization until
% the subtours are eliminated.

%   Copyright 2014 The MathWorks, Inc. 

%% Extract data from pts
nStops = size(pts,1);
stopsLat = pts(:,2);
stopsLon = pts(:,1);

%% Problem Formulation
% Formulate the travelling salesman problem for integer linear
% programming as follows:
%
% * Generate all possible trips, meaning all distinct pairs of stops.
%
% * Calculate the distance for each trip.
%
% * The cost function to minimize is the sum of the trip distances for each
% trip in the tour.
%
% * The decision variables are binary, and associated with each trip, where
% each 1 represents a trip that exists on the tour, and each 0 represents a
% trip that is not on the tour.
%
% * To ensure that the tour includes every stop, include the linear
% constraint that each stop is on exactly two trips. This means one arrival
% and one departure from the stop.

%% Calculate Distances Between Points
% Because there are 200 stops, there are 19,900 trips, meaning 19,900
% binary variables (# variables = 200 choose 2).
%
% Generate all the trips, meaning all pairs of stops.

idxs = nchoosek(1:nStops,2);

%%
% Calculate all the trip distances, assuming that the earth is flat in
% order to use the Pythagorean rule.

dist = hypot(stopsLat(idxs(:,1)) - stopsLat(idxs(:,2)), ...
             stopsLon(idxs(:,1)) - stopsLon(idxs(:,2)));
lendist = length(dist);

%%
% With this definition of the |dist| vector, the length of a tour is
%
% |dist'*x|
%
% where |x| is the binary solution vector. This is the distance of a tour
% that you try to minimize.

%% Equality Constraints
% The problem has two types of equality constraints.  The first enforces
% that there must be 200 trips total. The second enforces that each stop
% must have two trips attached to it (there must be a trip to each stop and a
% trip departing each stop).
%
% Specify the first type of equality constraint, that you must have
% |nStops| trips, in the form |Aeq*x = beq|.


Aeq = spones(1:length(idxs)); % Adds up the number of trips
beq = nStops-1; % Since this isn't a complete tour, it's just A to B, we have nStops -1 segments

%%
% To specify the second type of equality constraint, that there needs to be
% two trips attached to each stop, extend the |Aeq| matrix as sparse.

Aeq = [Aeq;spalloc(nStops,length(idxs),nStops*(nStops-1))]; % allocate a sparse matrix
for ii = 1:nStops
    whichIdxs = (idxs == ii); % find the trips that include stop ii
    whichIdxs = sparse(sum(whichIdxs,2)); % include trips where ii is at either end
    Aeq(ii+1,:) = whichIdxs'; % include in the constraint matrix
end

beq = [beq; 2*ones(nStops,1)];
% Enforce the constraints that the stop and start node will only have 1
% segment attached to them
beq(start+1) = 1;
beq(stop+1) = 1;

%% Binary Bounds
% All decision variables are binary. Now, set the |intcon| argument to the
% number of decision variables, put a lower bound of 0 on each, and an
% upper bound of 1.

intcon = 1:lendist;
lb = zeros(lendist,1);
ub = ones(lendist,1);

%% Optimize Using intlinprog
% The problem is ready to be solved. Call the solver.
opts = optimoptions('intlinprog','Display','off');
[xopt,fval,eflag,output] = intlinprog(dist,intcon,[],[],Aeq,beq,lb,ub,opts);

%% Extract our trip segments.
tours = detectSubtours(xopt,idxs);
numtours = length(tours); % number of subtours
% 
%%
% Include the linear inequality constraints to eliminate subtours, and
% repeatedly call the solver, until just one subtour remains.

A = spalloc(0,lendist,0); % Allocate a sparse linear inequality constraint matrix
b = [];
while numtours > 1 % repeat until there is just one subtour
    % Add the subtour constraints
    b = [b;zeros(numtours,1)]; % allocate b
    A = [A;spalloc(numtours,lendist,nStops)]; % a guess at how many nonzeros to allocate
    for ii = 1:numtours
        rowIdx = size(A,1)+1; % Counter for indexing
        subTourIdx = tours{ii}; % Extract the current subtour
%         The next lines find all of the variables associated with the
%         particular subtour, then add an inequality constraint to prohibit
%         that subtour and all subtours that use those stops.
        variations = nchoosek(1:length(subTourIdx),2);
        for jj = 1:length(variations)
            whichVar = (sum(idxs==subTourIdx(variations(jj,1)),2)) & ...
                       (sum(idxs==subTourIdx(variations(jj,2)),2));
            A(rowIdx,whichVar) = 1;
        end
        b(rowIdx) = length(subTourIdx)-1; % One less trip than subtour stops
    end

    % Try to optimize again
    [xopt,fval,eflag,output] = intlinprog(dist,intcon,A,b,Aeq,beq,lb,ub,opts);
    
    % How many subtours this time?
    tours = detectSubtours(xopt,idxs);
    numtours = length(tours); % number of subtours
end

%% Extract the order that the nodes are visited in
% We know the endpoints of each segment on the shortest trip, but it's more
% convenient to look at this as "the order the nodes are visited in".
% We begin at the start node, then continue on to the node attached to it,
% then repeat until we have gone through all of the points.

segments = find(xopt);
points = idxs(segments,:);
order = zeros(nStops,1);
[row,column] = find(points == start);
order(1) = start;
for i = 2:nStops
    if column == 1
        nextPoint = points(row,2);
    elseif column == 2
        nextPoint = points(row,1);
    end
    order(i) = nextPoint;
    points(row,:) = [];
    [row,column] = find(points == nextPoint);
end


