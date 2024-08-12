function onPlayerHit()
    playSound("assets/custom_notes/damage/mc_splat.ogg")
    if getSelfField("actionValue") == nil or getSelfField("actionValue") == "" then
        setVariable("health", getVariable("health") - 0.3)
    else
        setVariable("health", getVariable("health") - getSelfField("actionValue"))
    end
    if spriteExists("hurt_vignete") == false then
        addSprite("hurt_vignete", "assets/custom_notes/damage/hurt_vignete.png", 0, 0)
    else
        setSpriteProperty("hurt_vignete", "alpha", 1)
    end
    --tweenSpriteProperty("hurt_vignete", "alpha", 0, 1, "removeVignete")
    tweenSpriteProperty("hurt_vignete", "alpha", 0, 1)
    spriteSetScrollFactor("hurt_vignete", 0, 0)
    spriteSetCamera("hurt_vignete", "hud")
    characterPlayAnimation("bf", "hit")
end

function removeVignete()
    removeSprite("hurt_vignete")
end