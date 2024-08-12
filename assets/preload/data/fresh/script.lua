function stepHit()
    if curStep == 62 then
        setCamZoom("game", 0.5)
    end
end


function onNotePress(player, note)
    if curBeat < 16 or curBeat >= 144 then
        setCamZoom("game", 1.1)
    end
end