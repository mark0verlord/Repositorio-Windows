defmodule Sanitizer do
  @moduledoc """
  Documentation for `Santizer`.
  """

  @doc """
  Modulo para manejar el AST

  ## Examples

      #iex> Sanitizer.limpiar()
      #"Limpiando // Funcion incompleta"

  
  """

  def limpiar(nil) do
    IO.puts "Limpiando // Funcion incompleta"
  end



end
