module AiAgents
  class BaseAgent
    def initialize(form_data, previous_results = {})
      @form_data = form_data.to_context_hash
      @previous_results = previous_results
    end

    def build_prompt
      raise NotImplementedError, 'Subclasses must implement build_prompt'
    end

    protected

    def form_context
      @form_data
    end

    def previous_result(agent_name)
      @previous_results[agent_name]
    end
  end
end
