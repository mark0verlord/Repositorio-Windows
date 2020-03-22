defmodule Lector do
  @moduledoc """
  Documentation for `Lector`.
  """

  @doc """
  Modulo para manejar el lector de archivo

  ## Examples

      #iex> Lector.holaMundo()
      #"Lector // Funcion incompleta"

  require File
  """

  def limpiar(nil) do
    IO.puts "Lector // Funcion incompleta"
  end

  def lectorArchivo(nombreArchivo) do
    {:ok,archivo} = File.read(nombreArchivo)
    archivo
  end


end
