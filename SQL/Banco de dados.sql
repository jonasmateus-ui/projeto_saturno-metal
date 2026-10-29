-- =====================================================================
-- PROJETO ERP - SPACE METAL (Serralheria)
-- Modelagem de Dados - UNICID - Prof. Clovis Ferraro
-- =====================================================================

CREATE DATABASE IF NOT EXISTS Space_Metal
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;
USE Space_Metal;

-- =====================================================================
-- PARTE 1 - ENTIDADES INDEPENDENTES
-- =====================================================================

CREATE TABLE cliente (
    cpf_cnpj     VARCHAR(14)  PRIMARY KEY
                 CHECK (CHAR_LENGTH(cpf_cnpj) = 11 OR CHAR_LENGTH(cpf_cnpj) = 14),
    nome         VARCHAR(30)  NOT NULL, 
    sobrenome    VARCHAR(50)  NOT NULL, 
    email        VARCHAR(60),          
    cep          VARCHAR(9),
    rua          VARCHAR(60),          
    numero       VARCHAR(10),          
    complemento  VARCHAR(30),          
    bairro       VARCHAR(40),          
    cidade       VARCHAR(40),          
    uf           CHAR(2),
    ddd          VARCHAR(2)   NOT NULL,
    telefone     VARCHAR(9)
);

CREATE TABLE fornecedor (
    id_fornecedor INT AUTO_INCREMENT PRIMARY KEY,
    nome          VARCHAR(50)  NOT NULL, 
    cnpj          CHAR(14)     NOT NULL UNIQUE,
    telefone      VARCHAR(15),
    email         VARCHAR(60),          
    endereco      VARCHAR(80),          
    tipo_material VARCHAR(30)           
);


CREATE TABLE produto (
    codigo_produto INT AUTO_INCREMENT PRIMARY KEY,
    nome           VARCHAR(50)   NOT NULL, 
    tipo           VARCHAR(20),            
    material       VARCHAR(20),            
    descricao      VARCHAR(100),           
    unidade_medida VARCHAR(10)   NOT NULL,      
    preco          DECIMAL(10,2) NOT NULL CHECK (preco > 0)
);


CREATE TABLE servico (
    id_servico    INT AUTO_INCREMENT PRIMARY KEY,
    tipo_servico  VARCHAR(40)   NOT NULL,  
    valor         DECIMAL(10,2) NOT NULL CHECK (valor > 0),   
    prazo_entrega INT          NOT NULL CHECK (prazo_entrega > 0), 
    descricao     VARCHAR(100),          
    status        VARCHAR(15)   NOT NULL DEFAULT 'ATIVO'
                  CHECK (status IN ('ATIVO','INATIVO'))        
);

CREATE TABLE funcionario (
    id_funcionario INT AUTO_INCREMENT PRIMARY KEY,
    nome           VARCHAR(20)   NOT NULL, 
    sobrenome      VARCHAR(40),            
    cpf            CHAR(11)      NOT NULL UNIQUE,
    telefone       VARCHAR(15),
    cargo          VARCHAR(30)   NOT NULL, 
    salario        DECIMAL(10,2) NOT NULL CHECK (salario > 0),
    data_admissao  DATE          NOT NULL
);

CREATE TABLE lancamento_extrato (
    id_lancamento  INT AUTO_INCREMENT PRIMARY KEY,
    conta_bancaria VARCHAR(45)   NOT NULL, 
    data           DATE          NOT NULL,
    descricao      VARCHAR(100),
    valor          DECIMAL(12,2) NOT NULL CHECK (valor > 0),  
    tipo           VARCHAR(10)   NOT NULL CHECK (tipo IN ('CREDITO','DEBITO'))
);


-- =====================================================================
-- PARTE 2 - ENTIDADES DEPENDENTES
-- =====================================================================

CREATE TABLE orcamento (
    codigo_orcamento  INT AUTO_INCREMENT PRIMARY KEY,
    cpf_cnpj          VARCHAR(14)   NOT NULL,
    data              DATE          NOT NULL,
    valor_total       DECIMAL(10,2) NOT NULL CHECK (valor_total > 0),
    prazo_entrega     INT           NOT NULL CHECK (prazo_entrega > 0),   
    status            VARCHAR(15)   NOT NULL DEFAULT 'PENDENTE'
                      CHECK (status IN ('PENDENTE','APROVADO','RECUSADO')),
    desconto_aplicado DECIMAL(5,2)  NOT NULL DEFAULT 0.00
                      CHECK (desconto_aplicado BETWEEN 0 AND 10),         
    prazo_validade    DATE,                                               

    CONSTRAINT chk_orcamento_validade CHECK (prazo_validade IS NULL OR prazo_validade >= data),
    CONSTRAINT fk_orcamento_cliente FOREIGN KEY (cpf_cnpj) REFERENCES cliente(cpf_cnpj) ON UPDATE CASCADE
);

