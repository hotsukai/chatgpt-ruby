require 'faraday'
require 'dotenv'
Dotenv.load

class ChatGPTClient
  def initialize
    @client = Faraday.new(
      url: 'https://api.openai.com/v1',
      headers: {
        'Content-Type': 'application/json', 
        Authorization: "Bearer #{ENV['OPEN_AI_API_SECRET_KEY']}"}
      ) do |f|
        f.response :json, :content_type => "application/json"
      end
  end
  
  def post_chat
    response = @client.post('chat/completions',{
      "model": "gpt-3.5-turbo",
      "messages": [{"role": "user", "content": "completionsを和訳してください"}]
    }.to_json)
    ChatGptResponse.new(response)
  end
end

class ChatGptResponse
  attr_reader :content

  def initialize(response)
    data = response.body
    @success = response.status == 200
    @used_token_count = data['usage']['total_tokens']
    @content = data['choices'][0]['message']['content']
  end
end


def talk
  pp ChatGPTClient.new.post_chat.content
end

talk()