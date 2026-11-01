USE Space_Metal;

-- =====================================================================
-- 1. ENTIDADES INDEPENDENTES
-- =====================================================================

-- Novos Clientes
INSERT INTO cliente (cpf_cnpj, nome, sobrenome, email, cep, rua, numero, complemento, bairro, cidade, uf, ddd, telefone) VALUES
('55667788990', 'Roberto', 'Mendes', 'roberto.mendes@email.com', '01415-000', 'Alameda Santos', '850', 'Conj 12', 'Cerqueira César', 'São Paulo', 'SP', '11', '976543210'),
('11223344000155', 'Construtora', 'Horizonte Ltda', 'contato@horizonte.com.br', '04571-010', 'Avenida Engenheiro Luís Carlos Berrini', '500', '10º Andar', 'Brooklin', 'São Paulo', 'SP', '11', '934567890');

-- Novos Fornecedores
INSERT INTO fornecedor (nome, cnpj, telefone, ddd, email, cep, rua, numero, complemento, bairro, cidade, uf, tipo_material) VALUES
('Tubos & Estruturas SP', '44556677000122', '31002200', '11', 'comercial@tubosesp.com.br', '03108-010', 'Rua Bresser', '890', NULL, 'Mooca', 'São Paulo', 'SP', 'Tubos Estruturais'),
('Vidros & Alumínio Brasil', '88990011000133', '40059900', '11', 'vendas@vidrosbrasil.com.br', '04709-110', 'Rua Verbo Divino', '300', 'Galpão 2', 'Chácara Santo Antônio', 'São Paulo', 'SP', 'Esquadrias e Vidros');

-- Novos Produtos
INSERT INTO produto (nome, tipo, material, descricao, unidade_medida, preco) VALUES
('Perfil Quadrado Aço 40x40', 'Matéria-Prima', 'Aço Carbono', 'Barra com 6 metros linear', 'UN', 135.00),
('Chapa Antiderrapante Xadrez', 'Matéria-Prima', 'Aço', 'Chapa 2.500 x 1.200mm x 3mm', 'UN', 420.00),
('Disco de Corte 7 polegadas', 'Insumo', 'Abrasivo', 'Caixa com 10 unidades para esmerilhadeira', 'CX', 85.00);

-- Posição de Estoque Inicial
INSERT INTO estoque (codigo_produto, id_fornecedor, quantidade_atual, quantidade_minima) 
SELECT codigo_produto, 
       (SELECT MIN(id_fornecedor) FROM fornecedor), 40.00, 15.00 
FROM produto ORDER BY codigo_produto DESC LIMIT 3;

-- Novos Serviços oferecidos
INSERT INTO servico (tipo_servico, valor, prazo_entrega, descricao, status) VALUES
('Escada Caracol de Ferro', 4500.00, 20, 'Escada metálica helicoidal com corrimão tubular', 'ATIVO'),
('Cobertura em Estrutura Metálica', 12000.00, 30, 'Estrutura leve para garagem com telha termoacústica', 'ATIVO');

-- Novos Funcionários
INSERT INTO funcionario (nome, sobrenome, cpf, telefone, ddd, cargo, salario, data_admissao) VALUES
('Fernando', 'Almeida', '33344455566', '971234455', '11', 'Soldador Escalado', 3800.00, '2024-01-15'),
('Beatriz', 'Lima', '44455566677', '965432211', '11', 'Projetista CAD', 4200.00, '2023-11-01');

-- Novos Lançamentos Bancários
INSERT INTO lancamento_extrato (conta_bancaria, data, descricao, valor, tipo) VALUES
('Banco Bradesco - CC 98765-4', '2026-06-01', 'Recebimento Sinal Cliente Roberto', 1350.00, 'CREDITO'),
('Banco Bradesco - CC 98765-4', '2026-06-03', 'Pagamento Tubos & Estruturas SP', 2700.00, 'DEBITO');


-- =====================================================================
-- 2. ENTIDADES DEPENDENTES
-- =====================================================================

-- Novo Orçamento (Status APROVADO)
INSERT INTO orcamento (cpf_cnpj, data, valor_total, prazo_entrega, status, desconto_aplicado, prazo_validade) VALUES
('55667788990', '2026-05-20', 4500.00, 20, 'APROVADO', 0.00, '2026-06-20');

-- Novo Contrato
INSERT INTO contrato (codigo_orcamento, data_inicio, data_termino, valor, forma_pagamento, status, percentual_sinal) 
SELECT MAX(codigo_orcamento), '2026-06-01', '2026-06-21', 4500.00, 'Transferência', 'ATIVO', 30.00 
FROM orcamento;

-- Nova Cotação com fornecedor
INSERT INTO cotacao (id_fornecedor, data_cotacao, prazo_entrega, condicao_pagamento, validade, status) 
SELECT MIN(id_fornecedor), '2026-05-22', 5, 'Faturado 28 dias', '2026-06-22', 'ACEITA' 
FROM fornecedor;

