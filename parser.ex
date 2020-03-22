defmodule Parser do
  @moduledoc """
  Documentation for `Parser`.
  """

  @doc """
  Modulo para manejar el Parser

  ## Examples

      #iex> Parser.holaMundo()
      #"Parser // Funcion incompleta"

  require Regex
  require Enum
  """
  def main(tokens) do
    #El programa solo acepta directivas y declaraciones con (o sin) asignacion de variables y funciones
    ast = principal(tokens,[])
    IO.puts "Termino de generar el ast"
    ast
  end

  def principal(tokens,lista) do
    if Enum.count(tokens)>=1 do
      [head|_tail] = tokens
      case identificador(head) do
        :directiva ->
          case directiva(tokens) do
            {:ok,elemDirectiva,tokensRestantes} ->
              principal(tokensRestantes,lista++[elemDirectiva])
            {:error,mensajeError} ->
              [{:error,mensajeError}]
          end
        :tipoDato ->
          case declFuncion(tokens) do
            {:error,mensaje} -> [{:error,mensaje}]
            {funcion,tokensRestantes} ->
              lista = lista++[funcion]
              principal(tokensRestantes,lista)
          end
        _ ->
          lista++[{:sinReconocer,"El resto de los elementos no son reconocidos"}]
      end
    else
      lista
    end
  end

  def directiva([head1|[head2|tail2]]) do #Checa que tenga al menos dos elementos
    if identificador(head1)==:directiva and identificador(head2)==:idDirectiva do
      {:ok,{:directiva,:include,hd Regex.run(~r/"?[[:alnum:]\.]+"?/,head2)},tail2}
    else
      {:error,"Error en la sintaxis de directiva "<>head1<>" "<>head2}
    end
  end
  def directiva(_) do #Captura error en sintaxis
    {:error,"Error, termino antes de lo esperado"}
  end

  def declFuncion(tokens) do
    if Enum.count(tokens)>=4 do
      [aux1|[aux2|[aux3|resto]]] = tokens
      if identificador(aux1)==:tipoDato and (identificador(aux2)==:id or aux2=="main") and aux3=="\(" do
        declaraciones=parametros([aux3|resto],[])
        case declaraciones do
          {:error, mensaje} -> {:error, mensaje<>" in function "<>aux2}
          {listaParam,restoTokens} ->
            tokens = restoTokens
            if Enum.count(tokens)>=1 do
              case (hd tokens) do
                "\{" ->
                  #{listaStatements,tokens} = statements(tokens,[]) #Aqui me quede
                  #{{:function,aux1,aux2,listaParam,listaStatements},}
                  case statements(tokens,[]) do
                    {:error,mensaje} -> {:error,mensaje<>" en la funcion "<>aux2}
                    {listaStatements,tokens} -> {{:function,aux1,aux2,listaParam,listaStatements},tokens}
                    inesperado ->
                      IO.puts inesperado
                      {:error,"Unexpected error in statements of function "<>aux2}
                  end
                ";" ->
                  [_aux|tokens] = tokens
                  {{:function,aux1,aux2,listaParam,[]},tokens}
                _ -> {:error, "Unexpected function token. Expected ; or \{. In function "<>aux2}
              end
            end
          _ -> {:error, "Unexpected error in function "<>aux2}
        end
      else
        {:error, "Error in function syntax, expected type name ( [...], got "<>aux1<>" "<>aux2<>" "<>aux3<>" [...]"}
      end
    else
      {:error,"Error, funcion termino antes de lo esperado"}
    end
  end

  def statements(tokens,lista) do
    IO.puts "Entro a statements"
    IO.puts tokens
    if (((hd tokens) == "\{") and Enum.count(lista)==0) do
      [_aux|tokens]=tokens
      statements(tokens,lista)
    else
      IO.puts "Leyendo statements"
      if (hd tokens) == "\}" do
        [_aux|resto]= tokens
        {lista,resto}
      else
        if Enum.count(tokens)>=1 do
          [aux|resto] = tokens
          case identificador(aux) do
            :tipoDato ->
              case declVariables(resto,lista,aux) do
                {:error,mensaje} -> {:error,mensaje}
                {nuevosElem,resto} ->
                  lista = lista ++ nuevosElem
                  tokens = resto
                  statements(tokens,lista)
                _ -> {:error,"Unexpected error in statements reading"}
              end
            :reser ->
              case aux do
                "return" ->
                  case returnStatement(tokens) do
                    {:error,mensaje} -> {:error,mensaje}
                    {nuevoElem,resto} ->
                      lista = lista ++ [nuevoElem]
                      tokens = resto
                      statements(tokens,lista)
                  end
                _ -> {:error,"Unrecognized statement: "<>aux}
              end
            _ -> {:error, "Unrecognized statement: "<>aux}
          end
        else
            {:error,"Lectura de statements termino antes de lo esperado"}
        end
      end
    end
  end

  def declVariables(tokens,lista,tipo) do
    IO.puts "Entro a declaracion de variables"<>tipo<>"con:"
    IO.puts tokens
    if ((identificador(hd tokens) == :tipoDato) and Enum.count(lista)==0 and (hd tokens)!="void") do
      [_aux|lista]=lista
      IO.puts lista
    end
    if (hd tokens) == ";" do
      [_aux|resto]= tokens
      {lista,resto}
    else
      if Enum.count(tokens)>=2 do
        [aux1|resto] = tokens
        if identificador(aux1)==:id do
          lista = lista++[{:declVar,aux1}]
          [aux2|resto] = resto
          case aux2 do
            "," -> declVariables(resto,lista,tipo)
            ";" -> declVariables([aux2|resto],lista,tipo)
            "=" ->
              expres = expresion(resto)
              case expres do
                {:error,mensaje} -> {:error,mensaje}
                {auxExpres,resto} -> #Cambiar expresion por  {:expresion}
                  lista = lista++[{:asign,aux1,auxExpres}]

                  #En caso de querer hacer asignaciones contiguas int a=b=1+2;, por aqui se debe cambiar el
                  [aux1|resto] = resto
                  case aux1 do
                    "," -> declVariables(resto,lista,tipo)
                    ";" -> declVariables([aux1|resto],lista,tipo)
                    _ -> {:error,"In variable declaration (2), expected ',' or ';', got "<>aux1}
                  end
                _ -> {:error,"ERROR en la asignacion de valor a la variable declarada"}

              end
            _ -> {:error,"In variable declaration, expected ',', ';' or '=', got "<>aux1}
          end
        else
          {:error,"Invalid var name: "<>aux1}
        end
      else
          {:error,"Lectura de parametros termino antes de lo esperado"}
      end
    end
  end

  def expresion(tokens) do ## 2; debe devolver el ; en la lista de tokens
    ##Falta validar la longitud de tokens
    [aux|resto] = tokens
    ##Cambiar todo el case para aceptar mas casos
    case identificador(aux) do
      :cadena -> {{:cadena,aux},resto}
      :id -> {{:variable,aux},resto}
      :flotante ->
        {valor,_rest} = Float.parse(aux)
        {{:float,valor},resto}
      :int ->
        {valor,_rest} = Integer.parse(aux)
        {{:int,valor},resto}
      _ -> {:error,"Error leyendo la expresion"}
    end
  end

  def parametros(tokens,lista) do #Tipo (int a, char c, float d) do
    [aux|resto] = tokens
    if ((aux == "\(") and Enum.count(lista)==0) do
      parametros(resto,lista)
    else

      if (aux == "\)") do
        {lista,resto}
      else
        IO.puts "Entro a else"
        if Enum.count(tokens)>=2 do
          [aux1|[aux2|resto]] = tokens
          if identificador(aux1)==:tipoDato and aux1 != "void" and identificador(aux2)==:id do
            [aux|resto]=resto
            case aux do
              "," -> parametros(resto,lista++[{:parametro,aux1,aux2}])
              "\)" -> parametros([aux|resto],lista++[{:parametro,aux1,aux2}])
              _ -> {:error,"Expected ) or , instead got "<>aux}
            end
          else
            {:error,"#Sintaxis de parametro invalida "<>aux1<>" "<>aux2}
          end
        else
            {:error,"Lectura de parametros termino antes de lo esperado"}
        end
      end
    end
  end

  def returnStatement(tokens) do
    if Enum.count(tokens)>=2 do
      [_aux1|[aux|tokens]] = tokens
      if (aux==";") do
        {{:return,:empty},tokens}
      else
        case expresion([aux|tokens]) do
          {:error,mensaje} -> {:error,mensaje<>" ...in return statement"}
          {expr,tokens} ->
            [aux|tokens] = tokens
            if (aux==";") do
              {{:return,expr},tokens}
            else
              {:error, "Unexpected token in return statement, expected ';', got "<>aux}
            end
          _ -> {:error, "Unexpected error reading return statement"}
        end
      end
    else
      {:error, "Return statement ends before expected"}
    end
  end

  def identificador(elem) do
    cond do
      String.match?(elem,~r/^\".*\"$/) ->
        :cadena
      String.match?(elem,~r/^int|float|double|char|void$/) ->
        :tipoDato
      String.match?(elem,~r/^main|struct|break|if|else|long|switch|case|for|while|do|default|const|return$/) ->
        :reser
      String.match?(elem,~r/^\+|\-|\/|\*|\%|\!|\~$/) ->
        :operador
      String.match?(elem,~r/^[a-zA-Z][[:alnum:]]*$/) ->
        :id
      String.match?(elem,~r/^[0-9]+\.[0-9]+$/) ->
        :flotante
      String.match?(elem,~r/^[0-9]+$/) ->
        :int
      String.match?(elem,~r/^<"?[[:alnum:]\.]+"?>$/) ->
        :idDirectiva
      String.match?(elem,~r/^#include$/) ->
        :directiva
      true ->
        :unid
    end
  end

end
