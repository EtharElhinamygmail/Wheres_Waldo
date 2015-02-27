function animateWaldoSearch(xopt,pts,radius)
% Animate the finding of the Waldo's whose positions are in "pts", 
% from a moving window of radius "radius" that moves along an optimal path 
% "xopt".

npts = length(pts.X);
figure;

% Waldo Locations
plot(pts.X,pts.Y,'o');

% Format Axis
set(gca,'XTickLabel',[]);
set(gca,'YTickLabel',[]);
set(gca,'XLim',[-1 14]);
set(gca,'YLim',[0 9]);
hold on
axis equal
grid on

% Search path line
plot(xopt(1:npts),xopt(npts+1:end),'--k');

% Animate.  There's a flag in ANIMATESEARCHPATH that can be set to create a
% GIF file from the animation.
animateSearchPath(pts,xopt(1:npts),xopt(npts+1:end),radius);
