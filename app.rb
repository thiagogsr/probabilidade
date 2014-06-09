require 'bundler'
Bundler.setup

require 'sinatra'
require 'haml'
require 'open-uri'
require 'json'

configure { set :server, :puma }

configure { set :server, :puma }
set :public_folder, File.dirname(__FILE__) + '/public'

helpers do
  def factorial(n) (1..n).inject(1) {|r,i| r*i } end
end

get '/' do
  haml :index
end

post '/' do
  @sample = params[:sample]
  @result = {}
  sample = @sample.to_i

  (sample+1).times do |a|
    value = a.to_i
    diff = sample - value;
    success = 0.0
    fail = 1.0
    @result[value] = {}

    19.times do |i|
      success += 0.05
      fail -= 0.05
      success = success.round(2)
      fail = fail.round(2)

      numerator = factorial(sample)
      denominator = factorial(value) * factorial(diff)
      multiplication = (success ** value) * (fail ** diff)
      formule = "P\\left ( x=#{value} \\right ) = \\binom{#{sample}}{#{value}} * #{success}^{#{value}} * #{fail}^{#{diff}} = "
      formule += "\\frac{#{sample}!}{#{value}!\\left (#{sample}-#{value} \\right )!} * #{success}^{#{value}} * #{fail}^{#{diff}}"

      @result[value].merge!({
        success => {
          image: "http://latex.codecogs.com/png.latex?" + URI::encode(formule),
          result: ((numerator/denominator) * multiplication).round(4)
        }
      })
    end
  end

  haml :result
  # @result.to_json
end

