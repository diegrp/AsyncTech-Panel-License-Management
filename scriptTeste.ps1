[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Garantir que $ModoSilencioso esteja definido corretamente como booleano
if ($ModoSilencioso -is [string]) {
    $ModoSilencioso = $ModoSilencioso.ToLower() -eq "true"
} elseif (-not $ModoSilencioso) {
    $ModoSilencioso = $false
}

function Escrever-Etapa {
    param([string]$Mensagem)

    # Mostrar no console do PowerShell apenas se não estiver em modo silencioso
    if (-not $ModoSilencioso) {
        Write-Host "🔧 $Mensagem"
    }

    # Sempre envia JSON pela saída padrão (capturado no C#)
    $saida = @{
        Programa  = $Programa
        Etapa     = $Mensagem
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
    "instalar"    { Instalar-Programa }
    "desinstalar" { Desinstalar-Programa }
    default       { Escrever-Etapa "Ação desconhecida: $Acao" }
}

# Mostrar prompt final se não for silencioso
if (-not $ModoSilencioso) {
    Read-Host "Pressione Enter para sair"
}
