require 'gemini-ai'

# class GeminiClient
#   DEFAULT_MODEL = 'gemini-2.0-flash'

#   def initialize(model: DEFAULT_MODEL)
#     @client = Gemini.new(
#       credentials: {
#         service: 'generative-language-api',
#         api_key: ENV['GOOGLE_API_KEY'],
#         version: 'v1beta'
#       },
#       options: { model: model }
#     )
#   end

#   def complete_with_search(prompt, max_tokens: 3000)
#     Rails.logger.info "PROMPT ➜ #{prompt}"

#     response = @client.generate_content(
#       {
#         contents: { role: 'user', parts: { text: prompt } },
#         tools: [{ 'google_search' => {} }],
#         generationConfig: { maxOutputTokens: max_tokens }
#       }
#     )

#     content = response.dig('candidates', 0, 'content', 'parts', 0, 'text')
#     usage = response['usageMetadata']

#     Rails.logger.info "RESPONSE ➜ #{content}"

#     {
#       content: content,
#       usage: {
#         input_tokens: usage['promptTokenCount'] || 0,
#         output_tokens: usage['candidatesTokenCount'] || 0,
#         total_tokens: usage['totalTokenCount'] || 0
#       },
#       status: 'success'
#     }
#   rescue => e
#     Rails.logger.error("Gemini error: #{e.message}")

#     {
#       content: "Error: #{e.message}",
#       usage: nil,
#       status: 'error'
#     }
#   end
# end

class GeminiClient
  DEFAULT_MODEL = 'gemini-2.0-flash'

  def initialize(model: DEFAULT_MODEL)
    @client = Gemini.new(
      credentials: {
        service: 'generative-language-api',
        api_key: ENV['GOOGLE_API_KEY'],
        version: 'v1beta'
      },
      options: { model: model }
    )
  end

  def complete_with_search(prompt, max_tokens: 3000)

    response = @client.generate_content(
      {
        contents: { role: 'user', parts: { text: prompt } },
        tools: [{ 'google_search' => {} }],
        generationConfig: { maxOutputTokens: max_tokens }
      }
    )

    candidate = response.dig('candidates', 0)
    content = candidate.dig('content', 'parts', 0, 'text') || ''
    usage = response['usageMetadata'] || {}
    grounding = candidate['groundingMetadata'] || {}

    data_sources = extract_data_sources(grounding)
    searches_performed = grounding['webSearchQueries'] || []
    search_results = summarize_grounding_chunks(grounding)

    Rails.logger.info "RESPONSE ➜ #{content}"

    {
      content: content,
      usage: {
        input_tokens: usage['promptTokenCount'] || 0,
        output_tokens: usage['candidatesTokenCount'] || 0,
        total_tokens: usage['totalTokenCount'] || 0
      },
      status: 'success',
      data_sources: data_sources,
      searches_performed: searches_performed,
      search_results: search_results
    }
  rescue => e
    Rails.logger.error("Gemini error: #{e.message}")

    {
      content: "Error: #{e.message}",
      usage: nil,
      status: 'error',
      data_sources: {},
      searches_performed: [],
      search_results: []
    }
  end

  private

  def extract_data_sources(grounding)
    sources = {}
    (grounding['groundingChunks'] || []).each do |chunk|
      web = chunk['web'] || {}
      title = web['title'] || web['domain'] || web['uri']
      uri = web['uri']
      sources[title] = uri if title && uri
    end
    sources
  end

  def summarize_grounding_chunks(grounding)
    (grounding['groundingChunks'] || []).map do |chunk|
      { title: chunk.dig('web', 'title') }
    end
  end
end
