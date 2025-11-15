------------------------------------------------------------
-- HELPSEEK DATABASE - VERSÃO UNIFICADA 2025
-- Inclui: estrutura completa + dados base + IA (S01, S02, S03)
------------------------------------------------------------

-- 🧹 1️⃣ Recriação do Banco
IF DB_ID('HelpSeek') IS NOT NULL
BEGIN
    ALTER DATABASE HelpSeek SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE HelpSeek;
END
GO
CREATE DATABASE HelpSeek;
GO
USE HelpSeek;
GO

------------------------------------------------------------
-- 2️⃣ TABELAS BASE
------------------------------------------------------------
CREATE TABLE dbo.Usuarios (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Nome NVARCHAR(200) NOT NULL,
    Email NVARCHAR(200) NOT NULL,
    Papel NVARCHAR(50) NOT NULL,
    SenhaHash NVARCHAR(200) NOT NULL,
    Departamento NVARCHAR(100) NULL
);
GO

CREATE TABLE dbo.Status (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Nome NVARCHAR(100) NOT NULL
);
GO

CREATE TABLE dbo.Categorias (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Nome NVARCHAR(150) NOT NULL
);
GO

CREATE TABLE dbo.Prioridades (
    PrioridadeId INT IDENTITY(1,1) PRIMARY KEY,
    Nivel NVARCHAR(100) NOT NULL
);
GO

CREATE TABLE dbo.Sistemas (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Nome NVARCHAR(150) NOT NULL
);
GO

CREATE TABLE dbo.Chamados (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Titulo NVARCHAR(250) NOT NULL,
    Descricao NVARCHAR(MAX) NULL,
    UsuarioId INT NOT NULL,
    StatusId INT NOT NULL,
    CategoriaId INT NOT NULL,
    PrioridadeId INT NOT NULL,
    SistemaOrigemId INT NULL,
    EmailUsuario NVARCHAR(200) NULL,
    ResponsavelId INT NULL,
    PontuacaoConfiancaIA DECIMAL(5,2) NULL,
    CriadoEm DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    AtualizadoEm DATETIME2 NULL,
    CONSTRAINT FK_Chamados_Usuarios FOREIGN KEY (UsuarioId) REFERENCES dbo.Usuarios(Id),
    CONSTRAINT FK_Chamados_Status FOREIGN KEY (StatusId) REFERENCES dbo.Status(Id),
    CONSTRAINT FK_Chamados_Categorias FOREIGN KEY (CategoriaId) REFERENCES dbo.Categorias(Id),
    CONSTRAINT FK_Chamados_Prioridades FOREIGN KEY (PrioridadeId) REFERENCES dbo.Prioridades(PrioridadeId),
    CONSTRAINT FK_Chamados_Sistemas FOREIGN KEY (SistemaOrigemId) REFERENCES dbo.Sistemas(Id),
    CONSTRAINT FK_Chamados_Responsavel FOREIGN KEY (ResponsavelId) REFERENCES dbo.Usuarios(Id)
);
GO

CREATE TABLE dbo.Interacoes (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    ChamadoId INT NOT NULL,
    UsuarioId INT NOT NULL,
    Origem NVARCHAR(50) NOT NULL,
    Mensagem NVARCHAR(MAX) NOT NULL,
    CriadoEm DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_Interacoes_Chamados FOREIGN KEY (ChamadoId) REFERENCES dbo.Chamados(Id),
    CONSTRAINT FK_Interacoes_Usuarios FOREIGN KEY (UsuarioId) REFERENCES dbo.Usuarios(Id)
);
GO

CREATE TABLE dbo.Feedbacks (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    ChamadoId INT NOT NULL,
    UsuarioId INT NOT NULL,
    Nota INT NOT NULL CHECK (Nota BETWEEN 1 AND 5),
    Comentario NVARCHAR(MAX) NULL,
    CriadoEm DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_Feedbacks_Chamados FOREIGN KEY (ChamadoId) REFERENCES dbo.Chamados(Id),
    CONSTRAINT FK_Feedbacks_Usuarios FOREIGN KEY (UsuarioId) REFERENCES dbo.Usuarios(Id)
);
GO

