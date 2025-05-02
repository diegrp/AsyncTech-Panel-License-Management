[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# As variáveis $Acao e $Programa são definidas antes da execução remota, então não precisamos de 'param(...)'

function Escrever-Etapa {
    param([string]$Mensagem)

    # Mostrar para o usuário no PowerShell
    Write-Host "🔧 $Mensagem"

    # Enviar para o C# via saída padrão (JSON)
    $saida = @{
        Programa  = $Programa
        Etapa     = $Mensagem
        Timestamp = (Get-Date).ToString("HH:mm:ss")
    }

    $saida | ConvertTo-Json -Compress
}

function Instalar-Programa {
    Escrever-Etapa "Baixando instalador"
    Write-Host "🔧 Baixando instalador do programa..."
    Start-Sleep -Seconds 1

    Escrever-Etapa "Abrindo instalador"
    Write-Host "🔧 Abrindo instalador do programa..."
    Start-Sleep -Seconds 1

    Escrever-Etapa "Esperando instalação terminar"
    Write-Host "🔧 Esperando instalação terminar..."
    Start-Sleep -Seconds 1

    Escrever-Etapa "Instalação concluída"
    Write-Host "✅ Instalação concluída..."
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

Read-Host "Pressione Enter para sair"
