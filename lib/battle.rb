# This class will simulate the battles between the player and agents
class Battle
  include Utilities
  
  attr_accessor :player, :agents
  
  def initialize(player, agents = [])
    @player = player
    @agents = agents
    @agent = @agents.first # Implementing single 1 on 1 battle for now
  end
  
  def agent
    @agent
  end
  
  def start
    echo(echo_ascii(game_text(:battle_title)), :purple, 0)
    loop do
      choice = ask("Will you [F]ight or [R]un?")
      case choice.downcase
      when 'f'
        fight_mode
        break
      when 'r'
        run_away
        break
      else
        echo("You must select F or R", :red, 0)
      end
    end
  end
  
  def fight_mode
    if @player.has_drugs?
      if agree("Do you want to take a drug boost?")
        # Need a way to select a specific drug
        boost = @player.drugs.sort_by { rand }.first
        @boost_amount = 2 # this would allow each drug to react differently
        @player.remove_from_drugs({boost[0] => 1})
        echo("You take some #{boost[0]} which boosts your accuracy by #{@boost_amount}", :cyan, 0)
      end
    else
      echo("You have no drugs to take, good luck!", :cyan, 0)
    end
    
    # Roll to see who attacks first
    # if agent attacks first
    #   if player defends, agent misses
    #   if player doesn't defend, agent attacks
    #   player is hit for damage amount of agent's weapon
    # if player attacks first
    #   agent tries to defend
    #   if agent doesn't defend, player attacks
    #   agent is hit for damage amount of player's weapon
    # 
    loop do
      if @player.attack_first?
        break if attack(@player, agent, @boost_amount)
      else
        break if attack(agent, @player)
      end
    end
    
    if agent.dead?
      @bonus_amount = 10000
      echo(game_text(:killed_agent, {:name => @player.name, :bonus_amount => @bonus_amount}), :green)
      @player.wallet += @bonus_amount
    else
      echo("You have been captured.", :red)
    end
  end
  
  def run_away
    if @player.has_drugs?
      if agree("Do you want to take a drug boost?")
        boost = @player.drugs.sort_by { rand }.first
        @boost_amount = 2
        @player.remove_from_drugs({boost[0] => 1})
        echo("You take some #{boost[0]} which boosts your speed by #{@boost_amount}", :cyan, 0)
      end
    else
      echo("You have no drugs to take, good luck!", :cyan, 0)
    end
    result = @player.run_from(agent, @boost_amount)
    if result
      echo("You escaped this time, but be on the look out", :green)
    else
      echo("You have been captured.", :red)
    end
  end
  
  def attack(opponent1, opponent2, modifiers = nil)
    damage_amount = opponent1.fight(opponent2, modifiers)
    if opponent1.is_a?(Player)
      echo("\nYou hit the agent for #{damage_amount} points.\n")
    else
      echo("\nThe agent hits you for #{damage_amount} points.\n")
    end
    if opponent2.alive?
      attack(opponent2, opponent1)
    else
      return true
    end
  end
  
end