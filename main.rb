require 'rubygems'
require 'statemachine'

turnstile = Statemachine.build do
  trans :locked, :coin, :unlocked
  trans :unlocked, :pass, :locked
end


## Figure 1: Subway Turnstile
puts turnstile.state
turnstile.coin
puts turnstile.state
turnstile.pass  
puts turnstile.state
