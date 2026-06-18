# Checklist de Qualidade de Requisitos: API e Banco de Dados

**Purpose**: Verificação rápida de sanidade (Sanity Check) para o desenvolvedor antes da codificação
**Created**: 2026-06-18
**Feature**: [spec.md](file:///d:/workspace/ProvaFlutter/specs/007-carteira-investimentos/spec.md)

## Requirement Completeness
- [x] CHK001 - Os formatos exatos de resposta de erro (HTTP Status e payload) estão definidos para casos de valores negativos rejeitados? [Completeness, Gap]
- [x] CHK002 - As regras de tamanho máximo (length) ou caracteres especiais para os nomes de Carteira e Investimento estão documentadas? [Completeness, Data Model]
- [x] CHK003 - Existe um limite máximo definido de investimentos que uma carteira pode ter? [Completeness, Gap]

## Requirement Clarity
- [x] CHK004 - O formato de data/hora (ex: ISO-8601 UTC) para o campo `purchaseDate` está inequivocamente especificado? [Clarity, Spec §FR-004]
- [x] CHK005 - A forma de extração do usuário logado (ex: a partir do token JWT) para vinculação de carteira está claramente definida? [Clarity, Spec §FR-002]

## Security & Isolation
- [x] CHK006 - Os requisitos definem claramente que acessos via ID da carteira (ex: `/portfolios/:id`) devem validar a posse contra o usuário do token (prevenção contra IDOR)? [Security, Spec §FR-005]
- [x] CHK007 - Os requisitos documentam o que deve ocorrer se houver falha de banco de dados durante uma gravação em lote? [Exception Flow, Gap]

## Edge Cases
- [x] CHK008 - O comportamento do sistema (ex: erro 409 Conflict ou aceitação) está especificado caso o usuário tente criar duas carteiras com nomes idênticos? [Edge Case, Gap]
- [x] CHK009 - O comportamento exato de resposta (ex: array vazio `[]` com 200 OK) está especificado para consultas em carteiras vazias? [Edge Case, Spec §US1]
