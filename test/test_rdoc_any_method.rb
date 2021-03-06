require File.expand_path '../xref_test_case', __FILE__
require 'rdoc/code_objects'
require 'rdoc/generator/markup'

class RDocAnyMethodTest < XrefTestCase

  def test_aref
    m = RDoc::AnyMethod.new nil, 'method?'

    assert_equal 'method-i-method-3F', m.aref

    m.singleton = true

    assert_equal 'method-c-method-3F', m.aref
  end

  def test_arglists
    m = RDoc::AnyMethod.new nil, 'method'

    assert_nil m.arglists

    m.params = "(a, b)"
    m.block_params = "c, d"

    assert_equal "method(a, b) { |c, d| ... }", m.arglists

    call_seq = <<-SEQ
method(a) { |c| ... }
method(a, b) { |c, d| ... }
    SEQ

    m.call_seq = call_seq.dup

    assert_equal call_seq, m.arglists
  end

  def test_c_function
    @c1_m.c_function = 'my_c1_m'

    assert_equal 'my_c1_m', @c1_m.c_function
  end

  def test_full_name
    assert_equal 'C1::m', @c1.method_list.first.full_name
  end

  def test_markup_code
    tokens = [
      RDoc::RubyToken::TkCONSTANT. new(0, 0, 0, 'CONSTANT'),
      RDoc::RubyToken::TkDEF.       new(0, 0, 0, 'KW'),
      RDoc::RubyToken::TkIVAR.     new(0, 0, 0, 'IVAR'),
      RDoc::RubyToken::TkOp.       new(0, 0, 0, 'Op'),
      RDoc::RubyToken::TkId.       new(0, 0, 0, 'Id'),
      RDoc::RubyToken::TkNode.     new(0, 0, 0, 'Node'),
      RDoc::RubyToken::TkCOMMENT.  new(0, 0, 0, 'COMMENT'),
      RDoc::RubyToken::TkREGEXP.   new(0, 0, 0, 'REGEXP'),
      RDoc::RubyToken::TkSTRING.   new(0, 0, 0, 'STRING'),
      RDoc::RubyToken::TkVal.      new(0, 0, 0, 'Val'),
      RDoc::RubyToken::TkBACKSLASH.new(0, 0, 0, '\\'),
    ]

    @c2_a.collect_tokens
    @c2_a.add_tokens(*tokens)

    expected = [
      '<span class="ruby-constant">CONSTANT</span>',
      '<span class="ruby-keyword">KW</span>',
      '<span class="ruby-ivar">IVAR</span>',
      '<span class="ruby-operator">Op</span>',
      '<span class="ruby-identifier">Id</span>',
      '<span class="ruby-node">Node</span>',
      '<span class="ruby-comment">COMMENT</span>',
      '<span class="ruby-regexp">REGEXP</span>',
      '<span class="ruby-string">STRING</span>',
      '<span class="ruby-value">Val</span>',
      '\\'
    ].join

    assert_equal expected, @c2_a.markup_code
  end

  def test_markup_code_empty
    assert_equal '', @c2_a.markup_code
  end

  def test_marshal_load
    instance_method = Marshal.load Marshal.dump(@c1.method_list.last)

    assert_equal 'C1#m',  instance_method.full_name
    assert_equal 'C1',    instance_method.parent_name
    assert_equal '(foo)', instance_method.params

    aliased_method = Marshal.load Marshal.dump(@c2.method_list.last)

    assert_equal 'C2#a',  aliased_method.full_name
    assert_equal 'C2',    aliased_method.parent_name
    assert_equal '()',    aliased_method.params

    class_method = Marshal.load Marshal.dump(@c1.method_list.first)

    assert_equal 'C1::m', class_method.full_name
    assert_equal 'C1',    class_method.parent_name
    assert_equal '()',    class_method.params
  end

  def test_name
    m = RDoc::AnyMethod.new nil, nil

    assert_nil m.name
  end

  def test_param_list_block_params
    m = RDoc::AnyMethod.new nil, 'method'
    m.parent = @c1

    m.block_params = 'c, d'

    assert_equal %w[c d], m.param_list
  end

  def test_param_list_call_seq
    m = RDoc::AnyMethod.new nil, 'method'
    m.parent = @c1

    call_seq = <<-SEQ
method(a) { |c| ... }
method(a, b) { |c, d| ... }
    SEQ

    m.call_seq = call_seq

    assert_equal %w[a b c d], m.param_list
  end

  def test_param_list_params
    m = RDoc::AnyMethod.new nil, 'method'
    m.parent = @c1

    m.params = '(a, b)'

    assert_equal %w[a b], m.param_list
  end

  def test_param_list_params_block_params
    m = RDoc::AnyMethod.new nil, 'method'
    m.parent = @c1

    m.params = '(a, b)'
    m.block_params = 'c, d'

    assert_equal %w[a b c d], m.param_list
  end

  def test_param_seq
    m = RDoc::AnyMethod.new nil, 'method'
    m.parent = @c1
    m.params = 'a'

    assert_equal '(a)', m.param_seq

    m.params = '(a)'

    assert_equal '(a)', m.param_seq

    m.params = "(a,\n  b)"

    assert_equal '(a, b)', m.param_seq

    m.block_params = "c,\n  d"

    assert_equal '(a, b) { |c, d| ... }', m.param_seq
  end

  def test_param_seq_call_seq
    m = RDoc::AnyMethod.new nil, 'method'
    m.parent = @c1

    call_seq = <<-SEQ
method(a) { |c| ... }
method(a, b) { |c, d| ... }
    SEQ

    m.call_seq = call_seq

    assert_equal '(a, b) { |c, d| }', m.param_seq

  end

  def test_parent_name
    assert_equal 'C1', @c1.method_list.first.parent_name
    assert_equal 'C1', @c1.method_list.last.parent_name
  end

end