CREATE TABLE contrato (
    codigo_contrato  INT AUTO_INCREMENT PRIMARY KEY,
    codigo_orcamento INT           NOT NULL UNIQUE,
    data_inicio      DATE          NOT NULL,
    data_termino     DATE,
    valor            DECIMAL(10,2) NOT NULL CHECK (valor > 0),
    forma_pagamento  VARCHAR(20)   NOT NULL, 
    status           VARCHAR(15)   NOT NULL DEFAULT 'ATIVO' 
                     CHECK (status IN ('ATIVO','CANCELADO','FINALIZADO')),
    percentual_sinal DECIMAL(5,2)  NOT NULL DEFAULT 30.00
                     CHECK (percentual_sinal BETWEEN 30 AND 100),   

    CONSTRAINT chk_contrato_datas CHECK (data_termino IS NULL OR data_termino >= data_inicio),
    CONSTRAINT fk_contrato_orcamento FOREIGN KEY (codigo_orcamento) REFERENCES orcamento(codigo_orcamento) ON DELETE CASCADE
);

CREATE TABLE estoque (
    codigo_produto    INT PRIMARY KEY,
    quantidade_atual  DECIMAL(10,2) NOT NULL DEFAULT 0 CHECK (quantidade_atual >= 0),
    quantidade_minima DECIMAL(10,2) NOT NULL CHECK (quantidade_minima > 0),  

    CONSTRAINT fk_estoque_produto FOREIGN KEY (codigo_produto) REFERENCES produto(codigo_produto) ON DELETE CASCADE
);

CREATE TABLE cotacao (
    id_cotacao         INT AUTO_INCREMENT PRIMARY KEY,
    id_fornecedor      INT          NOT NULL,
    data_cotacao       DATE         NOT NULL,
    prazo_entrega      INT          NOT NULL CHECK (prazo_entrega > 0),  
    condicao_pagamento VARCHAR(40), 
    validade           DATE,
    status             VARCHAR(15)  NOT NULL DEFAULT 'ABERTA'
                       CHECK (status IN ('ABERTA','ACEITA','RECUSADA','EXPIRADA')),

    CONSTRAINT chk_cotacao_validade CHECK (validade IS NULL OR validade >= data_cotacao),
    CONSTRAINT fk_cotacao_fornecedor FOREIGN KEY (id_fornecedor) REFERENCES fornecedor(id_fornecedor) ON DELETE CASCADE
);

CREATE TABLE pedido_compra (
    id_pedido_compra INT AUTO_INCREMENT PRIMARY KEY,
    id_cotacao       INT           NOT NULL UNIQUE,
    data_pedido      DATE          NOT NULL,
    previsao_entrega DATE,
    data_recebimento DATE,
    valor_total      DECIMAL(10,2) NOT NULL CHECK (valor_total > 0),
    status           VARCHAR(15)   NOT NULL DEFAULT 'EMITIDO' 
                     CHECK (status IN ('EMITIDO','RECEBIDO','CANCELADO')),

    CONSTRAINT chk_pedido_datas CHECK (
        (previsao_entrega IS NULL OR previsao_entrega >= data_pedido)
        AND (data_recebimento IS NULL OR data_recebimento >= data_pedido)
    ),
    CONSTRAINT fk_pedido_cotacao FOREIGN KEY (id_cotacao) REFERENCES cotacao(id_cotacao) ON DELETE CASCADE
);

CREATE TABLE servico_contratado (
    id_servico_contratado INT AUTO_INCREMENT PRIMARY KEY,
    codigo_contrato       INT           NOT NULL,
    id_servico            INT           NOT NULL,
    medidas               VARCHAR(40),  
    quantidade            INT           NOT NULL CHECK (quantidade > 0),
    valor_acordado        DECIMAL(10,2) NOT NULL CHECK (valor_acordado > 0),
    status_execucao       VARCHAR(20)   NOT NULL DEFAULT 'PENDENTE'
                          CHECK (status_execucao IN ('PENDENTE','EM_FABRICACAO','EM_INSTALACAO','CONCLUIDO','CANCELADO')),
    data_inicio           DATE,
    data_conclusao        DATE,

    CONSTRAINT chk_servcontr_datas CHECK (data_conclusao IS NULL OR data_inicio IS NULL OR data_conclusao >= data_inicio),
    CONSTRAINT fk_servcontr_contrato FOREIGN KEY (codigo_contrato) REFERENCES contrato(codigo_contrato) ON DELETE CASCADE,
    CONSTRAINT fk_servcontr_servico  FOREIGN KEY (id_servico)      REFERENCES servico(id_servico)
);

