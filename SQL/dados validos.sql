USE Space_Metal;

-- =====================================================================
-- 1. ENTIDADES INDEPENDENTES
-- =====================================================================

-- Clientes
INSERT INTO cliente (cpf_cnpj, nome, sobrenome, email, cep, rua, numero, complemento, bairro, cidade, uf, ddd, telefone) VALUES
('12345678901', 'Carlos', 'Silveira', 'carlos.silveira@email.com', '01310-100', 'Avenida Paulista', '1000', 'Apto 42', 'Bela Vista', 'São Paulo', 'SP', '11', '987654321'),
('98765432109', 'Ana', 'Souza', 'ana.souza@email.com', '04551-010', 'Rua Funchal', '250', 'Bloco B', 'Vila Olímpia', 'São Paulo', 'SP', '11', '912345678');

-- Fornecedores (Com endereço completo e DDD)
INSERT INTO fornecedor (nome, cnpj, telefone, ddd, email, cep, rua, numero, complemento, bairro, cidade, uf, tipo_material) VALUES
('Metalurgica Ferros Ind', '12345678000199', '33334444', '11', 'contato@ferrosind.com.br', '03102-000', 'Rua dos Aços', '120', 'Galpão A', 'Mooca', 'São Paulo', 'SP', 'Perfis de Aço'),
('Parafusos & Cia', '98765432000188', '55556666', '11', 'vendas@parafusoscia.com.br', '04280-020', 'Rua das Porcas', '45', NULL, 'Ipiranga', 'São Paulo', 'SP', 'Fixadores');

-- Produtos (Matérias-primas e itens de estoque)
INSERT INTO produto (codigo_produto, nome, tipo, material, descricao, unidade_medida, preco) VALUES
(1, 'Perfil Tubular Aço 50x30', 'Matéria-Prima', 'Aço Carbono', 'Barra de 6 metros', 'UN', 150.00),
(2, 'Chapa de Aço Galv. 2mm', 'Matéria-Prima', 'Aço Galvanizado', 'Chapa 2x1 metro', 'UN', 280.00),
(3, 'Parafuso Sextavado 3/8', 'Insumo', 'Aço Inox', 'Caixa com 100 unidades', 'CX', 45.00);

-- Estoque inicial (Vinculado aos produtos e fornecedores)
INSERT INTO estoque (codigo_produto, id_fornecedor, quantidade_atual, quantidade_minima) VALUES
(1, 1, 50.00, 10.00),
(2, 1, 20.00, 5.00),
(3, 2, 100.00, 20.00);

-- Serviços oferecidos pela Serralheria
INSERT INTO servico (id_servico, tipo_servico, valor, prazo_entrega, descricao, status) VALUES
(1, 'Fabricação de Portão Basculante', 2500.00, 15, 'Portão em aço com pintura anticorrosiva', 'ATIVO'),
(2, 'Instalação de Grade de Proteção', 800.00, 5, 'Grades para janelas residenciais', 'ATIVO');

-- Funcionários
INSERT INTO funcionario (nome, sobrenome, cpf, telefone, ddd, cargo, salario, data_admissao) VALUES
('Marcos', 'Oliveira', '11122233344', '998877665', '11', 'Serralheiro', 3500.00, '2023-02-10'),
('Juliana', 'Santos', '22233344455', '988776654', '11', 'Auxiliar de Produção', 2200.00, '2023-06-15');

-- Lançamentos em extrato bancário
INSERT INTO lancamento_extrato (conta_bancaria, data, descricao, valor, tipo) VALUES
('Banco Itaú - CC 12345-6', '2026-05-01', 'Recebimento Sinal Cliente Carlos', 750.00, 'CREDITO'),
('Banco Itaú - CC 12345-6', '2026-05-03', 'Pagamento Fornecedor Ferros Ind', 1500.00, 'DEBITO');


-- =====================================================================
-- 2. ENTIDADES DEPENDENTES
-- =====================================================================

-- Orçamento (Status APROVADO para permitir a criação do contrato respeitando a RN04)
INSERT INTO orcamento (codigo_orcamento, cpf_cnpj, data, valor_total, prazo_entrega, status, desconto_aplicado, prazo_validade) VALUES
(1, '12345678901', '2026-04-25', 2500.00, 15, 'APROVADO', 0.00, '2026-05-25');

