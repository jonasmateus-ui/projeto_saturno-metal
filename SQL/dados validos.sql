-- CLIENTE (Nomes, sobrenomes, logradouros e e-mails compactos dentro dos novos limites de 30, 40 e 60)
INSERT INTO cliente (cpf_cnpj, nome, sobrenome, email, cep, rua, numero, complemento, bairro, cidade, uf, ddd, telefone) VALUES 
('11122233344', 'Ana', 'Silva', 'ana.silva@uol.com', '03314-000', 'R. Tuiuti', '1500', 'Ap 42', 'Tatuape', 'Sao Paulo', 'SP', '11', '988887777'),
('22233344455', 'Bruno', 'Mendes', 'bruno.m@gme.com', '03047-000', 'Av. C. Garcia', '2500', 'Bl 2', 'Bras', 'Sao Paulo', 'SP', '11', '966665555');

-- FORNECEDOR (Nomes fantasia e endereços enxutos respeitando os limites de 50 e 80)
INSERT INTO fornecedor (nome, cnpj, telefone, email, endereco, tipo_material) VALUES 
('Gerdau Comercial', '11222333000144', '1133334444', 'vendas@gerdau.com', 'Av. Ind, 450', 'Ferro e Aco'),
('Alu Central', '55666777000188', '1144445555', 'comercial@aluc.com', 'R. Juntas, 50', 'Aluminio');

-- PRODUTO (Nomes técnicos curtos dentro do limite de 50)
INSERT INTO produto (nome, tipo, material, descricao, unidade_medida, preco) VALUES 
('Tubo Quad 40x40 2mm', 'Tubo', 'Aco', 'Tubo de aco carbono quadrado de 40x40mm', 'M', 45.50),
('Barra Chata 1/2 x 1/8', 'Barra', 'Aluminio', 'Barra chata de aluminio natural 6m', 'UN', 25.00);

-- SERVIÇO (Tipos de serviço resumidos em até 40 caracteres)
INSERT INTO servico (tipo_servico, valor, prazo_entrega, descricao, status) VALUES 
('Portao Basculante', 2500.00, 15, 'Portao residencial em aco com requadro', 'ATIVO'),
('Grade de Protecao', 350.00, 7, 'Grade para janela sob medida por m2', 'ATIVO');

-- FUNCIONÁRIO (Primeiro nome em até 20 e sobrenome em até 40 caracteres)
INSERT INTO funcionario (nome, sobrenome, cpf, telefone, cargo, salario, data_admissao) VALUES 
('Jorge', 'Santos', '12345678901', '11977776666', 'Soldador', 2800.00, '2026-01-15'),
('Mariana', 'Costa', '98765432100', '11966665555', 'Vendedor', 2200.00, '2026-03-01');

-- LANÇAMENTO_EXTRATO (Contas bancárias e descrições curtas)
INSERT INTO lancamento_extrato (conta_bancaria, data, descricao, valor, tipo) VALUES 
('Ag1234 CC5678', '2026-10-20', 'PIX RECEBIDO ANA SILVA', 1050.00, 'CREDITO'),
('Ag1234 CC5678', '2026-10-22', 'TED PAGA GERDAU', 1500.00, 'DEBITO');
-- ORÇAMENTO
INSERT INTO orcamento (cpf_cnpj, data, valor_total, prazo_entrega, status, desconto_aplicado, prazo_validade) VALUES 
('11122233344', '2026-10-01', 3500.00, 15, 'APROVADO', 5.00, '2026-10-16'),
('22233344455', '2026-10-10', 1200.00, 10, 'PENDENTE', 0.00, '2026-10-25');

-- CONTRATO (Formas de pagamento curtas de até 20 caracteres)
INSERT INTO contrato (codigo_orcamento, data_inicio, data_termino, valor, forma_pagamento, status, percentual_sinal) VALUES 
(1, '2026-10-05', '2026-10-20', 3500.00, 'Pix', 'ATIVO', 30.00),
(2, '2026-10-12', '2026-10-22', 1200.00, 'Boleto', 'ATIVO', 50.00);

-- SERVICO_CONTRATADO (Medidas enxutas em até 40 caracteres)
INSERT INTO servico_contratado (codigo_contrato, id_servico, medidas, quantidade, valor_acordado, status_execucao, data_inicio, data_conclusao) VALUES 
(1, 1, '2.5x3.0m', 1, 3500.00, 'EM_FABRICACAO', '2026-10-06', NULL),
(2, 2, '1.2x1.5m', 2, 1200.00, 'PENDENTE', NULL, NULL);