-- Novo Pedido de Compra
INSERT INTO pedido_compra (id_cotacao, data_pedido, previsao_entrega, data_recebimento, valor_total, status) 
SELECT MAX(id_cotacao), '2026-05-25', '2026-05-30', '2026-05-30', 2700.00, 'RECEBIDO' 
FROM cotacao;

-- Serviço Contratado
INSERT INTO servico_contratado (codigo_contrato, id_servico, medidas, quantidade, valor_acordado, status_execucao, data_inicio, data_conclusao) 
SELECT (SELECT MAX(codigo_contrato) FROM contrato), 
       (SELECT MIN(id_servico) FROM servico), 
       'Diâmetro 1.40m x Altura 3.00m', 1, 4500.00, 'PENDENTE', NULL, NULL;

-- Registro de Pagamento do Sinal
INSERT INTO pagamento (codigo_contrato, forma_pagamento, data_pagamento, status, data_vencimento, valor_pagamento) 
SELECT MAX(codigo_contrato), 'Transferência', '2026-06-01', 'PAGO', '2026-06-01', 1350.00 
FROM contrato;

-- Atualização pós-pagamento do sinal (Com o sub-select isolado para evitar o Erro 1093)
UPDATE servico_contratado 
SET status_execucao = 'EM_FABRICACAO', data_inicio = '2026-06-02'
WHERE id_servico_contratado = (
    SELECT id_max FROM (
        SELECT MAX(id_servico_contratado) AS id_max FROM servico_contratado
    ) AS temp
);

-- Conta a Pagar associada ao último Pedido de Compra
INSERT INTO conta_pagar (id_pedido_compra, numero_parcela, valor_previsto, data_vencimento, status) 
SELECT MAX(id_pedido_compra), 1, 2700.00, '2026-06-27', 'PAGA' 
FROM pedido_compra;

-- Movimentação de Estoque
INSERT INTO movimentacao_estoque (codigo_produto, id_servico_contratado, id_pedido_compra, tipo, quantidade) 
SELECT (SELECT MIN(codigo_produto) FROM produto), NULL, (SELECT MAX(id_pedido_compra) FROM pedido_compra), 'ENTRADA', 20.00;

-- Movimentação de Caixa
INSERT INTO movimentacao_caixa (id_pagamento, id_conta_pagar, tipo, data_movimento, valor, forma_pagamento) 
SELECT (SELECT MAX(id_pagamento) FROM pagamento), NULL, 'ENTRADA', '2026-06-01', 1350.00, 'Transferência';

INSERT INTO movimentacao_caixa (id_pagamento, id_conta_pagar, tipo, data_movimento, valor, forma_pagamento) 
SELECT NULL, (SELECT MAX(id_conta_pagar) FROM conta_pagar), 'SAIDA', '2026-06-03', 2700.00, 'Boleto';


-- =====================================================================
-- 3. ENTIDADES ASSOCIATIVAS (Relacionamentos N:N)
-- =====================================================================

-- Serviços contidos no Orçamento
INSERT INTO contem (codigo_orcamento, id_servico, medidas, sub_total, quantidade) 
SELECT MAX(codigo_orcamento), (SELECT MIN(id_servico) FROM servico), 'Diâmetro 1.40m x Altura 3.00m', 4500.00, 1 
FROM orcamento;

-- Insumos/Produtos necessários para o serviço
INSERT INTO precisa (id_servico, codigo_produto, quantidade_necessaria) 
SELECT (SELECT MIN(id_servico) FROM servico), MIN(codigo_produto), 8.00 
FROM produto;

-- Funcionário alocado na execução
INSERT INTO executa (id_funcionario, id_servico_contratado) 
SELECT MIN(id_funcionario), MAX(id_servico_contratado) 
FROM funcionario, servico_contratado;

-- Itens da Cotação
INSERT INTO item_cotacao (id_cotacao, codigo_produto, quantidade, preco_unitario) 
SELECT MAX(id_cotacao), MIN(codigo_produto), 20.00, 135.00 
FROM cotacao, produto;

-- Itens do Pedido de Compra
INSERT INTO item_pedido_compra (id_pedido_compra, codigo_produto, quantidade, preco_unitario) 
SELECT MAX(id_pedido_compra), MIN(codigo_produto), 20.00, 135.00 
FROM pedido_compra, produto;

-- Conciliação Bancária
INSERT INTO conciliacao (id_lancamento, id_mov_caixa, data_conciliacao, status, observacao) 
SELECT MAX(id_lancamento), MAX(id_mov_caixa), '2026-06-02', 'CONCILIADO', 'Sinal conciliado automaticamente' 
FROM lancamento_extrato, movimentacao_caixa;