# WindBot (Saint Seiya – Bronze Only) — Handoff README

Esta PC no puede compilar el **WindBot** desde source (requiere tooling moderno). Esta guía deja los pasos para continuar en **otra PC** y terminar la integración del executor para el deck:

- Deck: `deck/Saint Seiya - Bronze Only.ydk`
- Bot name (deck key): `SaintSeiyaBronzeOnly`
- Deck file para WindBot: `AI_SaintSeiyaBronzeOnly.ydk`

## 0) Qué está pasando (síntoma)

Si ves esto:

```
Decks initialized, 53 found.
Deck not found, loading random: AI_Yosenju
```

significa que el **WindBot.exe** que estás usando **no contiene** el executor `SaintSeiyaBronzeOnly` compilado “adentro” del exe.

Tu carpeta `C:\ProjectIgnis\WindBot\Executors\...dll` **no se carga** (no hay carga dinámica de executors), por eso **no sirve** compilar un plugin DLL: hay que **recompilar WindBot.exe** con el executor incluido.

## 1) Requisitos en la otra PC

- Windows con permisos para instalar build tools.
- **Visual Studio Build Tools 2019 o 2022** (cualquiera que incluya MSBuild moderno).
- Workloads / componentes:
  - **.NET desktop build tools**
  - **.NET Framework 4.8 targeting pack** (WindBot upstream apunta a .NET 4.8)
- `git` instalado.

## 2) Clonar ProjectIgnis

Cloná este repo (o copiá tu carpeta completa si ya la tenés):

```powershell
git clone <TU_REMOTE_DE_PROJECTIGNIS> C:\ProjectIgnis
cd C:\ProjectIgnis
```

> Nota: si no tenés remote público, podés copiar `C:\ProjectIgnis` por zip/pendrive. Lo importante es mantener `deck/`, `sets/` y `expansions/`.

## 3) Clonar el repo de WindBot (source)

Dentro del repo, cloná WindBot en `repositories/`:

```powershell
cd C:\ProjectIgnis
mkdir -Force repositories | Out-Null
git clone https://github.com/IceYGO/windbot repositories\windbot
```

## 4) Aplicar los archivos del executor + deck al WindBot source

### 4.1) Copiar el executor

Los archivos “handoff” (porque `WindBot/` está ignorado por git) están en:

- `docs/windbot-handoff/SaintSeiyaBronzeOnlyExecutor.cs`
- `docs/windbot-handoff/AI_SaintSeiyaBronzeOnly.ydk`

Copiá el executor a:

- Destino (windbot source): `repositories/windbot/Game/AI/Decks/SaintSeiyaBronzeOnlyExecutor.cs`

### 4.2) Registrar el archivo en `WindBot.csproj`

Editá:

- `C:\ProjectIgnis\repositories\windbot\WindBot.csproj`

y asegurate de tener esta línea dentro del `<ItemGroup>` de `<Compile Include="Game\AI\Decks\...">`:

```xml
<Compile Include="Game\AI\Decks\SaintSeiyaBronzeOnlyExecutor.cs" />
```

### 4.3) Agregar el deck a WindBot source

Copiá el deck a:

- `C:\ProjectIgnis\repositories\windbot\Decks\AI_SaintSeiyaBronzeOnly.ydk`

Usá el archivo handoff:

- `docs/windbot-handoff/AI_SaintSeiyaBronzeOnly.ydk`

## 5) Compilar WindBot.exe desde source

### 5.1) Encontrar MSBuild moderno

En PowerShell:

```powershell
where msbuild
```

Debería devolver una ruta tipo:

- `C:\Program Files (x86)\Microsoft Visual Studio\...\MSBuild\Current\Bin\MSBuild.exe`

### 5.2) Build (Release | x86)

```powershell
cd C:\ProjectIgnis\repositories\windbot
msbuild .\WindBot.sln /p:Configuration=Release /p:Platform=x86 /v:minimal
```

Al final deberías obtener:

- `C:\ProjectIgnis\repositories\windbot\bin\Release\WindBot.exe`

## 6) “Deploy” del WindBot compilado a tu carpeta de ProjectIgnis

Copiá el output release al WindBot que usa EDOPro/ProjectIgnis:

```powershell
Copy-Item -Force "C:\ProjectIgnis\repositories\windbot\bin\Release\*" "C:\ProjectIgnis\WindBot\"
```

## 7) Asegurar runtime files (para que no crashee)

Cuando ejecutes `C:\ProjectIgnis\WindBot\WindBot.exe` manualmente, puede tirar:

- `Can't find cards database file.`  
  Solución: poner un `cards.cdb` junto a `WindBot.exe` (o el que use tu instalación).

- `DirectoryNotFoundException ... Dialogs\default.json`  
  Solución: asegurar que exista `C:\ProjectIgnis\WindBot\Dialogs\default.json` (los builds upstream copian `Dialogs/*.json` al output).

En el uso real desde EDOPro, normalmente ya tenés `WindBot\Decks\` + `WindBot\Dialogs\` presentes.

## 8) Registrar el bot en `WindBot/bots.json`

En tu ProjectIgnis (no el windbot source), editá:

- `C:\ProjectIgnis\WindBot\bots.json`

y agregá (si no está):

```json
{
  "name": "Saint Seiya - Bronze Only",
  "deck": "SaintSeiyaBronzeOnly",
  "difficulty": 2,
  "masterRules": [5]
}
```

## 9) Verificación (lo que tenés que ver en logs)

Al iniciar WindBot desde el duelo, esperás ver que **ya no** diga “Deck not found” al elegir `SaintSeiyaBronzeOnly`.

Idealmente también debería subir el conteo de “Decks initialized” (porque agregaste 1 executor).

## 10) Archivos clave (para debug rápido)

- Executor source: `repositories/windbot/Game/AI/Decks/SaintSeiyaBronzeOnlyExecutor.cs`
- Registro compile: `repositories/windbot/WindBot.csproj`
- Deck (source): `repositories/windbot/Decks/AI_SaintSeiyaBronzeOnly.ydk`
- WindBot deploy: `WindBot/WindBot.exe` + `WindBot/Decks/AI_SaintSeiyaBronzeOnly.ydk`
- Bot roster: `WindBot/bots.json`

