classdef (Abstract) BaseCondition < matlab.mixin.Heterogeneous
    methods (Abstract)
        to_bladed(obj,template)
    end
end