require "test_helper"

class Aeno::ContactsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @contact = Aeno::Contact.create!(name: "John Doe", email: "john@example.com")
  end

  test "should create contact with nested relationships and phones" do
    assert_difference("Aeno::Contact.count", 2) do # Main contact + 1 related contact
      assert_difference("Aeno::ContactRelationship.count", 1) do
        assert_difference("Aeno::Phone.count", 2) do # 1 for main, 1 for related
          post contacts_url, params: {
            contact: {
              name: "Jane Smith",
              email: "jane@example.com",
              phones_attributes: {
                "0" => { number: "555-0001", phone_type: "mobile" }
              },
              contact_relationships_attributes: {
                "0" => {
                  relation_type: "sibling",
                  related_contact_attributes: {
                    name: "Bob Smith",
                    email: "bob@example.com",
                    phones_attributes: {
                      "0" => { number: "555-0002", phone_type: "work" }
                    }
                  }
                }
              }
            }
          }
        end
      end
    end

    assert_response :redirect
    contact = Aeno::Contact.find_by(name: "Jane Smith")
    assert_equal 1, contact.phones.count
    assert_equal "555-0001", contact.phones.first.number
    assert_equal 1, contact.contact_relationships.count

    related = contact.contact_relationships.first.related_contact
    assert_equal "Bob Smith", related.name
    assert_equal 1, related.phones.count
    assert_equal "555-0002", related.phones.first.number
  end

  test "should update contact with nested relationships" do
    relationship = @contact.contact_relationships.create!(
      relation_type: "sibling",
      related_contact: Aeno::Contact.create!(name: "Alice", email: "alice@example.com")
    )
    phone = relationship.related_contact.phones.create!(number: "555-0003", phone_type: "mobile")

    patch contact_url(@contact), params: {
      contact: {
        name: "John Updated",
        contact_relationships_attributes: {
          "0" => {
            id: relationship.id,
            relation_type: "friend",
            related_contact_attributes: {
              id: relationship.related_contact.id,
              name: "Alice Updated",
              phones_attributes: {
                "0" => {
                  id: phone.id,
                  number: "555-UPDATED"
                }
              }
            }
          }
        }
      }
    }

    assert_response :redirect
    @contact.reload
    assert_equal "John Updated", @contact.name
    assert_equal "friend", relationship.reload.relation_type
    assert_equal "Alice Updated", relationship.related_contact.name
    assert_equal "555-UPDATED", phone.reload.number
  end

  test "should destroy nested relationships with _destroy flag" do
    relationship = @contact.contact_relationships.create!(
      relation_type: "sibling",
      related_contact: Aeno::Contact.create!(name: "ToDelete", email: "delete@example.com")
    )

    assert_difference("Aeno::ContactRelationship.count", -1) do
      patch contact_url(@contact), params: {
        contact: {
          contact_relationships_attributes: {
            "0" => {
              id: relationship.id,
              _destroy: "1"
            }
          }
        }
      }
    end

    assert_response :redirect
    assert_nil Aeno::ContactRelationship.find_by(id: relationship.id)
  end

  test "should handle deeply nested structure with timestamp keys" do
    post contacts_url, params: {
      contact: {
        name: "Test Contact",
        email: "test@example.com",
        contact_relationships_attributes: {
          "1234567890" => {
            relation_type: "sibling",
            related_contact_attributes: {
              name: "Related Contact",
              phones_attributes: {
                "9876543210" => { number: "555-1111", phone_type: "mobile" },
                "9876543211" => { number: "555-2222", phone_type: "work" }
              }
            }
          }
        }
      }
    }

    assert_response :redirect
    contact = Aeno::Contact.find_by(name: "Test Contact")
    related = contact.contact_relationships.first.related_contact
    assert_equal 2, related.phones.count
  end

  test "should accept phones as array instead of keyed hash" do
    post contacts_url, params: {
      contact: {
        name: "Array Test",
        email: "array@example.com",
        phones_attributes: [
          { number: "555-ARR-1", phone_type: "mobile" },
          { number: "555-ARR-2", phone_type: "work" }
        ]
      }
    }

    assert_response :redirect
    contact = Aeno::Contact.find_by(name: "Array Test")
    assert_equal 2, contact.phones.count
    assert_equal "555-ARR-1", contact.phones.first.number
  end

  test "should accept deeply nested arrays" do
    post contacts_url, params: {
      contact: {
        name: "Deep Array Test",
        email: "deeparray@example.com",
        phones_attributes: [
          { number: "555-MAIN", phone_type: "mobile" }
        ],
        contact_relationships_attributes: [
          {
            relation_type: "sibling",
            related_contact_attributes: {
              name: "Sibling Array",
              email: "sibarray@example.com",
              phones_attributes: [
                { number: "555-SIB-1", phone_type: "work" },
                { number: "555-SIB-2", phone_type: "mobile" }
              ]
            }
          },
          {
            relation_type: "friend",
            related_contact_attributes: {
              name: "Friend Array",
              email: "friendarray@example.com",
              phones_attributes: [
                { number: "555-FRD", phone_type: "mobile" }
              ]
            }
          }
        ]
      }
    }

    assert_response :redirect
    contact = Aeno::Contact.find_by(name: "Deep Array Test")
    assert_equal 1, contact.phones.count
    assert_equal 2, contact.contact_relationships.count

    sibling = contact.contact_relationships.find_by(relation_type: "sibling").related_contact
    assert_equal 2, sibling.phones.count

    friend = contact.contact_relationships.find_by(relation_type: "friend").related_contact
    assert_equal 1, friend.phones.count
  end

  test "should create related contacts directly without relation_type" do
    assert_difference("Aeno::Contact.count", 3) do # Main + 2 related
      assert_difference("Aeno::ContactRelationship.count", 2) do # 2 automatic joins
        post contacts_url, params: {
          contact: {
            name: "Main Contact",
            email: "main@example.com",
            related_contacts_attributes: {
              "1766135001" => {
                name: "Related One",
                email: "related1@example.com",
                phones_attributes: {
                  "1766135002" => { number: "555-REL1", phone_type: "mobile" }
                }
              },
              "1766135003" => {
                name: "Related Two",
                email: "related2@example.com"
              }
            }
          }
        }
      end
    end

    assert_response :redirect
    contact = Aeno::Contact.find_by(name: "Main Contact")
    assert_equal 2, contact.related_contacts.count
    assert_equal 2, contact.contact_relationships.count

    # Join records should have nil relation_type
    contact.contact_relationships.each do |rel|
      assert_nil rel.relation_type
    end

    related_one = contact.related_contacts.find_by(name: "Related One")
    assert_equal 1, related_one.phones.count
  end

  test "should accept mixed direct related_contacts and explicit contact_relationships" do
    post contacts_url, params: {
      contact: {
        name: "Mixed Contact",
        email: "mixed@example.com",
        related_contacts_attributes: {
          "1766135010" => { name: "Direct Related", email: "direct@example.com" }
        },
        contact_relationships_attributes: {
          "1766135011" => {
            relation_type: "sibling",
            related_contact_attributes: {
              name: "Explicit Sibling",
              email: "sibling@example.com"
            }
          }
        }
      }
    }

    assert_response :redirect
    contact = Aeno::Contact.find_by(name: "Mixed Contact")
    assert_equal 2, contact.related_contacts.count

    assert_equal 1, contact.contact_relationships.where(relation_type: nil).count
    assert_equal 1, contact.contact_relationships.where(relation_type: "sibling").count
  end
end
