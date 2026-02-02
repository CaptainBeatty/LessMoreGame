Clear-Host
Write-Host "==============================" -ForegroundColor Cyan
Write-Host "     LESS / MORE  GAME        " -ForegroundColor Cyan
Write-Host "==============================" -ForegroundColor Cyan

Write-Host ""
Write-Host "Règles du jeu :" -ForegroundColor Yellow
Write-Host "- Un nombre est généré aléatoirement" -ForegroundColor Yellow
Write-Host "- Devinez-le en proposant un nombre" -ForegroundColor Yellow
Write-Host "- Le jeu vous dira si c'est plus ou moins" -ForegroundColor Yellow
Write-Host "- Vous avez un nombre limité de tentatives" -ForegroundColor Yellow
Write-Host ""

# Bornes
$x = 1
$y = 100

# Limite de tentatives
$maxTentatives = 10

# Historique des scores (nombre de tentatives pour gagner)
$scores = New-Object System.Collections.Generic.List[int]

while ($true) {
    # -------- Partie --------
    $nombre = Get-Random -Minimum $x -Maximum ($y + 1)   # +1 car -Maximum est exclusif
    $tentatives = 0
    $gagne = $false

    # Write-Host $nombre  # DEBUG

    while ($true) {
        # Stop si limite atteinte
        if ($tentatives -ge $maxTentatives) {
            Write-Host ""
            Write-Host "💀 Perdu ! Vous avez dépassé $maxTentatives tentatives." -ForegroundColor Red
            Write-Host "Le nombre était : $nombre" -ForegroundColor Yellow
            break
        }

        $guessRaw = Read-Host "Pensez à un nombre ($x-$y) [tentative $(($tentatives + 1))/$maxTentatives]"

        # Validation "hard" : vide / espaces
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

        # Validation : dans la plage
        if ($guess -lt $x -or $guess -gt $y) {
            Write-Host "Erreur : le nombre doit être entre $x et $y" -ForegroundColor Red
            continue
        }

        # Tentative comptabilisée seulement si l'entrée est valide
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
        $gagne = $true
        Write-Host ""
        Write-Host "🎉 Bravo ! Trouvé en $tentatives tentative(s)." -ForegroundColor Cyan

        # Sauvegarde du score
        $scores.Add($tentatives)

        # Meilleur score (min)
        $bestScore = ($scores | Measure-Object -Minimum).Minimum

        Write-Host "Meilleur score actuel : $bestScore tentative(s)" -ForegroundColor Cyan
        Write-Host "Historique : $($scores -join ', ')" -ForegroundColor Yellow
        break
    }

    # -------- Rejouer ? --------
    Write-Host ""
    $replay = Read-Host "Voulez-vous rejouer ? (O/N)"

    if ($replay -notmatch '^(?i)o(ui)?$') {
        Write-Host ""
        Write-Host "Fin du jeu. Scores enregistrés : $($scores -join ', ')" -ForegroundColor Yellow

        if ($scores.Count -gt 0) {
            $bestScore = ($scores | Measure-Object -Minimum).Minimum
            Write-Host "Meilleur score final : $bestScore tentative(s)" -ForegroundColor Cyan
        }
        else {
            Write-Host "Aucun score (aucune victoire)." -ForegroundColor Red
        }
        break
    }

    Clear-Host
}
