class ClaudeClient
  include HTTParty

  base_uri 'https://api.anthropic.com/v1'

  def initialize
    @api_key = Rails.application.credentials.claude_api_key
    @headers = {
      'Content-Type' => 'application/json',
      'x-api-key' => @api_key,
      'anthropic-version' => '2023-06-01'
    }
  end

  def complete(prompt:, max_tokens: 2000)
    response = self.class.post(
      '/messages',
      headers: @headers,
      body: {
        model: 'claude-3-sonnet-20240229',
        max_tokens: max_tokens,
        messages: [
          {
            role: 'user',
            content: build_ultra_premium_prompt(prompt, max_tokens)
          }
        ]
      }.to_json,
      timeout: 300 # 5 minutes timeout
    )

    handle_response(response)
  end

  private

  def build_ultra_premium_prompt(prompt, max_tokens)
    <<~PROMPT
      #{prompt}

      ULTRA PREMIUM ANALYSIS REQUIREMENTS:
      - Provide exhaustive analysis with specific data points and sources
      - Include quantitative metrics and industry benchmarks where applicable
      - Give actionable, specific recommendations with implementation details
      - Consider edge cases and alternative scenarios
      - Provide confidence levels for predictions and recommendations
      - Maximum #{max_tokens} tokens for comprehensive depth

      CRITICAL: Respond ONLY with valid JSON. Do not include markdown wrappers or any text outside the JSON structure.
    PROMPT
  end

  def handle_response(response)
    if response.success?
      content = response.parsed_response.dig('content', 0, 'text')
      return content if content

      raise "Invalid response structure: #{response.body}"
    else
      error_msg = response.parsed_response&.dig('error', 'message') || 'Unknown error'
      raise "Claude API error (#{response.code}): #{error_msg}"
    end
  rescue JSON::ParserError => e
    raise "Failed to parse Claude API response: #{e.message}"
  end
end
