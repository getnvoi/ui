require "test_helper"

class ContactTest < ActiveSupport::TestCase
  test "create contact with nested siblings and phones" do
    contact_params = {
      name: "John Doe",
      email: "john@example.com",
      siblings_attributes: {
        "0" => {
          name: "Alice",
          age: 25,
          phones_attributes: {
            "0" => { number: "555-0001", phone_type: "mobile" },
            "1" => { number: "555-0002", phone_type: "work" }
          }
        },
        "1" => {
          name: "Bob",
          age: 30,
          phones_attributes: {
            "0" => { number: "555-0011", phone_type: "mobile" }
          }
        },
        "2" => {
          name: "Carol",
          age: 28
        }
      }
    }

    contact = Contact.create!(contact_params)

    assert_equal "John Doe", contact.name
    assert_equal "john@example.com", contact.email
    assert_equal 3, contact.siblings.count

    alice = contact.siblings.find_by(name: "Alice")
    assert_equal 25, alice.age
    assert_equal 2, alice.phones.count
    assert_equal "555-0001", alice.phones.find_by(phone_type: "mobile").number

    bob = contact.siblings.find_by(name: "Bob")
    assert_equal 1, bob.phones.count

    carol = contact.siblings.find_by(name: "Carol")
    assert_equal 0, carol.phones.count
  end

  test "update contact with existing nested records" do
    contact = Contact.create!(name: "John", email: "john@example.com")
    sibling = contact.siblings.create!(name: "Alice", age: 25)
    phone = sibling.phones.create!(number: "555-0001", phone_type: "mobile")

    update_params = {
      name: "John Updated",
      siblings_attributes: {
        "0" => {
          id: sibling.id,
          name: "Alice Updated",
          age: 26,
          phones_attributes: {
            "0" => {
              id: phone.id,
              number: "555-0001-UPDATED",
              phone_type: "work"
            }
          }
        }
      }
    }

    contact.update!(update_params)

    assert_equal "John Updated", contact.name
    assert_equal "Alice Updated", sibling.reload.name
    assert_equal 26, sibling.age
    assert_equal "555-0001-UPDATED", phone.reload.number
    assert_equal "work", phone.phone_type
  end

  test "add new nested records to existing contact" do
    contact = Contact.create!(name: "John", email: "john@example.com")
    sibling = contact.siblings.create!(name: "Alice", age: 25)

    update_params = {
      siblings_attributes: {
        "0" => {
          id: sibling.id,
          name: "Alice",
          age: 25,
          phones_attributes: {
            "0" => { number: "555-NEW", phone_type: "mobile" }
          }
        },
        "1" => {
          name: "New Sibling",
          age: 30
        }
      }
    }

    contact.update!(update_params)

    assert_equal 2, contact.siblings.count
    assert_equal 1, sibling.reload.phones.count
    assert_equal "555-NEW", sibling.phones.first.number

    new_sibling = contact.siblings.find_by(name: "New Sibling")
    assert_not_nil new_sibling
    assert_equal 30, new_sibling.age
  end

  test "destroy nested records with _destroy flag" do
    contact = Contact.create!(name: "John", email: "john@example.com")
    sibling1 = contact.siblings.create!(name: "Alice", age: 25)
    sibling2 = contact.siblings.create!(name: "Bob", age: 30)
    phone1 = sibling1.phones.create!(number: "555-0001", phone_type: "mobile")
    phone2 = sibling1.phones.create!(number: "555-0002", phone_type: "work")

    update_params = {
      siblings_attributes: {
        "0" => {
          id: sibling1.id,
          phones_attributes: {
            "0" => {
              id: phone1.id,
              _destroy: "1"
            },
            "1" => {
              id: phone2.id,
              _destroy: "0"
            }
          }
        },
        "1" => {
          id: sibling2.id,
          _destroy: "1"
        }
      }
    }

    contact.update!(update_params)

    assert_equal 1, contact.siblings.count
    assert_equal sibling1, contact.siblings.first
    assert_equal 1, sibling1.reload.phones.count
    assert_equal phone2, sibling1.phones.first
    assert_nil Sibling.find_by(id: sibling2.id)
    assert_nil Phone.find_by(id: phone1.id)
  end

  test "deeply nested update with mixed operations" do
    contact = Contact.create!(name: "John", email: "john@example.com")
    sibling1 = contact.siblings.create!(name: "Alice", age: 25)
    phone1 = sibling1.phones.create!(number: "555-0001", phone_type: "mobile")

    update_params = {
      name: "John Updated",
      siblings_attributes: {
        "0" => {
          id: sibling1.id,
          name: "Alice Updated",
          phones_attributes: {
            "0" => {
              id: phone1.id,
              number: "555-UPDATED"
            },
            "1" => {
              number: "555-NEW-1",
              phone_type: "work"
            },
            "2" => {
              number: "555-NEW-2",
              phone_type: "home"
            }
          }
        },
        "1" => {
          name: "New Sibling",
          age: 30,
          phones_attributes: {
            "0" => {
              number: "555-NEW-SIBLING",
              phone_type: "mobile"
            }
          }
        }
      }
    }

    contact.update!(update_params)

    assert_equal "John Updated", contact.name
    assert_equal 2, contact.siblings.count
    assert_equal 3, sibling1.reload.phones.count
    assert_equal "555-UPDATED", phone1.reload.number

    new_sibling = contact.siblings.find_by(name: "New Sibling")
    assert_equal 1, new_sibling.phones.count
    assert_equal "555-NEW-SIBLING", new_sibling.phones.first.number
  end

  test "works with timestamp-based keys instead of sequential indices" do
    contact_params = {
      name: "John Doe",
      email: "john@example.com",
      siblings_attributes: {
        "1234567890" => {
          name: "Alice",
          age: 25,
          phones_attributes: {
            "9876543210" => { number: "555-0001", phone_type: "mobile" },
            "9876543211" => { number: "555-0002", phone_type: "work" }
          }
        },
        "1234567891" => {
          name: "Bob",
          age: 30
        }
      }
    }

    contact = Contact.create!(contact_params)

    assert_equal 2, contact.siblings.count
    alice = contact.siblings.find_by(name: "Alice")
    assert_equal 2, alice.phones.count
  end
end
