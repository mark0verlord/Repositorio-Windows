defmodule Main do
  @moduledoc """
  Documentation for `Main`.
  """

  @doc """
  Modulo para manejar el resto de los modulos

  ## Examples

      #iex> Main.holaMundo()
      #"Main // Funcion incompleta"


  """

  def holaMundo(nil) do
    IO.puts "Main // Funcion incompleta"
  end

  def mainCompleto(nombreArchivo) do
    IO.puts "- -\tLeyendo archivo...\t - - "
    archivo = Lector.lectorArchivo(nombreArchivo)
    IO.puts archivo
    IO.puts "- -\tEjecutando lexer\t - -"
    listaTokens = Lexer.lexer(archivo)
    IO.puts listaTokens
    IO.puts "- -\t Limpiando lista de tokens\t - - "
    listaTokens = Lexer.borrarComentarios(listaTokens)
    IO.puts listaTokens
    IO.puts "- -\t Parser\t - - "
    ast=Parser.main(listaTokens)
    ##IO.puts ast
    IO.puts "- -\t PrettyPrinting\t - -"
    Prettyprinter.main(ast)
    IO.puts "- -\t Generador de Codigo\t - -"
    codigo = CodeGenerator.create(ast)
    IO.puts codigo
    IO.puts "- -\t Creador de Ejecutable\t - -"
    Gcc.exeCreator()

    #listaTokens
  end



end
