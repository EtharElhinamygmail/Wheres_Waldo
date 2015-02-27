function [c,ceq] = nonlcon(x,pts,radius)
% For the Waldo problem, we need to make sure that all of theWaldo
% locations in "pts" are withing a radius "r" of the path contained in "x".
%  We incorporate this as an inequality constraint that says the distance
%  to the nearest line segment "dist" minus "radius" must be less than or
%  equal to zero.

ceq = [];

x = x(:); % Ensure s is a column vector
n = length(x);
lineSegs = [x(1:n/2) x(n/2+1:end)]; % Coordinates of path
if strcmp(mexext,'mexw64')
    % Compiled c-code to speed up this calculation
    dist = minDistancePointsToLineSegments_mex(pts,lineSegs);
else
    dist = minDistancePointsToLineSegments(pts,lineSegs);
end

c = dist-radius;