-- PAGAMENTO
INSERT INTO pagamento (codigo_contrato, forma_pagamento, data_pagamento, status, data_vencimento, valor_pagamento) VALUES 
(1, 'Pix', '2026-10-05', 'PAGO', '2026-10-05', 1050.00), -- 30% sinal do Contrato 1
(1, 'Pix', NULL, 'AGUARDANDO', '2026-10-20', 2450.00), -- Saldo do Contrato 1
(2, 'Boleto', '2026-10-12', 'PAGO', '2026-10-12', 600.00), -- 50% sinal do Contrato 2
(2, 'Boleto', NULL, 'AGUARDANDO', '2026-10-22', 600.00); -- Saldo do Contrato 2

-- ESTOQUE (1:1 rigoroso com a Chave Primária correta)
INSERT INTO estoque (codigo_produto, quantidade_atual, quantidade_minima) VALUES 
(1, 50.00, 10.00),
(2, 15.00, 20.00);

-- COTAÇÃO (Condições de pagamento curtas de até 40 caracteres)
INSERT INTO cotacao (id_fornecedor, data_cotacao, prazo_entrega, condicao_pagamento, validade, status) VALUES 
(1, '2026-10-10', 3, 'Boleto 15 dias', '2026-10-17', 'ACEITA'),
(2, '2026-10-11', 5, 'A vista', '2026-10-15', 'EXPIRADA');

-- PEDIDO_COMPRA
INSERT INTO pedido_compra (id_cotacao, data_pedido, previsao_entrega, data_recebimento, valor_total, status) VALUES 
(1, '2026-10-12', '2026-10-15', '2026-10-15', 1500.00, 'RECEBIDO'),
(2, '2026-10-14', '2026-10-19', NULL, 800.00, 'EMITIDO');

-- CONTA_PAGAR
INSERT INTO conta_pagar (id_pedido_compra, numero_parcela, valor_previsto, data_vencimento, status) VALUES 
(1, 1, 1500.00, '2026-10-27', 'PAGA'),
(2, 1, 800.00, '2026-11-14', 'ABERTA');

-- MOVIMENTAÇÃO_ESTOQUE
INSERT INTO movimentacao_estoque (codigo_produto, id_servico_contratado, id_pedido_compra, tipo, quantidade, data_movimentacao) VALUES 
(1, NULL, 1, 'ENTRADA', 30.00, '2026-10-15 14:30:00'),
(1, 1, NULL, 'SAIDA', 12.00, '2026-10-16 08:00:00');

-- MOVIMENTAÇÃO_CAIXA
INSERT INTO movimentacao_caixa (id_pagamento, id_conta_pagar, tipo, data_movimento, valor, forma_pagamento) VALUES 
(1, NULL, 'ENTRADA', '2026-10-05', 1050.00, 'Pix'),
(NULL, 1, 'SAIDA', '2026-10-22', 1500.00, 'Boleto');

-- CONCILIACAO (Observações resumidas em até 150 caracteres)
INSERT INTO conciliacao (id_lancamento, id_mov_caixa, data_conciliacao, status, observacao) VALUES 
(1, 1, '2026-10-20', 'CONCILIADO', 'Pix de sinal recebido verificado no extrato bancario.'),
(2, 2, '2026-10-22', 'CONCILIADO', 'Pagamento de boleto a fornecedor compensado.');

-- CONTEM (Orçamentos com itens detalhados de forma compacta)
INSERT INTO contem (codigo_orcamento, id_servico, medidas, sub_total, quantidade) VALUES 
(1, 1, '2.5x3.0m', 2500.00, 1),
(1, 2, '1.2x1.5m', 1000.00, 3);

-- PRECISA (Ficha técnica de consumo de material por serviço)
INSERT INTO precisa (id_servico, codigo_produto, quantidade_necessaria) VALUES 
(1, 1, 18.50),
(2, 2, 4.00);

-- EXECUTA (Vincula funcionários à execução das obras)
INSERT INTO executa (id_funcionario, id_servico_contratado) VALUES 
(1, 1),
(1, 2);

-- ITEM_COTAÇÃO
INSERT INTO item_cotacao (id_cotacao, codigo_produto, quantidade, preco_unitario) VALUES 
(1, 1, 30.00, 50.00),
(2, 2, 10.00, 25.00);

-- ITEM_PEDIDO_COMPRA
INSERT INTO item_pedido_compra (id_pedido_compra, codigo_produto, quantidade, preco_unitario) VALUES 
(1, 1, 30.00, 50.00),
(2, 2, 10.00, 25.00);
