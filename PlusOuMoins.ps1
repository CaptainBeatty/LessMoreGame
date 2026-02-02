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
            Write-Host "ce n'est pas une valeur valide"
            continue
        }

        # Validation : dans la plage
        if ($guess -lt $x -or $guess -gt $y) {
            Write-Host "le scope n'est pas bon"
            continue
        }

        $tentatives++

        if ($guess -lt $nombre) {
            Write-Host "c'est plus!"
            continue
        }

        if ($guess -gt $nombre) {
            Write-Host "c'est moins!"
            continue
        }

        Write-Host "Bravo ! Trouvé en $tentatives tentative(s). Nouveau nombre généré.`n"
        break
    }
}
