// Rótulos de interface e tradução de campos.

#let idiomas-suportados = ("pt", "en")

#let rotulos = (
  pt: (
    resumo: "Resumo",
    experiencias: "Experiência profissional",
    projetos: "Projetos",
    formacao: "Formação acadêmica",
    habilidades: "Habilidades",
    certificacoes: "Certificações",
    idiomas: "Idiomas",
    atividades: "Atividades complementares",
    atual: "atual",
    tecnologias: "Tecnologias",
    pagina: "Página",
  ),
  en: (
    resumo: "Summary",
    experiencias: "Professional experience",
    projetos: "Projects",
    formacao: "Education",
    habilidades: "Skills",
    certificacoes: "Certifications",
    idiomas: "Languages",
    atividades: "Additional activities",
    atual: "present",
    tecnologias: "Technologies",
    pagina: "Page",
  ),
)

#let meses = (
  pt: ("jan.", "fev.", "mar.", "abr.", "maio", "jun.", "jul.", "ago.", "set.", "out.", "nov.", "dez."),
  en: ("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"),
)

// Valores conhecidos de `formacao[].status`, traduzidos automaticamente.
#let status-formacao = (
  "em andamento": (pt: "em andamento", en: "in progress"),
  "concluído": (pt: "concluído", en: "completed"),
  "concluido": (pt: "concluído", en: "completed"),
  "trancado": (pt: "trancado", en: "on hold"),
)

// Rótulo de interface no idioma pedido.
#let t(chave, idioma) = rotulos.at(idioma).at(chave)

// Lê `nome` de um item respeitando o idioma: com idioma "en", usa
// `nome_en` se existir; caso contrário, cai no campo sem sufixo.
#let campo(item, nome, idioma, default: none) = {
  if type(item) != dictionary { return default }
  let traduzido = nome + "_" + idioma
  if idioma != "pt" and traduzido in item { item.at(traduzido) } else { item.at(nome, default: default) }
}

// Status da formação: `status_en` tem prioridade; depois, tradução de valores conhecidos.
#let traduz-status(item, idioma) = {
  let traduzido = "status_" + idioma
  if idioma != "pt" and traduzido in item { return item.at(traduzido) }
  let status = item.at("status", default: none)
  if status == none { return none }
  let conhecido = status-formacao.at(lower(status), default: none)
  if conhecido == none { status } else { conhecido.at(idioma) }
}
