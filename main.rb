# frozen_string_literal: true

require 'faraday'
require 'dotenv'
Dotenv.load

class ChatGPTSession
  def initialize(system_statement_content = '')
    @system_statement = { role: 'system', content: system_statement_content }
    @message_histories = []
    @client = Faraday.new(
      url: 'https://api.openai.com/v1',
      headers: {
        'Content-Type': 'application/json',
        Authorization: "Bearer #{ENV['OPEN_AI_API_SECRET_KEY']}"
      }
    ) do |f|
      f.request :json
      f.response :json, content_type: 'application/json'
    end
  end

  def talk(message_content)
    @message_histories << { "role": 'user', "content": message_content }
    messages = [@system_statement] + @message_histories
    response = post(messages)

    @message_histories << { "role": 'assistant', "content": response.content }
    response.content
  end

  private

  def post(messages)
    response = @client.post('chat/completions', {
                              "model": 'gpt-3.5-turbo',
                              "messages": messages
                            })
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

def main
  chat_session = ChatGPTSession.new('You are a helpful assistant.')

  loop do
    print '>> '
    input = gets.chomp
    output = chat_session.talk(input)
    puts output.to_s
    puts '----------------------'
  end
end

main
