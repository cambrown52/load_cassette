function mustBeDegrees(angle,name)
arguments (Input)
    angle (1,1) double
    name (1,1) string = "Angle"
end

if 0 < abs(angle) && abs(angle) < 1
    warning("%s of %f deg is small (less than 1deg). %s must be input in Degrees.\nDid you mean to input %frad=%fdeg?",name,angle,name,angle,angle*180/pi)
elseif mod(angle,.1)>100*eps
    warning("%s of %f deg has many decimal places. %s must be input in Degrees.\nDid you mean to input %frad=%fdeg?",name,angle,name,angle,angle*180/pi)
end
end