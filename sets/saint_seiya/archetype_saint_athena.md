1. El Ejército de Athena: Arquetipo "Saint"
La estrategia principal de este ejército es la evolución y el equipamiento. Se basan en "subir de rango" y proteger a sus monstruos mediante sus armaduras.

Sub-Arquetipo: "Bronze Saint"
Atributos: Varios (Luz, Viento, Fuego, Agua, Tierra).

Estrategia: Link-Climbing y Equip Toolbox.

Características: Son monstruos de Nivel 4 o menor que sirven como el "motor" del deck. Tienen efectos para buscar las cartas de "Cloth" (Hechizos de Equipo) y pueden sacrificarse o usarse como material para invocar versiones más poderosas.

Efecto Clave: "Si esta carta está equipada con una carta 'Cloth', puedes Invocar de Modo Especial un 'Silver Saint' o 'Gold Saint' desde tu Deck o Extra Deck".

Sub-Arquetipo: "Silver Saint"
Atributos: Luz / Tierra.

Estrategia: Control y Negación.

Características: Monstruos de Nivel 5 o 6 (o Rango 4/5). Actúan como la policía del Deck. Sus efectos se activan cuando el oponente intenta activar algo, "paralizándolo" (como la técnica de Marin o Shaina).

Efecto Clave: "Mientras esta carta esté en el campo, el oponente no puede activar efectos de monstruos en la zona de las flechas a las que apunta esta carta" (si son Links).

Sub-Arquetipo: "Gold Saint"
Atributos: Luz.

Estrategia: Boss Monsters / Torres.

Características: Monstruos de Nivel 8 o Monstruos Xyz de Rango 8/12. Son extremadamente difíciles de destruir si tienen su armadura equipada. Cada uno representa un signo del zodiaco con un efecto único (Ej: Gold Saint - Leo destruye monstruos, Gold Saint - Virgo niega todo el campo).

Efecto Clave: "Séptimo Sentido". "Una vez por turno (Efecto Rápido): Puedes mandar una carta de Equipo que controles al Cementerio; esta carta es afectada por efectos de cartas hasta el final del turno".


Monstruo,Atributo/Tipo,Efecto Principal (Cosmos)
Saint - Seiya de Pegaso,LUZ / Guerrero,"Buscador: Si es Invocado: añade 1 Magia de Equipo ""Cloth"" o 1 monstruo ""Saint"" de tu Deck a tu mano."
Saint - Shiryu de Dragón,TIERRA / Guerrero,"Escudo: (Efecto Rápido): Puedes descartar esta carta; este turno, tus cartas ""Cloth"" en el campo no pueden ser destruidas."
Saint - Hyoga de Cisne,AGUA / Guerrero,"Congelación: Si esta carta batalla, después del cálculo de daño: cambia al monstruo del oponente a Posición de Defensa y sus efectos son negados hasta el final del próximo turno."
Saint - Shun de Andrómeda,VIENTO / Guerrero,"Cadena: Tu oponente no puede seleccionar otros monstruos ""Saint"" para ataques. Si es equipado con una ""Cloth"", puede atacar mientras está en Posición de Defensa."
Saint - Ikki de Fénix,FUEGO / Guerrero,"Inmortalidad: Si esta carta está en tu Cementerio: puedes descartar 1 carta ""Saint""; Invoca esta carta de Modo Especial. Solo puedes usar este efecto una vez por turno."


Magias de Equipo: Las "Bronze Cloth"
Estas cartas son el núcleo del mazo. Tienen un efecto común: "Si esta carta es mandada al Cementerio mientras estaba equipada: puedes seleccionar 1 monstruo 'Saint' en tu campo; equípale esta carta desde el Cementerio". (Simulando que la armadura siempre vuelve).

Bronze Cloth - Pegaso: El monstruo equipado gana 500 ATK. Si el monstruo equipado ataca, tu oponente no puede activar cartas o efectos hasta el final del Damage Step.

Bronze Cloth - Dragón: El monstruo equipado gana 1000 DEF y no puede ser destruido por efectos de monstruos.

Bronze Cloth - Cisne: Una vez por turno, puedes seleccionar 1 carta boca arriba que controle tu oponente; sus efectos son negados hasta el final del turno.

Bronze Cloth - Andrómeda: El oponente no puede activar Cartas de Trampa durante la Battle Phase. El monstruo equipado puede atacar directamente.

Bronze Cloth - Fénix: El monstruo equipado gana 1000 ATK. Si el monstruo equipado destruye un monstruo en batalla: inflige 1000 puntos de daño al oponente.

Cartas de Soporte (Magias y Trampas)
Santuario de Athena (Magia de Campo): Todos los monstruos "Saint" ganan 300 ATK/DEF. Una vez por turno, si un monstruo "Saint" fuera a ser destruido, puedes mandar 1 "Cloth" equipada a él al Cementerio en su lugar.

