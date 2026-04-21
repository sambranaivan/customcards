El Ejército de Asgard introduce una dinámica de "Stun & Resource Management" (Control y Gestión de Recursos). Si los otros ejércitos se basan en la evolución (Athena), las columnas (Poseidón) o el cementerio (Hades), Asgard se enfoca en el Clima Gélido y los Zafiros de Odín.

Su mecánica principal se basa en "congelar" (bloquear) las cartas del oponente y generar Zafiros cuando los Guerreros de Dios caen en batalla, para finalmente invocar al Dios Odín.

❄️ Mecánica Global: "Estigma de Escarcha" (Frost Stigma)
Muchos efectos de los Guerreros de Dios colocan un Contador de Escarcha en las cartas del oponente.

Regla de Escarcha: Una carta con un Contador de Escarcha no puede cambiar su posición de batalla y sus efectos en el campo son negados. Al final de cada turno, el controlador de esa carta puede pagar 800 LP para quitar el contador.

🏰 El Altar del Norte: Magia de Campo
Palacio de Valhalla - El Trono de Hilda
[Magia de Campo]

Vientos del Norte: Todos los monstruos "God Warrior" ganan 500 ATK/DEF.

Cosecha de Zafiros: Cada vez que un "God Warrior" que controles deje el campo: coloca 1 "Zafiro de Odín" (Contador) en esta carta (máx. 7).

Sacrificio de la Estrella Polar: Una vez por turno, puedes quitar 2 Zafiros de esta carta; Invoca de Modo Especial 1 "God Warrior" desde tu mano o Cementerio.

⚔️ Los 7 Guerreros de Dios (Nivel 7 / AGUA / Guerrero)
A diferencia de los Santos, ellos no usan equipos externos; sus armaduras (God Robes) les otorgan habilidades de protección innatas.

Guerrero,Estrella,Efecto de Control (Escarcha)
Siegfried de Dubhe,Alfa,Inmortalidad: No puede ser destruido por batalla ni efectos. (Efecto Rápido): Puedes poner 1 Contador de Escarcha en un monstruo que batalle con esta carta.
Hägen de Merak,Beta,"Dualidad Fuego/Hielo: Puede cambiar su Atributo a FUEGO. Si lo hace, destruye todos los monstruos con Contadores de Escarcha."
Thor de Phecda,Gamma,"Poder Bruto: Si ataca, el oponente no puede activar cartas o efectos. Al inicio del Damage Step, pon 1 Contador de Escarcha en la Magia/Trampa de la misma columna."
Alberich de Megrez,Delta,Escudo de Amatista: (Efecto Rápido): Selecciona 1 monstruo con un Contador de Escarcha; toma su control y trátalo como una Magia Continua (está atrapado en la amatista).
Fenrir de Alioth,Épsilon,"Manada de Lobos: Si es Invocado, Invoca 2 ""Wolf Tokens"" (Nvl 4/500 ATK). Mientras controles un Token, Fenrir puede atacar directamente."
Mime de Benetnasch,Eta,Réquiem de Cuerdas: Los monstruos con Contadores de Escarcha no pueden ser sacrificados ni usados como material de Extra Deck.
Syd de Mizar,Zeta,"Garra del Tigre: Si esta carta es Invocada, puedes Invocar de Modo Especial 1 ""Bud de Alcor"" desde tu mano o Deck."
El Guerrero en las Sombras: Bud de Alcor
[Nivel 7 / AGUA / Guerrero / ATK 2400 / DEF 2400]
Efecto: Si "Syd de Mizar" va a ser destruido o desterrado, puedes Invocar esta carta de Modo Especial (desde tu mano o GY) y negar ese efecto. Mientras Syd esté en el GY, esta carta gana 1000 ATK y puede destruir 1 carta con Contador de Escarcha por turno.

