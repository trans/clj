require "json"

module Jargon
  # Outcome of parsing arguments. Carries the parsed `data`, any validation
  # `errors`, and the resolved `subcommand`, plus flags describing meta-requests
  # (help, shell completion) that `run` acts on automatically. A pending
  # help/completion request is not a validation outcome — check
  # `help_requested?`/`completion_requested?` before treating `errors` as final.
  class Result
    getter data : JSON::Any
    getter errors : Array(String)

    # Resolved subcommand name, space-separated for nested commands; nil for a
    # flat CLI or when no subcommand matched.
    getter subcommand : String?
    getter? help_requested : Bool

    # Which subcommand's help was requested (nil = top-level help).
    getter help_subcommand : String?

    # The shell passed to `--completions` (e.g. "bash"), or nil if not requested.
    getter completion_shell : String?

    def initialize(@data : JSON::Any, @errors : Array(String) = [] of String, @subcommand : String? = nil,
                   @help_requested : Bool = false, @help_subcommand : String? = nil, @completion_shell : String? = nil)
    end

    def initialize(data : Hash(String, JSON::Any), @errors : Array(String) = [] of String, @subcommand : String? = nil,
                   @help_requested : Bool = false, @help_subcommand : String? = nil, @completion_shell : String? = nil)
      @data = JSON::Any.new(data)
    end

    # True when `--completions <shell>` was requested.
    def completion_requested? : Bool
      !@completion_shell.nil?
    end

    # True when parsing produced no validation errors. Note a help/completion
    # request is also error-free, so guard those separately when it matters.
    def valid? : Bool
      errors.empty?
    end

    # Alias for `help_requested?`.
    def help? : Bool
      @help_requested
    end

    # The parsed data as a compact JSON string.
    def to_json : String
      data.to_json
    end

    # The parsed data as an indented JSON string.
    def to_pretty_json : String
      data.to_pretty_json
    end

    # Fetch a top-level value, raising `KeyError` if absent.
    def [](key : String) : JSON::Any
      data[key]
    end

    # Fetch a top-level value, or nil if absent.
    def []?(key : String) : JSON::Any?
      data[key]?
    end
  end
end