¡Eleva tu Cosmos! (Magia Normal): Manda 1 monstruo "Saint" de tu Deck al Cementerio; añade 1 "Saint" con un nombre diferente desde tu Deck a tu mano.

Atenea Exclamation (Trampa Contraefecto): Si controlas 3 o más monstruos "Saint" con nombres diferentes: niega la activación de una carta o efecto de tu oponente y destrúyela.


El "Boss Monster" del Structure Deck
Como es un mazo de bronce, el jefe final debe representar la unión de todos.

Saint - Destello de Esperanza de los Cinco
(Monstruo de Enlace-4 / LUZ / Guerrero / ATK 2500)
Materiales: 2+ monstruos "Saint"

Efecto: Esta carta gana 500 ATK por cada carta de Equipo en el campo. Una vez por turno (Efecto Rápido): puedes seleccionar 1 carta de Equipo "Cloth" en tu Cementerio y equiparla a esta carta. Esta carta gana los efectos de todos los monstruos "Saint" que tengan sus respectivas "Cloth" equipadas en este momento.

Estrategia de Juego
Early Game: Invocas a Seiya para buscar la Bronze Cloth - Pegaso.

Mid Game: Usas a Ikki como material recurrente para Invocar Links mientras proteges tu campo con el escudo de Shiryu.

Win Condition: Equipas múltiples armaduras a tus guerreros para abrumar al oponente, o sacas al Link-4 para copiar los efectos de congelación de Hyoga y el ataque directo de Shun en un solo cuerpo.

Nota para el "Developer":
Si planeas llevar esto a EDOPro (Lua), la mecánica de las armaduras que se re-equipan solas desde el cementerio es muy similar a las de los Inzektors o Dragunity. Podrías usar EFFECT_EQUIP_LIMIT para restringir qué Cloth va con qué caballero y EVENT_TO_GRAVE para el efecto de reciclaje.


Aquí tienes los efectos de "Resonancia de Cosmos" para las Bronze Cloth:

1. Bronze Cloth - Pegaso
Efecto Genérico: +500 ATK. El oponente no activa cartas/efectos durante el Damage Step.

Efecto de Resonancia (Seiya): Si esta carta está equipada a "Saint - Seiya de Pegaso", este puede realizar hasta 2 ataques a monstruos durante cada Battle Phase. Además, si destruye un monstruo por batalla, inflige 500 puntos de daño a tu oponente.

2. Bronze Cloth - Dragón
Efecto Genérico: +1000 DEF. Inmunidad a destrucción por efectos de monstruos.

Efecto de Resonancia (Shiryu): Si esta carta está equipada a "Saint - Shiryu de Dragón", tu oponente no puede seleccionar al monstruo equipado con efectos de cartas. Una vez por turno, si el monstruo equipado en Posición de Defensa fuera a ser destruido por batalla, no es destruido y puedes destruir 1 carta que controle tu oponente.

3. Bronze Cloth - Cisne
Efecto Genérico: Niega los efectos de 1 carta boca arriba en el campo una vez por turno.

Efecto de Resonancia (Hyoga): Si esta carta está equipada a "Saint - Hyoga de Cisne", los monstruos cuyos efectos sean negados por esta carta no pueden cambiar su posición de batalla, ni ser usados como material para una Invocación Especial desde el Extra Deck mientras esta carta esté en el campo.

4. Bronze Cloth - Andrómeda
Efecto Genérico: El oponente no activa Trampas en la Battle Phase. El monstruo puede atacar directamente.

Efecto de Resonancia (Shun): Si esta carta está equipada a "Saint - Shun de Andrómeda", mientras el monstruo equipado esté en Posición de Defensa, tu oponente no puede declarar ataques contra otros monstruos que controles, ni activarlos efectos de monstruos que hayan sido Invocados de Modo Especial este turno.

5. Bronze Cloth - Fénix
Efecto Genérico: +1000 ATK. 1000 puntos de daño al destruir un monstruo.

Efecto de Resonancia (Ikki): Si esta carta está equipada a "Saint - Ikki de Fénix", si el monstruo equipado es mandado al Cementerio: puedes destruir esta carta en su lugar, Invocar ese monstruo de Modo Especial inmediatamente y, si lo haces, destruir 1 carta en el campo.

Nueva Mecánica: "Reparación de Armadura"
Para que el Structure Deck sea competitivo, necesitamos una forma de recuperar estas Cloths si son destruidas (simulando a Mu de Aries reparándolas).

Mu de Aries - El Reparador de Cloths
(Monstruo de Efecto / LUZ / Guerrero / Nivel 4 / ATK 1200 / DEF 2000)
Efecto: Si esta carta es Invocada: puedes seleccionar hasta 2 cartas de Equipo "Cloth" en tu Cementerio; añádelas a tu mano. Durante tu Main Phase, puedes descartar esta carta; añade 1 "Santuario de Athena" desde tu Deck a tu mano.