------------------------------------------------------------
-- 3️⃣ TABELAS AUXILIARES (IA e LOGS)
------------------------------------------------------------
CREATE TABLE dbo.Solucoes (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    ChamadoId INT NOT NULL,
    Sugestao NVARCHAR(MAX) NOT NULL,
    CriadaPorIA BIT NOT NULL DEFAULT 0,
    CriadoEm DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_Solucoes_Chamados FOREIGN KEY (ChamadoId)
        REFERENCES dbo.Chamados(Id)
);
GO

CREATE TABLE dbo.LogsChamado (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    ChamadoId INT NOT NULL,
    AlteradoPor INT NULL,
    CampoAlterado NVARCHAR(100) NOT NULL,
    ValorAntigo NVARCHAR(MAX) NULL,
    ValorNovo NVARCHAR(MAX) NULL,
    AlteradoEm DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_Logs_Chamados FOREIGN KEY (ChamadoId)
        REFERENCES dbo.Chamados(Id)
);
GO

------------------------------------------------------------
-- 4️⃣ POPULAR DADOS INICIAIS
------------------------------------------------------------

-- STATUS
INSERT INTO dbo.Status (Nome)
VALUES ('Aberto'), ('Em Andamento'), ('Em Resolução'), ('Resolvido');

-- CATEGORIAS
INSERT INTO dbo.Categorias (Nome)
VALUES ('Infraestrutura'), ('Aplicação'), ('Suporte Geral'), ('Impressora'), ('Rede');

-- PRIORIDADES
INSERT INTO dbo.Prioridades (Nivel)
VALUES ('Alta'), ('Média'), ('Baixa');

-- SISTEMAS
INSERT INTO dbo.Sistemas (Nome)
VALUES ('Portal Interno'),
       ('Aplicativo HelpSeek'),
       ('Servidor de E-mail'),
       ('Rede Corporativa'),
       ('Sistema de Impressão');

-- USUÁRIOS PADRÃO
DECLARE @AdminHash NVARCHAR(200) = LOWER(CONVERT(VARCHAR(200), HASHBYTES('SHA2_256', LOWER('admin@helpseek.local') + ':' + 'admin123'), 2));
DECLARE @TecHash   NVARCHAR(200) = LOWER(CONVERT(VARCHAR(200), HASHBYTES('SHA2_256', LOWER('tecnico@helpseek.local') + ':' + 'tech123'), 2));
DECLARE @ColabHash NVARCHAR(200) = LOWER(CONVERT(VARCHAR(200), HASHBYTES('SHA2_256', LOWER('colaborador@helpseek.local') + ':' + 'colab123'), 2));
DECLARE @IAHash NVARCHAR(200) = LOWER(CONVERT(VARCHAR(200), HASHBYTES('SHA2_256', LOWER('ia_user@helpseek.local') + ':' + 'test123'), 2));

INSERT INTO dbo.Usuarios (Nome, Email, Papel, SenhaHash, Departamento)
VALUES
('Admin', 'admin@helpseek.local', 'Administrador', @AdminHash, 'TI'),
('Tecnico Demo', 'tecnico@helpseek.local', 'Tecnico', @TecHash, 'Suporte'),
('Colaborador Demo', 'colaborador@helpseek.local', 'Colaborador', @ColabHash, 'Geral'),
('IA User', 'ia_user@helpseek.local', 'Colaborador', @IAHash, 'Teste');
GO

------------------------------------------------------------
-- 5️⃣ INSERÇÃO DOS CENÁRIOS DE IA
------------------------------------------------------------
USE HelpSeek;
GO

------------------------------------------------------------
-- ✅ INSERÇÃO DOS CENÁRIOS DE IA (corrigido)
------------------------------------------------------------

DECLARE @UsuarioIA INT = (SELECT TOP 1 Id FROM dbo.Usuarios WHERE Email='ia_user@helpseek.local');

-- 🔹 S01 – Triagem automática (Impressora)
INSERT INTO dbo.Chamados
(Titulo, Descricao, UsuarioId, CategoriaId, PrioridadeId, StatusId, PontuacaoConfiancaIA)
VALUES
('Impressora HP LaserJet não imprime e pisca luz vermelha',
 'Após trocar o toner... Código de erro E3 no painel.',
 @UsuarioIA,
 (SELECT TOP 1 Id FROM dbo.Categorias WHERE Nome='Impressora'),
 (SELECT TOP 1 PrioridadeId FROM dbo.Prioridades WHERE Nivel='Média'),
 (SELECT TOP 1 Id FROM dbo.Status WHERE Nome='Aberto'),
 0.87);

