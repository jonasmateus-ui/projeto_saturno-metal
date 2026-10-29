-- TABELA: cliente
-- Erro: Estouro de capacidade de campo (VARCHAR)
-- O que acontece: Tenta inserir um sobrenome com 55 caracteres, mas o limite configurado é de no máximo 50.
-- Erro esperado: Data too long for column 'sobrenome' at row 1
INSERT INTO cliente (cpf_cnpj, nome, sobrenome, ddd, telefone) 
VALUES ('33344455566', 'Carlos', 'De Oliveira Alcantara Braganca Santos Silva Vasconcelos', '11', '999999999');

-- TABELA: fornecedor
-- Erro: Violação de Chave Única (UNIQUE)
-- O que acontece: Tenta cadastrar um novo fornecedor usando o CNPJ '11222333000144', que já pertence à 'Gerdau Comercial'.
-- Erro esperado: Duplicate entry '11222333000144' for key 'cnpj'
INSERT INTO fornecedor (nome, cnpj, telefone) 
VALUES ('Serralheria Clone', '11222333000144', '1144443333');

-- TABELA: produto
-- Erro: Violação de Restrição de Verificação (CHECK)
-- O que acontece: O banco recusa a inserção porque o preço do produto foi definido como um valor negativo (-10.50).
-- Erro esperado: Check constraint 'produto_chk_1' is violated.
INSERT INTO produto (nome, tipo, material, unidade_medida, preco) 
VALUES ('Insumo Invalido', 'Insumo', 'Ferro', 'KG', -10.50);

-- TABELA: servico
-- Erro: Violação de Restrição de Domínio no CHECK
-- O que acontece: O campo 'status' aceita estritamente apenas 'ATIVO' ou 'INATIVO'. A palavra 'DELETADO' é rejeitada.
-- Erro esperado: Check constraint 'servico_chk_3' is violated.
INSERT INTO servico (tipo_servico, valor, prazo_entrega, status) 
VALUES ('Servico Antigo', 500.00, 5, 'DELETADO');

-- TABELA: funcionario
-- Erro: Violação de Restrição de Verificação (CHECK)
-- O que acontece: O banco impede o cadastro porque o salário do funcionário deve ser obrigatoriamente maior que zero.
-- Erro esperado: Check constraint 'funcionario_chk_1' is violated.
INSERT INTO funcionario (nome, sobrenome, cpf, cargo, salario, data_admissao) 
VALUES ('Luiz', 'Sousa', '44455566677', 'Ajudante', 0.00, '2026-01-01');

-- TABELA: lancamento_extrato
-- Erro: Violação de Restrição de Domínio no CHECK
-- O que acontece: A coluna 'tipo' exige textualmente as palavras 'CREDITO' ou 'DEBITO'. O banco recusa a palavra 'DINHEIRO'.
-- Erro esperado: Check constraint 'lancamento_extrato_chk_2' is violated.
INSERT INTO lancamento_extrato (conta_bancaria, data, valor, tipo) 
VALUES ('Ag1234 CC5678', '2026-10-22', 'Estorno Caixa', 250.00, 'DINHEIRO');
-- TABELA: orcamento
-- Erro: Desconto acima do limite parametrizado (CHECK)
-- O que acontece: A política comercial da empresa restringe o desconto a no máximo 10.00%. O sistema barra o valor de 12.50%.
-- Erro esperado: Check constraint 'orcamento_chk_2' is violated.
INSERT INTO orcamento (cpf_cnpj, data, valor_total, prazo_entrega, status, desconto_aplicado) 
VALUES ('11122233344', '2026-10-01', 1500.00, 5, 'PENDENTE', 12.50);

-- TABELA: contrato
-- Erro: Violação de Relacionamento 1:1 (UNIQUE)
-- O que acontece: Tenta criar um segundo contrato vinculado ao 'codigo_orcamento = 1', que já possui um contrato ativo.
-- Erro esperado: Duplicate entry '1' for key 'codigo_orcamento'
INSERT INTO contrato (codigo_orcamento, data_inicio, valor, forma_pagamento, status) 
VALUES (1, '2026-10-06', 3500.00, 'Pix', 'ATIVO');

-- TABELA: servico_contratado
-- Erro: Violação de Chave Estrangeira (FOREIGN KEY)
-- O que acontece: Tenta associar a execução de um serviço ao Contrato nº 999, que não existe no sistema.
-- Erro esperado: Cannot add or update a child row: a foreign key constraint fails (`fk_servcontr_contrato`)
INSERT INTO servico_contratado (codigo_contrato, id_servico, medidas, quantidade, valor_acordado) 
VALUES (999, 1, '1.5x1.5m', 1, 500.00);

-- TABELA: pagamento
-- Erro: Violação de Regra Condicional Dinâmica (CHECK)
-- O que acontece: A constraint 'chk_pagamento_pago' determina que se o status for 'PAGO', a data de pagamento NÃO pode ser nula.
-- Erro esperado: Check constraint 'chk_pagamento_pago' is violated.
INSERT INTO pagamento (codigo_contrato, forma_pagamento, data_pagamento, status, data_vencimento, valor_pagamento) 
VALUES (1, 'Pix', NULL, 'PAGO', '2026-10-20', 2450.00);
-- TABELA: estoque
-- Erro: Violação de Chave Primária Duplicada (Relacionamento 1:1 correto)
-- O que acontece: Como corrigimos a tabela para usar 'codigo_produto' como PK, o banco impede que o Produto 1 tenha duas linhas de estoque.
-- Erro esperado: Duplicate entry '1' for key 'PRIMARY'
INSERT INTO estoque (codigo_produto, quantidade_atual, quantidade_minima) 
VALUES (1, 10.00, 5.00);

