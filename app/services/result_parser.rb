class ResultParser
  def initialize(raw_response)
    @raw_response = raw_response
  end

  def parse
    clean_json = clean_response(@raw_response)
    JSON.parse(clean_json)
  rescue JSON::ParserError => e
    Rails.logger.error "Failed to parse agent response: #{e.message}"
    Rails.logger.error "Raw response preview: #{@raw_response[0..500]}"

    # Return error object instead of failing completely
    {
      error: "Failed to parse agent response",
      raw_response_preview: @raw_response[0..200],
      parse_error: e.message
    }
  end

  private

  def clean_response(response)
    # Remove markdown wrappers
    if response.include?('```json')
      json_blocks = response.split('```json')
      return json_blocks[1].split('```')[0].strip if json_blocks.length > 1
    elsif response.include?('```')
      code_blocks = response.split('```')
      return code_blocks[1].strip if code_blocks.length > 1
    end

    # Find JSON object boundaries
    json_start = response.index('{')
    json_end = response.rindex('}')

    if json_start && json_end && json_start < json_end
      return response[json_start..json_end]
    end

    response
  end
end
