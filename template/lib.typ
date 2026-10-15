// Função principal `curriculo` e componentes visuais.

#import "i18n.typ": t, campo, traduz-status
#import "datas.typ": formata-data, formata-periodo
#import "filtros.typ": filtra, ordena-por-data, ordena-por-recencia, prepara-experiencias
#import "validacao.typ": valida, falha

#let cor-padrao = rgb("#1f4e79")
#let fonte = "Source Sans 3"

// ---------------------------------------------------------------------------
// Utilitários
// ---------------------------------------------------------------------------

// Link clicável que exibe o próprio endereço, sem "https://".
#let link-visivel(endereco) = {
  let endereco = str(endereco)
  let destino = if endereco.contains("://") or endereco.starts-with("mailto:") { endereco } else { "https://" + endereco }
  let texto = endereco.replace(regex("^https?://"), "")
  link(destino, texto)
}

// Caminhos do YAML são relativos à raiz do projeto (--root).
#let caminho-raiz(caminho) = if caminho.starts-with("/") { caminho } else { "/" + caminho }

#let le-cor(valor) = {
  if valor == none or valor == "" { return cor-padrao }
  let valor = if valor.starts-with("#") { valor } else { "#" + valor }
  if valor.match(regex("^#([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$")) == none {
    falha("cor \"" + valor + "\" inválida; use hexadecimal, ex.: --input cor=#1f4e79")
  }
  rgb(valor)
}

// Linha com conteúdo à esquerda e data alinhada à direita.
#let linha-com-data(esquerda, direita) = grid(
  columns: (1fr, auto),
  column-gutter: 1em,
  esquerda,
  if direita != none { text(fill: luma(35%), direita) },
)

#let detalhe(conteudo) = text(fill: luma(35%), style: "italic", conteudo)

// Entrada de uma seção que não deve ser quebrada entre páginas.
#let entrada(corpo) = block(breakable: false, above: 0.75em, below: 0pt, width: 100%, corpo)

// ---------------------------------------------------------------------------
// Cabeçalho
// ---------------------------------------------------------------------------

#let contatos(pessoal, idioma) = {
  let partes = ()
  let cidade = campo(pessoal, "cidade", idioma)
  if cidade != none { partes.push(cidade) }
  if pessoal.at("telefone", default: none) != none {
    let tel = str(pessoal.telefone)
    partes.push(link("tel:" + tel.replace(regex("[^0-9+]"), ""), tel))
  }
  partes.push(link("mailto:" + pessoal.email, pessoal.email))
  for chave in ("linkedin", "github", "site") {
    if pessoal.at(chave, default: none) != none { partes.push(link-visivel(pessoal.at(chave))) }
  }
  // Cada contato é indivisível: a quebra de linha só acontece entre eles.
  partes.map(box).join([ #text(fill: luma(55%))[|] ])
}

#let cabecalho(pessoal, titulo, idioma, cor, mostrar-foto) = {
  let identificacao = {
    block(below: 0.45em, text(size: 22pt, weight: "bold", pessoal.nome))
    block(below: 0.6em, text(size: 12.5pt, fill: cor, weight: "semibold", titulo))
    block(text(size: 9.5pt, hyphenate: false, contatos(pessoal, idioma)))
  }
  let foto = pessoal.at("foto", default: none)
  if mostrar-foto and foto != none {
    grid(
      columns: (1fr, auto),
      column-gutter: 1.2em,
      align: (left + horizon, right + horizon),
      identificacao,
      box(clip: true, radius: 50%, image(caminho-raiz(foto), width: 2.3cm, height: 2.3cm, fit: "cover")),
    )
  } else {
    identificacao
  }
}

// ---------------------------------------------------------------------------
// Seções
// ---------------------------------------------------------------------------

#let secao-resumo(dados, perfil, tags, idioma) = {
  let resumos = dados.at("resumos", default: none)
  if resumos == none { return none }
  let texto = campo(resumos, perfil, idioma, default: campo(resumos, "padrao", idioma))
  if texto == none { return none }
  par(justify: true, texto)
}

#let secao-experiencias(dados, perfil, tags, idioma) = {
  let experiencias = prepara-experiencias(dados.at("experiencias", default: ()), tags)
  if experiencias.len() == 0 { return none }
  for exp in experiencias {
    entrada({
      linha-com-data(
        [*#campo(exp, "cargo", idioma)* — #campo(exp, "empresa", idioma)],
        formata-periodo(exp.inicio, exp.at("fim", default: none), idioma),
      )
      let local = campo(exp, "local", idioma)
      if local != none { v(0.25em, weak: true); detalhe(local) }
      let bullets = exp.itens.map(b => if type(b) == str { b } else { campo(b, "texto", idioma) })
      if bullets.len() > 0 {
        v(0.4em, weak: true)
        list(..bullets)
      }
    })
  }
}

#let secao-projetos(dados, perfil, tags, idioma) = {
  let projetos = filtra(dados.at("projetos", default: ()), tags)
  if projetos.len() == 0 { return none }
  for proj in projetos {
    entrada({
      let link-proj = proj.at("link", default: none)
      linha-com-data(
        strong(campo(proj, "nome", idioma)),
        if link-proj != none { link-visivel(link-proj) },
      )
      let descricao = campo(proj, "descricao", idioma)
      if descricao != none { v(0.3em, weak: true); descricao }
      let tecnologias = proj.at("tecnologias", default: ())
      if tecnologias != none and tecnologias.len() > 0 {
        v(0.3em, weak: true)
        detalhe(t("tecnologias", idioma) + ": " + tecnologias.map(str).join(", "))
      }
    })
  }
}