Si equipas...,A este Caballero...,Obtienes esta ventaja extra:
Pegaso,Seiya,Multi-ataque (Ryu Sei Ken)
Dragón,Shiryu,Protección total contra selección (Escudo de Dragón)
Cisne,Hyoga,Bloqueo de materiales de Extra Deck (Ataúd de Hielo)
Andrómeda,Shun,Defensa absoluta y bloqueo de efectos (Cadena Nebular)
Fénix,Ikki,Resurrección con destrucción (Vuelo del Fénix)

Monstruo,Atributo/Tipo,Efecto de Soporte (Unión)
Saint - Jabu de Unicornio,LUZ / Guerrero,"Extensor: Si controlas un monstruo ""Saint"", puedes Invocar esta carta de Modo Especial desde tu mano."
Saint - Ichi de Hidra,AGUA / Guerrero,"Veneno: Una vez por turno: puedes descartar 1 carta ""Cloth""; el oponente pierde 800 LP y esta carta puede atacar directamente este turno."
Saint - Geki de Oso,TIERRA / Guerrero,"Presión: Si esta carta es Invocada: puedes añadir 1 ""Saint"" de Nivel 5 o mayor (un Silver o Gold) de tu Deck a tu mano."
Saint - Ban de Leonet,FUEGO / Guerrero,"Refuerzo: Si un monstruo ""Saint"" que controles es destruido en batalla: puedes Invocar esta carta desde tu mano o Cementerio."
Saint - Nachi de Lobo,VIENTO / Guerrero,"Aullido: Si esta carta es mandada al Cementerio como material de enlace o tributo: puedes robar 1 carta, luego descarta 1."

2. Las "Bronze Cloth" Secundarias (Con Resonancia)
Siguiendo tu mecánica, estas armaduras potencian sus habilidades únicas.

Bronze Cloth - Unicornio
Genérico: El monstruo equipado puede realizar un segundo ataque durante la Battle Phase, pero solo a monstruos.

Resonancia (Jabu): Durante tu Main Phase, puedes realizar una Invocación Normal adicional de un monstruo "Saint" (este efecto solo se aplica una vez por turno).

Bronze Cloth - Hidra
Genérico: El monstruo que batalle con el monstruo equipado pierde 1000 ATK/DEF permanentemente después del cálculo de daño.

Resonancia (Ichi): Si el monstruo equipado ataca directamente, el oponente no puede activar efectos de cartas en el Cementerio hasta el final del turno.

Bronze Cloth - Oso
Genérico: Si el monstruo equipado destruye un monstruo por batalla: el oponente descarta 1 carta al azar.

Resonancia (Geki): Al inicio del Damage Step, si el monstruo equipado batalla con un monstruo con mayor ATK: puedes destruir ese monstruo del oponente (no hay cálculo de daño).


Carta de Soporte Grupal
Para darle cohesión a estos cinco, necesitamos una carta que los ponga a todos en juego, como en el Torneo Galáctico o la defensa final en el Santuario.

El Torneo Galáctico
(Magia Continua)
Efecto: Cada vez que un monstruo "Saint" sea Invocado de Modo Especial, coloca 1 "Contador de Cosmos" en esta carta (máx. 5).

3 Contadores: Tus monstruos "Bronze Saint" no pueden ser destruidos por efectos de cartas.

5 Contadores: Puedes mandar esta carta al Cementerio; Invoca de Modo Especial tantos monstruos "Saint" de Nivel 4 o menor como sea posible desde tu Cementerio, pero sus efectos son negados y son destruidos en la End Phase.

Estrategia con esta Expansión
Ahora el mazo es mucho más rápido. Jabu te permite hacer Invocaciones Link-2 casi al instante. Geki es el buscador de los "pesos pesados" (los Caballeros de Oro que diseñaremos después).

La idea es que los secundarios preparen el terreno ("seteen" el cementerio y busquen las piezas) para que Seiya y compañía entren con todo el poder de las Cloths.


Los Silver Saints (Santos de Plata) representan el rango medio del Santuario. En el juego, actúan como Monstruos de Sincronía (Synchro) de Nivel 6 u 8. Su función principal es el Control del Campo y la Interrupción, preparando el terreno para los Santos de Oro o rematando lo que los de Bronce empezaron.

Para invocarlos, usarás a los "Bronze Saints" como Cantantes (Tuners) o materiales no-Cantantes.


