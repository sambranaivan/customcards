-- Scyther
local s,id=GetID()
function s.initial_effect(c)
    -- TODO: Programar efecto
    -- **Ability — Technician (pasivo):** Si esta carta ataca directamente al LP del oponente: inflige 200 de daño adicional. *(Scyther es un maestro de la esgrima con hojas — cada golpe directo es preciso y doloroso)* **Slash:** Una vez por turno: si esta carta tiene ATK mayor al monstruo que ataca, destruye ese monstruo en batalla y esta carta puede atacar de nuevo en la misma Battle Phase, hasta un máximo de 2 ataques por turno. *(Slash es rápido y definitivo — si Scyther es más fuerte, corta y sigue)* **Agility:** Una vez por turno *(Quick Effect)*: cuando el oponente selecciona esta carta como objetivo de un efecto, reduce el ATK de esa carta o efecto origen en 500. Si el origen es un monstruo: su ATK se reduce permanentemente. *(Agility aumenta la velocidad de Scyther — esquiva el objetivo y sale más fuerte)*
end
