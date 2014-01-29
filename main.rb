require 'rubygems'
require 'statemachine'

class TurnstileContext
  attr_accessor :statemachine, :thank_you_light, :state, :alarm, :history

  def initialize
    @thank_you_light = false
    @state = :locked
    @alarm = false 
    @history = {}
  end

  def check_lock
    if state == :locked
      @statemachine.state = :locked
    else
      @statemachine.state = :unlocked
    end 
  end

  def alarm_sound
    alarm = true
    puts "<< ALARM SOUNDING >>" if alarm
  end

  def reset_alarm_lock
    alarm = false
    lock = :locked
    puts "<< RESET ALARM / LOCK >>"
  end

  def reset_alarm
    alarm = false
    puts "<< ALARM OFF >>"
  end

  def thank_you_light_on
    thank_you_light = true 
    state = :unlocked
    puts "<< Thank you! >>" if thank_you_light
  end

  def thank_you_light_off
    thank_you_light = false
    state = :locked
    puts "Thank you light OFF"
  end

  def testing
    puts "--Testing--"
  end

  def saves_device_states
    history[:state] = state 
    history[:thank_you_light] = thank_you_light
    history[:alarm] = alarm
  end

  def reset_device_states
    thank_you_light = false
    alarm = false
    state = :locked
    history = {}
  end

  def restore_device_states
    thank_you_light = history[:thank_you_light]
    alarm = history[:alarm]
    state = history[:state]
    history = {}  
  end

end

turnstile = Statemachine.build do
 
  superstate :normal_mode do
    on_entry :check_lock

    trans :locked, :coin, :unlocked, :thank_you_light_on
    trans :unlocked, :pass, :locked, :thank_you_light_off
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

    event :reset, :normal_mode, :reset_device_states
    event :return, :normal_mode, :restore_device_states
  end

end

## Figure 4: Turnstile with Diagnostic Mode. 
puts turnstile.state
turnstile.coin
puts turnstile.state
turnstile.pass
turnstile.coin
puts turnstile.state

turnstile.diagnose
puts turnstile.state
turnstile.return
puts turnstile.state

