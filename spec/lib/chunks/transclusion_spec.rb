require File.expand_path('../../spec_helper', File.dirname(__FILE__))
include ChunkSpecHelper

#FIXME: None of these work now, since transclusion is handled at the slot/cache
# level, but these cases should still be covered by tests


describe Chunk::Transclude, "transclude chunk tests" do
  include ActionView::Helpers::TextHelper

  it "should test_truth" do
    assert true
  end

=begin


 it "should test_circular_transclusion_should_be_invalid" do
    oak = Card.create! :name=>'Oak', :content=>'{{Quentin}}'
    qnt = Card.create! :name=>'Quentin', :content=>'{{Admin}}'
    adm = Card['Wagn Bot']
    adm.update_attributes :content => "{{Oak}}"
    #warn "circles: " + render(adm)
    assert_match /Circular transclusion/, adm.errors[:content]
  end

  it "should test_missing_transclude" do
    @a = Card.create :name=>'boo', :content=>"hey {{+there}}"
    assert_text_equal "hey Click to create boo+there", render(@a)
  end

  it "should test_absolute_transclude" do
    alpha = newcard 'Alpha', "Pooey"
    beta = newcard 'Beta', "{{Alpha}}"
    assert_text_equal "Pooey", render(beta)
  end

  it "should test_template_transclusion" do
     age, template = newcard('age'), Card['*template']
     specialtype = Card.create :typecode=>'Cardtype', :name=>'SpecialType'

     specialtype_template = specialtype.connect template, "{{#{SmartName.joint}age}}"
     assert_equal "{{#{SmartName.joint}age}}", render_test_card(specialtype_template)
     wooga = Card::SpecialType.create :name=>'Wooga'
     # card = card('Wooga')  #wtf?
     wooga_age = wooga.connect( age, "39" )
     assert_text_equal  span(wooga_age, "39"), render_test_card(wooga)
     assert_text_equal ['Wooga'], wooga_age.transcluders.plot(:name)
   end

  it "should test_relative_transclude" do
    alpha = newcard 'Alpha', "{{#{SmartName.joint}Beta}}"
    beta = newcard 'Beta'
    alpha_beta = alpha.connect beta, "Woot"
    assert_text_equal "Woot", render(alpha)
  end


  it "should test_shade_option" do
    alpha = newcard 'Alpha', "Pooey"
    beta = newcard 'Beta', "{{Alpha|shade:off}}"
    assert_text_equal "Pooey", render(newcard('Bee', "{{Alpha|shade:off}}" ))
    assert_text_equal "Pooey", render(newcard('Cee', "{{Alpha| shade: off }}" ))
    assert_text_equal "Pooey", render(newcard('Dee', "{{Alpha| shade:off }}" ))
    assert_text_equal "Pooey", render(newcard('Eee', "{{Alpha| shade:on }}" ))
  end


  # this tests container templating and transclusion syntax 'base:parent'
  it "should test_container_transclusion" do
    bob_city = Card.create! :name=>'bob+city', :content=> "Sparta"
    address_tmpl = Card.create! :name=>'address+*template', :content =>"{{+city|base:parent}}"
    bob_address = Card.create! :name=>'bob+address'
    #FIXME -- does not work retroactively if template is created later.

    assert_text_equal span(bob_city, "Sparta"), render(bob_address.reload), "include"
    assert_equal ["bob#{SmartName.joint}address"], bob_city.transcluders.plot(:name)
  end


  it "should test_nested_transclude" do
    alpha = newcard 'Alpha', "{{Beta}}"
    beta = newcard 'Beta', "{{Delta}}"
    delta = newcard 'Delta', "Booya"
    assert_text_equal "Booya", render( alpha )
  end


  private
  assert_text_equal(left, right, desc="")
    assert_equal strip_tags(left), strip_tags(right), desc
  end

  def span(card, text)
    %{<span class="transcluded" cardId="#{card.id}" inPopup="true">} +
      %{<span class="content transcludedContent" cardId="#{card.id}">#{text}</span></span>}
  end
=end

end