-- TABELA: cotacao
-- Erro: Inconsistência Cronológica de Datas (CHECK)
-- O que acontece: A data de validade da proposta comercial ('2026-10-05') não pode ser anterior à data em que ela foi criada ('2026-10-10').
-- Erro esperado: Check constraint 'chk_cotacao_validade' is violated.
INSERT INTO cotacao (id_fornecedor, data_cotacao, prazo_entrega, validade) 
VALUES (1, '2026-10-10', 3, '2026-10-05');

-- TABELA: pedido_compra
-- Erro: Inconsistência Cronológica de Datas (CHECK)
-- O que acontece: A restrição 'chk_pedido_datas' impede que a previsão de entrega de mercadoria seja registrada antes da data de emissão do pedido.
-- Erro esperado: Check constraint 'chk_pedido_datas' is violated.
INSERT INTO pedido_compra (id_cotacao, data_pedido, previsao_entrega, valor_total) 
VALUES (2, '2026-10-14', '2026-10-10', 800.00);

-- TABELA: conta_pagar
-- Erro: Violação de Chave Única Composta (UNIQUE)
-- O que acontece: Tenta criar uma nova linha financeira para a Parcela 1 do Pedido de Compra 1, que já foi cadastrada anteriormente.
-- Erro esperado: Duplicate entry '1-1' for key 'uq_conta_pedido_parcela'
INSERT INTO conta_pagar (id_pedido_compra, numero_parcela, valor_previsto, data_vencimento) 
VALUES (1, 1, 1500.00, '2026-11-30');

-- TABELA: movimentacao_estoque
-- Erro: Quantidade Inválida (CHECK)
-- O que acontece: Tenta registrar uma movimentação física de saída de material do estoque com quantidade zerada (0.00).
-- Erro esperado: Check constraint 'movimentacao_estoque_chk_2' is violated.
INSERT INTO movimentacao_estoque (codigo_produto, id_servico_contratado, tipo, quantidade) 
VALUES (1, 1, 'SAIDA', 0.00);

-- TABELA: movimentacao_caixa
-- Erro: Valor Inválido (CHECK)
-- O que acontece: O fluxo de caixa recusa registros financeiros de entradas ou saídas que possuam valor negativo ou zerado.
-- Erro esperado: Check constraint 'movimentacao_caixa_chk_1' is violated.
INSERT INTO movimentacao_caixa (id_pagamento, tipo, data_movimento, valor, forma_pagamento) 
VALUES (1, 'ENTRADA', '2026-10-05', -100.00, 'Pix');
-- TABELA: contem
-- Erro: Violação de Chave Primária Composta Duplicada
-- O que acontece: Tenta inserir o mesmo Serviço 1 dentro do mesmo Orçamento 1 pela segunda vez na tabela associativa.
-- Erro esperado: Duplicate entry '1-1' for key 'PRIMARY'
INSERT INTO contem (codigo_orcamento, id_servico, medidas, sub_total, quantidade) 
VALUES (1, 1, '2.5x3.0m', 2500.00, 1);

-- TABELA: precisa
-- Erro: Violação de Chave Estrangeira Pai Inexistente
-- O que acontece: Tenta criar uma regra na ficha técnica dizendo que o Serviço 1 precisa do Produto 999 (que não existe no catálogo).
-- Erro esperado: Cannot add or update a child row: a foreign key constraint fails (`fk_precisa_produto`)
INSERT INTO precisa (id_servico, codigo_produto, quantidade_necessaria) 
VALUES (1, 999, 10.00);

-- TABELA: executa
-- Erro: Violação de Chave Primária Composta Duplicada
-- O que acontece: Tenta escalar o funcionário 1 para trabalhar no serviço contratado 1 de novo, gerando duplicidade no diário de obras.
-- Erro esperado: Duplicate entry '1-1' for key 'PRIMARY'
INSERT INTO executa (id_funcionario, id_servico_contratado) 
VALUES (1, 1);

-- TABELA: item_cotacao
-- Erro: Preço Unitário Inválido (CHECK)
-- O que acontece: Tenta cadastrar o preço de um item cotado pelo fornecedor como R$ 0.00. A regra exige um valor estritamente maior que zero.
-- Erro esperado: Check constraint 'item_cotacao_chk_2' is violated.
INSERT INTO item_cotacao (id_cotacao, codigo_produto, quantidade, preco_unitario) 
VALUES (1, 1, 10.00, 0.00);

-- TABELA: item_pedido_compra
-- Erro: Violação de Restrição Única (UNIQUE)
-- O que acontece: Tenta inserir novamente o Produto 1 dentro do Pedido de Compra 1. O correto seria somar a quantidade no item já existente.
-- Erro esperado: Duplicate entry '1-1' for key 'uq_item_pedido_produto'
INSERT INTO item_pedido_compra (id_pedido_compra, codigo_produto, quantidade, preco_unitario) 
VALUES (1, 1, 5.00, 50.00);

-- TABELA: conciliacao
-- Erro: Violação de Chave Primária Composta Duplicada
-- O que acontece: Tenta registrar uma segunda conciliação exatamente para o mesmo cruzamento de Extrato Bancário 1 e Caixa 1.
-- Erro esperado: Duplicate entry '1-1' for key 'PRIMARY'
INSERT INTO conciliacao (id_lancamento, id_mov_caixa, data_conciliacao, status) 
VALUES (1, 1, '2026-10-20', 'CONCILIADO');
