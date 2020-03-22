defmodule Prettyprinter do
  @moduledoc """
  Documentation for `Prettyprinter`.
  """

  @doc """
  Modulo para imprimir el AST

  require String
  """

  def main(ast) do
    imprimir(ast,"")
  end

  def imprimir(ast,nivel) do
    if is_list(ast) do
      Enum.each(ast,fn(elem) -> imprimir(elem,nivel<>"") end)
    else
      case ast do
        {:function,tipo,id,_param,states} ->
          IO.puts nivel<>"FUN "<>String.upcase(tipo)<>" #{id}:"
          IO.puts nivel<>"  params:"
          IO.puts nivel<>"  body: "
          #Enum.each(states,fn(elem) -> imprimir(elem,nivel<>"    ") end)
          imprimir(states,nivel<>"    ")
        {:return,expr} ->
          IO.puts nivel<>"RETURN "
          imprimir(expr,nivel<>"  ")
        {:int,valor} ->
          IO.puts nivel<>"Int <#{valor}>"
        _ -> IO.puts nivel<>"##Error leyendo"
      end
    end
  end

end
