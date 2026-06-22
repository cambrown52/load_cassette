classdef BaseState < cassette.simulation.condition.BaseCondition
    properties
        yaw
        pitchangle
    end

   methods
       function obj=BaseState(yaw,pitchangle)
           arguments
               yaw (1,1)
               pitchangle (1,1) =NaN
           end
           if ~isa(yaw,"cassette.variables.BaseVariable")
               mustBeBetween(yaw,-360,360)
               cassette.Utils.mustBeDegrees(yaw,"Yaw position")
           end
           if ~isnan(pitchangle)
               mustBeBetween(pitchangle,-180,180)
               cassette.Utils.mustBeDegrees(pitchangle,"Pitch angle")
               obj.pitchangle=pitchangle;
           end
           obj.yaw=yaw;
       end
   end

end