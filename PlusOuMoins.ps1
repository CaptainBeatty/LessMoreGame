
<#
.SYNOPSIS
Jeu "Less / More" en PowerShell avec modes 1 joueur vs ordinateur et 2 joueurs, niveaux de difficulté et sauvegarde des scores.

.DESCRIPTION
Ce script implémente un jeu de devinette :
- Choix du mode : 1 joueur (nombre généré) ou 2 joueurs (nombre choisi et saisi de façon masquée)
- Choix de la difficulté : Facile / Moyen / Difficile (scope + tentatives max)
- Gestion stricte des saisies (vide, non-numérique, hors scope => erreur rouge)
- Feedback couleur (plus / moins / victoire / infos)
- Sauvegarde persistante des scores dans un fichier CSV (nom, niveau, tentatives, date)
- Menu principal avec option "Voir les scores" (Top 10)

.AUTHOR
CaptainBeatty

.DATE
2026-02-02

.NOTES
- Le fichier scores.csv est volontairement ignoré par Git (.gitignore) car il contient des données utilisateur.
- Le script doit être exécuté dans un terminal PowerShell (Windows PowerShell ou PowerShell 7+).
#>

# ==============================
# SECTION 1 — Gestion des scores
# ==============================
# - Initialise le fichier scores.csv s'il n'existe pas
# - Charge les scores au démarrage
# - Enregistre un score à chaque victoire
# - Affiche un tableau des meilleurs scores

# ==============================
# SECTION 2 — Interface / Menus
# ==============================
# - Affichage du header du jeu
# - Choix du mode (1 joueur / 2 joueurs)
# - Choix de la difficulté (scope + limite)

# ==============================
# SECTION 3 — Saisie sécurisée
# ==============================
# - Validation stricte des entrées (vide / non-numérique / hors scope => rouge)
# - Saisie masquée du nombre secret en mode 2 joueurs

# ==============================
# SECTION 4 — Boucle principale
# ==============================
# - Menu principal : jouer / voir les scores / quitter
# - Lancement des parties selon le mode et la difficulté
# - Gestion rejouer / changer difficulté / inverser rôles



# ---------------- SCORES PERSISTANTS ----------------
$ScoresFile = Join-Path $PSScriptRoot "scores.csv"

function Initialize-ScoresFile {
    if (-not (Test-Path $ScoresFile)) {
        "Player,Level,Attempts,Date" | Out-File -FilePath $ScoresFile -Encoding UTF8
    }
}

function Load-Scores {
    if (-not (Test-Path $ScoresFile)) { return @() }
    try {
        return Import-Csv -Path $ScoresFile
    }
    catch {
        Write-Host "Erreur : impossible de lire le fichier scores.csv" -ForegroundColor Red
        return @()
    }
}

function Save-Score {
    param(
        [Parameter(Mandatory)] [string]$Player,
        [Parameter(Mandatory)] [string]$Level,
        [Parameter(Mandatory)] [int]$Attempts
    )

    $row = [PSCustomObject]@{
        Player   = $Player
        Level    = $Level
        Attempts = $Attempts
        Date     = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    }

    $row | Export-Csv -Path $ScoresFile -NoTypeInformation -Append -Encoding UTF8
}

function Show-BestScores {
    param([int]$Top = 10)

    $scores = Load-Scores
    if (-not $scores -or $scores.Count -eq 0) {
        Write-Host "Aucun score enregistré." -ForegroundColor Yellow
        return
    }

    $best = $scores |
    Sort-Object @{Expression = { [int]$_.Attempts }; Ascending = $true }, Date |
    Select-Object -First $Top

    Write-Host ""
    Write-Host "===== Meilleurs scores (Top $Top) =====" -ForegroundColor Cyan
    $best | Format-Table Player, Level, Attempts, Date -AutoSize
    Write-Host ""
}

