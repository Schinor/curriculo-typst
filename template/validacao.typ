// Checagem do YAML antes de renderizar, com mensagens de erro em português.

#import "datas.typ": data-valida, normaliza
#import "i18n.typ": idiomas-suportados

#let secoes-conhecidas = (
  "resumo", "experiencias", "projetos", "formacao",
  "habilidades", "certificacoes", "idiomas", "atividades",
)

// Campos obrigatórios de cada item das listas.
#let obrigatorios = (
  experiencias: ("cargo", "empresa", "inicio"),
  projetos: ("nome",),
  formacao: ("curso", "instituicao", "inicio"),
  habilidades: ("grupo", "itens"),
  certificacoes: ("nome",),
  idiomas: ("idioma", "nivel"),
  atividades: ("titulo",),
)

// Campos de data de cada lista; `fim` aceita também "atual".
#let campos-data = (
  experiencias: ("inicio", "fim"),
  formacao: ("inicio", "fim"),
  certificacoes: ("data",),
  atividades: ("data",),
)

#let falha(mensagem) = panic("[curriculo] " + mensagem)

#let lista-ou-vazio(dados, chave) = {
  let valor = dados.at(chave, default: none)
  if valor == none { return () }
  if type(valor) != array { falha("\"" + chave + "\" deve ser uma lista") }
  valor
}

#let valida-tags(item, onde) = {
  let tags = item.at("tags", default: none)
  if tags != none and type(tags) != array {
    falha(onde + ".tags deve ser uma lista, ex.: tags: [ml, engenharia]")
  }
}

#let valida-data(item, campo, onde) = {
  let valor = item.at(campo, default: none)
  if valor == none { return }
  if not data-valida(valor, aceita-atual: campo == "fim") {
    let esperado = if campo == "fim" { "\"AAAA-MM\" ou \"atual\"" } else { "\"AAAA-MM\"" }
    falha(onde + "." + campo + " = \"" + normaliza(valor) + "\" fora do formato " + esperado)
  }
}

#let valida-bullets(exp, onde) = {
  let itens = exp.at("itens", default: none)
  if itens == none { return }
  if type(itens) != array { falha(onde + ".itens deve ser uma lista") }
  for (j, bullet) in itens.enumerate() {
    let onde-b = onde + ".itens[" + str(j) + "]"
    if type(bullet) == dictionary {
      if "texto" not in bullet { falha(onde-b + " sem campo obrigatório \"texto\"") }
      valida-tags(bullet, onde-b)
    } else if type(bullet) != str {
      falha(onde-b + " deve ser um texto ou um objeto com \"texto\"")
    }
  }
}

#let valida-lista(dados, secao) = {
  for (i, item) in lista-ou-vazio(dados, secao).enumerate() {
    let onde = secao + "[" + str(i) + "]"
    if type(item) != dictionary { falha(onde + " deve ser um objeto com campos") }
    for campo in obrigatorios.at(secao) {
      if item.at(campo, default: none) == none {
        falha(onde + " sem campo obrigatório \"" + campo + "\"")
      }
    }
    for campo in campos-data.at(secao, default: ()) { valida-data(item, campo, onde) }
    valida-tags(item, onde)
    if secao == "experiencias" { valida-bullets(item, onde) }
    if secao == "habilidades" and type(item.itens) != array {
      falha(onde + ".itens deve ser uma lista")
    }
  }
}

#let valida-pessoal(dados) = {
  let pessoal = dados.at("pessoal", default: none)
  if type(pessoal) != dictionary { falha("seção obrigatória \"pessoal\" ausente") }
  for campo in ("nome", "email") {
    if pessoal.at(campo, default: none) == none {
      falha("pessoal sem campo obrigatório \"" + campo + "\"")
    }
  }
}

#let valida-perfil(dados, perfil) = {
  let perfis = dados.at("perfis", default: none)
  if type(perfis) != dictionary or perfis.len() == 0 {
    falha("seção obrigatória \"perfis\" ausente ou vazia")
  }
  if perfil not in perfis {
    falha("perfil \"" + perfil + "\" não existe em perfis; disponíveis: " + perfis.keys().join(", "))
  }
  let config = perfis.at(perfil)
  let onde = "perfis." + perfil
  if type(config) != dictionary { falha(onde + " deve ser um objeto") }
  let secoes = config.at("secoes", default: none)
  if type(secoes) != array or secoes.len() == 0 {
    falha(onde + ".secoes deve ser uma lista não vazia")
  }
  for secao in secoes {
    if secao not in secoes-conhecidas {
      falha(onde + ".secoes contém seção desconhecida \"" + str(secao) + "\"; válidas: " + secoes-conhecidas.join(", "))
    }
  }
  valida-tags(config, onde)
}

#let valida(dados, perfil, idioma) = {
  if type(dados) != dictionary { falha("o arquivo de dados deve ser um objeto YAML") }
  if idioma not in idiomas-suportados {
    falha("idioma \"" + idioma + "\" não suportado; disponíveis: " + idiomas-suportados.join(", "))
  }
  valida-pessoal(dados)
  valida-perfil(dados, perfil)
  for secao in obrigatorios.keys() { valida-lista(dados, secao) }
  let resumos = dados.at("resumos", default: none)
  if resumos != none and type(resumos) != dictionary {
    falha("\"resumos\" deve ser um objeto com chaves por perfil (ex.: padrao, data-engineer)")
  }
}