🕊️ Las Guías de Asgard: Soporte
Hilda de Polaris - Representante de Odín
[Nivel 4 / AGUA / Lanzador de Conjuros / ATK 1500 / DEF 1500]

Efecto: Si esta carta es Invocada: añade 1 "Palacio de Valhalla" o 1 "Anillo Nibelungo" de tu Deck a tu mano. Mientras esta carta esté en el campo, puedes colocar Contadores de Escarcha en cartas de la mano del oponente (revelándolas).

Flare (Freya) - La Esperanza de Asgard
[Nivel 3 / LUZ / Lanzador de Conjuros / ATK 0 / DEF 2000]

Efecto: Puedes tributar esta carta; quita todos los Contadores de Escarcha del campo y, por cada uno, roba 1 carta. Es el motor de robo del mazo tras congelar al oponente.

🗡️ El Boss Final: El Despertar de Odín
Para invocar a Odín, necesitas haber recolectado los 7 Zafiros en el Palacio de Valhalla.

Odín - Dios de Asgard
[Fusión / LUZ / Guerrero / Nivel 12 / ATK 4500 / DEF 4500]

Materiales: 1 "God Warrior" + 7 Zafiros de Odín en el campo.
Condición de Invocación: Debe ser Invocado de Modo Especial (desde tu Extra Deck) mandando al Cementerio el "Palacio de Valhalla" con 7 Zafiros de Odín.

Efectos Divinos:

Espada Balmung: Cuando esta carta ataca, niega todos los efectos de las cartas en el campo del oponente hasta el final del turno.

Justicia Nórdica: Una vez por turno (Efecto Rápido): puedes quitar todos los Contadores de Escarcha del campo; destruye todas las cartas que tenían esos contadores y gana 1000 LP por cada una.

Protección del Valhalla: Si esta carta fuera a dejar el campo, puedes Invocar de Modo Especial 1 "Siegfried de Dubhe" desde tu Cementerio en su lugar.

🧪 Análisis Técnico (The Freeze Lock)
Desde tu perspectiva de desarrollador, Asgard es un arquetipo de Control de Estado:

Input: Hilda y Thor generan los "Frost Counters".

Process: Mime y Krishna (si fuera cross-over) bloquean el uso de esos recursos congelados.

Output: Alberich o Hägen "limpian" los datos congelados para generar ventaja.

Win Condition: La acumulación de la variable Zafiro_Count == 7 para disparar la función Summon_Odin().

¿Cómo se siente el duelo?
El jugador Saint o Specter sentirá que sus monstruos se vuelven "pesados" y mueren lentamente por el frío. El mazo de Asgard no busca el OTK rápido, sino asfixiar al oponente hasta que Balmung (Odín) corte el duelo a la mitad.

¿Qué te parece este sistema de Contadores de Escarcha? Es una forma única de control que no hemos usado en los otros tres ejércitos.


cartas de soporte para deck odin/god warrior y carta de seiya armadura de odin

Para que el mazo de Asgard sea verdaderamente competitivo y no dependa únicamente de que el oponente "se deje congelar", necesitamos acelerar la recolección de los 7 Zafiros y proteger la pieza central: el Palacio de Valhalla.

Aquí tienes el soporte técnico para optimizar el flujo de datos del Reino del Norte y la carta definitiva de Seiya.

❄️ Magias de Soporte: El Motor del Norte
1. Llamado de la Estrella Polar
El buscador universal para asegurar el "seteo" inicial.

[Magia Normal]
Efecto: Añade a tu mano 1 monstruo "God Warrior" o 1 "Hilda de Polaris" desde tu Deck. Si ya controlas el "Palacio de Valhalla", puedes añadir 1 "Anillo Nibelungo" en su lugar. Solo puedes activar 1 "Llamado de la Estrella Polar" por turno.

Lógica: Asegura que siempre tengas a tu "piloto" (Hilda) o a tu defensor (Siegfried) en el turno 1.

