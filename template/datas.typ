// Datas no formato "AAAA-MM" ou a palavra "atual".

#import "i18n.typ": meses, t

#let padrao-data = regex("^\d{4}-(0[1-9]|1[0-2])$")

// Aceita números vindos do YAML sem aspas (ex.: 2025) convertendo para texto.
#let normaliza(valor) = if valor == none { none } else { str(valor) }

#let data-valida(valor, aceita-atual: false) = {
  let valor = normaliza(valor)
  if aceita-atual and valor == "atual" { return true }
  valor != none and valor.match(padrao-data) != none
}

// "2025-03" → "mar. 2025" (pt) ou "Mar 2025" (en); "atual" → "atual"/"present".
#let formata-data(valor, idioma) = {
  let valor = normaliza(valor)
  if valor == none { return none }
  if valor == "atual" { return t("atual", idioma) }
  let (ano, mes) = valor.split("-")
  meses.at(idioma).at(int(mes) - 1) + " " + ano
}

#let formata-periodo(inicio, fim, idioma) = {
  let ini = formata-data(inicio, idioma)
  let fi = formata-data(fim, idioma)
  if ini == none { fi } else if fi == none { ini } else { ini + " – " + fi }
}

// Chave textual para ordenar do mais recente ao mais antigo:
// itens em andamento (`fim: atual`) vêm primeiro, depois pelo `inicio`.
#let chave-recencia(item) = {
  let em-andamento = normaliza(item.at("fim", default: none)) == "atual"
  (if em-andamento { "1" } else { "0" }) + normaliza(item.at("inicio", default: "0000-00"))
}