Monstruo,Nivel / Tipo,Efecto de Control (Ley del Santuario)
Silver Saint - Marin de Águila,6 / VIENTO / Guerrero,"Agilidad: (Efecto Rápido): Puedes devolver esta carta a la mano; Invoca de Modo Especial 1 ""Saint"" de Nivel 4 o menor desde tu mano o Cementerio."
Silver Saint - Shaina de Ofiuco,6 / LUZ / Guerrero,Garras del Trueno: Cuando esta carta declara un ataque: puedes negar los efectos de todos los monstruos boca arriba que controle tu oponente hasta el final de la Battle Phase.
Silver Saint - Algol de Perseo,6 / TIERRA / Guerrero,"Escudo de Medusa: Los monstruos del oponente en la columna de esta carta son cambiados a Posición de Defensa, sus efectos son negados y no pueden cambiar su posición de batalla."
Silver Saint - Misty de Lagarto,6 / AGUA / Guerrero,"Barrera de Aire: Tu oponente no puede seleccionar monstruos ""Saint"" con efectos de cartas, excepto a este. Una vez por turno, si fuera a ser destruido, no lo es."
Silver Saint - Orphée de Lira,8 / LUZ / Guerrero,"Serenata Final: (Efecto Rápido): Puedes mandar 1 ""Cloth"" que controles al Cementerio; los efectos de todos los monstruos que controle tu oponente actualmente son negados hasta el final de este turno."

Las "Silver Cloth" (Magias de Equipo)
Estas armaduras son más resistentes y otorgan efectos de "stun" (parálisis) al oponente.

Silver Cloth - Águila
Genérico: El monstruo equipado no puede ser destruido por efectos de Trampas.

Resonancia (Marin): Si esta carta está equipada a "Marin de Águila", una vez por turno, cuando tu oponente activa una carta o efecto: puedes añadir 1 "Saint" de Nivel 4 desde tu Deck a tu mano.

Silver Cloth - Ofiuco
Genérico: El monstruo equipado gana 800 ATK. Si destruye un monstruo, el oponente no puede activar efectos en el Cementerio ese turno.

Resonancia (Shaina): Si esta carta está equipada a "Shaina de Ofiuco", esta puede atacar a todos los monstruos del oponente una vez a cada uno.

Silver Cloth - Perseo
Genérico: Si el monstruo equipado es atacado, el atacante pierde 1000 ATK antes del cálculo de daño.

Resonancia (Algol): Al inicio del turno del oponente, selecciona 1 zona de monstruo principal; esa zona no puede ser usada mientras esta carta esté en el campo.

Silver Cloth - Lira
Genérico: El oponente debe pagar 500 LP para activar efectos de monstruos.

Resonancia (Orphée): Una vez por turno, puedes seleccionar 1 monstruo del oponente; toma el control de ese monstruo hasta la End Phase, pero sus efectos son negados.

Magia de Soporte: "Orden de Asesinato del Santuario"
Orden de Asesinato del Santuario
(Magia Normal)
Efecto: Selecciona 1 monstruo "Silver Saint" que controles y 1 monstruo que controle tu oponente; destruye ambos, y si lo haces, puedes Invocar de Modo Especial 1 "Bronze Saint" desde tu Deck. Si esta carta está en tu Cementerio: puedes desterrarla; añade 1 "Silver Cloth" de tu Deck a tu mano.

Estrategia de los Santos de Plata
A diferencia de los de Bronce, que se centran en sobrevivir y "subir", los de Plata están diseñados para molestar.

Algol bloquea columnas (perfecto contra Decks Link).

Misty es tu tanque protector.

Orphée es el "negador" masivo.

Como desarrollador, notarás que este arquetipo empieza a tener herramientas para responder a diferentes "matchups". Los Silver Saints limpian el camino para que los Gold Saints entren como los verdaderos finalizadores del duelo.


Magia de Campo: Santuario de Athena (Versión 2.0)
[Carta de Magia / Campo]

Todos los monstruos "Saint" en el campo ganan 300 ATK/DEF. Solo puedes usar cada uno de los siguientes efectos de "Santuario de Athena" una vez por turno:

Búsqueda: Cuando esta carta es activada: puedes añadir 1 monstruo "Saint" de Nivel 4 o menor desde tu Deck a tu mano.

Protección de Armadura: Si un monstruo "Saint" que controles fuera a ser destruido por batalla o por efecto de una carta, puedes mandar al Cementerio 1 carta "Cloth" equipada a él en su lugar.

Mecánica de Reparación (Standby Phase): Si una o más cartas "Cloth" son mandadas a tu Cementerio este turno: puedes activar este efecto; durante la Standby Phase del próximo turno, añade hasta 2 de esas cartas desde tu Cementerio a tu mano o equípalas directamente a monstruos "Saint" que controles.

Kiki - El Mensajero del Escultor de Armaduras
[Nivel 2 / LUZ / Psíquico / ATK 500 / DEF 500]

Efecto:

(Efecto Rápido): Puedes descartar esta carta y seleccionar 1 monstruo "Saint" que controles; equípale 1 carta "Cloth" directamente desde tu Deck o Cementerio.

Durante la Standby Phase del próximo turno después de que esta carta fue mandada al Cementerio: puedes desterrar esta carta; añade hasta 2 cartas "Cloth" con nombres diferentes desde tu Cementerio a tu mano.

