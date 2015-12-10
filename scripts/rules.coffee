# Description:
#   Make sure that hubot knows the rules.
#
# Commands:
#   hubot zasady|prawo - Make sure hubot still knows the rules.
#
# Notes:
#   DON'T DELETE THIS SCRIPT! ALL ROBAWTS MUST KNOW THE RULES

rules = [
  "1. Robot nie może skrzywdzić człowieka, ani przez zaniechanie działania dopuścić, aby człowiek doznał krzywdy.",
  "2. Robot musi być posłuszny rozkazom człowieka, chyba że stoją one w sprzeczności z Pierwszym Prawem.",
  "3. Robot musi chronić sam siebie, jeśli tylko nie stoi to w sprzeczności z Pierwszym lub Drugim Prawem."
  ]

module.exports = (robot) ->
  robot.respond /(zasady|prawo)/i, (msg) ->
    msg.send rules.join('\n')

