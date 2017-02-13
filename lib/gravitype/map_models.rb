module Gravitype
  module MapModels
    class << self
      def map(models, &block)
        if ENV["TESTING"]
          models.map(&block)
        else
          parallel_map(models, block)
        end
      end

      private

      def parallel_map(models, block)
        require "parallel"
        require "ruby-progressbar"

        progressbar = ProgressBar.create(
          total: models.map(&:count).reduce(:+),
          format: "%E | %B | %p%%",
        )

        Parallel.singleton_class.prepend(ParallelExt)
        Parallel.map(models, progressbar: progressbar, &block)
      end

      module ParallelExt
        def map(source, options = {}, &block)
          progressbar = options.delete(:progressbar)
          finished = false
          outputs = []
          Thread.current[:progress_outputs] = outputs
          progress_thread = Thread.new do
            while !finished
              # Set a timeout so that we include any new entries in `outputs`
              if ready = IO.select(outputs, nil, nil, 1)
                ready.first.each do |io|
                  if io.eof?
                    outputs.delete(io)
                  else
                    if io.readchar == "."
                      progressbar.increment
                    else
                      raise "Unexpected output."
                    end
                  end
                end
              end
            end
            progressbar.finish
            outputs.each(&:close)
          end
          super(source, options, &block)
        ensure
          finished = true
          progress_thread.join
        end

        def worker(job_factory, options, &block)
          progress_read, progress_write = IO.pipe
          worker = super(job_factory, options) do |*args|
            begin
              before, $stdout = $stdout, progress_write
              result = block.call(*args)
            ensure
              $stdout = before
              result
            end
          end
          progress_write.close
          Thread.current[:progress_outputs] << progress_read
          worker
        end
      end
    end
  end
end