DECLARE @Chamado1 INT = SCOPE_IDENTITY();

INSERT INTO dbo.Solucoes (ChamadoId, Sugestao, CriadaPorIA)
VALUES (@Chamado1,
 'Remover e reinstalar o cartucho; verificar aba de proteção; reset básico 30s.', 1);

INSERT INTO dbo.LogsChamado (ChamadoId, AlteradoPor, CampoAlterado, ValorAntigo, ValorNovo)
VALUES (@Chamado1, 1, 'ClassificacaoIA', NULL,
 '{"categoria":"Impressora","prioridade":"Média","confidence":0.87}');
GO

DECLARE @UsuarioIA INT = (SELECT TOP 1 Id FROM dbo.Usuarios WHERE Email='ia_user@helpseek.local');

-- 🔹 S02 – FAQ dinâmica (Senha Outlook)
INSERT INTO dbo.Chamados
(Titulo, Descricao, UsuarioId, CategoriaId, PrioridadeId, StatusId, PontuacaoConfiancaIA)
VALUES
('Esqueci a senha do e-mail corporativo',
 'Perdi o acesso ao Outlook e não lembro a senha. Posso redefinir sem abrir chamado?',
 @UsuarioIA,
 (SELECT TOP 1 Id FROM dbo.Categorias WHERE Nome='Suporte Geral'),
 (SELECT TOP 1 PrioridadeId FROM dbo.Prioridades WHERE Nivel='Média'),
 (SELECT TOP 1 Id FROM dbo.Status WHERE Nome='Aberto'),
 0.92);

DECLARE @Chamado2 INT = SCOPE_IDENTITY();

INSERT INTO dbo.Solucoes (ChamadoId, Sugestao, CriadaPorIA)
VALUES (@Chamado2,
 'Acesse o Portal SSO e redefina sua senha com CPF e token Auth. Caso não possua, abra chamado para o time de Identidade.', 1);

INSERT INTO dbo.LogsChamado (ChamadoId, AlteradoPor, CampoAlterado, ValorAntigo, ValorNovo)
VALUES (@Chamado2, 1, 'FAQSugerida', NULL,
 '{"pergunta":"Como redefinir senha do e-mail corporativo (Outlook)?","tags":["senha","Outlook","SSO"],"confidence":0.92}');
GO

DECLARE @UsuarioIA INT = (SELECT TOP 1 Id FROM dbo.Usuarios WHERE Email='ia_user@helpseek.local');

-- 🔹 S03 – Auto-resolve de rede (Switch SG-108)
INSERT INTO dbo.Chamados
(Titulo, Descricao, UsuarioId, CategoriaId, PrioridadeId, StatusId, PontuacaoConfiancaIA)
VALUES
('Sem internet no setor de vendas',
 'As estações do setor 3 perderam conexão após queda de energia. Switch SG-108 com luz laranja piscando.',
 @UsuarioIA,
 (SELECT TOP 1 Id FROM dbo.Categorias WHERE Nome='Rede'),
 (SELECT TOP 1 PrioridadeId FROM dbo.Prioridades WHERE Nivel='Média'),
 (SELECT TOP 1 Id FROM dbo.Status WHERE Nome='Aberto'),
 0.81);

DECLARE @Chamado3 INT = SCOPE_IDENTITY();

INSERT INTO dbo.Solucoes (ChamadoId, Sugestao, CriadaPorIA)
VALUES (@Chamado3,
 'Verifique modem principal; reinicie o switch SG-108; teste cabo uplink; se persistir, abrir chamado urgente relatando “uplink possivelmente danificado”.', 1);

INSERT INTO dbo.LogsChamado (ChamadoId, AlteradoPor, CampoAlterado, ValorAntigo, ValorNovo)
VALUES (@Chamado3, 1, 'AutoResolveIA', NULL,
 '{"passos":4,"tempo_execucao_min":4,"confidence":0.81}');
GO

------------------------------------------------------------
-- 🔎 VERIFICAÇÃO FINAL
------------------------------------------------------------
SELECT COUNT(*) AS TotalChamados FROM dbo.Chamados;
SELECT Titulo, PontuacaoConfiancaIA FROM dbo.Chamados ORDER BY Id DESC;
SELECT * FROM dbo.Solucoes ORDER BY Id DESC;
SELECT * FROM dbo.LogsChamado ORDER BY Id DESC;
GO