-- Contrato (Gerado a partir de um orçamento APROVADO)
INSERT INTO contrato (codigo_contrato, codigo_orcamento, data_inicio, data_termino, valor, forma_pagamento, status, percentual_sinal) VALUES
(1, 1, '2026-05-01', '2026-05-16', 2500.00, 'Pix', 'ATIVO', 30.00);

-- Cotação com fornecedor
INSERT INTO cotacao (id_cotacao, id_fornecedor, data_cotacao, prazo_entrega, condicao_pagamento, validade, status) VALUES
(1, 1, '2026-04-20', 3, '30 dias', '2026-05-20', 'ACEITA');

-- Pedido de Compra (Vinculado à cotação aceita)
INSERT INTO pedido_compra (id_pedido_compra, id_cotacao, data_pedido, previsao_entrega, data_recebimento, valor_total, status) VALUES
(1, 1, '2026-04-21', '2026-04-24', '2026-04-24', 1500.00, 'RECEBIDO');

-- Serviço Contratado (Vinculado ao contrato e serviço)
-- NOTA: Mantido como 'PENDENTE' inicialmente. A trigger só permite mudar para 'EM_FABRICACAO' se houver pagamento PAGO.
INSERT INTO servico_contratado (id_servico_contratado, codigo_contrato, id_servico, medidas, quantidade, valor_acordado, status_execucao, data_inicio, data_conclusao) VALUES
(1, 1, '1', '3.00m x 2.10m', 1, 2500.00, 'PENDENTE', NULL, NULL);

-- Pagamento (Registra o sinal de 30% pago, o que desbloqueará a trigger de produção se necessário)
INSERT INTO pagamento (id_pagamento, codigo_contrato, forma_pagamento, data_pagamento, status, data_vencimento, valor_pagamento) VALUES
(1, 1, 'Pix', '2026-05-01', 'PAGO', '2026-05-01', 750.00);

-- Contas a Pagar (Vinculado ao pedido de compra)
INSERT INTO conta_pagar (id_conta_pagar, id_pedido_compra, numero_parcela, valor_previsto, data_vencimento, status) VALUES
(1, 1, 1, 1500.00, '2026-05-21', 'PAGA');

-- Movimentação de Estoque (Respeita a RN20: ENTRADA exige id_pedido_compra)
INSERT INTO movimentacao_estoque (codigo_produto, id_servico_contratado, id_pedido_compra, tipo, quantidade) VALUES
(1, NULL, 1, 'ENTRADA', 10.00);

-- Movimentação de Caixa
INSERT INTO movimentacao_caixa (id_pagamento, id_conta_pagar, tipo, data_movimento, valor, forma_pagamento) VALUES
(1, NULL, 'ENTRADA', '2026-05-01', 750.00, 'Pix'),
(NULL, 1, 'SAIDA', '2026-05-03', 1500.00, 'Boleto');


-- =====================================================================
-- 3. ENTIDADES ASSOCIATIVAS (Relacionamentos N:N)
-- =====================================================================

-- Serviços contidos no orçamento
INSERT INTO contem (codigo_orcamento, id_servico, medidas, sub_total, quantidade) VALUES
(1, 1, '3.00m x 2.10m', 2500.00, 1);

-- Produtos necessários para realizar o serviço
INSERT INTO precisa (id_servico, codigo_produto, quantidade_necessaria) VALUES
(1, 1, 4.00), -- 4 barras de perfil tubular
(1, 3, 2.00); -- 2 caixas de parafusos

-- Funcionários que executam o serviço contratado
INSERT INTO executa (id_funcionario, id_servico_contratado) VALUES
(1, 1); -- Funcionário Marcos executa o serviço 1

-- Itens da cotação
INSERT INTO item_cotacao (id_cotacao, codigo_produto, quantidade, preco_unitario) VALUES
(1, 1, 10.00, 150.00);

-- Itens do pedido de compra
INSERT INTO item_pedido_compra (id_pedido_compra, codigo_produto, quantidade, preco_unitario) VALUES
(1, 1, 10.00, 150.00);

-- Conciliação bancária
INSERT INTO conciliacao (id_lancamento, id_mov_caixa, data_conciliacao, status, observacao) VALUES
(1, 1, '2026-05-02', 'CONCILIADO', 'Conciliado com extrato bancário do Itaú');