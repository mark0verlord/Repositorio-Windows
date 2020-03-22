defmodule Gcc do
  @moduledoc """
  Documentation for `Gcc`.
  """

  @doc """
  Modulo para manejar el Gcc

  ## Examples

      #iex> Gcc.hola()
      #"Limpiando // Funcion incompleta"

  
  """

  def hola() do
    IO.puts "GCC"
  end

  def exeCreator() do
    System.cmd("gcc",["-m32","assembler.s","-o","out"])
  end

end
