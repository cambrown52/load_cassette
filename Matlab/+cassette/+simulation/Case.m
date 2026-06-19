classdef Case
    %SIMULATION Summary of this class goes here
    %   Detailed explanation goes here

    properties
        name 
        wind
        turbinestate
        conditions (:,1) 

    end

    methods
        function obj = Case(name,wind,turbinestate,inargs)
            arguments
                name (1,1)
                wind (1,1)
                turbinestate (1,1)
                inargs.conditions (:,1) =[]

            end
            obj.name=name;
            obj.wind=wind;
            obj.turbinestate=turbinestate;
            if ~isempty(inargs.conditions)
                obj.conditions=inargs.conditions;
            end

        end

        function v=get_variables(obj)
            v=[];
            if isa(obj.name,"cassette.variables.BaseVariable")
                v=[v;obj.name];
            end
            v=[v; get_variables([obj.wind;obj.turbinestate;obj.conditions])];
        end


        function n=number_of_combinations(obj)
            v=obj.get_variables();
            if isempty(v)
                n=1;
            else
                v.generate_combinations();
                n=v.number_of_combinations();
            end
        end
        function obj=get_scalar_instance(obj,index)
            arguments
                obj (1,1) cassette.simulation.Case
                index (1,1) double {mustBePositive, mustBeInteger}
            end
            
            if isa(obj.name,"cassette.variables.BaseVariable")
                obj.name=obj.name.get_value(index);
            end
            obj.wind=obj.wind.get_scalar_instance(index);
            obj.turbinestate=obj.turbinestate.get_scalar_instance(index);
            obj.conditions=obj.conditions.get_scalar_instance(index);
        end

        function inputfile=to_bladed(simulation,template,outputfolder)
            arguments
                simulation
                template cassette.templates.BladedTemplate
                outputfolder (1,1) string {mustBeFolder}
            end
            warning("deprecated: use template.merge (works for any template type) method instead of simulation.to_bladed")

            inputfile=template.merge(simulation,outputfolder);


        end

        function st=to_struct(obj)
            st=struct();
            
            st.case.ObjectType=class(obj);
            st.case.name=obj.name;
            st.wind=obj.wind.to_struct();
            st.turbinestate=obj.turbinestate.to_struct();
            I=length(obj.conditions);
            st.conditions=cell(I,1);
            for i=1:I
                st.conditions{i}=obj.conditions(i).to_struct();
            end
        end

       
    end
end