namespace :fetcher do
  desc "TODO"
  task scratch: :environment do
    symbol = 'JTOUSDT'

    interval = '1m'

    initial_date_time = DateTime.parse('2024-01-14').utc

    def generate_url(symbol, interval, date_time)
      start_time = date_time.beginning_of_day.to_i * 1e3.to_i

      end_time = date_time.end_of_day.to_i * 1e3.to_i

      URI("https://fapi.binance.com/fapi/v1/klines?symbol=#{symbol}&interval=#{interval}&starttime=#{start_time}&endtime=#{end_time}&limit=1500")
    end

    workers = []

    worker_count = 10

    queue = Queue.new

    worker_count.times do |i|
      workers << Thread.new do
        date_time = initial_date_time - i.days

        loop do
          url = generate_url(symbol, interval, date_time)

          response = Net::HTTP.get(url)

          content = JSON.parse(response)

          if content.empty?
            break
          end

          puts "Worker #{i}: #{date_time} #{url}:#{content}"

          queue.push [symbol, date_time.to_date, interval, content]

          date_time = date_time - worker_count.day

          sleep(1)
        end
      end
    end

    workers.each(&:join)

    entries = []

    entries << queue.pop until queue.empty?

    entries = entries.map { |symbol, day, interval, content| { symbol: symbol, day: day, interval: interval, content: content } }

    BinanceFuturesKlines.insert_all(entries)
  end
end
