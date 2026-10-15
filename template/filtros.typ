// Seleção de itens por tags e ordenação.

#import "datas.typ": chave-recencia

// Item sem `tags` (ou com lista vazia) aparece em todos os perfis;
// caso contrário, precisa compartilhar ao menos uma tag com o perfil.
#let visivel(item, tags) = {
  if type(item) != dictionary { return true }
  let proprias = item.at("tags", default: ())
  if proprias == none or proprias.len() == 0 { return true }
  proprias.any(tag => tag in tags)
}

#let filtra(itens, tags) = {
  if itens == none { return () }
  itens.filter(item => visivel(item, tags))
}

// Mais recente primeiro; ver `chave-recencia`.
#let ordena-por-recencia(itens) = itens.sorted(key: chave-recencia).rev()

// Para itens com uma única data (`data`), mais recente primeiro; sem data vão ao fim.
#let ordena-por-data(itens) = itens.sorted(key: item => str(item.at("data", default: ""))).rev()

// Experiências visíveis, ordenadas, com os bullets também filtrados.
// Uma experiência cujos bullets foram todos removidos continua aparecendo.
#let prepara-experiencias(experiencias, tags) = {
  let visiveis = filtra(experiencias, tags).map(exp => {
    exp.insert("itens", filtra(exp.at("itens", default: ()), tags))
    exp
  })
  ordena-por-recencia(visiveis)
}
