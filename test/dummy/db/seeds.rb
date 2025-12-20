# Clear existing contacts
Aeno::Contact.destroy_all

# Create sample contacts
contacts = [
  {
    name: "Alice Johnson",
    email: "alice@example.com",
    city: "San Francisco",
    state: "CA"
  },
  {
    name: "Bob Smith",
    email: "bob@example.com",
    city: "New York",
    state: "NY"
  },
  {
    name: "Carol Williams",
    email: "carol@example.com",
    city: "Austin",
    state: "TX"
  },
  {
    name: "David Brown",
    email: "david@example.com",
    city: "Seattle",
    state: "WA"
  },
  {
    name: "Eve Davis",
    email: "eve@example.com",
    city: "Boston",
    state: "MA"
  }
]

contacts.each do |contact_data|
  Aeno::Contact.create!(contact_data)
end

puts "Created #{Aeno::Contact.count} sample contacts"
