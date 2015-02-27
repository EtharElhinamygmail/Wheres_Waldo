function [x,y] = rectangleAroundLine(p1,p2,r)
% Given a line segment with endpoints p1 and p2, return the vertices of a
% rectangle constructed around the line segment.  The width of the
% rectangle will be the distance between p1 and p2.  The height will be
% 2*r.

% X and Y coordinates of the endpoints.
x1 = p1(1);
y1 = p1(2);
x2 = p2(1);
y2 = p2(2);
m1 = (y2-y1)/(x2-x1);

% Calculate slope of line perpendicular to the line connecting p1 and p2
if m1 == 0 % Prevent divide by zero
    m1 = eps;
    m2 = 1E8;
else
    m2 = -1/m1;
end

% Intercept of the line with slope m2 through p1
b1 = y1-m2*x1;

% Rectangle vertices that lie on the line yy = m2*xx + b1
x31 = x1 + r/sqrt(1+m2^2);
x32 = x1 - r/sqrt(1+m2^2);
y31 = m2*x31+b1;
y32 = m2*x32+b1;

% Intercept of the line with slope m2 through p2
b2 = y2-m2*x2;

% Rectangle vertices that lie on the line yy = m2*xx + b2
x41 = x2 + r/sqrt(1+m2^2);
x42 = x2 - r/sqrt(1+m2^2);
y41 = m2*x41+b2;
y42 = m2*x42+b2;

% Assemble the vertices into vectors "x" and "y"
x = [x31; x32; x42; x41];
y = [y31; y32; y42; y41];
