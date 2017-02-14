module Gravitype
  class Introspection
    class Batch
      attr_reader :criteria

      def initialize(criteria)
        @criteria = criteria
      end

      def model
        @criteria.all.klass
      end

      def size
        model.collection.count(@criteria.selector, @criteria.options)
      end

      def schema
        @schema ||= Schema.new(@criteria).introspect
      end

      def data
        @data ||= Data.new(@criteria).introspect
      end

      def merged
        {
          merged: Introspection.merge(schema[:mongoid_schema], *data.values)
        }
      end

      def introspect
        schema.merge(data).merge(merged)
      end
    end

    class Batch
      class << self
        def create(models, batch_size = 1000)
          [].tap do |batches|
            models.each do |model|
              0.step(model.count, batch_size) do |offset|
                batches << Batch.new(model.skip(offset).limit(batch_size))
              end
            end
          end
        end

        def merge(*batch_introspections)
          batch_introspections.inject({}) do |result, batch_introspection|
            batch_introspection.each do |type, fields|
              result[type] = Introspection.merge(result[type] || [], fields)
            end
            result
          end
        end

        def map(models, &block)
          if ENV["TESTING"]
            models.map { |model| Batch.new(model) }.map(&block)
          else
            parallel_map(create(models), block)
          end
        end

        private

        def parallel_map(batches, block)
          require "parallel"
          require "ruby-progressbar"

          progressbar = ProgressBar.create(
            total: batches.inject(0) { |sum, batch| sum + batch.size },
            format: "%E | %B | %P%% (%c/%C)",
          )

          Parallel.singleton_class.prepend(ParallelExt)
          Parallel.map(batches, progressbar: progressbar, &block)
        end

        module ParallelExt
          def map(source, options = {}, &block)
            progressbar = options.delete(:progressbar)
            run = true
            outputs = []
            Thread.current[:progress_outputs] = outputs
            progress_thread = Thread.new do
              while run
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
              outputs.each(&:close)
            end
            super(source, options, &block)
          ensure
            run = false
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
end
