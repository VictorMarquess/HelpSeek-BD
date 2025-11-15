# 🗄️ HelpSeek-BD  
Banco de Dados oficial do Sistema de Chamados **HelpSeek**

Este repositório contém todo o material referente ao **banco de dados SQL Server** utilizado pelas versões **Desktop**, **Web**, **Mobile** e pela **API HelpSeek**.

---

## 🧱 Tecnologias e Ferramentas

- 💽 **SQL Server 2019+**
- 🛠️ **SQL Server Management Studio (SSMS)**
- 🔌 **ADO.NET / EF Core**
- 🧾 **Scripts .sql**
- 🌱 **Migrations opcionais (EF Core)**

---

## 🗂️ Estrutura do Banco de Dados

O banco se chama:

HelpSeek

markdown
Copiar código

E utiliza as seguintes tabelas principais:

| Tabela | Descrição |
|--------|-----------|
| **Usuarios** | Armazena dados de login e perfis (Colaborador, Técnico, Administrador) |
| **Chamados** | Registra abertura de chamados com título, descrição, status e prioridade |
| **Interacoes** | Histórico de mensagens entre colaborador e técnico |
| **Feedbacks** | Avaliação do atendimento |
| **Anexos** *(opcional)* | Arquivos enviados junto ao chamado |

---

## 🔗 Relações Principais

- **Usuarios (1) → (N) Chamados**  
- **Chamados (1) → (N) Interacoes**  
- **Chamados (1) → (1) Feedback**
