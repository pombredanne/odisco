module J = Json
module C = Http_client

type error =
  | Unknown_stage of string
  | Protocol_parse_error of string * string
  | Protocol_error of string
  | Bad_msg of string * string * string
  | Unknown_msg of string * J.t
  | Unexpected_msg of string
  | Invalid_input of string
  | Input_failure of (C.url * C.error) list
  | Input_response_failure of C.url * int
  | Unsupported_input_scheme of int * string

let string_of_error = function
  | Unknown_stage s ->
      Printf.sprintf "unknown stage '%s'" s
  | Protocol_parse_error (i, es) ->
      Printf.sprintf "protocol parse error on input '%s': %s" i es
  | Protocol_error msg ->
      Printf.sprintf "protocol error: %s" msg
  | Bad_msg (m, s, e) ->
      Printf.sprintf "bad '%s' msg: %s (%s)" m s e
  | Unknown_msg (s, v) ->
      Printf.sprintf "unknown msg '%s' (\"%s\")" s (J.string_of_type v)
  | Unexpected_msg m ->
      Printf.sprintf "unexpected msg '%s'" m
  | Invalid_input s ->
      Printf.sprintf "invalid input '%s'" s
  | Input_failure el ->
      let b = Buffer.create 256 in
        Buffer.add_string b "failure retrieving input:";
        List.iter (fun (u, e) ->
                     Buffer.add_string b (Printf.sprintf " [%s: %s]" u (C.string_of_error e))
                  ) el;
        Buffer.contents b
  | Input_response_failure (u, sc) ->
      Printf.sprintf "error response retrieving input '%s': status %d" u sc
  | Unsupported_input_scheme (id, s) ->
      Printf.sprintf "unsupported input scheme (%d): %s" id s

exception Worker_failure of error
