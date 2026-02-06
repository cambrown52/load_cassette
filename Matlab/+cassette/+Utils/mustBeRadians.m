function mustBeRadians(angle,name)
arguments (Input)
    angle (1,1) double
    name (1,1) string = "Angle"
end

if 2*pi<abs(angle)
    warning("%s of %f rad is large (greater than 2*pi rad). %s must be input in Radians.\nDid you mean to input %f deg=%f rad?",name,angle,name,angle,angle*pi/180)
elseif mod(angle*180/pi,.1)>100*eps && mod(angle,.1)<100*eps
    warning("%s of %f rad =%f deg does not round to an interger degree value. %s must be input in Radians.\nDid you mean to input %f deg=%f rad?",name,angle,angle*180/pi,name,angle,angle*pi/180)
end
end