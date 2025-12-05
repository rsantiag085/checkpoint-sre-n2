# 📘 Guia de Deploy e Rollback (SRE Nível 1)

Este documento descreve os procedimentos operacionais padrão (SOP) para implantar e reverter a aplicação SRE App.

---

## 🚀 Como fazer Deploy

### 1. Preparação Local
Antes de implantar, valide o artefato localmente:

```bash
# Construa a imagem de teste
docker build -t sre-app:1.0.1 app/

# Rode o container
docker run -p 8080:8080 sre-app:1.0.1