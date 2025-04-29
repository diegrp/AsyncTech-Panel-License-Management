param (
    [string]$Acao,   # "instalar" ou "desinstalar"
    [string]$Programa
)

function Escrever-Etapa {
    param([string]$Mensagem)

    $saida = @{
        Programa = $Programa
        Etapa = $Mensagem
        Timestamp = (Get-Date).ToString("HH:mm:ss")
    }

    $saida | ConvertTo-Json -Compress
}

function Instalar-Programa {
    Escrever-Etapa "Baixando instalador"
    Start-Sleep -Seconds 1

    Escrever-Etapa "Abrindo instalador"
    Start-Sleep -Seconds 1

    Escrever-Etapa "Esperando instalação terminar"
    Start-Sleep -Seconds 1

    Escrever-Etapa "Instalação concluída"
}

function Desinstalar-Programa {
    Escrever-Etapa "Executando desinstalador"
    Start-Sleep -Seconds 1

    Escrever-Etapa "Aguardando desinstalação"
    Start-Sleep -Seconds 1

    Escrever-Etapa "Desinstalação concluída"
}

# Execução baseada na ação
switch ($Acao) {
    "instalar"   { Instalar-Programa }
    "desinstalar" { Desinstalar-Programa }
    default      { Escrever-Etapa "Ação desconhecida: $Acao" }
}
