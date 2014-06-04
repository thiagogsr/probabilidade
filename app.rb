require 'bundler'
Bundler.setup

require 'sinatra'
require 'haml'

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
  @result = Hash.new
  success = 0
  fail = 1
  sample = @sample.to_i
  sample.times do |a|
    value = a.to_i
    diff = sample - value;
    x = Hash.new
    19.times do |i|
      success += 0.05
      fail -= 0.05

      numerator = factorial(sample)
      denominator = factorial(value) * factorial(diff)
      multiplication = (success ** value) * (fail ** diff)

      x[value][i][:formule] = "P\left ( x=#{value} \right ) = \binom{#{sample}}{#{value}} * #{success}^#{value} * #{fail}^#{diff} = "
      x[value][i][:formule] += "\frac{#{sample}!}{#{value}!\left (#{sample}-#{value} \right )!} * #{success}^#{value} * #{fail}^#{diff} ="
      x[value][i][:result] = (numerator/denominator) * multiplication
    end
    @result << x
  end
  haml :result
end

