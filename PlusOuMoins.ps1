param(
    # Override du niveau (sinon menu)
    [ValidateSet("Facile", "Moyen", "Difficile")]
    [string]$Niveau,

    # Override max tentatives (sinon calculé par difficulté)
    [ValidateRange(1, 999)]
    [int]$MaxTentatives,

    # Mode chrono (temps total max par partie)
    [switch]$Chrono,
    [ValidateRange(5, 3600)]
    [int]$TimeLimitSeconds = 60,

    # Désactiver certains bonus
    [switch]$NoHint,
    [switch]$NoBeep,
    [switch]$NoAnimation
)

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

BONUS :
- Indice intelligent après 5 tentatives (pair/impair)
- Mode chronométré (limite de temps par partie)
- Statistiques avancées (session)
- Sons/animation (beeps + ASCII)
- Paramètres CLI (-Niveau, -MaxTentatives, -Chrono, ...)

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

# ==============================
# SECTION 2 — Bonus (indice/chrono/stats/son/anim)
# ==============================

function Get-Hint {
    param([int]$Secret)
    if (($Secret % 2) -eq 0) { return "Indice : le nombre est PAIR." }
    return "Indice : le nombre est IMPAIR."
}

function New-StopwatchIfNeeded {
    param([switch]$Enabled)
    if (-not $Enabled) { return $null }
    return [System.Diagnostics.Stopwatch]::StartNew()
}

function Check-TimeOut {
    param(
        [System.Diagnostics.Stopwatch]$Stopwatch,
        [int]$LimitSeconds
    )
    if ($null -eq $Stopwatch) { return $false }
    return ($Stopwatch.Elapsed.TotalSeconds -ge $LimitSeconds)
}

function Beep-Feedback {
    param(
        [ValidateSet("Plus", "Moins", "Win", "Lose", "Info")]
        [string]$Type,
        [switch]$Disabled
    )
    if ($Disabled) { return }

    switch ($Type) {
        "Plus" { [console]::Beep(900, 120) }
        "Moins" { [console]::Beep(650, 120) }
        "Win" { [console]::Beep(1200, 180); [console]::Beep(1500, 180) }
        "Lose" { [console]::Beep(300, 250) }
        "Info" { [console]::Beep(500, 80) }
    }
}

function Show-WinAnimation {
    param([switch]$Disabled)
    if ($Disabled) { return }

    $frames = @(
        "   \o/   🎉  ",
        "    |    🎉  ",
        "   / \   🎉  "
    )

    for ($i = 0; $i -lt 6; $i++) {
        Clear-Host
        Write-Host "VICTOIRE !" -ForegroundColor Cyan
        Write-Host ""
        Write-Host $frames[$i % $frames.Count] -ForegroundColor Cyan
        Start-Sleep -Milliseconds 120
    }
}

function Show-SessionStats {
    param(
        [int]$GamesPlayed,
        [int]$GamesWon,
        [int[]]$WinAttempts
    )

    Write-Host ""
    Write-Host "===== Statistiques (session) =====" -ForegroundColor Cyan
    Write-Host ("Parties jouées : {0}" -f $GamesPlayed) -ForegroundColor Yellow
    Write-Host ("Victoires      : {0}" -f $GamesWon) -ForegroundColor Yellow

    if ($GamesPlayed -gt 0) {
        $winRate = [math]::Round(($GamesWon / $GamesPlayed) * 100, 2)
        Write-Host ("Taux de victoire : {0}%" -f $winRate) -ForegroundColor Yellow
    }

    if ($WinAttempts.Count -gt 0) {
        $avg = [math]::Round(($WinAttempts | Measure-Object -Average).Average, 2)
        $best = ($WinAttempts | Measure-Object -Minimum).Minimum
        Write-Host ("Moyenne tentatives (victoires) : {0}" -f $avg) -ForegroundColor Yellow
        Write-Host ("Meilleur score (session)       : {0}" -f $best) -ForegroundColor Yellow
    }
    else {
        Write-Host "Aucune victoire -> pas de moyenne / meilleur score." -ForegroundColor Red
    }
    Write-Host ""
}

# ==============================
# SECTION 3 — Interface / Menus
# ==============================

function Show-Header {
    param([string]$modeLabel, [string]$difficultyLabel)

    Clear-Host
    Write-Host "==============================" -ForegroundColor Cyan
    Write-Host "     LESS / MORE  GAME        " -ForegroundColor Cyan
    Write-Host "==============================" -ForegroundColor Cyan

    if ($modeLabel) { Write-Host "Mode : $modeLabel" -ForegroundColor Yellow }
    if ($difficultyLabel) { Write-Host "Difficulté : $difficultyLabel" -ForegroundColor Yellow }

    if ($Chrono) {
        Write-Host ("Chrono : ON ({0}s)" -f $TimeLimitSeconds) -ForegroundColor Yellow
    }

    Write-Host ""
    Write-Host "Règles du jeu :" -ForegroundColor Yellow
    Write-Host "- Devinez le nombre" -ForegroundColor Yellow
    Write-Host "- Le jeu indique plus / moins" -ForegroundColor Yellow
    Write-Host "- Saisie invalide => erreur rouge" -ForegroundColor Yellow
    Write-Host "- Tentatives limitées" -ForegroundColor Yellow
    if (-not $NoHint) { Write-Host "- Indice après 5 tentatives" -ForegroundColor Yellow }
    Write-Host ""
}

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

