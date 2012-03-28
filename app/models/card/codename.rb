class Card::Codename < ActiveRecord::Base
  cattr_accessor :cache
  @@pre_cache = {}


  # helpers for migrations, remove when migrations are obsolete (1.9)
  @@code2name = nil
  RENAMES = {
      "AccountRequest"   => "InvitationRequest",
      "wagn_bot"         => "wagbot",
    }
  CODENAMES = %w{
      *account *accountable *account_link *add_help *alert *all *all_plu
      *attach *autoname *bcc *captcha *cc *comment *community *content *count
      *create *created *creator *css *default *delete *edit_help *editing
      *editor *email *foot *from *head *home *includer *inclusion *incoming
      *input *invite *last_edited *layout *link *linker *logo *member
      *missing_link *navbox *now *option *option_label *outgoing *plu_card
      *plu_part *pluss *read *recent *referred_to_by *refer_to *related
      *request *right *role *rstar *search *self *send *session *sidebar
      *signup *star *subject *table_of_content *tagged *thank *tiny_mce
      *title *to *type *watching *type_plu_right *update *user *version
      *watcher *when_created *when_last_edited

      anyone_signed_in anyone administrator anonymous wagn_bot

      Basic Cardtype Date File Html Image AccountRequest Number Phrase
      PlainText Pointer Role Search Set Setting Toggle User
    }

  class <<self
    def name2code(name)
      code = ?* == name[0] ? name[1..-1] : name
      code = RENAMES[code] if RENAMES[code]
      warn Rails.logger.warn("name2code: #{name}, #{code}, #{RENAMES[code]}"); code
    end
    def code2name(code)
      if @@code2name.nil?
        @@code2name = {}
        CODENAMES.each { |name| @@code2name[name2code name] = name }
      end
      @@code2name[code] || "Not code[#{code}]"
    end
    # end migration helpers

    def [](code)           card_attr(code, :name)      end
    def codename(key)      code_attr(key, :codename)   end
    def code2id(code) card_attr(code, :id)        end
    def exists?(key)       code_attr(key)              end
    def name_change(key)   exists?(key) && reset_cache end 
    def codes()            get_cache(:code2card).each_value      end
    def type_codes()
      get_cache(:code2card).values.find_all {|h| h[:type_id]==Card::CardtypeID}
    end

    # This is a read-only cached model.  Entries must be added on bootstrap,
    # or as an administrative action when installing or upgrading wagn and
    # its packs.
=begin Use AR.create
    def insert(card_id, codename)
      Card.connection.insert(%{
        insert into card_codenames (card_id, codename) values (#{card_id}, '#{codename}')
      })
      reset_cache
=end

    def code_attr(key, attr=nil?)
      #warn "miss #{key} #{card2code.map(&:inspect)*"\n"}" unless card2code.has_key?(key)
      card2code &&
      card2code.has_key?(key) && (attr ? card2code[key][attr] : true)
    end

    def card_attr(key, attr=nil?)
      #warn "miss card #{key} #{code2card.map(&:inspect)*"\n"}" unless code2card.has_key?(key)
      code2card &&
      code2card.has_key?(key) && (attr ? code2card[key][attr] : true)
    end

    def reset_cache()
      set_cache('card2code', nil)
      set_cache('code2card', nil)
    end

  private

    def card2code() get_cache('card2code') end
    def code2card() get_cache('code2card') end

    def get_cache(key)
      if self.cache
        return c if c = self.cache.read(key)
        load_cache
        return self.cache.read(key)
      else
        return c if c = @@pre_cache[key.to_s]
        load_cache
        @@pre_cache[key.to_s]
      end
    end

    def set_cache(key, v)
      key = key.to_s
      self.cache ? self.cache.write(key, v) : @@pre_cache[key] = v
    end

    def load_cache()
      card2code = {}; code2card = {}

      #Card.where()
      Card.connection.select_all(%{
          select c.id, c.name, c.key, cd.codename, c.type_id
           from cards c left outer join card_codenames cd on c.id = cd.card_id
          where c.trash is false
            and (c.type_id = 5 or cd.codename is not null)
        }).map(&:symbolize_keys).each do |h|
          h[:type_id], h[:id] = h[:type_id].to_i, h[:id].to_i
          h[:codename] ||= Card.respond_to?(:klassname_for) ?
                Card.klassname_for(h[:name]) : h[:name]
          code2card[h[:codename]] = card2code[h[:id]] = card2code[h[:key]] = h
        end

      #warn "setting caches: #{code2card.inspect}\n#{card2code.inspect}\n"
      set_cache 'code2card', code2card
      set_cache 'card2code', card2code
    rescue Exception => e
      warn(Rails.logger.info "Error loading codenames #{e.inspect}, #{e.backtrace*"\n"}")
    end
  end

  @@default_id = @@cardtype_id = nil
end