#let secao-formacao(dados, perfil, tags, idioma) = {
  let formacao = ordena-por-recencia(filtra(dados.at("formacao", default: ()), tags))
  if formacao.len() == 0 { return none }
  for item in formacao {
    entrada({
      linha-com-data(
        [*#campo(item, "curso", idioma)* — #campo(item, "instituicao", idioma)],
        formata-periodo(item.inicio, item.at("fim", default: none), idioma),
      )
      let status = traduz-status(item, idioma)
      if status != none { v(0.25em, weak: true); detalhe(status) }
    })
  }
}

#let secao-habilidades(dados, perfil, tags, idioma) = {
  let grupos = filtra(dados.at("habilidades", default: ()), tags)
  if grupos.len() == 0 { return none }
  v(0.85em, weak: true)
  grid(
    columns: (auto, 1fr),
    column-gutter: 0.8em,
    row-gutter: 0.55em,
    ..grupos.map(g => (strong(campo(g, "grupo", idioma) + ":"), g.itens.map(str).join(", "))).flatten(),
  )
}

#let secao-certificacoes(dados, perfil, tags, idioma) = {
  let certificacoes = ordena-por-data(filtra(dados.at("certificacoes", default: ()), tags))
  if certificacoes.len() == 0 { return none }
  for cert in certificacoes {
    entrada({
      let emissor = campo(cert, "emissor", idioma)
      let link-cert = cert.at("link", default: none)
      linha-com-data(
        {
          strong(campo(cert, "nome", idioma))
          if emissor != none [ — #emissor]
          if link-cert != none [ — #link-visivel(link-cert)]
        },
        formata-data(cert.at("data", default: none), idioma),
      )
    })
  }
}

#let secao-idiomas(dados, perfil, tags, idioma) = {
  let idiomas = filtra(dados.at("idiomas", default: ()), tags)
  if idiomas.len() == 0 { return none }
  v(0.85em, weak: true)
  idiomas
    .map(i => [*#campo(i, "idioma", idioma):* #campo(i, "nivel", idioma)])
    .join(h(0.6em) + text(fill: luma(55%), "|") + h(0.6em))
}

#let secao-atividades(dados, perfil, tags, idioma) = {
  let atividades = ordena-por-data(filtra(dados.at("atividades", default: ()), tags))
  if atividades.len() == 0 { return none }
  for ativ in atividades {
    entrada({
      let org = campo(ativ, "org", idioma)
      linha-com-data(
        {
          strong(campo(ativ, "titulo", idioma))
          if org != none [ — #org]
        },
        formata-data(ativ.at("data", default: none), idioma),
      )
      let descricao = campo(ativ, "descricao", idioma)
      if descricao != none { v(0.3em, weak: true); descricao }
    })
  }
}

#let renderizadores = (
  resumo: secao-resumo,
  experiencias: secao-experiencias,
  projetos: secao-projetos,
  formacao: secao-formacao,
  habilidades: secao-habilidades,
  certificacoes: secao-certificacoes,
  idiomas: secao-idiomas,
  atividades: secao-atividades,
)

// ---------------------------------------------------------------------------
// Documento
// ---------------------------------------------------------------------------

// Gera o currículo de `perfil` a partir de `dados` (dicionário lido do YAML).
//  - idioma: "pt" ou "en"
//  - cor: hexadecimal da cor de destaque, ex.: "#1f4e79"
//  - foto: false oculta a foto mesmo que `pessoal.foto` exista
#let curriculo(dados, perfil: "full-cycle", idioma: "pt", cor: none, foto: true) = {
  valida(dados, perfil, idioma)
  let cor = le-cor(cor)
  let pessoal = dados.pessoal
  let config = dados.perfis.at(perfil)
  let tags = config.at("tags", default: ())
  let titulo = campo(config, "titulo", idioma, default: campo(pessoal, "titulo_padrao", idioma, default: ""))

  set document(title: pessoal.nome + " — " + titulo, author: pessoal.nome)
  set page(
    paper: "a4",
    margin: (x: 1.5cm, top: 1.4cm, bottom: 1.5cm),
    footer: context {
      let total = counter(page).final().first()
      if total > 1 {
        set text(size: 8.5pt, fill: luma(45%))
        align(right)[#pessoal.nome — #t("pagina", idioma) #counter(page).display() / #total]
      }
    },
  )
  set text(font: fonte, size: 10pt, lang: idioma, region: if idioma == "pt" { "BR" } else { none })
  set par(leading: 0.5em, spacing: 0.65em)
  set list(indent: 0.6em, body-indent: 0.5em, spacing: 0.4em, marker: text(fill: cor, sym.bullet))
  show link: set text(fill: cor)

  show heading.where(level: 1): it => block(above: 1.05em, below: 0.15em, sticky: true, width: 100%, {
    set text(size: 11.5pt, weight: "bold", fill: cor)
    upper(it.body)
    v(0.25em, weak: true)
    line(length: 100%, stroke: 0.6pt + cor)
  })

  cabecalho(pessoal, titulo, idioma, cor, foto)

  for secao in config.secoes {
    let corpo = renderizadores.at(secao)(dados, perfil, tags, idioma)
    // Seção vazia após o filtro não ganha título órfão.
    if corpo != none {
      heading(level: 1, t(secao, idioma))
      corpo
    }
  }
}