# ==============================
# SECTION 4 — Saisie sécurisée
# ==============================

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

function Read-SecretNumberMasked {
    param([int]$Min, [int]$Max)

    while ($true) {
        Write-Host ""
        Write-Host "Joueur 1 : saisissez le nombre secret (il sera masqué)" -ForegroundColor Yellow
        $secure = Read-Host "Nombre secret ($Min-$Max)" -AsSecureString

        $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
        try { $plain = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr) }
        finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr) }

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

# ==============================
# SECTION 5 — Boucle principale
# ==============================

Initialize-ScoresFile

# Historique session CPU (victoires)
$scoresCPU = New-Object System.Collections.Generic.List[int]

# Stats session (tous modes)
$gamesPlayed = 0
$gamesWon = 0
$winAttempts = New-Object System.Collections.Generic.List[int]

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

    if ($mainChoice -eq '3') { break }

    if ($mainChoice -ne '1') {
        Write-Host "Erreur : choix invalide" -ForegroundColor Red
        Start-Sleep -Milliseconds 900
        continue
    }

    # Mode + difficulté
    $modeConfig = Select-Mode

    if ($PSBoundParameters.ContainsKey("Niveau")) {
        switch ($Niveau) {
            "Facile" { $diffConfig = @{ Min = 1; Max = 50; MaxTry = 15; Label = "Facile" } }
            "Moyen" { $diffConfig = @{ Min = 1; Max = 100; MaxTry = 10; Label = "Moyen" } }
            "Difficile" { $diffConfig = @{ Min = 1; Max = 200; MaxTry = 8; Label = "Difficile" } }
        }
    }
    else {
        $diffConfig = Select-Difficulty
    }

    $x = $diffConfig.Min
    $y = $diffConfig.Max
    $maxTentatives = $diffConfig.MaxTry

    if ($PSBoundParameters.ContainsKey("MaxTentatives")) {
        $maxTentatives = $MaxTentatives
    }

    Show-Header -modeLabel $modeConfig.Label -difficultyLabel $diffConfig.Label

    if ($modeConfig.Mode -eq 1) {
        # ========= MODE 1 : vs ordinateur =========
        $playerName = Read-PlayerName -Prompt "Nom du joueur"

        while ($true) {
            $gamesPlayed++
            $nombre = Get-Random -Minimum $x -Maximum ($y + 1)
            $tentatives = 0
            $hintGiven = $false
            $sw = New-StopwatchIfNeeded -Enabled:$Chrono

            while ($true) {
                # Timeout
                if (Check-TimeOut -Stopwatch $sw -LimitSeconds $TimeLimitSeconds) {
                    Write-Host ""
                    Write-Host "⏱️ Temps écoulé ! Perdu." -ForegroundColor Red
                    Beep-Feedback -Type "Lose" -Disabled:$NoBeep
                    Write-Host "Le nombre était : $nombre" -ForegroundColor Yellow
                    break
                }

                # Limite tentatives
                if ($tentatives -ge $maxTentatives) {
                    Write-Host ""
                    Write-Host "💀 Perdu ! Limite atteinte : $maxTentatives tentatives." -ForegroundColor Red
                    Beep-Feedback -Type "Lose" -Disabled:$NoBeep
                    Write-Host "Le nombre était : $nombre" -ForegroundColor Yellow
                    break
                }

                $guess = Read-ValidGuess -Min $x -Max $y -TryIndex ($tentatives + 1) -MaxTry $maxTentatives
                $tentatives++
                Write-Host "Tentative n°$tentatives" -ForegroundColor Yellow

                # Indice après 5 tentatives
                if (-not $NoHint -and -not $hintGiven -and $tentatives -ge 5) {
                    Write-Host (Get-Hint -Secret $nombre) -ForegroundColor Yellow
                    Beep-Feedback -Type "Info" -Disabled:$NoBeep
                    $hintGiven = $true
                }

                if ($guess -lt $nombre) {
                    Write-Host "C'est plus !" -ForegroundColor Blue
                    Beep-Feedback -Type "Plus" -Disabled:$NoBeep
                    continue
                }

                if ($guess -gt $nombre) {
                    Write-Host "C'est moins !" -ForegroundColor Green
                    Beep-Feedback -Type "Moins" -Disabled:$NoBeep
                    continue
                }

                # Victoire
                Write-Host ""
                Write-Host "🎉 Bravo ! Trouvé en $tentatives tentative(s)." -ForegroundColor Cyan
                Beep-Feedback -Type "Win" -Disabled:$NoBeep
                Show-WinAnimation -Disabled:$NoAnimation

                $gamesWon++
                $winAttempts.Add($tentatives)
                Show-SessionStats -GamesPlayed $gamesPlayed -GamesWon $gamesWon -WinAttempts $winAttempts

                # Session history
                $scoresCPU.Add($tentatives)

                # Persist score
                Save-Score -Player $playerName -Level $diffConfig.Label -Attempts $tentatives

                $allScores = Load-Scores
                $bestGlobal = ($allScores | Measure-Object -Property Attempts -Minimum).Minimum
                Write-Host "Meilleur score global : $bestGlobal tentative(s)" -ForegroundColor Cyan

                Write-Host "Historique session (CPU) : $($scoresCPU -join ', ')" -ForegroundColor Yellow
                Write-Host ""
                Show-BestScores -Top 10
                break
            }

            Write-Host ""
            $replay = Read-Host "Rejouer ? (O/N) — D: changer difficulté — M: menu"

            if ($replay -match '^(?i)m$') { break }

            if ($replay -match '^(?i)d$') {
                if ($PSBoundParameters.ContainsKey("Niveau")) {
                    Write-Host "Niveau fixé par paramètre (-Niveau). Relance le script pour changer." -ForegroundColor Yellow
                    Start-Sleep -Milliseconds 1100
                }
                else {
                    $diffConfig = Select-Difficulty
                    $x = $diffConfig.Min; $y = $diffConfig.Max; $maxTentatives = $diffConfig.MaxTry
                }

                if ($PSBoundParameters.ContainsKey("MaxTentatives")) {
                    $maxTentatives = $MaxTentatives
                }

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
            $gamesPlayed++
            Show-Header -modeLabel $modeConfig.Label -difficultyLabel $diffConfig.Label

            $secret = Read-SecretNumberMasked -Min $x -Max $y
            $tentatives = 0
            $hintGiven = $false
            $sw = New-StopwatchIfNeeded -Enabled:$Chrono

            Write-Host "C'est parti ! $player2 doit deviner." -ForegroundColor Yellow

            while ($true) {
                # Timeout
                if (Check-TimeOut -Stopwatch $sw -LimitSeconds $TimeLimitSeconds) {
                    Write-Host ""
                    Write-Host "⏱️ Temps écoulé ! $player2 a perdu." -ForegroundColor Red
                    Beep-Feedback -Type "Lose" -Disabled:$NoBeep
                    Write-Host "Le nombre secret était : $secret" -ForegroundColor Yellow
                    break
                }

                # Limite tentatives
                if ($tentatives -ge $maxTentatives) {
                    Write-Host ""
                    Write-Host "💀 $player2 a perdu : $maxTentatives tentatives dépassées." -ForegroundColor Red
                    Beep-Feedback -Type "Lose" -Disabled:$NoBeep
                    Write-Host "Le nombre secret était : $secret" -ForegroundColor Yellow
                    break
                }

                $guess = Read-ValidGuess -Min $x -Max $y -TryIndex ($tentatives + 1) -MaxTry $maxTentatives
                $tentatives++
                Write-Host "Tentative n°$tentatives" -ForegroundColor Yellow

                # Indice après 5 tentatives
                if (-not $NoHint -and -not $hintGiven -and $tentatives -ge 5) {
                    Write-Host (Get-Hint -Secret $secret) -ForegroundColor Yellow
                    Beep-Feedback -Type "Info" -Disabled:$NoBeep
                    $hintGiven = $true
                }

                if ($guess -lt $secret) {
                    Write-Host "C'est plus !" -ForegroundColor Blue
                    Beep-Feedback -Type "Plus" -Disabled:$NoBeep
                    continue
                }

                if ($guess -gt $secret) {
                    Write-Host "C'est moins !" -ForegroundColor Green
                    Beep-Feedback -Type "Moins" -Disabled:$NoBeep
                    continue
                }

                # Victoire
                Write-Host ""
                Write-Host "🎉 Victoire ! $player2 a trouvé en $tentatives tentative(s)." -ForegroundColor Cyan
                Beep-Feedback -Type "Win" -Disabled:$NoBeep
                Show-WinAnimation -Disabled:$NoAnimation

                $gamesWon++
                $winAttempts.Add($tentatives)
                Show-SessionStats -GamesPlayed $gamesPlayed -GamesWon $gamesWon -WinAttempts $winAttempts

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
            $replay = Read-Host "Rejouer une manche ? (O/N) — D: changer difficulté — M: menu"

            if ($replay -match '^(?i)m$') { break }

            if ($replay -match '^(?i)d$') {
                if ($PSBoundParameters.ContainsKey("Niveau")) {
                    Write-Host "Niveau fixé par paramètre (-Niveau). Relance le script pour changer." -ForegroundColor Yellow
                    Start-Sleep -Milliseconds 1100
                }
                else {
                    $diffConfig = Select-Difficulty
                    $x = $diffConfig.Min; $y = $diffConfig.Max; $maxTentatives = $diffConfig.MaxTry
                }

                if ($PSBoundParameters.ContainsKey("MaxTentatives")) {
                    $maxTentatives = $MaxTentatives
                }
                continue
            }

            if ($replay -notmatch '^(?i)o(ui)?$') {
                Write-Host "Fin du mode deux joueurs." -ForegroundColor Yellow
                break
            }
        }
    }

    Read-Host "Session terminée. Appuyez sur Entrée pour revenir au menu principal"
}