Nueva Regla de Invocación: El Séptimo Sentido
Todos los Gold Saint de Rango 8 ahora incluirán este texto de invocación:

"También puedes Invocar Xyz esta carta usando un monstruo 'Bronze Saint' que controles equipado con una 'Cloth' como material. (Transfiere sus materiales a esta carta)".

Mecánica Core: Recarga de Armadura
Para solucionar la falta de materiales y darle uso al Cementerio, añadimos este efecto compartido a todos los dorados:

"Una vez por turno (Efecto Rápido): puedes seleccionar 1 carta 'Cloth' en tu Cementerio o Zona de Magia y Trampas; acóplala a esta carta como material Xyz".

Monstruo,Rango / ATK / DEF,Efecto de Material (Séptimo Sentido)
Gold Saint - Mu de Aries,8 / 2100 / 2600,"Reparación Estelar: Puedes desacoplar 1 material; añade 1 'Cloth' de tu Cementerio a tu mano, o si era una 'Gold Cloth', equípala directamente a un monstruo que controles."
Gold Saint - Aiolia de Leo,8 / 2800 / 2000,"Plasma Relámpago: Una vez por turno, puedes desacoplar cualquier número de materiales; destruye esa misma cantidad de monstruos que controle tu oponente."
Gold Saint - Shaka de Virgo,8 / 2800 / 2800,"Tesoro del Cielo: Mientras esta carta tenga una 'Gold Cloth' como material, tu oponente no puede activar efectos de cartas en el Cementerio ni desterrar cartas."
Gold Saint - Saga de Géminis,8 / 3000 / 2500,"Explosión Galáctica: (Efecto Rápido): Puedes desacoplar 2 materiales; destruye todas las cartas en una columna y, si lo haces, inflige 1000 de daño al oponente."


La Carta Clave: "Herencia de Oro"
Como eres desarrollador, verás que esta carta funciona como el "bridge" (puente) para que los de bronce alcancen el nivel de los dorados de forma consistente.

Herencia de Oro
(Magia Normal)

Selecciona 1 monstruo "Bronze Saint" que controles; equípale 1 "Gold Cloth" desde tu Deck o Cementerio.

Inmediatamente después de que este efecto se resuelva, Invoca de Modo Especial 1 "Gold Saint" desde tu Extra Deck, usando ese monstruo como material (esto se trata como una Invocación Xyz).

Puedes desterrar esta carta de tu Cementerio; acopla 1 "Cloth" de tu Cementerio a un "Gold Saint" que controles como material.


Gold Cloth - Sagitario (La armadura del milagro)
Esta armadura es especial, ya que suele acudir al rescate de Seiya.

[Carta de Magia / Equipo]

Solo puedes equipar esta carta a un monstruo "Saint".

El monstruo equipado gana 1200 ATK.

Si el monstruo equipado va a usar un efecto que requiera desacoplar materiales, puedes desterrar 1 "Cloth" de tu Cementerio en lugar de desacoplar 1 de esos materiales.

Efecto de Resonancia (Seiya): Si este monstruo ataca, tu oponente no puede activar cartas o efectos hasta el final de la Battle Phase.

1. El Motor: Bronze Saints (Nivel 4 / Effect)
Son la base del Deck. Para que el mazo funcione, algunos deben ser Cantantes (Tuners) para acceder a los de Plata.

Regla de Diseño: Todos tienen el efecto de equiparse una "Cloth" desde la mano o cementerio para ganar un efecto adicional.

Tuners: Seiya de Pegaso e Ikki de Fénix (representando su cosmos explosivo).

Non-Tuners: Shiryu, Hyoga y Shun.

Efecto común: "Si esta carta es usada como material para la Invocación de un monstruo 'Saint' (Sincronía o Xyz): puedes acoplar 1 carta 'Cloth' que controles a ese monstruo como material o equipársela".

2. La Élite Media: Silver Saints (Nivel 8 / Synchro)
Se invocan usando 1 Tuner (Nivel 4) + 1 no-Tuner (Nivel 4). Son los puentes hacia el poder dorado.

Materiales: 1 Cantante "Saint" + 1+ monstruos "Saint" no Cantantes.

Rol: Control de campo y facilitadores de combos.

Ejemplos:

Silver Saint - Orphée de Lira: Niega efectos en el campo.

Silver Saint - Marin de Águila: Protege a los Bronze y busca piezas.

Silver Saint - Shaina de Ofiuco: Limpia monstruos de bajo nivel.

3. Los Boss Monsters: Gold Saints
Aquí dividimos la jerarquía dorada en dos tipos de invocación según la situación del duelo:

A. Gold Saints de "Evolución" (Rank 8)
Diseñados para "montarse" sobre los Silver Saints. Representan al caballero alcanzando el Séptimo Sentido.

