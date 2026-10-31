-- =====================================================================
-- PROJETO ERP - SPACE METAL (Serralheria)
-- Script de Testes com Dados Inválidos (Regras de Negócio & CHECKs)
-- Baseado EXCLUSIVAMENTE nos registros cadastrados pelo script válido.

-- ATENÇÃO: EXECUTE CADA COMANDO INDIVIDUALMENTE!
-- =====================================================================

USE Space_Metal;

-- =====================================================================
-- TESTE 1: RN04 (Orçamento precisa estar APROVADO para virar contrato)
-- EXPLICAÇÃO: O orçamento 1 já existe e está 'APROVADO'. Para testar a trava
-- sem inserir novos dados válidos, tentamos inserir um contrato apontando para
-- um código de orçamento inexistente (ex: 999), cujo status retornado é NULL.
-- =====================================================================

-- COMANDO QUE DEVE GERAR ERRO (RODAR SEPARADO):
INSERT INTO contrato (codigo_contrato, codigo_orcamento, data_inicio, valor, forma_pagamento, status, percentual_sinal)
VALUES (999, 999, '2026-06-01', 1200.00, 'Pix', 'ATIVO', 30.00);
-- ERRO ESPERADO: Error Code: 1644. Erro (RN04): O orçamento precisa estar APROVADO para gerar um contrato. (ou erro de FK)

-- =====================================================================
-- TESTE 2: RN20 (Movimentação de Entrada de Estoque exige Pedido de Compra)
-- EXPLICAÇÃO: Tentativa de dar ENTRADA no produto 1 (já cadastrado)
-- sem informar o id_pedido_compra.
-- =====================================================================

-- COMANDO QUE DEVE GERAR ERRO (RODAR SEPARADO):
INSERT INTO movimentacao_estoque (codigo_produto, id_servico_contratado, id_pedido_compra, tipo, quantidade)
VALUES (1, NULL, NULL, 'ENTRADA', 10.00);
-- ERRO ESPERADO: Error Code: 1644. Erro (RN20): Movimentação de ENTRADA exige um id_pedido_compra.

-- =====================================================================
-- TESTE 3: RN20 (Movimentação de Saída de Estoque exige Serviço Contratado)
-- EXPLICAÇÃO: Tentativa de dar SAÍDA no produto 1 (já cadastrado)
-- sem informar o id_servico_contratado.
-- =====================================================================

-- COMANDO QUE DEVE GERAR ERRO (RODAR SEPARADO):
INSERT INTO movimentacao_estoque (codigo_produto, id_servico_contratado, id_pedido_compra, tipo, quantidade)
VALUES (1, NULL, NULL, 'SAIDA', 5.00);
-- ERRO ESPERADO: Error Code: 1644. Erro (RN20): Movimentação de SAÍDA exige um id_servico_contratado.

-- =====================================================================
-- TESTE 4: RN01 / RF13 (Trava de Segurança na Alteração de Status)
-- EXPLICAÇÃO: Tenta alterar o serviço contratado 1 para um status inválido
-- que não pertence ao CHECK (ex: 'EM_ANDAMENTO').
-- =====================================================================

-- COMANDO QUE DEVE GERAR ERRO (RODAR SEPARADO):
UPDATE servico_contratado
SET status_execucao = 'EM_ANDAMENTO'
WHERE id_servico_contratado = 1;
-- ERRO ESPERADO: Check constraint 'servico_contratado_chk_3' is violated.

-- =====================================================================
-- TESTE 5: Restrição CHECK de Valor Negativo ou Zerado em Produto
-- EXPLICAÇÃO: Tentativa de cadastrar um novo produto com preço zerado.
-- =====================================================================

-- COMANDO QUE DEVE GERAR ERRO (RODAR SEPARADO):
INSERT INTO produto (nome, tipo, material, descricao, unidade_medida, preco)
VALUES ('Perfil Aço Gratis', 'Matéria-Prima', 'Aço', 'Teste de preço zerado', 'UN', 0.00);
-- ERRO ESPERADO: Check constraint 'produto_chk_1' is violated.

-- =====================================================================
-- TESTE 6: Restrição CHECK de Desconto Excessivo no Orçamento (> 10%)
-- EXPLICAÇÃO: Usa o cliente existente '12345678901' e tenta aplicar 15% de desconto.
-- =====================================================================

-- COMANDO QUE DEVE GERAR ERRO (RODAR SEPARADO):
INSERT INTO orcamento (cpf_cnpj, data, valor_total, prazo_entrega, status, desconto_aplicado)
VALUES ('12345678901', '2026-06-01', 1000.00, 10, 'PENDENTE', 15.00);
-- ERRO ESPERADO: Check constraint 'orcamento_chk_2' is violated.

-- =====================================================================
-- TESTE 7: Restrição CHECK de Status PAGO sem Data de Pagamento
-- EXPLICAÇÃO: Tenta registrar um pagamento como 'PAGO' no Contrato 1 (já existente),
-- porém com data_pagamento NULL.
-- =====================================================================

-- COMANDO QUE DEVE GERAR ERRO (RODAR SEPARADO):
INSERT INTO pagamento (codigo_contrato, forma_pagamento, data_pagamento, status, data_vencimento, valor_pagamento)
VALUES (1, 'Pix', NULL, 'PAGO', '2026-06-01', 500.00);
-- ERRO ESPERADO: Check constraint 'chk_pagamento_pago' is violated.