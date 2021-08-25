module Simpler
  class Router
    class Route
      attr_reader :controller, :action

      def initialize(method, path, controller, action)
        @method = method
        @segments = path.split('/')
        @controller = controller
        @action = action
      end

      def match?(method, path_segments)
        return false if @method != method || path_segments.size != @segments.size

        @path_var = {}
        path_segments.each_with_index do |path_segment, index|
          if @segments[index].start_with?(':')
            @path_var[@segments[index]] = path_segment
          else
            return false if path_segment != @segments[index]
          end
        end
        true
      end

      attr_reader :path_var
    end
  end
end