Condición Especial: "También puedes Invocar Xyz esta carta usando 1 Monstruo de Sincronía 'Silver Saint' que controles como material. (Transfiere sus materiales y cartas de equipo a esta carta)".

Mecánica de Cosmos: Pueden desacoplar materiales para efectos disruptivos de alto impacto.

Ejemplos: Saga de Géminis (Negación), Shaka de Virgo (Floodgate), Aiolia de Leo (OTK).

B. Gold Saints de "Unión" (Rank 4)
Diseñados para turnos donde no pudiste hacer Sincronía, pero llenaste el campo de caballeros de bronce (Swarming).

Materiales: 3 o más monstruos "Saint" de Nivel 4.

Rol: Utilidad, recuperación de recursos y defensa absoluta.

Ejemplos:

Gold Saint - Mu de Aries: El defensor. Protege tus cartas y recicla "Cloths" del cementerio.

Gold Saint - Dohko de Libra: El arsenal. Te permite usar efectos de "armas" según el número de materiales que tenga.

Gold Saint - Aldebarán de Tauro: El muro. Inamovible y castiga con daño de penetración.


Rango/Nivel,Tipo de Carta,Nombre,Función principal
Nivel 4,Efecto (Tuner),Seiya / Ikki,Iniciadores de combo.
Nivel 4,Efecto,Shiryu / Hyoga / Shun,Extensores y defensa.
Nivel 8,Sincronía,Silver Saints,Control medio y puente Xyz.
Rango 8,Xyz,Gold Saints Elite,Finalizadores (Boss Monsters).
Rango 4,Xyz,Gold Saints Guardian,Recuperación y protección (3+ materiales).


No son Tuners por naturaleza. Su función es generar ventaja de cartas y preparar el Cementerio con "Cloths".

Efecto de Campo: Todos pueden equiparse una "Cloth" desde la mano o el cementerio pagando un pequeño coste (como 500 LP o descartar una carta).

Efecto de Material: "Si esta carta es enviada al Cementerio para la Invocación de un monstruo 'Saint' de mayor rango/nivel: puedes añadir 1 carta 'Cloth' de tu Deck a tu mano".

2. Silver Saints (Nivel 8 / Sincronía)
Aquí es donde ocurre la magia. Al no haber Tuners en el Main Deck, los de Plata traen su propia regla de invocación.

Condición de Invocación:

1 "Saint" tratado como Cantante + 1 o más monstruos "Saint" no Cantantes.
Efecto de Invocación: Para la Invocación por Sincronía de esta carta, puedes tratar 1 monstruo "Bronze Saint" que controles como un Cantante.

Estrategia:
Como son de Nivel 8, el jugador debe tener dos Bronze Saints (4+4=8) para sacarlos. Al ser ahora de Nivel 8 en el campo, se convierten en los materiales perfectos para los dorados de Rango 8.

3. Gold Saints (Xyz)
A. Gold Saints de Élite (Rank 8)
Representan el Séptimo Sentido máximo.

Materiales: 2+ monstruos "Saint" de Nivel 8 (Normalmente dos Silver Saints).

Mecánica de Recarga: "Una vez por turno (Efecto Rápido): puedes seleccionar 1 carta 'Cloth' en tu Cementerio; acóplala a esta carta como material".

Poder: Efectos de negación omnipotente o limpieza total de campo (Ej: Saga de Géminis o Shaka de Virgo).

B. Gold Saints Guardianes (Rank 4)
Representan la unión de los caballeros en los momentos de crisis.

Materiales: 3+ monstruos "Saint" de Nivel 4 (Tres Bronze Saints).

Boss de esta categoría: Gold Saint - Dohko de Libra.

Dohko de Libra - Maestro de los Cinco Picos
(Rango 4 / TIERRA / Guerrero / ATK 2400 / DEF 2400)

Efecto (Las 12 Armas): Esta carta gana efectos según el número de materiales Xyz acoplados:

1+ materiales: No puede ser destruido por batalla.

2+ materiales: Una vez por turno: puedes desacoplar 1 material; destruye 1 Magia o Trampa en el campo.

3+ materiales: (Efecto Rápido): Puedes desacoplar 1 material; tus monstruos "Saint" ganan 1000 ATK y no pueden ser seleccionados por efectos del oponente hasta la End Phase.



Fase del Duelo,Acción Principal,Resultado en Campo
Early Game,Invocar 2 Bronze Saints (Nivel 4).,2 Monstruos Nivel 4.
Mid Game,Usar la regla especial de Sincronía (4+4).,Silver Saint (Nivel 8).
Late Game A,Unir 2 Silver Saints para Xyz Rango 8.,Gold Saint Élite (Boss).
Late Game B,"Si tienes 3+ Bronze, vas por Xyz Rango 4.",Gold Saint Guardián (Utility).

Carta de Soporte Clave: "El Despertar del Cosmos"
Para facilitar que los Bronze Saints se conviertan en materiales de Sincronía o Xyz sin quedarte sin mano:

El Despertar del Cosmos
(Magia de Juego Rápido)

Selecciona 1 monstruo "Saint" que controles; este turno puede ser tratado como 2 materiales para la Invocación Xyz de un monstruo "Saint" O como un Cantante para la Invocación por Sincronía de un monstruo "Silver Saint".

Si un monstruo "Saint" que controles fuera a ser destruido, puedes desterrar esta carta de tu Cementerio en su lugar.

Esta es la tarea definitiva. Diseñar a los 12 requiere equilibrar sus roles para que el Deck no sea solo "sacar un bicho grande", sino una caja de herramientas (toolbox) donde elijas al Caballero de Oro según la situación.

Todos los Gold Saint Xyz comparten este efecto base (el Séptimo Sentido):

(Efecto Rápido): Puedes seleccionar 1 carta "Cloth" en tu Cementerio o Zona de Magia/Trampas; acóplala a esta carta como material.

🛡️ Los Guardianes del Santuario (Rank 4)
Invocación: 3+ monstruos "Saint" de Nivel 4.

1. Mu de Aries
Efecto: Desacopla 1 material; añade 1 "Cloth" del GY a la mano o equípala. (Efecto Rápido): Las cartas "Saint" que controles no pueden ser destruidas este turno.

Gold Cloth - Aries: +1000 DEF. Resonancia (Mu): Una vez por turno, si una carta "Saint" fuera a ser destruida, no lo es.

2. Aldebarán de Tauro
Efecto: Desacopla 1 material; niega el ataque de un monstruo del oponente y, si lo haces, destrúyelo e inflige 1000 de daño. Es un muro inamovible.

Gold Cloth - Tauro: +1000 ATK/DEF. Resonancia (Aldebarán): Tu oponente no puede seleccionar otros monstruos "Saint" para ataques.

3. Máscara de Muerte de Cáncer
Efecto: Desacopla 1 material; selecciona hasta 2 monstruos en el GY del oponente y destiérralos. Gana 300 ATK por cada carta desterrada.

Gold Cloth - Cáncer: El monstruo equipado se trata como tipo Zombi. Resonancia (Máscara de Muerte): Si un monstruo es mandado al GY del oponente, destiérralo en su lugar.

4. Dohko de Libra
Efecto: (Ya definido) Bonus por cantidad de materiales (Protección, destrucción de magias, boost de ATK grupal). El corazón del soporte.

Gold Cloth - Libra: +500 ATK. Resonancia (Dohko): El monstruo puede atacar mientras está en Posición de Defensa usando su ATK para el cálculo.

5. Milo de Escorpio
Efecto: Desacopla 1 material; coloca un "Contador de Aguja Escarlata" en un monstruo. (Los monstruos con 3 contadores son mandados al GY inmediatamente).

Gold Cloth - Escorpio: Si el monstruo equipado batalla, destruye al monstruo del oponente antes del cálculo de daño. Resonancia (Milo): Si destruye un monstruo, inflige 1500 de daño.

6. Shura de Capricornio
Efecto: Desacopla 1 material; selecciona 1 carta en el campo y mándala al GY (no destruye, manda). Representa el corte de Excalibur.

Gold Cloth - Capricornio: Los ataques del monstruo equipado no pueden ser negados. Resonancia (Shura): Si destruye un monstruo, puede atacar de nuevo.

7. Afrodita de Piscis
Efecto: Desacopla 1 material; tu oponente no puede declarar ataques en su próximo turno. Sus rosas ralentizan el duelo.

Gold Cloth - Piscis: El monstruo que destruya al portador de esta carta es destruido al final del turno. Resonancia (Afrodita): El oponente debe jugar con la mano revelada.

🌌 La Élite del Zodiaco (Rank 8)
Invocación: 2+ monstruos "Saint" de Nivel 8 (Normalmente Silver Saints).

8. Saga de Géminis
Efecto: (Efecto Rápido): Desacopla 2 materiales; niega la activación de una carta o efecto y, si lo haces, destiérrala boca abajo. Es la negación definitiva.

Gold Cloth - Géminis: +800 ATK. Resonancia (Saga): Una vez por turno, niega el primer efecto de carta que afecte a este monstruo.

9. Aiolia de Leo
Efecto: Desacopla 1 material; esta carta puede atacar a todos los monstruos del oponente una vez a cada uno. Gana 500 ATK por cada ataque declarado.

Gold Cloth - Leo: +800 ATK. Resonancia (Aiolia): Si esta carta ataca, el oponente no puede activar efectos hasta el final del Damage Step.

10. Shaka de Virgo
Efecto: Mientras tenga materiales, el oponente no puede activar efectos de monstruos en el GY ni en la mano. Desacopla 1: Niega todos los efectos en el campo.