# ---------------- UI / JEU ----------------
# Affiche l'en-tête du jeu (titre, mode, difficulté, règles)
function Show-Header {
    param([string]$modeLabel, [string]$difficultyLabel)

    Clear-Host
    Write-Host "==============================" -ForegroundColor Cyan
    Write-Host "     LESS / MORE  GAME        " -ForegroundColor Cyan
    Write-Host "==============================" -ForegroundColor Cyan

    if ($modeLabel) { Write-Host "Mode : $modeLabel" -ForegroundColor Yellow }
    if ($difficultyLabel) { Write-Host "Difficulté : $difficultyLabel" -ForegroundColor Yellow }

    Write-Host ""
    Write-Host "Règles du jeu :" -ForegroundColor Yellow
    Write-Host "- Devinez le nombre" -ForegroundColor Yellow
    Write-Host "- Le jeu indique plus / moins" -ForegroundColor Yellow
    Write-Host "- Saisie invalide => erreur rouge" -ForegroundColor Yellow
    Write-Host "- Tentatives limitées" -ForegroundColor Yellow
    Write-Host ""
}
# Demande le mode de jeu (1 joueur / 2 joueurs) et retourne un objet de config
function Select-Mode {
    while ($true) {
        Clear-Host
        Write-Host "Choisissez le mode :" -ForegroundColor Cyan
        Write-Host "1) Un joueur contre l'ordinateur" -ForegroundColor Green
        Write-Host "2) Deux joueurs" -ForegroundColor Yellow
        Write-Host ""

        $choice = Read-Host "Votre choix (1/2)"
        switch ($choice) {
            '1' { return @{ Mode = 1; Label = "1 joueur vs ordinateur" } }
            '2' { return @{ Mode = 2; Label = "Deux joueurs" } }
            default {
                Write-Host "Erreur : choix invalide (1 ou 2)" -ForegroundColor Red
                Start-Sleep -Milliseconds 900
            }
        }
    }
}
# Demande la difficulté et retourne scope + limite de tentatives
function Select-Difficulty {
    while ($true) {
        Clear-Host
        Write-Host "Choisissez une difficulté :" -ForegroundColor Cyan
        Write-Host "1) Facile    (1-50)   - 15 tentatives" -ForegroundColor Green
        Write-Host "2) Moyen     (1-100)  - 10 tentatives" -ForegroundColor Yellow
        Write-Host "3) Difficile (1-200)  - 8 tentatives" -ForegroundColor Red
        Write-Host ""

        $choice = Read-Host "Votre choix (1/2/3)"
        switch ($choice) {
            '1' { return @{ Min = 1; Max = 50; MaxTry = 15; Label = "Facile" } }
            '2' { return @{ Min = 1; Max = 100; MaxTry = 10; Label = "Moyen" } }
            '3' { return @{ Min = 1; Max = 200; MaxTry = 8; Label = "Difficile" } }
            default {
                Write-Host "Erreur : choix invalide (1, 2 ou 3)" -ForegroundColor Red
                Start-Sleep -Milliseconds 900
            }
        }
    }
}
# Lit une saisie et boucle tant que ce n'est pas un entier valide dans le scope
function Read-ValidGuess {
    param(
        [int]$Min,
        [int]$Max,
        [int]$TryIndex,
        [int]$MaxTry
    )

    while ($true) {
        $raw = Read-Host "Nombre ($Min-$Max) [${TryIndex}/$MaxTry]"

        if ([string]::IsNullOrWhiteSpace($raw)) {
            Write-Host "Erreur : saisie invalide (vide)" -ForegroundColor Red
            continue
        }

        $n = 0
        if (-not [int]::TryParse($raw, [ref]$n)) {
            Write-Host "Erreur : saisie invalide (pas un nombre)" -ForegroundColor Red
            continue
        }

        if ($n -lt $Min -or $n -gt $Max) {
            Write-Host "Erreur : le nombre doit être entre $Min et $Max" -ForegroundColor Red
            continue
        }

        return $n
    }
}
# Saisie masquée du nombre secret (mode 2 joueurs) puis efface l'écran
function Read-SecretNumberMasked {
    param([int]$Min, [int]$Max)

    while ($true) {
        Write-Host ""
        Write-Host "Joueur 1 : saisissez le nombre secret (il sera masqué)" -ForegroundColor Yellow
        $secure = Read-Host "Nombre secret ($Min-$Max)" -AsSecureString

        # Conversion SecureString -> string (uniquement pour valider)
        $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
        try {
            $plain = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
        }
        finally {
            [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
        }

        if ([string]::IsNullOrWhiteSpace($plain)) {
            Write-Host "Erreur : saisie invalide (vide)" -ForegroundColor Red
            continue
        }

        $n = 0
        if (-not [int]::TryParse($plain, [ref]$n)) {
            Write-Host "Erreur : saisie invalide (pas un nombre)" -ForegroundColor Red
            continue
        }

        if ($n -lt $Min -or $n -gt $Max) {
            Write-Host "Erreur : le nombre doit être entre $Min et $Max" -ForegroundColor Red
            continue
        }

        Clear-Host
        return $n
    }
}

function Read-PlayerName {
    param([string]$Prompt = "Nom du joueur")

    $name = Read-Host $Prompt
    if ([string]::IsNullOrWhiteSpace($name)) { return "Player" }
    return $name.Trim()
}

# -------------------- MAIN --------------------

Initialize-ScoresFile

# Scores (session) en mode 1 joueur vs ordinateur (toujours utile pour affichage rapide)
$scoresCPU = New-Object System.Collections.Generic.List[int]

# -------- Menu principal (nouveau) --------
while ($true) {
    Clear-Host
    Write-Host "==============================" -ForegroundColor Cyan
    Write-Host "     LESS / MORE  GAME        " -ForegroundColor Cyan
    Write-Host "==============================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Menu principal :" -ForegroundColor Yellow
    Write-Host "1) Jouer" -ForegroundColor Green
    Write-Host "2) Voir les scores" -ForegroundColor Cyan
    Write-Host "3) Quitter" -ForegroundColor Red
    Write-Host ""

    $mainChoice = Read-Host "Votre choix (1/2/3)"

    if ($mainChoice -eq '2') {
        Clear-Host
        Show-BestScores -Top 10
        Read-Host "Appuyez sur Entrée pour revenir au menu"
        continue
    }

    if ($mainChoice -eq '3') {
        break
    }

    if ($mainChoice -ne '1') {
        Write-Host "Erreur : choix invalide" -ForegroundColor Red
        Start-Sleep -Milliseconds 900
        continue
    }

    # Lancement d'une session de jeu (mode + difficulté)
    $modeConfig = Select-Mode
    $diffConfig = Select-Difficulty

    $x = $diffConfig.Min
    $y = $diffConfig.Max
    $maxTentatives = $diffConfig.MaxTry

    Show-Header -modeLabel $modeConfig.Label -difficultyLabel $diffConfig.Label

    if ($modeConfig.Mode -eq 1) {
        # ========= MODE 1 : vs ordinateur =========
        $playerName = Read-PlayerName -Prompt "Nom du joueur"

        while ($true) {
            $nombre = Get-Random -Minimum $x -Maximum ($y + 1)
            $tentatives = 0

            while ($true) {
                if ($tentatives -ge $maxTentatives) {
                    Write-Host ""
                    Write-Host "💀 Perdu ! Limite atteinte : $maxTentatives tentatives." -ForegroundColor Red
                    Write-Host "Le nombre était : $nombre" -ForegroundColor Yellow
                    break
                }

                $guess = Read-ValidGuess -Min $x -Max $y -TryIndex ($tentatives + 1) -MaxTry $maxTentatives
                $tentatives++
                Write-Host "Tentative n°$tentatives" -ForegroundColor Yellow

                if ($guess -lt $nombre) { Write-Host "C'est plus !"  -ForegroundColor Blue; continue }
                if ($guess -gt $nombre) { Write-Host "C'est moins !" -ForegroundColor Green; continue }

                Write-Host ""
                Write-Host "🎉 Bravo ! Trouvé en $tentatives tentative(s)." -ForegroundColor Cyan

                # Session history
                $scoresCPU.Add($tentatives)

                # Persist score
                Save-Score -Player $playerName -Level $diffConfig.Label -Attempts $tentatives

                # Best score global (fichier)
                $allScores = Load-Scores
                $bestGlobal = ($allScores | Measure-Object -Property Attempts -Minimum).Minimum
                Write-Host "Meilleur score global : $bestGlobal tentative(s)" -ForegroundColor Cyan

                Write-Host "Historique session : $($scoresCPU -join ', ')" -ForegroundColor Yellow
                Write-Host ""
                Show-BestScores -Top 10
                break
            }

            Write-Host ""
            $replay = Read-Host "Rejouer ? (O/N) — ou D pour changer difficulté"

            if ($replay -match '^(?i)d$') {
                $diffConfig = Select-Difficulty
                $x = $diffConfig.Min; $y = $diffConfig.Max; $maxTentatives = $diffConfig.MaxTry
                Show-Header -modeLabel $modeConfig.Label -difficultyLabel $diffConfig.Label
                continue
            }

            if ($replay -notmatch '^(?i)o(ui)?$') {
                Write-Host "Fin du jeu." -ForegroundColor Yellow
                break
            }

            Show-Header -modeLabel $modeConfig.Label -difficultyLabel $diffConfig.Label
        }
    }
    else {
        # ========= MODE 2 : Deux joueurs =========
        $player1 = Read-PlayerName -Prompt "Nom du Joueur 1 (choisit le nombre)"
        $player2 = Read-PlayerName -Prompt "Nom du Joueur 2 (devine)"

        while ($true) {
            Show-Header -modeLabel $modeConfig.Label -difficultyLabel $diffConfig.Label

            $secret = Read-SecretNumberMasked -Min $x -Max $y

            Write-Host "C'est parti ! $player2 doit deviner." -ForegroundColor Yellow
            $tentatives = 0

            while ($true) {
                if ($tentatives -ge $maxTentatives) {
                    Write-Host ""
                    Write-Host "💀 $player2 a perdu : $maxTentatives tentatives dépassées." -ForegroundColor Red
                    Write-Host "Le nombre secret était : $secret" -ForegroundColor Yellow
                    break
                }

                $guess = Read-ValidGuess -Min $x -Max $y -TryIndex ($tentatives + 1) -MaxTry $maxTentatives
                $tentatives++
                Write-Host "Tentative n°$tentatives" -ForegroundColor Yellow

                if ($guess -lt $secret) { Write-Host "C'est plus !"  -ForegroundColor Blue; continue }
                if ($guess -gt $secret) { Write-Host "C'est moins !" -ForegroundColor Green; continue }

                Write-Host ""
                Write-Host "🎉 Victoire ! $player2 a trouvé en $tentatives tentative(s)." -ForegroundColor Cyan

                # Persist score : on log le joueur qui devine
                Save-Score -Player $player2 -Level $diffConfig.Label -Attempts $tentatives

                $allScores = Load-Scores
                $bestGlobal = ($allScores | Measure-Object -Property Attempts -Minimum).Minimum
                Write-Host "Meilleur score global : $bestGlobal tentative(s)" -ForegroundColor Cyan
                Write-Host ""
                Show-BestScores -Top 10
                break
            }

            Write-Host ""
            $swap = Read-Host "Inverser les rôles ? (O/N)"
            if ($swap -match '^(?i)o(ui)?$') {
                $tmp = $player1; $player1 = $player2; $player2 = $tmp
            }

            Write-Host ""
            $replay = Read-Host "Rejouer une manche ? (O/N) — ou D pour changer difficulté"
            if ($replay -match '^(?i)d$') {
                $diffConfig = Select-Difficulty
                $x = $diffConfig.Min; $y = $diffConfig.Max; $maxTentatives = $diffConfig.MaxTry
                continue
            }

            if ($replay -notmatch '^(?i)o(ui)?$') {
                Write-Host "Fin du mode deux joueurs." -ForegroundColor Yellow
                break
            }
        }
    }

    # Retour au menu principal après une session
    Read-Host "Session terminée. Appuyez sur Entrée pour revenir au menu principal"
}
