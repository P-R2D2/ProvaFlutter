# Feature Specification: Carteira de Investimentos

**Feature Branch**: `007-carteira-investimentos`  
**Created**: 2026-06-18  
**Status**: Draft  
**Input**: User description: "Quero criar a entidade Carteira para que ela possa armazenar os investimentos do usuário, e dentre esses investimentos, eles devem ser especificados."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Visualizar a Carteira e seus Investimentos (Priority: P1)

Como usuário, desejo acessar minha carteira para visualizar todos os investimentos específicos que possuo.

**Why this priority**: É a funcionalidade central; sem poder visualizar os ativos, a carteira não tem utilidade prática.

**Independent Test**: Can be fully tested by creating a portfolio with dummy investments and ensuring the user can retrieve and view the list.

**Acceptance Scenarios**:

1. **Given** um usuário logado com uma carteira vazia, **When** ele acessa a tela da carteira, **Then** o sistema exibe uma mensagem indicando que não há investimentos.
2. **Given** um usuário logado com uma carteira contendo investimentos, **When** ele acessa a tela da carteira, **Then** o sistema exibe a lista detalhada de cada investimento especificado.

---

### User Story 2 - Adicionar um Investimento Específico (Priority: P1)

Como usuário, desejo poder adicionar um novo investimento (especificando seus detalhes) à minha carteira.

**Why this priority**: É essencial para popular a carteira com dados reais do usuário.

**Independent Test**: Can be fully tested by submitting a new investment form/request and verifying it gets saved in the user's portfolio.

**Acceptance Scenarios**:

1. **Given** um usuário logado na sua carteira, **When** ele preenche os detalhes de um novo investimento e salva, **Then** o investimento é registrado na carteira com sucesso.
2. **Given** a tentativa de adicionar um investimento faltando informações obrigatórias, **When** o usuário tenta salvar, **Then** o sistema recusa e pede o preenchimento correto.

---

### Edge Cases

- What happens when o usuário tenta adicionar um valor negativo de investimento?
- How does system handle a exclusão de um investimento que já não existe na carteira?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST permitir que um usuário visualize sua carteira e todos os investimentos associados a ela.
- **FR-002**: System MUST permitir a inserção de novos investimentos, que devem estar estritamente vinculados à carteira do usuário logado.
- **FR-003**: System MUST permitir que um único usuário crie e gerencie múltiplas carteiras separadas (ex: Aposentadoria, Reserva de Emergência) para melhor dividir seus objetivos.
- **FR-004**: System MUST registrar detalhes específicos de cada investimento, exigindo as seguintes informações: Nome, Tipo de Ativo, Quantidade, Preço de Compra e Data da Compra, a fim de permitir cálculos futuros de rentabilidade e evolução patrimonial.
- **FR-005**: System MUST garantir que a carteira de um usuário não seja acessível ou visível por outro usuário.

### Key Entities *(include if feature involves data)*

- **Carteira**: A entidade que pertence exclusivamente a um Usuário e serve de agrupador para investimentos.
- **Investimento**: O ativo específico contido dentro de uma Carteira, com propriedades detalhando seu tipo, valor e características.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Usuários conseguem adicionar novos investimentos na carteira e visualizá-los em tempo real com 100% de precisão de dados.
- **SC-002**: 0% de vazamento de dados; carteiras são perfeitamente isoladas por usuário.
- **SC-003**: Consultas de carregamento da carteira de investimentos devem ser respondidas rapidamente (dentro do SLA aceitável).

## Assumptions

- Presume-se que o sistema de autenticação existente (login/cadastro) será utilizado para identificar o dono da carteira.
- Presume-se que os investimentos serão gerenciados manualmente pelo usuário neste primeiro momento, sem integrações bancárias automáticas complexas.
