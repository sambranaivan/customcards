-- Mega Gyarados
local s,id=GetID()
function s.initial_effect(c)
    -- TODO: Programar efecto
    -- **Materiales:** "Gyarados" + "Gyaradosita" Al ser invocado: cambia el Atributo de todos los monstruos en el campo a DARK hasta el final del turno. *(La Mega Evolución de Gyarados lo convierte en tipo Agua/Siniestro — arrastra la oscuridad al campo entero)* **Ability — Moxie Amplificada (pasivo):** Cada vez que esta carta destruye un monstruo del oponente en batalla: gana 400 ATK permanentemente *(escala superior a Gyarados base)* y roba 1 carta. **Crunch *(Signature STAB Siniestro)*:** Una vez por turno: selecciona 1 monstruo boca arriba que controle el oponente; ese monstruo pierde 800 ATK/DEF permanentemente. Si su ATK llega a 0 o menos: es destruido. Luego, inflige 400 de daño al LP del oponente. *(Crunch — el movimiento más fiel al tipo Siniestro de Mega Gyarados: muerde, debilita permanentemente y hace daño)*
end
