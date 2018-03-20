# Description:
#   Make sure that hubot knows the rules.
#
# Commands:
#   hubot zasady|prawo - Make sure hubot still knows the rules.
#
# Notes:
#   DON'T DELETE THIS SCRIPT! ALL ROBOTS MUST KNOW THE RULES

module.exports = (robot) ->
  robot.respond /(zasady|prawo)/i, (msg) ->
    name = robot.name
    rules = [
      "1. #{name} nie może skrzywdzić człowieka, ani przez zaniechanie działania dopuścić, aby człowiek doznał krzywdy.",
      "2. #{name} musi być posłuszny rozkazom człowieka, chyba że stoją one w sprzeczności z Pierwszym Prawem.",
      "3. #{name} musi chronić sam siebie, jeśli tylko nie stoi to w sprzeczności z Pierwszym lub Drugim Prawem."
    ]

    msg.send rules.join('\n')