CREATE TABLE pagamento (
    id_pagamento    INT AUTO_INCREMENT PRIMARY KEY,
    codigo_contrato INT           NOT NULL,
    forma_pagamento VARCHAR(20)   NOT NULL,     
    data_pagamento  DATE,                       
    status          VARCHAR(15)   NOT NULL DEFAULT 'AGUARDANDO' 
                    CHECK (status IN ('AGUARDANDO','PARCIAL','PAGO','CANCELADO')),
    data_vencimento DATE          NOT NULL,
    valor_pagamento DECIMAL(10,2) NOT NULL CHECK (valor_pagamento > 0),
CONSTRAINT chk_pagamento_pago CHECK (status <> 'PAGO' OR data_pagamento IS NOT NULL),
CONSTRAINT fk_pagamento_contrato FOREIGN KEY (codigo_contrato) REFERENCES contrato(codigo_contrato) ON DELETE CASCADE
);

CREATE TABLE conta_pagar (
id_conta_pagar   INT AUTO_INCREMENT PRIMARY KEY,
id_pedido_compra INT           NOT NULL,
numero_parcela   INT           NOT NULL CHECK (numero_parcela > 0),
valor_previsto   DECIMAL(10,2) NOT NULL CHECK (valor_previsto > 0),
data_vencimento  DATE          NOT NULL,
status           VARCHAR(15)   NOT NULL DEFAULT 'ABERTA' 
CHECK (status IN ('ABERTA','PARCIAL','PAGA','CANCELADA')),
CONSTRAINT uq_conta_pedido_parcela UNIQUE (id_pedido_compra, numero_parcela),
CONSTRAINT fk_conta_pedido FOREIGN KEY (id_pedido_compra) REFERENCES pedido_compra(id_pedido_compra) ON DELETE CASCADE
);

CREATE TABLE movimentacao_estoque (
id_movimentacao       INT AUTO_INCREMENT PRIMARY KEY,
codigo_produto        INT           NOT NULL,
id_servico_contratado INT,
id_pedido_compra      INT,
tipo                  VARCHAR(10)   NOT NULL CHECK (tipo IN ('ENTRADA','SAIDA')),
quantidade            DECIMAL(10,2) NOT NULL CHECK (quantidade > 0),
data_movimentacao     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
CONSTRAINT fk_movest_produto   FOREIGN KEY (codigo_produto)        REFERENCES produto(codigo_produto) ON UPDATE CASCADE,
CONSTRAINT fk_movest_servcontr FOREIGN KEY (id_servico_contratado) REFERENCES servico_contratado(id_servico_contratado) ON DELETE SET NULL,
CONSTRAINT fk_movest_pedido    FOREIGN KEY (id_pedido_compra)      REFERENCES pedido_compra(id_pedido_compra) ON DELETE SET NULL
);

CREATE TABLE movimentacao_caixa (
id_mov_caixa    INT AUTO_INCREMENT PRIMARY KEY,
id_pagamento    INT,
id_conta_pagar  INT,
tipo            VARCHAR(10)   NOT NULL CHECK (tipo IN ('ENTRADA','SAIDA')),
data_movimento  DATE          NOT NULL,
valor           DECIMAL(10,2) NOT NULL CHECK (valor > 0),
forma_pagamento VARCHAR(20)   NOT NULL, 
CONSTRAINT fk_movcaixa_pagamento FOREIGN KEY (id_pagamento)   REFERENCES pagamento(id_pagamento) ON DELETE SET NULL,
CONSTRAINT fk_movcaixa_conta     FOREIGN KEY (id_conta_pagar)  REFERENCES conta_pagar(id_conta_pagar) ON DELETE SET NULL
);

-- =====================================================================
-- PARTE 3 - ENTIDADES ASSOCIATIVAS (Relacionamentos N:N)
-- =====================================================================

CREATE TABLE contem (
codigo_orcamento INT           NOT NULL,
id_servico       INT           NOT NULL,
medidas          VARCHAR(40),  
sub_total        DECIMAL(10,2) NOT NULL CHECK (sub_total > 0),
quantidade       INT           NOT NULL CHECK (quantidade > 0),
PRIMARY KEY (codigo_orcamento, id_servico),
CONSTRAINT fk_contem_orcamento FOREIGN KEY (codigo_orcamento) REFERENCES orcamento(codigo_orcamento) ON DELETE CASCADE,
CONSTRAINT fk_contem_servico   FOREIGN KEY (id_servico)       REFERENCES servico(id_servico),
INDEX idx_contem_servico (id_servico)
);

