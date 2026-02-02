classdef BaseState
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
       function to_bladed(obj,template)
           %overwrite by child class
       end
   end

end