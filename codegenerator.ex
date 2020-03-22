defmodule CodeGenerator do
  @moduledoc """
  Documentation for `CodeGenerator`.
  """

  @doc """
  Modulo para manejar el CodeGenerator

  ## Examples

      #iex> CodeGenerator.holaMundo()
      #"Hallo Welt"

  Require Regex
  Require File
  """

  def holaMundo do
    IO.puts "Hallo Welt"
  end


  def create(codigo) do
    plantilla = 
" .globl main
main:
 movl    $returnInt, %eax
 ret"
    if is_list(codigo) do
      aux = Enum.map(codigo,fn(elem) -> 
        case elem do
          {:function,"int","main",_,statements} ->
            Enum.map(statements,fn(state) -> 
              case state do
                {:return,{:int,valor}} ->
                  valor = "#{valor}"
                  #IO.puts valor
                  Regex.replace(~r/returnInt/,plantilla,valor)
                  
                _ ->
                  nil
              end
            end)
          _ ->
            IO.puts elem
            nil
          end
      end)
      aux = hd aux
      assemblerCreator(aux)
      aux
    else
      "De plano algo raro paso"
    end
  end

  def assemblerCreator(codigo) do
    case File.open("assembler.s",[:write]) do
      {:ok,file} ->
        IO.binwrite(file,codigo)
        IO.puts "Ensamblador creado"
        File.close(file)
      _ -> IO.puts "Error escribiendo el ensamblador"
    end
  end

end
