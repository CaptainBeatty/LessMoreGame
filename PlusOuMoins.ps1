function Show-Header {
    param([string]$difficultyLabel)

    Clear-Host
    Write-Host "==============================" -ForegroundColor Cyan
    Write-Host "     LESS / MORE  GAME        " -ForegroundColor Cyan
    Write-Host "==============================" -ForegroundColor Cyan

    if ($difficultyLabel) {
        Write-Host "Difficulté : $difficultyLabel" -ForegroundColor Yellow
    }

    Write-Host ""
    Write-Host "Règles du jeu :" -ForegroundColor Yellow
    Write-Host "- Un nombre est généré aléatoirement" -ForegroundColor Yellow
    Write-Host "- Devinez-le en proposant un nombre" -ForegroundColor Yellow
    Write-Host "- Le jeu vous dira si c'est plus ou moins" -ForegroundColor Yellow
    Write-Host "- Vous avez un nombre limité de tentatives" -ForegroundColor Yellow
    Write-Host ""
}

function Select-Difficulty {
    while ($true) {
        Clear-Host
        Write-Host "Choisissez une difficulté :" -ForegroundColor Cyan
        Write-Host "1) Facile   (1-50)   - 15 tentatives" -ForegroundColor Green
        Write-Host "2) Moyen    (1-100)  - 10 tentatives" -ForegroundColor Yellow
        Write-Host "3) Difficile(1-200)  - 8 tentatives" -ForegroundColor Red
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

# Historique des scores (nombre de tentatives quand victoire)
$scores = New-Object System.Collections.Generic.List[int]

# --------- Sélection difficulté (au démarrage) ---------
$config = Select-Difficulty
$x = $config.Min
$y = $config.Max
$maxTentatives = $config.MaxTry
$difficultyLabel = $config.Label

Show-Header -difficultyLabel $difficultyLabel

while ($true) {
    # -------- Partie --------
    $nombre = Get-Random -Minimum $x -Maximum ($y + 1)   # +1 car -Maximum est exclusif
    $tentatives = 0

    while ($true) {
        # Défaite si limite atteinte
        if ($tentatives -ge $maxTentatives) {
            Write-Host ""
            Write-Host "💀 Perdu ! Limite atteinte : $maxTentatives tentatives." -ForegroundColor Red
            Write-Host "Le nombre était : $nombre" -ForegroundColor Yellow
            break
        }

        $guessRaw = Read-Host "Nombre ($x-$y) [$(($tentatives + 1))/$maxTentatives]"

        # Validation : vide
        if ([string]::IsNullOrWhiteSpace($guessRaw)) {
            Write-Host "Erreur : saisie invalide (vide)" -ForegroundColor Red
            continue
        }

        # Validation : entier
        $guess = 0
        if (-not [int]::TryParse($guessRaw, [ref]$guess)) {
            Write-Host "Erreur : saisie invalide (pas un nombre)" -ForegroundColor Red
            continue
        }

        # Validation : scope
        if ($guess -lt $x -or $guess -gt $y) {
            Write-Host "Erreur : le nombre doit être entre $x et $y" -ForegroundColor Red
            continue
        }

        # Tentative comptée seulement si valide
        $tentatives++
        Write-Host "Tentative n°$tentatives" -ForegroundColor Yellow

        if ($guess -lt $nombre) {
            Write-Host "C'est plus !" -ForegroundColor Blue
            continue
        }

        if ($guess -gt $nombre) {
            Write-Host "C'est moins !" -ForegroundColor Green
            continue
        }

        # Victoire
        Write-Host ""
        Write-Host "🎉 Bravo ! Trouvé en $tentatives tentative(s)." -ForegroundColor Cyan

        $scores.Add($tentatives)
        $bestScore = ($scores | Measure-Object -Minimum).Minimum

        Write-Host "Meilleur score (victoires uniquement) : $bestScore" -ForegroundColor Cyan
        Write-Host "Historique : $($scores -join ', ')" -ForegroundColor Yellow
        break
    }

    # -------- Rejouer ? --------
    Write-Host ""
    $replay = Read-Host "Rejouer ? (O/N) — ou tapez D pour changer de difficulté"

    if ($replay -match '^(?i)d$') {
        $config = Select-Difficulty
        $x = $config.Min
        $y = $config.Max
        $maxTentatives = $config.MaxTry
        $difficultyLabel = $config.Label
        Show-Header -difficultyLabel $difficultyLabel
        continue
    }

    if ($replay -notmatch '^(?i)o(ui)?$') {
        Write-Host ""
        Write-Host "Fin du jeu." -ForegroundColor Yellow

        if ($scores.Count -gt 0) {
            $bestScore = ($scores | Measure-Object -Minimum).Minimum
            Write-Host "Meilleur score final : $bestScore tentative(s)" -ForegroundColor Cyan
            Write-Host "Scores : $($scores -join ', ')" -ForegroundColor Yellow
        }
        else {
            Write-Host "Aucune victoire enregistrée." -ForegroundColor Red
        }
        break
    }

    Show-Header -difficultyLabel $difficultyLabel
}