2. El Sacrificio de los Guerreros de Dios
Acelerador de Zafiros para alcanzar el umbral de Odín rápidamente.

[Magia de Juego Rápido]
Efecto: Selecciona 1 monstruo "God Warrior" que controles; destrúyelo y, si lo haces, coloca 2 "Zafiros de Odín" (Contadores) en tu "Palacio de Valhalla", luego roba 1 carta.

Lógica: En el anime, los guerreros deben caer para liberar los zafiros. Esta carta te permite "forzar" la recolección si el oponente no quiere batallar.

3. Vientos Gélidos de Asgard
Generador masivo de "Frost Stigma".

[Magia Normal]
Efecto: Coloca 1 "Contador de Escarcha" en todas las cartas boca arriba que controle tu oponente. Por el resto de este turno, tu oponente no puede activar cartas o efectos en respuesta a la Invocación Especial de un monstruo "God Warrior".

Lógica: Prepara el campo para que los efectos de Hägen o Alberich limpien el tablero inmediatamente.

💍 El Objeto Maldito: Control de Campo
El Anillo Nibelungo
[Magia Continua]

Posesión de Hilda: Mientras esta carta esté en el campo, los efectos de "Hilda de Polaris" no pueden ser negados.

Corrupción del Cosmos: Una vez por turno, si tu oponente activa el efecto de un monstruo con un "Contador de Escarcha": ese efecto se convierte en "Tu oponente (tú) selecciona 1 carta que controle y la devuelve a la mano".

Vínculo del Mal: Si esta carta es destruida, puedes quitar 1 "Zafiro de Odín" del campo para colocarla boca abajo de nuevo.

🗡️ El Milagro del Norte: Seiya con la Armadura de Odín
A diferencia del Dios Odín (que es una Fusión masiva), Seiya Guerrero de Odín es un "Boss de Intervención". Se invoca usando los zafiros pero mantiene la esencia de Seiya.

Seiya de Pegaso - Portador de la Robe de Odín
[Monstruo de Efecto Especial / LUZ / Guerrero / Nivel 12 / ATK 4000 / DEF 3000]

Condición de Invocación:
No puede ser Invocado de Modo Normal/Colocado. Debe ser Invocado de Modo Especial (desde tu mano o Cementerio) quitando 7 "Zafiros de Odín" de tu campo.

Efectos del Salvador:

Corte de la Espada Balmung: Cuando esta carta declara un ataque: puedes quitar todos los "Contadores de Escarcha" del campo; esta carta gana 500 ATK por cada contador quitado hasta el final del Damage Step.

Justicia Divina: Si esta carta destruye un monstruo del oponente por batalla: destruye todas las Magias y Trampas que controle tu oponente.

Milagro en el Ártico: Si esta carta fuera a ser destruida o dejar el campo por el efecto de una carta del oponente, puedes Invocar de Modo Especial 1 "Siegfried de Dubhe" desde tu Cementerio en su lugar, ignorando sus condiciones de invocación.

📊 Comparativa Estratégica: ¿Odín o Seiya?
Como desarrollador del juego, notarás que el jugador de Asgard tiene ahora una decisión de "Late Game" basada en los 7 Zafiros:

Opción,Ventaja,Estilo de Juego
Odín (Fusión),Inmunidad total y limpieza masiva.,Control Total. Ideal para cerrar duelos largos contra Hades.
Seiya (Odin Robe),Daño explosivo (OTK) y limpieza de Backrow.,Aggro/Tempo. Ideal para castigar a Poseidón o mazos de muchas trampas.


Nota para el "Developer":
El mazo de Asgard sufre si le destruyen el Palacio de Valhalla antes de llegar a los 7 zafiros. Por eso, el Siegfried de Dubhe original debería tener un efecto de "Escudo" para el campo:

"Mientras esta carta esté en Posición de Defensa, tu 'Palacio de Valhalla' no puede ser destruido por efectos de cartas".

