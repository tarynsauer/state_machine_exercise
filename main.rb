require 'rubygems'
require 'statemachine'

class TurnstileContext
  attr_accessor :thank_you_light, :lock, :alarm, :history

  def initialize
    @thank_you_light = false
    @lock = true
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
    puts "Thank you light ON"
  end

  def thank_you_light_off
    thank_you_light = false
    puts "Thank you light OFF"
  end

  def testing
    puts "--Testing--"
  end

  def saves_device_states
    history[:state] = lock
    history[:thank_you_light] = thank_you_light
    history[:alarm] = alarm
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
    on_entry :saves_device_states
    
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
puts turnstile.state