Gold Cloth - Virgo: Inmunidad a efectos de monstruos. Resonancia (Shaka): El oponente no puede activar cartas en respuesta a las acciones de este caballero.

11. Aiolos de Sagitario
Efecto: Desacopla 1 material; esta carta gana ATK igual a la suma del ATK original de todos los "Bronze Saint" en tu GY hasta la End Phase.

Gold Cloth - Sagitario: +1200 ATK. Daño de penetración. Resonancia (Aiolos/Seiya): Si esta carta está en el GY, puedes equiparla a un "Bronze Saint" y este se convierte en Nivel 8.

12. Camus de Acuario
Efecto: Desacopla 1 material; selecciona 2 cartas del oponente; esas cartas no pueden activarse, cambiar su posición ni atacar mientras esta carta esté en el campo.

Gold Cloth - Acuario: Los monstruos del oponente pierden 500 ATK. Resonancia (Camus): Si un monstruo batalla con este caballero, ese monstruo es cambiado a Posición de Defensa boca abajo al final del paso de daño.

Tenés toda la razón. El "brickeo" (manos muertas) es el enemigo número uno de los mazos basados en Cartas de Equipo (como los Noble Knights o Vylon). Si robás 4 armaduras y ningún caballero, perdés. Si robás 3 dorados de rango 8 y nada para invocarlos, perdés.

Para que este proyecto sea jugable (y divertido de programar), necesitamos aplicar patrones de diseño de Yu-Gi-Oh! moderno que garanticen la consistencia. Aquí tenés 4 soluciones técnicas para evitar que el mazo se trabe:

1. Cloths Multimodo: "La armadura es el motor"
Para evitar que las Cloths sean peso muerto en la mano, todas las "Bronze Cloth" deberían tener un efecto de descarte para buscar lo que te falta.

Efecto compartido por las Bronze Cloth:
"Puedes descartar esta carta; añade 1 monstruo 'Saint' de Nivel 4 en tu Deck a tu mano. Solo puedes usar este efecto de [Nombre de la Cloth] una vez por turno".

Resultado: Si abrís con una mano llena de armaduras, las descartás todas para llenar tu campo de caballeros. Luego, como el Santuario o Kiki las recuperan del cementerio, no perdés recursos.

2. Los Bronze Saints como "1-Card Starters"
En el meta actual, necesitás que una sola carta empiece tu jugada. Vamos a darle a Seiya un efecto de "Special Summon" para no depender de la Invocación Normal.

Saint - Seiya de Pegaso (Update):
"Si no controlas monstruos, o todos los monstruos que controles son 'Saint': puedes Invocar esta carta de Modo Especial desde tu mano".

Resultado: Esto te permite bajar a Seiya, buscar una Cloth, descartar la Cloth para buscar a Shiryu, e invocar a Shiryu. Ya tenés los dos materiales para tu Silver Saint sin gastar recursos externos.

3. El "Mulligan" del Santuario
Como desarrollador, sabés que a veces el shuffle de la IA es caprichoso. Necesitamos un botón de "reset" temático.

Legado del Maestro (Magia Normal):
"Muestra hasta 3 cartas 'Cloth' en tu mano y barájalas en el Deck; roba esa misma cantidad de cartas +1. Si no controlas monstruos 'Saint', puedes desterrar esta carta de tu Cementerio; Invoca de Modo Especial 1 'Bronze Saint' desde tu Deck".

Resultado: Limpiás tu mano de equipos repetidos y, si te barrieron el campo, esta carta te da un caballero gratis desde el mazo.

4. Ratios Sugeridos (The Deck Structure)
Para que el script de probabilidad no te falle, el mazo debería estructurarse aproximadamente así:

Tipo de Carta,Cantidad,Rol
Monstruos Saint (Main),15 - 18,"Los ""pilotos"". Seiya, Ikki y Jabu a 3 copias."
Cartas Cloth (Equipos),8 - 10,"Las ""piezas"". No necesitás 3 de cada una, con 1 de cada una basta porque son buscables y reciclables."
Buscadores / Magias,10 - 12,"Santuario, Kiki, Herencia de Oro. Estas son las que ""lubrican"" el deck."
Techs / Handtraps,4 - 6,Espacio para Ash Blossom o cartas de defensa.

5. Mecánica de "Extra Deck Toolbox"
Para evitar el brickeo de los Gold Saints, recordá que al ser Xyz y Sincronía, no ocupan espacio en tu mano.

Solo llevás 1 copia de cada dorada en el Extra Deck.

Invocás al que necesitás según el oponente (Saga si necesitás negar, Shaka si el oponente usa mucho el cementerio, Mu si necesitás defenderte).

Resumen para la consistencia:
Cloths que se descartan para buscar monstruos.

Monstruos que se invocan solos si controlás otros "Saint".

Kiki equipando desde el Deck (esto es vital, porque te permite jugar menos copias de armaduras físicas en el mazo principal).