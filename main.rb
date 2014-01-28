require 'rubygems'
require 'statemachine'

class TurnstileContext
  attr_accessor :thank_you_light, :alarm, :history

  def initialize
    @thank_you_light = false 
    @alarm = false 
    @history = {}
  end

  def thank_you
    puts "<< Thank you! >>" if thank_you_light
  end

  def alarm_sound
    puts "<< ALARM SOUNDING >>" if alarm
  end

  def reset_alarm_lock
    puts "<< RESET ALARM / LOCK >>"
  end

  def reset_alarm
    puts "<< ALARM OFF >>"
  end

  def thank_you_light_on
    thank_you_light = true 
    puts "Thank you light ON'"
  end

  def thank_you_light_off
    thank_you_light = false
    puts "Thank you light OFF"
  end

  def testing
    puts "--Testing--"
  end

  def set_history_pseduo_state
    puts "Entering diagnostic mode"
    #history[:state] = self.state 
    #history[:alarm] = alarm 
    #history[:light] = thank_you_light 
  end

  def get_history_pseudo_state
    self.state = history[:state]
    alarm = history[:alarm]
    thank_you_light = history[:light]
    history = {}
  end
end

turnstile = Statemachine.build do
  superstate :normal_mode do
    trans :locked, :coin, :unlocked, :thank_you
    trans :unlocked, :pass, :locked
    trans :locked, :pass, :violation, :alarm_sound
    trans :violation, :ready, :locked, :reset_alarm_lock
    trans :violation, :reset, :violation, :reset_alarm
    trans :violation, :pass, :violation
    trans :violation, :coin, :violation

    event :diagnose, :diagnostic_mode
  end

  context TurnstileContext.new

  superstate :diagnostic_mode do
    trans :test_coin, :coin, :test_pass, :thank_you_light_on
    trans :test_pass, :pass, :test_coin, :thank_you_light_off

    trans :diagnostic_mode, :test_lock, :diagnostic_mode, :testing
    trans :diagnostic_mode, :test_unlock, :diagnostic_mode, :testing
    trans :diagnostic_mode, :test_alarm, :diagnostic_mode, :testing
    trans :diagnostic_mode, :test_reset_alarm, :diagnostic_mode, :testing

    event :reset, :normal_mode
    event :return, :normal_mode
  end

end


## Figure 4: Turnstile with Diagnostic Mode. 
puts turnstile.state
turnstile.coin
puts turnstile.state
turnstile.pass  
puts turnstile.state
turnstile.pass
turnstile.pass
turnstile.coin
turnstile.ready


puts turnstile.state
turnstile.pass
turnstile.reset
puts turnstile.state


turnstile.diagnose
turnstile.coin
puts turnstile.state
turnstile.test_lock
turnstile.reset

puts turnstile.state
