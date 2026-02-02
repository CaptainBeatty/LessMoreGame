Clear-Host
Write-Host "==============================" -ForegroundColor Cyan
Write-Host "     LESS / MORE  GAME        " -ForegroundColor Cyan
Write-Host "==============================" -ForegroundColor Cyan

Write-Host ""
Write-Host "Règles du jeu :" -ForegroundColor Yellow
Write-Host "- Un nombre est généré aléatoirement" -ForegroundColor Yellow
Write-Host "- Devinez-le en proposant un nombre" -ForegroundColor Yellow
Write-Host "- Le jeu vous dira si c'est plus ou moins" -ForegroundColor Yellow
Write-Host ""


# Bornes
$x = 1
$y = 100

while ($true) {
    # boucle des parties

    # Génère un nouveau nombre aléatoire à chaque partie
    $nombre = Get-Random -Minimum $x -Maximum ($y + 1)   # +1 car -Maximum est exclusif

    $tentatives = 0

    # Write-Host $nombre  # DEBUG : décommente si tu veux afficher le nombre

    while ($true) {
        # boucle des tentatives

        $guessRaw = Read-Host "Pensez à un nombre ($x-$y)"

        # Validation : doit être un entier
        $guess = 0
        if (-not [int]::TryParse($guessRaw, [ref]$guess)) {
            Write-Host "ce n'est pas une valeur valide" -ForegroundColor Red
            continue
        }

        # Validation : dans la plage
        if ($guess -lt $x -or $guess -gt $y) {
            Write-Host "le scope n'est pas bon" -ForegroundColor Red
            continue
        }

        $tentatives++

        Write-Host "Tentative n°$tentatives" -ForegroundColor Yellow

        if ($guess -lt $nombre) {
            Write-Host "c'est plus!" -ForegroundColor Blue
            continue
        }

        if ($guess -gt $nombre) {
            Write-Host "c'est moins!" -ForegroundColor Green
            continue
        }

        
        Write-Host "Bravo ! Trouvé en $tentatives tentative(s). Nouveau nombre généré.`n" -ForegroundColor Cyan
        break
    }
}
