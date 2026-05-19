classdef BaseState < cassette.simulation.condition.BaseCondition
    properties
        yaw
    end

   methods
       function obj=BaseState(yaw)
           arguments
               yaw (1,1) double {mustBeBetween(yaw,-360,360)}
           end

           cassette.Utils.mustBeDegrees(yaw,"Yaw position")
           obj.yaw=yaw;
       end
   end

end