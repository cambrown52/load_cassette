classdef BaseState
    properties
        yaw
    end

   methods
       function obj=BaseState(yaw)
           obj.yaw=yaw;
       end
       function to_bladed(obj,template)
           %overwrite by child class
       end
   end

end