CREATE TABLE precisa (
id_servico            INT           NOT NULL,
codigo_produto        INT           NOT NULL,
quantidade_necessaria DECIMAL(10,2) NOT NULL CHECK (quantidade_necessaria > 0),
PRIMARY KEY (id_servico, codigo_produto),
CONSTRAINT fk_precisa_servico FOREIGN KEY (id_servico)     REFERENCES servico(id_servico) ON DELETE CASCADE,
CONSTRAINT fk_precisa_produto FOREIGN KEY (codigo_produto) REFERENCES produto(codigo_produto),
INDEX idx_precisa_produto (codigo_produto)
);

CREATE TABLE executa (
id_funcionario        INT NOT NULL,
id_servico_contratado INT NOT NULL,
PRIMARY KEY (id_funcionario, id_servico_contratado),
CONSTRAINT fk_executa_funcionario FOREIGN KEY (id_funcionario)        REFERENCES funcionario(id_funcionario) ON DELETE CASCADE,
CONSTRAINT fk_executa_servcontr   FOREIGN KEY (id_servico_contratado) REFERENCES servico_contratado(id_servico_contratado) ON DELETE CASCADE,
INDEX idx_executa_servcontr (id_servico_contratado)
);

CREATE TABLE item_cotacao (
id_cotacao     INT           NOT NULL,
codigo_produto INT           NOT NULL,
quantidade     DECIMAL(10,2) NOT NULL CHECK (quantidade > 0),
preco_unitario DECIMAL(10,2) NOT NULL CHECK (preco_unitario > 0),
PRIMARY KEY (id_cotacao, codigo_produto),
CONSTRAINT fk_itemcot_cotacao FOREIGN KEY (id_cotacao)     REFERENCES cotacao(id_cotacao) ON DELETE CASCADE,
CONSTRAINT fk_itemcot_produto FOREIGN KEY (codigo_produto) REFERENCES produto(codigo_produto),
INDEX idx_itemcot_produto (codigo_produto)
);

CREATE TABLE item_pedido_compra (
id_item_pedido   INT AUTO_INCREMENT PRIMARY KEY,
id_pedido_compra INT           NOT NULL,
codigo_produto   INT           NOT NULL,
quantidade       DECIMAL(10,2) NOT NULL CHECK (quantidade > 0),
preco_unitario   DECIMAL(10,2) NOT NULL CHECK (preco_unitario > 0),
CONSTRAINT uq_item_pedido_produto UNIQUE (id_pedido_compra, codigo_produto),
CONSTRAINT fk_itemped_pedido  FOREIGN KEY (id_pedido_compra) REFERENCES pedido_compra(id_pedido_compra) ON DELETE CASCADE,
CONSTRAINT fk_itemped_produto FOREIGN KEY (codigo_produto)   REFERENCES produto(codigo_produto),
INDEX idx_itemped_produto (codigo_produto)
);

CREATE TABLE conciliacao (
id_lancamento    INT          NOT NULL,
id_mov_caixa     INT          NOT NULL,
data_conciliacao DATE         NOT NULL,
status           VARCHAR(15)  NOT NULL DEFAULT 'CONCILIADO' 
CHECK (status IN ('CONCILIADO','DIVERGENTE')),
observacao       VARCHAR(150), 
PRIMARY KEY (id_lancamento, id_mov_caixa),
CONSTRAINT fk_concil_lancamento FOREIGN KEY (id_lancamento) REFERENCES lancamento_extrato(id_lancamento) ON DELETE CASCADE,
CONSTRAINT fk_concil_movcaixa   FOREIGN KEY (id_mov_caixa)  REFERENCES movimentacao_caixa(id_mov_caixa) ON DELETE CASCADE,
INDEX idx_concil_movcaixa (id_mov_caixa)
);

-- =====================================================================
-- PARTE 4 - SELECT PARA VISUALIZAR AS TABELAS
-- =====================================================================

SELECT * FROM cliente;
SELECT * FROM fornecedor;
SELECT * FROM produto;
SELECT * FROM servico;
SELECT * FROM funcionario;
SELECT * FROM lancamento_extrato;
-- Entidades dependentes
SELECT * FROM orcamento;
SELECT * FROM contrato;
SELECT * FROM estoque;
SELECT * FROM cotacao;
SELECT * FROM pedido_compra;
SELECT * FROM servico_contratado;
SELECT * FROM pagamento;
SELECT * FROM conta_pagar;
SELECT * FROM movimentacao_estoque;
SELECT * FROM movimentacao_caixa;
-- Entidades associativas
SELECT * FROM contem;
SELECT * FROM precisa;
SELECT * FROM executa;
SELECT * FROM item_cotacao;
SELECT * FROM item_pedido_compra;
SELECT * FROM conciliacao;