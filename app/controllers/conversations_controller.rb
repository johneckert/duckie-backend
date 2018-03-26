require 'rest-client'

class ConversationsController < ApplicationController
  before_action :find_conversation

  def index
    conversations = Conversation.all
    render json: conversations, status: 200
  end

  def show
    render json: @conversation, status: 200
  end

  def create
    @conversation = Conversation.create(user_id: params[:user_id], transcript: params[:transcript])
    render json: @conversation, status: 201
  end

def update
  @conversation = Conversation.find(params[:id])
  @conversation.update(conversation_params)
  #organize for watson
  parameters = {
    'text' => @conversation.transcript,
    'features' => {
      'concepts' => {
        'limit' => 10
      },
      'keywords' =>
      {
        'emotion' => false,
        'sentiment' => false,
        'limit' => 10
      }
    }
  }.to_json

  #send transcript to watson and get keyword respons
  response = RestClient::Request.execute method: :post, url: "https://gateway.watsonplatform.net/natural-language-understanding/api/v1/analyze?version=2017-02-27", user: ENV["watson_username"], password: ENV["watson_password"], headers: {'Content-Type': "application/json"}, payload: parameters

  #set keyword tolerance
  tolerance = 1
  #generate keyword objects and att to conversation
  converted_response = JSON.parse(response)

  keyword_array = create_keywords_from_keywords(converted_response, tolerance, computer_words)
  concept_array = create_keywords_from_concepts(converted_response, tolerance, computer_words)

  dirty_array = keyword_array.concat(concept_array)
  raw_array = dirty_array.uniq {|keyword| keyword[:word]}
  raw_array.sort! {|a,b| b.relevance <=> a.relevance }.first(5)

  raw_array.each do |keyword|
    keyword[:word] = keyword[:word].titleize
    current_convo_keywords = @conversation.keywords
    matching = @conversation.keywords.select{|kw| kw.word.titleize == keyword[:word]}
    if matching.length == 0
      @conversation.keywords << keyword
    end
  end



  puts @conversation.keywords
  render json: @conversation.keywords, status: 201
