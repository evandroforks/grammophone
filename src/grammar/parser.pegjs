{
  function extractOptional(optional, index) {
    return optional ? optional[index] : null;
  }

  function extractList(list, index) {
    return list.map(element => element[index]);
  }

  function buildList(head, tail, index) {
    return [head].concat(extractList(tail, index));
  }
}

Grammar
  = _ rules:(Rule _)* {
      return {
        type: "grammar",
        rules: extractList(rules, 0),
        location: location()
      };
    }

Rule
  = name:Head _ choice:ChoiceExpression (_ RuleSeparator)* {
      return {
        type: "rule",
        name: name,
        choice: choice,
        location: location()
      };
    }

ChoiceExpression
  = head:SequenceExpression tail:(_ ChoiceSeparator _ SequenceExpression)* {
      return {
        type: "choice",
        alternatives: buildList(head, tail, 3),
        location: location()
      };
    }

SequenceExpression
  = head:PrimaryExpression tail:(_ PrimaryExpression)* {
      return {
        type: "sequence",
        elements: buildList(head, tail, 1),
        location: location()
      };
    }
  / &(Head / ChoiceSeparator / RuleSeparator / !.) {
      return {
        type: "sequence",
        elements: [],
        location: location()
      };
    }

PrimaryExpression
  = expr:(SymbolExpression / EpsilonExpression) !(_ RuleDefinition) {
  	  return expr;
    }

SymbolExpression
  = name:Symbol {
      return {
        type: "symbol",
        name: name,
        location: location()
      };
    }

EpsilonExpression
  = EpsilonLiteral {
      return {
      	type: "epsilon",
        location: location()
       };
    }

Head
  = name:Symbol _ RuleDefinition {
      return name;
    }

Symbol
  = Identifier
  / String

EpsilonLiteral
  = "#epsilon"

Identifier
  = IdentifierStartCharacter (IdentifierCharacter / "-" &IdentifierCharacter)* IdentifierCharacter* {
      return text();
    }

// Based on "N1518: Recommendations for extended identifier characters for C and C++".

IdentifierStartCharacter "identifier start character"
  = [A-Z_a-z\xA8\xAA\xAD\xAF\xB2-\xB5\xB7-\xBA\xBC-\xBE\xC0-\xD6\xD8-\xF6\xF8-\u02FF\u0370-\u167F\u1681-\u180D\u180F-\u1DBF\u1E00-\u1FFF\u200B-\u200D\u202A-\u202E\u203F\u2040\u2054\u2060-\u20CF\u2100-\u218F\u2460-\u24FF\u2776-\u2793\u2C00-\u2DFF\u2E80-\u2FFF\u3004-\u3007\u3021-\u302F\u3031-\uD7FF\uF900-\uFD3D\uFD40-\uFDCF\uFDF0-\uFE1F\uFE30-\uFE44\uFE47-\uFFFD]
  / [\uD800-\uD83E\uD840-\uD87E\uD880-\uD8BE\uD8C0-\uD8FE\uD900-\uD93E\uD940-\uD97E\uD980-\uD9BE\uD9C0-\uD9FE\uDA00-\uDA3E\uDA40-\uDA7E\uDA80-\uDABE\uDAC0-\uDAFE\uDB00-\uDB3E\uDB40-\uDB7E][\uDC00-\uDFFF]
  / [\uD83F\uD87F\uD8BF\uD8FF\uD93F\uD97F\uD9BF\uD9FF\uDA3F\uDA7F\uDABF\uDAFF\uDB3F\uDB7F][\uDC00-\uDFFD]

IdentifierCharacter "identifier character"
  = [0-9A-Z_a-z\xA8\xAA\xAD\xAF\xB2-\xB5\xB7-\xBA\xBC-\xBE\xC0-\xD6\xD8-\xF6\xF8-\u167F\u1681-\u180D\u180F-\u1FFF\u200B-\u200D\u202A-\u202E\u203F\u2040\u2054\u2060-\u218F\u2460-\u24FF\u2776-\u2793\u2C00-\u2DFF\u2E80-\u2FFF\u3004-\u3007\u3021-\u302F\u3031-\uD7FF\uF900-\uFD3D\uFD40-\uFDCF\uFDF0-\uFE44\uFE47-\uFFFD]
  / [\uD800-\uD83E\uD840-\uD87E\uD880-\uD8BE\uD8C0-\uD8FE\uD900-\uD93E\uD940-\uD97E\uD980-\uD9BE\uD9C0-\uD9FE\uDA00-\uDA3E\uDA40-\uDA7E\uDA80-\uDABE\uDAC0-\uDAFE\uDB00-\uDB3E\uDB40-\uDB7E][\uDC00-\uDFFF]
  / [\uD83F\uD87F\uD8BF\uD8FF\uD93F\uD97F\uD9BF\uD9FF\uDA3F\uDA7F\uDABF\uDAFF\uDB3F\uDB7F][\uDC00-\uDFFD]

String "string"
  = '"' chars:DoubleStringCharacter* '"' {
      return chars.join("");
    }
  / "'" chars:SingleStringCharacter* "'" {
      return chars.join("");
    }

DoubleStringCharacter
  = !('"' / "\\") . { return text(); }
  / "\\" escape:EscapeCharacter { return escape; }

SingleStringCharacter
  = !("'" / "\\") . { return text(); }
  / "\\" escape:EscapeCharacter { return escape; }

EscapeCharacter
  = "'"
  / '"'
  / "\\"

RuleDefinition
  = "->"
  / ":"

ChoiceSeparator
  = "|"

RuleSeparator
  = ";"
  / "."

_ "whitespace"
  = (Whitespace / LineTerminatorSequence / Comment)*

Whitespace "whitespace"
  = "\t"
  / "\v"
  / "\f"
  / " "
  / "\u00A0"
  / "\uFEFF"
  / Zs

LineTerminator
  = [\n\r\u2028\u2029]

LineTerminatorSequence "end of line"
  = "\n"
  / "\r\n"
  / "\r"
  / "\u2028"
  / "\u2029"

Comment "comment"
  = MultiLineComment
  / SingleLineComment

MultiLineComment
  = "/*" (!"*/" .)* "*/"

MultiLineCommentNoLineTerminator
  = "/*" (!("*/" / LineTerminator) .)* "*/"

SingleLineComment
  = "//" (!LineTerminator .)*

// Separator, Space
Zs = [\u0020\u00A0\u1680\u2000-\u200A\u202F\u205F\u3000]
