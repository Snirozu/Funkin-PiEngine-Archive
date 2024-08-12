require "math"

function onPlayerHit()
    startRepeatingTimer(0.01, "ebolaLoop")
    playSound("assets/custom_notes/ebola/laugh" .. math.random(1, 4) .. ".ogg")
end

function ebolaLoop()
    setVariable("health", getVariable("health") - 0.001)
end