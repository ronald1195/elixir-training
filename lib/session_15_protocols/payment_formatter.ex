defmodule Session15.PaymentFormatter do
  @moduledoc """
  Protocol for formatting payment data.

  ## Your Task
  Define a protocol and implement it for different data types.
  """

  @doc """
  Formats payment data for display.
  """
  # TODO: Define protocol with format/1 function
  # defprotocol do
  #   def format(payment)
  # end
end

# TODO: Implement for different structs

defmodule Session15.CreditCardPayment do
  defstruct [:amount, :currency, :last_four, :brand]
end

defmodule Session15.BankTransfer do
  defstruct [:amount, :currency, :bank_name, :account_last_four]
end

defmodule Session15.CryptoPayment do
  defstruct [:amount, :currency, :wallet_address, :network]
end

# TODO: defimpl Session15.PaymentFormatter, for: Session15.CreditCardPayment do
#   def format(payment) do
#     # Return formatted string like "VISA ****1234: $50.00"
#   end
# end
