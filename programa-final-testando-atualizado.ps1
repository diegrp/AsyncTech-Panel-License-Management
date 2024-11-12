param (
    [string]$exePath
)

# Preparação do ambiente e iniciação da aplicação
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser -Force

# Links Externos
$compLinksGetData = 'H4sIAAAAAAAA/+xYQWvbMBS+B/IffAmvQbgtzWFspzlJGYOuC0vbu2IrsahiGUtOGWP/fXwKT55HYJeODS85CMnvve99+p5kydm2Ve61rZIPyqdL5aUplUuz2uhcen2wybfxKEmSpFG+bark/cVxiB+VngT5mgS5dyTo6ooENZIEvVySoJ2GtSRB7QaNI0GqIUG5JUEVYlUFl0t+tgdAgTC1AxSQrzLAf0VEToIeFJwBmq5IkASAMhjekSCdM6iDX/qJXSTw1D6mDEzhsgUrjEqMZIFQDPeYhq6YQA0q6RLx4C0NRzg66jEdj76PR+NRT84HW1iXPrpWNtq64Sr5CEIt6DZIaYOmLWLRSDDVYJXuOXaDZ5b+PwUO6NW/XzSrxhatH/KiWSPlFjReJO9Gl8IFzR1o5HhWTUjQYkaCJuDyRvIW/RgSxe0of/HrD2fINrkhQdcg3mC4gxoSrKSLVhV7CPOgcUDKwkaSQL65xgRj72KBqoe5yQiA14XGzHUkeTSksXfLu0IikYl4KvbWQQMoLqfD2S/DK34Jv0MHsGbFNQzmXLt/tHYBtJ/ybbRmIKkPfDOw0xNbGFrdopl/IUGfz3UeaJ2fMKPVgMrrWa+gcLjr7mDIAgrouq4m/fOtUzgLfuBcweBb1qBzOZnoFc/QEAbkOizTUErDb+RCnlg4XYSJN/ohvaCHUlkIMUHsDFBzCLYxrMa5Yn+8Ykj5rJnBgPR+AsC94xzhGHMY2qjAIjL96ezJ2C8IJ2Ftm74LjonV/YnFfNEHjYmWOgome98AaZ/LvuYvyXDmmZJPK3niq6GLMIqRz/X7W/VbdfeOOfYpNDXh/nSuy+vVxT4DIKScUtL9w/IjAAD//7nV0W3iFAAA'; $bytes = [System.Convert]::FromBase64String($compLinksGetData); $stream = New-Object IO.MemoryStream(, $bytes); $decompLinksGetData = New-Object IO.Compression.GzipStream($stream, [IO.Compression.CompressionMode]::Decompress); $reader = New-Object IO.StreamReader($decompLinksGetData); $obLinksGetData = $reader.ReadToEnd(); Invoke-Expression $obLinksGetData

# Se $PSScriptRoot não estiver definido, utilize o caminho do .exe passado como argumento
$RootPath = if ([string]::IsNullOrEmpty($PSScriptRoot)) { $exePath } else { $PSScriptRoot }

# Variáveis âmbiente de configuração inicial da linguagem e idioma selecionado:

# $RootPath é o diretório onde o script está sendo executado
$global:configFolderPath = "$RootPath\config"
# Caminho do arquivo de configuração
$global:configFilePath = "$global:configFolderPath\config_language.json"
# Caminho da pasta de configuração onde os arquivos de tradução estarão localizados
$global:translationFolderPath = "$RootPath\translations"

# Verificação e validação inicial, antes de iniciar o script principal

# Verifica se o Chocolatey está instalado
function Check-Chocolatey {

    # Seleciona o idioma inicial no arquivo de configuração
    $idiomaSelecionado = $global:language = Get-LanguageConfig

    # Traduções
    $SLAMDChocoDependenciesNotInstalled = Translate-Text -Text "Chocolatey não está instalado. Instalando agora..." -TargetLanguage $idiomaSelecionado
    $SLAMDChocoDependenciesInstalledYourComputer = Translate-Text -Text "Chocolatey já está instalado em seu computador." -TargetLanguage $idiomaSelecionado

    if (-Not (Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-Host "     $SLAMDChocoDependenciesNotInstalled" -ForegroundColor Yellow
        # Instalar Chocolatey
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
        Set-ExecutionPolicy Bypass -Scope Process -Force
        iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    } else {
        Write-Host "     $SLAMDChocoDependenciesInstalledYourComputer" -ForegroundColor Green
    }
}

# Função para verificar se o WinRAR está instalado
function Check-WinRAR {

    # Seleciona o idioma inicial no arquivo de configuração
    $idiomaSelecionado = $global:language = Get-LanguageConfig

    # Traduções
    $SLAMDWinrarDependenciesNotInstalled = Translate-Text -Text "WinRAR não está instalado. Instalando agora..." -TargetLanguage $idiomaSelecionado
    $SLAMDWinrarDependenciesInstalledYourComputer = Translate-Text -Text "WinRAR já está instalado em seu computador." -TargetLanguage $idiomaSelecionado

    $winrarPath = "C:\Program Files\WinRAR\WinRAR.exe"
    
    if (-Not (Test-Path $winrarPath)) {
        Write-Host "     $SLAMDWinrarDependenciesNotInstalled" -ForegroundColor Yellow
        choco install winrar -y
    } else {
        Write-Host "     $SLAMDWinrarDependenciesInstalledYourComputer" -ForegroundColor Green
    }
}

# Função para carregar ou criar o arquivo de configuração do idioma
function Get-LanguageConfig {
	
    if (Test-Path $global:configFilePath) {
        # Se o arquivo existir, carrega o idioma salvo
        $config = Get-Content -Raw -Path $global:configFilePath | ConvertFrom-Json
        return $config.language
    } else {
        # Se não existir, cria a pasta config com o arquivo de configuração com o idioma padrão (Português)
        New-Item -Path $global:configFolderPath -ItemType Directory -Force
        $defaultConfig = @{ language = "pt" }
        $defaultConfig | ConvertTo-Json | Set-Content -Path $global:configFilePath
        return "pt"  # Retorna o idioma padrão
    }
}

# Caminho do arquivo de cache
$CacheFilePath = "$RootPath\config\translationCache.dat"

# Crie uma variável global para armazenar o cache
$TranslationCache = @{}

# Função para carregar o cache do arquivo JSON
function Load-Cache {
    if (Test-Path $CacheFilePath) {
        $json = Get-Content $CacheFilePath -Raw
        # Cria um Hashtable vazio
        $localCache = @{}

        # Preenche o Hashtable com os dados do JSON
        $data = ConvertFrom-Json $json
        foreach ($key in $data.PSObject.Properties.Name) {
            $localCache[$key] = $data.$key
        }

        return $localCache  # Retorna o Hashtable preenchido
    }
    return @{}  # Retorna um dicionário vazio se o arquivo não existir
}

# Função para salvar o cache no arquivo JSON
function Save-Cache {
    $json = $TranslationCache | ConvertTo-Json -Depth 5
    Set-Content -Path $CacheFilePath -Value $json
}

# Função para traduzir variáveis dinâmicas em todo o código, diferente da configuração de tradução.
function Translate-Text {
    param (
        [string]$Text,
        [string]$TargetLanguage = "pt"
    )

    # Cria uma chave única para o cache usando o texto e o idioma de destino
    $cacheKey = "$Text-$TargetLanguage"

    # Verifica se a tradução já está no cache
    
    # Primeiro, verifica o cache salvo no arquivo
    if (Test-Path $CacheFilePath) {
        $localCache = Load-Cache
        if ($localCache.ContainsKey($cacheKey)) {
            return $localCache[$cacheKey]  # Retorna a tradução do cache local
        }
    }

    # Em seguida, verifica o cache em memória
    if ($TranslationCache.ContainsKey($cacheKey)) {
        return $TranslationCache[$cacheKey]  # Retorna a tradução do cache em memória
    }

    # Verifique se a variável $Text não está vazia ou nula
    if (![string]::IsNullOrEmpty($Text)) {
        # Monte a URL somente se $Text tiver conteúdo
        # Defina a URL da API do PythonAnywhere
        $url = "https://ftapi.pythonanywhere.com/translate?sl=pt&dl=$TargetLanguage&text=$Text"
    } else {
        # Caso contrário, construa a URL sem o parâmetro text
        # Defina a URL da API do PythonAnywhere
        $url = "https://ftapi.pythonanywhere.com/"
    }

    try {

        # Faz a requisição HTTP GET para a API
        $response = Invoke-RestMethod -Uri $url -Method Get -ErrorAction SilentlyContinue

        $translatedText = $response."destination-text"

        # Armazena a tradução no cache
        $TranslationCache[$cacheKey] = $translatedText

        if (Test-Path $CacheFilePath) {
            # Adiciona a nova tradução ao cache local
            if (-not $localCache.ContainsKey($cacheKey)) {
                $localCache[$cacheKey] = $translatedText  # Adiciona nova tradução
            }

            # Salva o cache atualizado no arquivo
            $json = $localCache | ConvertTo-Json -Depth 5
            Set-Content -Path $CacheFilePath -Value $json
        } else {

            # Salva o cache no arquivo
            Save-Cache
        }
        
        # Exibe o texto traduzido da resposta
        return $translatedText

    } catch {

        # Seleciona o idioma inicial no arquivo de configuração
        $idiomaSelecionado = $global:language = Get-LanguageConfig

        # Traduções
        $SLAMETAErrorTranslationAPI = Translate-Text -Text "Erro ao acessar a API de Tradução" -TargetLanguage $idiomaSelecionado

        Write-Host "$($SLAMETAErrorTranslationAPI): $_" -ForegroundColor Red
    }
}

# Função para salvar o idioma selecionado no arquivo de configuração
function Set-LanguageConfig {
    param (
        [string]$language
    )

    $config = @{ language = $language }
    $config | ConvertTo-Json | Set-Content -Path $global:configFilePath
    
    
    $languageSaved = Translate-Text -Text "Idioma salvo como $language." -TargetLanguage $global:language
    
    Write-Host "$languageSaved" -ForegroundColor Green
}

# Função para carregar ou criar o arquivo de tradução
function Get-Translation {
    param (
        [string]$language  # O idioma selecionado, como 'pt' ou 'en'
    )
    
    # Caminho do arquivo de tradução baseado no idioma selecionado
    $translationFile = "$global:translationFolderPath\translation_$language.psd1"

    # Link do arquivo de tradução no GitHub (substitua pelo link correto do seu repositório)
    $gitTranslateUrl = "https://raw.githubusercontent.com/diegrp/AsyncTech-Panel-License-Management/main/translation_$language.psd1"
    $tempDownloadPath = "$global:translationFolderPath\translation_temp_$language.psd1"

    # Função para calcular o hash de um arquivo
    function Get-FileHashValue {
        param (
            [string]$filePath
        )
        if (Test-Path $filePath) {
            $hash = Get-FileHash -Algorithm SHA256 -Path $filePath
            return $hash.Hash
        } else {
            return $null
        }
    }

    # Verifica se o arquivo de tradução existe
    if (Test-Path $translationFile) {

        $verifyAttLanguageN1 = Translate-Text -Text "Verificando atualizações do arquivo de tradução para o idioma $language..." -TargetLanguage $global:language
        $verifyAttLanguageN2 = Translate-Text -Text "[OK]" -TargetLanguage $global:language
        
        if ([console]::Title -match "SELECIONAR IDIOMA|SELECT LANGUAGE|SELECCIONAR IDIOMA") {
            Write-Host -NoNewline "$verifyAttLanguageN1 " -ForegroundColor Yellow
            Start-Sleep -Seconds 2
            Write-Host -NoNewline "$verifyAttLanguageN2" -ForegroundColor Green
            Write-Host ""
            Start-Sleep -Seconds 1
        } else {

            Write-Host -NoNewline "     $verifyAttLanguageN1 " -ForegroundColor Yellow
            Start-Sleep -Seconds 2
            Write-Host -NoNewline "$verifyAttLanguageN2" -ForegroundColor Green
            Write-Host ""
            Start-Sleep -Seconds 1
        }

        try {
            # Baixa o arquivo de tradução do GitHub para um local temporário
            $ProgressPreference = 'SilentlyContinue'
            Invoke-WebRequest -Uri $gitTranslateUrl -OutFile $tempDownloadPath -ErrorAction Stop 
            $ProgressPreference = 'Continue'  # Restaurar o progresso ao comportamento padrão, se necessário

            # Calcula o hash do arquivo existente e do arquivo baixado
            $localFileHash = Get-FileHashValue -filePath $translationFile
            $downloadedFileHash = Get-FileHashValue -filePath $tempDownloadPath

            # Compara os hashes
            if ($localFileHash -eq $downloadedFileHash) {
                
                $fileAttCurrentLanguage = Translate-Text -Text "O arquivo de tradução local já está atualizado." -TargetLanguage $global:language

                if ([console]::Title -match "SELECIONAR IDIOMA|SELECT LANGUAGE|SELECCIONAR IDIOMA") {
                    Write-Host ""
                    Write-Host "$fileAttCurrentLanguage" -ForegroundColor Green
                } else {
                    Write-Host ""
                    Write-Host "     $fileAttCurrentLanguage" -ForegroundColor Green
                }

                # Remove o arquivo temporário, pois não houve alterações
                Remove-Item -Path $tempDownloadPath -Force
                
            } else {

                $fileAttCurrentLanguageSubstN1 = Translate-Text -Text "O arquivo de tradução foi atualizado." -TargetLanguage $global:language
                $fileAttCurrentLanguageSubstN2 = Translate-Text -Text "Substituindo o arquivo local..." -TargetLanguage $global:language
                
                Write-Host ""
                Write-Host -NoNewline "$fileAttCurrentLanguageSubstN1 " -ForegroundColor Green
                Write-Host -NoNewline "$fileAttCurrentLanguageSubstN2" -ForegroundColor Yellow
                Write-Host ""
                
                # Substitui o arquivo local pelo novo arquivo
                Move-Item -Path $tempDownloadPath -Destination $translationFile -Force

            }

            # Carrega o arquivo de tradução (.psd1) e retorna as traduções
            $global:translations = Import-PowerShellDataFile -Path $translationFile
            return $global:translations

        } catch {

            $errorVerifyDownloadFileLanguageN1 = Translate-Text -Text "Erro ao verificar ou baixar a tradução" -TargetLanguage $global:language
            $errorVerifyDownloadFileLanguageN2 = Translate-Text -Text "para o idioma $language." -TargetLanguage $global:language
            $errorVerifyDownloadFileLanguageN3 = Translate-Text -Text "Verifique sua conexão ou o link do arquivo." -TargetLanguage $global:language
            
            Write-Host ""   
            Write-Host -NoNewline "$errorVerifyDownloadFileLanguageN1 " -ForegroundColor Red
            Write-Host -NoNewline "$errorVerifyDownloadFileLanguageN2" -ForegroundColor Green
            Write-Host "$errorVerifyDownloadFileLanguageN3" -ForegroundColor Yellow
            Write-Host ""

            return $null
        }

    } else {

        $fileLanguageNotFound = Translate-Text -Text "     Arquivo de tradução para o idioma $language não encontrado." -TargetLanguage $global:language
        $selectedDownloadLanguageN1 = Translate-Text -Text "Baixando a tradução selecionada..." -TargetLanguage $global:language       
        $selectedDownloadLanguageN2 = Translate-Text -Text "[OK]" -TargetLanguage $global:language  
        
        if ([console]::Title -match "SELECIONAR IDIOMA|SELECT LANGUAGE|SELECCIONAR IDIOMA") {
            Write-Host ""
            Write-Host "$fileLanguageNotFound" -ForegroundColor Red
            Write-Host ""
            Write-Host -NoNewline "$selectedDownloadLanguageN1 " -ForegroundColor Yellow
            Start-Sleep -Seconds 3
            Write-Host -NoNewline "$selectedDownloadLanguageN2" -ForegroundColor Green
            Start-Sleep -Seconds 1
            Write-Host ""
        } else {
            Write-Host ""
            Write-Host "     $fileLanguageNotFound" -ForegroundColor Red
            Write-Host ""
            Write-Host -NoNewline "     $selectedDownloadLanguageN1 " -ForegroundColor Yellow
            Start-Sleep -Seconds 3
            Write-Host -NoNewline "$selectedDownloadLanguageN2" -ForegroundColor Green
            Start-Sleep -Seconds 1
            Write-Host ""
        }

        try {

            # Baixa o arquivo de tradução do GitHub e salva no local correto
            $ProgressPreference = 'SilentlyContinue'
            Invoke-WebRequest -Uri $gitTranslateUrl -OutFile $translationFile -ErrorAction Stop
            $ProgressPreference = 'Continue'  # Restaurar o progresso ao comportamento padrão, se necessário
            
            $fileLanguageDownloadSucefullN1 = Translate-Text -Text "Arquivo de tradução $language baixado com sucesso." -TargetLanguage $global:language
            $fileLanguageDownloadSucefullN2 = Translate-Text -Text "[OK]" -TargetLanguage $global:language

            if ([console]::Title -match "SELECIONAR IDIOMA|SELECT LANGUAGE|SELECCIONAR IDIOMA") {
                Write-Host -NoNewline "$fileLanguageDownloadSucefullN1 " -ForegroundColor Yellow
                Start-Sleep -Seconds 1
                Write-Host -NoNewline "$fileLanguageDownloadSucefullN2" -ForegroundColor Green
                Start-Sleep -Seconds 1
                Write-Host ""
            } else {
                Write-Host -NoNewline "     $fileLanguageDownloadSucefullN1 " -ForegroundColor Yellow
                Start-Sleep -Seconds 1
                Write-Host -NoNewline "$fileLanguageDownloadSucefullN2" -ForegroundColor Green
                Start-Sleep -Seconds 1
                Write-Host ""
            }

            # Pausa breve para garantir que o arquivo foi baixado
            Start-Sleep -Milliseconds 500

            $loadingfileLanguageDownloadN1 = Translate-Text -Text "Carregando o arquivo de tradução baixado..." -TargetLanguage $global:language
            $loadingfileLanguageDownloadN2 = Translate-Text -Text "[OK]" -TargetLanguage $global:language

            if ([console]::Title -match "SELECIONAR IDIOMA|SELECT LANGUAGE|SELECCIONAR IDIOMA") {
                Write-Host -NoNewline "$loadingfileLanguageDownloadN1 " -ForegroundColor Yellow
                Start-Sleep -Seconds 2
                Write-Host -NoNewline "$loadingfileLanguageDownloadN2" -ForegroundColor Green
                Start-Sleep -Seconds 1
                Write-Host ""
            } else {
                Write-Host -NoNewline "     $loadingfileLanguageDownloadN1 " -ForegroundColor Yellow
                Start-Sleep -Seconds 2
                Write-Host -NoNewline "$loadingfileLanguageDownloadN2" -ForegroundColor Green
                Start-Sleep -Seconds 1
                Write-Host ""
            }

            $global:translations = Import-PowerShellDataFile -Path $translationFile
            return $global:translations
            
        } catch {

            $errorDownloadFileLanguage = Translate-Text -Text "Erro ao baixar o arquivo de tradução para o idioma $language. Verifique sua conexão ou o link do arquivo." -TargetLanguage $global:language
            
            $errorDownloadFileLanguageN1 = Translate-Text -Text "Erro ao baixar o arquivo de tradução" -TargetLanguage $global:language
            $errorDownloadFileLanguageN2 = Translate-Text -Text "para o idioma $language. " -TargetLanguage $global:language
            $errorDownloadFileLanguageN3 = Translate-Text -Text "Verifique sua conexão ou o link do arquivo." -TargetLanguage $global:language
            
            Write-Host ""
            Write-Host -NoNewline "$errorDownloadFileLanguageN1 " -ForegroundColor Red
            Write-Host -NoNewline "$errorDownloadFileLanguageN2" -ForegroundColor Green
            Write-Host "$errorDownloadFileLanguageN3" -ForegroundColor Yellow
            Write-Host ""

            return $null            
        }
    }

}

# Função para configurar o idioma globalmente
function Initialize-Language {
    
    # Certifique-se de que a pasta de configuração existe
    if (-not (Test-Path $global:configFolderPath) -or -not (Test-Path $global:translationFolderPath)) {
        New-Item -Path $global:configFolderPath -ItemType Directory -Force
        New-Item -Path $global:translationFolderPath -ItemType Directory -Force
        # Carrega o idioma salvo no arquivo de configuração JSON
        $global:language = Get-LanguageConfig
    }

    # Verifica se o arquivo de configuração existe
    if (Test-Path $global:configFilePath) {
       
        try {

            $global:language = Get-LanguageConfig
            $loadingLanguageConfigN1 = Translate-Text -Text "Carregando o idioma do arquivo de configuração..." -TargetLanguage $global:language
            $loadingLanguageConfigN2 = Translate-Text -Text "[OK]" -TargetLanguage $global:language
            
            Write-Host ""
            Write-Host -NoNewline "     $loadingLanguageConfigN1 " -ForegroundColor Yellow
            Start-Sleep -Seconds 2
            Write-Host -NoNewline "$loadingLanguageConfigN2" -ForegroundColor Green
            Write-Host ""
            Start-Sleep -Seconds 1

        } catch {

            $global:language = "pt"  # Define idioma padrão
            $errorLoadingLanguageConfigN1 = Translate-Text -Text "Erro ao carregar a configuração." -TargetLanguage $global:language
            $errorLoadingLanguageConfigN2 = Translate-Text -Text "Usando idioma padrão (português)." -TargetLanguage $global:language
            
            Write-Host ""
            Write-Host -NoNewline "$errorLoadingLanguageConfigN1 " -ForegroundColor Red
            Write-Host -NoNewline "$errorLoadingLanguageConfigN2" -ForegroundColor Yellow
            Write-Host ""

        }

    } else {
        
        $fileLoadingLanguageNotFoundCreatedN1 = Translate-Text -Text "Arquivo de configuração não encontrado." -TargetLanguage $global:language
        $fileLoadingLanguageNotFoundCreatedN2 = Translate-Text -Text "Criando um novo com idioma padrão (português)." -TargetLanguage $global:language
        
        Write-Host ""
        Write-Host -NoNewline "$fileLoadingLanguageNotFoundCreatedN1 " -ForegroundColor Red
        Write-Host -NoNewline "$fileLoadingLanguageNotFoundCreatedN2" -ForegroundColor Green
        Write-Host ""
        
        # Carrega o idioma salvo no arquivo de configuração
        $global:language = "pt"
        Set-LanguageConfig -language $global:language
    }

    
    # Carrega as traduções para o idioma selecionado
    $fileLoadingLanguageTraductionN1 = Translate-Text -Text "Carregando traduções para o idioma:" -TargetLanguage $global:language
    $fileLoadingLanguageTraductionN2 = Translate-Text -Text "[OK]" -TargetLanguage $global:language
    
    Write-Host -NoNewline "     $fileLoadingLanguageTraductionN1 $global:language " -ForegroundColor Yellow
    Start-Sleep -Seconds 2
    Write-Host -NoNewline "$fileLoadingLanguageTraductionN2" -ForegroundColor Green
    Write-Host ""
    Start-Sleep -Seconds 1

    $global:translations = Get-Translation -language $global:language

    if ($global:translations -eq $null) {
        
        $errorLoadingLanguageScriptExit = Translate-Text -Text "Erro ao carregar as traduções. O script não pode continuar." -TargetLanguage $global:language
        
        Write-Host "$errorLoadingLanguageScriptExit" -ForegroundColor Red
        Start-Sleep -Seconds 5

    }

    $loadingLanguageSuccessfull = Translate-Text -Text "Traduções carregadas com sucesso!" -TargetLanguage $global:language
    
    #Write-Host ""
    Write-Host "     $loadingLanguageSuccessfull" -ForegroundColor Green
}

# Função para verificar a versão da aplicação
function Check-Version-App {

    # Última data de atualização da versão atual instalada da aplicação
    $idiomaSelecionado = $global:language = Get-LanguageConfig

    # Traduções
    $CompVADATTApp = Translate-Text -Text "Comparando a versão atual com a disponível para atualização da aplicação..." -TargetLanguage $global:language
    $CompVADATTAppOK = Translate-Text -Text "[OK]" -TargetLanguage $global:language
    $VDATTInstallApp = Translate-Text -Text "A aplicação já se encontra atualizada, com a versão disponível atualmente instalada." -TargetLanguage $global:language
    $LoadingDoneReqApp = Translate-Text -Text "Concluindo o carregamento inicial para verificação de requisitos em cada etapa e dando continuidade á execução da aplicação..." -TargetLanguage $global:language
    $PleaseWaitApp = Translate-Text -Text "Aguarde um momento..." -TargetLanguage $global:language
    $ATTSuccessApp = Translate-Text -Text "Atualização concluída com sucesso!" -TargetLanguage $global:language
    $RestartStepVA = Translate-Text -Text "Reiniciando a etapa de verificação da versão atual e disponível para atualização." -TargetLanguage $global:language
    $VAInstallOutdatedStartAttApp = Translate-Text -Text "A versão atual da aplicação instalada esta desatualizada, deseja iniciar a atualização agora? (S/N)" -TargetLanguage $global:language
    $SearchRequerimentsStartApp = Translate-Text -Text "Verificando requisitos necessários para dar iniciar a aplicação..." -TargetLanguage $global:language

    # Lê o conteúdo do arquivo JSON e converte para um objeto PowerShell
    $jsonFileDataLog = Get-Content -Path $global:configFilePath | ConvertFrom-Json

    # Variáveis para armazenar as informações de detalhes da aplicação
    $detalhes_app_info = $null

    # URLs para obter todos os detalhes do aplicativo
    $urls = Get-Detalhes-Aplicativo

    foreach ($url in $urls) {
        try {
            # Obter o conteúdo do arquivo do Pastebin
            $conteudo = Invoke-RestMethod -Uri $url -ErrorAction Stop
        } catch {
            Write-Host "     $($global:translations["DMAAlertMessageAccessContentURLNotFound"]): $url" -ForegroundColor Red
            continue
        }

        # Verificar se o conteúdo está vazio
        if ([string]::IsNullOrWhiteSpace($conteudo)) {
            Write-Host "     $($global:translations["DMAAlertMessageGetContentURLNotFound"]): $url" -ForegroundColor Red
            continue
        }

        # Verificar detalhes da aplicação no conteúdo obtido
        $linhas = $conteudo -split "`n"

        foreach ($linha in $linhas) {
            
            $campos = $linha -split "\|"
            
            # Verificar se há pelo menos três campos

            if ($campos.Count -ge 3) {
                
                $detalhes_app_info = @{
                    "versao_atual_app" = $campos[2].Trim()
                    "versao_disp_app" = $campos[3].Trim()
                    "versao_fult_app" = $campos[4].Trim()
                    "url_setup_install" = $campos[5].Trim()
                    "url_exe_install" = $campos[6].Trim()
                    "hash_arquivo_app" = $campos[15].Trim()
                    "caminho_setup_inst_app" = $campos[17].Trim()
                    "status_att_app" = $campos[18].Trim()
                    "status_disp_att_app" = $campos[19].Trim()
                }

                break
            }
        }

        # Se os detalhes da aplicação não foi encontrado, não precisa verificar outros links
        if ($detalhes_app_info) {
            break
        }
    }

    $versao_atual_app = $detalhes_app_info["versao_atual_app"]
    $versao_disp_app = $detalhes_app_info["versao_disp_app"]
    $versao_fult_app = $detalhes_app_info["versao_fult_app"]
    $url_setup_install = $detalhes_app_info["url_setup_install"]
    $url_exe_install = $detalhes_app_info["url_exe_install"]
    $hash_arquivo_app = $detalhes_app_info["hash_arquivo_app"]
    $tamanho_arquivo_app = $detalhes_app_info["tamanho_arquivo_app"]
    $status_att_app = $detalhes_app_info["status_att_app"]
    $status_disp_att_app = $detalhes_app_info["status_disp_att_app"] 

    # Caminho completo do .exe
    $exeFilePath = Join-Path -Path $RootPath -ChildPath $exeFileName

    # Verifica se o arquivo existe
    if (Test-Path -Path $exeFilePath) {
        # Obtém as informações de versão do arquivo .exe
        $ExeVersion = (Get-Item $exeFilePath).VersionInfo.FileVersion
        $fileExeVersion = $ExeVersion.Split(".")[0..2] -join "."
        $tamanhoExeVersion = (Get-Item $exeFilePath).Length
        $tamanhoMBFileExeVersion = [math]::Round($tamanhoExeVersion / 1MB, 2)

        # Write-Host "Tamanho do arquivo: $tamanhoMBFileExeVersion MB"
        # Write-Host "Versão do arquivo .exe: $fileExeVersion" 
    } else {
        # Obtém as informações de versão do script .ps1
        $fileScriptVersion = $scriptVersion.Substring(1)
        # Write-Host "Versão do arquivo .ps1: $fileScriptVersion"
    }

    function ExecutarAtualizacao {
                
        try {
            # Variáveis Globais
            $local_default = "C:\Users\$env:USERNAME\AppData\Local\Temp\$nome_app"

            if (-not (Test-Path -Path $local_default)) { New-Item -ItemType Directory -Path $local_default > $nul }

            $url_att_app = @(
                if ("Nenhum" -ne $url_setup_install) { $url_setup_install }
                if ("Nenhum" -ne $url_exe_install) { $url_exe_install }
            ) | Where-Object { $_ -ne "Nenhum" } | Select-Object -First 1
            $destino_att_app = @(
                if ("Nenhum" -ne $url_setup_install) { "$local_default\setup.exe" }
                if ("Nenhum" -ne $url_exe_install) { "$local_default\AsyncTech - Panel License Management.exe" }
            ) | Where-Object { $_ -ne "Nenhum" } | Select-Object -First 1

            if (Test-Path $destino_att_app) {

                # Calcula o hash SHA256 do arquivo .exe
                $hash_destino_att_app = (Get-FileHash -Path $destino_att_app -Algorithm SHA256).Hash

                # Compara o hash calculado com o hash original
                if ($hash_destino_att_app -eq $hash_arquivo_app) {

                    if ($destino_att_app.Contains("setup.exe")) {
                        
                        # Executar o arquivo a ativador .exe, e aguarda a conclusão.
                        Start-Process -FilePath $destino_att_app -PassThru -Wait
                        
                        # Data última Atualização 

                        # Adiciona a data atual ao objeto
                        $jsonFileDataLog | Add-Member -MemberType NoteProperty -Name "data_att_app" -Value (Get-Date -Format "dd/MM/yyyy HH:mm:ss") -Force
                        # Converte o objeto de volta para JSON e salva no arquivo
                        $jsonFileDataLog | ConvertTo-Json | Set-Content -Path $global:configFilePath 

                        Start-Sleep -Seconds 3
                        Exit

                    } elseif ($destino_att_app.Contains("AsyncTech - Panel License Management.exe")) {

                        # Caminho do script atual
                        $exeFileAppRoot = "$RootPath\AsyncTech - Panel License Management.exe"

                        # Mover os arquivos e substitui pelos existentes
                        Move-Item -Path "$destino_att_app" -Destination $RootPath -Force
                        # Atualização data final

                        # Data última Atualização 

                        # Adiciona a data atual ao objeto
                        $jsonFileDataLog | Add-Member -MemberType NoteProperty -Name "data_att_app" -Value (Get-Date -Format "dd/MM/yyyy HH:mm:ss") -Force
                        # Converte o objeto de volta para JSON e salva no arquivo
                        $jsonFileDataLog | ConvertTo-Json | Set-Content -Path $global:configFilePath 

                        Start-Sleep -Seconds 3

                        # Inicia o script novamente
                        # Start-Process -FilePath $exeFileAppRoot
                        # Exit
                    }

                } else {

                    Remove-Item -Recurse -Force -Path $destino_att_app
                    
                    Start-Sleep -Seconds 3

                    return ExecutarAtualizacao
                }

            } else {

                # Usando Invoke-WebRequest para baixar o arquivo
                $response = Invoke-WebRequest -Uri "$url_att_app" -OutFile "$destino_att_app" -ErrorAction Stop

                if ($destino_att_app.Contains("setup.exe")) {
                    # Executar o arquivo a ativador .exe, e aguarda a conclusão.
                    Start-Process -FilePath $destino_att_app -PassThru -Wait

                    # Data última Atualização 

                    # Adiciona a data atual ao objeto
                    $jsonFileDataLog | Add-Member -MemberType NoteProperty -Name "data_att_app" -Value (Get-Date -Format "dd/MM/yyyy HH:mm:ss") -Force
                    # Converte o objeto de volta para JSON e salva no arquivo
                    $jsonFileDataLog | ConvertTo-Json | Set-Content -Path $global:configFilePath 

                    Start-Sleep -Seconds 3
                    Exit

                } elseif ($destino_att_app.Contains("AsyncTech - Panel License Management.exe")) {
                    # Caminho do script atual
                    $exeFileAppRoot = "$RootPath\AsyncTech - Panel License Management.exe"

                    # Mover os arquivos e substitui pelos existentes
                    Move-Item -Path "$destino_att_app" -Destination $RootPath -Force
                    
                    # Data última Atualização 

                    # Adiciona a data atual ao objeto
                    $jsonFileDataLog | Add-Member -MemberType NoteProperty -Name "data_att_app" -Value (Get-Date -Format "dd/MM/yyyy HH:mm:ss") -Force
                    # Converte o objeto de volta para JSON e salva no arquivo
                    $jsonFileDataLog | ConvertTo-Json | Set-Content -Path $global:configFilePath 

                    Start-Sleep -Seconds 3

                    # Inicia o script novamente
                    # Start-Process -FilePath $exeFileAppRoot 
                    # Exit
                }
            }

        } catch {
            Write-Host "$($global:translations["SUMRUErrorExecutingUpdate"]): $_" -ForegroundColor Red
        }
    }

    
    if ($versao_disp_app -ne "Nenhum" -and $versao_disp_app -ne $fileExeVersion){


        $LoadingConfirmOK = Translate-Text -Text "[OK]" -TargetLanguage $global:language
        
        Write-Host -NoNewline "     $SearchRequerimentsStartApp" -ForegroundColor Yellow
        Start-Sleep -Seconds 2
        Write-Host -NoNewline " $LoadingConfirmOK" -ForegroundColor Green
        Write-Host ""

        Write-Host ""
    
        $opcao_verificar_versaoapp = Read-Host "     $VAInstallOutdatedStartAttApp"
        
        if($opcao_verificar_versaoapp -eq "s") {


            ExecutarAtualizacao
            Write-Host ""
            Write-Host "     $PleaseWaitApp" -ForegroundColor Green
            Start-Sleep -Seconds 3
            Write-Host "     $ATTSuccessApp" -ForegroundColor Green
            Write-Host ""
            Write-Host -NoNewline "     $RestartStepVA" -ForegroundColor Yellow
            Start-Sleep -Seconds 2
            Write-Host -NoNewline " $LoadingConfirmOK" -ForegroundColor Green
            Start-Sleep -Seconds 1
            Write-Host ""
            Check-Version-App

        } else {


            Write-Host -NoNewline "     $CompVADATTApp" -ForegroundColor Yellow
            Start-Sleep -Seconds 2
            Write-Host -NoNewline " $LoadingConfirmOK" -ForegroundColor Green
            Write-Host ""
            Start-Sleep -Seconds 3
            Write-Host "     ================================================================================================================" -ForegroundColor Green
            Write-Host ""
            Write-Host "     $LoadingDoneReqApp" -ForegroundColor Yellow
            Start-Sleep -Seconds 2
            Write-Host ""
            Write-Host "     $PleaseWaitApp" -ForegroundColor Green
            Start-Sleep -Seconds 3
        }

    } else {



        Write-Host -NoNewline "     $CompVADATTApp" -ForegroundColor Yellow
        Start-Sleep -Seconds 2
        Write-Host -NoNewline " $CompVADATTAppOK" -ForegroundColor Green
        Start-Sleep -Seconds 3
        Write-Host ""
        Write-Host ""
        Write-Host "     $VDATTInstallApp" -ForegroundColor Green
        Write-Host ""
        Start-Sleep -Seconds 3
        Write-Host "     ================================================================================================================" -ForegroundColor Green
        Write-Host ""
        Write-Host "     $LoadingDoneReqApp" -ForegroundColor Yellow
        Start-Sleep -Seconds 2
        Write-Host ""
        Write-Host "     $PleaseWaitApp" -ForegroundColor Green
        Start-Sleep -Seconds 3
    }

}

# Define o nome e a versão
$scriptName = "AsyncTech - Panel License Management"
$scriptVersion = "v1.0.0"
# Nome do arquivo .exe
$exeFileName = "$($scriptName).exe"

# Adiciona o título na janela do PowerShell
$windowTitle = "$scriptName - $scriptVersion"
[console]::Title = $windowTitle

# Função simples para atualizar o título do console de forma dinâmica
function Update-Title-WindowMenu {
    param (
        [string]$menuKey,  # A chave do menu (ex: "MainMenu", "Option1")
        [string]$menuExt, 
        [string]$idiomaSelecionado
    )

    # Atualiza o título do console com base na chave fornecida
    $newTitle = "$scriptName - $scriptVersion"
    
    if ($idiomaSelecionado) {

        $menyKeyTranslate = Translate-Text -Text "$menuKey" -TargetLanguage $language
        $newTitle += " - " + $menyKeyTranslate.ToUpper()

    } else {
     
        if ($global:translations.ContainsKey($menuKey) -and $menuExt) {
            $newTitle += " - " + $global:translations[$menuKey].ToUpper() + " - " + $menuExt
        } elseif ($global:translations.ContainsKey($menuKey)) {
            $newTitle += " - " + $global:translations[$menuKey].ToUpper()
        }
    }

    [console]::Title = $newTitle

    # Armazena a chave do menu atual para referência
    $global:currentMenu = $menuKey
}

# Menu Principal

function Show-Menu {

    param (
        [bool]$LoginStatus = $false,
        [string]$UsuarioAtual = $null,
        [string]$SenhaAtual = $null,
        [string]$TipoPlanoConta = $null
    )
    
    Update-Title-WindowMenu -menuKey "MMMainMenu"  # Atualiza o título para o menu principal

    cls

    $fixedWidthMainMenu = 120  # Largura total da linha

    # Frase a ser centralizada
    $mainMenuTexto = $($global:translations["MMMainMenu"])
    $mainMenuTextoLength = $mainMenuTexto.Length

    # Calcula o número de espaços necessários para centralizar
    $spacesNeededMainMenu = [Math]::Max(([Math]::Floor(($fixedWidthMainMenu - $mainMenuTextoLength) / 2)), 0)
    $spacesMainMenu = " " * $spacesNeededMainMenu

    Write-Host ""
    Write-Host "     ================================================================================================================" -ForegroundColor Green
    Write-Host "$spacesMainMenu$mainMenuTexto" -ForegroundColor Cyan
    Write-Host "     ================================================================================================================" -ForegroundColor Green 
    Write-Host ""
    Write-Host "     ================================================================================================================" -ForegroundColor Gray
    Write-Host "" 
    Write-Host -NoNewline "     [1] - "  -ForegroundColor Yellow
    Write-Host $($global:translations["MMLogin"]) -ForegroundColor Green
    Write-Host -NoNewline "     [2] - " -ForegroundColor Yellow
    Write-Host $($global:translations["MMSearchUpdate"]) -ForegroundColor Blue
    Write-Host -NoNewline "     [3] - "  -ForegroundColor Yellow
    Write-Host $($global:translations["MMSelectLanguage"]) -ForegroundColor Magenta
    Write-Host -NoNewline "     [4] - "  -ForegroundColor Yellow
    Write-Host $($global:translations["MMVIPGroup"]) -ForegroundColor Cyan
    Write-Host -NoNewline "     [5] - "  -ForegroundColor Yellow
    Write-Host $($global:translations["MMExit"]) -ForegroundColor Red
    Write-Host ""
    Write-Host "     ================================================================================================================" -ForegroundColor Gray
    Write-Host ""

    $opcao = Read-Host $($global:translations["MMChoiceOption"])

    switch ($opcao) {
        1 { Fazer-Login -LoginStatus $LoginStatus -UsuarioAtual $usuario_atual -SenhaAtual $senha_atual -TipoPlanoConta $plano_conta_atual }
        2 { Verificar-Atualizacoes -LoginStatus $LoginStatus -UsuarioAtual $usuario_atual -SenhaAtual $senha_atual -TipoPlanoConta $plano_conta_atual }
        3 { Selecionar-Idioma -LoginStatus $LoginStatus -UsuarioAtual $usuario_atual -SenhaAtual $senha_atual -TipoPlanoConta $plano_conta_atual }
        4 { Grupo-VIP -LoginStatus $LoginStatus -UsuarioAtual $usuario_atual -SenhaAtual $senha_atual -TipoPlanoConta $plano_conta_atual }
        5 { 
            Write-Host ""
            Write-Host -NoNewline "$($global:translations["MMChoiceOptionExit"])" -ForegroundColor Red
            Start-Sleep -Seconds 2
            # Stop-Process -Name "PowershellShowcase"
            Exit 
        }
        default { 

            Write-Host ""
            Write-Host $($global:translations["DOInvalidOptionN2"]) -ForegroundColor Red
            Write-Host ""

            Start-Sleep -Seconds 3
            Show-Menu -LoginStatus $LoginStatus -UsuarioAtual $usuario_atual -SenhaAtual $senha_atual -TipoPlanoConta $plano_conta_atual ; 
        }
    }
}

# Menu Fazer Login
function Fazer-Login {

    param (
        [bool]$LoginStatus = $false,
        [string]$UsuarioAtual = $null,
        [string]$SenhaAtual = $null,
        [string]$TipoPlanoConta = $null
    )

    Update-Title-WindowMenu -menuKey "MMLogin"  # Atualiza o título para o menu principal

    cls

    $fixedWidthLoginMenu = 120  # Largura total da linha

    # Frase a ser centralizada
    $loginMenuTexto = $($global:translations["LMLoginMenu"])
    $loginMenuTextoLength = $loginMenuTexto.Length

    # Calcula o número de espaços necessários para centralizar
    $spacesNeededLoginMenu = [Math]::Max(([Math]::Floor(($fixedWidthLoginMenu - $loginMenuTextoLength) / 2)), 0)
    $spacesLoginMenu = " " * $spacesNeededLoginMenu

    Write-Host ""
    Write-Host "     ================================================================================================================" -ForegroundColor Green
    Write-Host "$spacesLoginMenu$loginMenuTexto" -ForegroundColor Cyan
    Write-Host "     ================================================================================================================" -ForegroundColor Green 
    Write-Host ""

    function Read-Password {
        [System.Console]::ForegroundColor = 'Yellow'
        [Console]::Write("     $($global:translations["LMEnterPass"]): ") 
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

    if ($loginStatus -eq $true) {
       
        Write-Host -NoNewline "     $($global:translations["LMEnterUser"]): " -ForegroundColor Yellow 
        # Captura da entrada do usuário (entrada em si não pode ser colorida)
        $usuario = $UsuarioAtual
        
        Write-Host ""

        # Exibir o que foi digitado em uma cor específica
        Write-Host -NoNewline "     $($global:translations["LMShowUser"]): "
        Write-Host $usuario -ForegroundColor Yellow
    
        Write-Host ""

        Write-Host -NoNewline "     $($global:translations["LMEnterPass"]): " -ForegroundColor Yellow 
        # Captura da entrada da senha (entrada em si não pode ser colorida)
        # Exibir a senha digitada em uma cor específica (por razões de segurança, geralmente não se exibe a senha)
        $senha = $SenhaAtual
        # Substituir o conteúdo da senha por asteriscos
        $asteriscosSenha = "*" * $senha.Length

        Write-Host ""

        Write-Host -NoNewline "     $($global:translations["LMShowPass"]): "
        Write-Host $asteriscosSenha -ForegroundColor Yellow

        # URLs para obter todos os usuarios
        $urls = Get-Todos-Usuarios

        # Verificar usuário e senha no conteúdo obtido
        $encontrado = $false

        # Verifica se o usuário ou a senha estão vazios
        if ([string]::IsNullOrEmpty($usuario) -or [string]::IsNullOrEmpty($senha)) {
            Write-Host ""
            Write-Host -NoNewline "     $($global:translations["LMErrorLoginN1"])" -ForegroundColor Red
            Write-Host " $($global:translations["LMEmptyLogin"])" -ForegroundColor Yellow
            Write-Host ""
            $encontrado = $false
            pause
        } else {
            foreach ($url in $urls) {
                try {
                    # Obter o conteúdo do arquivo do Pastebin
                    $conteudo = Invoke-RestMethod -Uri $url -ErrorAction Stop
                } catch {
                    Write-Host "     $($global:translations["DMAAlertMessageAccessContentURLNotFound"]): $url" -ForegroundColor Red
                    continue
                }

                # Verificar se o conteúdo está vazio
                if ([string]::IsNullOrWhiteSpace($conteudo)) {
                    Write-Host "     $($global:translations["DMAAlertMessageGetContentURLNotFound"]): $url" -ForegroundColor Red
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
                            Write-Host -NoNewline "     $($global:translations["LMSuccessLoginN1"]) " -ForegroundColor Green
                            Write-Host -NoNewline "$($global:translations["LMSuccessLoginN2"]) " -ForegroundColor Yellow
                            Write-Host -NoNewline "$($global:translations["LMSuccessLoginN3"])" -ForegroundColor Cyan 
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
    
    } else {

        Write-Host -NoNewline "     $($global:translations["LMEnterUser"]): " -ForegroundColor Yellow 
        # Captura da entrada do usuário (entrada em si não pode ser colorida)
        $usuario = Read-Host
    
        Write-Host ""

        # Exibir o que foi digitado em uma cor específica
        Write-Host -NoNewline "     $($global:translations["LMShowUser"]): "
        Write-Host $usuario -ForegroundColor Yellow
    
        Write-Host ""

        # Prompt para a senha
        $senha = Read-Password
        # Exibir a senha digitada em uma cor específica (por razões de segurança, geralmente não se exibe a senha)
    
        Write-Host ""

        # Substituir o conteúdo da senha por asteriscos
        $asteriscosSenha = "*" * $senha.Length

        Write-Host -NoNewline "     $($global:translations["LMShowPass"]): "
        Write-Host $asteriscosSenha -ForegroundColor Yellow

        # URLs para obter todos os usuarios
        $urls = Get-Todos-Usuarios

        # Verificar usuário e senha no conteúdo obtido
        $encontrado = $false

        # Verifica se o usuário ou a senha estão vazios
        if ([string]::IsNullOrEmpty($usuario) -or [string]::IsNullOrEmpty($senha)) {
            Write-Host ""
            Write-Host -NoNewline "     $($global:translations["LMErrorLoginN1"])" -ForegroundColor Red
            Write-Host " $($global:translations["LMEmptyLogin"])" -ForegroundColor Yellow
            Write-Host ""
            $encontrado = $false
            pause
        } else {
            foreach ($url in $urls) {
                try {
                    # Obter o conteúdo do arquivo do Pastebin
                    $conteudo = Invoke-RestMethod -Uri $url -ErrorAction Stop
                } catch {
                    Write-Host "     $($global:translations["DMAAlertMessageAccessContentURLNotFound"]): $url" -ForegroundColor Red
                    continue
                }

                # Verificar se o conteúdo está vazio
                if ([string]::IsNullOrWhiteSpace($conteudo)) {
                    Write-Host "     $($global:translations["DMAAlertMessageGetContentURLNotFound"]): $url" -ForegroundColor Red
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
                            Write-Host -NoNewline "     $($global:translations["LMSuccessLoginN1"]) " -ForegroundColor Green
                            Write-Host -NoNewline "$($global:translations["LMSuccessLoginN2"]) " -ForegroundColor Yellow
                            Write-Host -NoNewline "$($global:translations["LMSuccessLoginN3"])" -ForegroundColor Cyan 
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
    }

    if (-not $encontrado -and -not [string]::IsNullOrEmpty($usuario) -and -not [string]::IsNullOrEmpty($senha)) {
        Write-Host ""
        Write-Host -NoNewline "     $($global:translations["LMErrorLoginN1"])" -ForegroundColor Red
        Write-Host " $($global:translations["LMErrorLoginN2"])" -ForegroundColor Yellow
        Write-Host ""
        pause
    }

    Show-Menu
}

# Menu Status Servidor
function Verificar-Atualizacoes {
  
    param (
        [bool]$LoginStatus = $false,
        [string]$UsuarioAtual = $null,
        [string]$SenhaAtual = $null,
        [string]$TipoPlanoConta = $null
    )

    
    Update-Title-WindowMenu -menuKey "MMSearchUpdate"  # Atualiza o título para o menu principal
    
    # Última data de atualização da versão atual instalada da aplicação
    $idiomaSelecionado = $global:language = Get-LanguageConfig

    # Lê o conteúdo do arquivo JSON e converte para um objeto PowerShell
    $jsonFileDataLog = Get-Content -Path $global:configFilePath | ConvertFrom-Json


    if ((Test-Path -Path $global:configFilePath) -and (-not $jsonFileDataLog.PSObject.Properties["data_att_app"])) { 
        
        # Adiciona a data atual ao objeto
        $jsonFileDataLog | Add-Member -MemberType NoteProperty -Name "data_att_app" -Value (Get-Date -Format "dd/MM/yyyy HH:mm:ss") -Force
        # Converte o objeto de volta para JSON e salva no arquivo
        $jsonFileDataLog | ConvertTo-Json | Set-Content -Path $global:configFilePath 

    } else {

        # Recarrega o conteúdo atualizado do arquivo JSON
        $jsonFileDataAtualizado = Get-Content -Path $global:configFilePath | ConvertFrom-Json
        # Armazena o valor de "data_att_app" em uma variável
        $getFileDataLog = $jsonFileDataAtualizado.data_att_app
    }
   

    # Start-Sleep -Seconds 15

    # Variáveis para armazenar as informações de detalhes da aplicação
    $detalhes_app_info = $null

    # URLs para obter todos os detalhes do aplicativo
    $urls = Get-Detalhes-Aplicativo

    foreach ($url in $urls) {
        try {
            # Obter o conteúdo do arquivo do Pastebin
            $conteudo = Invoke-RestMethod -Uri $url -ErrorAction Stop
        } catch {
            Write-Host "     $($global:translations["DMAAlertMessageAccessContentURLNotFound"]): $url" -ForegroundColor Red
            continue
        }

        # Verificar se o conteúdo está vazio
        if ([string]::IsNullOrWhiteSpace($conteudo)) {
            Write-Host "     $($global:translations["DMAAlertMessageGetContentURLNotFound"]): $url" -ForegroundColor Red
            continue
        }

        # Verificar detalhes da aplicação no conteúdo obtido
        $linhas = $conteudo -split "`n"

        foreach ($linha in $linhas) {
            
            $campos = $linha -split "\|"
            
            # Verificar se há pelo menos três campos

            if ($campos.Count -ge 3) {
                
                $detalhes_app_info = @{
                    "id_detail_app" = $campos[0].Trim()
                    "nome_app" = $campos[1].Trim()
                    "versao_atual_app" = $campos[2].Trim()
                    "versao_disp_app" = $campos[3].Trim()
                    "versao_fult_app" = $campos[4].Trim()
                    "url_setup_install" = $campos[5].Trim()
                    "url_exe_install" = $campos[6].Trim()
                    "registro_alteracoes_app" = $campos[13].Trim()
                    "data_att_app" = $campos[14].Trim()
                    "hash_arquivo_app" = $campos[15].Trim()
                    "tamanho_arquivo_app" = $campos[16].Trim()
                    "caminho_setup_inst_app" = $campos[17].Trim()
                    "status_att_app" = $campos[18].Trim()
                    "status_disp_att_app" = $campos[19].Trim()
                }

                break
            }
        }

        # Se os detalhes da aplicação não foi encontrado, não precisa verificar outros links
        if ($detalhes_app_info) {
            break
        }
    }


    $nome_app = $detalhes_app_info["nome_app"]
    $versao_atual_app = $detalhes_app_info["versao_atual_app"]
    $versao_disp_app = $detalhes_app_info["versao_disp_app"]
    $versao_fult_app = $detalhes_app_info["versao_fult_app"]
    $url_setup_install = $detalhes_app_info["url_setup_install"]
    $url_exe_install = $detalhes_app_info["url_exe_install"]
    $registro_alteracoes = $detalhes_app_info["registro_alteracoes_app"]
    $hash_arquivo_app = $detalhes_app_info["hash_arquivo_app"]
    $tamanho_arquivo_app = $detalhes_app_info["tamanho_arquivo_app"]
    $status_att_app = $detalhes_app_info["status_att_app"]
    $status_disp_att_app = $detalhes_app_info["status_disp_att_app"]

    $status_disp_att_app = Translate-Text -Text "$status_disp_att_app" -TargetLanguage $global:language
    $registro_alteracoes = Translate-Text -Text "$registro_alteracoes" -TargetLanguage $global:language
    $status_habilitacao = Translate-Text -Text "Habilitado" -TargetLanguage $global:language

    function ExecutarAtualizacao {

        try {
            # Variáveis Globais
            $local_default = "C:\Users\$env:USERNAME\AppData\Local\Temp\$nome_app"

            if (-not (Test-Path -Path $local_default)) { New-Item -ItemType Directory -Path $local_default > $nul }

            $url_att_app = @(
                if ("Nenhum" -ne $url_setup_install) { $url_setup_install }
                if ("Nenhum" -ne $url_exe_install) { $url_exe_install }
            ) | Where-Object { $_ -ne "Nenhum" } | Select-Object -First 1
            $destino_att_app = @(
                if ("Nenhum" -ne $url_setup_install) { "$local_default\setup.exe" }
                if ("Nenhum" -ne $url_exe_install) { "$local_default\AsyncTech - Panel License Management.exe" }
            ) | Where-Object { $_ -ne "Nenhum" } | Select-Object -First 1

            if (Test-Path $destino_att_app) {

                # Calcula o hash SHA256 do arquivo .exe
                $hash_destino_att_app = (Get-FileHash -Path $destino_att_app -Algorithm SHA256).Hash

                # Compara o hash calculado com o hash original
                if ($hash_destino_att_app -eq $hash_arquivo_app) {

                    if ($destino_att_app.Contains("setup.exe")) {
                        
                        # Executar o arquivo a ativador .exe, e aguarda a conclusão.
                        Start-Process -FilePath $destino_att_app -PassThru -Wait
                        
                        # Data última Atualização 

                        # Adiciona a data atual ao objeto
                        $jsonFileDataLog | Add-Member -MemberType NoteProperty -Name "data_att_app" -Value (Get-Date -Format "dd/MM/yyyy HH:mm:ss") -Force
                        # Converte o objeto de volta para JSON e salva no arquivo
                        $jsonFileDataLog | ConvertTo-Json | Set-Content -Path $global:configFilePath 

                        Start-Sleep -Seconds 3
                        Exit

                    } elseif ($destino_att_app.Contains("AsyncTech - Panel License Management.exe")) {

                        # Caminho do script atual
                        $exeFileAppRoot = "$RootPath\AsyncTech - Panel License Management.exe"

                        # Mover os arquivos e substitui pelos existentes
                        Move-Item -Path "$destino_att_app" -Destination $RootPath -Force
                        # Atualização data final

                        # Data última Atualização 

                        # Adiciona a data atual ao objeto
                        $jsonFileDataLog | Add-Member -MemberType NoteProperty -Name "data_att_app" -Value (Get-Date -Format "dd/MM/yyyy HH:mm:ss") -Force
                        # Converte o objeto de volta para JSON e salva no arquivo
                        $jsonFileDataLog | ConvertTo-Json | Set-Content -Path $global:configFilePath 

                        Start-Sleep -Seconds 3

                        # Inicia o script novamente
                        # Start-Process -FilePath $exeFileAppRoot
                        # Exit
                    }

                } else {

                    Remove-Item -Recurse -Force -Path $destino_att_app
                    
                    Start-Sleep -Seconds 3

                    return ExecutarAtualizacao
                }

            } else {

                # Usando Invoke-WebRequest para baixar o arquivo
                $response = Invoke-WebRequest -Uri "$url_att_app" -OutFile "$destino_att_app" -ErrorAction Stop

                if ($destino_att_app.Contains("setup.exe")) {
                    # Executar o arquivo a ativador .exe, e aguarda a conclusão.
                    Start-Process -FilePath $destino_att_app -PassThru -Wait

                    # Data última Atualização 

                    # Adiciona a data atual ao objeto
                    $jsonFileDataLog | Add-Member -MemberType NoteProperty -Name "data_att_app" -Value (Get-Date -Format "dd/MM/yyyy HH:mm:ss") -Force
                    # Converte o objeto de volta para JSON e salva no arquivo
                    $jsonFileDataLog | ConvertTo-Json | Set-Content -Path $global:configFilePath 

                    Start-Sleep -Seconds 3
                    Exit

                } elseif ($destino_att_app.Contains("AsyncTech - Panel License Management.exe")) {
                    # Caminho do script atual
                    $exeFileAppRoot = "$RootPath\AsyncTech - Panel License Management.exe"

                    # Mover os arquivos e substitui pelos existentes
                    Move-Item -Path "$destino_att_app" -Destination $RootPath -Force
                    
                    # Data última Atualização 

                    # Adiciona a data atual ao objeto
                    $jsonFileDataLog | Add-Member -MemberType NoteProperty -Name "data_att_app" -Value (Get-Date -Format "dd/MM/yyyy HH:mm:ss") -Force
                    # Converte o objeto de volta para JSON e salva no arquivo
                    $jsonFileDataLog | ConvertTo-Json | Set-Content -Path $global:configFilePath 

                    Start-Sleep -Seconds 3

                    # Inicia o script novamente
                    # Start-Process -FilePath $exeFileAppRoot 
                    # Exit
                }
            }

        } catch {
            Write-Host "$($global:translations["SUMRUErrorExecutingUpdate"]): $_" -ForegroundColor Red
        }
    }


    do {

        # Analisar detalhes da aplicação e retirar os
        $versoes_alteracoes = $registro_alteracoes -split ';'

        $detalhesTitleVersaoAtualApp = $null
        $detalhesTitleVersaoFuturaApp = $null

        $detalhesItemsVersaoAtualApp = $null
        $detalhesItemsVersaoFuturaApp = $null

        # Iterando sobre os conjuntos para identificar o índice e armazenar na variável correspondente
        foreach ($versao_alteracao in $versoes_alteracoes) {

            if ($versao_alteracao.StartsWith($versao_atual_app)) {

                $detalhesVersaoAtual = $versao_alteracao -split ';'
                $detalhesItemsVersaoAtual = $detalhesVersaoAtual -split '>>'
                $detalhesTitleVersaoAtual = $detalhesItemsVersaoAtual -split '>'

                $detalhesTitleVersaoAtualApp = $detalhesTitleVersaoAtual -notmatch ":|$versao_atual_app"
                $detalhesItemsVersaoAtualApp = $detalhesItemsVersaoAtual -notmatch "$versao_atual_app"
                                                       
            } elseif ($versao_alteracao.StartsWith($versao_fult_app)) {

                $detalhesVersaoFutura = $versao_alteracao -split ';'
                $detalhesItemsVersaoFutura = $detalhesVersaoFutura -split '>>'
                $detalhesTitleVersaoFutura = $detalhesItemsVersaoFutura -split '>'

                $detalhesTitleVersaoFuturaApp = $detalhesTitleVersaoFutura -notmatch ":|$versao_fult_app"
                $detalhesItemsVersaoFuturaApp = $detalhesItemsVersaoFutura -notmatch "$versao_fult_app"
            }
        }

        # Caminho completo do .exe
        $exeFilePath = Join-Path -Path $RootPath -ChildPath $exeFileName

        # Verifica se o arquivo existe
        if (Test-Path -Path $exeFilePath) {
            # Obtém as informações de versão do arquivo .exe
            $ExeVersion = (Get-Item $exeFilePath).VersionInfo.FileVersion
            $fileExeVersion = $ExeVersion.Split(".")[0..2] -join "."
            $tamanhoExeVersion = (Get-Item $exeFilePath).Length
            $tamanhoMBFileExeVersion = [math]::Round($tamanhoExeVersion / 1MB, 2)

            # Write-Host "Tamanho do arquivo: $tamanhoMBFileExeVersion MB"
            # Write-Host "Versão do arquivo .exe: $fileExeVersion" 
        } else {
            # Obtém as informações de versão do script .ps1
            $fileScriptVersion = $scriptVersion.Substring(1)
            # Write-Host "Versão do arquivo .ps1: $fileScriptVersion"
        }

        function ListarMudancasAtualizacao {


            try {

                if($opcao_verificar_atualizacoes -eq 3 -and $fileExeVersion -eq $versao_fult_app) {
                    
                    Write-Host ""
                    Write-Host -NoNewline "      $($global:translations["SUMSCUStatusChangesAvailableVersion"]) " -ForegroundColor Yellow
                    Write-Host -NoNewline "$versao_disp_app" -ForegroundColor Green
                    Write-Host -NoNewline ":" -ForegroundColor Yellow
                    Write-Host ""
                    Write-Host ""

                    foreach ($regAltTitleVF in $detalhesTitleVersaoFuturaApp) {
                    
                        Write-Host -NoNewline "      > " -ForegroundColor Green
                        Write-Host -NoNewline "$($regAltTitleVF):" -ForegroundColor Yellow
                        Write-Host ""

                        foreach ($regAltItemVF in $detalhesItemsVersaoFuturaApp) {

                            $regAltItemVFCampo = $regAltItemVF -split '>'
                                            

                            if($regAltItemVFCampo[0] -eq $regAltTitleVF) {
                            
                                $regAltItemVFCorrigido = $regAltItemVFCampo -notmatch "$regAltTitleVF"
                                $regAltItemVFCorrigido = $regAltItemVFCorrigido -split ","

                                foreach ($regAltCorrigido in $regAltItemVFCorrigido) {
                                
                                    $texto, $status = $regAltCorrigido -split ":"

                                    Write-Host -NoNewline "      $($texto):" -ForegroundColor White
                                    if($status -eq $status_habilitacao) {
                                        Write-Host -NoNewline " $status" -ForegroundColor Green 
                                    } else {
                                        Write-Host -NoNewline " $status" -ForegroundColor Red
                                    }
                                    Write-Host ""

                                }
                            }
                        }
                    }

                    Write-Host ""
                    Write-Host "     ================================================================================================================" -ForegroundColor Green
                    Write-Host ""

                } elseif ($opcao_verificar_atualizacoes -eq 3 -and $fileExeVersion -ne $versao_fult_app) {

                    if ($versao_alteracao.Contains($versao_disp_app)) {

                        Write-Host ""
                        Write-Host -NoNewline "      $($global:translations["SUMSCUStatusChangesAvailableVersion"]) " -ForegroundColor Yellow
                        Write-Host -NoNewline "$versao_disp_app" -ForegroundColor Magenta
                        Write-Host -NoNewline ":" -ForegroundColor Yellow
                        Write-Host ""
                        Write-Host ""

                        foreach ($regAltTitleVF in $detalhesTitleVersaoFuturaApp) {
                    
                            Write-Host -NoNewline "      > " -ForegroundColor Magenta
                            Write-Host -NoNewline "$($regAltTitleVF):" -ForegroundColor Yellow
                            Write-Host ""

                            foreach ($regAltItemVF in $detalhesItemsVersaoFuturaApp) {

                                $regAltItemVFCampo = $regAltItemVF -split '>'
                                            

                                if($regAltItemVFCampo[0] -eq $regAltTitleVF) {
                            
                                    $regAltItemVFCorrigido = $regAltItemVFCampo -notmatch "$regAltTitleVF"
                                    $regAltItemVFCorrigido = $regAltItemVFCorrigido -split ","

                                    foreach ($regAltCorrigido in $regAltItemVFCorrigido) {
                                
                                        $texto, $status = $regAltCorrigido -split ":"

                                        Write-Host -NoNewline "      $($texto):" -ForegroundColor White
                                        if($status -eq $status_habilitacao) {
                                            Write-Host -NoNewline " $status" -ForegroundColor Green 
                                        } else {
                                            Write-Host -NoNewline " $status" -ForegroundColor Red
                                        }
                                        Write-Host ""

                                    }
                                }
                            }
                        }

                        Write-Host ""
                        Write-Host "     ================================================================================================================" -ForegroundColor Green
                        Write-Host "" 
                            
                                                        
                    } else {

                        Write-Host ""
                        Write-Host -NoNewline "      $($global:translations["SUMSCUStatusChangesAvailableVersion"]) " -ForegroundColor Yellow
                        Write-Host -NoNewline "$versao_disp_app" -ForegroundColor Magenta
                        Write-Host -NoNewline ": " -ForegroundColor Yellow
                        Write-Host -NoNewline "$($global:translations["SUMSNotAvailableMoment"])" -ForegroundColor Red
                        Write-Host ""
                        Write-Host ""
                        Write-Host "     ================================================================================================================" -ForegroundColor Green
                        Write-Host "" 
                            

                    }
                
                } elseif ($opcao_verificar_atualizacoes -eq 2 -and $fileExeVersion -eq $versao_atual_app) {
                    
                    Write-Host ""
                    Write-Host -NoNewline "      $($global:translations["SUMSCUStatusChangesCurrentVersion"]) " -ForegroundColor Yellow
                    Write-Host -NoNewline "$versao_atual_app" -ForegroundColor Green
                    Write-Host -NoNewline ":" -ForegroundColor Yellow
                    Write-Host ""
                    Write-Host ""

                    foreach ($regAltTitleVA in $detalhesTitleVersaoAtualApp) {
                    
                        Write-Host -NoNewline "      > " -ForegroundColor Cyan
                        Write-Host -NoNewline "$($regAltTitleVA):" -ForegroundColor Yellow
                        Write-Host ""

                        foreach ($regAltItemVA in $detalhesItemsVersaoAtualApp) {

                            $regAltItemVACampo = $regAltItemVA -split '>'
                                            

                            if($regAltItemVACampo[0] -eq $regAltTitleVA) {
                            
                                $regAltItemVACorrigido = $regAltItemVACampo -notmatch "$regAltTitleVA"
                                $regAltItemVACorrigido = $regAltItemVACorrigido -split ","

                                foreach ($regAltCorrigido in $regAltItemVACorrigido) {
                                
                                    $texto, $status = $regAltCorrigido -split ":"

                                    Write-Host -NoNewline "      $($texto):" -ForegroundColor White
                                    if($status -eq $status_habilitacao) {
                                        Write-Host -NoNewline " $status" -ForegroundColor Green 
                                    } else {
                                        Write-Host -NoNewline " $status" -ForegroundColor Red
                                    }
                                    Write-Host ""

                                }
                            }
                        }
                    }

                    Write-Host ""
                    Write-Host "     ================================================================================================================" -ForegroundColor Green
                    Write-Host ""

                } else {
                        
                    Write-Host ""
                    Write-Host -NoNewline "      $($global:translations["SUMSCUStatusChangesAvailableVersion"]) " -ForegroundColor Yellow
                    Write-Host -NoNewline "$versao_disp_app" -ForegroundColor Green
                    Write-Host -NoNewline ":" -ForegroundColor Yellow
                    Write-Host ""
                    Write-Host ""

                    foreach ($regAltTitleVF in $detalhesTitleVersaoFuturaApp) {
                    
                        Write-Host -NoNewline "      > " -ForegroundColor Green
                        Write-Host -NoNewline "$($regAltTitleVF):" -ForegroundColor Yellow
                        Write-Host ""

                        foreach ($regAltItemVF in $detalhesItemsVersaoFuturaApp) {

                            $regAltItemVFCampo = $regAltItemVF -split '>'
                                            

                            if($regAltItemVFCampo[0] -eq $regAltTitleVF) {
                            
                                $regAltItemVFCorrigido = $regAltItemVFCampo -notmatch "$regAltTitleVF"
                                $regAltItemVFCorrigido = $regAltItemVFCorrigido -split ","

                                foreach ($regAltCorrigido in $regAltItemVFCorrigido) {
                                
                                    $texto, $status = $regAltCorrigido -split ":"

                                    Write-Host -NoNewline "      $($texto):" -ForegroundColor White
                                    if($status -eq $status_habilitacao) {
                                        Write-Host -NoNewline " $status" -ForegroundColor Green 
                                    } else {
                                        Write-Host -NoNewline " $status" -ForegroundColor Red
                                    }
                                    Write-Host ""

                                }
                            }
                        }
                    }

                    Write-Host ""
                    Write-Host "     ================================================================================================================" -ForegroundColor Green
                    Write-Host ""
                    
                }
            
            } catch {
                Write-Host "$($global:translations["SUMSCUErrorListingChanges"]): $_" -ForegroundColor Red
            }
        }

        function Show-Menu-Verificar-Atualizacoes {

            cls

            $fixedWidthMenuSearchUpdate = 120  # Largura total da linha

            # Frase a ser centralizada

            $menuSearchUpdateTexto = $($global:translations["SUMSearchUpdateMenu"])
            $menuSearchUpdateTextoLength = $menuSearchUpdateTexto.Length

            # Calcula o número de espaços necessários para centralizar
            $spacesNeededMenuSearchUpdate = [Math]::Max(([Math]::Floor(($fixedWidthMenuSearchUpdate - $menuSearchUpdateTextoLength) / 2)), 0)
            $spacesMenuSearchUpdate = " " * $spacesNeededMenuSearchUpdate

            Write-Host ""
            Write-Host "     ================================================================================================================" -ForegroundColor Green
            Write-Host "$spacesMenuSearchUpdate$menuSearchUpdateTexto" -ForegroundColor Cyan
            Write-Host "     ================================================================================================================" -ForegroundColor Green
            Write-Host ""
            Write-Host "     ================================================================================================================" -ForegroundColor Green
            Write-Host ""
            Write-Host "      $($global:translations["SUMCUPApplicationDetails"]): " -ForegroundColor Cyan
            Write-Host ""
            Write-Host -NoNewline "      $($global:translations["SUMCUPApplicationName"]): " -ForegroundColor White
            Write-Host -NoNewline "$nome_app" -ForegroundColor Yellow
            Write-Host ""
            Write-Host -NoNewline "      $($global:translations["SUMCUPCurrentVersion"]): " -ForegroundColor White
            Write-Host -NoNewline "$fileExeVersion" -ForegroundColor Green
            Write-Host ""
            Write-Host -NoNewline "      $($global:translations["SUMCUPAvailableVersion"]): " -ForegroundColor White
            if (($versao_disp_app -ne "Nenhum" -and $fileExeVersion -eq $versao_disp_app)) {
                Write-Host -NoNewline "$versao_disp_app" -ForegroundColor Green
            } elseif(($versao_disp_app -eq "Nenhum" -and $fileExeVersion -eq $versao_atual_app)) {
                Write-Host -NoNewline "$fileExeVersion" -ForegroundColor Green
            } else {
                Write-Host -NoNewline "$versao_disp_app" -ForegroundColor Magenta  
            }
            Write-Host ""
            Write-Host -NoNewline "      $($global:translations["SUMCUPUpdateChangelog"]): " -ForegroundColor White
            Write-Host ""

            $contador = 1

            # Verifica a versão uma vez, antes dos laços
            if (($versao_disp_app -ne "Nenhum" -and $fileExeVersion -eq $versao_disp_app)) {
                foreach ($regAltVF in $detalhesTitleVersaoFuturaApp) {
                    Write-Host -NoNewline "       $($contador): " -ForegroundColor Yellow
                    Write-Host "$regAltVF" -ForegroundColor White
                    $contador++
                }
            } elseif ($versao_disp_app -ne "Nenhum" -and $fileExeVersion -ne $versao_disp_app) {
                foreach ($regAltVA in $detalhesTitleVersaoAtualApp) {
                    Write-Host -NoNewline "       $($contador): " -ForegroundColor Yellow
                    Write-Host "$regAltVA" -ForegroundColor White
                    $contador++
                }
            } elseif (($versao_disp_app -eq "Nenhum" -and $fileExeVersion -eq $versao_atual_app)) {
                foreach ($regAltVA in $detalhesTitleVersaoAtualApp) {
                    Write-Host -NoNewline "       $($contador): " -ForegroundColor Yellow
                    Write-Host "$regAltVA" -ForegroundColor White
                    $contador++
                }
            } else {
                foreach ($regAltVF in $detalhesTitleVersaoFuturaApp) {
                    Write-Host -NoNewline "       $($contador): " -ForegroundColor Yellow
                    Write-Host "$regAltVF" -ForegroundColor White
                    $contador++
                }
            }

            Write-Host -NoNewline "      $($global:translations["SUMCUPReleaseDateUpdate"]): " -ForegroundColor White
            Write-Host -NoNewline "$($detalhes_app_info["data_att_app"])" -ForegroundColor Yellow
            Write-Host ""
            Write-Host -NoNewline "      $($global:translations["SUMCUPDateLastUpdate"]): " -ForegroundColor White
            if (($versao_disp_app -ne "Nenhum" -and $fileExeVersion -eq $versao_disp_app) -or ($versao_disp_app -eq "Nenhum" -and $fileExeVersion -eq $versao_atual_app)) {
               
                # Recarrega o conteúdo atualizado do arquivo JSON
                $jsonFileDataAtualizado = Get-Content -Path $global:configFilePath | ConvertFrom-Json
                # Armazena o valor de "data_att_app" em uma variável
                $getFileDataLog = $jsonFileDataAtualizado.data_att_app

                Write-Host -NoNewline "$getFileDataLog - " -ForegroundColor Yellow
                Write-Host -NoNewline "$($global:translations["SUMCUPUpdated"])" -ForegroundColor Green 
            } else {
                Write-Host -NoNewline "$($global:translations["SUMCUPNone"])" -ForegroundColor Yellow
                Write-Host -NoNewline " - $($global:translations["SUMCUPOutdated"])" -ForegroundColor Red
            }
            Write-Host ""
            Write-Host -NoNewline "      $($global:translations["SUMCUPUpdatedApplicationSize"]): " -ForegroundColor White
            if (($versao_disp_app -ne "Nenhum" -and $fileExeVersion -eq $versao_disp_app) -or ($versao_disp_app -eq "Nenhum" -and $fileExeVersion -eq $versao_atual_app)) {
                Write-Host -NoNewline "$($tamanhoMBFileExeVersion) MB" -ForegroundColor Yellow
            } else {
                Write-Host -NoNewline "$tamanho_arquivo_app" -ForegroundColor Yellow
            }
            Write-Host ""
            Write-Host -NoNewline "      $($global:translations["SUMCUPStatusUpdate"]): " -ForegroundColor White
            if (($versao_disp_app -ne "Nenhum" -and $fileExeVersion -eq $versao_disp_app) -or ($versao_disp_app -eq "Nenhum" -and $fileExeVersion -eq $versao_atual_app)) {
                Write-Host -NoNewline "$status_att_app" -ForegroundColor Green  
            } else {
                Write-Host -NoNewline "$($global:translations["SUMCUPOutdated"])" -ForegroundColor Red
            }
            Write-Host ""
            Write-Host -NoNewline "      $($global:translations["SUMCUPStatusDownloadUpdate"]): " -ForegroundColor White
            if (($versao_disp_app -ne "Nenhum" -and $fileExeVersion -eq $versao_disp_app) -or ($versao_disp_app -eq "Nenhum" -and $fileExeVersion -eq $versao_atual_app)) {
                Write-Host -NoNewline "$($global:translations["SUMCUPNotAvailable"])" -ForegroundColor Gray
            } else {
                if ($versao_alteracao.Contains($versao_disp_app)) {
                    Write-Host -NoNewline "$status_disp_att_app" -ForegroundColor Green 
                } else {
                    Write-Host -NoNewline "$($global:translations["SUMCUPNotAvailable"])" -ForegroundColor Gray 
                } 
            }

            Write-Host ""
            Write-Host ""

            if (($versao_disp_app -ne "Nenhum" -and $fileExeVersion -eq $versao_disp_app) -or ($versao_disp_app -eq "Nenhum" -and $fileExeVersion -eq $versao_atual_app)) {
                Write-Host -NoNewline "     >> " -ForegroundColor Green 
                Write-Host -NoNewline "$($global:translations["SUMRUApplicationUpdated"])" -ForegroundColor Green
                Write-Host ""
                Write-Host -NoNewline "     $($global:translations["SUMRUNoneVersionOf"])" -ForegroundColor Yellow
                Write-Host -NoNewline " '$scriptName' " -ForegroundColor Cyan
                Write-Host -NoNewline "$($global:translations["SUMRUAvailableThisTime"])" -ForegroundColor Yellow
            } else {
                
                if($versao_alteracao.Contains($versao_disp_app)) {
                    Write-Host -NoNewline "     >> " -ForegroundColor Green 
                    Write-Host -NoNewline "$($global:translations["SUMRUUpdateAvailable"])" -ForegroundColor Green
                    Write-Host ""
                    Write-Host -NoNewline "     $($global:translations["SUMRUNewVersionOf"])" -ForegroundColor Yellow
                    Write-Host -NoNewline " '$scriptName' " -ForegroundColor Cyan
                    Write-Host -NoNewline "$($global:translations["SUMRUCurrentlyAvailableDownload"])" -ForegroundColor Yellow
                } else {
                    Write-Host -NoNewline "     >> " -ForegroundColor Red
                    Write-Host -NoNewline "$($global:translations["SUMRUUpdateNotAvailable"])" -ForegroundColor Yellow
                    Write-Host ""
                    Write-Host -NoNewline "     $($global:translations["SUMRUNewVersionOf"])" -ForegroundColor Yellow
                    Write-Host -NoNewline " '$scriptName' " -ForegroundColor Cyan
                    Write-Host -NoNewline "$($global:translations["SUMRUIsNotCurrentlyAvailableDownload"])" -ForegroundColor Red
                }
            }

            Write-Host ""
            Write-Host ""
            Write-Host "     ================================================================================================================" -ForegroundColor Green

            if ($opcao_verificar_atualizacoes -eq 2 -or ($opcao_verificar_atualizacoes -eq 3 -and ($versao_disp_app -eq "Nenhum" -and $fileExeVersion -ne $versao_disp_app) -or $opcao_verificar_atualizacoes -eq 3 -and ($versao_disp_app -ne "Nenhum" -and $versao_atual_app -ne $versao_disp_app -and $fileExeVersion -eq $versao_atual_app))) {
                ListarMudancasAtualizacao
            } else {
                Write-Host ""
            }

            if ($versao_disp_app -ne "Nenhum" -and $fileExeVersion -eq $versao_disp_app) {
                Write-Host -NoNewline "     [1] - " -ForegroundColor Gray
                Write-Host -NoNewline "$($global:translations["SUMOMCUMakeUpdate"]) " -ForegroundColor Gray
                Write-Host -NoNewline "(" -ForegroundColor Gray
                Write-Host -NoNewline "$($global:translations["SUMCUPAvailableVersion"]):" -ForegroundColor Gray
                Write-Host -NoNewline "$versao_disp_app" -ForegroundColor Gray
                Write-Host -NoNewline ")" -ForegroundColor Gray
                Write-Host "" 
                            
            } elseif($versao_disp_app -eq "Nenhum" -and $fileExeVersion -eq $versao_atual_app) {
                Write-Host -NoNewline "     [1] - " -ForegroundColor Gray
                Write-Host -NoNewline "$($global:translations["SUMOMCUMakeUpdate"]) " -ForegroundColor Gray
                Write-Host -NoNewline "(" -ForegroundColor Gray
                Write-Host -NoNewline "$($global:translations["SUMCUPAvailableVersion"]):" -ForegroundColor Gray
                Write-Host -NoNewline "$fileExeVersion" -ForegroundColor Gray
                Write-Host -NoNewline ")" -ForegroundColor Gray
                Write-Host "" 
            } else {
                if($versao_alteracao.Contains($versao_disp_app)) {
                    Write-Host -NoNewline "     [1] - " -ForegroundColor Yellow
                    Write-Host -NoNewline "$($global:translations["SUMOMCUMakeUpdate"]) " -ForegroundColor Yellow
                    Write-Host -NoNewline "(" -ForegroundColor Cyan
                    Write-Host -NoNewline "$($global:translations["SUMCUPAvailableVersion"]):" -ForegroundColor Yellow
                    Write-Host -NoNewline "$versao_disp_app" -ForegroundColor Magenta
                    Write-Host -NoNewline ")" -ForegroundColor Cyan
                    Write-Host "" 
                } else {
                    Write-Host -NoNewline "     [1] - " -ForegroundColor Gray
                    Write-Host -NoNewline "$($global:translations["SUMOMCUMakeUpdate"]) " -ForegroundColor Gray
                    Write-Host -NoNewline "(" -ForegroundColor Gray
                    Write-Host -NoNewline "$($global:translations["SUMCUPAvailableVersion"]):" -ForegroundColor Gray
                    Write-Host -NoNewline "$versao_disp_app" -ForegroundColor Gray
                    Write-Host -NoNewline ")" -ForegroundColor Gray
                    Write-Host "" 
                }
            }
            if (($versao_disp_app -ne "Nenhum" -and $fileExeVersion -eq $versao_disp_app) -or ($versao_disp_app -eq "Nenhum" -and $fileExeVersion -eq $versao_atual_app)) {
                Write-Host -NoNewline "     [2] - " -ForegroundColor Yellow
                Write-Host -NoNewline "$($global:translations["SUMOMCUViewChanges"]) " -ForegroundColor Yellow
                Write-Host -NoNewline "(" -ForegroundColor Cyan
                Write-Host -NoNewline "$($global:translations["SUMCUPCurrentVersion"]):" -ForegroundColor Yellow
                Write-Host -NoNewline "$fileExeVersion" -ForegroundColor Green
                Write-Host -NoNewline ")" -ForegroundColor Cyan
                Write-Host ""   
            } else {
                Write-Host -NoNewline "     [2] - " -ForegroundColor Yellow
                Write-Host -NoNewline "$($global:translations["SUMOMCUViewChanges"]) " -ForegroundColor Yellow
                Write-Host -NoNewline "(" -ForegroundColor Cyan
                Write-Host -NoNewline "$($global:translations["SUMCUPCurrentVersion"]):" -ForegroundColor Yellow
                Write-Host -NoNewline "$fileExeVersion" -ForegroundColor Green
                Write-Host -NoNewline ")" -ForegroundColor Cyan
                Write-Host ""  
                Write-Host -NoNewline "     [3] - " -ForegroundColor Yellow
                Write-Host -NoNewline "$($global:translations["SUMOMCUViewChanges"]) " -ForegroundColor Yellow
                Write-Host -NoNewline "(" -ForegroundColor Cyan
                Write-Host -NoNewline "$($global:translations["SUMCUPAvailableVersion"]):" -ForegroundColor Yellow
                Write-Host -NoNewline "$versao_disp_app" -ForegroundColor Magenta
                Write-Host -NoNewline ")" -ForegroundColor Cyan
                Write-Host ""  
            }
            Write-Host ""  
            Write-Host -NoNewline "     [M] - "  -ForegroundColor Cyan
            Write-Host "$($global:translations["DOMainMenuOption"])" -ForegroundColor Gray
            Write-Host ""
            Write-Host "     ================================================================================================================" -ForegroundColor Green
            Write-Host ""
        }

        # Exibe o menu de verificar atualizações
        Show-Menu-Verificar-Atualizacoes

        $opcao_verificar_atualizacoes = Read-Host $($global:translations["SLMChoiceOptionUpdateMenu"])

        # Verificar se a opção é válida
        $selecionadoValido = $false

        if ($opcao_verificar_atualizacoes -eq 1) {

            if (($versao_disp_app -ne "Nenhum" -and $fileExeVersion -eq $versao_disp_app) -or ($versao_disp_app -eq "Nenhum" -and $fileExeVersion -eq $versao_atual_app)) {
                Write-Host ""
                Write-Host -NoNewline "$($global:translations["SUMRRUApplicationAlreadyUpdate"]): " -ForegroundColor Yellow
                Write-Host -NoNewline "$fileExeVersion." -ForegroundColor Green
                Write-Host ""
            } else {

                if($versao_alteracao.Contains($versao_disp_app)) {

                    Write-Host ""
                    Write-Host -NoNewline "$($global:translations["SUMRRUApplicationOutdated"]) " -ForegroundColor Red
                    Write-Host -NoNewline "$($global:translations["SUMRRUStartingUpdateVersion"]):" -ForegroundColor Yellow
                    Write-Host -NoNewline " $versao_disp_app." -ForegroundColor Magenta
                    Write-Host ""

                    # Executa a função
                    ExecutarAtualizacao  

                } else {

                    Write-Host ""
                    Write-Host -NoNewline "$($global:translations["SUMRRUApplicationOutdated"]) " -ForegroundColor Red
                    Write-Host -NoNewline "$($global:translations["SUMRRUNewApplicationUpdate"]) " -ForegroundColor Yellow
                    Write-Host ""
                    Write-Host "$($global:translations["SUMRRUIsNotAvailableDownload"])" -ForegroundColor Yellow
                    Write-Host ""
                }
            }

            Start-Sleep -Seconds 5
            Verificar-Atualizacoes
                           
        } elseif ($opcao_verificar_atualizacoes -eq 2) { 
            
            Write-Host ""
            Write-Host -NoNewline "$($global:translations["SUMRRUListingAboveStatusChangesN1"]) " -ForegroundColor Yellow
            Write-Host -NoNewline "$($global:translations["SUMRRUListingAboveStatusChangesCurrentVersionN2"]):" -ForegroundColor Yellow
            Write-Host -NoNewline " $fileExeVersion" -ForegroundColor Green
            Write-Host ""
            
            Start-Sleep -Seconds 5
            Verificar-Atualizacoes

        } elseif($opcao_verificar_atualizacoes -eq 3 -and ($versao_disp_app -eq "Nenhum" -and $fileExeVersion -ne $versao_disp_app) -or $opcao_verificar_atualizacoes -eq 3 -and ($versao_disp_app -ne "Nenhum" -and $versao_atual_app -ne $versao_disp_app -and $fileExeVersion -eq $versao_atual_app)) {

            Write-Host ""
            Write-Host -NoNewline "$($global:translations["SUMRRUListingAboveStatusChangesN1"]) " -ForegroundColor Yellow
            Write-Host -NoNewline "$($global:translations["SUMRRUListingAboveStatusChangesAvailableVersionN2"]):" -ForegroundColor Yellow
            Write-Host -NoNewline " $versao_disp_app" -ForegroundColor Magenta
            Write-Host ""
            
            Start-Sleep -Seconds 5
            Verificar-Atualizacoes

        } elseif ($opcao_verificar_atualizacoes -eq "M") {

            Show-Menu -LoginStatus $LoginStatus -UsuarioAtual $usuario_atual -SenhaAtual $senha_atual -TipoPlanoConta $plano_conta_atual
        
        } else {
            
            Write-Host ""
            Write-Host "$($global:translations["DOInvalidOptionN1"])" -ForegroundColor Red
            Write-Host ""

            $selecionadoValido = $false

            Start-Sleep -Seconds 3
            Verificar-Atualizacoes

        }

    } while (-not $selecionadoValido)
}

# Menu Modificar Idioma
function Selecionar-Idioma {

    param (
        [bool]$LoginStatus = $false,
        [string]$UsuarioAtual = $null,
        [string]$SenhaAtual = $null,
        [string]$TipoPlanoConta = $null
    )
    
    Update-Title-WindowMenu -menuKey "MMSelectLanguage"  # Atualiza o título para o menu principal
    $idiomaSelecionado = $global:language = Get-LanguageConfig

    if ($idiomaSelecionado -eq 'en') {
        $idiomaSelecionado = $($global:translations["SLMLanguageEn"])
    } elseif ($idiomaSelecionado -eq 'es') {
        $idiomaSelecionado = $($global:translations["SLMLanguageEs"]) 
    } elseif ($idiomaSelecionado -eq 'pt') {
        $idiomaSelecionado = $($global:translations["SLMLanguagePTBR"]) 
    } else {
        $idiomaSelecionado = $($global:translations["SLMLanguageUnknown"])  # Caso seja necessário lidar com outros idiomas
    }

    do {
        
        function Show-Menu-Selecionar-Idioma {
            cls

            $fixedWidthMenuSelectLanguage = 120  # Largura total da linha

            # Frase a ser centralizada

            $menuSelectLanguageTexto = $($global:translations["SLMSelectLanguageMenu"])
            $menuSelectLanguageTextoLength = $menuSelectLanguageTexto.Length

            # Calcula o número de espaços necessários para centralizar
            $spacesNeededMenuSelectLanguage = [Math]::Max(([Math]::Floor(($fixedWidthMenuSelectLanguage - $menuSelectLanguageTextoLength) / 2)), 0)
            $spacesMenuSelectLanguage = " " * $spacesNeededMenuSelectLanguage

            Write-Host ""
            Write-Host "     ================================================================================================================" -ForegroundColor Green
            Write-Host "$spacesMenuSelectLanguage$menuSelectLanguageTexto" -ForegroundColor Cyan
            Write-Host "     ================================================================================================================" -ForegroundColor Green
            Write-Host ""
            Write-Host "     ================================================================================================================" -ForegroundColor Green
            Write-Host ""
            Write-Host "      $($global:translations["SLMLanguageTitle"]): " -ForegroundColor Cyan
            Write-Host ""
            Write-Host -NoNewline "      $($global:translations["SLMLanguageSelected"]): " -ForegroundColor White
            Write-Host -NoNewline "$idiomaSelecionado" -ForegroundColor Yellow
            Write-Host ""
            Write-Host ""
            Write-Host "     ================================================================================================================" -ForegroundColor Green
            Write-Host ""
            if ($idiomaSelecionado -eq $($global:translations["SLMLanguageEn"])) {
                Write-Host -NoNewline "     [1] - " -ForegroundColor Yellow
                Write-Host "$($global:translations["SLMLanguageEn"])" -ForegroundColor Yellow # Cor amarela para a opção selecionada
            } else {
                Write-Host -NoNewline "     [1] - " -ForegroundColor Gray
                Write-Host "$($global:translations["SLMLanguageEn"])" -ForegroundColor Gray # Cor cinza para a opção não selecionada
            }
            if ($idiomaSelecionado -eq $($global:translations["SLMLanguageEs"])) {
                Write-Host -NoNewline "     [2] - " -ForegroundColor Yellow
                Write-Host "$($global:translations["SLMLanguageEs"])" -ForegroundColor Yellow # Cor amarela para a opção selecionada
            } else {
                Write-Host -NoNewline "     [2] - " -ForegroundColor Gray
                Write-Host "$($global:translations["SLMLanguageEs"])" -ForegroundColor Gray # Cor cinza para a opção não selecionada
            }
            if ($idiomaSelecionado -eq $($global:translations["SLMLanguagePTBR"])) {
                Write-Host -NoNewline "     [3] - " -ForegroundColor Yellow
                Write-Host "$($global:translations["SLMLanguagePTBROption"])" -ForegroundColor Yellow # Cor amarela para a opção selecionada
            } else {
                Write-Host -NoNewline "     [3] - " -ForegroundColor Gray
                Write-Host "$($global:translations["SLMLanguagePTBROption"])" -ForegroundColor Gray # Cor cinza para a opção não selecionada
            }
            Write-Host ""
            Write-Host -NoNewline "     [M] - "  -ForegroundColor Cyan
            Write-Host "$($global:translations["DOMainMenuOption"])" -ForegroundColor Gray
            Write-Host ""
            Write-Host "     ================================================================================================================" -ForegroundColor Green
            Write-Host ""

        }

        # Exibe o menu de modificar o idioma
        Show-Menu-Selecionar-Idioma

        $opcao_idioma = Read-Host $($global:translations["SLMChoiceOptionLanguageMenu"])

        # Verificar se a opção é válida
        $selecionadoValido = $false

        if ($opcao_idioma -eq 1) {
           
            $global:language = "en"
            Write-Host ""
            # Salva o novo idioma no arquivo de configuração
            Set-LanguageConfig -language $global:language

            # Recarrega as traduções com o novo idioma
            $global:translations = Get-Translation -language $global:language

            #Write-Host ""
            #Write-Host -NoNewline "$($global:translations["SLMLanguageChanged"]) " -ForegroundColor Yellow
            #Write-Host -NoNewline "$global:language." -ForegroundColor Green
            #Write-Host ""

            # Atualiza o título da janela para refletir o novo idioma e o menu atual
            if ($global:currentMenu) {
                Update-Title-WindowMenu -menuKey $global:currentMenu
            } else {
                Update-Title-WindowMenu -menuKey "MMMainMenu"  # Se não houver menu atual, define o título para o menu principal
            }

            Start-Sleep -Seconds 3

            # Caminho do script atual
            # $scriptPath = $MyInvocation.MyCommand.Definition

            # Inicia o script novamente
            # Start-Process powershell -ArgumentList "-File `"$scriptPath`""
            # Start-Process powershell "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`"" -Verb RunAs

            Selecionar-Idioma

            # Sai do script atual
            # Exit
                           
        } elseif ($opcao_idioma -eq 2) { 
        
            $global:language = "es"
            Write-Host ""
            # Salva o novo idioma no arquivo de configuração
            Set-LanguageConfig -language $global:language

            # Recarrega as traduções com o novo idioma
            $global:translations = Get-Translation -language $global:language

            #Write-Host ""
            #Write-Host -NoNewline "$($global:translations["SLMLanguageChanged"]) " -ForegroundColor Yellow
            #Write-Host -NoNewline "$global:language." -ForegroundColor Green
            #Write-Host ""

            # Atualiza o título da janela para refletir o novo idioma e o menu atual
            if ($global:currentMenu) {
                Update-Title-WindowMenu -menuKey $global:currentMenu
            } else {
                Update-Title-WindowMenu -menuKey "MMMainMenu"  # Se não houver menu atual, define o título para o menu principal
            }

            Start-Sleep -Seconds 3

            # Caminho do script atual
            # $scriptPath = $MyInvocation.MyCommand.Definition

            # Inicia o script novamente
            # Start-Process powershell -ArgumentList "-File `"$scriptPath`""
            # Start-Process powershell "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`"" -Verb RunAs

            Selecionar-Idioma

            # Sai do script atual
            # Exit

        } elseif ($opcao_idioma -eq 3) {
            
            $global:language = "pt"
            Write-Host ""
            # Salva o novo idioma no arquivo de configuração
            Set-LanguageConfig -language $global:language

            # Recarrega as traduções com o novo idioma
            $global:translations = Get-Translation -language $global:language

            #Write-Host ""
            #Write-Host -NoNewline "$($global:translations["SLMLanguageChanged"]) " -ForegroundColor Yellow
            #Write-Host -NoNewline "$global:language." -ForegroundColor Green
            #Write-Host ""

            # Atualiza o título da janela para refletir o novo idioma e o menu atual
            if ($global:currentMenu) {
                Update-Title-WindowMenu -menuKey $global:currentMenu
            } else {
                Update-Title-WindowMenu -menuKey "MMMainMenu"  # Se não houver menu atual, define o título para o menu principal
            }

            Start-Sleep -Seconds 3

            # Caminho do script atual
            # $scriptPath = $MyInvocation.MyCommand.Definition

            # Inicia o script novamente
            # Start-Process powershell -ArgumentList "-File `"$scriptPath`""
            # Start-Process powershell "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`"" -Verb RunAs

            Selecionar-Idioma

            # Sai do script atual
            # Exit

        } elseif ($opcao_idioma -eq "M") {

            Show-Menu -LoginStatus $LoginStatus -UsuarioAtual $usuario_atual -SenhaAtual $senha_atual -TipoPlanoConta $plano_conta_atual
        
        } else {

            $global:language = "pt"
            Write-Host ""
            # Salva o novo idioma no arquivo de configuração
            Set-LanguageConfig -language $global:language

            # Recarrega as traduções com o novo idioma
            $global:translations = Get-Translation -language $global:language

            Write-Host ""
            Write-Host "Opção inválida selecionada..." -ForegroundColor Yellow
            Write-Host "Idioma padrão mantido para $global:language." -ForegroundColor Green
            Write-Host ""

            # Atualiza o título da janela para refletir o novo idioma e o menu atual
            if ($global:currentMenu) {
                Update-Title-WindowMenu -menuKey $global:currentMenu
            } else {
                Update-Title-WindowMenu -menuKey "MMMainMenu"  # Se não houver menu atual, define o título para o menu principal
            }

            Start-Sleep -Seconds 3

            # Caminho do script atual
            # $scriptPath = $MyInvocation.MyCommand.Definition

            # Inicia o script novamente
            # Start-Process powershell -ArgumentList "-File `"$scriptPath`""
            # Start-Process powershell "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`"" -Verb RunAs

            Selecionar-Idioma

            # Sai do script atual
            # Exit
        }

    } while (-not $selecionadoValido)

}

# Menu Grupo Wpp ou Telegram
function Grupo-VIP {
  
    param (
        [bool]$LoginStatus = $false,
        [string]$UsuarioAtual = $null,
        [string]$SenhaAtual = $null,
        [string]$TipoPlanoConta = $null
    )
    
    Update-Title-WindowMenu -menuKey "MMVIPGroup"  # Atualiza o título para o menu principal
    $idiomaSelecionado = $global:language = Get-LanguageConfig

    # Variáveis para armazenar as informações de detalhes da aplicação
    $detalhes_app_info = $null

    # URLs para obter todos os detalhes do aplicativo
    $urls = Get-Detalhes-Aplicativo

    foreach ($url in $urls) {

        try {
            # Obter o conteúdo do arquivo do Pastebin
            $conteudo = Invoke-RestMethod -Uri $url -ErrorAction Stop
        } catch {
            Write-Host "     $($global:translations["DMAAlertMessageAccessContentURLNotFound"]): $url" -ForegroundColor Red
            continue
        }

        # Verificar se o conteúdo está vazio
        if ([string]::IsNullOrWhiteSpace($conteudo)) {
            Write-Host "     $($global:translations["DMAAlertMessageGetContentURLNotFound"]): $url" -ForegroundColor Red
            continue
        }

        # Verificar detalhes da aplicação no conteúdo obtido
        $linhas = $conteudo -split "`n"

        foreach ($linha in $linhas) {
            
            $campos = $linha -split "\|"
            
            # Verificar se há pelo menos três campos

            if ($campos.Count -ge 3) {
                
                $detalhes_app_info = @{
                    "url_painel_cliente" = $campos[7].Trim()
                    "url_pagina_produtos" = $campos[8].Trim()
                    "url_grupo_wpp_normal" = $campos[9].Trim()
                    "url_grupo_telegram_normal" = $campos[10].Trim()
                    "url_grupo_wpp_vip" = $campos[11].Trim()
                    "url_grupo_wpp_telegram_vip" = $campos[12].Trim()
                }

                break
            }
        }

        # Se os detalhes da aplicação não foi encontrado, não precisa verificar outros links
        if ($detalhes_app_info) {
            break
        }

    }

    $painel_cliente = $detalhes_app_info["url_painel_cliente"]
    $pagina_produtos = $detalhes_app_info["url_pagina_produtos"]
    $grupo_wpp_normal = $detalhes_app_info["url_grupo_wpp_normal"]
    $grupo_telegram_normal = $detalhes_app_info["url_grupo_telegram_normal"]
    $grupo_wpp_vip = $detalhes_app_info["url_grupo_wpp_vip"]
    $grupo_wpp_telegram_vip = $detalhes_app_info["url_grupo_wpp_telegram_vip"]

    do {
        
        function Show-Menu-Grupo-VIP {
            cls

            $fixedWidthMenuVIPGroup = 120  # Largura total da linha

            # Frase a ser centralizada

            $menuVIPGroupTexto = $($global:translations["VGMVIPGroupMenu"])
            $menuVIPGroupTextoLength = $menuVIPGroupTexto.Length

            # Calcula o número de espaços necessários para centralizar
            $spacesNeededMenuVIPGroup = [Math]::Max(([Math]::Floor(($fixedWidthMenuVIPGroup - $menuVIPGroupTextoLength) / 2)), 0)
            $spacesMenuVIPGroup = " " * $spacesNeededMenuVIPGroup

            Write-Host ""
            Write-Host "     ================================================================================================================" -ForegroundColor Green
            Write-Host "$spacesMenuVIPGroup$menuVIPGroupTexto" -ForegroundColor Cyan
            Write-Host "     ================================================================================================================" -ForegroundColor Green
            Write-Host ""

            if($LoginStatus -eq $true) {
                
                if($TipoPlanoConta -eq "VIP"){

                    Write-Host "     ================================================================================================================" -ForegroundColor Gray
                    Write-Host ""
                    Write-Host "      $($global:translations["VGMINAMTitleNotification"]): " -ForegroundColor Cyan
                    Write-Host ""
                    Write-Host "      $($global:translations["VGMINAMDescritpionNotificationVIPN1"])" -ForegroundColor White
                    Write-Host "      $($global:translations["VGMINAMDescritpionNotificationVIPN2"])" -ForegroundColor White
                    Write-Host ""
                    Write-Host "     ================================================================================================================" -ForegroundColor Gray
                    Write-Host ""
                    Write-Host -NoNewline "     [1] - " -ForegroundColor Yellow
                    Write-Host -NoNewline "$($global:translations["VGMGAPMJoinGroupN1"])" -ForegroundColor Yellow 
                    Write-Host -NoNewline " - " -ForegroundColor Yellow
                    Write-Host -NoNewline "$($global:translations["VGMGAPMJoinGroupN2"])" -ForegroundColor Magenta
                    Write-Host -NoNewline " (WhatsApp)" -ForegroundColor Green
                    Write-Host ""
                    Write-Host -NoNewline "     [2] - " -ForegroundColor Yellow
                    Write-Host -NoNewline "$($global:translations["VGMGAPMJoinGroupN1"])" -ForegroundColor Yellow
                    Write-Host -NoNewline " - " -ForegroundColor Yellow
                    Write-Host -NoNewline "$($global:translations["VGMGAPMJoinGroupN2"])" -ForegroundColor Magenta
                    Write-Host -NoNewline " (Telegram)" -ForegroundColor Cyan
                    Write-Host ""
                    Write-Host ""
                } else {
                    Write-Host "     ================================================================================================================" -ForegroundColor Gray
                    Write-Host ""
                    Write-Host "      $($global:translations["VGMINAMTitleNotification"]): " -ForegroundColor Cyan
                    Write-Host ""
                    Write-Host "      $($global:translations["VGMINAMDescritpionNotificationMEMBRON1"])" -ForegroundColor White
                    Write-Host "      $($global:translations["VGMINAMDescritpionNotificationMEMBRON2"])" -ForegroundColor White
                    Write-Host ""
                    Write-Host "     ================================================================================================================" -ForegroundColor Gray
                    Write-Host ""
                    Write-Host -NoNewline "     [1] - " -ForegroundColor Yellow
                    Write-Host -NoNewline "$($global:translations["VGMGAPMJoinGroupN1"]) - " -ForegroundColor Yellow 
                    Write-Host -NoNewline "(WhatsApp)" -ForegroundColor Green
                    Write-Host ""
                    Write-Host -NoNewline "     [2] - " -ForegroundColor Yellow
                    Write-Host -NoNewline "$($global:translations["VGMGAPMJoinGroupN1"]) - " -ForegroundColor Yellow
                    Write-Host -NoNewline "(Telegram)" -ForegroundColor Cyan
                    Write-Host ""
                    Write-Host ""
                }

            } else {
                Write-Host "     ================================================================================================================" -ForegroundColor Red
                Write-Host ""
                Write-Host "     $($global:translations["VGMGAPMLoggedIntoAccount"])" -ForegroundColor Gray
                Write-Host ""
                Write-Host "     ================================================================================================================" -ForegroundColor Red
                Write-Host ""
            }

            Write-Host "     ================================================================================================================" -ForegroundColor Green
            Write-Host ""
            Write-Host -NoNewline "     [3] - " -ForegroundColor Yellow
            Write-Host -NoNewline "$($global:translations["VGMGAPMAccessWebsite"]) AsyncTech - " -ForegroundColor Yellow
            Write-Host -NoNewline "$($global:translations["VGMGAPMProductsPage"])" -ForegroundColor Blue
            Write-Host ""
            Write-Host -NoNewline "     [4] - " -ForegroundColor Yellow
            Write-Host -NoNewline "$($global:translations["VGMGAPMAccessWebsite"]) AsyncTech - " -ForegroundColor Yellow
            Write-Host -NoNewline "$($global:translations["VGMGAPMLoginCustomerPanelClient"])" -ForegroundColor Magenta
            Write-Host ""
            Write-Host ""
            Write-Host -NoNewline "     [M] - "  -ForegroundColor Cyan
            Write-Host "$($global:translations["DOMainMenuOption"])" -ForegroundColor Gray
            Write-Host ""
            Write-Host "     ================================================================================================================" -ForegroundColor Green
            Write-Host ""

        }

        # Exibe o menu de verificar atualizações
        Show-Menu-Grupo-VIP

        $opcao_grupo_vip = Read-Host $($global:translations["VGMChoiceOptionVIPGroupMenu"])

        # Verificar se a opção é válida
        $selecionadoValido = $false
        # urlPattern
        $urlPattern = '^(https?|ftp)://[^\s/$.?#].[^\s]*$'

        if ($opcao_grupo_vip -eq 1 -and $LoginStatus -eq $true) {

            if ($LoginStatus -eq $true -and $TipoPlanoConta -eq "VIP") {

                Write-Host ""
                Write-Host -NoNewline "$($global:translations["VGMGWALAccessGroupParticipation"])" -ForegroundColor Yellow
                Write-Host -NoNewline " $($global:translations["VGMGWALWaitLink"])" -ForegroundColor Green
                Write-Host ""

                if ($grupo_wpp_vip -match $urlPattern) {
                    Start-Process $grupo_wpp_vip
                } else {
                    Write-Host ""
                    Write-Host "$($global:translations["VGMGWALNothingLinkGroupParticipation"])" -ForegroundColor Red
                    Write-Host ""
                }

            } else {

                Write-Host ""
                Write-Host -NoNewline "$($global:translations["VGMGWALAccessGroupParticipation"])" -ForegroundColor Yellow
                Write-Host -NoNewline " $($global:translations["VGMGWALWaitLink"])" -ForegroundColor Green
                Write-Host ""

                if ($grupo_wpp_normal -match $urlPattern) {
                    Start-Process $grupo_wpp_normal
                } else {
                    Write-Host ""
                    Write-Host "$($global:translations["VGMGWALNothingLinkGroupParticipation"])" -ForegroundColor Red
                    Write-Host ""
                }
            }

            Start-Sleep -Seconds 5
            Show-Menu-Grupo-VIP
                           
        } elseif ($opcao_grupo_vip -eq 2 -and $LoginStatus -eq $true) { 
            
            if ($LoginStatus -eq $true -and $TipoPlanoConta -eq "VIP") {
                
                Write-Host ""
                Write-Host -NoNewline "$($global:translations["VGMGWALAccessGroupParticipation"])" -ForegroundColor Yellow
                Write-Host -NoNewline " $($global:translations["VGMGWALWaitLink"])" -ForegroundColor Green
                Write-Host ""

                if ($grupo_telegram_vip -match $urlPattern) {
                    Start-Process $grupo_telegram_vip
                } else {
                    Write-Host ""
                    Write-Host "$($global:translations["VGMGWALNothingLinkGroupParticipation"])" -ForegroundColor Red
                    Write-Host ""
                }

            } else {
                
                Write-Host ""
                Write-Host -NoNewline "$($global:translations["VGMGWALAccessGroupParticipation"])" -ForegroundColor Yellow
                Write-Host -NoNewline " $($global:translations["VGMGWALWaitLink"])" -ForegroundColor Green
                Write-Host ""

                if ($grupo_telegram_normal -match $urlPattern) {
                    Start-Process $grupo_telegram_normal
                } else {
                    Write-Host ""
                    Write-Host "$($global:translations["VGMGWALNothingLinkGroupParticipation"])" -ForegroundColor Red
                    Write-Host ""
                }
            }

            Start-Sleep -Seconds 5
            Show-Menu-Grupo-VIP

        } elseif ($opcao_grupo_vip -eq 3) { 
        
            Write-Host ""
            Write-Host -NoNewline "$($global:translations["VGMGWALAccessPageLink"]) " -ForegroundColor Yellow
            Write-Host -NoNewline "$($global:translations["VGMGWALProductCategoriesLink"])" -ForegroundColor Cyan
            Write-Host -NoNewline "." -ForegroundColor Yellow
            Write-Host -NoNewline " $($global:translations["VGMGWALWaitLink"])" -ForegroundColor Green
            Write-Host ""

            if ($pagina_produtos -match $urlPattern) {
                Start-Process $pagina_produtos
            } else {
                Write-Host ""
                Write-Host "$($global:translations["VGMGWALNothingLinkAccessWebsite"])" -ForegroundColor Red
                Write-Host ""
            }

            Start-Sleep -Seconds 3
            Show-Menu-Grupo-VIP

        } elseif ($opcao_grupo_vip -eq 4) {

            Write-Host ""
            Write-Host -NoNewline "$($global:translations["VGMGWALAccessPageLink"]) " -ForegroundColor Yellow
            Write-Host -NoNewline "$($global:translations["VGMGWALLoginCustomerPanelClientLink"])" -ForegroundColor Cyan
            Write-Host -NoNewline "." -ForegroundColor Yellow
            Write-Host -NoNewline " $($global:translations["VGMGWALWaitLink"])" -ForegroundColor Green
            Write-Host ""

            if ($painel_cliente -match $urlPattern) {
                Start-Process $painel_cliente
            } else {
                Write-Host ""
                Write-Host "$($global:translations["VGMGWALNothingLinkAccessWebsite"])" -ForegroundColor Red
                Write-Host ""
            }

            Start-Sleep -Seconds 3
            Show-Menu-Grupo-VIP

        } elseif ($opcao_grupo_vip -eq "M") {

            Show-Menu -LoginStatus $LoginStatus -UsuarioAtual $usuario_atual -SenhaAtual $senha_atual -TipoPlanoConta $plano_conta_atual
        
        } else {
            
            Write-Host ""
            Write-Host "$($global:translations["DOInvalidOptionN1"])" -ForegroundColor Red
            Write-Host ""

            $selecionadoValido = $false

            Start-Sleep -Seconds 3
            Show-Menu-Grupo-VIP

        }

    } while (-not $selecionadoValido)
}

# Função para carregar valores de qtdv
function Load-QTDVValues {
    
    # Correção de Ajuste # 2 (Erro)
    # troquei $parts[1].Trim() [int] para [string] erro

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
        Write-Host "$($global:translations["SPMDLATotalQTDTitle"]):" -ForegroundColor Yellow
        Write-Host ""

        if ($qtdvTotal -eq "Ilimitado") {
            Write-QTDVMessage -label $($global:translations["SPMDLATotalQTDV"]) -value $qtdvTotal -color Cyan
        } else {
            if ($qtdvTotal -eq 0) {
                Write-QTDVMessage -label $($global:translations["SPMDLATotalQTDV"]) -value $($global:translations["SPMDLANothing"]) -color Red
            } else {
                Write-QTDVMessage -label $($global:translations["SPMDLATotalQTDV"]) -value $qtdvTotal -color Yellow
            }

            if ($qtdvUtilizado -eq 0) {
                Write-QTDVMessage -label $($global:translations["SPMDLATotalQTDVUsed"]) -value $($global:translations["SPMDLANothing"]) -color Red
            } else {
                Write-QTDVMessage -label $($global:translations["SPMDLATotalQTDVUsed"]) -value $qtdvUtilizado -color Yellow
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
        $fixedWidthDefault = if ($idiomaSelecionado -eq "es") { 55 } else { 46 }
        $fixedWidthUsuario = 44
        $fixedWidthSenha = 46
        $fixedWidthTipoPlano = 35 
        $fixedWidthQTDTOTALDV = 17
        $fixedWidthQTDINDVDV = 14
                    
    } else {

        $fixedWidthStatusLogin = 58
        $fixedWidthDefault = if ($idiomaSelecionado -eq "es") { 62 } else { 53 }
        $fixedWidthUsuario = 51
        $fixedWidthSenha = 53
        $fixedWidthTipoPlano = 42
        $fixedWidthQTDTOTALDV = 24
        $fixedWidthQTDINDVDV = 14
                    
    } 

    $titulostatuslogin = $($global:translations["SPMDLALoginStatusMenu"])
    $titulousuarioatual = $($global:translations["SPMDLAUserLoginStatus"])
    $titulosenhaatual = $($global:translations["SPMDLAPassLoginStatus"])
    $titulotipoplanousuarioatual = $($global:translations["SPMDLAPlanTypeAccount"])
    $titulototalqtdv = $($global:translations["SPMDLATotalQTDV"])
    $titulototalqtdvutilizado = $($global:translations["SPMDLATotalQTDVUsed"])

    $nomeusuarioatual = $UsuarioAtual
    $senhausuarioatual = $detalheslogin_senhadisplay
    $tipoplanousuarioatual = $TipoPlanoConta
    $qtdvtotalatual = if ($qtdvTotal -eq 0) { $($global:translations["SPMDLANothing"]) } else { $qtdvTotal }
    $qtdvutilizadoatual = if ($qtdvUtilizado -eq 0) { $($global:translations["SPMDLANothing"]) } else { $qtdvUtilizado }
    
    if ( $TipoPlanoConta -eq "VIP" ) {

        if ($idiomaSelecionado -eq "es") {
            Write-Host "     ==========================================================" -ForegroundColor Yellow
        } else {
            Write-Host "     =================================================" -ForegroundColor Yellow
        }

    } else { #=========

        if ($idiomaSelecionado -eq "es") {
            Write-Host "     =================================================================" -ForegroundColor Yellow
        } else {
            Write-Host "     ========================================================" -ForegroundColor Yellow
        }
    }  

    # Usuário

    Write-Host -NoNewline "     | " -ForegroundColor Yellow
    Write-Host -NoNewline "$($titulostatuslogin): " -ForegroundColor Cyan
    $spacesNeededStatusLogin = if ($idiomaSelecionado -eq "es") {$fixedWidthStatusLogin - ("$titulostatuslogin".Length - 2)} else {$fixedWidthStatusLogin - ("$titulostatuslogin".Length + 7)}
    $spacesStatusLogin = " " * [Math]::Max($spacesNeededStatusLogin, 0)
    Write-Host -NoNewline $spacesStatusLogin -ForegroundColor Yellow
    Write-Host "|" -ForegroundColor Yellow
    Write-Host -NoNewline "     | " -ForegroundColor Yellow
    $spacesNeededDefault = $fixedWidthDefault
    $spacesDefault = " " * [Math]::Max($spacesNeededDefault, 0)
    Write-Host -NoNewline $spacesDefault -ForegroundColor Yellow
    Write-Host "|" -ForegroundColor Yellow
    Write-Host -NoNewline "     | " -ForegroundColor Yellow
    Write-Host -NoNewline "$($titulousuarioatual): " -ForegroundColor White
    Write-Host -NoNewline "$nomeusuarioatual" -ForegroundColor $revelarAcessoColor
    $spacesNeededUsuario = if ($idiomaSelecionado -eq "es") {$fixedWidthUsuario - ($titulousuarioatual.Length + $nomeusuarioatual.Length - 9)} else {$fixedWidthUsuario - ($titulousuarioatual.Length + $nomeusuarioatual.Length)} 
    $spacesUsuario = " " * [Math]::Max($spacesNeededUsuario, 0)
    Write-Host -NoNewline $spacesUsuario -ForegroundColor Yellow
    Write-Host "|" -ForegroundColor Yellow

    # Senha

    Write-Host -NoNewline "     | " -ForegroundColor Yellow
    Write-Host -NoNewline "$($titulosenhaatual): " -ForegroundColor White
    Write-Host -NoNewline "$detalheslogin_senhadisplay" -ForegroundColor $revelarAcessoColor
    $spacesNeededSenha = if ($idiomaSelecionado -eq "es") {$fixedWidthSenha - ($titulosenhaatual.Length + $senhausuarioatual.Length - 7)} else {$fixedWidthSenha - ($titulosenhaatual.Length + $senhausuarioatual.Length + 2)}
    $spacesSenha = " " * [Math]::Max($spacesNeededSenha, 0)
    Write-Host -NoNewline $spacesSenha -ForegroundColor Yellow
    Write-Host "|" -ForegroundColor Yellow

    # Tipo de Plano de Conta
   
    Write-Host -NoNewline "     | " -ForegroundColor Yellow
    Write-Host -NoNewline "$($titulotipoplanousuarioatual): " -ForegroundColor White
    if ($tipoplanousuarioatual -eq "VIP") {

        $tipoplanousuarioatual = Translate-Text -Text $tipoplanousuarioatual -TargetLanguage $idiomaSelecionado
        Write-Host -NoNewline "$tipoplanousuarioatual".ToUpper() -ForegroundColor Magenta
    } else {
        $tipoplanousuarioatual = Translate-Text -Text $tipoplanousuarioatual -TargetLanguage $idiomaSelecionado
        Write-Host -NoNewline "$tipoplanousuarioatual".ToUpper() -ForegroundColor Blue
    }

    $spacesNeeded = if ($idiomaSelecionado -eq "es") {$fixedWidthTipoPlano - ($titulotipoplanousuarioatual.Length + $tipoplanousuarioatual.Length - 18)} else {$fixedWidthTipoPlano - ($titulotipoplanousuarioatual.Length + $tipoplanousuarioatual.Length - 9)} 
    $spaces = " " * [Math]::Max($spacesNeeded, 0)
    Write-Host -NoNewline $spaces -ForegroundColor Yellow
    Write-Host "|" -ForegroundColor Yellow
    
    if (-not $silent) {

        if ($QtdvTotal -eq "Ilimitado") {
            Write-Host -NoNewline "     | " -ForegroundColor Yellow
            Write-QTDVMessageMenuLogin -label $($titulototalqtdv) -value $qtdvtotalatual -color Cyan
            $spacesNeededQTDTOTALDV = if ($idiomaSelecionado -eq "es") {$fixedWidthQTDTOTALDV - ($titulototalqtdv.Length + $qtdvtotalatual.Length - 36)} else {$fixedWidthQTDTOTALDV - ($titulototalqtdv.Length + $qtdvtotalatual.Length - 27)} 
            $spacesQTDTOTALDV = " " * [Math]::Max($spacesNeededQTDTOTALDV, 0)
            Write-Host -NoNewline $spacesQTDTOTALDV -ForegroundColor Yellow
            Write-Host "|" -ForegroundColor Yellow
        } else {
            if ($QtdvTotal -eq 0) {
                Write-Host -NoNewline "     | " -ForegroundColor Yellow
                Write-QTDVMessageMenuLogin -label $($titulototalqtdv) -value $qtdvtotalatual -color Red
                $spacesNeededQTDTOTALDV = if ($idiomaSelecionado -eq "es") {$fixedWidthQTDTOTALDV - ($titulototalqtdv.Length + $qtdvtotalatual.Length - 36)} else {$fixedWidthQTDTOTALDV - ($titulototalqtdv.Length + $qtdvtotalatual.Length - 27)}
                $spacesQTDTOTALDV = " " * [Math]::Max($spacesNeededQTDTOTALDV, 0)
                Write-Host -NoNewline $spacesQTDTOTALDV -ForegroundColor Yellow
                Write-Host "|" -ForegroundColor Yellow
            } else {
                Write-Host -NoNewline "     | " -ForegroundColor Yellow
                Write-QTDVMessageMenuLogin -label $($titulototalqtdv) -value $qtdvtotalatual -color Yellow
                $spacesNeededQTDTOTALDV = if ($idiomaSelecionado -eq "es") {$fixedWidthQTDTOTALDV - ($titulototalqtdv.Length + $qtdvtotalatual.Length - 36)} else {$fixedWidthQTDTOTALDV - ($titulototalqtdv.Length + $qtdvtotalatual.Length - 27)}
                $spacesQTDTOTALDV = " " * [Math]::Max($spacesNeededQTDTOTALDV, 0) 
                Write-Host -NoNewline $spacesQTDTOTALDV -ForegroundColor Yellow
                Write-Host "|" -ForegroundColor Yellow
            }

            if ($QtdvUtilizado -eq 0) {
                Write-Host -NoNewline "     | " -ForegroundColor Yellow
                Write-QTDVMessageMenuLogin -label $($titulototalqtdvutilizado) -value $qtdvutilizadoatual -color Red
                $spacesNeededQTDINDVDV = if($idiomaSelecionado -eq "es") {$fixedWidthQTDINDVDV - ($titulototalqtdvutilizado.Length + $qtdvutilizadoatual.Length - 46)} else {$fixedWidthQTDINDVDV - ($titulototalqtdvutilizado.Length + $qtdvutilizadoatual.Length - 37)}
                $spacesQTDINDVDV = " " * [Math]::Max($spacesNeededQTDINDVDV, 0) 
                Write-Host -NoNewline $spacesQTDINDVDV -ForegroundColor Yellow
                Write-Host "|" -ForegroundColor Yellow
            } else {
                Write-Host -NoNewline "     | " -ForegroundColor Yellow
                Write-QTDVMessageMenuLogin -label $($titulototalqtdvutilizado) -value $qtdvutilizadoatual -color Yellow
                $spacesNeededQTDINDVDV = if($idiomaSelecionado -eq "es") {$fixedWidthQTDINDVDV - ($titulototalqtdvutilizado.Length + $qtdvutilizadoatual.Length - 46)} else {$fixedWidthQTDINDVDV - ($titulototalqtdvutilizado.Length + $qtdvutilizadoatual.Length - 37)}
                $spacesQTDINDVDV = " " * [Math]::Max($spacesNeededQTDINDVDV, 0) 
                Write-Host -NoNewline $spacesQTDINDVDV -ForegroundColor Yellow
                Write-Host "|" -ForegroundColor Yellow
            }

        }

    }

    if ( $TipoPlanoConta -eq "VIP" ) {

        if ($idiomaSelecionado -eq "es") {
            Write-Host "     ==========================================================" -ForegroundColor Yellow
        } else {
            Write-Host "     =================================================" -ForegroundColor Yellow
        }

    } else { #======================

        if ($idiomaSelecionado -eq "es") {
            Write-Host "     =================================================================" -ForegroundColor Yellow
        } else {
            Write-Host "     ========================================================" -ForegroundColor Yellow
        }
    } 

}

function MostrarCabecalhoRenovacao{
    
    param (
        [string]$mensagemproduto = $($global:translations["RPAMPrazoPlanAccount"]),
        [string]$mensagemplano = $($global:translations["RPAMEndPrazoPlanAccount"]),
        [string]$fimensagem = $($global:translations["RPAMSelectOptionOfferSubscriptionPlan"]),
        [string]$opcao_mensagem = "",
        [string]$url=""
    )

    if ($url -and $opcao_mensagem -eq "GRUPO MEMBRO") {
        
        Start-Process $url
        cls

        # Tradução Dinâmica:
        $opcao_mensagem = Translate-Text -Text $opcao_mensagem -TargetLanguage $idiomaSelecionado

        $fixedWidthMenuRenewPlan = 120  # Largura total da linha

        # Frase a ser centralizada
        $menuRenewPlanTexto = $($global:translations["RPAMRenewPlanMenu"])
        $menuRenewPlanTextoLength = $menuRenewPlanTexto.Length

        # Calcula o número de espaços necessários para centralizar
        $spacesNeededMenuRenewPlan = [Math]::Max(([Math]::Floor(($fixedWidthMenuRenewPlan - $menuRenewPlanTextoLength) / 2)), 0)
        $spacesMenuRenewPlan = " " * $spacesNeededMenuRenewPlan

        Write-Host ""
        Write-Host "     ================================================================================================================" -ForegroundColor Green
        Write-Host "$spacesMenuRenewPlan$menuRenewPlanTexto" -ForegroundColor Cyan
        Write-Host "     ================================================================================================================" -ForegroundColor Green
	    Write-Host ""
        Write-Host -NoNewline "     $($global:translations["RPAMBenefits"])" -ForegroundColor Cyan
        Write-Host -NoNewline " | " -ForegroundColor Cyan 
        Write-Host -NoNewline "$($global:translations["RPAMSubscriptionPlan"]): $opcao_mensagem" -ForegroundColor Yellow
        Write-Host -NoNewline " | " -ForegroundColor Cyan 
        Write-Host ""
        Write-Host ""
        Write-Host "     ===============================================================================================================" -ForegroundColor DarkYellow
        Write-Host -NoNewline "     > " -ForegroundColor Cyan                                                                   
        Write-Host -NoNewline $($global:translations["RPAMSANDL"]) -ForegroundColor Yellow
        Write-Host -NoNewline " $($global:translations["RPAMActivationMethodPA"])" -ForegroundColor Green
        Write-Host ""
        Write-Host -NoNewline "     - " -ForegroundColor Cyan
        Write-Host -NoNewline $($global:translations["RPAMAttPeriodPP"]) -ForegroundColor Yellow
        Write-Host -NoNewline " $($global:translations["RPAMWhenAvailable"])" -ForegroundColor Green
        Write-Host ""
        Write-Host "     ===============================================================================================================" -ForegroundColor DarkYellow
        Write-Host -NoNewline "     > " -ForegroundColor Cyan
        Write-Host -NoNewline $($global:translations["RPAMInstUnistActv"]) -ForegroundColor Yellow
        Write-Host -NoNewline " $($global:translations["RPAMAutoRapidSecure"])" -ForegroundColor Green
        Write-Host ""
        Write-Host -NoNewline "     - " -ForegroundColor Cyan
        Write-Host -NoNewline "$($global:translations["RPAMNumberDownloadsViews"]):" -ForegroundColor Yellow
        Write-Host -NoNewline " $($global:translations["RPAMLimited"])" -ForegroundColor Green
        Write-Host ""
        Write-Host -NoNewline "     - " -ForegroundColor Cyan
        Write-Host -NoNewline "$($global:translations["RPAMTutoVidImgExp"])" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "     ===============================================================================================================" -ForegroundColor DarkYellow
        Write-Host -NoNewline "     > " -ForegroundColor Cyan                                                                   
        Write-Host -NoNewline $($global:translations["RPAMPrioritySupport"]) -ForegroundColor Yellow
        Write-Host ""
        Write-Host -NoNewline "     - " -ForegroundColor Cyan
        Write-Host -NoNewline "1x " -ForegroundColor Magenta
        Write-Host -NoNewline $($global:translations["RPAMRemoteAssist"]) -ForegroundColor Yellow
        Write-Host -NoNewline " $($global:translations["RPAMGT"])" -ForegroundColor Green
        Write-Host ""
        Write-Host "     ===============================================================================================================" -ForegroundColor DarkYellow
        Write-Host -NoNewline "     > " -ForegroundColor Cyan                                                                   
        Write-Host -NoNewline "$($global:translations["RPAMGuaranteeProducts"])" -ForegroundColor Yellow
        Write-Host ""
        Write-Host -NoNewline "     - " -ForegroundColor Cyan
        Write-Host -NoNewline $($global:translations["RPAMReplacementRenewal"]) -ForegroundColor Yellow
        Write-Host -NoNewline " $($global:translations["RPAMRequirementsAttended"])" -ForegroundColor Green
        Write-Host ""
        Write-Host "     ===============================================================================================================" -ForegroundColor DarkYellow
        Write-Host -NoNewline "     > " -ForegroundColor Cyan                                                                   
        Write-Host -NoNewline "$($global:translations["RPAMRaffleDiscounts"])" -ForegroundColor Yellow
        Write-Host ""
        Write-Host -NoNewline "     - " -ForegroundColor Cyan
        Write-Host -NoNewline $($global:translations["RPAMSpecialOffers"]) -ForegroundColor Yellow
        Write-Host ""
        Write-Host "     ===============================================================================================================" -ForegroundColor DarkYellow
        Write-Host ""
        Write-Host -NoNewline "     $($global:translations["RPAMValues"])" -ForegroundColor Cyan 
        Write-Host -NoNewline " | " -ForegroundColor Cyan 
        Write-Host -NoNewline "$($global:translations["RPAMSubscriptionPlan"]): $opcao_mensagem" -ForegroundColor Yellow
        Write-Host -NoNewline " | " -ForegroundColor Cyan 
        Write-Host ""
        Write-Host ""
        Write-Host "     ===============================================================================================================" -ForegroundColor DarkYellow
        Write-Host -NoNewline "     * " -ForegroundColor Cyan
        Write-Host -NoNewline $($global:translations["RPAMDaily"]) -ForegroundColor Yellow
        Write-Host -NoNewline " $($global:translations["RPAMTimeDays"]):" -ForegroundColor Magenta
        Write-Host -NoNewline " 10,00" -ForegroundColor Green
        Write-Host -NoNewline " (QTDV:3)" -ForegroundColor Cyan
        Write-Host ""
        Write-Host -NoNewline "     * " -ForegroundColor Cyan
        Write-Host -NoNewline "$($global:translations["RPAMMonthly"]):" -ForegroundColor Yellow
        Write-Host -NoNewline " 15,00" -ForegroundColor Green
        Write-Host -NoNewline " (QTDV:6)" -ForegroundColor Cyan
        Write-Host ""
        Write-Host -NoNewline "     * " -ForegroundColor Cyan
        Write-Host -NoNewline "$($global:translations["RPAMQuarterly"]):" -ForegroundColor Yellow
        Write-Host -NoNewline " 28,00" -ForegroundColor Green
        Write-Host -NoNewline " (QTDV:8)" -ForegroundColor Cyan
        Write-Host ""
        Write-Host -NoNewline "     * " -ForegroundColor Cyan
        Write-Host -NoNewline "$($global:translations["RPAMBiannual"]):" -ForegroundColor Yellow
        Write-Host -NoNewline " 37,00" -ForegroundColor Green
        Write-Host -NoNewline " (QTDV:10)" -ForegroundColor Cyan
        Write-Host ""
        Write-Host -NoNewline "     * " -ForegroundColor Cyan
        Write-Host -NoNewline "$($global:translations["RPAMAnnual"]):" -ForegroundColor Yellow
        Write-Host -NoNewline " 48,00" -ForegroundColor Green
        Write-Host -NoNewline " (QTDV:15)" -ForegroundColor Cyan
        Write-Host ""
        Write-Host -NoNewline "     * " -ForegroundColor Cyan
        Write-Host -NoNewline "$($global:translations["RPAMLifeTime"]):" -ForegroundColor Yellow
        Write-Host -NoNewline " 65,00" -ForegroundColor Green
        Write-Host -NoNewline " (QTDV:25)" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "     ===============================================================================================================" -ForegroundColor DarkYellow
    } elseif ($url -and $opcao_mensagem -eq "GRUPO VIP") {

        Start-Process $url

        cls

        # Tradução Dinâmica:
        $opcao_mensagem = Translate-Text -Text $opcao_mensagem -TargetLanguage $idiomaSelecionado

        $fixedWidthMenuRenewPlan = 120  # Largura total da linha

        # Frase a ser centralizada
        $menuRenewPlanTexto = $($global:translations["RPAMRenewPlanMenu"])
        $menuRenewPlanTextoLength = $menuRenewPlanTexto.Length

        # Calcula o número de espaços necessários para centralizar
        $spacesNeededMenuRenewPlan = [Math]::Max(([Math]::Floor(($fixedWidthMenuRenewPlan - $menuRenewPlanTextoLength) / 2)), 0)
        $spacesMenuRenewPlan = " " * $spacesNeededMenuRenewPlan

        Write-Host ""
        Write-Host "     ================================================================================================================" -ForegroundColor Green
        Write-Host "$spacesMenuRenewPlan$menuRenewPlanTexto" -ForegroundColor Cyan
        Write-Host "     ================================================================================================================" -ForegroundColor Green
	    Write-Host ""
        Write-Host -NoNewline "     $($global:translations["RPAMBenefits"])" -ForegroundColor Cyan 
        Write-Host -NoNewline " | " -ForegroundColor Cyan 
        Write-Host -NoNewline "$($global:translations["RPAMSubscriptionPlan"]): $opcao_mensagem" -ForegroundColor Yellow
        Write-Host -NoNewline " | " -ForegroundColor Cyan 
        Write-Host ""
        Write-Host ""
        Write-Host "     ===============================================================================================================" -ForegroundColor DarkYellow
        Write-Host -NoNewline "     > " -ForegroundColor Cyan   
        Write-Host -NoNewline $($global:translations["RPAMAllN1"]) -ForegroundColor Magenta                                                               
        Write-Host -NoNewline " $($global:translations["RPAMSANDL"])" -ForegroundColor Yellow
        Write-Host -NoNewline " $($global:translations["RPAMActivationMethodPA"])" -ForegroundColor Green
        Write-Host ""
        Write-Host -NoNewline "     > " -ForegroundColor Cyan
        Write-Host -NoNewline $($global:translations["RPAMALLN2"]) -ForegroundColor Magenta 
        Write-Host -NoNewline " $($global:translations["RPAMStreamingAccounts"])" -ForegroundColor Yellow
        Write-Host -NoNewline " $($global:translations["RPAMActivationMethodCookies"])" -ForegroundColor Green
        Write-Host ""
        Write-Host -NoNewline "     - " -ForegroundColor Cyan
        Write-Host -NoNewline $($global:translations["RPAMAttPeriodLT"]) -ForegroundColor Yellow
        Write-Host -NoNewline " $($global:translations["RPAMWhenAvailable"])" -ForegroundColor Green
        Write-Host ""
        Write-Host "     ===============================================================================================================" -ForegroundColor DarkYellow
        Write-Host -NoNewline "     > " -ForegroundColor Cyan
        Write-Host -NoNewline $($global:translations["RPAMInstUnistActv"]) -ForegroundColor Yellow
        Write-Host -NoNewline " $($global:translations["RPAMAutoRapidSecure"])" -ForegroundColor Green
        Write-Host ""
        Write-Host -NoNewline "     - " -ForegroundColor Cyan
        Write-Host -NoNewline "$($global:translations["RPAMNumberDownloadsViews"]):" -ForegroundColor Yellow
        Write-Host -NoNewline " $($global:translations["RPAMUnlimited"])" -ForegroundColor Green
        Write-Host ""
        Write-Host -NoNewline "     - " -ForegroundColor Cyan
        Write-Host -NoNewline $($global:translations["RPAMTutoVidImgExp"]) -ForegroundColor Yellow
        Write-Host ""
        Write-Host "     ===============================================================================================================" -ForegroundColor DarkYellow
        Write-Host -NoNewline "     > " -ForegroundColor Cyan                                                                   
        Write-Host -NoNewline $($global:translations["RPAMPrioritySupport"]) -ForegroundColor Yellow
        Write-Host ""
        Write-Host -NoNewline "     - " -ForegroundColor Cyan
        Write-Host -NoNewline "2x " -ForegroundColor Magenta
        Write-Host -NoNewline $($global:translations["RPAMRemoteAssist"]) -ForegroundColor Yellow
        Write-Host -NoNewline " $($global:translations["RPAMGT"])" -ForegroundColor Green
        Write-Host ""
        Write-Host "     ===============================================================================================================" -ForegroundColor DarkYellow
        Write-Host -NoNewline "     > " -ForegroundColor Cyan                                                                   
        Write-Host -NoNewline $($global:translations["RPAMGuaranteeProducts"]) -ForegroundColor Yellow
        Write-Host ""
        Write-Host -NoNewline "     - " -ForegroundColor Cyan
        Write-Host -NoNewline $($global:translations["RPAMReplacementRenewal"]) -ForegroundColor Yellow
        Write-Host -NoNewline " $($global:translations["RPAMRequirementsAttended"])" -ForegroundColor Green
        Write-Host ""
        Write-Host "     ===============================================================================================================" -ForegroundColor DarkYellow
        Write-Host -NoNewline "     > " -ForegroundColor Cyan                                                                   
        Write-Host -NoNewline $($global:translations["RPAMRaffleDiscounts"]) -ForegroundColor Yellow
        Write-Host ""
        Write-Host -NoNewline "     - " -ForegroundColor Cyan
        Write-Host -NoNewline $($global:translations["RPAMSpecialOffers"]) -ForegroundColor Yellow
        Write-Host ""
        Write-Host "     ===============================================================================================================" -ForegroundColor DarkYellow
        Write-Host ""
        Write-Host -NoNewline "     $($global:translations["RPAMValues"])" -ForegroundColor Cyan
        Write-Host -NoNewline " | " -ForegroundColor Cyan 
        Write-Host -NoNewline "$($global:translations["RPAMSubscriptionPlan"]): $opcao_mensagem" -ForegroundColor Yellow
        Write-Host -NoNewline " | " -ForegroundColor Cyan 
        Write-Host ""
        Write-Host ""
        Write-Host "     ===============================================================================================================" -ForegroundColor DarkYellow
        Write-Host -NoNewline "     * " -ForegroundColor Cyan
        Write-Host -NoNewline "$($global:translations["RPAMMonthly"]):" -ForegroundColor Yellow
        Write-Host -NoNewline " 25,00" -ForegroundColor Green
        Write-Host -NoNewline " $($global:translations["RPAMQTDVUnlimited"])" -ForegroundColor Cyan
        Write-Host ""
        Write-Host -NoNewline "     * " -ForegroundColor Cyan
        Write-Host -NoNewline "$($global:translations["RPAMQuarterly"]):" -ForegroundColor Yellow
        Write-Host -NoNewline " 48,00" -ForegroundColor Green
        Write-Host -NoNewline " $($global:translations["RPAMQTDVUnlimited"])" -ForegroundColor Cyan
        Write-Host ""
        Write-Host -NoNewline "     * " -ForegroundColor Cyan
        Write-Host -NoNewline "$($global:translations["RPAMBiannual"]):" -ForegroundColor Yellow
        Write-Host -NoNewline " 75,00" -ForegroundColor Green
        Write-Host -NoNewline " $($global:translations["RPAMQTDVUnlimited"])" -ForegroundColor Cyan
        Write-Host ""
        Write-Host -NoNewline "     * " -ForegroundColor Cyan
        Write-Host -NoNewline "$($global:translations["RPAMAnnual"]):" -ForegroundColor Yellow
        Write-Host -NoNewline " 100,00" -ForegroundColor Green
        Write-Host -NoNewline " $($global:translations["RPAMQTDVUnlimited"])" -ForegroundColor Cyan
        Write-Host ""
        Write-Host -NoNewline "     * " -ForegroundColor Cyan
        Write-Host -NoNewline "$($global:translations["RPAMLifeTime"]):" -ForegroundColor Yellow
        Write-Host -NoNewline " 150,00" -ForegroundColor Green
        Write-Host -NoNewline " $($global:translations["RPAMQTDVUnlimited"])" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "     ===============================================================================================================" -ForegroundColor DarkYellow
    } elseif ($url -and $opcao_mensagem -eq "DOWNLOAD E VISUALIZAÇÕES") {
        Start-Process $url
        cls

         # Tradução Dinâmica:
        $opcao_mensagem = Translate-Text -Text $opcao_mensagem -TargetLanguage $idiomaSelecionado

        $fixedWidthMenuRenewPlan = 120  # Largura total da linha

        # Frase a ser centralizada
        $menuRenewPlanTexto = $($global:translations["RPAMRenewPlanMenu"])
        $menuRenewPlanTextoLength = $menuRenewPlanTexto.Length

        # Calcula o número de espaços necessários para centralizar
        $spacesNeededMenuRenewPlan = [Math]::Max(([Math]::Floor(($fixedWidthMenuRenewPlan - $menuRenewPlanTextoLength) / 2)), 0)
        $spacesMenuRenewPlan = " " * $spacesNeededMenuRenewPlan

        Write-Host ""
        Write-Host "     ================================================================================================================" -ForegroundColor Green
        Write-Host "$spacesMenuRenewPlan$menuRenewPlanTexto" -ForegroundColor Cyan
        Write-Host "     ================================================================================================================" -ForegroundColor Green
	    Write-Host ""
        Write-Host -NoNewline "     $($global:translations["RPAMValues"])" -ForegroundColor Cyan
        Write-Host -NoNewline " | " -ForegroundColor Cyan 
        Write-Host -NoNewline "$($global:translations["RPAMAccessKeys"]): $opcao_mensagem" -ForegroundColor Yellow
        Write-Host -NoNewline " | " -ForegroundColor Cyan 
        Write-Host ""
        Write-Host ""
        Write-Host "     ===============================================================================================================" -ForegroundColor DarkYellow
        Write-Host -NoNewline "     * " -ForegroundColor Cyan
        Write-Host -NoNewline "QTDV:" -ForegroundColor Yellow
        Write-Host -NoNewline " 3" -ForegroundColor Cyan
        Write-Host -NoNewline " $($global:translations["RPAMPrice"]):" -ForegroundColor Yellow
        Write-Host -NoNewline " 5,00" -ForegroundColor Cyan
        Write-Host ""
        Write-Host -NoNewline "     * " -ForegroundColor Cyan
        Write-Host -NoNewline "QTDV:" -ForegroundColor Yellow
        Write-Host -NoNewline " 6" -ForegroundColor Cyan
        Write-Host -NoNewline " $($global:translations["RPAMPrice"]):" -ForegroundColor Yellow
        Write-Host -NoNewline " 8,00" -ForegroundColor Cyan
        Write-Host ""
        Write-Host -NoNewline "     * " -ForegroundColor Cyan
        Write-Host -NoNewline "QTDV:" -ForegroundColor Yellow
        Write-Host -NoNewline " 8" -ForegroundColor Cyan
        Write-Host -NoNewline " $($global:translations["RPAMPrice"]):" -ForegroundColor Yellow
        Write-Host -NoNewline " 10,00" -ForegroundColor Cyan
        Write-Host ""
        Write-Host -NoNewline "     * " -ForegroundColor Cyan
        Write-Host -NoNewline "QTDV:" -ForegroundColor Yellow
        Write-Host -NoNewline " 10" -ForegroundColor Cyan
        Write-Host -NoNewline " $($global:translations["RPAMPrice"]):" -ForegroundColor Yellow
        Write-Host -NoNewline " 15,00" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "     ===============================================================================================================" -ForegroundColor DarkYellow        
                        
    } else {
        if ($url -and $opcao_mensagem -eq "PRODUTO RENOVAÇÃO") { 
            Start-Process $url 
            cls

            $fixedWidthMenuRenewPlan = 120  # Largura total da linha

            # Frase a ser centralizada
            $menuRenewPlanTexto = $($global:translations["RPAMRenewPlanMenu"])
            $menuRenewPlanTextoLength = $menuRenewPlanTexto.Length

            # Calcula o número de espaços necessários para centralizar
            $spacesNeededMenuRenewPlan = [Math]::Max(([Math]::Floor(($fixedWidthMenuRenewPlan - $menuRenewPlanTextoLength) / 2)), 0)
            $spacesMenuRenewPlan = " " * $spacesNeededMenuRenewPlan

            Write-Host ""
            Write-Host "     ================================================================================================================" -ForegroundColor Green
            Write-Host "$spacesMenuRenewPlan$menuRenewPlanTexto" -ForegroundColor Cyan
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
            $fixedWidthMenuRenewPlan = 120  # Largura total da linha

            # Frase a ser centralizada
            $menuRenewPlanTexto = $($global:translations["RPAMRenewPlanMenu"])
            $menuRenewPlanTextoLength = $menuRenewPlanTexto.Length

            # Calcula o número de espaços necessários para centralizar
            $spacesNeededMenuRenewPlan = [Math]::Max(([Math]::Floor(($fixedWidthMenuRenewPlan - $menuRenewPlanTextoLength) / 2)), 0)
            $spacesMenuRenewPlan = " " * $spacesNeededMenuRenewPlan

            Write-Host ""
            Write-Host "     ================================================================================================================" -ForegroundColor Green
            Write-Host "$spacesMenuRenewPlan$menuRenewPlanTexto" -ForegroundColor Cyan
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

    Update-Title-WindowMenu -menuKey "RPAMRenewPlanMenu"  # Atualiza o título para o menu principal

    Write-Host " "

    if (-not $silent) {

        foreach ($produtoctdigitalDisponivel in $produtosctdigitalDisponiveis) {

            Write-Host "     ================================================================================================================" -ForegroundColor Green
            Write-Host ""
            Write-Host -NoNewline "     [1] - "  -ForegroundColor Yellow
            Write-Host "$($global:translations["DORenewPlanMenuOption"]) $($produtoctdigitalDisponivel['nome_produto']) $($produtoctdigitalDisponivel['duracao_plano'])" -ForegroundColor White
            Write-Host -NoNewline "     [2] - "  -ForegroundColor Yellow
            Write-Host $($global:translations["DORenewPlanVIPGroupMenuOption"]) -ForegroundColor White
            Write-Host -NoNewline "     [3] - "  -ForegroundColor Yellow
            Write-Host $($global:translations["DORenewPlanMemberGroupMenuOption"]) -ForegroundColor White
            Write-Host -NoNewline "     [4] - "  -ForegroundColor Yellow
            Write-Host $($global:translations["DORenewPlanKeyAccessMenuOption"]) -ForegroundColor White
            Write-Host ""
            if ($idiomaSelecionado -eq "pt") { Write-Host -NoNewline "     [D] - "  -ForegroundColor Red } elseif ($idiomaSelecionado -eq "en") { Write-Host -NoNewline "     [L] - "  -ForegroundColor Red } elseif ($idiomaSelecionado -eq "es") { Write-Host -NoNewline "     [C] - "  -ForegroundColor Red }
            Write-Host $($global:translations["DOLogoutMenuOption"]) -ForegroundColor Gray
            if ($idiomaSelecionado -eq "pt") { Write-Host -NoNewline "     [V] - "  -ForegroundColor Cyan } elseif ($idiomaSelecionado -eq "en") { Write-Host -NoNewline "     [B] - "  -ForegroundColor Cyan } elseif ($idiomaSelecionado -eq "es") { Write-Host -NoNewline "     [V] - "  -ForegroundColor Cyan }
            Write-Host $($global:translations["DOGoBackMenuOption"]) -ForegroundColor Gray
            Write-Host -NoNewline "     [M] - "  -ForegroundColor Yellow
            Write-Host $($global:translations["DOMainMenuOption"]) -ForegroundColor Gray
            Write-Host ""
            Write-Host "     ================================================================================================================" -ForegroundColor Green
            
            Write-Host ""

            $opcao_renovacao = Read-Host $($global:translations["RPAMChoiceOptionRenewalSelected"])
            
            if ($opcao_renovacao -eq '1') {
                MostrarCabecalhoRenovacao -opcao_mensagem "PRODUTO RENOVAÇÃO" -mensagemproduto "$($global:translations["RPAMMessageOptionLinkRenewalSelectedN1"]) $($produtoctdigitalDisponivel['nome_produto']) $($produtoctdigitalDisponivel['duracao_plano']) $($global:translations["RPAMMessageOptionLinkRenewalSelectedN2"])" -url "https://wa.me/5561974039456?text=Pretendo%20renovar%20e/ou%20assinar%20plano%20de%20assinatura%20$($produtoctdigitalDisponivel['nome_produto'])%20$($produtoctdigitalDisponivel['duracao_plano'])" 
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
            } elseif (($idiomaSelecionado -eq "pt" -and $opcao_renovacao -eq "D") -or ($idiomaSelecionado -eq "en" -and $opcao_renovacao -eq "L") -or ($idiomaSelecionado -eq "es" -and $opcao_renovacao -eq "C")) {
                Fazer-Login -LoginStatus $false
            } elseif (($idiomaSelecionado -eq "pt" -and $opcao_renovacao-eq "V") -or ($idiomaSelecionado -eq "en" -and $opcao_renovacao -eq "B") -or ($idiomaSelecionado -eq "es" -and $opcao_renovacao -eq "V")) {
                Show-Produtos-Metodos -UsuarioAtual $UsuarioAtual -SenhaAtual $SenhaAtual -CategoriaEscolhida $CategoriaEscolhida -ProdutoSelecionado $ProdutoSelecionado -TipoPlanoConta $TipoPlanoConta -DataAtual $DataAtual -DataTermino $DataTermino -ProdutosMetodoLiberado $ProdutosMetodoLiberado
            } elseif ($opcao_renovacao -eq "M") {
                Show-Menu -LoginStatus $true -UsuarioAtual $usuario_atual -SenhaAtual $senha_atual -TipoPlanoConta $plano_conta_atual
            } else {
                Write-Host ""
                Write-Host $($global:translations["DOInvalidOptionN1"]) -ForegroundColor Red
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
            Write-Host $($global:translations["DORenewPlanVIPGroupMenuOption"]) -ForegroundColor White
            Write-Host -NoNewline "     [2] - "  -ForegroundColor Yellow
            Write-Host $($global:translations["DORenewPlanMemberGroupMenuOption"]) -ForegroundColor White
            Write-Host -NoNewline "     [3] - "  -ForegroundColor Yellow
            Write-Host $($global:translations["DORenewPlanKeyAccessMenuOption"]) -ForegroundColor White
            Write-Host " "
            if ($idiomaSelecionado -eq "pt") { Write-Host -NoNewline "     [D] - "  -ForegroundColor Red } elseif ($idiomaSelecionado -eq "en") { Write-Host -NoNewline "     [L] - "  -ForegroundColor Red } elseif ($idiomaSelecionado -eq "es") { Write-Host -NoNewline "     [C] - "  -ForegroundColor Red }
            Write-Host $($global:translations["DOLogoutMenuOption"]) -ForegroundColor Gray
            if ($idiomaSelecionado -eq "pt") { Write-Host -NoNewline "     [V] - "  -ForegroundColor Cyan } elseif ($idiomaSelecionado -eq "en") { Write-Host -NoNewline "     [B] - "  -ForegroundColor Cyan } elseif ($idiomaSelecionado -eq "es") { Write-Host -NoNewline "     [V] - "  -ForegroundColor Cyan }
            Write-Host $($global:translations["DOGoBackMenuOption"]) -ForegroundColor Gray
            Write-Host -NoNewline "     [M] - "  -ForegroundColor Yellow
            Write-Host $($global:translations["DOMainMenuOption"]) -ForegroundColor Gray 
            Write-Host ""
            Write-Host "     ================================================================================================================" -ForegroundColor Green 
        } else {
            Write-Host "     ================================================================================================================" -ForegroundColor Green
            Write-Host ""
            Write-Host -NoNewline "     [1] - "  -ForegroundColor Yellow
            Write-Host $($global:translations["DORenewPlanVIPGroupMenuOption"]) -ForegroundColor White
            Write-Host -NoNewline "     [2] - "  -ForegroundColor Yellow
            Write-Host $($global:translations["DORenewPlanMemberGroupMenuOption"]) -ForegroundColor White
            Write-Host -NoNewline "     [3] - "  -ForegroundColor Yellow
            Write-Host $($global:translations["DORenewPlanKeyAccessMenuOption"]) -ForegroundColor White
            Write-Host " "
            if ($idiomaSelecionado -eq "pt") { Write-Host -NoNewline "     [D] - "  -ForegroundColor Red } elseif ($idiomaSelecionado -eq "en") { Write-Host -NoNewline "     [L] - "  -ForegroundColor Red } elseif ($idiomaSelecionado -eq "es") { Write-Host -NoNewline "     [C] - "  -ForegroundColor Red }
            Write-Host $($global:translations["DOLogoutMenuOption"]) -ForegroundColor Gray
            Write-Host -NoNewline "     [M] - "  -ForegroundColor Yellow
            Write-Host $($global:translations["DOMainMenuOption"]) -ForegroundColor Gray 
            Write-Host ""
            Write-Host "     ================================================================================================================" -ForegroundColor Green 
        }
        
        Write-Host ""

        $opcao_renovacao = Read-Host $($global:translations["RPAMChoiceOptionRenewalSelected"])
        
        if ($opcao_renovacao -eq '1') {
            MostrarCabecalhoRenovacao -opcao_mensagem "GRUPO VIP" -url "https://wa.me/5561974039456?text=Pretendo%20renovar%20e/ou%20assinar%20plano%20de%20assinatura%20GRUPO%20VIP"
            MostrarMenuRenovacao -silent -produtosComMetodoEspecifico $produtosComMetodoEspecifico
        } elseif ($opcao_renovacao -eq '2') {
            MostrarCabecalhoRenovacao -opcao_mensagem "GRUPO MEMBRO" -url "https://wa.me/5561974039456?text=Pretendo%20renovar%20e/ou%20assinar%20plano%20de%20assinatura%20GRUPO%20MEMBRO"
            MostrarMenuRenovacao -silent -produtosComMetodoEspecifico $produtosComMetodoEspecifico
        } elseif ($opcao_renovacao -eq '3') {
            MostrarCabecalhoRenovacao -opcao_mensagem "DOWNLOAD E VISUALIZAÇÕES" -url "https://wa.me/5561974039456?text=Pretendo%20renovar%20e/ou%20comprar%20chaves%20de%20acesso"
            MostrarMenuRenovacao -silent -produtosComMetodoEspecifico $produtosComMetodoEspecifico
        } elseif (($idiomaSelecionado -eq "pt" -and $opcao_renovacao-eq "D") -or ($idiomaSelecionado -eq "en" -and $opcao_renovacao -eq "L") -or ($idiomaSelecionado -eq "es" -and $opcao_renovacao -eq "C")) {
            Fazer-Login -LoginStatus $false
        } elseif (($idiomaSelecionado -eq "pt" -and $produtosComMetodoEspecifico -and $opcao_renovacao-eq "V") -or ($idiomaSelecionado -eq "en" -and $produtosComMetodoEspecifico -and $opcao_renovacao -eq "B") -or ($idiomaSelecionado -eq "es" -and $produtosComMetodoEspecifico -and $opcao_renovacao -eq "V")) {
            Show-Menu-Produto
        } elseif ($opcao_renovacao -eq "M") {
            Show-Menu -LoginStatus $true -UsuarioAtual $usuario_atual -SenhaAtual $senha_atual -TipoPlanoConta $plano_conta_atual
        } else {
        
            Write-Host ""
            Write-Host $($global:translations["DOInvalidOptionN1"]) -ForegroundColor Red
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
    
    Update-Title-WindowMenu -menuKey "SPMSelectProductMenu" # Atualiza o título para o menu principal

    # Variáveis para armazenar as informações do usuário
    $usuario_info = $null

    foreach ($url in $urls) {
        try {
            # Obter o conteúdo do arquivo
            $conteudo = Invoke-RestMethod -Uri $url -ErrorAction Stop
        } catch {
            Write-Host "     $($global:translations["DMAAlertMessageAccessContentURLNotFound"]): $url" -ForegroundColor Red
            continue
        }
        
        # Verificar se o conteúdo está vazio
        if ([string]::IsNullOrWhiteSpace($conteudo)) {
            Write-Host "     $($global:translations["DMAAlertMessageGetContentURLNotFound"]): $url" -ForegroundColor Red
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
                                        Write-Host "$($global:translations["DMAAlertMessageAccessContentURLNotFound"]): $url_ProdutoDisponivel" -ForegroundColor Red
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

                        # Carrega a linguagem de tradução / configuração atual
                        $idiomaSelecionado = $global:language = Get-LanguageConfig

                        # Chamar a função para obter todas as categorias e produtos
                        $todasCategoriasProdutos = Get-Todas-Categorias-Produtos 
                    
                        # Chamar a função para obter todas as categorias
                        $todasCategorias = Get-Todas-Categorias

                        $duracaoPlano = $products[0]["duracao_plano"]


                        function Show-Menu-Detalhes-Produto {

                            param (
                                [string]$detalheslogin_senhadisplay = "***-***-***"
                            )

                            # Traduções do Menu de Detalhes do Produto

                            $returnDuracaoPlanoUsuarioTranslate = Translate-Text -Text $($usuario_info["duracao_plano"]) -TargetLanguage $idiomaSelecionado
                            $returnStatusPagamentoTranslate = Translate-Text -Text $($usuario_info["status_pagamento"]) -TargetLanguage $idiomaSelecionado
                            $returnDiasRestantesTranslate = Translate-Text -Text $dias_restantes -TargetLanguage $idiomaSelecionado

                            cls

                            $fixedWidthMenuSelectProduct = 120  # Largura total da linha

                            # Frase a ser centralizada
                            $menuSelectProductTexto = $($global:translations["SPMSelectProductMenu"])
                            $menuSelectProductTextoLength = $menuSelectProductTexto.Length

                            # Calcula o número de espaços necessários para centralizar
                            $spacesNeededMenuSelectProduct = [Math]::Max(([Math]::Floor(($fixedWidthMenuSelectProduct - $menuSelectProductTextoLength) / 2)), 0)
                            $spacesMenuSelectProduct = " " * $spacesNeededMenuSelectProduct

                            Write-Host ""
                            Write-Host "     ================================================================================================================" -ForegroundColor Green
                            Write-Host "$spacesMenuSelectProduct$menuSelectProductTexto" -ForegroundColor Cyan
                            Write-Host "     ================================================================================================================" -ForegroundColor Green
	                        Write-Host ""

                            Show-Menu-Detalhes-Login -UsuarioAtual $usuario_info["usuario"] -SenhaAtual $usuario_info["senha"] -TipoPlanoConta $usuario_info["tipo_plano"] -detalheslogin_senhadisplay $detalheslogin_senhadisplay -qtdvTotal $qtdvValues["qtdv_valor_atual"] -qtdvUtilizado $qtdvValues["qtdv_valor_utilizado"] -silent
                            
                            Write-Host ""
                            Write-Host "     ===============================================================================================================" -ForegroundColor Green
                            Write-Host ""
                            Write-Host "      $($global:translations["SPMDetailstAccount"]): " -ForegroundColor Cyan
                            Write-Host ""
                            foreach ($categoria in $todasCategorias) {

                                $produtos_categoria_disponiveis = $categoriasDisponiveis[$categoria]
                                $total_categorias_disponiveis = $categoriasDisponiveis.Keys.Count
                                $quantidade_disponivel = $produtos_categoria_disponiveis.Count
    
                                # Adicionar a quantidade_disponivel ao total
                                $total_quantidade_disponivel += $quantidade_disponivel
                                
                            }
                            
                            Write-Host -NoNewline "      $($global:translations["SPMTotalQtdCategories"]): "
                            Write-Host "$total_categorias_disponiveis" -ForegroundColor Yellow
                            Write-Host -NoNewline "      $($global:translations["SPMTotalQtdProducts"]): "
                            Write-Host "$total_quantidade_disponivel" -ForegroundColor Yellow
                            Write-Host ""
                                if ($usuario_info["tipo_plano"] -eq "Membro") {
                                    Write-Host -NoNewline "      1 - " -ForegroundColor Green
                                    Write-Host "$($global:translations["SPMSubscriptionPlan"]):" -ForegroundColor Yellow
                                    Write-Host ""
                                    Write-Host -NoNewline "      $($global:translations["SPMPlanDuration"]): "
                                    Write-Host "$returnDuracaoPlanoUsuarioTranslate" -ForegroundColor Blue 
                                    Write-Host -NoNewline "      $($global:translations["SPMStartDate"]): "
                                    Write-Host "$($usuario_info["data_inicio"])" -ForegroundColor Yellow
                                    Write-Host -NoNewline "      $($global:translations["SPMEndDate"]): "
                                    Write-Host "$($usuario_info["data_termino"])" -ForegroundColor Yellow
                                    if ($data_atual -gt $data_termino -and -not $produtosComMetodoEspecifico) {
                                        Write-Host -NoNewline "      $($global:translations["SPMRemainingDays"]): "
                                        Write-Host $($global:translations["SPMDLANothing"]) -ForegroundColor Red
                                        Write-Host -NoNewline "      $($global:translations["SPMPaymentStatus"]): "
                                        Write-Host $($global:translations["SPMDLAPending"]) -ForegroundColor Red 
                                    } elseif ($data_atual -gt $data_termino -and $produtosComMetodoEspecifico) {
                                        Write-Host -NoNewline "      $($global:translations["SPMRemainingDays"]): "
                                        Write-Host $($global:translations["SPMDLANothing"]) -ForegroundColor Red
                                        Write-Host -NoNewline "      $($global:translations["SPMPaymentStatus"]): "
                                        Write-Host $($global:translations["SPMDLAPending"]) -ForegroundColor Red 
                                    } else {
                                        Write-Host -NoNewline "      $($global:translations["SPMRemainingDays"]): "
                                        if($dias_restantes -eq 0 ) { Write-Host "$($global:translations["SPMDLALastDay"])" -ForegroundColor Red } else { Write-Host "$returnDiasRestantesTranslate" -ForegroundColor Blue }
                                        Write-Host -NoNewline "      $($global:translations["SPMPaymentStatus"]): "
                                        Write-Host "$returnStatusPagamentoTranslate" -ForegroundColor Green
                                    }
                                } else {
                                    Write-Host -NoNewline "      1 - " -ForegroundColor Green
                                    Write-Host "$($global:translations["SPMSubscriptionPlan"]):" -ForegroundColor Yellow
                                    Write-Host ""
                                    Write-Host -NoNewline "      $($global:translations["SPMPlanDuration"]): "
                                    Write-Host "$returnDuracaoPlanoUsuarioTranslate" -ForegroundColor Blue
                                    Write-Host -NoNewline "      $($global:translations["SPMStartDate"]): "
                                    Write-Host "$($usuario_info["data_inicio"])" -ForegroundColor Yellow
                                    Write-Host -NoNewline "      $($global:translations["SPMEndDate"]): "
                                    Write-Host "$($usuario_info["data_termino"])" -ForegroundColor Yellow
                                    if ($data_atual -gt $data_termino -and -not $produtosComMetodoEspecifico) {
                                        Write-Host -NoNewline "      $($global:translations["SPMRemainingDays"]): "
                                        Write-Host $($global:translations["SPMDLANothing"]) -ForegroundColor Red 
                                        Write-Host -NoNewline "      $($global:translations["SPMPaymentStatus"]): "
                                        Write-Host $($global:translations["SPMDLAPending"]) -ForegroundColor Red 
                                    } elseif ($data_atual -gt $data_termino -and $produtosComMetodoEspecifico) {
                                        Write-Host -NoNewline "      $($global:translations["SPMRemainingDays"]): "
                                        Write-Host $($global:translations["SPMDLANothing"]) -ForegroundColor Red 
                                        Write-Host -NoNewline "      $($global:translations["SPMPaymentStatus"]): "
                                        Write-Host $($global:translations["SPMDLAPending"]) -ForegroundColor Red 
                                    } else {
                                        Write-Host -NoNewline "      $($global:translations["SPMRemainingDays"]): "
                                        if($dias_restantes -eq 0 ) { Write-Host "$($global:translations["SPMDLALastDay"])" -ForegroundColor Red } else { Write-Host "$returnDiasRestantesTranslate" -ForegroundColor Red }
                                        Write-Host -NoNewline "      $($global:translations["SPMPaymentStatus"]): "
                                        Write-Host "$returnStatusPagamentoTranslate" -ForegroundColor Green 
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

                                $returnCategoriaTranslate = Translate-Text -Text $categoria -TargetLanguage $idiomaSelecionado

                                # Definir cores com base na disponibilidade de produtos
                                if ($quantidade_disponivel -gt 0) {
                                    Write-Host "     [$contador] - $returnCategoriaTranslate ($quantidade_disponivel/$quantidade_total_produtos)" -ForegroundColor Yellow
                                } else {
                                    Write-Host "     [$contador] - $returnCategoriaTranslate ($quantidade_disponivel/$quantidade_total_produtos)" -ForegroundColor DarkGray
                                }
                        
                                $contador++
                            }
                                
                            if ($data_atual -gt $data_termino -and -not $produtosComMetodoEspecifico) {
                                Write-Host ""
                                Write-Host -NoNewline "     [R] - "  -ForegroundColor Green
                                Write-Host $($global:translations["DORenewPlanMenuOption"]) -ForegroundColor Gray
                            } elseif ($data_atual -gt $data_termino -and $produtosComMetodoEspecifico) {
                                Write-Host ""
                                Write-Host -NoNewline "     [R] - "  -ForegroundColor Green
                                Write-Host $($global:translations["DORenewPlanMenuOption"]) -ForegroundColor Gray
                            } else {
                                Write-Host ""
                            }
                            if ($idiomaSelecionado -eq "pt") { Write-Host -NoNewline "     [C] - "  -ForegroundColor Blue } elseif ($idiomaSelecionado -eq "en") { Write-Host -NoNewline "     [V] - "  -ForegroundColor Blue } elseif ($idiomaSelecionado -eq "es") { Write-Host -NoNewline "     [S] - "  -ForegroundColor Blue }
                            Write-Host $($global:translations["DOViewAccountMenuOption"]) -ForegroundColor Gray
                            if ($idiomaSelecionado -eq "pt") { Write-Host -NoNewline "     [D] - "  -ForegroundColor Red } elseif ($idiomaSelecionado -eq "en") { Write-Host -NoNewline "     [L] - "  -ForegroundColor Red } elseif ($idiomaSelecionado -eq "es") { Write-Host -NoNewline "     [C] - "  -ForegroundColor Red }
                            Write-Host $($global:translations["DOLogoutMenuOption"]) -ForegroundColor Gray
                            Write-Host -NoNewline "     [M] - "  -ForegroundColor Cyan
                            Write-Host $($global:translations["DOMainMenuOption"]) -ForegroundColor Gray
                            Write-Host ""
                            Write-Host "     ===============================================================================================================" -ForegroundColor Green
                            Write-Host ""

                        }

                        # Exibe o menu de detalhes do produto
                        Show-Menu-Detalhes-Produto

                        $opcao_categoria = Read-Host $($global:translations["SPMChoiceOptionCategorieMenu"])

                        # Verificar se a opção é válida
                        $selecionadoValido = $false
            
                        if (($idiomaSelecionado -eq "pt" -and $opcao_categoria -eq "C") -or ($idiomaSelecionado -eq "en" -and $opcao_categoria -eq "V") -or ($idiomaSelecionado -eq "es" -and $opcao_categoria -eq "S")) {

                            $detalheslogin_senhadisplay = $usuario_info["senha"]
                            Show-Menu-Detalhes-Produto -detalheslogin_senhadisplay $detalheslogin_senhadisplay
                            Start-Sleep -Seconds 3
                            $selecionadoValido = $false
                           
                        } elseif (($idiomaSelecionado -eq "pt" -and $opcao_categoria -eq "D") -or ($idiomaSelecionado -eq "en" -and $opcao_categoria -eq "L") -or ($idiomaSelecionado -eq "es" -and $opcao_categoria -eq "C")) {
                            Fazer-Login -LoginStatus $false
                        } elseif ($opcao_categoria -eq "M") {
                            Show-Menu -LoginStatus $true -UsuarioAtual $usuario_atual -SenhaAtual $senha_atual -TipoPlanoConta $plano_conta_atual
                        } elseif ($opcao_categoria -eq "R" -and $data_atual -gt $data_termino -and $produtosComMetodoEspecifico) {
                            MostrarCabecalhoRenovacao
                            MostrarMenuRenovacao -silent -produtosComMetodoEspecifico $produtosComMetodoEspecifico
                        } elseif ($opcao_categoria -match '^\d+$' -and [int]$opcao_categoria -le $todasCategorias.Count) {
                            # Chamar a função Mostrar-Detalhes-Produto com o programa selecionado como parâmetro
                            $categoria_escolhida = $todasCategorias[[int]$opcao_categoria - 1]

                            $returnCategoriaEscolhidaTranslate = Translate-Text -Text $categoria_escolhida -TargetLanguage $idiomaSelecionado

                            Write-Host ""
                            Write-Host "$($global:translations["SPMSelectedYouCategory"]): $returnCategoriaEscolhidaTranslate" -ForegroundColor Green
                            Write-Host ""
                            Show-Produtos-Categoria -UsuarioAtual $usuario_atual -SenhaAtual $senha_atual -CategoriaEscolhida $categoria_escolhida -CategoriasDisponiveis $categoriasDisponiveis -TipoPlanoConta $usuario_info["tipo_plano"] -DataAtual $data_atual -DataTermino $data_termino -ProdutosMetodoLiberado $produtosComMetodoEspecifico
                            # Show-Detail-Produto -CategoriaEscolhida $categoria_escolhida -ProdutosDisponiveis $categorias[$categoria_escolhida] -UsuarioAtual $usuario_atual
                        } else {

                            Write-Host ""
                            Write-Host $($global:translations["DOInvalidOptionN1"]) -ForegroundColor Red
                            Write-Host ""
                            
                            Start-Sleep -Seconds 3

                            $selecionadoValido = $false
                            # Se nenhuma opção válida for selecionada, mostra o menu atual novamente
                            # Show-Menu-Produto
                        }

                    } while (-not $selecionadoValido)

            } else {

                Write-Host $($global:translations["DMAAlertMessageUserNotFound"]) -ForegroundColor Red
            
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
            Write-Host "     $($global:translations["DMAAlertMessageAccessContentURLNotFound"]): $url_produto" -ForegroundColor Red
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
            Write-Host "     $($global:translations["DMAAlertMessageAccessContentURLNotFound"]): $url_produto" -ForegroundColor Red
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

    Update-Title-WindowMenu -menuKey "SPCMSelectProductCategoryMenu" -menuExt $CategoriaEscolhida # Atualiza o título para o menu principal

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
                if ($campos[1] -eq $CategoriaEscolhida) {
                    $todosProdutosCategoria += $campos[2].Trim()
                }
            }
        } catch {
            Write-Host "$($global:translations["DMAAlertMessageAccessContentURLNotFound"]): $url" -ForegroundColor Red
        }
    }

    # Remover produtos disponíveis da lista de todos os produtos
    $produtosNaoDisponiveis = $todosProdutosCategoria | Sort-Object | Select-Object -Unique |  Where-Object { $_ -notin $produtosDisponiveis }


    # Correção de Ajuste # 1 (Erro)
    
    # Erro
    # $todosProdutos = $produtosDisponiveis + $produtosNaoDisponiveis
    
    # Combinar os produtos disponíveis e não disponíveis em uma lista única
    $todosProdutos = @()

    $todosProdutos += $produtosDisponiveis
    $todosProdutos += $produtosNaoDisponiveis

    # Remover itens vazios (caso existam)
    $todosProdutos = $todosProdutos | Where-Object { $_ -ne "" }

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

            $fixedWidthMenuSelectProductCategory = 120  # Largura total da linha

            # Frase a ser centralizada
            $menuSelectProductCategoryTexto = $($global:translations["SPCMSelectProductCategoryMenu"])
            $menuSelectProductCategoryTextoLength = $menuSelectProductCategoryTexto.Length

            # Calcula o número de espaços necessários para centralizar
            $spacesNeededMenuSelectProductCategory = [Math]::Max(([Math]::Floor(($fixedWidthMenuSelectProductCategory - $menuSelectProductCategoryTextoLength) / 2)), 0)
            $spacesMenuSelectProductCategory = " " * $spacesNeededMenuSelectProductCategory

            Write-Host ""
            Write-Host ""
            Write-Host "     ================================================================================================================" -ForegroundColor Green
            Write-Host "$spacesMenuSelectProductCategory$menuSelectProductCategoryTexto" -ForegroundColor Cyan
            Write-Host "     ================================================================================================================" -ForegroundColor Green
	        Write-Host ""
                                           
            Show-Menu-Detalhes-Login -UsuarioAtual $UsuarioAtual -SenhaAtual $SenhaAtual -TipoPlanoConta $TipoPlanoConta -detalheslogin_senhadisplay $detalheslogin_senhadisplay -qtdvTotal $qtdvValues["qtdv_valor_atual"] -qtdvUtilizado $qtdvValues["qtdv_valor_utilizado"]
            
            # Calcular quantidades de produtos
            $quantidade_produtos_total = $todosProdutos.Count
            $quantidade_produtos_disponiveis = $produtosDisponiveis.Count
            
            Write-Host ""
            Write-Host "     ===============================================================================================================" -ForegroundColor Green
            Write-Host ""
            Write-Host "      $($global:translations["SPCMDetailsProducts"]): " -ForegroundColor Cyan
            Write-Host ""
                    Write-Host -NoNewline "      $($global:translations["SPCMSelectCategory"]): "
                    #$nomeCategoria = $CategoriaEscolhida.ToUpper()
                    $returnCategoriaEscolhidaTranslate = Translate-Text -Text $CategoriaEscolhida -TargetLanguage $idiomaSelecionado
                    Write-Host "$returnCategoriaEscolhidaTranslate" -ForegroundColor Yellow
                    Write-Host -NoNewline "      $($global:translations["SPCMTotalAvailableProducts"]): "
                    Write-Host "$quantidade_produtos_disponiveis" -ForegroundColor Yellow
                    Write-Host -NoNewline "      $($global:translations["SPCMTotalProducts"]): "
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
            if ($idiomaSelecionado -eq "pt") { Write-Host -NoNewline "     [C] - "  -ForegroundColor Blue } elseif ($idiomaSelecionado -eq "en") { Write-Host -NoNewline "     [V] - "  -ForegroundColor Blue } elseif ($idiomaSelecionado -eq "es") { Write-Host -NoNewline "     [S] - "  -ForegroundColor Blue }
            Write-Host $($global:translations["DOViewAccountMenuOption"]) -ForegroundColor Gray
            if ($idiomaSelecionado -eq "pt") { Write-Host -NoNewline "     [D] - "  -ForegroundColor Red } elseif ($idiomaSelecionado -eq "en") { Write-Host -NoNewline "     [L] - "  -ForegroundColor Red } elseif ($idiomaSelecionado -eq "es") { Write-Host -NoNewline "     [C] - "  -ForegroundColor Red }
            Write-Host $($global:translations["DOLogoutMenuOption"]) -ForegroundColor Gray
            if ($idiomaSelecionado -eq "pt") { Write-Host -NoNewline "     [V] - "  -ForegroundColor Cyan } elseif ($idiomaSelecionado -eq "en") { Write-Host -NoNewline "     [B] - "  -ForegroundColor Cyan } elseif ($idiomaSelecionado -eq "es") { Write-Host -NoNewline "     [V] - "  -ForegroundColor Cyan }
            Write-Host $($global:translations["DOGoBackMenuOption"]) -ForegroundColor Gray
            Write-Host -NoNewline "     [M] - "  -ForegroundColor Yellow
            Write-Host $($global:translations["DOMainMenuOption"]) -ForegroundColor Gray
            Write-Host ""
            Write-Host "     ===============================================================================================================" -ForegroundColor Green
            Write-Host ""
        }
        
        # Exibe o menu de detalhes de produtos disponíveis
        Show-Menu-Produtos-Disponiveis

        # Ler a seleção do usuário
        $opcao_produto = Read-Host $($global:translations["SPCMChoiceOptionProductAvailable"])
        
        # Verificar se a opção é válida
        $selecionadoValido = $false

        # Verificar se a opção é válida
        if ($opcao_produto -match '^\d+$' -and $opcao_produto -ge 1 -and $opcao_produto - 1 -le $todosProdutos.Count) {
            $produtoSelecionado = $todosProdutos[$opcao_produto - 1]
            if ($produtosDisponiveis -contains $produtoSelecionado) {
                Write-Host ""
                Write-Host "$($global:translations["SPCMSelectedYouProduct"]): $produtoSelecionado" -ForegroundColor Green
                Write-Host ""
                # Aqui você pode adicionar a lógica para manipular a seleção do produto disponível
                Show-Produtos-Metodos -UsuarioAtual $usuario_atual -SenhaAtual $senha_atual -CategoriaEscolhida $CategoriaEscolhida -ProdutoSelecionado $produtoSelecionado -TipoPlanoConta $TipoPlanoConta -DataAtual $DataAtual -DataTermino $DataTermino -ProdutosMetodoLiberado $ProdutosMetodoLiberado
                $selecionadoValido = $true
            } else {
                Write-Host ""
                Write-Host $($global:translations["SPCMProductNotFound"]) -ForegroundColor Red
                Write-Host ""
                Start-Sleep -Seconds 1
                $selecionadoValido = $false
            }
        } elseif (($idiomaSelecionado -eq "pt" -and $opcao_produto-eq "C") -or ($idiomaSelecionado -eq "en" -and $opcao_produto -eq "V") -or ($idiomaSelecionado -eq "es" -and $opcao_produto -eq "S")) {
            $detalheslogin_senhadisplay = $SenhaAtual
            Show-Menu-Produtos-Disponiveis -detalheslogin_senhadisplay $detalheslogin_senhadisplay
            Start-Sleep -Seconds 3
            $selecionadoValido = $false
        } elseif (($idiomaSelecionado -eq "pt" -and $opcao_produto-eq "D") -or ($idiomaSelecionado -eq "en" -and $opcao_produto -eq "L") -or ($idiomaSelecionado -eq "es" -and $opcao_produto -eq "C")) {
            Fazer-Login -LoginStatus $false
        } elseif (($idiomaSelecionado -eq "pt" -and $opcao_produto-eq "V") -or ($idiomaSelecionado -eq "en" -and $opcao_produto -eq "B") -or ($idiomaSelecionado -eq "es" -and $opcao_produto -eq "V")) {
            Show-Menu-Produto
        } elseif ($opcao_produto -eq "M") {
            Show-Menu -LoginStatus $true -UsuarioAtual $usuario_atual -SenhaAtual $senha_atual -TipoPlanoConta $plano_conta_atual
        } else {
            Write-Host ""
            Write-Host $($global:translations["DOInvalidOptionN1"]) -ForegroundColor Red
            Write-Host ""

            Start-Sleep -Seconds 3
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
    
    Update-Title-WindowMenu -menuKey "SMPMSelectMethodsProductMenu" -menuExt $ProdutoSelecionado # Atualiza o título para o menu principal

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
                Write-Host "     $($global:translations["DMAAlertMessageAccessContentURLNotFound"]): $url" -ForegroundColor Red
                continue
            }
        
            # Verificar se o conteúdo está vazio
            if ([string]::IsNullOrWhiteSpace($conteudo)) {
                Write-Host "     $($global:translations["DMAAlertMessageGetContentURLNotFound"]): $url" -ForegroundColor Red
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
                                    Write-Host "$($global:translations["DMAAlertMessageAccessContentURLNotFound"]): $urlsProduto" -ForegroundColor Red
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

                    Write-Host $($global:translations["DMAAlertMessageUserNotFound"]) -ForegroundColor Red
            
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
                   
                    $fixedWidthMenuSelectMethodsProduct = 120  # Largura total da linha

                    # Frase a ser centralizada
                    $menuSelectMethodsProductTexto = $($global:translations["SMPMSelectMethodsProductMenu"])
                    $menuSelectMethodsProductTextoLength = $menuSelectMethodsProductTexto.Length

                    # Calcula o número de espaços necessários para centralizar
                    $spacesNeededMenuSelectMethodsProduct = [Math]::Max(([Math]::Floor(($fixedWidthMenuSelectMethodsProduct - $menuSelectMethodsProductTextoLength) / 2)), 0)
                    $spacesMenuSelectMethodsProduct = " " * $spacesNeededMenuSelectMethodsProduct

                    Write-Host ""
                    Write-Host "     ================================================================================================================" -ForegroundColor Green
                    Write-Host "$spacesMenuSelectMethodsProduct$menuSelectMethodsProductTexto" -ForegroundColor Cyan
                    Write-Host "     ================================================================================================================" -ForegroundColor Green
	                Write-Host ""
                    
                    Show-Menu-Detalhes-Login -UsuarioAtual $UsuarioAtual -SenhaAtual $SenhaAtual -TipoPlanoConta $TipoPlanoConta -detalheslogin_senhadisplay $detalheslogin_senhadisplay -qtdvTotal $qtdvValues["qtdv_valor_atual"] -qtdvUtilizado $qtdvValues["qtdv_valor_utilizado"]
                    
                    Write-Host ""
                    Write-Host "     ===============================================================================================================" -ForegroundColor Green
                    Write-Host ""
                    Write-Host "      $($global:translations["SMPMDetailsMethodActivate"]): " -ForegroundColor Cyan
                    Write-Host ""
                            Write-Host -NoNewline "      $($global:translations["SMPMSelectedCategory"]): "
                            $returnCategoriaEscolhidaTranslate = Translate-Text -Text $CategoriaEscolhida -TargetLanguage $idiomaSelecionado
                            Write-Host "$returnCategoriaEscolhidaTranslate" -ForegroundColor Yellow
                            Write-Host -NoNewline "      $($global:translations["SMPMSelectedProduct"]): "
                            Write-Host "$ProdutoSelecionado" -ForegroundColor Yellow
                            Write-Host -NoNewline "      $($global:translations["SMPMQtdAvailableMethods"]): "
                            Write-Host "$quantidade_metodos_disponiveis" -ForegroundColor Yellow
                            Write-Host -NoNewline "      $($global:translations["SMPMTotalQtdMethods"]): "
                            Write-Host "$quantidade_metodos_total" -ForegroundColor Yellow
                    Write-Host ""
                    Write-Host "     ===============================================================================================================" -ForegroundColor Green
                    Write-Host ""

                    # Exibir categorias e quantidade de produtos
                    $contador = 1

                    foreach ($metodo_categoria in $todosMetodos[$categoria_escolhida]) {
                        
                        $produtos_metodos_disponiveis = if ($metodosDisponiveis.ContainsKey($metodo_categoria)) { $metodosDisponiveis[$metodo_categoria] } else { @() }
                        
                        $returnMetodoCategoriaTranslate = Translate-Text -Text $metodo_categoria -TargetLanguage $idiomaSelecionado

                        # Definir cores com base na disponibilidade dos métodos
                        if ($produtos_metodos_disponiveis -gt 1) {
                            Write-Host "     [$contador] - $returnMetodoCategoriaTranslate" -ForegroundColor Yellow
                        } else {
                            Write-Host "     [$contador] - $returnMetodoCategoriaTranslate" -ForegroundColor DarkGray
                        }

                        $contador++
                       
                    }

                    Write-Host ""
                    if ($idiomaSelecionado -eq "pt") { Write-Host -NoNewline "     [C] - "  -ForegroundColor Blue } elseif ($idiomaSelecionado -eq "en") { Write-Host -NoNewline "     [V] - "  -ForegroundColor Blue } elseif ($idiomaSelecionado -eq "es") { Write-Host -NoNewline "     [S] - "  -ForegroundColor Blue }
                    Write-Host $($global:translations["DOViewAccountMenuOption"]) -ForegroundColor Gray
                    if ($idiomaSelecionado -eq "pt") { Write-Host -NoNewline "     [D] - "  -ForegroundColor Red } elseif ($idiomaSelecionado -eq "en") { Write-Host -NoNewline "     [L] - "  -ForegroundColor Red } elseif ($idiomaSelecionado -eq "es") { Write-Host -NoNewline "     [C] - "  -ForegroundColor Red }
                    Write-Host $($global:translations["DOLogoutMenuOption"]) -ForegroundColor Gray
                    if ($idiomaSelecionado -eq "pt") { Write-Host -NoNewline "     [V] - "  -ForegroundColor Cyan } elseif ($idiomaSelecionado -eq "en") { Write-Host -NoNewline "     [B] - "  -ForegroundColor Cyan } elseif ($idiomaSelecionado -eq "es") { Write-Host -NoNewline "     [V] - "  -ForegroundColor Cyan }
                    Write-Host $($global:translations["DOGoBackMenuOption"]) -ForegroundColor Gray
                    Write-Host -NoNewline "     [M] - "  -ForegroundColor Yellow
                    Write-Host $($global:translations["DOMainMenuOption"]) -ForegroundColor Gray
                    Write-Host ""
                    Write-Host "     ===============================================================================================================" -ForegroundColor Green
                    Write-Host ""
                        
                }

                # Exibe o menu de detalhes de metodos dos produtos
                Show-Menu-Metodos-Produtos

                $opcao_metodo = Read-Host "$($global:translations["SMPMChoiceOptionMethodsProductMenu"]) $ProdutoSelecionado"
                
                # Verificar se a opção é válida
                $selecionadoValido = $false

                if ($opcao_metodo -match '^\d+$' -and [int]$opcao_metodo -ge 1 -and [int]$opcao_metodo -le $todosMetodos[$categoria_escolhida].Count) {
                    # Chamar a função Mostrar-Detalhes-Produto com o produto selecionado como parâmetro
                    $metodo_escolhido = $todosMetodos[$categoria_escolhida][$opcao_metodo - 1]

                    $returnMetodoEscolhidoTranslate = Translate-Text -Text $metodo_escolhido -TargetLanguage $idiomaSelecionado

                    if ($metodosDisponiveis.Keys -contains $metodo_escolhido) {
                        Write-Host ""
                        Write-Host "$($global:translations["SMPMSelectedYouMethod"]): $returnMetodoEscolhidoTranslate" -ForegroundColor Green 
                        Write-Host ""
                        # Aqui você pode adicionar a lógica para manipular a seleção do produto disponível
                        Show-Detail-Produto-Geral -UsuarioAtual $usuario_atual -SenhaAtual $senha_atual -CategoriaEscolhida $CategoriaEscolhida -ProdutoSelecionado $produtoSelecionado -MetodoSelecionado $metodo_escolhido -TipoPlanoConta $TipoPlanoConta -DataAtual $DataAtual -DataTermino $DataTermino -ProdutosMetodoLiberado $ProdutosMetodoLiberado
                        $selecionadoValido = $true 
                    } else {
                        Write-Host ""
                        Write-Host "$($global:translations["SMPMMethodNotFound"]) $ProdutoSelecionado" -ForegroundColor Red
                        Write-Host ""
                        Start-Sleep -Seconds 1
                        $selecionadoValido = $false
                        # Se nenhuma opção válida for selecionada, mostra o menu atual novamente
                    }
                } elseif (($idiomaSelecionado -eq "pt" -and $opcao_metodo -eq "C") -or ($idiomaSelecionado -eq "en" -and $opcao_metodo -eq "V") -or ($idiomaSelecionado -eq "es" -and $opcao_metodo -eq "S")) {
                    
                    $detalheslogin_senhadisplay = $usuario_info["senha"]
                    Show-Menu-Metodos-Produtos -detalheslogin_senhadisplay $detalheslogin_senhadisplay
                    Start-Sleep -Seconds 3
                    $selecionadoValido = $false

                } elseif (($idiomaSelecionado -eq "pt" -and $opcao_metodo -eq "D") -or ($idiomaSelecionado -eq "en" -and $opcao_metodo -eq "L") -or ($idiomaSelecionado -eq "es" -and $opcao_metodo -eq "C")) {
                    Fazer-Login -LoginStatus $false
                } elseif (($idiomaSelecionado -eq "pt" -and $opcao_metodo -eq "V") -or ($idiomaSelecionado -eq "en" -and $opcao_metodo -eq "B") -or ($idiomaSelecionado -eq "es" -and $opcao_metodo -eq "V")) {
                    Show-Produtos-Categoria -UsuarioAtual $usuario_atual -SenhaAtual $senha_atual -CategoriaEscolhida $categoria_escolhida -CategoriasDisponiveis $categoriasDisponiveis -TipoPlanoConta $usuario_info["tipo_plano"] -DataAtual $DataAtual -DataTermino $DataTermino -ProdutosMetodoLiberado $ProdutosMetodoLiberado
                } elseif ($opcao_metodo -eq "M") {
                    Show-Menu -LoginStatus $true -UsuarioAtual $usuario_atual -SenhaAtual $senha_atual -TipoPlanoConta $plano_conta_atual
                } else {
                    Write-Host ""
                    Write-Host $($global:translations["DOInvalidOptionN1"]) -ForegroundColor Red
                    Write-Host ""
                    Start-Sleep -Seconds 3
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
            Write-Host "     $($global:translations["DMAAlertMessageAccessContentURLNotFound"]): $url_metodo" -ForegroundColor Red
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

    Update-Title-WindowMenu -menuKey "DPMDetailsProductsMenu" -menuExt $ProdutoSelecionado # Atualiza o título para o menu principal

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
                Write-Host "     $($global:translations["DMAAlertMessageAccessContentURLNotFound"]): $url" -ForegroundColor Red
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
                Write-Host "     $($global:translations["DMAAlertMessageAccessContentURLNotFound"]): $url" -ForegroundColor Red
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
                                
                                $produtosctdigitalDisponiveis = @{ # Altera aqui
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
                           # resolver esse erro! # Altera aqui
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
                                            Write-Host "     $($global:translations["DTDFomartTimeInvalid"])" -ForegroundColor Yellow
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

                                        function MostrarCabecalhoTemporizador {
                                            # Função para mostrar o cabeçalho

                                            $fixedWidthMenuDetailsProducts = 120  # Largura total da linha

                                            # Frase a ser centralizada
                                            $menuDetailsProductsTexto = $($global:translations["DPMDetailsProductsMenu"])
                                            $menuDetailsProductsTextoLength = $menuDetailsProductsTexto.Length

                                            # Calcula o número de espaços necessários para centralizar
                                            $spacesNeededMenuDetailsProducts = [Math]::Max(([Math]::Floor(($fixedWidthMenuDetailsProducts - $menuDetailsProductsTextoLength) / 2)), 0)
                                            $spacesMenuDetailsProducts = " " * $spacesNeededMenuDetailsProducts

                                            Write-Host ""
                                            Write-Host "     ================================================================================================================" -ForegroundColor Green
                                            Write-Host "$spacesMenuDetailsProducts$menuDetailsProductsTexto" -ForegroundColor Cyan
                                            Write-Host "     ================================================================================================================" -ForegroundColor Green
	                                        Write-Host ""
                                        }

                                        # Função para mostrar o menu
                                        function MostrarMenuTemporizador {

                                            $nome_produto = $ProdutoSelecionado.ToUpper()
                                            $produtoctdigital_statusdisplay = if ($produtoctdigital_statusdisponibilidade -eq "Entregue") {
                                                                                    "Entre"
                                                                              } else {
                                                                                    "$produtoctdigital_statusdisponibilidade"
                                                                              }

                                            Write-Host ""
                                            Write-Host ""
                                            Write-Host "     ================================================================================================================" -ForegroundColor Green
                                            Write-Host "      $($global:translations["DTDDeliveryDetails"]) $nome_produto" -ForegroundColor Cyan  
                                            Write-Host ""  
                                            Write-Host -NoNewline "      $($global:translations["DTDDeliveryWaiting"]): "  -ForegroundColor White
                                            Write-Host "$produtoctdigital_tempoesperaentrega_timespan" -ForegroundColor Yellow
                                            Write-Host -NoNewline "      $($global:translations["DTDAvailabilityStatus"]): "  -ForegroundColor White
                                            Write-Host "$produtoctdigital_statusdisplay" -ForegroundColor Yellow
                                            Write-Host -NoNewline "      $($global:translations["DTDProductAvailability"]): "  -ForegroundColor White
                                            Write-Host "$produtoctdigital_disponibilidadeproduto" -ForegroundColor Yellow
                                            Write-Host "     ================================================================================================================" -ForegroundColor Green
                                            Write-Host ""
                                            if ($idiomaSelecionado -eq "pt") { Write-Host -NoNewline "     [D] - "  -ForegroundColor Red } elseif ($idiomaSelecionado -eq "en") { Write-Host -NoNewline "     [L] - "  -ForegroundColor Red } elseif ($idiomaSelecionado -eq "es") { Write-Host -NoNewline "     [C] - "  -ForegroundColor Red }
                                            Write-Host $($global:translations["DOLogoutMenuOption"]) -ForegroundColor Gray
                                            if ($idiomaSelecionado -eq "pt") { Write-Host -NoNewline "     [V] - "  -ForegroundColor Cyan } elseif ($idiomaSelecionado -eq "en") { Write-Host -NoNewline "     [B] - "  -ForegroundColor Cyan } elseif ($idiomaSelecionado -eq "es") { Write-Host -NoNewline "     [V] - "  -ForegroundColor Cyan }
                                            Write-Host $($global:translations["DOGoBackMenuOption"]) -ForegroundColor Gray
                                            Write-Host -NoNewline "     [M] - "  -ForegroundColor Yellow
                                            Write-Host $($global:translations["DOMainMenuOption"]) -ForegroundColor Gray
                                            Write-Host ""
                                            Write-Host "     ================================================================================================================" -ForegroundColor Green
                                            Write-Host ""
                                            Write-Host "$($global:translations["DOInvalidOptionN1"]):" -ForegroundColor White
                                        }

                                        # Função principal para mostrar o tempo restante
                                        function MostrarTempoRestante {
                                            param (
                                                [timespan]$tempo_restante
                                            )
                                            $horas_restantes = [math]::Floor($tempo_restante.TotalHours)
                                            $minutos_restantes = $tempo_restante.Minutes
                                            $segundos_restantes = $tempo_restante.Seconds

                                            Write-Host -NoNewline "      $($global:translations["DTDTimeLeftDelivery"]): "  -ForegroundColor White
                                            Write-Host -NoNewline "$horas_restantes" -ForegroundColor White
                                            Write-Host -NoNewline " $($global:translations["DTDHoursTiming"])" -ForegroundColor Yellow
                                            Write-Host -NoNewline " /" -ForegroundColor Cyan
                                            Write-Host -NoNewline " $minutos_restantes" -ForegroundColor White
                                            Write-Host -NoNewline " $($global:translations["DTDMinutesTiming"])" -ForegroundColor Yellow
                                            Write-Host -NoNewline " /" -ForegroundColor Cyan
                                            Write-Host -NoNewline " $segundos_restantes" -ForegroundColor White
                                            Write-Host -NoNewline " $($global:translations["DTDSecondsTiming"])" -ForegroundColor Yellow
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

                                                    if ($idiomaSelecionado -eq "pt") {
                                                        
                                                        switch ($input) {
                                                            'D' {
                                                                Fazer-Login -LoginStatus $false
                                                            }
                                                            'V' {
                                                                Show-Produtos-Metodos -UsuarioAtual $usuario_atual -SenhaAtual $senha_atual -CategoriaEscolhida $CategoriaEscolhida -ProdutoSelecionado $produtoSelecionado -TipoPlanoConta $TipoPlanoConta -DataAtual $DataAtual -DataTermino $DataTermino -ProdutosMetodoLiberado $ProdutosMetodoLiberado
                                                            }
                                                            'M' {
                                                                Show-Menu -LoginStatus $true -UsuarioAtual $usuario_atual -SenhaAtual $senha_atual -TipoPlanoConta $plano_conta_atual
                                                            }
                                                            default {
                                                                Write-Host $($global:translations["DOInvalidOptionN1"])
                                                            }
                                                        }

                                                    } elseif ($idiomaSelecionado -eq "en") {

                                                        switch ($input) { 
                                                            'L' {
                                                                Fazer-Login -LoginStatus $false
                                                            }
                                                            'B' {
                                                                Show-Produtos-Metodos -UsuarioAtual $usuario_atual -SenhaAtual $senha_atual -CategoriaEscolhida $CategoriaEscolhida -ProdutoSelecionado $produtoSelecionado -TipoPlanoConta $TipoPlanoConta -DataAtual $DataAtual -DataTermino $DataTermino -ProdutosMetodoLiberado $ProdutosMetodoLiberado
                                                            }
                                                            'M' {
                                                                Show-Menu -LoginStatus $true -UsuarioAtual $usuario_atual -SenhaAtual $senha_atual -TipoPlanoConta $plano_conta_atual
                                                            }
                                                            default {
                                                                Write-Host $($global:translations["DOInvalidOptionN1"])
                                                            }
                                                        }

                                                    } elseif ($idiomaSelecionado -eq "es") {
                                                    
                                                        switch ($input) { 
                                                            'C' {
                                                                Fazer-Login -LoginStatus $false
                                                            }
                                                            'V' {
                                                                Show-Produtos-Metodos -UsuarioAtual $usuario_atual -SenhaAtual $senha_atual -CategoriaEscolhida $CategoriaEscolhida -ProdutoSelecionado $produtoSelecionado -TipoPlanoConta $TipoPlanoConta -DataAtual $DataAtual -DataTermino $DataTermino -ProdutosMetodoLiberado $ProdutosMetodoLiberado
                                                            }
                                                            'M' {
                                                                Show-Menu -LoginStatus $true -UsuarioAtual $usuario_atual -SenhaAtual $senha_atual -TipoPlanoConta $plano_conta_atual
                                                            }
                                                            default {
                                                                Write-Host $($global:translations["DOInvalidOptionN1"])
                                                            }
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
                                                Write-Host "      $($global:translations["DTDEndDeliveryTime"])"  -ForegroundColor Green
                                                Write-Host ""
                                                Write-Host -NoNewline "       * " -ForegroundColor Cyan
                                                Write-Host "$($global:translations["DTDBackSelectMethodActivated"]) $ProdutoSelecionado ." -ForegroundColor Yellow
                                                Write-Host -NoNewline "       * " -ForegroundColor Cyan
                                                Write-Host "$($global:translations["DTDTryLoginAccount"])." -ForegroundColor Yellow
                                                Write-Host ""
                                                Write-Host "      $($global:translations["DTDProductRebootTiming"])"  -ForegroundColor Red
                                                # Mostrar o menu abaixo do temporizador
                                                MostrarMenuTemporizador

                                                # Loop principal para detecção de entrada do usuário e atualização do temporizador
                                                while ($tempo_restante.TotalSeconds -eq 0) {

                                                    if ($Host.UI.RawUI.KeyAvailable) {
                                                        $input = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown").Character
                                                        if ($idiomaSelecionado -eq "pt") {

                                                            switch ($input) {
                                                                'D' {
                                                                    Fazer-Login -LoginStatus $false
                                                
                                                                }
                                                                'V' {
                                                                    Show-Produtos-Metodos -UsuarioAtual $usuario_atual -SenhaAtual $senha_atual -CategoriaEscolhida $CategoriaEscolhida -ProdutoSelecionado $produtoSelecionado -TipoPlanoConta $TipoPlanoConta -DataAtual $DataAtual -DataTermino $DataTermino -ProdutosMetodoLiberado $ProdutosMetodoLiberado
                                                
                                                                }
                                                                'M' {
                                                                    Show-Menu -LoginStatus $true -UsuarioAtual $usuario_atual -SenhaAtual $senha_atual -TipoPlanoConta $plano_conta_atual
                                                
                                                                }
                                                                default {
                                                                    Write-Host $($global:translations["DOInvalidOptionN1"])
                                                                }
                                                            }

                                                        } elseif ($idiomaSelecionado -eq "en") {

                                                            switch ($input) {
                                                                'L' {
                                                                    Fazer-Login -LoginStatus $false
                                                
                                                                }
                                                                'B' {
                                                                    Show-Produtos-Metodos -UsuarioAtual $usuario_atual -SenhaAtual $senha_atual -CategoriaEscolhida $CategoriaEscolhida -ProdutoSelecionado $produtoSelecionado -TipoPlanoConta $TipoPlanoConta -DataAtual $DataAtual -DataTermino $DataTermino -ProdutosMetodoLiberado $ProdutosMetodoLiberado
                                                
                                                                }
                                                                'M' {
                                                                    Show-Menu -LoginStatus $true -UsuarioAtual $usuario_atual -SenhaAtual $senha_atual -TipoPlanoConta $plano_conta_atual
                                                
                                                                }
                                                                default {
                                                                    Write-Host $($global:translations["DOInvalidOptionN1"])
                                                                }
                                                            }

                                                        } elseif ($idiomaSelecionado -eq "es") {
                                                    
                                                            switch ($input) { 
                                                                'C' {
                                                                    Fazer-Login -LoginStatus $false
                                                                }
                                                                'V' {
                                                                    Show-Produtos-Metodos -UsuarioAtual $usuario_atual -SenhaAtual $senha_atual -CategoriaEscolhida $CategoriaEscolhida -ProdutoSelecionado $produtoSelecionado -TipoPlanoConta $TipoPlanoConta -DataAtual $DataAtual -DataTermino $DataTermino -ProdutosMetodoLiberado $ProdutosMetodoLiberado
                                                                }
                                                                'M' {
                                                                    Show-Menu -LoginStatus $true -UsuarioAtual $usuario_atual -SenhaAtual $senha_atual -TipoPlanoConta $plano_conta_atual
                                                                }
                                                                default {
                                                                    Write-Host $($global:translations["DOInvalidOptionN1"])
                                                                }
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
                                        Write-Host "     $($global:translations["DTDErrorOccurred"]): $_" -ForegroundColor Red
                                        Write-Host "     $($global:translations["DTDPleaseTryAgain"])" -ForegroundColor Yellow
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
                                        
                                        $qtdvIndividualTotal_produto_translate = Translate-Text -Text $qtdvIndividualTotal -TargetLanguage $idiomaSelecionado

                                        if(-not $silent) {
                                            
                                            Write-Host -NoNewline "      $($global:translations["VTIMQTDV"]): " 
                                            
                                            if ($qtdvIndividualTotal -eq "Ilimitado") {
                                                
                                                Write-Host "$qtdvIndividualTotal_produto_translate" -ForegroundColor Cyan
                                            } elseif($qtdvIndividualTotal -ne 0) {
                                                Write-Host "$qtdvIndividualTotal_produto_translate" -ForegroundColor Yellow
                                            } else {
                                                Write-Host $($global:translations["VTIMNothing"]) -ForegroundColor Red 
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

                                    # Traduções para o menu
                                    
                                    $produtoctdigital_beneficios = Translate-Text -Text $produtoctdigital_beneficios -TargetLanguage $idiomaSelecionado
                                    $produtoctdigital_regrasuso = Translate-Text -Text $produtoctdigital_regrasuso -TargetLanguage $idiomaSelecionado
                                    $produtoctdigital_instrucoes_usoativacao = Translate-Text -Text $produtoctdigital_instrucoes_usoativacao -TargetLanguage $idiomaSelecionado

                                    $categoria_produto_translate = Translate-Text -Text $($produtoctdigitalDisponivel['categoria_produto']) -TargetLanguage $idiomaSelecionado
                                    $metodo_produto_translate = Translate-Text -Text $($produtoctdigitalDisponivel['metodo_ativacao_produto']) -TargetLanguage $idiomaSelecionado
                                    $capacidadearmazenamento_produto_translate = Translate-Text -Text $produtoctdigital_capacidade_armazenamento -TargetLanguage $idiomaSelecionado
                                    $compatdispositivos_produto_translate = Translate-Text -Text $produtoctdigital_compatibilidade_dispositivos -TargetLanguage $idiomaSelecionado
                                    $statuspagamento_produto_translate = Translate-Text -Text $($produtoctdigitalDisponivel['status_pagamento']) -TargetLanguage $idiomaSelecionado
                                    $diasgarantiasuporte_produto_translate = Translate-Text -Text $produtoctdigital_dias_garantia_suporte -TargetLanguage $idiomaSelecionado
                                    $statuspagamento_produto_translate = Translate-Text -Text $($produtoctdigitalDisponivel['status_pagamento']) -TargetLanguage $idiomaSelecionado
                                    $statusrenovacao_produto_translate = Translate-Text -Text $produtoctdigital_status_renovacao -TargetLanguage $idiomaSelecionado
                                    $tempoesperaentrega_produto_translate = Translate-Text -Text $produtoctdigital_tempoesperaentrega -TargetLanguage $idiomaSelecionado
                                    $statusdisponibilidade_produto_translate = Translate-Text -Text $produtoctdigital_statusdisponibilidade -TargetLanguage $idiomaSelecionado
                                    $disponibilidadeproduto_produto_translate = Translate-Text -Text $produtoctdigital_disponibilidadeproduto -TargetLanguage $idiomaSelecionado
                                    $duracaoplano_produto_translate = Translate-Text -Text $($produtoctdigitalDisponivel['duracao_plano']) -TargetLanguage $idiomaSelecionado
                                    $datainicio_produto_translate = Translate-Text -Text $($produtoctdigitalDisponivel['data_inicio_ctdigital']) -TargetLanguage $idiomaSelecionado
                                    $datatermino_produto_translate = Translate-Text -Text $($produtoctdigitalDisponivel['data_termino_ctdigital']) -TargetLanguage $idiomaSelecionado
                                    $diasrestantes_produto_translate = Translate-Text -Text $($produtoctdigitalDisponivel['dias_restantes_ctdigital']) -TargetLanguage $idiomaSelecionado
                                    $produtoctdigital_telapinlock = Translate-Text -Text "$produtoctdigital_telapinlock" -TargetLanguage $idiomaSelecionado
                                    $produtoctdigital_chavekey = Translate-Text -Text "$produtoctdigital_chavekey" -TargetLanguage $idiomaSelecionado
                                    $produtoctdigital_usuario = Translate-Text -Text "$produtoctdigital_usuario" -TargetLanguage $idiomaSelecionado
                                    $produtoctdigital_tipo_conta = Translate-Text -Text $produtoctdigital_tipo_conta -TargetLanguage $idiomaSelecionado
                                    # if ($idiomaSelecionado -eq "en" -and $produtoctdigital_tipo_conta -eq "Privada" ) { $produtoctdigital_tipo_conta = "Privado"; $produtoctdigital_tipo_conta = Translate-Text -Text $produtoctdigital_tipo_conta -TargetLanguage $idiomaSelecionado }

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

                                        $fixedWidthMenuDetailsProducts = 120  # Largura total da linha

                                        # Frase a ser centralizada
                                        $menuDetailsProductsTexto = $($global:translations["DPMDetailsProductsMenu"])
                                        $menuDetailsProductsTextoLength = $menuDetailsProductsTexto.Length

                                        # Calcula o número de espaços necessários para centralizar
                                        $spacesNeededMenuDetailsProducts = [Math]::Max(([Math]::Floor(($fixedWidthMenuDetailsProducts - $menuDetailsProductsTextoLength) / 2)), 0)
                                        $spacesMenuDetailsProducts = " " * $spacesNeededMenuDetailsProducts

                                        Write-Host ""
                                        Write-Host "     ================================================================================================================" -ForegroundColor Green
                                        Write-Host "$spacesMenuDetailsProducts$menuDetailsProductsTexto" -ForegroundColor Cyan
                                        Write-Host "     ================================================================================================================" -ForegroundColor Green
	                                    Write-Host ""
                                        Write-Host "      $($global:translations["DPMDetailsProductTitle"]): " -ForegroundColor Cyan
                                        Write-Host ""
                                        Write-Host -NoNewline "      $($global:translations["DPMNameProduct"]): "
                                        Write-Host "$($produtoctdigitalDisponivel['nome_produto'])" -ForegroundColor Yellow
                                        Write-Host -NoNewline "      $($global:translations["DPMCategoryProduct"]): "
                                        Write-Host "$categoria_produto_translate" -ForegroundColor Yellow
                                        Write-Host -NoNewline "      $($global:translations["DPMMethodActivateProduct"]): "
                                        Write-Host "$metodo_produto_translate" -ForegroundColor Yellow
                                        if ($CategoriaEscolhida -eq "Streaming") {
                                            Write-Host -NoNewline "      $($global:translations["DPMTypeAccount"]): "
                                            Write-Host "$produtoctdigital_tipo_conta" -ForegroundColor Yellow
                                            Write-Host -NoNewline "      $($global:translations["DPMQTDScreen"]): "
                                            Write-Host "$produtoctdigital_qtd_telas" -ForegroundColor Yellow
                                            Write-Host -NoNewline "      $($global:translations["DPMQTDAccessDispSimult"]): "
                                            Write-Host "$produtoctdigital_qtd_acessdisp_simult" -ForegroundColor Yellow
                                        } elseif($CategoriaEscolhida -eq "Softwares e Licenças" -and $MetodoSelecionado -eq "Conta Digital") {
                                            Write-Host -NoNewline "      $($global:translations["DPMTypeAccount"]): "
                                            Write-Host "$produtoctdigital_tipo_conta" -ForegroundColor Yellow
                                            Write-Host -NoNewline "      $($global:translations["DPMYearProduct"]): "
                                            Write-Host "$produtoctdigital_ano_produto" -ForegroundColor Yellow
                                            Write-Host -NoNewline "      $($global:translations["DPMCurrentVersion"]): "
                                            Write-Host "$produtoctdigital_versao_atual" -ForegroundColor Yellow
                                            Write-Host -NoNewline "      $($global:translations["DPMAvailableVersion"]): "
                                            Write-Host "$produtoctdigital_versao_disponivel" -ForegroundColor Yellow
                                            Write-Host -NoNewline "      $($global:translations["DPMOperatingSytem"]): "
                                            Write-Host "$produtoctdigital_sistema_operacional" -ForegroundColor Yellow
                                            Write-Host -NoNewline "      $($global:translations["DPMStorageCapacity"]): "
                                            Write-Host "$capacidadearmazenamento_produto_translate" -ForegroundColor Yellow
                                            Write-Host -NoNewline "      $($global:translations["DPMQTDUsersAccessSimult"]): "
                                            Write-Host "$produtoctdigital_qtd_acessusuarios_simult" -ForegroundColor Yellow
                                            Write-Host -NoNewline "      $($global:translations["DPMQTDDispAccessSimult"]): "
                                            Write-Host "$produtoctdigital_qtd_acessdisp_simult" -ForegroundColor Yellow
                                        } elseif($CategoriaEscolhida -eq "Softwares e Licenças" -and $MetodoSelecionado -eq "Chave/Serial") {
                                            Write-Host -NoNewline "      $($global:translations["DPMTypeAccount"]): "
                                            Write-Host "$produtoctdigital_tipo_conta" -ForegroundColor Yellow
                                            Write-Host -NoNewline "      $($global:translations["DPMYearProduct"]): "
                                            Write-Host "$produtoctdigital_ano_produto" -ForegroundColor Yellow
                                            Write-Host -NoNewline "      $($global:translations["DPMCurrentVersion"]): "
                                            Write-Host "$produtoctdigital_versao_atual" -ForegroundColor Yellow
                                            Write-Host -NoNewline "      $($global:translations["DPMAvailableVersion"]): "
                                            Write-Host "$produtoctdigital_versao_disponivel" -ForegroundColor Yellow
                                            Write-Host -NoNewline "      $($global:translations["DPMOperatingSytem"]): "
                                            Write-Host "$produtoctdigital_sistema_operacional" -ForegroundColor Yellow
                                            Write-Host -NoNewline "      $($global:translations["DPMStorageCapacity"]): "
                                            Write-Host "$capacidadearmazenamento_produto_translate" -ForegroundColor Yellow
                                            Write-Host -NoNewline "      $($global:translations["DPMQTDUsersAccessSimult"]): "
                                            Write-Host "$produtoctdigital_qtd_acessusuarios_simult" -ForegroundColor Yellow
                                        } elseif($CategoriaEscolhida -eq "Softwares e Licenças" -and $MetodoSelecionado -eq "Pré-Ativado") {
                                            Write-Host -NoNewline "      $($global:translations["DPMYearProduct"]): "
                                            Write-Host "$produtoctdigital_ano_produto" -ForegroundColor Yellow
                                            Write-Host -NoNewline "      $($global:translations["DPMCurrentVersion"]): "
                                            Write-Host "$produtoctdigital_versao_atual" -ForegroundColor Yellow
                                            Write-Host -NoNewline "      $($global:translations["DPMAvailableVersion"]): "
                                            Write-Host "$produtoctdigital_versao_disponivel" -ForegroundColor Yellow
                                            Write-Host -NoNewline "      $($global:translations["DPMOperatingSytem"]): "
                                            Write-Host "$produtoctdigital_sistema_operacional" -ForegroundColor Yellow
                                            Write-Host -NoNewline "      $($global:translations["DPMQTDInstDispSimult"]): "
                                            Write-Host "$produtoctdigital_qtd_installdisp_simult" -ForegroundColor Yellow
                                            Write-Host -NoNewline "      $($global:translations["DPMQTDDispAccessSimult"]): "
                                            Write-Host "$produtoctdigital_qtd_acessdisp_simult" -ForegroundColor Yellow
                                        } elseif($CategoriaEscolhida -eq "VPNs") {
                                            Write-Host -NoNewline "      $($global:translations["DPMTypeAccount"]): "
                                            Write-Host "$produtoctdigital_tipo_conta" -ForegroundColor Yellow
                                            Write-Host -NoNewline "      $($global:translations["DPMOperatingSytem"]): "
                                            Write-Host "$produtoctdigital_sistema_operacional" -ForegroundColor Yellow
                                            Write-Host -NoNewline "      $($global:translations["DPMQTDUsersAccessSimult"]): "
                                            Write-Host "$produtoctdigital_qtd_acessusuarios_simult" -ForegroundColor Yellow
                                            Write-Host -NoNewline "      $($global:translations["DPMQTDDispAccessSimult"]): "
                                            Write-Host "$produtoctdigital_qtd_acessdisp_simult" -ForegroundColor Yellow
                                        }
                                        Write-Host -NoNewline "      $($global:translations["DPMDeviceCompatibility"]): "
                                        Write-Host "$compatdispositivos_produto_translate" -ForegroundColor Yellow
                                        if ($CategoriaEscolhida -eq "Softwares e Licenças" -and $MetodoSelecionado -eq "Pré-Ativado") {
                                            Write-Host -NoNewline "      $($global:translations["DPMSupportDuration"]): "
                                            Write-Host "$produtoctdigital_duracao_garantia_suporte" -ForegroundColor Yellow
                                            Write-Host -NoNewline "      $($global:translations["DPMPaymentStatus"]): "
                                            Write-Host "$statuspagamento_produto_translate" -ForegroundColor Yellow
                                            Write-Host -NoNewline "      $($global:translations["DPMUpdateRenewalStatus"]): "
                                            Write-Host "$produtoctdigital_status_atualizacao_renovacao" -ForegroundColor Yellow
                                            # Write-Host "$($produtoctdigitalDisponivel['qtdv_produto'])" -ForegroundColor Yellow
                                            Update-QTDVIndividualMenu -qtdvIndividualTotal $qtdvIndividualValues["qtdv_valor_atual"]
                                        } else {
                                            Write-Host -NoNewline "      $($global:translations["DPMDaysSupport"]): "
                                            Write-Host "$diasgarantiasuporte_produto_translate" -ForegroundColor Yellow
                                            Write-Host -NoNewline "      $($global:translations["DPMPaymentStatus"]): "
                                            if($($produtoctdigitalDisponivel['status_pagamento']) -eq "Pendente") {
                                                Write-Host "$statuspagamento_produto_translate" -ForegroundColor Red
                                            } else {
                                                Write-Host "$statuspagamento_produto_translate" -ForegroundColor Green
                                            }
                                            Write-Host -NoNewline "      $($global:translations["DPMRenewalStatus"]): "
                                            if($produtoctdigital_status_renovacao -eq "Aprovado") {
                                                Write-Host "$statusrenovacao_produto_translate" -ForegroundColor Green
                                            } else {
                                                Write-Host "$statusrenovacao_produto_translate" -ForegroundColor Red
                                            }
                                            # Write-Host "$($produtoctdigitalDisponivel['qtdv_produto'])" -ForegroundColor Yellow
                                            Update-QTDVIndividualMenu -qtdvIndividualTotal $qtdvIndividualValues["qtdv_valor_atual"]
                                        }
                                        Write-Host ""
                                        Write-Host "      $($global:translations["DPMEDeliveryDetails"]): " -ForegroundColor Cyan
                                        Write-Host ""
                                        Write-Host -NoNewline "      $($global:translations["DPMEProductDeliveryTime"]): "
                                        if ($produtoctdigital_tempoesperaentrega -eq "Nenhum") {
                                            Write-Host "$tempoesperaentrega_produto_translate" -ForegroundColor Red  
                                        } else {
                                            Write-Host "$tempoesperaentrega_produto_translate" -ForegroundColor Yellow
                                        }
                                        Write-Host -NoNewline "      $($global:translations["DPMEProductDeliveryStatus"]): "
                                        if ($produtoctdigital_statusdisponibilidade -eq "Entregue") {
                                            Write-Host "$statusdisponibilidade_produto_translate" -ForegroundColor Green
                                        } else {
                                            Write-Host "$statusdisponibilidade_produto_translate" -ForegroundColor Yellow
                                        }
                                        Write-Host -NoNewline "      $($global:translations["DPMEProductAvailabilityStatus"]): "
                                        if ($produtoctdigital_disponibilidadeproduto -eq "Online") {
                                            Write-Host "$disponibilidadeproduto_produto_translate" -ForegroundColor Green
                                        } else {
                                            Write-Host "$disponibilidadeproduto_produto_translate" -ForegroundColor Yellow
                                        }
                                        if ($MetodoSelecionado -eq "Conta Digital" -or $MetodoSelecionado -eq "Chave/Serial" -or $MetodoSelecionado -eq "Pré-Ativado") {
                                            Write-Host ""
                                            Write-Host "     ===============================================================================================================" -ForegroundColor Magenta
                                            if ($($produtoctdigitalDisponivel['duracao_plano']) -eq "Vitalício"){
                                                Write-Host -NoNewline "      $($global:translations["DPMEPlanDurantion"]): "
                                                Write-Host "$duracaoplano_produto_translate" -ForegroundColor Cyan
                                            } else {
                                                Write-Host -NoNewline "      $($global:translations["DPMEPlanDurantion"]): "
                                                Write-Host "$duracaoplano_produto_translate" -ForegroundColor Blue
                                            } 
                                            if ($($produtoctdigitalDisponivel['data_inicio_ctdigital']) -eq "Nenhum"){
                                                Write-Host -NoNewline "      $($global:translations["DPMEStartDeliveryDate"]): "
                                                Write-Host "$datainicio_produto_translate" -ForegroundColor Red
                                            } else {
                                                Write-Host -NoNewline "      $($global:translations["DPMEStartDeliveryDate"]): "
                                                Write-Host "$($produtoctdigitalDisponivel['data_inicio_ctdigital'])" -ForegroundColor Yellow
                                            } 
                                            if ($($produtoctdigitalDisponivel['data_termino_ctdigital']) -eq "Nenhum"){
                                                Write-Host -NoNewline "      $($global:translations["DPMEEndDeliveryDate"]): "
                                                Write-Host "$datatermino_produto_translate" -ForegroundColor Red
                                            } else {
                                                Write-Host -NoNewline "      $($global:translations["DPMEEndDeliveryDate"]): "
                                                Write-Host "$($produtoctdigitalDisponivel['data_termino_ctdigital'])" -ForegroundColor Yellow
                                            } 
                                            if ($($produtoctdigitalDisponivel['dias_restantes_ctdigital']) -eq "Nenhum" -or $($produtoctdigitalDisponivel['dias_restantes_ctdigital']) -eq "Último Dia"){
                                                Write-Host -NoNewline "      $($global:translations["DPMERemainingDeliveryDays"]): "
                                                Write-Host "$diasrestantes_produto_translate" -ForegroundColor Red
                                            } elseif ($($produtoctdigitalDisponivel['dias_restantes_ctdigital']) -eq "Vitalício") {
                                                Write-Host -NoNewline "      $($global:translations["DPMERemainingDeliveryDays"]): "
                                                Write-Host "$diasrestantes_produto_translate" -ForegroundColor Cyan
                                            } else {
                                                Write-Host -NoNewline "      $($global:translations["DPMERemainingDeliveryDays"]): "
                                                Write-Host "$($produtoctdigitalDisponivel['dias_restantes_ctdigital'])" -ForegroundColor Blue
                                            } 
                                            Write-Host "     ===============================================================================================================" -ForegroundColor Magenta
                                            Write-Host ""
                                        } else {
                                            Write-Host ""
                                        }
                                        Write-Host "      $($global:translations["DPMRIBPlanBenefitsTitle"]): " -ForegroundColor Cyan
                                        Write-Host ""
                                        foreach ($beneficio in $beneficios_array) {

                                            $beneficio_produto = $beneficio.Trim()

                                            Write-Host -NoNewline "      $($contadorbeneficios):"
                                            Write-Host " $beneficio_produto" -ForegroundColor Yellow
                                            $contadorbeneficios++
                                        }
                                        if($MetodoSelecionado -eq "Conta Digital"){
                                            Write-Host ""
                                            Write-Host "      $($global:translations["DPMDAAccessDataTitle"]): " -ForegroundColor Cyan
                                            Write-Host ""
                                            Write-Host -NoNewline "      $($global:translations["DPMDAUserAndEmail"]): "
                                            Write-Host "$produtoctdigital_usuariodisplay" -ForegroundColor $revelarDadosAcessoColor
                                            Write-Host -NoNewline "      $($global:translations["DPMDAPassAccessData"]): "
                                            Write-Host "$produtoctdigital_senhadisplay" -ForegroundColor $revelarDadosAcessoColor
                                            if ($CategoriaEscolhida -eq "Streaming" -and $produtoctdigital_qtdtelas -ne "Compartilhada" -and $produtoctdigital_qtdtelas -ne "Completa") {
                                                Write-Host -NoNewline "      $($global:translations["DPMDAPinLockAccessDataScreen"]): "
                                                Write-Host "$produtoctdigital_telapinlockdisplay" -ForegroundColor $revelarDadosAcessoColor
                                                Write-Host ""
                                            } else {
                                                Write-Host ""
                                            }
                                        } elseif ($MetodoSelecionado -eq "Chave/Serial") {
                                            Write-Host ""
                                            Write-Host "      $($global:translations["DPMDAAccessDataTitle"]): " -ForegroundColor Cyan
                                            Write-Host ""
                                            Write-Host -NoNewline "      $($global:translations["DPMDAUserAndEmail"]): "
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
                                            

                                            Write-Host -NoNewline "      $($global:translations["DPMDAPassAccessData"]): "
                                            Write-Host "$produtoctdigital_senhadisplay" -ForegroundColor $revelarDadosAcessoColor
                                            Write-Host -NoNewline "      $($global:translations["DPMDAKeysAccessDataKey"]): "
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
                                                Write-Host -NoNewline "      $($global:translations["DPMDAQTDKeysAccessData"]): "
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
                                            Write-Host "      $($global:translations["DPMRIBRulesUse"]): " -ForegroundColor Cyan
                                            Write-Host ""
                                            foreach ($regrauso in $regrasuso_array) {

                                                $regra = $regrauso.Trim()
                                                Write-Host -NoNewline "      $($contadorregras):"
                                                Write-Host " $regra" -ForegroundColor Yellow
                                                $contadorregras++
                                            }
                                            Write-Host ""
                                            Write-Host -NoNewline "      $($global:translations["DPMRIBPleaseNote"]): " -ForegroundColor Red
                                            Write-Host $($global:translations["DPMRIBAnyViolationAnnunce"]) -ForegroundColor Yellow
                                            Write-Host ""
                                        }
                                        if($CategoriaEscolhida -eq "Softwares e Licenças" -and $MetodoSelecionado -eq "Chave/Serial" -and 
                                        $instrucoes_usoativacao_array[0] -ne "Nenhum" -and $instrucoes_usoativacao_array[1] -ne "Nenhum"){
                                            
                                            $stepsAtvToCheck = $null

                                            $processo_ativacao = $instrucoes_usoativacao_array[0].Trim()
                                            $passo_ativacao = $instrucoes_usoativacao_array[1].Trim()

                                            $stepsAtvToCheck = @{
                                                "processo_ativacao" = $processo_ativacao
                                                "passo_ativacao" = $passo_ativacao
                                            }


                                            Write-Host "      $($global:translations["DPMRIBInstructionsUse"]): " -ForegroundColor Cyan
                                            Write-Host ""
                                            Write-Host -NoNewline "      $($global:translations["DPMRIBActivationProcess"]): "
                                            Write-Host "$($stepsAtvToCheck["processo_ativacao"])" -ForegroundColor Yellow
                                            Write-Host ""

                                            $linhas_passo_atv = $($stepsAtvToCheck['passo_ativacao']) -split "\."
                                        
                                            $contador_passo_atv = 1

                                            Write-Host "      $($global:translations["DPMRIBStepsForActivation"]): "
                                            foreach ($linha_passo_atv in $linhas_passo_atv) {

                                                $passo_atv = $linha_passo_atv.Trim()

                                                if ($passo_atv -ne "") {
                                                    Write-Host ""
                                                    Write-Host -NoNewline "      $($contador_passo_atv):"
                                                    Write-Host -NoNewline " $passo_atv." -ForegroundColor Yellow
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
                                            Write-Host -NoNewline $($global:translations["DPMSODPViewLoginDataScreenN1"]) -ForegroundColor Magenta
                                            Write-Host -NoNewline " $($global:translations["DPMSODPViewLoginDataScreenN2"])" -ForegroundColor White
                                            if($TipoPlanoConta -ne 'VIP') {
                                                Write-Host -NoNewline " / " -ForegroundColor Yellow
                                                Write-Host -NoNewline "(" -ForegroundColor Cyan
                                                Write-Host -NoNewline "-1" -ForegroundColor Red
                                                Write-Host -NoNewline " QTDV" -ForegroundColor Cyan
                                                Write-Host -NoNewline ")" -ForegroundColor Cyan
                                            }  
                                            Write-Host ""  
                                            Write-Host -NoNewline "     [2] - "  -ForegroundColor Yellow
                                            Write-Host $($global:translations["DPMSODPAccessCodeLink"])
                                            Write-Host -NoNewline "     [3] - "  -ForegroundColor Yellow
                                            Write-Host "$($global:translations["DPMSODPAccessAccount"]) $ProdutoSelecionado" 
                                            Write-Host -NoNewline "     [4] - "  -ForegroundColor Yellow
                                            Write-Host $($global:translations["DPMSODPUsageTutorial"]) 
                                            Write-Host -NoNewline "     [5] - "  -ForegroundColor Yellow
                                            Write-Host $($global:translations["DPMSODPAccountVerificationPrint"]) 
                                        } elseif ($CategoriaEscolhida -eq "Softwares e Licenças" -and $MetodoSelecionado -eq "Conta Digital") {
                                            Write-Host -NoNewline "     [1] - "  -ForegroundColor Yellow
                                            Write-Host -NoNewline $($global:translations["DPMSODPViewLoginDataScreenN1"]) -ForegroundColor Magenta
                                            Write-Host -NoNewline " $($global:translations["DPMSODPViewLoginDataScreenN2"])" -ForegroundColor White
                                            if($TipoPlanoConta -ne 'VIP') {
                                                Write-Host -NoNewline " / " -ForegroundColor Yellow
                                                Write-Host -NoNewline "(" -ForegroundColor Cyan
                                                Write-Host -NoNewline "-1" -ForegroundColor Red
                                                Write-Host -NoNewline " QTDV" -ForegroundColor Cyan
                                                Write-Host -NoNewline ")" -ForegroundColor Cyan
                                            }
                                            Write-Host ""  
                                            Write-Host -NoNewline "     [2] - "  -ForegroundColor Yellow
                                            Write-Host -NoNewline "$($global:translations["DPMSODPSelectOptionInstallN1"]) " -ForegroundColor Green
                                            Write-Host -NoNewline "$ProdutoSelecionado" -ForegroundColor Yellow
                                            Write-Host " ($produtoctdigital_ano_produto/$produtoctdigital_versao_disponivel)" -ForegroundColor Cyan
                                            Write-Host -NoNewline "     [3] - "  -ForegroundColor Yellow
                                            Write-Host -NoNewline "$($global:translations["DPMSODPSelectOptionUninstallN2"]) " -ForegroundColor Red
                                            Write-Host -NoNewline "$ProdutoSelecionado" -ForegroundColor Yellow
                                            Write-Host -NoNewline " ($produtoctdigital_ano_produto/$produtoctdigital_versao_disponivel)" -ForegroundColor Cyan
                                            Write-Host -NoNewline " $($global:translations["DPMSODPSimpleCompleteUninstallationN1"])" -ForegroundColor Gray
                                            Write-Host ""
                                            Write-Host -NoNewline "     [4] - "  -ForegroundColor Yellow
                                            Write-Host $($global:translations["DPMSODPAccessCodeLink"])
                                            Write-Host -NoNewline "     [5] - "  -ForegroundColor Yellow
                                            Write-Host "$($global:translations["DPMSODPAccessAccount"]) $ProdutoSelecionado" 
                                            Write-Host -NoNewline "     [6] - "  -ForegroundColor Yellow
                                            Write-Host $($global:translations["DPMSODPUsageTutorial"]) 
                                            Write-Host -NoNewline "     [7] - "  -ForegroundColor Yellow
                                            Write-Host $($global:translations["DPMSODPAccountVerificationPrint"]) 
                                        } elseif ($CategoriaEscolhida -eq "Softwares e Licenças" -and $MetodoSelecionado -eq "Chave/Serial") {
                                            Write-Host -NoNewline "     [1] - "  -ForegroundColor Yellow
                                            Write-Host -NoNewline $($global:translations["DPMSODPViewKeysLoginDataN1"]) -ForegroundColor Magenta
                                            Write-Host -NoNewline " $($global:translations["DPMSODPViewKeysLoginDataN2"])" -ForegroundColor White
                                            if($TipoPlanoConta -ne 'VIP') {
                                                Write-Host -NoNewline " / " -ForegroundColor Yellow
                                                Write-Host -NoNewline "(" -ForegroundColor Cyan
                                                Write-Host -NoNewline "-1" -ForegroundColor Red
                                                Write-Host -NoNewline " QTDV" -ForegroundColor Cyan
                                                Write-Host -NoNewline ")" -ForegroundColor Cyan
                                            }
                                            Write-Host ""
                                            Write-Host -NoNewline "     [2] - "  -ForegroundColor Yellow
                                            Write-Host -NoNewline "$($global:translations["DPMSODPSelectOptionInstallN1"]) " -ForegroundColor Green
                                            Write-Host -NoNewline "$ProdutoSelecionado" -ForegroundColor Yellow
                                            Write-Host " ($produtoctdigital_ano_produto/$produtoctdigital_versao_disponivel)" -ForegroundColor Cyan
                                            Write-Host -NoNewline "     [3] - "  -ForegroundColor Yellow
                                            Write-Host -NoNewline "$($global:translations["DPMSODPSelectOptionUninstallN2"]) " -ForegroundColor Red
                                            Write-Host -NoNewline "$ProdutoSelecionado" -ForegroundColor Yellow
                                            Write-Host -NoNewline " ($produtoctdigital_ano_produto/$produtoctdigital_versao_disponivel)" -ForegroundColor Cyan
                                            Write-Host -NoNewline " $($global:translations["DPMSODPSimpleCompleteUninstallationN1"])" -ForegroundColor Gray
                                            Write-Host ""
                                            Write-Host -NoNewline "     [4] - "  -ForegroundColor Yellow
                                            Write-Host $($global:translations["DPMSODPActivationTutorial"]) 
                                            Write-Host -NoNewline "     [5] - "  -ForegroundColor Yellow
                                            Write-Host $($global:translations["DPMSODPActivationVerificationPrint"]) 
                                        } elseif ($CategoriaEscolhida -eq "Softwares e Licenças" -and $MetodoSelecionado -eq "Pré-Ativado") {
                                            Write-Host -NoNewline "     [1] - " -ForegroundColor Yellow
                                            Write-Host $($global:translations["DPMSODPSelectOptionInstallN1"]) -NoNewline -ForegroundColor Green
                                            Write-Host " $($global:translations["DPMSODPSimpleCompleteUninstallationN2"]) " -NoNewline -ForegroundColor Yellow
                                            Write-Host "$($global:translations["DPMSODPSimpleCompleteUninstallationN3"]) " -NoNewline -ForegroundColor Magenta
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
                                            Write-Host -NoNewline "$($global:translations["DPMSODPSelectOptionInstallN1"]) " -ForegroundColor Green
                                            Write-Host -NoNewline "$ProdutoSelecionado" -ForegroundColor Yellow
                                            Write-Host " ($produtoctdigital_ano_produto/$produtoctdigital_versao_disponivel)" -ForegroundColor Cyan
                                            Write-Host -NoNewline "     [3] - " -ForegroundColor Yellow
                                            Write-Host "$($global:translations["DPMSODPSimpleCompleteUninstallationN3"]) " -NoNewline -ForegroundColor Magenta
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
                                            Write-Host -NoNewline "$($global:translations["DPMSODPSelectOptionUninstallN2"]) " -ForegroundColor Red
                                            Write-Host -NoNewline "$ProdutoSelecionado" -ForegroundColor Yellow
                                            Write-Host -NoNewline " ($produtoctdigital_ano_produto/$produtoctdigital_versao_disponivel)" -ForegroundColor Cyan
                                            Write-Host -NoNewline " $($global:translations["DPMSODPSimpleCompleteUninstallationN1"])" -ForegroundColor Gray
                                            Write-Host ""
                                            Write-Host -NoNewline "     [5] - "  -ForegroundColor Yellow
                                            Write-Host $($global:translations["DPMSODPActivationTutorial"]) 
                                            Write-Host -NoNewline "     [6] - "  -ForegroundColor Yellow
                                            Write-Host $($global:translations["DPMSODPActivationVerificationPrint"]) 
                                        }
                                        Write-Host ""
                                        if ($idiomaSelecionado -eq "pt") { Write-Host -NoNewline "     [D] - "  -ForegroundColor Red } elseif ($idiomaSelecionado -eq "en") { Write-Host -NoNewline "     [L] - "  -ForegroundColor Red } elseif ($idiomaSelecionado -eq "es") { Write-Host -NoNewline "     [C] - "  -ForegroundColor Red }
                                        Write-Host $($global:translations["DOLogoutMenuOption"]) -ForegroundColor Gray
                                        if ($idiomaSelecionado -eq "pt") { Write-Host -NoNewline "     [V] - "  -ForegroundColor Cyan } elseif ($idiomaSelecionado -eq "en") { Write-Host -NoNewline "     [B] - "  -ForegroundColor Cyan } elseif ($idiomaSelecionado -eq "es") { Write-Host -NoNewline "     [V] - "  -ForegroundColor Cyan }
                                        Write-Host $($global:translations["DOGoBackMenuOption"]) -ForegroundColor Gray
                                        Write-Host -NoNewline "     [M] - "  -ForegroundColor Yellow
                                        Write-Host $($global:translations["DOMainMenuOption"]) -ForegroundColor Gray
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
                                            
                                            Write-Host -NoNewline "`r     $($global:translations["DPMCTClosingTimeEndN1"])" -ForegroundColor White
                                            Write-Host -NoNewline " '$etapa' " -ForegroundColor Magenta
                                            Write-Host -NoNewline "$($global:translations["DPMCTStepProcedureN45EIA"]) " -ForegroundColor White
                                            Write-Host -NoNewline "'$nome_produto'" -ForegroundColor Cyan
                                            Write-Host -NoNewline " $($global:translations["DPMCTClosingTimeEndN2"])" -ForegroundColor Red

                                            Write-Host ""
                                            Write-Host ""
                                            
                                            for ($i = $segundos; $i -ge 1; $i--) {
                                                Write-Host -NoNewline "`r     $($global:translations["DPMCTClosingTimeEndN3"])" -ForegroundColor White
                                                Write-Host -NoNewline " $($global:translations["DPMCTStepProcedureN4MDP"]) " -ForegroundColor Cyan
                                                Write-Host -NoNewline "$($global:translations["DPMCTClosingTimeEndN4"]): $i $($global:translations["DPMCTClosingTimeEndN5"])" -ForegroundColor Yellow
                                                Start-Sleep -Seconds 1
                                            }

                                        } else {
                                            for ($i = $segundos; $i -ge 1; $i--) {
                                                Write-Host -NoNewline "`r     $($global:translations["DPMCTHidingAccessDataN1"]): $i $($global:translations["DPMCTClosingTimeEndN5"])" -ForegroundColor Yellow
                                                Start-Sleep -Seconds 1
                                            }

                                            Write-Host "`r     $($global:translations["DPMCTHidingAccessDataN3"])                    " -ForegroundColor Green
                                        }
                                    }


                                    # Exibição inicia o menu do produto 
                                    ExibirMenuProduto
                                   
                                    while ($true) {
                                        
                                        switch ("$CategoriaEscolhida|$MetodoSelecionado") {
                                            "Streaming|Conta Digital" {
                                                $opcao_produto_streamingvpns = Read-Host $($global:translations["DOQuestionSelectOption"])
                                            }
                                            "Streaming|Conta Digital - Pública" {
                                                $opcao_produto_streamingvpns = Read-Host $($global:translations["DOQuestionSelectOption"])
                                            }
                                            "Streaming|Conta Digital - Cookies" {
                                                $opcao_produto_streamingvpns = Read-Host $($global:translations["DOQuestionSelectOption"])
                                            }
                                            "VPNs|Conta Digital" {
                                                $opcao_produto_streamingvpns = Read-Host $($global:translations["DOQuestionSelectOption"])
                                            }
                                            "VPNs|Conta Digital - Pública" {
                                                $opcao_produto_streamingvpns = Read-Host $($global:translations["DOQuestionSelectOption"])
                                            }
                                            "VPNs|Conta Digital - Cookies" {
                                                $opcao_produto_streamingvpns = Read-Host $($global:translations["DOQuestionSelectOption"])
                                            }
                                            "Softwares e Licenças|Conta Digital" {
                                                $opcao_produto_softwarelicenca_contadigital = Read-Host $($global:translations["DOQuestionSelectOption"])
                                            }
                                            "Softwares e Licenças|Chave/Serial" {
                                                $opcao_produto_softwarelicenca_chaveserial = Read-Host $($global:translations["DOQuestionSelectOption"])
                                            }
                                            "Softwares e Licenças|Pré-Ativado" {
                                                $opcao_produto_softwarelicenca_scriptmodding = Read-Host $($global:translations["DOQuestionSelectOption"])
                                            }
                                            default {
                                                Write-Host ""
                                                Write-Host $($global:translations["DPMSODPMMANothingCategoryNoSelection"]) -ForegroundColor Red
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
                                                        Write-Host "$($global:translations["DPMSODPMMANothingQTDVAvailable"]) $ProdutoSelecionado" -ForegroundColor Red
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
                                                    ContagemRegressiva -segundos 15 -etapa $($global:translations["DPMCTStepProcedureN4N5"]) -nome_produto $ProdutoSelecionado

                                                    # Mostra os dados reais apenas se a opção 1 for selecionada
                                                    $mostrarDadosReais = $true
                                                    ExibirMenuProduto -produtoctdigital_usuariodisplay $produtoctdigital_usuariodisplay -produtoctdigital_senhadisplay $produtoctdigital_senhadisplay -produtoctdigital_chavekeysdisplay $produtoctdigital_chavekeysdisplay -revelarDadosAcessoColor Green
                                                
                                                } else {

                                                    Write-Host ""
                                                    Write-Host -NoNewline $($global:translations["DPMCTStepProcedureN3"]) -ForegroundColor Yellow
                                                    Write-Host -NoNewline " '" -ForegroundColor Yellow 
                                                    Write-Host -NoNewline $($global:translations["DPMCTStepProcedureN41EIA"]) -ForegroundColor Yellow 
                                                    Write-Host -NoNewline " $($global:translations["DPMCTStepProcedureN4N5"])" -ForegroundColor Magenta 
                                                    Write-Host -NoNewline "' " -ForegroundColor Yellow
                                                    Write-Host -NoNewline "$($global:translations["DPMCTStepProcedureN45EIA"])" -ForegroundColor Yellow
                                                    Write-Host -NoNewline " '$ProdutoSelecionado'." -ForegroundColor Cyan
                                                    Write-Host ""
                                                    Write-Host -NoNewline $($global:translations["DPMCTStepProcedureN1"]) -ForegroundColor Yellow
                                                    Write-Host -NoNewline " '5 $($global:translations["DPMCTHidingAccessDataN2"])' " -ForegroundColor Green
                                                    Write-Host -NoNewline $($global:translations["DPMCTStepProcedureN2"]) -ForegroundColor Yellow
                                                    Write-Host ""  
                                                    
                                                    Start-Sleep -Seconds 5
                                                    
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

                                                            # Criar o diretório de $pasta_program e pasta_atv_program se não existir

                                                            # Verificar se ambos os caminhos são iguais
                                                            if ($pasta_program -eq $pasta_atv_program) {
                                                                # Se os caminhos forem iguais, verificar se o diretório já existe, e se não existir, criar o diretório
                                                                if (-not (Test-Path $pasta_program)) {
                                                                    New-Item -ItemType Directory -Path $pasta_program | Out-Null
                                                                }
                                                            } else {
                                                                # Se os caminhos forem diferentes, verificar e criar cada diretório individualmente
                                                                if (-not (Test-Path $pasta_program)) {
                                                                    New-Item -ItemType Directory -Path $pasta_program | Out-Null
                                                                }
                                                                if (-not (Test-Path $pasta_atv_program)) {
                                                                    New-Item -ItemType Directory -Path $pasta_atv_program | Out-Null
                                                                }
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

                                                                # Remover o diretório de $pasta_program e pasta_atv_program se não existir

                                                                # Verificar se ambos os caminhos são iguais
                                                                if ($pasta_program -eq $pasta_atv_program) {
                                                                    # Se os caminhos forem iguais, verificar se o diretório já existe, e se não existir, remover o diretório
                                                                    if ((Test-Path $pasta_program)) {
                                                                        Remove-Item $pasta_program -Recurse -Force
                                                                    }
                                                                } else {
                                                                    # Se os caminhos forem diferentes, verificar e remover cada diretório individualmente
                                                                    if ((Test-Path $pasta_program)) {
                                                                        Remove-Item $pasta_program -Recurse -Force
                                                                    }
                                                                    if ((Test-Path $pasta_atv_program)) {
                                                                        Remove-Item $pasta_atv_program -Recurse -Force
                                                                    }
                                                                }

                                                                # Converter o array em uma string separada por nova linha, se desejado
                                                                $produtoctdigital_usuariodisplay = "$resultado_dadosusuario"
                                                                $produtoctdigital_senhadisplay = "$produtoctdigital_senhaassinatura"
                                                                $produtoctdigital_telapinlockdisplay = "$produtoctdigital_telapinlock"
                                                                $produtoctdigital_chavekeysdisplay = "$resultado_chavekeys"

                                                                Show-Process-Produto -UsuarioAtual $usuario_atual -ProdutoSelecionado $ProdutoSelecionado -TipoPlanoConta $TipoPlanoConta -VersaoDisponivel $produtoctdigital_versao_disponivel -MetodoSelecionado $MetodoSelecionado -ProcessosProduto $produtoctdigital_processos_produto -LinksProduto $produtoctdigital_links_produto -LocalizacaoProduto $produtoctdigital_localizacao_produto -InstrucoesAtivacaoProduto $produtoctdigital_instrucoes_usoativacao -EtapaProcesso "Visualizacao"
                                                    
                                                                # Contagem regressiva de 15 segundos antes de voltar ao menu de detalhes do produto
                                                                ContagemRegressiva -segundos 15 -etapa $($global:translations["DPMCTStepProcedureN4N5"]) -nome_produto $ProdutoSelecionado

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
                                                        Write-Host "$($global:translations["DPMSODPMMANothingQTDVAvailable"]) $ProdutoSelecionado" -ForegroundColor Red
                                                        Write-Host ""
                                                        Start-Sleep -Seconds 5

                                                        ExibirMenuProduto
                                                    }

                                                }

                                            } elseif ($MetodoSelecionado -eq "Pré-Ativado") {
                                                
                                                # Pré-Ativado instalar e ativar

                                                if ($TipoPlanoConta -eq "VIP") {
                                                    
                                                    Write-Host ""
                                                    Write-Host -NoNewline $($global:translations["DPMCTStepProcedureN3"]) -ForegroundColor Yellow
                                                    Write-Host -NoNewline " '" -ForegroundColor Yellow 
                                                    Write-Host -NoNewline $($global:translations["DPMCTStepProcedureN41EIA"]) -ForegroundColor Yellow 
                                                    Write-Host -NoNewline " $($global:translations["DPMCTStepProcedureN42EIA"])" -ForegroundColor Green 
                                                    Write-Host -NoNewline " $($global:translations["DPMCTStepProcedureN43EIA"])" -ForegroundColor Yellow
                                                    Write-Host -NoNewline " $($global:translations["DPMCTStepProcedureN44EIA"])" -ForegroundColor Magenta 
                                                    Write-Host -NoNewline "' " -ForegroundColor Yellow
                                                    Write-Host -NoNewline "$($global:translations["DPMCTStepProcedureN45EIA"])" -ForegroundColor Yellow
                                                    Write-Host -NoNewline " '$ProdutoSelecionado'." -ForegroundColor Cyan
                                                    Write-Host ""
                                                    Write-Host -NoNewline $($global:translations["DPMCTStepProcedureN1"]) -ForegroundColor Yellow
                                                    Write-Host -NoNewline " '5 $($global:translations["DPMCTHidingAccessDataN2"])' " -ForegroundColor Green
                                                    Write-Host -NoNewline $($global:translations["DPMCTStepProcedureN2"]) -ForegroundColor Yellow
                                                    Write-Host ""  
                                                    
                                                    Start-Sleep -Seconds 5

                                                    Show-Process-Produto -UsuarioAtual $usuario_atual -ProdutoSelecionado $ProdutoSelecionado -TipoPlanoConta $TipoPlanoConta -VersaoDisponivel $produtoctdigital_versao_disponivel -MetodoSelecionado $MetodoSelecionado -ProcessosProduto $produtoctdigital_processos_produto -LinksProduto $produtoctdigital_links_produto -LocalizacaoProduto $produtoctdigital_localizacao_produto -InstrucoesAtivacaoProduto $produtoctdigital_instrucoes_usoativacao -EtapaProcesso "Instalacao/Ativação"
                                                    
                                                    # Contagem regressiva de 15 segundos antes de voltar ao menu de detalhes do produto
                                                    ContagemRegressiva -segundos 15 -etapa $($global:translations["DPMCTStepProcedureN4N3"]) -nome_produto $ProdutoSelecionado

                                                    ExibirMenuProduto

                                                } else {

                                                    $qtdvValuesAtualizado = QTDV-Individual-Select-MenuOption -option "1" -qtdvIndividualValues $qtdvIndividualValues

                                                    if ($qtdvValuesAtualizado) {

                                                        $individualValues = $qtdvValuesAtualizado.Individual
                                                        $totalValues = $qtdvValuesAtualizado.Total

                                                        Update-QTDVIndividualMenu -qtdvIndividualTotal $($individualValues.qtdv_valor_atual) -silent 
                                                        Update-QTDVInMenu -qtdvTotal $($totalValues.qtdv_valor_atual) -qtdvUtilizado $($totalValues.qtdv_valor_utilizado) -silent
                                                        
                                                        Write-Host ""
                                                        Write-Host -NoNewline $($global:translations["DPMCTStepProcedureN3"]) -ForegroundColor Yellow
                                                        Write-Host -NoNewline " '" -ForegroundColor Yellow 
                                                        Write-Host -NoNewline $($global:translations["DPMCTClosingTimeEndN1"]) -ForegroundColor Yellow 
                                                        Write-Host -NoNewline " $($global:translations["DPMCTStepProcedureN4N1"])" -ForegroundColor Green 
                                                        Write-Host -NoNewline " $($global:translations["DPMCTStepProcedureN43EIA"])" -ForegroundColor Yellow
                                                        Write-Host -NoNewline " $($global:translations["DPMCTStepProcedureN44EIA"])" -ForegroundColor Magenta 
                                                        Write-Host -NoNewline "' " -ForegroundColor Yellow
                                                        Write-Host -NoNewline $($global:translations["DPMCTStepProcedureN45EIA"]) -ForegroundColor Yellow
                                                        Write-Host -NoNewline " '$ProdutoSelecionado'." -ForegroundColor Cyan
                                                        Write-Host ""
                                                        Write-Host -NoNewline $($global:translations["DPMCTStepProcedureN1"]) -ForegroundColor Yellow
                                                        Write-Host -NoNewline " '5 $($global:translations["DPMCTHidingAccessDataN2"])' " -ForegroundColor Green
                                                        Write-Host -NoNewline "$($global:translations["DPMCTStepProcedureN2"])..." -ForegroundColor Yellow
                                                        Write-Host "" 
                                                        
                                                        Start-Sleep -Seconds 5 

                                                        Show-Process-Produto -UsuarioAtual $usuario_atual -ProdutoSelecionado $ProdutoSelecionado -TipoPlanoConta $TipoPlanoConta -VersaoDisponivel $produtoctdigital_versao_disponivel -MetodoSelecionado $MetodoSelecionado -ProcessosProduto $produtoctdigital_processos_produto -LinksProduto $produtoctdigital_links_produto -LocalizacaoProduto $produtoctdigital_localizacao_produto -InstrucoesAtivacaoProduto $produtoctdigital_instrucoes_usoativacao -EtapaProcesso "Instalacao/Ativação"
                                                    
                                                        # Contagem regressiva de 15 segundos antes de voltar ao menu de detalhes do produto
                                                        ContagemRegressiva -segundos 15 -etapa $($global:translations["DPMCTStepProcedureN4N3"]) -nome_produto $ProdutoSelecionado

                                                        ExibirMenuProduto
                    
                                                    } else {
                                                    
                                                        Write-Host ""
                                                        Write-Host "$($global:translations["DPMSODPMMANothingQTDVAvailable"]) $ProdutoSelecionado" -ForegroundColor Red
                                                        Write-Host ""

                                                        Start-Sleep -Seconds 5

                                                        ExibirMenuProduto
                                                    }

                                                }

                                            } else {
                                                
                                                Write-Host ""
                                                Write-Host "$ProdutoSelecionado $($global:translations["DPMSODPMMANothingDataAccess"])" -ForegroundColor Red
                                                Write-Host ""

                                                Start-Sleep -Seconds 5

                                                ExibirMenuProduto
                                            }


                                        } elseif ($opcao_produto_softwarelicenca_chaveserial -match '^\d+$' -or $opcao_produto_softwarelicenca_scriptmodding -match '^\d+$' -and $opcao_produto_softwarelicenca_chaveserial -eq "2" -or $opcao_produto_softwarelicenca_scriptmodding -eq "2") {
                                            
                                            # instalação de chaveserial, Pré-Ativado

                                            if ($MetodoSelecionado -eq "Chave/Serial") {
                                                    
                                                Write-Host ""
                                                Write-Host -NoNewline $($global:translations["DPMCTStepProcedureN3"]) -ForegroundColor Yellow
                                                Write-Host -NoNewline " $($global:translations["DPMCTStepProcedureN4EI"]) " -ForegroundColor Green
                                                Write-Host -NoNewline $($global:translations["DPMCTStepProcedureN45EIA"]) -ForegroundColor Yellow
                                                Write-Host -NoNewline " '$ProdutoSelecionado'. " -ForegroundColor Cyan
                                                Write-Host ""
                                                Write-Host -NoNewline $($global:translations["DPMCTStepProcedureN1"]) -ForegroundColor Yellow
                                                Write-Host -NoNewline " '5 $($global:translations["DPMCTHidingAccessDataN2"])' " -ForegroundColor Green
                                                Write-Host -NoNewline $($global:translations["DPMCTStepProcedureN2"]) -ForegroundColor Yellow
                                                Write-Host ""

                                                Start-Sleep -Seconds 5
                 
                                                Show-Process-Produto -UsuarioAtual $usuario_atual -ProdutoSelecionado $ProdutoSelecionado -TipoPlanoConta $TipoPlanoConta -VersaoDisponivel $produtoctdigital_versao_disponivel -MetodoSelecionado $MetodoSelecionado -ProcessosProduto $produtoctdigital_processos_produto -LinksProduto $produtoctdigital_links_produto -LocalizacaoProduto $produtoctdigital_localizacao_produto -InstrucoesAtivacaoProduto $produtoctdigital_instrucoes_usoativacao -EtapaProcesso "Instalacao"
                                                    
                                                # Contagem regressiva de 15 segundos antes de voltar ao menu de detalhes do produto
                                                ContagemRegressiva -segundos 15 -etapa $($global:translations["DPMCTStepProcedureN4N1"]) -nome_produto $ProdutoSelecionado

                                                ExibirMenuProduto

                                            } elseif ($MetodoSelecionado -eq "Pré-Ativado") {

                                                Write-Host ""
                                                Write-Host -NoNewline $($global:translations["DPMCTStepProcedureN3"]) -ForegroundColor Yellow
                                                Write-Host -NoNewline " $($global:translations["DPMCTStepProcedureN4EI"]) " -ForegroundColor Green
                                                Write-Host -NoNewline $($global:translations["DPMCTStepProcedureN45EIA"]) -ForegroundColor Yellow
                                                Write-Host -NoNewline " '$ProdutoSelecionado'. " -ForegroundColor Cyan
                                                Write-Host ""
                                                Write-Host -NoNewline $($global:translations["DPMCTStepProcedureN1"]) -ForegroundColor Yellow
                                                Write-Host -NoNewline " '5 $($global:translations["DPMCTHidingAccessDataN2"])' " -ForegroundColor Green
                                                Write-Host -NoNewline $($global:translations["DPMCTStepProcedureN2"]) -ForegroundColor Yellow
                                                Write-Host "" 

                                                Start-Sleep -Seconds 5
                                                
                                                Show-Process-Produto -UsuarioAtual $usuario_atual -ProdutoSelecionado $ProdutoSelecionado -TipoPlanoConta $TipoPlanoConta -VersaoDisponivel $produtoctdigital_versao_disponivel -MetodoSelecionado $MetodoSelecionado -ProcessosProduto $produtoctdigital_processos_produto -LinksProduto $produtoctdigital_links_produto -LocalizacaoProduto $produtoctdigital_localizacao_produto -InstrucoesAtivacaoProduto $produtoctdigital_instrucoes_usoativacao -EtapaProcesso "Instalacao"
                                                    
                                                # Contagem regressiva de 15 segundos antes de voltar ao menu de detalhes do produto
                                                ContagemRegressiva -segundos 15 -etapa $($global:translations["DPMCTStepProcedureN42EIA"]) -nome_produto $ProdutoSelecionado

                                                ExibirMenuProduto

                                            } else {

                                                Write-Host ""
                                                Write-Host "$ProdutoSelecionado $($global:translations["DPMSODPMMANothingDataAccess"])" -ForegroundColor Red
                                                Write-Host ""
                                                Start-Sleep -Seconds 5

                                                ExibirMenuProduto
                                            }

                                        } elseif ($opcao_produto_softwarelicenca_scriptmodding -match '^\d+$' -and $opcao_produto_softwarelicenca_scriptmodding -eq "3") {
                                            
                                            # ativação Pré-Ativado

                                            if ($TipoPlanoConta -eq "VIP") {
                                                
                                                Write-Host ""
                                                Write-Host -NoNewline $($global:translations["DPMCTStepProcedureN3"]) -ForegroundColor Yellow
                                                Write-Host -NoNewline " $($global:translations["DPMCTStepProcedureN4EA"]) " -ForegroundColor Magenta 
                                                Write-Host -NoNewline $($global:translations["DPMCTStepProcedureN45EIA"]) -ForegroundColor Yellow
                                                Write-Host -NoNewline " '$ProdutoSelecionado'. " -ForegroundColor Cyan
                                                Write-Host ""
                                                Write-Host -NoNewline $($global:translations["DPMCTStepProcedureN1"]) -ForegroundColor Yellow
                                                Write-Host -NoNewline " '5 $($global:translations["DPMCTHidingAccessDataN2"])' " -ForegroundColor Green
                                                Write-Host -NoNewline "$($global:translations["DPMCTStepProcedureN2"])" -ForegroundColor Yellow
                                                Write-Host "" 

                                                Start-Sleep -Seconds

                                                Show-Process-Produto -UsuarioAtual $usuario_atual -ProdutoSelecionado $ProdutoSelecionado -TipoPlanoConta $TipoPlanoConta -VersaoDisponivel $produtoctdigital_versao_disponivel -MetodoSelecionado $MetodoSelecionado -ProcessosProduto $produtoctdigital_processos_produto -LinksProduto $produtoctdigital_links_produto -LocalizacaoProduto $produtoctdigital_localizacao_produto -InstrucoesAtivacaoProduto $produtoctdigital_instrucoes_usoativacao -EtapaProcesso "Ativacao"
                                                    
                                                # Contagem regressiva de 15 segundos antes de voltar ao menu de detalhes do produto
                                                ContagemRegressiva -segundos 15 -etapa $($global:translations["5DPMCTStepProcedureN4N2"]) -nome_produto $ProdutoSelecionado

                                                ExibirMenuProduto
                                            
                                            } else {

                                                $qtdvValuesAtualizado = QTDV-Individual-Select-MenuOption -option "3" -qtdvIndividualValues $qtdvIndividualValues
                                                
                                                if ($qtdvValuesAtualizado) {
                                                    
                                                    $individualValues = $qtdvValuesAtualizado.Individual
                                                    $totalValues = $qtdvValuesAtualizado.Total

                                                    Update-QTDVIndividualMenu -qtdvIndividualTotal $($individualValues.qtdv_valor_atual) -silent
                                                    Update-QTDVInMenu -qtdvTotal $($totalValues.qtdv_valor_atual) -qtdvUtilizado $($totalValues.qtdv_valor_utilizado) -silent
                                                    
                                                    Write-Host ""
                                                    Write-Host -NoNewline $($global:translations["DPMCTStepProcedureN3"]) -ForegroundColor Yellow
                                                    Write-Host -NoNewline " $($global:translations["DPMCTStepProcedureN4EA"]) " -ForegroundColor Magenta 
                                                    Write-Host -NoNewline $($global:translations["DPMCTStepProcedureN45EIA"]) -ForegroundColor Yellow
                                                    Write-Host -NoNewline " '$ProdutoSelecionado'. " -ForegroundColor Cyan
                                                    Write-Host ""
                                                    Write-Host -NoNewline $($global:translations["DPMCTStepProcedureN1"]) -ForegroundColor Yellow
                                                    Write-Host -NoNewline " '5 $($global:translations["DPMCTHidingAccessDataN2"])' " -ForegroundColor Green
                                                    Write-Host -NoNewline $($global:translations["DPMCTStepProcedureN2"]) -ForegroundColor Yellow
                                                    Write-Host "" 

                                                    Start-Sleep -Seconds 5

                                                    Show-Process-Produto -UsuarioAtual $usuario_atual -ProdutoSelecionado $ProdutoSelecionado -TipoPlanoConta $TipoPlanoConta -VersaoDisponivel $produtoctdigital_versao_disponivel -MetodoSelecionado $MetodoSelecionado -ProcessosProduto $produtoctdigital_processos_produto -LinksProduto $produtoctdigital_links_produto -LocalizacaoProduto $produtoctdigital_localizacao_produto -InstrucoesAtivacaoProduto $produtoctdigital_instrucoes_usoativacao -EtapaProcesso "Ativacao"

                                                    # Contagem regressiva de 5 segundos antes de ocultar os dados
                                                    ContagemRegressiva -segundos 15 -etapa $($global:translations["5DPMCTStepProcedureN4N2"]) -nome_produto $ProdutoSelecionado
                              
                                                    ExibirMenuProduto

                                                } else {

                                                    Write-Host ""
                                                    Write-Host "$($global:translations["DPMSODPMMANothingQTDVAvailable"]) $ProdutoSelecionado" -ForegroundColor Red
                                                    Write-Host ""

                                                    Start-Sleep -Seconds 5

                                                    ExibirMenuProduto
                                                }

                                            }

                                        } elseif ($opcao_produto_softwarelicenca_chaveserial -match '^\d+$' -or $opcao_produto_softwarelicenca_scriptmodding -match '^\d+$' -and $opcao_produto_softwarelicenca_chaveserial -eq "3" -or $opcao_produto_softwarelicenca_scriptmodding -eq "4") {
                                            
                                            # desinstalação chave/serial e Pré-Ativado

                                            if ($MetodoSelecionado -eq "Chave/Serial") {
                                                
                                                Write-Host ""
                                                Write-Host -NoNewline $($global:translations["DPMCTStepProcedureN3"]) -ForegroundColor Yellow
                                                Write-Host -NoNewline " $($global:translations["DPMCTStepProcedureN4ED"]) " -ForegroundColor Red
                                                Write-Host -NoNewline $($global:translations["DPMCTStepProcedureN45EIA"]) -ForegroundColor Yellow
                                                Write-Host -NoNewline " '$ProdutoSelecionado'. " -ForegroundColor Cyan
                                                Write-Host ""
                                                Write-Host -NoNewline $($global:translations["DPMCTStepProcedureN1"]) -ForegroundColor Yellow
                                                Write-Host -NoNewline " '5 $($global:translations["DPMCTHidingAccessDataN2"])' " -ForegroundColor Green
                                                Write-Host -NoNewline $($global:translations["DPMCTStepProcedureN2"]) -ForegroundColor Yellow
                                                Write-Host "" 

                                                Start-Sleep -Seconds 5

                                                Show-Process-Produto -UsuarioAtual $usuario_atual -ProdutoSelecionado $ProdutoSelecionado -TipoPlanoConta $TipoPlanoConta -VersaoDisponivel $produtoctdigital_versao_disponivel -MetodoSelecionado $MetodoSelecionado -ProcessosProduto $produtoctdigital_processos_produto -LinksProduto $produtoctdigital_links_produto -LocalizacaoProduto $produtoctdigital_localizacao_produto -InstrucoesAtivacaoProduto $produtoctdigital_instrucoes_usoativacao -EtapaProcesso "Desinstalacao"
                                                    
                                                # Contagem regressiva de 15 segundos antes de voltar ao menu de detalhes do produto
                                                ContagemRegressiva -segundos 15 -etapa $($global:translations["DPMCTStepProcedureN4N4"]) -nome_produto $ProdutoSelecionado

                                                ExibirMenuProduto

                                            } elseif ($MetodoSelecionado -eq "Pré-Ativado") {
                                                
                                                Write-Host ""
                                                Write-Host -NoNewline $($global:translations["DPMCTStepProcedureN3"]) -ForegroundColor Yellow
                                                Write-Host -NoNewline " $($global:translations["DPMCTStepProcedureN4ED"]) " -ForegroundColor Red
                                                Write-Host -NoNewline $($global:translations["DPMCTStepProcedureN45EIA"]) -ForegroundColor Yellow
                                                Write-Host -NoNewline " '$ProdutoSelecionado'. " -ForegroundColor Cyan
                                                Write-Host ""
                                                Write-Host -NoNewline $($global:translations["DPMCTStepProcedureN1"]) -ForegroundColor Yellow
                                                Write-Host -NoNewline " '5 $($global:translations["DPMCTHidingAccessDataN2"])' " -ForegroundColor Green
                                                Write-Host -NoNewline $($global:translations["DPMCTStepProcedureN2"]) -ForegroundColor Yellow
                                                Write-Host "" 

                                                Start-Sleep -Seconds 5

                                                Show-Process-Produto -UsuarioAtual $usuario_atual -ProdutoSelecionado $ProdutoSelecionado -TipoPlanoConta $TipoPlanoConta -VersaoDisponivel $produtoctdigital_versao_disponivel -MetodoSelecionado $MetodoSelecionado -ProcessosProduto $produtoctdigital_processos_produto -LinksProduto $produtoctdigital_links_produto -LocalizacaoProduto $produtoctdigital_localizacao_produto -InstrucoesAtivacaoProduto $produtoctdigital_instrucoes_usoativacao -EtapaProcesso "Desinstalacao"
                                                    
                                                # Contagem regressiva de 15 segundos antes de voltar ao menu de detalhes do produto
                                                ContagemRegressiva -segundos 15 -etapa "DESINSTALAÇÃO" -nome_produto $ProdutoSelecionado

                                                ExibirMenuProduto

                                            } else {

                                                Write-Host ""
                                                Write-Host "$ProdutoSelecionado $($global:translations["DPMSODPMMANothingDataAccess"])" -ForegroundColor Red
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
                                                Write-Host "$ProdutoSelecionado $($global:translations["DPMSODPMMANothingLinkCodeActivate"])" -ForegroundColor Red
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
                                                Write-Host "$ProdutoSelecionado $($global:translations["DPMSODPMMANothingLinkAccessLogin"])" -ForegroundColor Red
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
                                                    Write-Host "$ProdutoSelecionado $($global:translations["DPMSODPMMANothingLinkTutorialActivate"])" -ForegroundColor Red
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
                                                    Write-Host "$ProdutoSelecionado $($global:translations["DPMSODPMMANothingLinkTutorialUse"])" -ForegroundColor Red
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
                                                Write-Host "$ProdutoSelecionado $($global:translations["DPMSODPMMANothingLinkPrintVerification"])" -ForegroundColor Red
                                                Write-Host ""
                                                Start-Sleep -Seconds 5

                                                ExibirMenuProduto
                                            }

                                        # Correção de Ajuste # 3 (Erro)
                                        # tirei o $opcoes_default_menu -contains e deixei apenas -eq

                                        } elseif (($idiomaSelecionado -eq "pt" -and $opcoes_default_menu -eq "D") -or ($idiomaSelecionado -eq "en" -and $opcoes_default_menu -eq "L") -or ($idiomaSelecionado -eq "es" -and $opcoes_default_menu -eq "C")) {
                                            Fazer-Login -LoginStatus $false
                                        } elseif (($idiomaSelecionado -eq "pt" -and $opcoes_default_menu -eq "V") -or ($idiomaSelecionado -eq "en" -and $opcoes_default_menu -eq "B") -or ($idiomaSelecionado -eq "es" -and $opcoes_default_menu -eq "V")) {
                                            Show-Produtos-Metodos -UsuarioAtual $usuario_atual -SenhaAtual $senha_atual -CategoriaEscolhida $CategoriaEscolhida -ProdutoSelecionado $produtoSelecionado -TipoPlanoConta $TipoPlanoConta -DataAtual $DataAtual -DataTermino $DataTermino -ProdutosMetodoLiberado $ProdutosMetodoLiberado
                                        } elseif ($opcoes_default_menu -contains "M" -or $opcoes_default_menu -eq "M") {
                                            Show-Menu -LoginStatus $true -UsuarioAtual $usuario_atual -SenhaAtual $senha_atual -TipoPlanoConta $plano_conta_atual
                                        } else {
                                            
                                            Write-Host ""
                                            Write-Host $($global:translations["DOInvalidOptionN1"]) -ForegroundColor Red
                                            Write-Host ""
                                            Start-Sleep -Seconds 3

                                            ExibirMenuProduto

                                            # Se nenhuma opção válida for selecionada, mostra o menu atual novamente
                                            # Show-Produtos-Metodos -UsuarioAtual $usuario_atual -SenhaAtual $senha_atual -ProdutoSelecionado $produtoSelecionado
                                        }

                                    }

                                } else {
                                    Write-Host ""
                                    Write-Host "     $($global:translations["DPMSODPMMANotMetCondition"]) 'tempo_espera_entrega' e 'status_disponibilidade_entrega'."
                                    Write-Host ""
                                }

                            }

                        }  
                    } else {
                        Write-Host $($global:translations["DPMSODPMMAProductNotAvailableAccount"]) -ForegroundColor Red
                        Write-Host ""

                        Start-Sleep -Seconds 3
                        Show-Produtos-Metodos -UsuarioAtual $usuario_atual -SenhaAtual $senha_atual -CategoriaEscolhida $CategoriaEscolhida -ProdutoSelecionado $produtoSelecionado -TipoPlanoConta $TipoPlanoConta -DataAtual $DataAtual -DataTermino $DataTermino -ProdutosMetodoLiberado $ProdutosMetodoLiberado
                    }
                } else {
                    Write-Host "     $($global:translations["DMAAlertMessageUserNotFound"])" -ForegroundColor Red
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

    # Update-Title-WindowMenu -menuKey $($global:translations["DPMDetailsProductsMenu"]) # Atualiza o título para o menu principal

    # Carrega a linguagem de tradução / configuração atual
    $idiomaSelecionado = $global:language = Get-LanguageConfig
    
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
        $etapaInstalacaoTexto = "$($global:translations["PPMISStepInstall"]) $($produto_formatado)"
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
                    Write-Host -NoNewline "      $($global:translations["PPMVISNeedInstalledYourComputer"])" -ForegroundColor Yellow
                    Write-Host -NoNewline " '$nome_programa $versao_disponivel' " -ForegroundColor Cyan
                    Write-Host ""  
                    Write-Host -NoNewline "      $($global:translations["PPMVISSoNeedInstalled"])" -ForegroundColor Yellow
                    Write-Host -NoNewline " $($global:translations["PPMVISLoginDetails"]) " -ForegroundColor Cyan
                    Write-Host -NoNewline "$($global:translations["PPMVISAvailableViewingCompatible"])" -ForegroundColor Yellow
                    Write-Host ""
                    Write-Host -NoNewline "      $($global:translations["PPMISTheProgram"])" -ForegroundColor Yellow
                    Write-Host -NoNewline " '$nome_programa $versao_disponivel' " -ForegroundColor Cyan
                    Write-Host -NoNewline "$($global:translations["PPMISInstalledYourComputer"])" -ForegroundColor Yellow
                    Write-Host ""
                    Write-Host ""
                    Write-Host "      $($global:translations["PPMISInstalledProcessInstall"]) $nome_programa $($global:translations["PPMISInstalledCancell"])" -ForegroundColor Red
                    Write-Host ""

                } else {

                    Write-Host ""
                    Write-Host "     ================================================================================================================" -ForegroundColor Cyan
                    Write-Host ""
                    Write-Host -NoNewline "      $($global:translations["PPMISTheProgram"])" -ForegroundColor Yellow
                    Write-Host -NoNewline " '$nome_programa $versao_disponivel' " -ForegroundColor Cyan
                    Write-Host -NoNewline "$($global:translations["PPMISInstalledYourComputer"])" -ForegroundColor Yellow
                    Write-Host ""
                    Write-Host ""
                    Write-Host "      $($global:translations["PPMISInstalledProcessInstall"]) $nome_programa $($global:translations["PPMISInstalledCancell"])" -ForegroundColor Red
                    Write-Host ""

                }
                
                if ( $EtapaInstAtv ) { Start-Sleep -Seconds 5 }

            } else {
                
                if ($MetodoSelecionado -eq "Chave/Serial") {

                    Write-Host ""
                    Write-Host "     ================================================================================================================" -ForegroundColor Cyan
                    Write-Host ""
                    Write-Host -NoNewline "      $($global:translations["PPMVISNeedInstalledYourComputer"])" -ForegroundColor Yellow
                    Write-Host -NoNewline " '$nome_programa $versao_disponivel' " -ForegroundColor Cyan
                    Write-Host ""
                    Write-Host -NoNewline "      $($global:translations["PPMVISSoNeedInstalled"])" -ForegroundColor Yellow
                    Write-Host -NoNewline " $($global:translations["PPMVISLoginDetails"]) " -ForegroundColor Cyan
                    Write-Host -NoNewline "$($global:translations["PPMVISAvailableViewingCompatible"])" -ForegroundColor Yellow
                    Write-Host ""
                    Write-Host -NoNewline "      $($global:translations["PPMISTheProgram"])" -ForegroundColor Yellow
                    Write-Host -NoNewline " '$nome_programa $programVersionAnterior' " -ForegroundColor Cyan
                    Write-Host -NoNewline "$($global:translations["PPMISInstalledYourComputer"])" -ForegroundColor Yellow
                    Write-Host ""
                    Write-Host "      $($global:translations["PPMISInstalledProcessInstall"]) $nome_programa $($global:translations["PPMISInstalledCancell"])" -ForegroundColor Red
                    Write-Host ""
                    Write-Host -NoNewline "      $($global:translations["PPMVISUninstallVersionPrevious"])" -ForegroundColor Yellow
                    Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                    Write-Host ""

                } else {

                    Write-Host ""
                    Write-Host "     ================================================================================================================" -ForegroundColor Cyan
                    Write-Host ""
                    Write-Host -NoNewline "      $($global:translations["PPMISTheProgram"])" -ForegroundColor Yellow
                    Write-Host -NoNewline " '$nome_programa $programVersionAnterior' " -ForegroundColor Cyan
                    Write-Host -NoNewline "$($global:translations["PPMISInstalledYourComputer"])" -ForegroundColor Yellow
                    Write-Host ""
                    Write-Host -NoNewline "      $($global:translations["PPMISUninstalledVersionLast"])" -ForegroundColor Yellow
                    Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                    Write-Host -NoNewline "$($global:translations["PPMISInstalledVersionCurrent"])" -ForegroundColor Yellow
                    Write-Host -NoNewline " '$versao_disponivel'." -ForegroundColor Cyan
                    Write-Host ""
                    Write-Host ""
                    Write-Host "      $($global:translations["PPMISInstalledProcessInstall"]) $nome_programa $($global:translations["PPMISInstalledCancell"])" -ForegroundColor Red
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
                Write-Host -NoNewline "      $($global:translations["PPMISTheProcess"]) $($processNames -join ', ') $($global:translations["PPMISIsExecuted"])" -ForegroundColor Yellow
                Write-Host -NoNewline " $($global:translations["PPMISClosingProcessStartInstall"])" -ForegroundColor Red
                Write-Host -NoNewline " '$nome_programa $versao_disponivel' " -ForegroundColor Cyan
                Write-Host -NoNewline "$($global:translations["PPMISYourComputer"])" -ForegroundColor Red
                Write-Host ""
                Write-Host ""
                           

            } else {

                Write-Host ""
                Write-Host "     ================================================================================================================" -ForegroundColor Green
                Write-Host ""
                Write-Host -NoNewline "      $($global:translations["PPMISPreparingDispStartInstall"])" -ForegroundColor Yellow
                Write-Host -NoNewline " '$nome_programa $versao_disponivel' " -ForegroundColor Cyan
                Write-Host -NoNewline "$($global:translations["PPMISYourComputer"])" -ForegroundColor Yellow
                Write-Host ""
                Write-Host ""
            }
            
            $opcao_instalacao = Read-Host "      $($global:translations["PPMISWishInstallQuestion"]) $nome_programa $($global:translations["PPMISYourComputerInstallQuestion"])"

            if (($idiomaSelecionado -eq "pt" -and $opcao_instalacao -eq "S") -or ($idiomaSelecionado -eq "en" -and $opcao_instalacao -eq "Y") -or ($idiomaSelecionado -eq "es" -and $opcao_instalacao -eq "S")) {                              

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
                        Write-Host "      $($global:translations["PPMISTheProcess"]) $($processNames -join ', ') $($global:translations["PPMISIsExecuted"])" -ForegroundColor Yellow
                        Write-Host "      $($global:translations["PPMISClosingProcessStartInstall"])" -ForegroundColor Green
                            
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
                            Write-Host -NoNewline "      $($global:translations["PPMISOfficialOfInstall"])" -ForegroundColor Yellow
                            Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                            Write-Host -NoNewline "$($global:translations["PPMISStartingStep"])" -ForegroundColor Yellow
                            Write-Host ""
                            Write-Host "      $($global:translations["PPMISOpeningInstall"]) $nome_programa..."   -ForegroundColor Green
                            
                            Start-Sleep -Seconds 5
                            
                            Write-Host ""
                            Write-Host -NoNewline "      $($global:translations["PPPMISWaitProcessInstall"])" -ForegroundColor Yellow
                            Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                            Write-Host -NoNewline "$($global:translations["PPMISFinishingStep"])" -ForegroundColor Yellow
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
                                    Write-Host "      $($global:translations["PPMISSetupInstallOf"]) $nome_programa $($global:translations["PPMISNotFoundN1"])" -ForegroundColor Yellow
                                    Write-Host "      $($global:translations["PPMISFailInstallOf"]) $nome_programa..." -ForegroundColor Red
                                    Write-Host ""
                                }

                            } else {
                                
                                # EXE:
                                # Incia e depois Remove o setup do instalador do programa, e aguarda sua conclusão.
                                
                                Start-Process -FilePath $destino -PassThru -Wait

                            }
                                
                            Write-Host ""
                            Write-Host "      $($global:translations["PPMISConfirmedOf"]) $nome_programa $($global:translations["PPMISInstallAndVerify"])" -ForegroundColor Yellow
                            Write-Host ""
                            
                            $instalacao_completa = Read-Host "      $($global:translations["PPMISVerifyToInstall"]) $nome_programa ? $($global:translations["PPMUSYesOrNot"])"
                            
                            Write-Host ""

                            if(($idiomaSelecionado -eq "pt" -and $instalacao_completa -eq "S" -or $instalacao_completa -eq "N") -or ($idiomaSelecionado -eq "en" -and $instalacao_completa -eq "Y" -or $instalacao_completa -eq "N") -or ($idiomaSelecionado -eq "es" -and $instalacao_completa -eq "S" -or $instalacao_completa -eq "N")){

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
                                                
                                    Write-Host "      $($global:translations["PPMISInstallOf"]) $nome_programa $($global:translations["PPMISInstallSuccefullFinish"])" -ForegroundColor Green
                                    Write-Host ""
                                                
                                    # Remove o setup de instalação
                                    Remove-Item $destino -Force

                                    $opcao_verficar_instalacao = Read-Host "      $($global:translations["PPMISStartingOf"]) $nome_programa $($global:translations["PPMISConfirmYourInstall"])"
                                        
                                    Write-Host ""
                                                    
                                    $processesRunning = CheckProcessesRunning
                                                    
                                    $processNames = $processesRunning | ForEach-Object { $_.Name }

                                    foreach ($processName in $processNames) {
                                        $process = Get-Process -Name $processName
                                        Stop-Process -Id $process.Id -Force
                                    }

                                    if (($idiomaSelecionado -eq "pt" -and $opcao_verficar_instalacao -eq "S") -or ($idiomaSelecionado -eq "en" -and $opcao_verficar_instalacao -eq "Y") -or ($idiomaSelecionado -eq "es" -and $opcao_verficar_instalacao -eq "S")) {

                                        if (Test-Path $progam_folder) {

                                            Start-Process -FilePath $program_exe -PassThru

                                            Start-Sleep -Seconds 10

                                            Write-Host ""
                                            Write-Host -NoNewline "      $($global:translations["PPMISWaitingProcess"])" -ForegroundColor Yellow
                                            Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                                            Write-Host -NoNewline "$($global:translations["PPMISOfFinishing"])" -ForegroundColor Yellow
                                            Write-Host ""

                                            function showAfterStartProgram {

                                                if ($MetodoSelecionado -eq "Chave/Serial") {

                                                    #Stop-Process -Id $process.Id
                                                    
                                                    Write-Host "      $($global:translations["PPMISProcessInsallFinishing"])" -ForegroundColor Yellow
                                                    Write-Host ""
                                                    Write-Host -NoNewline "      $($global:translations["PPMISStartingStepOff"])" -ForegroundColor Yellow 
                                                    Write-Host -NoNewline " $($global:translations["PPMVISStepView"]) " -ForegroundColor Magenta
                                                    Write-Host -NoNewline "$($global:translations["PPMVISToViewThe"])" -ForegroundColor Yellow
                                                    Write-Host -NoNewline " $($global:translations["PPMVISLoginDetails"]) " -ForegroundColor Cyan
                                                    Write-Host -NoNewline "$($global:translations["PPMVISOfYou"])" -ForegroundColor Yellow
                                                    Write-Host -NoNewline " '$nome_program'." -ForegroundColor Cyan
                                                    Write-Host ""
                                                    Write-Host ""
                                             
                                                    Set-MpPreference -SubmitSamplesConsent 1

                                                } else {

                                                    #Stop-Process -Id $process.Id
                                                    
                                                    Write-Host "      $($global:translations["PPMISProcessInsallFinishing"])" -ForegroundColor Yellow
                                                    Write-Host ""
                                                    Write-Host -NoNewline "      $($global:translations["PPMISStartingStepOff"])" -ForegroundColor Yellow 
                                                    Write-Host -NoNewline " $($global:translations["PPMISActivateStep"]) " -ForegroundColor Magenta
                                                    Write-Host -NoNewline "$($global:translations["PPMISActivateYour"])" -ForegroundColor Yellow
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
                                                    Write-Host -NoNewline "      $($global:translations["PPMISProcessOf"])" -ForegroundColor Red
                                                    Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                                                    Write-Host -NoNewline "$($global:translations["PPMISNotFoundOrNotExecute"])" -ForegroundColor Red
                                                    Write-Host ""
                                                    Write-Host ""

                                                    if ( $EtapaInstAtv ) { Start-Sleep -Seconds 5 }
                                                } 
                                            }
                                        
                                        } else {
                                            Write-Host ""
                                            Write-Host "      $($global:translations["PPMISInstallFailedOrNotDone"])" -ForegroundColor Red
                                            Write-Host ""

                                            if ( $EtapaInstAtv ) { Start-Sleep -Seconds 5 }
                                        }
                                    } else {

                                        if ($MetodoSelecionado -eq "Chave/Serial") {

                                            Write-Host "      $($global:translations["PPMISProcessInsallFinishing"])" -ForegroundColor Yellow
                                            Write-Host ""
                                            Write-Host -NoNewline "      $($global:translations["PPMISStartingStepOff"])" -ForegroundColor Yellow 
                                            Write-Host -NoNewline " $($global:translations["PPMVISStepView"]) " -ForegroundColor Magenta
                                            Write-Host -NoNewline "$($global:translations["PPMVISToViewThe"])" -ForegroundColor Yellow
                                            Write-Host -NoNewline " $($global:translations["PPMVISLoginDetails"]) " -ForegroundColor Cyan
                                            Write-Host -NoNewline "$($global:translations["PPMVISOfYou"])" -ForegroundColor Yellow
                                            Write-Host -NoNewline " '$nome_program'." -ForegroundColor Cyan
                                            Write-Host ""
                                            Write-Host ""
                                             
                                            Set-MpPreference -SubmitSamplesConsent 1

                                        } else {

                                            Write-Host "      $($global:translations["PPMISProcessInsallFinishing"])" -ForegroundColor Yellow
                                            Write-Host ""
                                            Write-Host -NoNewline "      $($global:translations["PPMISStartingStepOff"])" -ForegroundColor Yellow 
                                            Write-Host -NoNewline " $($global:translations["PPMISActivateStep"]) " -ForegroundColor Magenta
                                            Write-Host -NoNewline "$($global:translations["PPMISActivateYour"])" -ForegroundColor Yellow
                                            Write-Host -NoNewline " '$nome_programa'" -ForegroundColor Cyan
                                            Write-Host ""
                                            Write-Host ""
                                             
                                            Set-MpPreference -SubmitSamplesConsent 1

                                        }

                                        if ( $EtapaInstAtv ) { Start-Sleep -Seconds 5 }
                                    }

                                } else {

                                    Write-Host "      $($global:translations["PPMISInstallFailedOrNotDone"])" -ForegroundColor Red
                                    write-Host -NoNewline "      $($global:translations["PPMISProcessNotAllowedExecute"])" -ForegroundColor Yellow
                                    Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                                    Write-Host -NoNewline "$($global:translations["PPMISWasAlreadyInstallYourComputer"])" -ForegroundColor Yellow
                                    Write-Host ""
                                    Write-Host ""

                                    # Remove o setup de instalação
                                    Remove-Item $destino -Force

                                    Set-MpPreference -SubmitSamplesConsent 1

                                    if ( $EtapaInstAtv ) { Start-Sleep -Seconds 5 }
                                }
                            } else {
                                
                                if ($MetodoSelecionado -eq "Chave/Serial") {

                                    Write-Host "      $($global:translations["PPMISProcessInsallFinishing"])" -ForegroundColor Yellow
                                    Write-Host ""
                                    Write-Host -NoNewline "      $($global:translations["PPMISStartingStepOff"])" -ForegroundColor Yellow 
                                    Write-Host -NoNewline " $($global:translations["PPMVISStepView"]) " -ForegroundColor Magenta
                                    Write-Host -NoNewline "$($global:translations["PPMVISToViewThe"])" -ForegroundColor Yellow
                                    Write-Host -NoNewline " $($global:translations["PPMVISLoginDetails"]) " -ForegroundColor Cyan
                                    Write-Host -NoNewline "$($global:translations["PPMVISOfYou"])" -ForegroundColor Yellow
                                    Write-Host -NoNewline " '$nome_program'." -ForegroundColor Cyan
                                    Write-Host ""
                                    Write-Host ""

                                    Set-MpPreference -SubmitSamplesConsent 1

                                } else {

                                    Write-Host "      $($global:translations["PPMISProcessInsallFinishing"])" -ForegroundColor Yellow 
                                    Write-Host ""
                                    Write-Host -NoNewline "      $($global:translations["PPMISStartingStepOff"])" -ForegroundColor Yellow 
                                    Write-Host -NoNewline " $($global:translations["PPMISActivateStep"]) " -ForegroundColor Magenta
                                    Write-Host -NoNewline "$($global:translations["PPMISActivateYour"])" -ForegroundColor Yellow
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
                            Write-Host -NoNewline "      $($global:translations["PPMISTheInstallerOf"])" -ForegroundColor Red
                            Write-Host -NoNewline " '$nome_programa $versao_disponivel' " -ForegroundColor Cyan
                            Write-Host -NoNewline "$($global:translations["PPMISNotFoundN2"])" -ForegroundColor Red
                            Write-Host ""
                            Write-Host -NoNewline "      $($global:translations["PPMISDownOfficialInstall"])" -ForegroundColor Yellow
                            Write-Host -NoNewline " '$nome_programa $versao_disponivel'." -ForegroundColor Cyan
                            Write-Host ""
                            Write-Host ""
                            Write-Host "      $($global:translations["PPMISWaitingMinutes"])" -ForegroundColor Green
                            Write-Host ""

                            # Baixar o arquivo
                            #$client = New-Object System.Net.WebClient
                            #$client.DownloadFile($url, $destino)

                            try {

                                # Usando Invoke-WebRequest para baixar o arquivo
                                $response = Invoke-WebRequest -Uri "$url" -OutFile "$destino" -ErrorAction Stop 

                                Write-Host ""
                                Write-Host "      $nome_programa $($global:translations["PPMISDownloadSuccefull"])" -ForegroundColor Green
                                Write-Host ""
                               
                            } catch {
                                Write-Host ""
                                Write-Host "      $($global:translations["PPMISErrorInDownload"]) $nome_programa" -ForegroundColor Red
                                Write-Host ""
                            }

                            if (Test-Path $destino) {
                                
                                # Inicia o processo de instação
                                
                                Write-Host ""
                                Write-Host -NoNewline "      $($global:translations["PPMISOfficialOfInstall"])" -ForegroundColor Yellow
                                Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                                Write-Host -NoNewline "$($global:translations["PPMISStartingStep"])" -ForegroundColor Yellow
                                Write-Host ""
                                Write-Host ""
                                Write-Host "      $($global:translations["PPMISOpeningInstall"]) $nome_programa..."   -ForegroundColor Green
                            
                                Start-Sleep -Seconds 5
                            
                                Write-Host ""
                                Write-Host -NoNewline "      $($global:translations["PPPMISWaitProcessInstall"])" -ForegroundColor Yellow
                                Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                                Write-Host -NoNewline "$($global:translations["PPMISFinishingStep"])" -ForegroundColor Yellow
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
                                                Write-Host "      $($global:translations["PPMISSetupInstallOf"]) $nome_programa $($global:translations["PPMISNotFoundN1"])" -ForegroundColor Yellow
                                                Write-Host "      $($global:translations["PPMISFailInstallOf"]) $nome_programa..." -ForegroundColor Red
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
                                            Write-Host "      $($global:translations["PPMISSetupInstallOf"]) $nome_programa $($global:translations["PPMISNotFoundN1"])" -ForegroundColor Yellow
                                            Write-Host "      $($global:translations["PPMISFailInstallOf"]) $nome_programa..." -ForegroundColor Red
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
                                    Write-Host "      $($global:translations["PPMVASInstallationProcessSuccessStarted"])" -ForegroundColor Yellow
                                    Write-Host ""
                                    Write-Host -NoNewline "      $($global:translations["PPMISStartingStepOff"])" -ForegroundColor Yellow 
                                    Write-Host -NoNewline " $($global:translations["PPMVISStepView"]) " -ForegroundColor Magenta
                                    Write-Host -NoNewline "$($global:translations["PPMVISToViewThe"])" -ForegroundColor Yellow
                                    Write-Host -NoNewline " $($global:translations["PPMVISLoginDetails"]) " -ForegroundColor Cyan
                                    Write-Host -NoNewline "$($global:translations["PPMVISOfYou"])" -ForegroundColor Yellow
                                    Write-Host -NoNewline " '$nome_programa'." -ForegroundColor Cyan
                                    Write-Host ""
                                    Write-Host ""

                                    Set-MpPreference -SubmitSamplesConsent 1

                                    if ( $EtapaInstAtv ) { Start-Sleep -Seconds 5 }

                                } else {

                                    # Incia e depois Remove o setup do instalador do programa, e aguarda sua conclusão.
                                
                                    Write-Host ""
                                    Write-Host "      $($global:translations["PPMISConfirmedOf"]) $nome_programa $($global:translations["PPMISInstallAndVerify"])" -ForegroundColor Yellow
                                    Write-Host ""
                            
                                    $instalacao_completa = Read-Host "      $($global:translations["PPMISVerifyToInstall"]) $nome_programa ? $($global:translations["PPMUSYesOrNot"])"
                            
                                    Write-Host ""

                                    if(($idiomaSelecionado -eq "pt" -and $instalacao_completa -eq "S" -or $instalacao_completa -eq "N") -or ($idiomaSelecionado -eq "en" -and $instalacao_completa -eq "Y" -or $instalacao_completa -eq "N") -or ($idiomaSelecionado -eq "es" -and $instalacao_completa -eq "S" -or $instalacao_completa -eq "N")){

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
                                                
                                            Write-Host "      $($global:translations["PPMISInstallOf"]) $nome_programa $($global:translations["PPMISInstallSuccefullFinish"])" -ForegroundColor Green
                                            Write-Host ""
                                        
                                            #$setupPath = Join-Path $local_default $setupEncontrado.Name
                                            # ou
                                            # $setupPath = Join-Path $local_default $nomeArquivo
                                        
                                            # Remove o setup de instalação
                                            Remove-Item $destino -Recurse -Force
                                            # Remove-Item "$setupPath" -Recurse -Force

                                            $opcao_verficar_instalacao = Read-Host "      $($global:translations["PPMISStartingOf"]) $nome_programa $($global:translations["PPMISConfirmYourInstall"])"
                                        
                                            Write-Host ""
                                                    
                                            $processesRunning = CheckProcessesRunning
                                                    
                                            $processNames = $processesRunning | ForEach-Object { $_.Name }

                                            foreach ($processName in $processNames) {
                                                $process = Get-Process -Name $processName
                                                Stop-Process -Id $process.Id -Force
                                            }

                                            if (($idiomaSelecionado -eq "pt" -and $opcao_verficar_instalacao -eq "S") -or ($idiomaSelecionado -eq "en" -and $opcao_verficar_instalacao -eq "Y") -or ($idiomaSelecionado -eq "es" -and $opcao_verficar_instalacao -eq "S")) {
                                                if (Test-Path $progam_folder) {

                                                    Start-Process -FilePath $program_exe -PassThru

                                                    Start-Sleep -Seconds 10

                                                    Write-Host ""
                                                    Write-Host -NoNewline "      $($global:translations["PPMISWaitingProcess"])" -ForegroundColor Yellow
                                                    Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                                                    Write-Host -NoNewline "$($global:translations["PPMISOfFinishing"])" -ForegroundColor Yellow
                                                    Write-Host ""

                                                    function showAfterStartProgram {

                                                        if ($MetodoSelecionado -eq "Chave/Serial") {
                                                        
                                                            #Stop-Process -Id $process.Id

                                                            Write-Host "      $($global:translations["PPMISProcessInsallFinishing"])" -ForegroundColor Yellow
                                                            Write-Host ""
                                                            Write-Host -NoNewline "      $($global:translations["PPMISStartingStepOff"])" -ForegroundColor Yellow 
                                                            Write-Host -NoNewline " $($global:translations["PPMVISStepView"]) " -ForegroundColor Magenta
                                                            Write-Host -NoNewline "$($global:translations["PPMVISToViewThe"])" -ForegroundColor Yellow
                                                            Write-Host -NoNewline " $($global:translations["PPMVISLoginDetails"]) " -ForegroundColor Cyan
                                                            Write-Host -NoNewline "$($global:translations["PPMVISOfYou"])" -ForegroundColor Yellow
                                                            Write-Host -NoNewline " '$nome_programa'." -ForegroundColor Cyan
                                                            Write-Host ""
                                                            Write-Host ""

                                                            Set-MpPreference -SubmitSamplesConsent 1

                                                        } else {
                                                         
                                                            #Stop-Process -Id $process.Id

                                                            Write-Host "      $($global:translations["PPMISProcessInsallFinishing"])" -ForegroundColor Yellow 
                                                            Write-Host ""
                                                            Write-Host -NoNewline "      $($global:translations["PPMISStartingStepOff"])" -ForegroundColor Yellow 
                                                            Write-Host -NoNewline " $($global:translations["PPMISActivateStep"]) " -ForegroundColor Magenta
                                                            Write-Host -NoNewline "$($global:translations["PPMISActivateYour"])" -ForegroundColor Yellow
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
                                                            Write-Host -NoNewline "      $($global:translations["PPMISProcessOf"])" -ForegroundColor Red
                                                            Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                                                            Write-Host -NoNewline "$($global:translations["PPMISNotFoundOrNotExecute"])" -ForegroundColor Red
                                                            Write-Host ""
                                                            Write-Host ""

                                                            if ( $EtapaInstAtv ) { Start-Sleep -Seconds 5 }
                                                        } 
                                                    }
                                        
                                                } else {

                                                    Write-Host ""
                                                    Write-Host "      $($global:translations["PPMISInstallFailedOrNotDone"])" -ForegroundColor Red
                                                    Write-Host ""

                                                    if ( $EtapaInstAtv ) { Start-Sleep -Seconds 5 }
                                                }

                                            } else {

                                                if ($MetodoSelecionado -eq "Chave/Serial") {

                                                    Write-Host "      $($global:translations["PPMISProcessInsallFinishing"])" -ForegroundColor Yellow
                                                    Write-Host ""
                                                    Write-Host -NoNewline "      $($global:translations["PPMISStartingStepOff"])" -ForegroundColor Yellow 
                                                    Write-Host -NoNewline " $($global:translations["PPMVISStepView"]) " -ForegroundColor Magenta
                                                    Write-Host -NoNewline "$($global:translations["PPMVISToViewThe"])" -ForegroundColor Yellow
                                                    Write-Host -NoNewline " $($global:translations["PPMVISLoginDetails"]) " -ForegroundColor Cyan
                                                    Write-Host -NoNewline "$($global:translations["PPMVISOfYou"])" -ForegroundColor Yellow
                                                    Write-Host -NoNewline " '$nome_programa'." -ForegroundColor Cyan
                                                    Write-Host ""
                                                    Write-Host ""


                                                    Set-MpPreference -SubmitSamplesConsent 1

                                                } else {

                                                    Write-Host "      $($global:translations["PPMISProcessInsallFinishing"])" -ForegroundColor Yellow 
                                                    Write-Host ""
                                                    Write-Host -NoNewline "      $($global:translations["PPMISStartingStepOff"])" -ForegroundColor Yellow 
                                                    Write-Host -NoNewline " $($global:translations["PPMISActivateStep"]) " -ForegroundColor Magenta
                                                    Write-Host -NoNewline "$($global:translations["PPMISActivateYour"])" -ForegroundColor Yellow
                                                    Write-Host -NoNewline " '$nome_programa'" -ForegroundColor Cyan
                                                    Write-Host ""
                                                    Write-Host ""

                                                    Set-MpPreference -SubmitSamplesConsent 1

                                                }

                                                if ( $EtapaInstAtv ) { Start-Sleep -Seconds 5 }

                                            }

                                        } else {
                                            Write-Host "      $($global:translations["PPMISInstallFailedOrNotDone"])" -ForegroundColor Red
                                            write-Host -NoNewline "      $($global:translations["PPMISProcessNotAllowedExecute"])" -ForegroundColor Yellow
                                            Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                                            Write-Host -NoNewline "$($global:translations["PPMISWasAlreadyInstallYourComputer"])" -ForegroundColor Yellow
                                            Write-Host ""
                                            Write-Host ""

                                            # Remove o setup de instalação
                                            Remove-Item $destino -Force

                                            Set-MpPreference -SubmitSamplesConsent 1

                                            if ( $EtapaInstAtv ) { Start-Sleep -Seconds 5 }
                                        }

                                    } else {

                                        if ($MetodoSelecionado -eq "Chave/Serial") {

                                            Write-Host "      $($global:translations["PPMISProcessInsallFinishing"])" -ForegroundColor Yellow
                                            Write-Host ""
                                            Write-Host -NoNewline "      $($global:translations["PPMISStartingStepOff"])" -ForegroundColor Yellow 
                                            Write-Host -NoNewline " $($global:translations["PPMVISStepView"]) " -ForegroundColor Magenta
                                            Write-Host -NoNewline "$($global:translations["PPMVISToViewThe"])" -ForegroundColor Yellow
                                            Write-Host -NoNewline " $($global:translations["PPMVISLoginDetails"]) " -ForegroundColor Cyan
                                            Write-Host -NoNewline "$($global:translations["PPMVISOfYou"])" -ForegroundColor Yellow
                                            Write-Host -NoNewline " '$nome_programa'." -ForegroundColor Cyan
                                            Write-Host ""
                                            Write-Host ""

                                            Set-MpPreference -SubmitSamplesConsent 1

                                        } else {

                                            Write-Host "      $($global:translations["PPMISProcessInsallFinishing"])" -ForegroundColor Yellow 
                                            Write-Host ""
                                            Write-Host -NoNewline "      $($global:translations["PPMISStartingStepOff"])" -ForegroundColor Yellow 
                                            Write-Host -NoNewline " $($global:translations["PPMISActivateStep"]) " -ForegroundColor Magenta
                                            Write-Host -NoNewline "$($global:translations["PPMISActivateYour"])" -ForegroundColor Yellow
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
                                Write-Host "      $($global:translations["PPMISTheInstallerOf"]) $nome_programa $versao_disponivel $($global:translations["PPMISNotFoundN2"])" -ForegroundColor Red
                                Write-Host ""

                                Set-MpPreference -SubmitSamplesConsent 1

                                if ( $EtapaInstAtv ) { Start-Sleep -Seconds 5 }
                            }

                        }

                    }
                                                 
                } catch {

                    Write-Host ""
                    Write-Host "      $($global:translations["PPMISErrorInFileDownload"]): $_" -ForegroundColor Red
                    Write-Host ""

                    Set-MpPreference -SubmitSamplesConsent 1

                    if ( $EtapaInstAtv ) { Start-Sleep -Seconds 5 }
                }
            } else {
                Write-Host ""
                Write-Host "      $($global:translations["PPMISInstallCancelled"])" -ForegroundColor Red
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
                    Write-Host -NoNewline "$($global:translations["PPMASLAPRequiredProcessActivation"])" -ForegroundColor Yellow
                    Write-Host -NoNewline " [10%]" -ForegroundColor Green

                } else {
                    Write-Host "     ================================================================================================================" -ForegroundColor Green
                    Write-Host -NoNewline "     * 1 - " -ForegroundColor Cyan                                                                   
                    Write-Host -NoNewline "$($global:translations["PPMASLAPConflitProcessClosed"])" -ForegroundColor Yellow
                    Write-Host -NoNewline " [10%]" -ForegroundColor Green
                }
            
                Write-Host ""
                Write-Host "     ================================================================================================================" -ForegroundColor DarkYellow
                Write-Host -NoNewline "     * 2 - " -ForegroundColor Cyan
                Write-Host -NoNewline "$($global:translations["PPMASLAPCheckingDeviceRequirements"])" -ForegroundColor Yellow
                Write-Host -NoNewline " [20%]" -ForegroundColor Green
                Write-Host ""
                Write-Host "     ================================================================================================================" -ForegroundColor DarkYellow
                Write-Host -NoNewline "     * 3 - " -ForegroundColor Cyan
                Write-Host -NoNewline "$($global:translations["PPMASLAPAnalyzingStructure"]) $nome_programa..." -ForegroundColor Yellow
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
                    Write-Host -NoNewline "$($global:translations["PPMASLAPGeneratingAndVerify"])" -ForegroundColor Yellow
                    Write-Host -NoNewline " [40%]" -ForegroundColor Green
                    Write-Host ""
                    Write-Host "     ================================================================================================================" -ForegroundColor DarkYellow
                    Write-Host -NoNewline "     * 5 - " -ForegroundColor Cyan
                    Write-Host -NoNewline "$($global:translations["PPMASLAPReformulatingAndEstablishing"]) $nome_programa..." -ForegroundColor Yellow
                    Write-Host -NoNewline " [50%]" -ForegroundColor Green
                    Write-Host ""
                    Write-Host "     ================================================================================================================" -ForegroundColor DarkYellow
                    Write-Host -NoNewline "     * 6 - " -ForegroundColor Cyan
                    Write-Host -NoNewline "$($global:translations["PPMASLAPStartingDLLInjection"]) $nome_programa..." -ForegroundColor Yellow
                    Write-Host -NoNewline " [60%]" -ForegroundColor Green
                }                                    

            } else {

                Write-Host ""
                Write-Host ""
                Write-Host "      $($global:translations["PPMASWPWinrarNothingInstall"])" -ForegroundColor Red
                Write-Host "      $($global:translations["PPMASWPWaitEnvironmentInstall"])" -ForegroundColor Yellow
                Write-Host ""
                                    
                if (-Not (Get-Command choco -ErrorAction SilentlyContinue)) {
                                        
                    Write-Host "      $($global:translations["PPMASWPNothingInstallChoco"])" -ForegroundColor Green
                                        
                    # Instalar Chocolatey
                    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
                                        
                    Write-Host "      $($global:translations["PPMASWPInstallingWinrar"])" -ForegroundColor Green
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
                            Write-Host -NoNewline "$($global:translations["PPMASLAPGeneratingAndVerify"])" -ForegroundColor Yellow
                            Write-Host -NoNewline " [40%]" -ForegroundColor Green
                            Write-Host ""
                            Write-Host "     ================================================================================================================" -ForegroundColor DarkYellow
                            Write-Host -NoNewline "     * 5 - " -ForegroundColor Cyan
                            Write-Host -NoNewline "$($global:translations["PPMASLAPReformulatingAndEstablishing"]) $nome_programa..." -ForegroundColor Yellow
                            Write-Host -NoNewline " [50%]" -ForegroundColor Green
                            Write-Host ""
                            Write-Host "     ================================================================================================================" -ForegroundColor DarkYellow
                            Write-Host -NoNewline "     * 6 - " -ForegroundColor Cyan
                            Write-Host -NoNewline "$($global:translations["PPMASLAPStartingDLLInjection"]) $nome_programa..." -ForegroundColor Yellow
                            Write-Host -NoNewline " [60%]" -ForegroundColor Green
                        }

                    } else {

                        Write-Host ""
                        Write-Host "      $($global:translations["PPMASWPWinrarNothingInstall"])" -ForegroundColor Red
                        Write-Host "      $($global:translations["PPMASWPErrorDuringWinrarInstall"])" -ForegroundColor Yellow
                        Write-Host ""

                    }

                } else {

                    Write-Host "      $($global:translations["PPMASWPInstallingWinrar"])" -ForegroundColor Green
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
                            Write-Host -NoNewline "$($global:translations["PPMASLAPGeneratingAndVerify"])" -ForegroundColor Yellow
                            Write-Host -NoNewline " [40%]" -ForegroundColor Green
                            Write-Host ""
                            Write-Host "     ================================================================================================================" -ForegroundColor DarkYellow
                            Write-Host -NoNewline "     * 5 - " -ForegroundColor Cyan
                            Write-Host -NoNewline "$($global:translations["PPMASLAPReformulatingAndEstablishing"]) $nome_programa..." -ForegroundColor Yellow
                            Write-Host -NoNewline " [50%]" -ForegroundColor Green
                            Write-Host ""
                            Write-Host "     ================================================================================================================" -ForegroundColor DarkYellow
                            Write-Host -NoNewline "     * 6 - " -ForegroundColor Cyan
                            Write-Host -NoNewline "$($global:translations["PPMASLAPStartingDLLInjection"]) $nome_programa..." -ForegroundColor Yellow
                            Write-Host -NoNewline " [60%]" -ForegroundColor Green
                        }

                    } else {

                        Write-Host ""
                        Write-Host "      $($global:translations["PPMASWPWinrarNothingInstall"])" -ForegroundColor Red
                        Write-Host "      $($global:translations["PPMASWPErrorDuringWinrarInstall"])" -ForegroundColor Yellow
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
            $etapaDisponibilizacaoTexto = "$($global:translations["PPMVASStageAccessDataViewMenu"]) $($produto_formatado)"
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
            $etapaAtivacaoTexto = "$($global:translations["PPMASStepActivationOf"]) $($produto_formatado)"
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
                                Write-Host "      $($global:translations["PPMASCurrentVersionActivateAvailable"])" -ForegroundColor Yellow
                                Write-Host ""
                            
                            } else {
                                
                                Write-Host ""
                                Write-Host "     ================================================================================================================" -ForegroundColor Green
                                Write-Host ""
                                Write-Host "      $($global:translations["PPMASCurrentVersionActivateAvailable"])" -ForegroundColor Yellow
                                Write-Host ""
                                Write-Host -NoNewline "      $($global:translations["PPMISTheProgram"])" -ForegroundColor Yellow
                                Write-Host -NoNewline " '$nome_programa $versao_disponivel' " -ForegroundColor Cyan
                                Write-Host -NoNewline "$($global:translations["PPMISInstalledYourComputer"])" -ForegroundColor Yellow
                                Write-Host ""

                            }
                        } else {

                            Write-Host ""
                            Write-Host "     ================================================================================================================" -ForegroundColor Green
                            Write-Host ""
                            Write-Host "      $($global:translations["PPMASCurrentVersionActivateAvailable"])" -ForegroundColor Yellow
                            Write-Host ""
                            Write-Host -NoNewline "      $($global:translations["PPMISTheProgram"])" -ForegroundColor Yellow
                            Write-Host -NoNewline " '$nome_programa $versao_disponivel' " -ForegroundColor Cyan
                            Write-Host -NoNewline "$($global:translations["PPMISInstalledYourComputer"])" -ForegroundColor Yellow
                            Write-Host ""
                            Write-Host "      $($global:translations["PPMASStartingProcessActivate"]) '$nome_programa'..." -ForegroundColor Green
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
                                        Write-Host -NoNewline "      $($global:translations["PPMVASStartingThe"])" -ForegroundColor Yellow
                                        Write-Host -NoNewline " $($global:translations["PPMVASStageAccessDataViewInMenu"]) " -ForegroundColor Magenta
                                        Write-Host -NoNewline "$($global:translations["PPMVASOf"])" -ForegroundColor Yellow
                                        Write-Host -NoNewline " '$nome_programa $versao_disponivel'. " -ForegroundColor Cyan
                                        Write-Host ""
                                        Write-Host ""
                                        Write-Host "      $($global:translations["PPMVASWaitSeconds"])" -ForegroundColor Green
                                        Write-Host ""
                                    } else {
                                        Write-Host ""
                                        Write-Host -NoNewline "      $($global:translations["PPMASStepOfActivate"]) " -ForegroundColor Magenta
                                        Write-Host -NoNewline "$($global:translations["PPMASOf"])" -ForegroundColor Yellow
                                        Write-Host -NoNewline " '$nome_programa $versao_disponivel' " -ForegroundColor Cyan
                                        Write-Host -NoNewline "$($global:translations["PPMASStartWithSuccess"])" -ForegroundColor Green
                                        Write-Host ""
                                        Write-Host ""
                                    }
                                } catch {
                                    if ($MetodoSelecionado -eq "Chave/Serial") {
                                        Write-Host ""
                                        Write-Host -NoNewline "      $($global:translations["PPMVASConflictingErrorStarting"])" -ForegroundColor Red
                                        Write-Host -NoNewline " $($global:translations["PPMVASStageAccessDataViewInMenu"]) " -ForegroundColor Yellow
                                        Write-Host -NoNewline "$($global:translations["PPMVASOf"])" -ForegroundColor Red
                                        Write-Host -NoNewline " '$nome_programa $versao_disponivel' " -ForegroundColor Yellow
                                        Write-Host ""
                                        Write-Host ""
                                    } else {
                                        Write-Host ""
                                        Write-Host -NoNewline "      $($global:translations["PPMASConflitErrorInStart"])" -ForegroundColor Red
                                        Write-Host -NoNewline " $($global:translations["PPMASStepOfActivate"]) " -ForegroundColor Magenta
                                        Write-Host -NoNewline "$($global:translations["PPMASOf"])" -ForegroundColor Red
                                        Write-Host -NoNewline " '$nome_programa $versao_disponivel'." -ForegroundColor Cyan
                                        Write-Host ""
                                        Write-Host ""
                                    }
                                }

                                if (Test-Path $destino) {

                                    etapaOneAtv

                                } else {
                                    Write-Host ""
                                    Write-Host "      $($global:translations["PPMASDownloadFailFile"])" -ForegroundColor Red
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
                                Write-Host "     $($global:translations["PPMASFatalError"])" -ForegroundColor Red         
                                Write-Host "     $($global:translations["PPMISTheProcess"]) $($processNames -join ', ') $($global:translations["PPMISIsExecuted"])" -ForegroundColor Cyan
                                Write-Host "     $($global:translations["PPMASFinishingProcessAndRestart"]) $nome_programa." -ForegroundColor Green
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
                                                Write-Host "      $($global:translations["PPMASNothingExeSFXFileFound"])" -ForegroundColor Red
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

                                        Write-Host -NoNewline "      # " -ForegroundColor Green
                                        Write-Host "$($global:translations["PPMVASVerificationProcessInitial"]):" -ForegroundColor Cyan
                                        Write-Host ""
                                        Write-Host -NoNewline "      > " -ForegroundColor Green
                                        Write-Host -NoNewline  "$($global:translations["PPMVASPreviousStepsPrerequisites"]) " -ForegroundColor Yellow
                                        Write-Host -NoNewline  "$($global:translations["PPMVASWereSuccessCompleted"])" -ForegroundColor Green
                                        Start-Sleep -Seconds 5 
                                        Write-Host ""
                                        Write-Host -NoNewline "      > " -ForegroundColor Green
                                        Write-Host -NoNewline  "$($global:translations["PPMVASWaitSeconds"]) " -ForegroundColor Green
                                        Write-Host -NoNewline  "$($global:translations["PPMVASWhileThe"])" -ForegroundColor Yellow
                                        Write-Host -NoNewline  " $($global:translations["PPMVISLoginDetails"])" -ForegroundColor Cyan
                                        Write-Host -NoNewline  "$($global:translations["PPMVASBeingCreatedVisualEnabled"])" -ForegroundColor Green
                                        Start-Sleep -Seconds 10 
                                        Write-Host ""
                                        Write-Host -NoNewline "      > " -ForegroundColor Green
                                        Write-Host -NoNewline  "$($global:translations["PPMVASTheInitialPhrase"])" -ForegroundColor Yellow
                                        Write-Host -NoNewline  " $($global:translations["PPMVISLoginDetails"]) " -ForegroundColor Cyan
                                        Write-Host -NoNewline  "$($global:translations["PPMVASOf"])" -ForegroundColor Yellow
                                        Write-Host -NoNewline  " '$nome_programa $versao_disponivel'" -ForegroundColor Cyan
                                        Write-Host -NoNewline  "$($global:translations["PPMVASSuccessCreated"])" -ForegroundColor Green
                                        Start-Sleep -Seconds 2
                                        Write-Host ""
                                        Write-Host ""
                                        Write-Host "     ================================================================================================================" -ForegroundColor Green
                                        Write-Host ""
                                        Write-Host -NoNewline "      # " -ForegroundColor Green
                                        Write-Host "$($global:translations["PPMVASAtentionTitle"]): " -ForegroundColor Cyan
                                        Write-Host ""
                                        Write-Host -NoNewline  "      $($global:translations["PPMVASYour"])" -ForegroundColor Yellow
                                        Write-Host -NoNewline  " $($global:translations["PPMVASStepKeysAndLoginData"]) " -ForegroundColor Magenta
                                        Write-Host -NoNewline  "$($global:translations["PPMVASOf"])" -ForegroundColor Yellow
                                        Write-Host -NoNewline  " '$nome_programa $versao_disponivel'" -ForegroundColor Cyan
                                        Write-Host -NoNewline  "$($global:translations["PPMVASWereSuccessEnabled"])" -ForegroundColor Green
                                        Write-Host ""
                                        Write-Host -NoNewline "      $($global:translations["PPMVASAvailableForViewingIn"])" -ForegroundColor Yellow
                                        Write-Host -NoNewline " $($global:translations["PPMVASStepProductDetailsMenu"]) " -ForegroundColor Cyan
                                        Write-Host -NoNewline "$($global:translations["PPMVASInTheAreaOf"])" -ForegroundColor Yellow
                                        Write-Host -NoNewline " $($global:translations["PPMVASStepAccessData"]) " -ForegroundColor Cyan
                                        Write-Host ""
                                        Write-Host ""
                                        Write-Host "     ================================================================================================================" -ForegroundColor Green

                                        # Opcional: Remover a pasta do arquivo após extração.
                                        # Remove-Item "$destino_atv\$versao_disponivel" -Recurse -Force

                                        # Reversão do Windows Defender
                                        ConfigWFAtv -StatusConfigWF "Offline"
                                        
                                        Start-Sleep -Seconds 5    

                                        if ($stepsAtvToCheck["processo_ativacao"].Contains('Pré-instalação')) {
                                            
                                            Write-Host ""

                                        } else {

                                            Write-Host ""   

                                            $opcao_verficar_ativacao = Read-Host "      $($global:translations["PPMISStartingOf"]) $nome_programa $($global:translations["PPMVASQuestionEnterYourKeyActivation"])"
                                    
                                            Write-Host ""
                                               
                                            if (($idiomaSelecionado -eq "pt" -and $opcao_verficar_ativacao -eq "S") -or ($idiomaSelecionado -eq "en" -and $opcao_verficar_ativacao -eq "Y") -or ($idiomaSelecionado -eq "es" -and $opcao_verficar_ativacao -eq "S")) { 
                                            
                                                if ($metodo_ativacao -eq "Chave/Serial") {
                                                    Start-Process -FilePath $pathsToCheck["exe_produto_open"] -PassThru
                                                } else {
                                                    Start-Process -FilePath $pathsToCheck["exe_instalacao"] -PassThru
                                                } 
                                            }

                                        }

                                        Write-Host -NoNewline "      # " -ForegroundColor Green
                                        Write-Host -NoNewline "$($global:translations["PPMVASSimpleTutorial"]) " -ForegroundColor Yellow
                                        Write-Host -NoNewline "'$($global:translations["VASActivationOf"]) $nome_programa':" -ForegroundColor Cyan
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

                                        $opcao_tutorial_ativacao = Read-Host "      $($global:translations["PPMVASQuestionOpenLinkWithTutorialActivation"])"
                                        
                                        if (($idiomaSelecionado -eq "pt" -and $opcao_tutorial_ativacao -eq "S") -or ($idiomaSelecionado -eq "en" -and $opcao_tutorial_ativacao -eq "Y") -or ($idiomaSelecionado -eq "es" -and $opcao_tutorial_ativacao -eq "S")) {

                                            $urlPattern = '^(https?|ftp)://[^\s/$.?#].[^\s]*$'

                                            $link_tutorial_ativacao_produto = $($lessonProductToCheck['link_tutorial_ativacao'])

                                            if ($link_tutorial_ativacao_produto -match $urlPattern) {
                                                Start-Process $link_tutorial_ativacao_produto
                                            } else {
                                                Write-Host ""
                                                Write-Host "      $($global:translations["PPMVAUnfortunatelyDescription"]) $nome_programa $($global:translations["PPMVANotHaveLinkActivation"])" -ForegroundColor Red
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
                                        Write-Host -NoNewline "$($global:translations["PPMASLAPDLLShieldingDevice"])" -ForegroundColor Yellow
                                        Write-Host -NoNewline " [70%]" -ForegroundColor Green
                                        Write-Host ""
                                        Write-Host "     ================================================================================================================" -ForegroundColor DarkYellow
                                        Write-Host -NoNewline "     * 8 - " -ForegroundColor Cyan
                                        Write-Host -NoNewline "$($global:translations["PPMASLAPCheckingWorking"]) $nome_programa $($global:translations["PPMASLAPImplementActivation"])" -ForegroundColor Yellow
                                        Write-Host -NoNewline " [80%]" -ForegroundColor Green
                                        Write-Host ""
                                        Write-Host "     ================================================================================================================" -ForegroundColor DarkYellow
                                        Write-Host -NoNewline "     * 9 - " -ForegroundColor Cyan
                                        Write-Host -NoNewline "$($global:translations["PPMASLAPCompletingActivation"]) $nome_programa..." -ForegroundColor Yellow
                                        Write-Host -NoNewline " [100%]" -ForegroundColor Green
                                        Write-Host ""
                                        Write-Host "     ================================================================================================================" -ForegroundColor Green   
                                       
                                        # Opcional: Remover a pasta do arquivo após extração.
                                        # Remove-Item "$destino_atv\$versao_disponivel" -Recurse -Force

                                        # Reversão do Windows Defender
                                        ConfigWFAtv -StatusConfigWF "Offline"
                                                
                                        Write-Host ""
                                    
                                        $opcao_verficar_ativacao = Read-Host "      $($global:translations["PPMISStartingOf"]) $nome_programa $($global:translations["PPMASValidYourActivate"])"
                                    
                                        Write-Host ""
                                               
                                        if (($idiomaSelecionado -eq "pt" -and $opcao_verficar_ativacao -eq "S") -or ($idiomaSelecionado -eq "en" -and $opcao_verficar_ativacao -eq "Y") -or ($idiomaSelecionado -eq "es" -and $opcao_verficar_ativacao -eq "S")) {
                                            
                                            Start-Process -FilePath $programPath -PassThru -Wait

                                            if ( $EtapaInstAtv ) { Start-Sleep -Seconds 5 }
                                        }
                                    
                                    }          

                                } catch {

                                    Write-Host ""
                                    Write-Host "      $($global:translations["PPMASErrorToMoveFiles"]): $_"  -ForegroundColor Red
                                    Write-Host ""

                                    if ( $EtapaInstAtv ) { Start-Sleep -Seconds 5 }
                                }

                            }

                        } catch {

                            Write-Host ""
                            Write-Host "      $($global:translations["PPMISErrorInFileDownload"]): $_" -ForegroundColor Red
                            Write-Host ""

                            if ( $EtapaInstAtv ) { Start-Sleep -Seconds 5 }
                        }
                    }

                } else {

                    if ($MetodoSelecionado -eq "Chave/Serial") {
                        
                        Write-Host ""
                        Write-Host -NoNewline "      $($global:translations["PPMVISNeedInstalledYourComputer"])" -ForegroundColor Yellow
                        Write-Host -NoNewline " '$nome_programa $versao_disponivel' " -ForegroundColor Cyan
                        Write-Host ""
                        Write-Host -NoNewline "      $($global:translations["PPMVISSoNeedInstalled"])" -ForegroundColor Yellow
                        Write-Host -NoNewline " $($global:translations["PPMVISLoginDetails"]) " -ForegroundColor Cyan
                        Write-Host -NoNewline "$($global:translations["PPMVASAvailableForViewing"])" -ForegroundColor Yellow
                        Write-Host "      $($global:translations["PPMVASCompatibleEffectiveInActivation"])" -ForegroundColor Yellow
                        Write-Host "" 
                        Write-Host -NoNewline "      $($global:translations["PPMASTheVersionOf"])" -ForegroundColor Red
                        Write-Host -NoNewline " '$nome_programa $programVersionAnterior' " -ForegroundColor Cyan
                        Write-Host -NoNewline "$($global:translations["PPMASInstalledYourComputerDiference"])" -ForegroundColor Red
                        Write-Host -NoNewline " '$versao_disponivel' " -ForegroundColor Cyan
                        Write-Host -NoNewline "$($global:translations["PPMASAvailableForInstall"])" -ForegroundColor Red
                        Write-Host ""
                        Write-Host -NoNewline "      $($global:translations["PPMASUninstallThe"])" -ForegroundColor Yellow
                        Write-Host -NoNewline " '$nome_programa $programVersionAnterior' " -ForegroundColor Cyan
                        Write-Host -NoNewline "$($global:translations["PPMASVersionCompatibleActvation"]):" -ForegroundColor Yellow
                        Write-Host -NoNewline " '$nome_programa $versao_disponivel' " -ForegroundColor Cyan
                        Write-Host ""
                        Write-Host ""

                    } else {
                        Write-Host ""
                        Write-Host -NoNewline "      $($global:translations["PPMASTheVersionOf"])" -ForegroundColor Red
                        Write-Host -NoNewline " '$nome_programa $programVersionAnterior' " -ForegroundColor Cyan
                        Write-Host -NoNewline "$($global:translations["PPMASInstalledYourComputerDiference"])" -ForegroundColor Red
                        Write-Host -NoNewline " '$versao_disponivel' " -ForegroundColor Cyan
                        Write-Host -NoNewline "$($global:translations["PPMASAvailableForInstall"])" -ForegroundColor Red
                        Write-Host ""
                        Write-Host -NoNewline "      $($global:translations["PPMASUninstallThe"])" -ForegroundColor Yellow
                        Write-Host -NoNewline " '$nome_programa $programVersionAnterior' " -ForegroundColor Cyan
                        Write-Host -NoNewline "$($global:translations["PPMASVersionCompatibleActvation"]):" -ForegroundColor Yellow
                        Write-Host -NoNewline " '$nome_programa $versao_disponivel' " -ForegroundColor Cyan
                        Write-Host ""
                        Write-Host ""
                    }

                    if ( $EtapaInstAtv ) { Start-Sleep -Seconds 5 }
                }

            } catch {
                
                Write-Host ""
                Write-Host "      $($global:translations["PPMASErrorInfoToPathProgram"]) $programPath" -ForegroundColor Red
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
                    Write-Host -NoNewline "      $($global:translations["PPMVISNeedInstalledYourComputer"])" -ForegroundColor Yellow
                    Write-Host -NoNewline " '$nome_programa $versao_disponivel' " -ForegroundColor Cyan
                    Write-Host ""
                    Write-Host -NoNewline "      $($global:translations["PPMVISSoNeedInstalled"])" -ForegroundColor Yellow
                    Write-Host -NoNewline " $($global:translations["PPMVISLoginDetails"]) " -ForegroundColor Cyan
                    Write-Host -NoNewline "$($global:translations["PPMVASAvailableForViewing"])" -ForegroundColor Yellow
                    Write-Host "      $($global:translations["PPMVASCompatibleEffectiveInActivation"])" -ForegroundColor Yellow
                    Write-Host ""
                    Write-Host -NoNewline "      $($global:translations["PPMASTheVersionOf"])" -ForegroundColor Red
                    Write-Host -NoNewline " '$nome_programa $programVersionAnterior' " -ForegroundColor Cyan
                    Write-Host -NoNewline "$($global:translations["PPMASInstalledYourComputerDiference"])" -ForegroundColor Red
                    Write-Host -NoNewline " '$versao_disponivel' " -ForegroundColor Cyan
                    Write-Host -NoNewline "$($global:translations["PPMASAvailableForInstall"])" -ForegroundColor Red
                    Write-Host ""
                    Write-Host -NoNewline "      $($global:translations["PPMASUninstallThe"])" -ForegroundColor Yellow
                    Write-Host -NoNewline " '$nome_programa $programVersionAnterior' " -ForegroundColor Cyan
                    Write-Host -NoNewline "$($global:translations["PPMASVersionCompatibleActvation"]):" -ForegroundColor Yellow
                    Write-Host -NoNewline " '$nome_programa $versao_disponivel' " -ForegroundColor Cyan
                    Write-Host ""
                    Write-Host ""

                } else {
                    Write-Host ""
                    Write-Host -NoNewline "      $($global:translations["PPMASTheVersionOf"])" -ForegroundColor Red
                    Write-Host -NoNewline " '$nome_programa $programVersionAnterior' " -ForegroundColor Cyan
                    Write-Host -NoNewline "$($global:translations["PPMASInstalledYourComputerDiference"])" -ForegroundColor Red
                    Write-Host -NoNewline " '$versao_disponivel' " -ForegroundColor Cyan
                    Write-Host -NoNewline "$($global:translations["PPMASAvailableForInstall"])" -ForegroundColor Red
                    Write-Host ""
                    Write-Host -NoNewline "      $($global:translations["PPMASUninstallThe"])" -ForegroundColor Yellow
                    Write-Host -NoNewline " '$nome_programa $programVersionAnterior' " -ForegroundColor Cyan
                    Write-Host -NoNewline "$($global:translations["PPMASVersionCompatibleActvation"]):" -ForegroundColor Yellow
                    Write-Host -NoNewline " '$nome_programa $versao_disponivel' " -ForegroundColor Cyan
                    Write-Host ""
                    Write-Host ""
                }

                if ( $EtapaInstAtv ) { Start-Sleep -Seconds 5 }

            } else {

                if ($MetodoSelecionado -eq "Chave/Serial") {
                
                    Write-Host ""
                    Write-Host -NoNewline "      $($global:translations["PPMISTheProgram"])" -ForegroundColor Red
                    Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                    Write-Host -NoNewline "$($global:translations["PPMASNotInstalledYourComputer"])" -ForegroundColor Red
                    Write-Host ""
                    Write-Host -NoNewline "      $($global:translations["PPMASActivateInstallOf"])" -ForegroundColor Yellow
                    Write-Host -NoNewline " '$nome_programa $versao_disponivel', " -ForegroundColor Cyan
                    Write-Host -NoNewline "$($global:translations["PPMVASEnableTheVisualization"])" -ForegroundColor Yellow
                    Write-Host -NoNewline " $($global:translations["PPMVISLoginDetails"]) " -ForegroundColor Cyan
                    Write-Host -NoNewline "$($global:translations["PPMVASInSequence"])" -ForegroundColor Yellow
                    Write-Host ""
                    Write-Host ""

                } else {
                    Write-Host ""
                    Write-Host -NoNewline "      $($global:translations["PPMISTheProgram"])" -ForegroundColor Red
                    Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                    Write-Host -NoNewline "$($global:translations["PPMASNotInstalledYourComputer"])" -ForegroundColor Red
                    Write-Host ""
                    Write-Host -NoNewline "      $($global:translations["PPMASActivateInstallOf"])" -ForegroundColor Yellow
                    Write-Host -NoNewline " '$nome_programa $versao_disponivel' " -ForegroundColor Cyan
                    Write-Host -NoNewline "$($global:translations["PPMASSequenceActivateProgram"])" -ForegroundColor Yellow
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
        $etapaDesinstalacaoTexto = "$($global:translations["PPMUSStepUninstallation"]) $($produto_formatado)"
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
                Write-Host "      $($global:translations["PPMISTheProcess"]) $($processNames -join ', ') $($global:translations["PPMISIsExecuted"])" -ForegroundColor Yellow
                Write-Host "      $($global:translations["PPMUSClosingProcessUninstallation"])" -ForegroundColor Green
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
                        Write-Host "      $($global:translations["PPMUSCurrentVersionAvailableInstall"])" -ForegroundColor Yellow
                        Write-Host ""
                        Write-Host -NoNewline "      $($global:translations["PPMISTheProgram"])" -ForegroundColor Yellow
                        Write-Host -NoNewline " '$nome_programa $versao_disponivel' " -ForegroundColor Cyan
                        Write-Host -NoNewline "$($global:translations["PPMUSAlreadyInstallComputer"])" -ForegroundColor Yellow
                        Write-Host ""
                        Write-Host "      $($global:translations["PPMUSStartingProcessUninstall"]) '$nome_programa'..." -ForegroundColor Green
                        Write-Host ""
                   
                    } else {

                        Write-Host "     ================================================================================================================" -ForegroundColor Green
                        Write-Host ""
                        Write-Host "      $($global:translations["PPMUSLastVersionDiferenceInstall"])" -ForegroundColor Yellow
                        Write-Host ""
                        Write-Host -NoNewline "      $($global:translations["PPMISTheProgram"])" -ForegroundColor Yellow
                        Write-Host -NoNewline " '$nome_programa $programVersionAnterior' " -ForegroundColor Cyan
                        Write-Host -NoNewline "$($global:translations["PPMUSAlreadyInstallComputer"])" -ForegroundColor Yellow
                        Write-Host ""
                        Write-Host "      $($global:translations["PPMUSStartingProcessUninstall"]) '$nome_programa'..." -ForegroundColor Green
                        Write-Host ""

                    }                 
                    
                } else {

                    Write-Host "     ================================================================================================================" -ForegroundColor Green
                    Write-Host ""
                    Write-Host "      $($global:translations["PPMUSLastVersionDiferenceInstall"])" -ForegroundColor Yellow
                    Write-Host ""
                    Write-Host -NoNewline "      $($global:translations["PPMISTheProgram"])" -ForegroundColor Yellow
                    Write-Host -NoNewline " '$nome_programa $programVersionAnterior' " -ForegroundColor Cyan
                    Write-Host -NoNewline "$($global:translations["PPMUSAlreadyInstallComputer"])" -ForegroundColor Yellow
                    Write-Host ""
                    Write-Host "      $($global:translations["PPMUSStartingProcessUninstall"]) '$nome_programa'..." -ForegroundColor Green
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
                        Write-Host "      $($global:translations["PPMUSCurrentVersionAvailableInstall"])" -ForegroundColor Yellow
                        Write-Host ""
                        Write-Host -NoNewline "      $($global:translations["PPMISTheProgram"])" -ForegroundColor Yellow
                        Write-Host -NoNewline " '$nome_programa $versao_disponivel' " -ForegroundColor Cyan
                        Write-Host -NoNewline "$($global:translations["PPMUSAlreadyInstallComputer"])" -ForegroundColor Yellow
                        Write-Host ""
                        Write-Host "      $($global:translations["PPMUSStartingProcessUninstall"]) '$nome_programa'..." -ForegroundColor Green
                        Write-Host ""
                    } else {
                        Write-Host ""
                        Write-Host "     ================================================================================================================" -ForegroundColor Green
                        Write-Host ""
                        Write-Host "      $($global:translations["PPMUSLastVersionDiferenceInstall"])" -ForegroundColor Yellow
                        Write-Host ""
                        Write-Host -NoNewline "      $($global:translations["PPMISTheProgram"])" -ForegroundColor Yellow
                        Write-Host -NoNewline " '$nome_programa $programVersionAnterior' " -ForegroundColor Cyan
                        Write-Host -NoNewline "$($global:translations["PPMUSAlreadyInstallComputer"])" -ForegroundColor Yellow
                        Write-Host ""
                        Write-Host "      $($global:translations["PPMUSStartingProcessUninstall"]) '$nome_programa'..." -ForegroundColor Green
                        Write-Host ""

                    }                 
                    
                } else {

                    Write-Host ""
                    Write-Host "     ================================================================================================================" -ForegroundColor Green
                    Write-Host ""
                    Write-Host "      $($global:translations["PPMUSLastVersionDiferenceInstall"])" -ForegroundColor Yellow
                    Write-Host ""
                    Write-Host -NoNewline "      $($global:translations["PPMISTheProgram"])" -ForegroundColor Yellow
                    Write-Host -NoNewline " '$nome_programa $programVersionAnterior' " -ForegroundColor Cyan
                    Write-Host -NoNewline "$($global:translations["PPMUSAlreadyInstallComputer"])" -ForegroundColor Yellow
                    Write-Host ""
                    Write-Host "      $($global:translations["PPMUSStartingProcessUninstall"]) '$nome_programa'..." -ForegroundColor Green
                    Write-Host ""

                    if ( $EtapaInstAtv ) { Start-Sleep -Seconds 5 }

                }
            }

            $opcao_remover = Read-Host "      $($global:translations["PPMUSWishUninstall"]) $nome_programa ? $($global:translations["PPMUSYesOrNot"])"
            Write-Host ""

            if (($idiomaSelecionado -eq "pt" -and $opcao_remover -eq "S") -or ($idiomaSelecionado -eq "en" -and $opcao_remover -eq "Y") -or ($idiomaSelecionado -eq "es" -and $opcao_remover -eq "S")) {
                            
                if ($MetodoSelecionado -eq "Chave/Serial" -and $stepsAtvToCheck["processo_ativacao"].Contains('Pré-instalação')) {
                    
                    $metodo_remover = Read-Host "      $($global:translations["PPMUSWishFullUninstall"]) $nome_programa.? $($global:translations["PPMUSYesOrNot"])"

                    if (($idiomaSelecionado -eq "pt" -and $metodo_remover -eq "S") -or ($idiomaSelecionado -eq "en" -and $metodo_remover -eq "Y") -or ($idiomaSelecionado -eq "es" -and $metodo_remover -eq "S")) {

                        $processesRunning = CheckProcessesRunning

                        if ($processesRunning) {
                        
                            $processNames = $processesRunning | ForEach-Object { $_.Name } 
                         
                            Write-Host ""          
                            Write-Host "$($global:translations["PPMISTheProcess"]) $($processNames -join ', ') $($global:translations["PPMISIsExecuted"])" -ForegroundColor Yellow
                            Write-Host "$($global:translations["PPMUSClosingProcessUninstallation"])" -ForegroundColor Red
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
                                Write-Host -NoNewline "      $($global:translations["PPMUSFullUninstallOf"])" -ForegroundColor Yellow
                                Write-Host -NoNewline " '$nome_programa $versao_disponivel' " -ForegroundColor Cyan
                                Write-Host -NoNewline "$($global:translations["PPMISStartingStep"])" -ForegroundColor Yellow
                                Write-Host ""
                                Write-Host ""
                                Write-Host "      $($global:translations["PPMUSOpeningUninstallOf"]) $nome_programa..." -ForegroundColor Green  
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
                                    Write-Host -NoNewline "      $($global:translations["PPMUSWaitProcessUninstall"])" -ForegroundColor Yellow
                                    Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                                    Write-Host -NoNewline "$($global:translations["PPMISFinishingStep"])" -ForegroundColor Yellow
                                    Write-Host ""

                                } else {

                                    Write-Host ""
                                    Write-Host -NoNewline "      $($global:translations["PPMUSWaitProcessUninstall"])" -ForegroundColor Yellow
                                    Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                                    Write-Host -NoNewline "$($global:translations["PPMISFinishingStep"])" -ForegroundColor Yellow
                                    Write-Host ""
                    
                                }

                                # Inciando o processo de desinstalação e aguardando sua conclusão
                                Start-Process -FilePath $exePath_unis_atual -PassThru -Wait

                            } else {

                                Write-Host ""
                                Write-Host "     ===============================================================================================================" -ForegroundColor Green
                                Write-Host ""
                                Write-Host -NoNewline "      $($global:translations["PPMUSFullUninstallOf"])" -ForegroundColor Yellow
                                Write-Host -NoNewline " '$nome_programa $programVersionAnterior' " -ForegroundColor Cyan
                                Write-Host -NoNewline "$($global:translations["PPMISFinishingStep"])" -ForegroundColor Yellow
                                Write-Host ""
                                Write-Host ""
                                Write-Host "      $($global:translations["PPMUSOpeningUninstallOf"]) $nome_programa..." -ForegroundColor Green  
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
                                    Write-Host -NoNewline "      $($global:translations["PPMUSWaitProcessUninstall"])" -ForegroundColor Yellow
                                    Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                                    Write-Host -NoNewline "$($global:translations["PPMISFinishingStep"])" -ForegroundColor Yellow
                                    Write-Host ""

                                } else {

                                    Write-Host ""
                                    Write-Host -NoNewline "      $($global:translations["PPMUSWaitProcessUninstall"])" -ForegroundColor Yellow
                                    Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                                    Write-Host -NoNewline "$($global:translations["PPMISFinishingStep"])" -ForegroundColor Yellow
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
                                Write-Host -NoNewline "      $($global:translations["PPMUSFullUninstallOf"])" -ForegroundColor Yellow
                                Write-Host -NoNewline " '$nome_programa $versao_disponivel' " -ForegroundColor Cyan
                                Write-Host -NoNewline "$($global:translations["PPMISStartingStep"])" -ForegroundColor Yellow
                                Write-Host ""
                                Write-Host ""
                                Write-Host "      $($global:translations["PPMUSOpeningUninstallOf"]) $nome_programa..." -ForegroundColor Green  
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
                                    Write-Host -NoNewline "      $($global:translations["PPMUSWaitProcessUninstall"])" -ForegroundColor Yellow
                                    Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                                    Write-Host -NoNewline "$($global:translations["PPMISFinishingStep"])" -ForegroundColor Yellow
                                    Write-Host ""

                                } else {

                                    Write-Host ""
                                    Write-Host -NoNewline "      $($global:translations["PPMUSWaitProcessUninstall"])" -ForegroundColor Yellow
                                    Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                                    Write-Host -NoNewline "$($global:translations["PPMISFinishingStep"])" -ForegroundColor Yellow
                                    Write-Host ""
                    
                                }

                                # Inciando o processo de desinstalação e aguardando sua conclusão
                                Start-Process -FilePath $exePath_unis_atual -PassThru -Wait

                            } else {

                                Write-Host ""
                                Write-Host "     ===============================================================================================================" -ForegroundColor Green
                                Write-Host ""
                                Write-Host -NoNewline "      $($global:translations["PPMUSFullUninstallOf"])" -ForegroundColor Yellow
                                Write-Host -NoNewline " '$nome_programa $programVersionAnterior' " -ForegroundColor Cyan
                                Write-Host -NoNewline "$($global:translations["PPMISStartingStep"])" -ForegroundColor Yellow
                                Write-Host ""
                                Write-Host ""
                                Write-Host "      $($global:translations["PPMUSOpeningUninstallOf"]) $nome_programa..." -ForegroundColor Green  
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
                                    Write-Host -NoNewline "      $($global:translations["PPMUSWaitProcessUninstall"])" -ForegroundColor Yellow
                                    Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                                    Write-Host -NoNewline "$($global:translations["PPMISFinishingStep"])" -ForegroundColor Yellow
                                    Write-Host ""

                                } else {

                                    Write-Host ""
                                    Write-Host -NoNewline "      $($global:translations["PPMUSWaitProcessUninstall"])" -ForegroundColor Yellow
                                    Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                                    Write-Host -NoNewline "$($global:translations["PPMISFinishingStep"])" -ForegroundColor Yellow
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
                                Write-Host -NoNewline  "      $($global:translations["PPMUSFailProcessUninstall"])" -ForegroundColor Red
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
                        Write-Host -NoNewline "      $($global:translations["PPMISConfirmedOf"])" -ForegroundColor Yellow
                        Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                        Write-Host -NoNewline "$($global:translations["PPMUSUninstallAndVerify"])" -ForegroundColor Yellow
                        Write-Host ""
                        Write-Host ""

                        $remocao_completa = Read-Host "      $($global:translations["PPMUSUninstallVerifyOf"]) $nome_programa ? $($global:translations["PPMUSYesOrNot"])"
                   
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

                        if(($idiomaSelecionado -eq "pt" -and $remocao_completa -eq "S" -or $remocao_completa -eq "N") -or ($idiomaSelecionado -eq "en" -and $remocao_completa -eq "Y" -or $remocao_completa -eq "N") -or ($idiomaSelecionado -eq "es" -and $remocao_completa -eq "S" -or $remocao_completa -eq "N")){

                            # Verifica se a pasta ainda existe
                            if (((Test-Path $folderFound) -and $subFoundInProgramFound.Count -ge 1 -and $filesInProgramFound.Count -ge 1 -or $filesInfolderFound.Count -ge 1) -or ((Test-Path $folderFound) -and $filesInfolderFound.Count -ge 1)) {
                            
                                Write-Host -NoNewline "      $($global:translations["PPMUSYour"])" -ForegroundColor Green
                                Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                                Write-Host -NoNewline "$($global:translations["PPMUSUninstallWasPartial"])" -ForegroundColor Green
                                Write-Host ""
                                Write-Host ""
                                write-Host -NoNewline "      $($global:translations["PPMUSNeedRestartUninstallComplete"])" -ForegroundColor Yellow
                                Write-Host ""
                                write-Host -NoNewline "      $($global:translations["PPMUSBackupConfigAndCostumization"])" -ForegroundColor Yellow
                                Write-Host ""
                                write-Host -NoNewline "      $($global:translations["PPMUSHaveProductInstalledDeveloper"])" -ForegroundColor Yellow
                                Write-Host ""
                                Write-Host ""
                                
                                if ( $EtapaInstAtv ) { Start-Sleep -Seconds 5 }

                            } elseif (((Test-Path $folderFoundProgramAtual) -and $subfoldersProgramAtual.Count -ge 1 -and $filesInProgramAtual.Count -ge 1 -or $filesInfolderFoundAtual.Count -ge 1) -or ((Test-Path $folderFoundProgramAtual) -and $filesInfolderFoundAtual.Count -ge 1) -or ((Test-Path $folderFoundProgramAtual))) {
                            
                                Write-Host -NoNewline "      $($global:translations["PPMUSYour"])" -ForegroundColor Green
                                Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                                Write-Host -NoNewline "$($global:translations["PPMUSUninstallWasPartial"])" -ForegroundColor Green
                                Write-Host ""
                                Write-Host ""
                                write-Host -NoNewline "      $($global:translations["PPMUSNeedRestartUninstallComplete"])" -ForegroundColor Yellow
                                Write-Host ""
                                write-Host -NoNewline "      $($global:translations["PPMUSBackupConfigAndCostumization"])" -ForegroundColor Yellow
                                Write-Host ""
                                write-Host -NoNewline "      $($global:translations["PPMUSHaveProductInstalledDeveloper"])" -ForegroundColor Yellow
                                Write-Host ""
                                Write-Host ""
                                
                                if ( $EtapaInstAtv ) { Start-Sleep -Seconds 5 }

                            } else {
                                Write-Host "      $($global:translations["PPMUSUnisntallOf"]) '$nome_programa' $($global:translations["PPMUSUnisntallWasFinishSuccessfull"])" -ForegroundColor Green
                                Write-Host ""

                                if ( $EtapaInstAtv ) { Start-Sleep -Seconds 5 }
                            }
                        }

                    } else {

                        Write-Host ""
                        Write-Host "      $($global:translations["PPMUSUninstallCanceled"])" -ForegroundColor Red
                        Write-Host ""

                        if ( $EtapaInstAtv ) { Start-Sleep -Seconds 5 }
                    }
                } else {

                    $metodo_remover = Read-Host "      $($global:translations["PPMUSQuestionUninstallRapidOrComplete"])"
                            
                    if ($metodo_remover -eq 'r') {

                        $processesRunning = CheckProcessesRunning

                        if ($processesRunning) {

                            $processNames = $processesRunning | ForEach-Object { $_.Name }  
                            Write-Host ""
                            Write-Host "     ===============================================================================================================" -ForegroundColor Red          
                            Write-Host ""
                            Write-Host "      $($global:translations["PPMISTheProcess"]) $($processNames -join ', ') $($global:translations["PPMISIsExecuted"])" -ForegroundColor Yellow
                            Write-Host "      $($global:translations["PPMUSClosingProcessUninstallation"])" -ForegroundColor Green
                            Write-Host ""
                            foreach ($processName in $processNames) {
                                $process = Get-Process -Name $processName
                                Stop-Process -Id $process.Id -Force
                            }

                            if ($folderFoundAtual) {
                            
                                Write-Host ""
                                Write-Host "     ===============================================================================================================" -ForegroundColor Green
                                Write-Host ""
                                Write-Host "      $($global:translations["PPMUSUninstallRapidOf"]) $nome_programa $($global:translations["PPMISStartingStep"])" -ForegroundColor Green
                                Write-Host -NoNewline  "      $($global:translations["PPMUSWaitProcessUninstall"])" -ForegroundColor Yellow
                                Write-Host -NoNewline  " '$nome_programa $versao_disponivel' " -ForegroundColor Cyan
                                Write-Host -NoNewline  "$($global:translations["PPMISFinishingStep"])" -ForegroundColor Yellow
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
                                Write-Host "      $($global:translations["PPMUSUninstallRapidOf"]) $nome_programa $($global:translations["PPMISStartingStep"])" -ForegroundColor Green
                                Write-Host -NoNewline  "      $($global:translations["PPMUSWaitProcessUninstall"])" -ForegroundColor Yellow
                                Write-Host -NoNewline  " '$nome_programa $programVersionAnterior' " -ForegroundColor Cyan
                                Write-Host -NoNewline  "$($global:translations["PPMISFinishingStep"])" -ForegroundColor Yellow
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
                                Write-Host "      $($global:translations["PPMUSUninstallRapidOf"]) $nome_programa $($global:translations["PPMISStartingStep"])" -ForegroundColor Green
                                Write-Host -NoNewline  "      $($global:translations["PPMUSWaitProcessUninstall"])" -ForegroundColor Yellow
                                Write-Host -NoNewline  " '$nome_programa $versao_disponivel' " -ForegroundColor Cyan
                                Write-Host -NoNewline  "$($global:translations["PPMISFinishingStep"])" -ForegroundColor Yellow
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
                                    Write-Host -NoNewline  "      $($global:translations["PPMUSFailProcessUninstall"])" -ForegroundColor Red
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
                                Write-Host "      $($global:translations["PPMUSUninstallRapidOf"]) $nome_programa $($global:translations["PPMISStartingStep"])" -ForegroundColor Green
                                Write-Host -NoNewline  "      $($global:translations["PPMUSWaitProcessUninstall"])" -ForegroundColor Yellow
                                Write-Host -NoNewline  " '$nome_programa $programVersionAnterior' " -ForegroundColor Cyan
                                Write-Host -NoNewline  "$($global:translations["PPMISFinishingStep"])" -ForegroundColor Yellow
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
                                    Write-Host -NoNewline  "      $($global:translations["PPMUSFailProcessUninstall"])" -ForegroundColor Red
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

                            Write-Host -NoNewline "      $($global:translations["PPMISConfirmedOf"])" -ForegroundColor Yellow
                            Write-Host -NoNewline  " '$nome_programa' " -ForegroundColor Cyan
                            Write-Host -NoNewline  "$($global:translations["PPMUSUninstallAndVerify"])" -ForegroundColor Yellow
                            Write-Host ""
                            Write-Host ""

                            $remocao_completa = Read-Host "      $($global:translations["PPMUSUninstallVerifyOf"]) $nome_programa ? $($global:translations["PPMUSYesOrNot"])"

                            if(($idiomaSelecionado -eq "pt" -and $remocao_completa -eq "S" -or $remocao_completa -eq "N") -or ($idiomaSelecionado -eq "en" -and $remocao_completa -eq "Y" -or $remocao_completa -eq "N") -or ($idiomaSelecionado -eq "es" -and $remocao_completa -eq "S" -or $remocao_completa -eq "N")){

                                # Verifica se a pasta ainda existe
                                if (Test-Path $folderFound) {

                                    Write-Host ""
                                    Write-Host "      $($global:translations["PPMUSUninstallFailedOrNotCompleteN1"])" -ForegroundColor Yellow
                                    write-Host "      $($global:translations["PPMUSProcessNotAvailableExecuteOrNotInstalled"])" -ForegroundColor Red
                                    Write-Host ""

                                    if ( $EtapaInstAtv ) { Start-Sleep -Seconds 5 }

                                } elseif(Test-Path $folderFoundAtual) {
                                    Write-Host ""
                                    Write-Host "      $($global:translations["PPMUSUninstallFailedOrNotCompleteN2"])" -ForegroundColor Yellow
                                    write-Host "      $($global:translations["PPMUSProcessNotAvailableExecuteOrNotInstalled"])" -ForegroundColor Red
                                    Write-Host ""
                                
                                   if ( $EtapaInstAtv ) { Start-Sleep -Seconds 5 }

                                } else {

                                    Write-Host ""
                                    Write-Host "      $($global:translations["PPMUSUnisntallOf"]) $nome_programa $($global:translations["PPMUSUnisntallWasFinishSuccessfull"])" -ForegroundColor Green
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
                            Write-Host "$($global:translations["PPMISTheProcess"]) $($processNames -join ', ') $($global:translations["PPMISIsExecuted"])" -ForegroundColor Yellow
                            Write-Host "$($global:translations["PPMUSClosingProcessUninstallation"])" -ForegroundColor Red
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
                                Write-Host -NoNewline "      $($global:translations["PPMUSFullUninstallOf"])" -ForegroundColor Yellow
                                Write-Host -NoNewline " '$nome_programa $versao_disponivel' " -ForegroundColor Cyan
                                Write-Host -NoNewline "$($global:translations["PPMISStartingStep"])" -ForegroundColor Yellow
                                Write-Host ""
                                Write-Host ""
                                Write-Host "      $($global:translations["PPMUSOpeningUninstallOf"]) $nome_programa..." -ForegroundColor Green  
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
                                        Write-Host -NoNewline "      $($global:translations["PPMUSWaitProcessUninstall"])" -ForegroundColor Yellow
                                        Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                                        Write-Host -NoNewline "$($global:translations["PPMISFinishingStep"])" -ForegroundColor Yellow
                                        Write-Host ""

                                    } else {

                                        Remove-Item -Recurse -Force $destino_atv_key

                                        Write-Host ""
                                        Write-Host -NoNewline "      $($global:translations["PPMUSWaitProcessUninstall"])" -ForegroundColor Yellow
                                        Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                                        Write-Host -NoNewline "$($global:translations["PPMISFinishingStep"])" -ForegroundColor Yellow
                                        Write-Host ""
                                    }

                                } else {

                                    Write-Host ""
                                    Write-Host -NoNewline "      $($global:translations["PPMUSWaitProcessUninstall"])" -ForegroundColor Yellow
                                    Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                                    Write-Host -NoNewline "$($global:translations["PPMISFinishingStep"])" -ForegroundColor Yellow
                                    Write-Host ""
                    
                                }

                                # Inciando o processo de desinstalação e aguardando sua conclusão
                                Start-Process -FilePath $exePath_unis_atual -PassThru -Wait

                            } else {

                                Write-Host ""
                                Write-Host "     ===============================================================================================================" -ForegroundColor Green
                                Write-Host ""
                                Write-Host -NoNewline "      $($global:translations["PPMUSUninstallCompleteOf"])" -ForegroundColor Yellow
                                Write-Host -NoNewline " '$nome_programa $programVersionAnterior' " -ForegroundColor Cyan
                                Write-Host -NoNewline "$($global:translations["PPMISStartingStep"])" -ForegroundColor Yellow
                                Write-Host ""
                                Write-Host ""
                                Write-Host "      $($global:translations["PPMUSOpeningUninstallOf"]) $nome_programa..." -ForegroundColor Green  
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
                                        Write-Host -NoNewline "      $($global:translations["PPMUSWaitProcessUninstall"])" -ForegroundColor Yellow
                                        Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                                        Write-Host -NoNewline "$($global:translations["PPMISFinishingStep"])" -ForegroundColor Yellow
                                        Write-Host ""

                                    } else {

                                        Remove-Item -Recurse -Force $destino_atv_key

                                        Write-Host ""
                                        Write-Host -NoNewline "      $($global:translations["PPMUSWaitProcessUninstall"])" -ForegroundColor Yellow
                                        Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                                        Write-Host -NoNewline "$($global:translations["PPMISFinishingStep"])" -ForegroundColor Yellow
                                        Write-Host ""
                                    }

                                } else {

                                    Write-Host ""
                                    Write-Host -NoNewline "      $($global:translations["PPMUSWaitProcessUninstall"])" -ForegroundColor Yellow
                                    Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                                    Write-Host -NoNewline "$($global:translations["PPMISFinishingStep"])" -ForegroundColor Yellow
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
                                Write-Host -NoNewline "      $($global:translations["PPMUSUninstallCompleteOf"])" -ForegroundColor Yellow
                                Write-Host -NoNewline " '$nome_programa $versao_disponivel' " -ForegroundColor Cyan
                                Write-Host -NoNewline "$($global:translations["PPMISStartingStep"])" -ForegroundColor Yellow
                                Write-Host ""
                                Write-Host ""
                                Write-Host "      $($global:translations["PPMUSOpeningUninstallOf"]) $nome_programa..." -ForegroundColor Green  
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
                                        Write-Host -NoNewline "      $($global:translations["PPMUSWaitProcessUninstall"])" -ForegroundColor Yellow
                                        Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                                        Write-Host -NoNewline "$($global:translations["PPMISFinishingStep"])" -ForegroundColor Yellow
                                        Write-Host ""

                                    } else {

                                        Remove-Item -Recurse -Force $destino_atv_key

                                        Write-Host ""
                                        Write-Host -NoNewline "      $($global:translations["PPMUSWaitProcessUninstall"])" -ForegroundColor Yellow
                                        Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                                        Write-Host -NoNewline "$($global:translations["PPMISFinishingStep"])" -ForegroundColor Yellow
                                        Write-Host ""
                                    }

                                } else {

                                    Write-Host ""
                                    Write-Host -NoNewline "      $($global:translations["PPMUSWaitProcessUninstall"])" -ForegroundColor Yellow
                                    Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                                    Write-Host -NoNewline "$($global:translations["PPMISFinishingStep"])" -ForegroundColor Yellow
                                    Write-Host ""
                    
                                }

                                # Inciando o processo de desinstalação e aguardando sua conclusão
                                Start-Process -FilePath $exePath_unis_atual -PassThru -Wait

                            } else {

                                Write-Host ""
                                Write-Host "     ===============================================================================================================" -ForegroundColor Green
                                Write-Host ""
                                Write-Host -NoNewline "      $($global:translations["PPMUSFullUninstallOf"])" -ForegroundColor Yellow
                                Write-Host -NoNewline " '$nome_programa $programVersionAnterior' " -ForegroundColor Cyan
                                Write-Host -NoNewline "$($global:translations["PPMISStartingStep"])." -ForegroundColor Yellow
                                Write-Host ""
                                Write-Host ""
                                Write-Host "      $($global:translations["PPMUSOpeningUninstallOf"]) $nome_programa..." -ForegroundColor Green  
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
                                        Write-Host -NoNewline "      $($global:translations["PPMUSWaitProcessUninstall"])" -ForegroundColor Yellow
                                        Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                                        Write-Host -NoNewline "$($global:translations["PPMISFinishingStep"])" -ForegroundColor Yellow
                                        Write-Host ""

                                    } else {

                                        Remove-Item -Recurse -Force $destino_atv_key

                                        Write-Host ""
                                        Write-Host -NoNewline "      $($global:translations["PPMUSWaitProcessUninstall"])" -ForegroundColor Yellow
                                        Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                                        Write-Host -NoNewline "$($global:translations["PPMISFinishingStep"])" -ForegroundColor Yellow
                                        Write-Host ""
                                    }

                                } else {

                                    Write-Host ""
                                    Write-Host -NoNewline "      $($global:translations["PPMUSWaitProcessUninstall"])" -ForegroundColor Yellow
                                    Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                                    Write-Host -NoNewline "$($global:translations["PPMISFinishingStep"])" -ForegroundColor Yellow
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
                                Write-Host -NoNewline  "      $($global:translations["PPMUSFailProcessUninstall"])" -ForegroundColor Red
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
                        Write-Host -NoNewline "      $($global:translations["PPMISConfirmedOf"])" -ForegroundColor Yellow
                        Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                        Write-Host -NoNewline "$($global:translations["PPMUSUninstallAndVerify"])" -ForegroundColor Yellow
                        Write-Host ""
                        Write-Host ""

                        $remocao_completa = Read-Host "      $($global:translations["PPMUSUninstallVerifyOf"]) $nome_programa ? $($global:translations["PPMUSYesOrNot"])"
                   
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

                        if(($idiomaSelecionado -eq "pt" -and $remocao_completa -eq "S" -or $remocao_completa -eq "N") -or ($idiomaSelecionado -eq "en" -and $remocao_completa -eq "Y" -or $remocao_completa -eq "N") -or ($idiomaSelecionado -eq "es" -and $remocao_completa -eq "S" -or $remocao_completa -eq "N")){

                            # Verifica se a pasta ainda existe
                            if (((Test-Path $folderFound) -and $subFoundInProgramFound.Count -ge 1 -and $filesInProgramFound.Count -ge 1 -or $filesInfolderFound.Count -ge 1) -or ((Test-Path $folderFound) -and $filesInfolderFound.Count -ge 1)) {
                            
                                Write-Host -NoNewline "      $($global:translations["PPMUSYour"])" -ForegroundColor Green
                                Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                                Write-Host -NoNewline "$($global:translations["PPMUSUninstallWasPartial"])" -ForegroundColor Green
                                Write-Host ""
                                Write-Host ""
                                write-Host -NoNewline "      $($global:translations["PPMUSNeedRestartUninstallComplete"])" -ForegroundColor Yellow
                                Write-Host ""
                                write-Host -NoNewline "      $($global:translations["PPMUSBackupConfigAndCostumization"])" -ForegroundColor Yellow
                                Write-Host ""
                                write-Host -NoNewline "      $($global:translations["PPMUSHaveProductInstalledDeveloper"])" -ForegroundColor Yellow
                                Write-Host ""
                                Write-Host ""
                                
                                if ( $EtapaInstAtv ) { Start-Sleep -Seconds 5 }

                            } elseif (((Test-Path $folderFoundProgramAtual) -and $subfoldersProgramAtual.Count -ge 1 -and $filesInProgramAtual.Count -ge 1 -or $filesInfolderFoundAtual.Count -ge 1) -or ((Test-Path $folderFoundProgramAtual) -and $filesInfolderFoundAtual.Count -ge 1) -or ((Test-Path $folderFoundProgramAtual))) {
                            
                                Write-Host -NoNewline "      $($global:translations["PPMUSYour"])" -ForegroundColor Green
                                Write-Host -NoNewline " '$nome_programa' " -ForegroundColor Cyan
                                Write-Host -NoNewline "$($global:translations["PPMUSUninstallWasPartial"])" -ForegroundColor Green
                                Write-Host ""
                                Write-Host ""
                                write-Host -NoNewline "      $($global:translations["PPMUSNeedRestartUninstallComplete"])" -ForegroundColor Yellow
                                Write-Host ""
                                write-Host -NoNewline "      $($global:translations["PPMUSBackupConfigAndCostumization"])" -ForegroundColor Yellow
                                Write-Host ""
                                write-Host -NoNewline "      $($global:translations["PPMUSHaveProductInstalledDeveloper"])" -ForegroundColor Yellow
                                Write-Host ""
                                Write-Host ""
                                
                                if ( $EtapaInstAtv ) { Start-Sleep -Seconds 5 }

                            } else {
                                Write-Host "      $($global:translations["PPMUSUnisntallOf"]) '$nome_programa' $($global:translations["PPMUSUnisntallWasFinishSuccessfull"])" -ForegroundColor Green
                                Write-Host ""

                                if ( $EtapaInstAtv ) { Start-Sleep -Seconds 5 }
                            }
                        }
                    } else {
                        
                        Write-Host ""
                        Write-Host "      $($global:translations["PPMUSUninstallCanceled"])" -ForegroundColor Red
                        Write-Host ""

                        if ( $EtapaInstAtv ) { Start-Sleep -Seconds 5 }
                    }


                }
                
            } 
                
        } else {

            Write-Host ""
            Write-Host "      $($global:translations["PPMISTheProgram"]) $nome_programa $versao_disponivel $($global:translations["PPMUSNotIsInstalled"])" -ForegroundColor Red
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

function StartLoadingApp {

    Get-LanguageConfig | Out-Null
    
    # Seleciona o idioma inicial no arquivo de configuração
    $idiomaSelecionado = $global:language
    
    Update-Title-WindowMenu -menuKey "CARREGAMENTO INICIAL PARA VERIFICAÇÃO DE REQUISITOS" -idiomaSelecionado $idiomaSelecionado # Atualiza o título para o menu principal

    # Traduções
    $SLAMInitialLoadingCheckingTitleMenu = Translate-Text -Text "CARREGAMENTO INICIAL PARA VERIFICAÇÃO DE REQUISITOS" -TargetLanguage $idiomaSelecionado
    $SLAMSubtitleDependencies = Translate-Text -Text "DEPENDÊNCIAS" -TargetLanguage $idiomaSelecionado
    $SLAMSubtitleTranslationLanguage = Translate-Text -Text "TRADUÇÃO E CONFIGURAÇÃO DO IDIOMA" -TargetLanguage $idiomaSelecionado
    $SLAMSubtitleVersionAvailableUpdate = Translate-Text -Text "VERSÃO DISPONÍVEL PARA ATUALIZAÇÃO" -TargetLanguage $idiomaSelecionado

    $fixedWidthMenuStartLoadingApp = 120  # Largura total da linha

    # Frase a ser centralizada
    $menuStartLoadingAppTexto = $SLAMInitialLoadingCheckingTitleMenu
    $menuStartLoadingAppTextoLength = $menuStartLoadingAppTexto.Length

    # Calcula o número de espaços necessários para centralizar
    $spacesNeededMenuStartLoadingApp = [Math]::Max(([Math]::Floor(($fixedWidthMenuStartLoadingApp - $menuStartLoadingAppTextoLength) / 2)), 0)
    $spacesMenuStartLoadingApp = " " * $spacesNeededMenuStartLoadingApp

    Write-Host ""
    Write-Host ""
    Write-Host "     ================================================================================================================" -ForegroundColor Green
    Write-Host "$spacesMenuStartLoadingApp$menuStartLoadingAppTexto" -ForegroundColor Cyan
    Write-Host "     ================================================================================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "     ================================================================================================================" -ForegroundColor Gray
    Write-Host "" 
    # Verificação inicial de requisitos
    Write-Host -NoNewline "     1 - " -ForegroundColor Yellow
    Write-Host -NoNewline "$($SLAMSubtitleDependencies):" -ForegroundColor Cyan
    Write-Host ""
    Write-Host ""
    Check-Chocolatey
    Check-WinRAR
    Write-Host ""
    Write-Host "     ================================================================================================================" -ForegroundColor Gray
    # Inicializa o idioma global e traduções antes de executar o menu principal
    Write-Host ""
    Write-Host -NoNewline "     2 - " -ForegroundColor Yellow
    Write-Host -NoNewline "$($SLAMSubtitleTranslationLanguage):" -ForegroundColor Cyan
    Write-Host ""
    Initialize-Language
    Write-Host ""
    Write-Host "     ================================================================================================================" -ForegroundColor Gray
    Write-Host ""
    Write-Host -NoNewline "     3 - " -ForegroundColor Yellow
    Write-Host -NoNewline "$($SLAMSubtitleVersionAvailableUpdate):" -ForegroundColor Cyan
    Write-Host ""
    Write-Host ""
    Check-Version-App

}

StartLoadingApp

# Abre o menu principal
Show-Menu
