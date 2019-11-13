module Components
import JSON2
export Component, ComponentContainer, <|, hasproperty, is_prop_available

abstract type AbstractComponent end


struct Component <: AbstractComponent
    type ::String
    namespace ::String
    props ::Dict{Symbol, Any}
    available_props ::Set{Symbol}
end

JSON2.@format Component begin
    available_props => (exclude = true,)
end

function <|(comp::Component, value::Any)
    comp.props["children"] = value
    return comp
end

hasproperty(c::Component, prop::Symbol) = haskey(c.props, prop)
is_prop_available(c::Component, prop::Symbol) = prop in c.available_props

function collect_with_ids(comp)
    result = Dict{Symbol, Component}()
    if haskey(comp.props, :id)
        push!(result, Symbol(comp.props[:id])=>comp)
    end
    if haskey(comp.props, :children)
        if comp.props[:children] isa Vector || comp.props[:children] isa Tuple
            for child in comp.props[:children]
                if child isa Component 
                    merge!(result, collect_with_ids(child))
                end
            end
        elseif comp.props[:children] isa Component
            merge!(result, collect_with_ids(comp.props[:children]))            
        end        
    end
    return result
end
end