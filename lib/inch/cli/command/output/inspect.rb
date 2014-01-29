module Inch
  module CLI
    module Command
      module Output
        class Inspect < Base
          attr_reader :objects

          COLOR = :color198     # magenta-ish
          BG_COLOR = :color207  # magenta-ish
          LJUST = 20

          def initialize(options, objects)
            @options = options
            @objects = objects

            display_objects
          end

          private

          def display_objects
            objects.each do |o|
              print_object(o)
            end
          end

          def print_object(o)
            trace
            trace_header(o.path, COLOR, BG_COLOR)

            print_file_info(o)
            print_code_info(o)
            print_doc_info(o)
            print_namespace_info(o)
            print_roles_info(o)

            echo "Score (min: #{o.evaluation.min_score}, max: #{o.evaluation.max_score})".ljust(40) + "#{o.score.to_i}".rjust(5) + "#{o.priority.to_i}".rjust(4)
            echo
          end

          def print_file_info(o)
            o.files.each do |f|
              echo "-> #{f[0]}:#{f[1]}".color(COLOR)
            end
            echo separator
          end

          def print_code_info(o)
            if o.method?
              o.comment_and_abbrev_source.lines.each do |line|
                echo line.gsub(/\n$/m, '').dark
              end
              echo separator
            end
          end

          def print_roles_info(o)
            if o.roles.empty?
              echo "No roles assigned.".dark
            else
              o.roles.each do |role|
                name = role.class.to_s.split('::Role::').last
                if role.potential_score
                  score = "(#{role.potential_score.to_i})".rjust(5).yellow.dark
                else
                  value = role.score.to_i
                  score = value.abs.to_s.rjust(4)
                  if value < 0
                    score = ("-" + score).red
                  elsif value > 0
                    score = ("+" + score).green
                  else
                    score = " " + score
                  end
                end
                priority = role.priority.to_s.rjust(4)
                if role.priority == 0
                  priority = priority.dark
                end
                echo name.ljust(40) + score + priority
                if role.max_score
                  echo "  (set max score to #{role.max_score})"
                end
                if role.min_score
                  echo "  (set min score to #{role.min_score})"
                end
              end
            end
            echo separator
          end

          def print_doc_info(o)
            if o.nodoc?
              echo "The object was tagged not to documented.".yellow
            else
              echo "Docstring".ljust(LJUST) + "#{o.has_doc? ? 'Yes' : 'No text'}"
              if o.method?
                echo "Parameters:".ljust(LJUST) + "#{o.has_parameters? ? '' : 'No parameters'}"
                o.parameters.each do |p|
                  echo "  " + p.name.ljust(LJUST-2) + "#{p.mentioned? ? 'Mentioned' : 'No text'} / #{p.typed? ? 'Typed' : 'Not typed'} / #{p.described? ? 'Described' : 'Not described'}"
                end
                echo "Return type:".ljust(LJUST) + "#{o.return_mentioned? ? 'Defined' : 'Not defined'}"
              end
            end
            echo separator
          end

          def print_namespace_info(o)
            if o.namespace?
              echo "Children (height: #{o.height}):"
              o.children.each do |child|
                echo "+ " + child.path.color(COLOR)
              end
              echo separator
            end
          end

          def echo(msg = "")
            trace edged(COLOR, msg)
          end

          def separator
            "-".color(COLOR) * (CLI::COLUMNS - 2)
          end
        end
      end
    end
  end
end