'use strict';

const assert = require('assert');
const Grammar = require('../src/grammar/index');

function assertProductions(expected, spec) {
  let result = Grammar.parse(spec);
  if (result.error) {
    throw result.error;
  }
  assert.deepEqual(expected, result.grammar.productions);
}

function assertParseError(spec) {
  let result = Grammar.parse(spec);
  assert.ok(result.error, 'Expected parse error');
}

describe('Parser', function() {
  it('should parse simple grammars', function() {
    assertProductions([['a', 'b']], 'a -> b');
    assertProductions([['a', 'b', 'c']], 'a -> b c');
    assertProductions([['a', 'b'], ['a', 'c']], 'a -> b | c');
    assertProductions([['a', 'b'], ['c', 'd'], ['c', 'e']], 'a -> b\n c -> d | e');
  });

  it('should parse empty productions', function() {
    assertProductions([['a'], ['b']], 'a -> b ->');
    assertProductions([['a', 'b'], ['c']], 'a -> b c ->');
    assertProductions([['a'], ['b', 'c']], 'a -> b -> c');
    assertProductions([['a'], ['b'], ['c']], 'a -> b -> c ->');
    assertProductions([['a', 'b'], ['c', 'd']], 'a -> b c -> d');
    assertProductions([['a', 'b', 'c'], ['d', 'e']], 'a -> b c d -> e');
    assertProductions([['a'], ['a']], 'a -> |');
    assertProductions([['a', 'b'], ['a']], 'a -> b |');
    assertProductions([['a'], ['a', 'b']], 'a -> | b');
    assertProductions([['a'], ['a'], ['b']], 'a -> | b ->');
    assertProductions([['a', 'b'], ['a'], ['c']], 'a -> b | c ->');
    assertProductions([['a', 'b'], ['a', 'c'], ['d']], 'a -> b | c d ->');
  });

  it('should accept semicolon and period as rule separators', function() {
    assertProductions([['a'], ['b']], 'a -> . b -> .');
    assertProductions([['a'], ['b']], 'a -> ; b -> ;');
    assertProductions([['a', 'b'], ['c', 'd']], 'a -> b; c -> d;');
  });

  it('should accept arrow and colon for defining a rule', function() {
    assertProductions([['a', 'b'], ['c', 'd']], 'a -> b; c -> d');
    assertProductions([['a', 'b'], ['c', 'd']], 'a : b; c : d');
  });

  it('should allow uppercase and lowercase letters and underscores in symbols', function() {
    assertProductions([['A', '_b']], 'A -> _b');
  });

  it('should allow dashes and numbers within symbols', function() {
    assertProductions([['a-b', 'b1']], 'a-b -> b1');
    assertProductions([['a', 'b']], 'a->b');
  });

  it('should allow non-ascii symbols', function() {
    assertProductions([['A', 'α']], 'A -> α');
    assertProductions([['🧀', '🥛'], ['🥛', '🐮']], '🧀 -> 🥛; 🥛 -> 🐮');
    assertProductions([['hello', '你好'], ['hello', 'שלום'], ['hello', 'வணக்கம்'], ['hello', 'Γειά'], ['hello', 'привет']], 'hello -> 你好 | שלום | வணக்கம் | Γειά | привет');
  });

  it('should allow symbols to be written as strings', function() {
    assertProductions([['a', '->']], `a -> "->"`);
    assertProductions([['a', '->']], `a -> '->'`);
    assertProductions([['a', '\'']], `a -> '\\''`);
    assertProductions([['a', '\"']], `a -> "\\""`);
  });

  it('should parse rules containing end of line characters', function() {
    assertProductions([['a', 'b'], ['a', 'c']], 'a -> b |\nc;');
    assertProductions([['a', 'b'], ['a', 'c']], 'a ->\nb |\nc;');
    assertProductions([['a', 'b'], ['a', 'c']], 'a\n->\nb\n|\nc;');
  });

  it('should parse the literal epsilon symbol', function() {
    assertProductions([['a']], 'a -> #epsilon;');
    assertProductions([['a', 'b']], 'a -> #epsilon b #epsilon;');
  });

  it('should parse empty expressions', function() {
    assertProductions([['a'], ['b', 'c']], 'a -> ; b -> c;');
    assertProductions([['a', 'b'], ['a']], 'a -> b | ;');
    assertProductions([['a'], ['a', 'b']], 'a -> | b;');
    assertProductions([['a'], ['a']], 'a -> | ;');
  });

  it('should parse end of line as the end of a rule', function() {
    assertProductions([['a', 'b'], ['c', 'd']], 'a -> b\nc -> d');
    assertProductions([['a', 'b'], ['c', 'd'], ['c', 'e']], 'a ->\nb\nc -> d |\ne');
    assertProductions([['a'], ['a'], ['a', 'c', 'd'], ['e', 'f']], 'a -> |\n|\nc d\ne -> f');
    assertProductions([['a'], ['c', 'd']], 'a -> #epsilon\nc -> d');
    assertProductions([['a'], ['a'], ['c', 'd']], 'a -> | #epsilon\nc -> d');
  });

  it('should ignore single-line comments', function() {
    assertProductions([['a', 'b']], '// a -> a\na -> b');
    assertProductions([['a', 'b']], 'a -> b // 123');
  });

  it('should ignore multiple-line comments', function() {
    assertProductions([['a', 'b']], '/* a -> a\na -> c*/a -> /* ? */\nb');
  });

  it('should parse an empty grammar', function() {
    assertProductions([], '');
    assertProductions([], '// empty\n');
  });

  it('should throw for parse errors', function() {
    assertParseError('a -> b; c');
    assertParseError('a b -> c');
    assertParseError('-> a');
    assertParseError('a');
    assertParseError('a.y -> a.');
    assertParseError('a -> b.z .');
  });
});
