defmodule Examples.Tmp do
  alias Phoenix.PubSub

  def run(time, num_sample) do
    for x <- 10..num_sample do
      Process.sleep(time)
      PubSub.broadcast(Examples.PubSub, "line_chart", {:gen, x})
    end
  end
end
