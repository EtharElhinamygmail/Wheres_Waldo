function animateSearchPath(pts,x,y,radius)
% Animate the search path for finding the Waldo's.  This function:
% * Moves a circle of radius "radius" along a path specified by "x" and "y"
% * Changes the marker of a point that has been found
% * Can save the animation as a GIF if the WRITEGIF flag is set to 1

WRITEGIF = 0;
filename = 'findingWaldo.gif';

pointsFound = false(height(pts),1);
foundPoints = plot(NaN,NaN,'*k');

t = linspace(0,2*pi);
lineColor = [1.0 0.91 0.91];
stepSize = 0.1;

% Circular viewing area at the start of the path
cx = x(1)+radius*cos(t);
cy = y(1)+radius*sin(t);
pc0 = patch(cx,cy,lineColor,'LineStyle','none');
uistack(pc0,'bottom')

% Circular viewing area at the leading point of the path
cx = x(1)+radius*cos(t);
cy = y(1)+radius*sin(t);
pc1 = patch(cx,cy,lineColor,'LineStyle','none');
uistack(pc1,'bottom')

% Update the points that have been found
dists = minDistancePointsToLineSegments([pts.X pts.Y],[x(1) y(1); x(1) y(1)]);
pointsFound = pointsFound | dists<=radius;
foundPoints.XData = pts.X(pointsFound);
foundPoints.YData = pts.Y(pointsFound);

if WRITEGIF
    generateGIF('first',filename);
end

for i = 1:length(x)-1
    
    % Create a new rectangle viewing area for this line segment
    lineLength = hypot(x(i+1)-x(i),y(i+1)-y(i));
    nSteps = lineLength/stepSize;
    stepSizeN = 1/nSteps;
    rect(i).p = patch([x(i) x(i) x(i) x(i)],[y(i) y(i) y(i) y(i)],lineColor,'LineStyle','none');
    uistack(rect(i).p,'bottom')
    
    for j = 1:nSteps
        % Expand the rectangular viewing area along the line segment
        newx = x(i) + (x(i+1)-x(i))*stepSizeN*j;
        newy = y(i) + (y(i+1)-y(i))*stepSizeN*j;
        [rx,ry] = rectangleAroundLine([x(i) y(i)],[newx newy],radius);
        rect(i).p.XData = rx;
        rect(i).p.YData = ry;
        
        % Move the circle at the leading point of the path
        cx = newx+radius*cos(t);
        cy = newy+radius*sin(t);
        pc1.XData = cx;
        pc1.YData = cy;
        
        % Update the points that have been found
        dists = minDistancePointsToLineSegments([pts.X pts.Y],[x(i) y(i); newx newy]);
        pointsFound = pointsFound | dists<=radius;
        foundPoints.XData = pts.X(pointsFound);
        foundPoints.YData = pts.Y(pointsFound);
        if WRITEGIF
            generateGIF('append',filename);
        end
    end
    
    % Add a circle at the next node in the path
    cx = x(i+1)+radius*cos(t);
    cy = y(i+1)+radius*sin(t);
    circ(i).p = patch(cx,cy,lineColor,'LineStyle','none');    
    
    dists = minDistancePointsToLineSegments([pts.X pts.Y],[x(i) y(i); x(i+1) y(i+1)]);
    pointsFound = pointsFound | dists<=radius;
    foundPoints.XData = pts.X(pointsFound);
    foundPoints.YData = pts.Y(pointsFound);
    
    uistack(circ(i).p,'bottom')
    if WRITEGIF
        generateGIF('append',filename);
    end
end

end

function generateGIF(flag,filename)
% Helper function for creating an animated GIF.  See the documentation
% examples for IMWRITE for more info on createing GIF's.
if strcmp(flag,'first');
    set(gcf,'Color','w');
end
drawnow;
frame = getframe(gcf);
im = frame2im(frame);
[A,map] = rgb2ind(im,256);
switch flag
    case 'first'
        imwrite(A,map,filename,'gif','LoopCount',Inf,'DelayTime',0.05);
    case 'append'
        imwrite(A,map,filename,'gif','WriteMode','append','DelayTime',0.05);
    otherwise
        error('Bad flag: %s',flag);
end

end