defmodule Examples.Tmp do
  alias Phoenix.PubSub

  def gen_numbers(time, num_sample) do
    for x <- 1..num_sample do
      Process.sleep(time)
      PubSub.broadcast(Examples.PubSub, "line_chart", {:gen, x})
    end
  end

  def gen_datetimes(time, num_sample) do
    for x <- 1..num_sample do
      Process.sleep(time)
      dt = DateTime.utc_now() |> DateTime.to_unix()

      PubSub.broadcast(Examples.PubSub, "timeline_chart", {:gen, dt})
    end
  end
end
