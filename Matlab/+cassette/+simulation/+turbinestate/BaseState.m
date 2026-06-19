classdef BaseState < cassette.simulation.condition.BaseCondition
    properties
        yaw
    end

   methods
       function obj=BaseState(yaw)
           arguments
               yaw (1,1)
           end
           if ~isa(yaw,"cassette.variables.BaseVariable")
               mustBeBetween(yaw,-360,360)
               cassette.Utils.mustBeDegrees(yaw,"Yaw position")
           end
           obj.yaw=yaw;
       end
   end

end