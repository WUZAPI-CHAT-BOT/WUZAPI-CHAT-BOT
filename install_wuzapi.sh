#!/data/data/com.termux/files/usr/bin/bash

# Caminho do arquivo de log atualizado
LOG_FILE="/storage/emulated/0/Tasker/termux/TASKER-WUZAPI/logs/install.log"

# Variável de controle para o log
LOGGING_ENABLED=1

# Verificar e criar o arquivo de log
if [ ! -f "$LOG_FILE" ]; then
    mkdir -p "$(dirname "$LOG_FILE")" || { echo "Erro ao criar o diretório de logs."; exit 1; }
    touch "$LOG_FILE" || { echo "Erro ao criar o arquivo de log."; exit 1; }
else
    > "$LOG_FILE"  # Limpar o conteúdo do arquivo existente
fi

# Função para registrar mensagens no log
log_message() {
    if [ "$LOGGING_ENABLED" -eq 1 ]; then
        echo "$1" >> "$LOG_FILE"
    fi
}

# Função para monitorar a saída
monitor_output() {
    while IFS= read -r line; do
        echo "$line"  # Mostrar a saída no terminal
        log_message "$line"  # Registrar no log se habilitado
    done
}

# Redirecionar para o diretório home do Termux
cd /data/data/com.termux/files/home

echo "A INSTALACAO PODE LEVAR ATE 10 MINUTOS POR FAVOR AGUARDE O PROCESSO FINALIZAR"
log_message ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

              🚀  INICIANDO PROCESSO DE CONFIGURACAO 🚀
                         DO TASKER-WUZAPI-CHATBOT
       

              👋   BEM-VINDO AO TASKER-WUZAPI-CHATBOT   👋          


                  A INSTALACAO PODE LEVAR ATE 10 MINUTOS
                  POR FAVOR AGUARDE O PROCESSO FINALIZAR

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
"
# Remover diretório existente se já estiver presente
if [ -d "WUZAPI-CHAT-BOT" ]; then
    rm -rf WUZAPI-CHAT-BOT
    echo "DIRETÓRIO WUZAPI-CHAT-BOT REMOVIDO PARA SER SUBSTITUÍDO"
    log_message "DIRETÓRIO WUZAPI-CHAT-BOT REMOVIDO PARA SER SUBSTITUÍDO"
fi

# Atualizar pacotes e instalar os pacotes necessários
echo "ATUALIZANDO PACOTES E INSTALANDO DEPENDÊNCIAS BÁSICAS"
log_message "ATUALIZANDO PACOTES E INSTALANDO DEPENDÊNCIAS BÁSICAS"
DEBIAN_FRONTEND=noninteractive pkg upgrade -o Dpkg::Options::="--force-confnew" -y 2>&1 | while IFS= read -r line; do monitor_output <<< "$line"; done

echo "INSTALANDO GIT, GOLANG E FFMPEG"
log_message "INSTALANDO GIT, GOLANG E FFMPEG"
yes | DEBIAN_FRONTEND=noninteractive pkg install -y git golang ffmpeg 2>&1 | while IFS= read -r line; do monitor_output <<< "$line"; done

# Clonar o repositório WUZAPI-CHAT-BOT
echo "CLONANDO REPOSITÓRIO WUZAPI-CHAT-BOT....."
log_message "CLONANDO REPOSITÓRIO WUZAPI-CHAT-BOT....."
git clone https://github.com/WUZAPI-CHAT-BOT/WUZAPI-CHAT-BOT 2>&1 | while IFS= read -r line; do monitor_output <<< "$line"; done

# Navegar até o diretório do projeto
echo "ACESSANDO DIRETÓRIO DO PROJETO WUZAPI-CHAT-BOT"
log_message "ACESSANDO DIRETÓRIO DO PROJETO WUZAPI-CHAT-BOT"
cd WUZAPI-CHAT-BOT || { 
    echo "ERRO AO ACESSAR O DIRETÓRIO DO PROJETO WUZAPI-CHAT-BOT"; 
    log_message "ERRO AO ACESSAR O DIRETÓRIO DO PROJETO WUZAPI-CHAT-BOT"; 
    exit 1; 
}

# Compilar o binário do WuzAPI
echo "COMPILANDO BINÁRIO"
log_message "COMPILANDO BINÁRIO"
go build . 2>&1 | while IFS= read -r line; do monitor_output <<< "$line"; done

# Dar permissões de execução ao binário e ao script de inicialização
chmod +x wuzapi
if [ -f "./start_wuzapi.sh" ]; then
    chmod +x start_wuzapi.sh
fi

# Conceder permissões para aplicativos externos no Termux
echo "Configurando permissões para aplicativos externos no Termux..."
log_message "Configurando permissões para aplicativos externos no Termux..."
mkdir -p ~/.termux && echo "allow-external-apps=true" >> ~/.termux/termux.properties
termux-reload-settings 2>&1 | while IFS= read -r line; do monitor_output <<< "$line"; done

# Executar WuzAPI
echo "EXECUTANDO API DO WUZAPI"
log_message "EXECUTANDO API DO WUZAPI"
./wuzapi 2>&1 | while IFS= read -r line; do monitor_output <<< "$line"; done
