# Fedora Post-Install Setup Script

![Bash](https://img.shields.io/badge/Shell-Bash-4EAA25?logo=gnu-bash)
![Fedora](https://img.shields.io/badge/OS-Fedora-51A2DA?logo=fedora)

Script de automação para configuração inicial do Fedora Linux com instalação de softwares essenciais.

## 🗂 Visão Geral

### Funcionalidades Principais
- Configuração automática do DNF
- Instalação de repositórios RPM Fusion
- Atualização completa do sistema
- Instalação de softwares populares
- Configuração de fonts Microsoft

### Requisitos
- Fedora 36 ou superior
- Acesso root (sudo)
- Conexão com internet

## 📦 Componentes Instalados

| Categoria         | Softwares/Configurações               |
|-------------------|----------------------------------------|
| Virtualização     | VirtualBox 6.1 + Drivers               |
| Terminais         | Warp Terminal                          |
| Multimídia        | Spotify, Stremio, Codecs               |
| Comunicação       | Telegram Desktop                       |
| Fontes            | Pacote Microsoft Core Fonts            |
| Otimizações       | Configuração DNF (mirrors/paralelismo) |

## 📊 Sistema de Logs
- Arquivo: `/var/log/fedora_setup.log`
- Registro detalhado com timestamps
- Níveis de log:
  - `INFO`: Operações bem-sucedidas
  - `WARNING`: Alertas não críticos
  - `ERROR`: Falhas graves

## ⚙️ Controle de Erros
- Verificação de compatibilidade do sistema
- Interrupção segura com `Ctrl+C`
- Rollback automático de operações incompletas
- Validação de etapas críticas

## 🔧 Personalização
Modifique no script:
```bash
# Local do log
LOG_FILE="/caminho/alternativo.log"

# Configurações do DNF
max_parallel_downloads=10
fastestmirror=true

# Comentar aplicativos não desejados na função main()
```

## ⚠️ Observações Importantes
1. VirtualBox requer rebuild dos módulos de kernel
2. Sistemas ostree podem ter problemas com Warp Terminal
3. Recomendado reinicialização após instalação

## 📜 Licença
[MIT License](https://opensource.org/licenses/MIT)
