defmodule Pedidos do
  use GenStateMachine

  def start_link(nome, telefone) do
    pedido = %{pedido: DateTime.utc_now(), cliente: %{nome: nome, telefone: telefone}}
    GenStateMachine.start_link(__MODULE__, {:ligacao, pedido})
  end

  def iniciar_pedido(nome, telefone) do
    {:ok, pid} = start_link(nome, telefone)
    pid
  end

  def status(pid), do: GenStateMachine.call(pid, :status)

  def realizar_pedido(pid, descricao) do
    GenStateMachine.cast(pid, {:pedido, descricao})
  end

  def cancelar(pid) do
    GenStateMachine.cast(pid, :problema_com_pedido)
  end

  def concluir(pid) do
    GenStateMachine.cast(pid, :pedido_encaminhado)
  end

  # SERVER

  def handle_event({:call, from}, :status, state, pedido) do
    {:next_state, state, pedido, [{:reply, from, {state, pedido}}]}
  end

  def handle_event(:cast, {:pedido, descricao}, :ligacao, pedido) do
    {:next_state, :aguardar, %{dados: pedido, descricao: descricao}}
  end

  def handle_event(:cast, :problema_com_pedido, :aguardar, pedido) do
    {:next_state, :cancelado, {pedido, "Houve um problema com o pedido"}}
  end

  def handle_event(:cast, :pedido_encaminhado, :aguardar, pedido) do
    {:next_state, :concluido, {pedido, "Seu pedido chegará em 5 minutos"}}
  end
end
