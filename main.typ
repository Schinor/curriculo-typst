#import "template/lib.typ": curriculo

#let dados  = yaml(sys.inputs.at("dados",  default: "/exemplos/dados.yaml"))
#let perfil = sys.inputs.at("perfil", default: "full-cycle")
#let idioma = sys.inputs.at("idioma", default: "pt")

#curriculo(
  dados,
  perfil: perfil,
  idioma: idioma,
  cor: sys.inputs.at("cor", default: none),
  foto: sys.inputs.at("foto", default: "sim") != "nao",
)