end


  private

  def find_conversation
    @conversation = Conversation.find_by(id: conversation_params[:id])
  end

  def conversation_params
    params.require(:conversation).permit(:user_id, :transcript, :id, :audio, :created_at, :updated_at)
  end

  #helpers for creating keyword instances
  def create_keywords_from_keywords(response_hash, tolerance, rel_word_hash)
    keyword_array = []
    response_hash['keywords'].map do |keyword_obj|
      if rel_word_hash.include?(keyword_obj['text'].downcase)
        keyword_obj['relevance'] = keyword_obj['relevance'] + 1
      end
      new_word = Keyword.create_with(relevance: keyword_obj['relevance']).find_or_create_by(word: "#{keyword_obj['text']}")
      if new_word[:relevance] >= tolerance
        keyword_array << new_word
      end
    end
    keyword_array
  end

  def create_keywords_from_concepts(response_hash, tolerance, rel_word_hash)
    keyword_array = []
    response_hash['concepts'].map do |concept_obj|
      if rel_word_hash.include?(concept_obj['text'].downcase)
        concept_obj['relevance'] = concept_obj['relevance'] + 1
      end
      new_word = Keyword.create_with(relevance: concept_obj['relevance']).find_or_create_by(word: "#{concept_obj['text']}")
      if new_word[:relevance] >= tolerance
        keyword_array << new_word
      end
    end
    keyword_array
  end



  def computer_words
    ["tml", "ide", "net", "nbsp", "machine language", "ascii", "1gl", "program", "data type", "number", "variables", "algorithm", "abend", "absolute address", "absolute coding", "access violation", "acm", "action statement", "actionscript", "activex", "ada", "add", "ado", "advanced scsi programming interface", "aggregation", "agile development methods", "agile manifesto", "alert", "algol", "algorithm", "altair basic", "ambient occlusion", "aop", "api", "applet", "argument", "arithmetic operator", "array", "array of pointers", "ascii", "asp", "aspi", "assembler", "assembly", "associative operation", "autohotkey", "automata-based programming", "automated unit testing", "automation", "\nbooleanbabel", "backend", "back-face culling", "background thread", "backpropagation neural network", "base address", "batch file", "batch job", "bcpl", "bean", "beanshell", "binary search", "bind", "bit shift", "bitwise operators", "block", "block-level element", "bom", "bool", "boolean", "boolean data type", "bracket", "branch", "brooks", "bug", "bug tracking", "bugfairy", "build computer", "bytecode", "\ncompiled programming language", "c", "c sharp", "c++", "c#", "camel book", "camelcase", "captured variable", "cc", "chaos model", "char", "character code", "character encoding", "character set", "chaos model", "circuit satisfiability problem", "class", "class", "classpath", "clojure", "clos", "closure", "clr", "cobol", "cocoa", "cocoa touch", "code", "code refactoring", "codepage", "coffeescript", "command language", "comment", "common business oriented language", "common gateway interface", "compilation", "compile", "compiler", "complementarity", "compute", "computer science", "commutative operation", "concat", "concatenation", "concurrency", "conditional expression", "conditional statement", "constant", "constructor", "constructor chaining", "content migration", "control flow", "cpan", "cpl", "crapplet", "cs", "csat", "css", "css compressor", "css editor", "curly bracket", "curry", "cvs", "cygwin", "\nsparse matrixd","dongle", "darkbasic", "dart", "dataflow programming", "data-flow analysis", "data flow diagram", "data source", "data type", "datalog", "dde", "dead code", "debug", "debugger", "debugging", "declaration", "declarative programming", "declare", "decompiler", "decrement", "deductive database", "delimiter", "dense matrix", "dereference operator", "dependent variable", "developer", "dhtml", "die", "diff", "direct address", "discrete optimization", "dissembler", "div", "django", "dml", "do", "dom", "dragon book", "dribbleware", "dump", "dword", "dylan programming language", "dynamic dump", "exececlipse", "ecmascript", "eight queens problem", "element", "ellipsis", "else", "else if", "elsif", "embedded java", "encapsulation", "encode", "endian", "endless loop", "eof", "epoch", "eq", "equal", "error", "errorlevel", "esac", "escape", "escape character", "escape sequence", "eval", "event", "event handler", "event listener", "event-driven programming", "exec", "exception", "exception handling", "exists", "exponent", "exponential backoff", "expression", "foreach", "f programming language", "f#", "false", "fifth generation language", "first generation language", "first-class object", "flag", "flat file", "floating-point", "for", "foreach", "forth", "forth generation language", "fortran", "framework", "front end", "full stack developer", "function", "functional programming", "fuzz testing", "\ngame of life", "gang of four", "garbage collection", "gaussian pyramid", "gcc", "ge", "general-purpose language", "generation language", "genetic programming", "gigo", "github", "glitch", "glob", "glue code", "go language", "goto", "gpl", "gt", "gtk", "gw basic", "haskell", "hal", "hard code", "hash", "haskell", "heap", "hello world", "heuristic evaluation", "hex editor", "hdml", "hiew", "high-level language", "html", "hungarian notation", "hwclock", "hypertext markup language", "iteration", "ide", "if else", "if statement", "immutable object", "imperative programming", "implicit parallelism", "increment", "indirection operator", "inherent error", "inheritance", "inline", "input/output statement", "instance", "instantiation", "instructions", "int", "integer", "integrated development environment", "intellij idea", "intermediate language", "interpreted", "interpreter", "invalid", "ioccc", "ipc", "isapi", "iteration", "javascript", "js", "logojava", "java champion", "java ee", "java me", "java native language", "java reserved words", "javabean", "javac", "javafx", "javascript", "javascriptcore", "javax", "jbuilder", "java", "jcl", "jdbc", "jdk", "jil", "jit", "jhtml", "jni", "jre", "jscript", "json", "jsp", "jsr", "julia", "jvm", "karel", "kit", "kludge", "kluge", "looplabel", "lambda calculus", "language", "language processor", "lexical analysis", "lexicon", "linker", "lisp", "live script", "literal", "llvm", "local optimum", "logic programming", "logical operation", "logo", "lookup table", "loony bin", "loop", "loophole", "loosely typed language", "low-level language", "library", "lt", "lua", "lut", "matlab logomachine language", "matlab", "magic quotes", "map", "markup language", "math", "matlab", "mbean", "memoization", "mercurial", "meta-character", "metaclass", "metalanguage", "method", "method overloading", "metro", "middleware", "mod", "module", "modulo", "monkey testing", "monkey patch", "monte carlo method", "msdn", "msvc", "multi-pass compiler", "mumps", "mutex", "microsoft", ".netnan", "ne", ".net", "native compiler", "native language", "natural language", "nbsp", "nda", "nested function", "nested loop join", "newline", "nil pointer", "nim", "node.js", "node js", "nodelist", "noncontiguous data structure", "non-disclosure agreement", "nonexecutable statement", "no-operation instructions", "null", "null character", "null pointer", "operatorobject code", "object file", "object module", "object-oriented programming", "objective-c", "obfuscated code", "ocaml", "octave", "odbc", "oop", "one-pass compiler", "opcode", "open database connectivity", "opengl polygon", "operand", "operator", "operator associatively", "operator precedence", "or operator", "overflow error", "overload", "practical extraction reporting language", "p-code", "package", "parenthesis", "parse", "pascal", "pascal case", "pastebin", "pdl", "pear", "perl", "persistent memory", "personaljava", "php", "phrase tag", "pick", "pickling", "picojava", "pipe", "pixel shader", "pod", "pointer", "polymorphism", "pop", "positional parameter", "private", "procedural language", "procedure", "process", "program", "program generator", "program listing", "programmable", "programmer", "programming", "programming in logic", "programming language", "programming tools", "prolog", "pseudocode", "pseudolanguage", "pseudo-operation", "pseudo-random", "public", "purebasic", "push", "python", "python pickling", "pythonic", "qi", "qt", "quick-and-dirty", "return statement", "r", "race condition", "racket", "rad", "random", "random seed", "rcs", "rdf", "react", "react native", "real number", "recursion", "recursive", "regex", "regular expression", "reia", "relational algebra", "religion of chi", "rem", "remark", "repeat counter", "repl", "reserved character", "redux", "reserved word", "resource description framework", "return address", "return statement", "reverse engineering", "revision control", "rom basic", "routine", "routing algorithm", "rpg", "ruby", "run time", "rust", "spaghetti codes-expression", "safe font", "sandbox", "scala", "scanf", "schema matching", "scheme", "scratch", "sdk", "second generation language", "section", "security descriptor definition language", "seed", "segfault", "separator", "sequence", "server-side", "server-side scripting", "servlet", "sgml", "shebang", "shell scripts", "shift", "short-circuit operator", "signedness", "simulated annealing", "single step", "smalltalk", "smil", "snippet", "soap", "socket", "soft", "software development phases", "software development process", "software engineering", "software library", "software life cycle", "source", "source code", "source computer", "source data", "sourceforge", "spaghetti code", "sparse matrix", "sparsity", "special purpose language", "spl", "spooling", "sql", "stack", "stack pointer", "standard attribute", "statement", "stdin", "strong typed language", "stubroutine", "stylesheet", "subprogram", "subroutine", "subscript", "substring", "subversion", "superclass", "switch statement", "syntactic sugar", "syntax error", "system development", "systems engineer", "systems programming language", "tupletail recursion", "tcl", "tcl/tk", "ternary operator", "theoretical computer science", "third-generation language", "thread", "thunk", "tk", "token", "transcompiler", "true", "basic", "trunk", "tuple", "turbo pascal", "turing completeness", "unary operator", "undefined", "undefined variable", "underflow", "unescape", "unit test", "unshift", "value", "var", "variable", "vb", "vector", "vhdl", "vim", "visual basic", "visual studio", "void", "waterfall model", "web development", "webgl", "while", "whole number", "wml", "workspace", "xml", "xna", "xor operator", "xoxo", "xsl", "xslt", "y combinator", "yaml", "z-buffering", "zombie"]
  end

end
